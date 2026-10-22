import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/jelly_button.dart';
import 'package:sticker_world/core/widgets/outlined_text.dart';
import 'package:sticker_world/core/widgets/pattern_background.dart';
import 'package:sticker_world/core/widgets/screen_frame.dart';
import 'package:sticker_world/core/widgets/white_frame_card.dart';
import 'package:sticker_world/data/providers.dart';
import 'package:sticker_world/domain/pin_service.dart';
import 'package:sticker_world/features/pin/pin_pad.dart';

enum _RecoveryStep { code, newPin, confirmPin, done }

/// PIN을 잊었을 때: 복구 코드 입력 → 새 PIN 두 번 → 새 복구 코드 보여 주기.
/// 기록은 그대로 남는다. 성공하면 true로 돌아간다.
class RecoveryScreen extends ConsumerStatefulWidget {
  const RecoveryScreen({super.key});

  @override
  ConsumerState<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends ConsumerState<RecoveryScreen> {
  final _codeController = TextEditingController();
  _RecoveryStep _step = _RecoveryStep.code;
  String _verifiedCode = '';
  String _firstPin = '';
  String _newCode = '';
  String? _message;
  bool _busy = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _checkCode() async {
    final input = _codeController.text;
    if (!PinService.isValidRecoveryCodeFormat(input)) {
      setState(() => _message = '복구 코드 12자리를 입력해 주세요.');
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    final check = await ref.read(pinServiceProvider).verifyRecoveryCode(input);
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    switch (check.outcome) {
      case PinOutcome.ok:
        setState(() {
          _verifiedCode = input;
          _step = _RecoveryStep.newPin;
        });
      case PinOutcome.wrong:
        setState(() => _message = '복구 코드가 달라요. 남은 기회는 ${check.triesLeft}번이에요.');
      case PinOutcome.locked:
        setState(() => _message = '여러 번 틀려서 10분 뒤에 다시 해 주세요.');
    }
  }

  void _onNewPin(String pin) {
    setState(() {
      _firstPin = pin;
      _step = _RecoveryStep.confirmPin;
      _message = null;
    });
  }

  Future<void> _onConfirmPin(String pin) async {
    if (pin != _firstPin) {
      setState(() {
        _step = _RecoveryStep.newPin;
        _message = '처음 입력과 달라요. 다시 정해 주세요.';
      });
      return;
    }
    setState(() => _busy = true);
    final result = await ref
        .read(pinServiceProvider)
        .resetPinWithRecovery(recoveryCode: _verifiedCode, newPin: pin);
    if (!mounted) {
      return;
    }
    setState(() {
      _busy = false;
      _newCode = result.newRecoveryCode ?? '';
      _step = _RecoveryStep.done;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ScreenFrame(
          title: '비밀번호 다시 만들기',
          color: AppColors.purple,
          pattern: BgPattern.dots,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: WhiteFrameCard(headerTitle: _header, child: _body()),
            ),
          ),
        ),
        if (context.canPop())
          Positioned(
            left: 16,
            top: 16,
            child: JellyButton(
              width: 72,
              height: 72,
              color: AppColors.white,
              borderRadius: BorderRadius.circular(36),
              semanticLabel: '뒤로',
              onTap: () => context.pop(false),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 40,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String get _header => switch (_step) {
    _RecoveryStep.code => '복구 코드',
    _RecoveryStep.newPin => '새 비밀번호',
    _RecoveryStep.confirmPin => '한 번 더 입력',
    _RecoveryStep.done => '새 복구 코드',
  };

  Widget _body() {
    return switch (_step) {
      _RecoveryStep.code => _codeStep(),
      _RecoveryStep.newPin => _pinStep('새 비밀번호 4자리를 누르세요.', _onNewPin),
      _RecoveryStep.confirmPin => _pinStep('같은 번호를 한 번 더 누르세요.', _onConfirmPin),
      _RecoveryStep.done => _doneStep(),
    };
  }

  Widget _codeStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '처음 비밀번호를 만들 때 받은 12자리 코드를 입력하세요.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, color: AppColors.ink),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _codeController,
          textCapitalization: TextCapitalization.characters,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 30, letterSpacing: 2),
          decoration: const InputDecoration(
            hintText: 'XXXX-XXXX-XXXX',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        _messageText(),
        const SizedBox(height: 8),
        JellyButton(
          color: AppColors.gold,
          height: 72,
          onTap: _busy ? null : _checkCode,
          child: const Center(child: OutlinedText('다음', fontSize: 30)),
        ),
      ],
    );
  }

  Widget _pinStep(String prompt, ValueChanged<String> onCompleted) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          prompt,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, color: AppColors.ink),
        ),
        const SizedBox(height: 12),
        PinPad(enabled: !_busy, onCompleted: onCompleted),
        _messageText(),
      ],
    );
  }

  Widget _doneStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '새 복구 코드예요. 이전 코드는 이제 쓸 수 없어요. 사진으로 찍어 두세요.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, color: AppColors.ink),
        ),
        const SizedBox(height: 16),
        Text(
          _newCode,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 38,
            letterSpacing: 2,
            color: AppColors.red,
          ),
        ),
        const SizedBox(height: 20),
        JellyButton(
          color: AppColors.gold,
          height: 72,
          onTap: () => context.pop(true),
          child: const Center(child: OutlinedText('사진으로 찍어 뒀어요', fontSize: 26)),
        ),
      ],
    );
  }

  Widget _messageText() {
    final message = _message;
    if (message == null) {
      return const SizedBox(height: 0);
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20, color: AppColors.misdeed),
      ),
    );
  }
}
