import 'package:flutter/material.dart';

/// 젤리처럼 통통한 버튼 (USJ 앱 스타일).
/// 아래쪽 그림자, 누르면 살짝 줄어드는 효과를 준다. (흰 하이라이트는 두지 않는다.)
/// 자식 위젯은 버튼 크기에 꽉 맞게 늘어난다. 가운데 정렬이 필요하면 Center로 감싼다.
class JellyButton extends StatefulWidget {
  const JellyButton({
    super.key,
    required this.child,
    required this.color,
    this.onTap,
    this.height = 96,
    this.width,
    this.borderRadius = const BorderRadius.all(Radius.circular(30)),
    this.semanticLabel,
  });

  final Widget child;
  final Color color;
  final VoidCallback? onTap;
  final double height;
  final double? width;
  final BorderRadius borderRadius;
  final String? semanticLabel;

  @override
  State<JellyButton> createState() => _JellyButtonState();
}

class _JellyButtonState extends State<JellyButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _setPressed(true) : null,
        onTapUp: enabled ? (_) => _setPressed(false) : null,
        onTapCancel: enabled ? () => _setPressed(false) : null,
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.95 : 1,
          duration: const Duration(milliseconds: 90),
          child: SizedBox(
            height: widget.height,
            width: widget.width,
            child: CustomPaint(
              painter: _JellyPainter(
                color: widget.color,
                borderRadius: widget.borderRadius,
              ),
              child: ClipRRect(
                borderRadius: widget.borderRadius,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _JellyPainter extends CustomPainter {
  const _JellyPainter({required this.color, required this.borderRadius});

  final Color color;
  final BorderRadius borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final outer = borderRadius.toRRect(Offset.zero & size);
    canvas.drawRRect(
      outer,
      Paint()..color = Color.lerp(color, const Color(0xFF000000), 0.2)!,
    );

    // 아래 10%는 그림자색으로 남기고 위쪽 90%를 본색으로 덮는다.
    final body = borderRadius.toRRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.9),
    );
    canvas.drawRRect(body, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_JellyPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderRadius != borderRadius;
  }
}
