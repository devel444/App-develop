import 'package:flutter/material.dart';
import 'package:sticker_world/core/theme/app_colors.dart';

const _notch = 18.0;

/// 티켓 모양 길: 직사각형에서 양옆 가운데를 반원으로 파낸다.
Path _ticketPath(Size size) {
  final body = Path()
    ..addRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(24)),
    );
  final midY = size.height / 2;
  final leftNotch = Path()
    ..addOval(Rect.fromCircle(center: Offset(0, midY), radius: _notch));
  final rightNotch = Path()
    ..addOval(
      Rect.fromCircle(center: Offset(size.width, midY), radius: _notch),
    );
  return Path.combine(
    PathOperation.difference,
    Path.combine(PathOperation.difference, body, leftNotch),
    rightNotch,
  );
}

class _TicketClipper extends CustomClipper<Path> {
  const _TicketClipper();

  @override
  Path getClip(Size size) => _ticketPath(size);

  @override
  bool shouldReclip(_TicketClipper oldClipper) => false;
}

/// 티켓 테두리와 가운데 점선(찢는 선).
class _TicketEdgePainter extends CustomPainter {
  const _TicketEdgePainter({
    required this.color,
    required this.dividerFromRight,
  });

  final Color color;

  /// 오른쪽 끝에서 점선까지의 거리 (null이면 점선 없음).
  final double? dividerFromRight;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      _ticketPath(size),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    final fromRight = dividerFromRight;
    if (fromRight == null) {
      return;
    }
    // 버튼 칸 바로 왼쪽에 점선을 긋는다 (찢는 선).
    final dashPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 3;
    final x = size.width - fromRight;
    for (var y = 14.0; y < size.height - 14; y += 18) {
      canvas.drawLine(Offset(x, y), Offset(x, y + 10), dashPaint);
    }
  }

  @override
  bool shouldRepaint(_TicketEdgePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.dividerFromRight != dividerFromRight;
}

/// 교환권을 티켓 모양으로 보여 준다. 오른쪽 칸에 [trailing]을 놓는다.
class TicketCard extends StatelessWidget {
  const TicketCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.color = AppColors.white,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: const _TicketClipper(),
          child: Container(
            color: color,
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 28,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 20,
                          color: AppColors.misdeed,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) SizedBox(width: 150, child: trailing),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _TicketEdgePainter(
                color: AppColors.ink,
                dividerFromRight: trailing == null ? null : 174,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
