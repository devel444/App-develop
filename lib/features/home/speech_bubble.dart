import 'package:flutter/material.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/features/home/home_extras.dart';

const _tailWidth = 16.0;

/// 캐릭터가 말하는 말풍선. 왼쪽 가운데에 꼬리가 있어서 캐릭터 쪽을 가리킨다.
class SpeechBubble extends StatelessWidget {
  const SpeechBubble({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final compact = homeIsCompact(context);
    return CustomPaint(
      painter: const _BubblePainter(),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          _tailWidth + (compact ? 14 : 18),
          compact ? 10 : 14,
          compact ? 14 : 18,
          compact ? 10 : 14,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: compact ? 20 : 26,
            height: 1.25,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  const _BubblePainter();

  @override
  void paint(Canvas canvas, Size size) {
    const radius = 22.0;
    final body = Path()
      ..addRRect(
        RRect.fromLTRBR(
          _tailWidth,
          0,
          size.width,
          size.height,
          const Radius.circular(radius),
        ),
      );
    final tail = Path()
      ..moveTo(_tailWidth + 1, size.height * 0.36)
      ..lineTo(0, size.height * 0.5)
      ..lineTo(_tailWidth + 1, size.height * 0.64)
      ..close();
    final bubble = Path.combine(PathOperation.union, body, tail);

    canvas.drawPath(bubble, Paint()..color = AppColors.white);
    canvas.drawPath(
      bubble,
      Paint()
        ..color = AppColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_BubblePainter oldDelegate) => false;
}
