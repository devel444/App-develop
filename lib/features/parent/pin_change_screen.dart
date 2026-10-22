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
import 'package:sticker_world/features/pin/pin_pad.dart';

enum _Step { first, confirm, done }

/// 부모 비밀번호 바꾸기 (부모 모드 안에서만). 새 번호를 두 번 누르면 바뀌고,
/// 새 복구 코드를 한 번 보여 준다. 예전 복구 코드는 못 쓰게 된다.
class PinChangeScreen extends ConsumerStatefulWidget {
  const PinChangeScreen({super.key});

  @override
  ConsumerState<PinChangeScreen> createState() => _PinChangeScreenState();
}

class _PinChangeScreenState extends ConsumerState<PinChangeScreen> {
  _Step _step = _Step.first;
  String _first = '';
  String _recoveryCode = '';
  String? _message;
  bool _saving = false;

  void _onFirst(String pin) {
    setState(() {
      _first = pin;
      _message = null;
      _step = _Step.confirm;
    });
  }

  Future<void> _onConfirm(String pin) async {
    if (pin != _first) {
      setState(() {
        _message = '처음 입력과 달라요. 다시 정해 주세요.';
        _step = _Step.first;
      });
      return;
    }
    setState(() => _saving = true);
    final code = await ref.read(pinServiceProvider).createPin(pin);
    if (!mounted) {
      return;
    }
    setState(() {
      _saving = false;
      _recoveryCode = code;
      _step = _Step.done;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      title: '비밀번호 바꾸기',
      color: AppColors.purple,
      pattern: BgPattern.dots,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: WhiteFrameCard(
            headerTitle: switch (_step) {
              _Step.first => '새 번호',
              _Step.confirm => '한 번 더',
              _Step.done => '새 복구 코드',
            },
            child: switch (_step) {
              _Step.first => _pad('새 4자리 숫자를 누르세요.', _onFirst),
              _Step.confirm => _pad('같은 번호를 한 번 더 누르세요.', _onConfirm),
              _Step.done => _done(),
            },
          ),
        ),
      ),
    );
  }

  Widget _pad(String prompt, ValueChanged<String> onCompleted) {
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
        if (_message != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _message!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, color: AppColors.misdeed),
            ),
          ),
      ],
    );
  }

  Widget _done() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '새 번호로 바꿨어요.\n이 복구 코드는 지금 한 번만 보여 줘요. 사진으로 찍어 두세요.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, height: 1.4, color: AppColors.ink),
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
          semanticLabel: '돌아가기',
          onTap: () => context.pop(),
          child: const Center(child: OutlinedText('사진으로 찍어 뒀어요', fontSize: 26)),
        ),
      ],
    );
  }
}
