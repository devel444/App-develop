import 'package:flutter/material.dart';
import 'package:sticker_world/core/theme/app_colors.dart';

/// 홈 배경 풍경: 하늘, 구름, 언덕, 성. 화면 크기에 비례해서 그린다.
class HomeLandscapePainter extends CustomPainter {
  const HomeLandscapePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF2B8BDD), Color(0xFF7CC4F2)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, sky);

    final cloud = Paint()..color = AppColors.white;
    _drawCloud(canvas, cloud, Offset(w * 0.80, h * 0.20), w * 0.26, h);
    _drawCloud(canvas, cloud, Offset(w * 0.92, h * 0.33), w * 0.16, h);
    _drawCloud(canvas, cloud, Offset(w * 0.10, h * 0.44), w * 0.22, h);

    canvas.drawOval(
      Rect.fromLTWH(-w * 0.25, h * 0.56, w * 0.9, h * 0.5),
      Paint()..color = const Color(0xFF5AB53A),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.35, h * 0.60, w * 0.95, h * 0.5),
      Paint()..color = const Color(0xFF6CC24A),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.72, w, h * 0.28),
      Paint()..color = AppColors.grass,
    );

    _drawCastle(canvas, w, h);
  }

  void _drawCloud(
    Canvas canvas,
    Paint paint,
    Offset center,
    double width,
    double h,
  ) {
    final height = h * 0.05;
    final rect = Rect.fromCenter(center: center, width: width, height: height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(height / 2)),
      paint,
    );
  }

  void _drawCastle(Canvas canvas, double w, double h) {
    final x = w * 0.05;
    final stone = Paint()..color = const Color(0xFFF4F6FB);
    final roof = Paint()..color = AppColors.pink;
    final door = Paint()..color = AppColors.red;

    // 본관과 탑 세 개
    canvas.drawRect(Rect.fromLTWH(x, h * 0.60, w * 0.30, h * 0.13), stone);
    canvas.drawRect(
      Rect.fromLTWH(x + w * 0.04, h * 0.52, w * 0.07, h * 0.21),
      stone,
    );
    canvas.drawRect(
      Rect.fromLTWH(x + w * 0.19, h * 0.52, w * 0.07, h * 0.21),
      stone,
    );
    canvas.drawRect(
      Rect.fromLTWH(x + w * 0.11, h * 0.45, w * 0.08, h * 0.28),
      stone,
    );

    // 지붕 세 개
    canvas.drawPath(_roof(x + w * 0.04, h * 0.52, w * 0.07), roof);
    canvas.drawPath(_roof(x + w * 0.19, h * 0.52, w * 0.07), roof);
    canvas.drawPath(_roof(x + w * 0.11, h * 0.45, w * 0.08), roof);

    // 문
    canvas.drawRect(
      Rect.fromLTWH(x + w * 0.12, h * 0.66, w * 0.05, h * 0.07),
      door,
    );
  }

  Path _roof(double left, double top, double width) {
    return Path()
      ..moveTo(left, top)
      ..lineTo(left + width / 2, top - width * 0.6)
      ..lineTo(left + width, top)
      ..close();
  }

  @override
  bool shouldRepaint(HomeLandscapePainter oldDelegate) => false;
}
