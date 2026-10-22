import 'package:flutter/material.dart';
import 'package:sticker_world/core/theme/app_colors.dart';

/// 굵은 외곽선이 있는 글씨 (USJ 앱 제목 스타일).
/// 같은 글씨를 두 번 그린다. 아래는 외곽선, 위는 채움.
class OutlinedText extends StatelessWidget {
  const OutlinedText(
    this.text, {
    super.key,
    this.fontSize = 32,
    this.fontFamily = 'Jua',
    this.color = AppColors.white,
    this.outlineColor = AppColors.ink,
    this.outlineWidth = 4,
    this.textAlign = TextAlign.center,
  });

  final String text;
  final double fontSize;
  final String fontFamily;
  final Color color;
  final Color outlineColor;
  final double outlineWidth;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      height: 1.15,
    );
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = outlineWidth * 2
      ..strokeJoin = StrokeJoin.round
      ..color = outlineColor;

    return Stack(
      children: [
        Text(
          text,
          textAlign: textAlign,
          style: base.copyWith(foreground: outline),
        ),
        Text(
          text,
          textAlign: textAlign,
          style: base.copyWith(color: color),
        ),
      ],
    );
  }
}
