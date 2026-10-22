import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:sticker_world/data/repositories/settings_repository.dart';

enum PinOutcome { ok, wrong, locked }

/// PIN 확인 결과. wrong이면 남은 기회, locked이면 남은 잠금 시간을 담는다.
class PinCheck {
  const PinCheck(
    this.outcome, {
    this.triesLeft = 0,
    this.lockedFor = Duration.zero,
    this.newRecoveryCode,
  });

  final PinOutcome outcome;
  final int triesLeft;
  final Duration lockedFor;

  /// 복구 코드로 PIN을 바꾼 경우에만 채워진다. 이 코드는 한 번만 보여 준다.
  final String? newRecoveryCode;

  bool get isOk => outcome == PinOutcome.ok;
}

/// 부모 PIN과 복구 코드 (PLAN.md 7장).
/// - PIN은 솔트 + SHA-256 해시로만 저장한다 (CLAUDE.md).
/// - PIN 5번 틀리면 1분 잠금, 그 뒤 틀릴 때마다 잠금 시간이 2배.
/// - 복구 코드는 12자리. 5번 틀리면 10분 잠금, 같은 방식으로 늘어난다.
class PinService {
  PinService(this._settings, {DateTime Function()? clock, Random? random})
    : _clock = clock ?? DateTime.now,
      _random = random ?? Random.secure();

  static const pinLength = 4;
  static const recoveryCodeLength = 12;
  static const _maxFailures = 5;
  static const _pinBaseLock = Duration(minutes: 1);
  static const _recoveryBaseLock = Duration(minutes: 10);
  static const _maxLockSteps = 10;

  // 헷갈리는 글자(0, O, 1, I)는 뺐다.
  static const _codeAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  static const _pinSalt = 'pin_salt';
  static const _pinHash = 'pin_hash';
  static const _pinFailed = 'pin_failed';
  static const _pinLockedUntil = 'pin_locked_until';
  static const _recoverySalt = 'recovery_salt';
  static const _recoveryHash = 'recovery_hash';
  static const _recoveryFailed = 'recovery_failed';
  static const _recoveryLockedUntil = 'recovery_locked_until';

  final SettingsRepository _settings;
  final DateTime Function() _clock;
  final Random _random;

  Future<bool> hasPin() async => (await _settings.get(_pinHash)) != null;

  /// 새 PIN을 저장하고, 새 복구 코드를 만들어 돌려준다.
  /// 복구 코드는 이 순간에만 보여 주고 다시 볼 수 없다.
  Future<String> createPin(String pin) async {
    _checkPinFormat(pin);
    final pinSalt = _newSalt();
    await _settings.set(_pinSalt, pinSalt);
    await _settings.set(_pinHash, _hash(pinSalt, pin));
    await _resetCounters(_pinFailed, _pinLockedUntil);

    return _storeNewRecoveryCode();
  }

  /// PIN을 확인한다. 맞으면 실패 횟수를 0으로 되돌린다.
  Future<PinCheck> verifyPin(String pin) {
    return _check(
      input: pin,
      saltKey: _pinSalt,
      hashKey: _pinHash,
      failedKey: _pinFailed,
      lockedUntilKey: _pinLockedUntil,
      baseLock: _pinBaseLock,
    );
  }

  /// PIN을 잊었을 때: 복구 코드가 맞으면 새 PIN으로 바꾸고 새 복구 코드를 만든다.
  Future<PinCheck> resetPinWithRecovery({
    required String recoveryCode,
    required String newPin,
  }) async {
    _checkPinFormat(newPin);
    final check = await verifyRecoveryCode(recoveryCode);
    if (!check.isOk) {
      return check;
    }

    final newCode = await createPin(newPin);
    return PinCheck(PinOutcome.ok, newRecoveryCode: newCode);
  }

  /// 복구 코드만 확인한다. PIN은 바꾸지 않는다. 복구 화면에서 새 PIN을 고르기 전에 쓴다.
  Future<PinCheck> verifyRecoveryCode(String recoveryCode) {
    return _check(
      input: _normalizeCode(recoveryCode),
      saltKey: _recoverySalt,
      hashKey: _recoveryHash,
      failedKey: _recoveryFailed,
      lockedUntilKey: _recoveryLockedUntil,
      baseLock: _recoveryBaseLock,
    );
  }

