import 'package:flutter/material.dart';

/// 화면 배경 무늬. 탭마다 색과 무늬가 다르다 (PLAN.md 8장).
enum BgPattern { dots, stripes }

class PatternBackground extends StatelessWidget {
  const PatternBackground({
    super.key,
    required this.color,
    required this.child,
    this.pattern = BgPattern.dots,
  });

  final Color color;
  final Widget child;
  final BgPattern pattern;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _PatternPainter(color: color, pattern: pattern),
          ),
        ),
        child,
      ],
    );
  }
}

class _PatternPainter extends CustomPainter {
  const _PatternPainter({required this.color, required this.pattern});

  final Color color;
  final BgPattern pattern;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = color);

    switch (pattern) {
      case BgPattern.dots:
        const step = 34.0;
        final dot = Paint()..color = const Color(0x26FFFFFF);
        for (var y = step / 2; y < size.height; y += step) {
          for (var x = step / 2; x < size.width; x += step) {
            canvas.drawCircle(Offset(x, y), 6, dot);
          }
        }
      case BgPattern.stripes:
        const band = 44.0;
        final stripe = Paint()..color = const Color(0x1AFFFFFF);
        for (var x = -size.height; x < size.width; x += band * 2) {
          final path = Path()
            ..moveTo(x, 0)
            ..lineTo(x + band, 0)
            ..lineTo(x + band + size.height, size.height)
            ..lineTo(x + size.height, size.height)
            ..close();
          canvas.drawPath(path, stripe);
        }
    }
  }

  @override
  bool shouldRepaint(_PatternPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.pattern != pattern;
  }
}
