import 'package:flutter/material.dart';

/// 스티커 코인 아이콘 (금색 동전 + 가운데 홈).
class CoinIcon extends StatelessWidget {
  const CoinIcon({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.3, -0.4),
          colors: [Color(0xFFFFF4B8), Color(0xFFFFC93B), Color(0xFFE09A00)],
        ),
        border: Border.all(color: const Color(0xFF8A5A00), width: size * 0.06),
      ),
      child: Container(
        width: size * 0.16,
        height: size * 0.56,
        decoration: BoxDecoration(
          color: const Color(0xFFC98A00),
          borderRadius: BorderRadius.circular(size * 0.08),
        ),
      ),
    );
  }
}