  /// PIN 입력이 잠겨 있으면 남은 시간, 아니면 0.
  Future<Duration> pinLockRemaining() => _lockRemaining(_pinLockedUntil);

  /// 복구 코드 입력이 잠겨 있으면 남은 시간, 아니면 0.
  Future<Duration> recoveryLockRemaining() =>
      _lockRemaining(_recoveryLockedUntil);

  /// 복구 코드 형식이 맞는지 (하이픈·공백·대소문자는 무시).
  static bool isValidRecoveryCodeFormat(String input) {
    final normalized = _normalizeCode(input);
    if (normalized.length != recoveryCodeLength) {
      return false;
    }
    return normalized.split('').every(_codeAlphabet.contains);
  }

  /// 사람이 보는 형식으로 바꾼다. 'K7QM2XPA9WRT' → 'K7QM-2XPA-9WRT'.
  static String formatRecoveryCode(String code) {
    final normalized = _normalizeCode(code);
    final groups = <String>[];
    for (var i = 0; i < normalized.length; i += 4) {
      groups.add(normalized.substring(i, min(i + 4, normalized.length)));
    }
    return groups.join('-');
  }

  Future<String> _storeNewRecoveryCode() async {
    final code = _newRecoveryCode();
    final recoverySalt = _newSalt();
    await _settings.set(_recoverySalt, recoverySalt);
    await _settings.set(_recoveryHash, _hash(recoverySalt, code));
    await _resetCounters(_recoveryFailed, _recoveryLockedUntil);
    return formatRecoveryCode(code);
  }

  Future<PinCheck> _check({
    required String input,
    required String saltKey,
    required String hashKey,
    required String failedKey,
    required String lockedUntilKey,
    required Duration baseLock,
  }) async {
    final now = _clock();
    final remaining = await _lockRemaining(lockedUntilKey);
    if (remaining > Duration.zero) {
      return PinCheck(PinOutcome.locked, lockedFor: remaining);
    }

    final salt = await _settings.get(saltKey);
    final expected = await _settings.get(hashKey);
    if (salt == null || expected == null) {
      throw StateError('아직 PIN이 만들어지지 않았어요.');
    }

    if (_hash(salt, input) == expected) {
      await _resetCounters(failedKey, lockedUntilKey);
      return const PinCheck(PinOutcome.ok);
    }

    final failures = await _settings.getInt(failedKey) + 1;
    await _settings.set(failedKey, '$failures');
    if (failures < _maxFailures) {
      return PinCheck(PinOutcome.wrong, triesLeft: _maxFailures - failures);
    }

    // 5번째부터 잠금. 이후 틀릴 때마다 잠금 시간이 2배.
    final steps = min(failures - _maxFailures, _maxLockSteps);
    final lock = baseLock * (1 << steps);
    await _settings.set(
      lockedUntilKey,
      '${now.add(lock).millisecondsSinceEpoch}',
    );
    return PinCheck(PinOutcome.locked, lockedFor: lock);
  }

  Future<Duration> _lockRemaining(String lockedUntilKey) async {
    final lockedUntilMs = await _settings.getInt(lockedUntilKey);
    final remainingMs = lockedUntilMs - _clock().millisecondsSinceEpoch;
    return remainingMs > 0
        ? Duration(milliseconds: remainingMs)
        : Duration.zero;
  }

  Future<void> _resetCounters(String failedKey, String lockedUntilKey) async {
    await _settings.set(failedKey, '0');
    await _settings.set(lockedUntilKey, '0');
  }

  String _newSalt() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return base64Url.encode(bytes);
  }

  String _newRecoveryCode() {
    return List.generate(
      recoveryCodeLength,
      (_) => _codeAlphabet[_random.nextInt(_codeAlphabet.length)],
    ).join();
  }

  static String _hash(String salt, String input) {
    return sha256.convert(utf8.encode('$salt:$input')).toString();
  }

  static String _normalizeCode(String input) {
    return input.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
  }

  static void _checkPinFormat(String pin) {
    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      throw ArgumentError.value(pin, 'pin', 'PIN은 숫자 4자리여야 해요.');
    }
  }
}
