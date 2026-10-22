import 'package:flutter/material.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/outlined_text.dart';

/// 금색 배지 메달. 얻은 배지는 [child] 그림, 못 얻은 배지는 '?'로 보인다.
class GoldMedal extends StatelessWidget {
  const GoldMedal({super.key, this.size = 90, this.locked = false, this.child});

  final double size;
  final bool locked;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: locked ? _lockedGradient : _goldGradient,
        border: Border.all(color: const Color(0xFF9A6400), width: size * 0.05),
        boxShadow: [
          BoxShadow(
            color: const Color(0x33000000),
            offset: Offset(0, size * 0.05),
          ),
        ],
      ),
      child: locked
          ? OutlinedText(
              '?',
              fontFamily: 'LilitaOne',
              fontSize: size * 0.45,
              color: const Color(0xFFFFF4C2),
              outlineColor: const Color(0xFF9A6400),
              outlineWidth: 2,
            )
          : child,
    );
  }

  static const _goldGradient = RadialGradient(
    center: Alignment(-0.3, -0.4),
    radius: 0.9,
    colors: [Color(0xFFFFF4B8), Color(0xFFF5B800), Color(0xFFC98A00)],
    stops: [0, 0.55, 1],
  );

  static const _lockedGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.goldDeep, Color(0xFFB08A1A)],
  );
}
