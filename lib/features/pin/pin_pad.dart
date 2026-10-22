import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/jelly_button.dart';
import 'package:sticker_world/domain/pin_service.dart';

/// 숫자 키패드. 숫자 위치가 누를 때마다 바뀌어서 아이가 손 위치로 외울 수 없다 (PLAN.md 7장).
/// 4자리를 다 누르면 [onCompleted]가 불리고, 입력은 자동으로 지워진다.
class PinPad extends StatefulWidget {
  const PinPad({
    super.key,
    required this.onCompleted,
    this.enabled = true,
    this.random,
  });

  final ValueChanged<String> onCompleted;
  final bool enabled;

  /// 테스트에서 섞는 순서를 고정하려고 넣었다.
  final Random? random;

  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> {
  late final Random _random = widget.random ?? Random();
  late List<String> _digits = _shuffledDigits();
  String _entered = '';

  List<String> _shuffledDigits() {
    return List.generate(10, (i) => '$i')..shuffle(_random);
  }

  void _press(String digit) {
    if (!widget.enabled) {
      return;
    }
    final next = _entered + digit;
    if (next.length < PinService.pinLength) {
      setState(() => _entered = next);
      return;
    }
    setState(() {
      _entered = '';
      _digits = _shuffledDigits();
    });
    widget.onCompleted(next);
  }

  void _backspace() {
    if (!widget.enabled || _entered.isEmpty) {
      return;
    }
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Dots(filled: _entered.length),
        const SizedBox(height: 24),
        for (var row = 0; row < 4; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                for (var col = 0; col < 3; col++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: _cell(row * 3 + col),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  /// 칸 0~8은 숫자, 9는 빈칸, 10은 마지막 숫자, 11은 지우기.
  Widget _cell(int slot) {
    if (slot == 9) {
      return const SizedBox(height: 96);
    }
    if (slot == 11) {
      return JellyButton(
        key: const ValueKey('pin-backspace'),
        color: AppColors.mint,
        height: 96,
        semanticLabel: '지우기',
        onTap: widget.enabled ? _backspace : null,
        child: const Center(
          child: Icon(Icons.backspace_rounded, size: 38, color: AppColors.ink),
        ),
      );
    }
    final digit = slot < 9 ? _digits[slot] : _digits[9];
    return JellyButton(
      key: ValueKey('pin-$digit'),
      color: AppColors.white,
      height: 96,
      semanticLabel: '숫자 $digit',
      onTap: widget.enabled ? () => _press(digit) : null,
      child: Center(
        child: Text(
          digit,
          style: const TextStyle(fontSize: 40, color: AppColors.ink),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.filled});

  final int filled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < PinService.pinLength; i++)
          Container(
            width: 26,
            height: 26,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < filled ? AppColors.red : AppColors.white,
              border: Border.all(color: AppColors.ink, width: 3),
            ),
          ),
      ],
    );
  }
}
