import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/repositories/settings_repository.dart';
import 'package:sticker_world/domain/pin_service.dart';

import '../support/test_database.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository settings;
  late FakeClock clock;
  late PinService pin;

  setUp(() {
    db = createTestDatabase();
    settings = SettingsRepository(db);
    clock = FakeClock();
    pin = PinService(settings, clock: clock.call, random: Random(7));
  });

  tearDown(() => db.close());

  test('PIN을 만들면 확인할 수 있다', () async {
    expect(await pin.hasPin(), isFalse);

    await pin.createPin('1234');

    expect(await pin.hasPin(), isTrue);
    expect((await pin.verifyPin('1234')).isOk, isTrue);
  });

  test('PIN은 평문이 아니라 해시로 저장된다', () async {
    await pin.createPin('1234');

    final stored = await settings.get('pin_hash');
    expect(stored, isNotNull);
    expect(stored, isNot('1234'));
    expect(stored, isNot(contains('1234')));
    expect(stored!.length, 64); // SHA-256 16진수
  });

  test('PIN 형식이 아니면 거절한다', () async {
    expect(() => pin.createPin('123'), throwsArgumentError);
    expect(() => pin.createPin('12a4'), throwsArgumentError);
    expect(() => pin.createPin('12345'), throwsArgumentError);
  });

  test('틀리면 남은 기회를 알려 주고, 다섯 번째에 1분 잠긴다', () async {
    await pin.createPin('1234');

    final first = await pin.verifyPin('0000');
    expect(first.outcome, PinOutcome.wrong);
    expect(first.triesLeft, 4);

    for (var i = 0; i < 3; i++) {
      await pin.verifyPin('0000');
    }
    final fifth = await pin.verifyPin('0000');
    expect(fifth.outcome, PinOutcome.locked);
    expect(fifth.lockedFor, const Duration(minutes: 1));
  });

  test('잠긴 동안에는 맞는 PIN도 받지 않는다', () async {
    await pin.createPin('1234');
    for (var i = 0; i < 5; i++) {
      await pin.verifyPin('0000');
    }

    final during = await pin.verifyPin('1234');

    expect(during.outcome, PinOutcome.locked);
    expect(await pin.pinLockRemaining(), greaterThan(Duration.zero));
  });

  test('잠금이 풀린 뒤 또 틀리면 잠금 시간이 두 배가 된다', () async {
    await pin.createPin('1234');
    for (var i = 0; i < 5; i++) {
      await pin.verifyPin('0000');
    }
    clock.advance(const Duration(minutes: 1, seconds: 1));

    final sixth = await pin.verifyPin('0000');

    expect(sixth.outcome, PinOutcome.locked);
    expect(sixth.lockedFor, const Duration(minutes: 2));
  });

  test('맞히면 틀린 횟수가 0으로 돌아간다', () async {
    await pin.createPin('1234');
    await pin.verifyPin('0000');
    await pin.verifyPin('0000');

    await pin.verifyPin('1234');

    final next = await pin.verifyPin('0000');
    expect(next.triesLeft, 4);
  });

  group('복구 코드', () {
    test('복구 코드는 12자리이고 XXXX-XXXX-XXXX 형식으로 나온다', () async {
      final code = await pin.createPin('1234');

      expect(code, matches(RegExp(r'^[A-Z2-9]{4}-[A-Z2-9]{4}-[A-Z2-9]{4}$')));
      expect(PinService.isValidRecoveryCodeFormat(code), isTrue);
    });

    test('복구 코드로 새 PIN을 만들면 새 복구 코드를 준다', () async {
      final code = await pin.createPin('1234');

      final result = await pin.resetPinWithRecovery(
        recoveryCode: code,
        newPin: '5678',
      );

      expect(result.isOk, isTrue);
      expect(result.newRecoveryCode, isNotNull);
      expect(result.newRecoveryCode, isNot(code));
      expect((await pin.verifyPin('5678')).isOk, isTrue);
      expect((await pin.verifyPin('1234')).isOk, isFalse);
    });

    test('바뀐 뒤에는 예전 복구 코드를 쓸 수 없다', () async {
      final oldCode = await pin.createPin('1234');
      await pin.resetPinWithRecovery(recoveryCode: oldCode, newPin: '5678');

      final check = await pin.verifyRecoveryCode(oldCode);

      expect(check.outcome, PinOutcome.wrong);
    });

    test('하이픈과 대소문자, 공백은 무시한다', () async {
      final code = await pin.createPin('1234');
      final messy = code.toLowerCase().replaceAll('-', ' ');

      final result = await pin.resetPinWithRecovery(
        recoveryCode: messy,
        newPin: '0909',
      );

      expect(result.isOk, isTrue);
    });

    test('복구 코드를 다섯 번 틀리면 10분 잠긴다', () async {
      await pin.createPin('1234');
      final wrong = PinService.formatRecoveryCode('AAAAAAAAAAAA');

      PinCheck? last;
      for (var i = 0; i < 5; i++) {
        last = await pin.verifyRecoveryCode(wrong);
      }

      expect(last!.outcome, PinOutcome.locked);
      expect(last.lockedFor, const Duration(minutes: 10));
      expect(await pin.recoveryLockRemaining(), greaterThan(Duration.zero));
    });

    test('복구 코드가 틀리면 PIN은 바뀌지 않는다', () async {
      await pin.createPin('1234');

      final result = await pin.resetPinWithRecovery(
        recoveryCode: 'AAAA-AAAA-AAAA',
        newPin: '5678',
      );

      expect(result.isOk, isFalse);
      expect((await pin.verifyPin('1234')).isOk, isTrue);
    });

    test('형식을 바꿔 주는 함수는 4글자씩 끊어 하이픈을 넣는다', () {
      expect(PinService.formatRecoveryCode('k7qm2xpa9wrt'), 'K7QM-2XPA-9WRT');
    });

    test('헷갈리는 글자 0, O, 1, I가 들어가면 형식이 틀린 것이다', () {
      expect(PinService.isValidRecoveryCodeFormat('K0QM-2XPA-9WRT'), isFalse);
      expect(PinService.isValidRecoveryCodeFormat('K7QM-2XPA-9WR'), isFalse);
    });
  });
}
