import 'package:flutter/material.dart';
import 'package:sticker_world/core/theme/app_colors.dart';

/// 내용 양옆의 노란 ◀ ▶ 화살표. 맵 월드 넘기기, 기록 페이지 넘기기에 쓴다.
class PageArrows extends StatelessWidget {
  const PageArrows({
    super.key,
    required this.child,
    this.onPrevious,
    this.onNext,
  });

  final Widget child;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Arrow(pointsLeft: true, semanticLabel: '이전', onTap: onPrevious),
        Expanded(child: child),
        _Arrow(pointsLeft: false, semanticLabel: '다음', onTap: onNext),
      ],
    );
  }
}

/// 페이지 점. 지금 페이지만 크고 하얗게 보인다.
class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          Container(
            width: i == index ? 22 : 16,
            height: i == index ? 22 : 16,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i == index ? AppColors.white : const Color(0x802E6F96),
            ),
          ),
      ],
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({
    required this.pointsLeft,
    required this.semanticLabel,
    required this.onTap,
  });

  final bool pointsLeft;
  final String semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Opacity(
          opacity: onTap == null ? 0.4 : 1,
          child: SizedBox(
            width: 44,
            height: 76,
            child: CustomPaint(painter: _ArrowPainter(pointsLeft: pointsLeft)),
          ),
        ),
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  const _ArrowPainter({required this.pointsLeft});

  final bool pointsLeft;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (pointsLeft) {
      path
        ..moveTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height / 2);
    } else {
      path
        ..moveTo(0, 0)
        ..lineTo(0, size.height)
        ..lineTo(size.width, size.height / 2);
    }
    path.close();

    canvas.drawPath(path, Paint()..color = AppColors.yellow);
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_ArrowPainter oldDelegate) {
    return oldDelegate.pointsLeft != pointsLeft;
  }
}
