import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sticker_world/core/theme/app_colors.dart';

/// 누르고 있으면 원이 차오르고, 다 차면 [onOpen]이 한 번 불린다.
/// 중간에 손을 떼면 원이 되돌아가고 아무 일도 없다.
/// 부모 모드처럼 아이가 실수로 들어가지 않게 하는 용도로 쓴다.
class HoldToOpen extends StatefulWidget {
  const HoldToOpen({
    super.key,
    required this.child,
    required this.onOpen,
    this.holdDuration = const Duration(seconds: 3),
  });

  final Widget child;
  final VoidCallback onOpen;
  final Duration holdDuration;

  @override
  State<HoldToOpen> createState() => _HoldToOpenState();
}

class _HoldToOpenState extends State<HoldToOpen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ring = AnimationController(
    vsync: this,
    duration: widget.holdDuration,
  );
  Timer? _timer;

  void _press() {
    _ring.forward(from: 0);
    _timer = Timer(widget.holdDuration, _complete);
  }

  void _release() {
    _timer?.cancel();
    _timer = null;
    _ring.reverse();
  }

  void _complete() {
    _timer = null;
    _ring.reset();
    widget.onOpen();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ring.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      // 아이콘처럼 그림 자체가 터치를 받지 않아도 눌림을 잡도록 한다.
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => _press(),
      onPointerUp: (_) => _release(),
      onPointerCancel: (_) => _release(),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          widget.child,
          AnimatedBuilder(
            animation: _ring,
            builder: (context, _) {
              if (_ring.value == 0) {
                return const SizedBox.shrink();
              }
              return IgnorePointer(
                child: SizedBox.square(
                  dimension: 84,
                  child: CircularProgressIndicator(
                    value: _ring.value,
                    strokeWidth: 6,
                    color: AppColors.gold,
                    backgroundColor: const Color(0x33FFFFFF),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
