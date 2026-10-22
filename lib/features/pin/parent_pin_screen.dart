import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sticker_world/core/router/routes.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/jelly_button.dart';
import 'package:sticker_world/core/widgets/pattern_background.dart';
import 'package:sticker_world/core/widgets/screen_frame.dart';
import 'package:sticker_world/core/widgets/white_frame_card.dart';
import 'package:sticker_world/data/providers.dart';
import 'package:sticker_world/domain/pin_service.dart';
import 'package:sticker_world/features/pin/pin_pad.dart';

/// 부모 PIN을 맞춰야 true가 된다. 스티커 붙이기·빼기·부모 모드는 모두 이 화면을 거친다.
Future<bool> requireParentPin(BuildContext context) async {
  final ok = await context.push<bool>(Routes.pin);
  return ok ?? false;
}

/// 홈의 🔔을 3초 길게 누르면 부모 모드로 들어간다.
Future<void> openParentMode(BuildContext context) async {
  final ok = await requireParentPin(context);
  if (ok && context.mounted) {
    await context.push(Routes.parent);
  }
}

class ParentPinScreen extends ConsumerStatefulWidget {
  const ParentPinScreen({super.key});

  @override
  ConsumerState<ParentPinScreen> createState() => _ParentPinScreenState();
}

class _ParentPinScreenState extends ConsumerState<ParentPinScreen> {
  String? _message;
  bool _checking = false;
  Duration _lockLeft = Duration.zero;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _loadLock();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _loadLock() async {
    final left = await ref.read(pinServiceProvider).pinLockRemaining();
    if (left > Duration.zero) {
      _startCountdown(left);
    }
  }

  void _startCountdown(Duration left) {
    _ticker?.cancel();
    setState(() => _lockLeft = left);
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      final next = _lockLeft - const Duration(seconds: 1);
      if (next <= Duration.zero) {
        timer.cancel();
        setState(() {
          _lockLeft = Duration.zero;
          _message = null;
        });
      } else {
        setState(() => _lockLeft = next);
      }
    });
  }

  Future<void> _submit(String pin) async {
    setState(() {
      _checking = true;
      _message = null;
    });
    final check = await ref.read(pinServiceProvider).verifyPin(pin);
    if (!mounted) {
      return;
    }
    switch (check.outcome) {
      case PinOutcome.ok:
        context.pop(true);
      case PinOutcome.wrong:
        setState(() {
          _checking = false;
          _message = '비밀번호가 달라요. 남은 기회는 ${check.triesLeft}번이에요.';
        });
      case PinOutcome.locked:
        setState(() => _checking = false);
        _startCountdown(check.lockedFor);
        setState(() => _message = '여러 번 틀려서 잠시 쉬어요.');
    }
  }

  Future<void> _forgotPin() async {
    final ok = await context.push<bool>(Routes.pinRecovery);
    if (ok == true && mounted) {
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = _lockLeft > Duration.zero;

    return Stack(
      fit: StackFit.expand,
      children: [
        ScreenFrame(
          title: '엄마·아빠 비밀번호',
          color: AppColors.purple,
          pattern: BgPattern.dots,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: WhiteFrameCard(
                headerTitle: '부모 확인',
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PinPad(
                      enabled: !locked && !_checking,
                      onCompleted: _submit,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 56,
                      child: Center(
                        child: Text(
                          locked ? _lockText(_lockLeft) : (_message ?? ''),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            color: AppColors.misdeed,
                          ),
                        ),
                      ),
                    ),
                    JellyButton(
                      color: AppColors.gold,
                      height: 64,
                      semanticLabel: '비밀번호를 잊었어요',
                      onTap: _forgotPin,
                      child: const Center(
                        child: Text(
                          '비밀번호를 잊었어요',
                          style: TextStyle(fontSize: 24, color: AppColors.ink),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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

  static String _lockText(Duration left) {
    final minutes = left.inMinutes.toString().padLeft(2, '0');
    final seconds = (left.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds 뒤에 다시 입력할 수 있어요.';
  }
}
