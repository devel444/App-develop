import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sticker_world/core/router/routes.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/jelly_button.dart';
import 'package:sticker_world/core/widgets/outlined_text.dart';
import 'package:sticker_world/core/widgets/pattern_background.dart';
import 'package:sticker_world/core/widgets/screen_frame.dart';
import 'package:sticker_world/core/widgets/white_frame_card.dart';
import 'package:sticker_world/data/providers.dart';
import 'package:sticker_world/features/pin/pin_pad.dart';

enum _SetupStep { name, pin, confirmPin, recoveryCode }

/// 처음 실행할 때 한 번만 보인다: 아이 이름 → 부모 PIN 두 번 → 복구 코드 보여 주기.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController();
  _SetupStep _step = _SetupStep.name;
  String _name = '';
  String _firstPin = '';
  String _recoveryCode = '';
  String? _message;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _nextFromName() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _message = '아이 이름을 입력해 주세요.');
      return;
    }
    setState(() {
      _name = name;
      _message = null;
      _step = _SetupStep.pin;
    });
  }

  void _onFirstPin(String pin) {
    setState(() {
      _firstPin = pin;
      _message = null;
      _step = _SetupStep.confirmPin;
    });
  }

  Future<void> _onConfirmPin(String pin) async {
    if (pin != _firstPin) {
      setState(() {
        _message = '처음 입력과 달라요. 다시 정해 주세요.';
        _step = _SetupStep.pin;
      });
      return;
    }
    setState(() => _saving = true);
    await ref.read(childRepositoryProvider).create(name: _name);
    final code = await ref.read(pinServiceProvider).createPin(pin);
    if (!mounted) {
      return;
    }
    setState(() {
      _saving = false;
      _recoveryCode = code;
      _step = _SetupStep.recoveryCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      title: '환영해요!',
      color: AppColors.yellow,
      pattern: BgPattern.dots,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: WhiteFrameCard(headerTitle: _header, child: _body()),
        ),
      ),
    );
  }

  String get _header => switch (_step) {
    _SetupStep.name => '아이 이름',
    _SetupStep.pin => '엄마·아빠 비밀번호',
    _SetupStep.confirmPin => '한 번 더 입력',
    _SetupStep.recoveryCode => '복구 코드',
  };

  Widget _body() {
    return switch (_step) {
      _SetupStep.name => _nameStep(),
      _SetupStep.pin => _pinStep('4자리 숫자를 정해 주세요.', _onFirstPin),
      _SetupStep.confirmPin => _pinStep('같은 번호를 한 번 더 누르세요.', _onConfirmPin),
      _SetupStep.recoveryCode => _recoveryStep(),
    };
  }

  Widget _nameStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '스티커를 모을 아이의 이름이에요.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, color: AppColors.ink),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _nameController,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 32),
          decoration: const InputDecoration(
            hintText: '예: 지우',
            border: OutlineInputBorder(),
          ),
        ),
        _messageText(),
        const SizedBox(height: 16),
        JellyButton(
          color: AppColors.gold,
          height: 72,
          semanticLabel: '다음',
          onTap: _nextFromName,
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
        PinPad(enabled: !_saving, onCompleted: onCompleted),
        _messageText(),
      ],
    );
  }

  Widget _recoveryStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '$_name 스티커판을 만들었어요!\n'
          '비밀번호를 잊으면 이 코드로 다시 만들 수 있어요.\n'
          '지금 한 번만 보여 줘요. 사진으로 찍어 두세요.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            height: 1.4,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          _recoveryCode,
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
          semanticLabel: '시작하기',
          onTap: () => context.go(Routes.home),
          child: const Center(child: OutlinedText('사진으로 찍어 뒀어요', fontSize: 26)),
        ),
      ],
    );
  }

  Widget _messageText() {
    final message = _message;
    if (message == null) {
      return const SizedBox.shrink();
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
