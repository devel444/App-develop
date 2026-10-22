import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/outlined_text.dart';

/// 도장 '쿵!' 연출. 큰 별이 내려와 찍히고, 별 조각이 사방으로 튄다.
/// 연출이 끝나면 [onFinished]가 한 번 불린다.
class StampCelebration extends StatefulWidget {
  const StampCelebration({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<StampCelebration> createState() => _StampCelebrationState();
}

class _StampCelebrationState extends State<StampCelebration> {
  static const _duration = Duration(milliseconds: 1500);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_duration, widget.onFinished);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0x66000000),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < 14; i++) _Spark(index: i),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                    width: 200,
                    height: 200,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        center: Alignment(-0.3, -0.4),
                        colors: [
                          Color(0xFFFFF4B8),
                          Color(0xFFFFC93B),
                          Color(0xFFE09A00),
                        ],
                      ),
                      border: Border.all(
                        color: const Color(0xFF8A5A00),
                        width: 8,
                      ),
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      size: 120,
                      color: AppColors.white,
                    ),
                  )
                  .animate()
                  .scale(
                    begin: const Offset(3, 3),
                    end: const Offset(1, 1),
                    duration: 320.ms,
                    curve: Curves.bounceOut,
                  )
                  .fadeIn(duration: 120.ms)
                  .then(delay: 60.ms)
                  .shake(hz: 6, offset: const Offset(8, 0), duration: 300.ms),
              const SizedBox(height: 16),
              const OutlinedText('쿵!', fontSize: 110)
                  .animate(delay: 120.ms)
                  .scale(
                    begin: const Offset(2.2, 2.2),
                    end: const Offset(1, 1),
                    duration: 280.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: 150.ms),
            ],
          ),
        ],
      ),
    );
  }
}

/// 별 조각 하나. 가운데에서 사방으로 튀었다가 사라진다.
class _Spark extends StatelessWidget {
  const _Spark({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final angle = 2 * pi * index / 14;
    final distance = 150.0 + (index.isEven ? 40 : 0);
    final color = index.isEven ? AppColors.gold : AppColors.white;

    return Icon(Icons.star_rounded, size: index.isEven ? 34 : 24, color: color)
        .animate(delay: (index * 25).ms)
        .move(
          begin: Offset.zero,
          end: Offset(cos(angle) * distance, sin(angle) * distance),
          duration: 600.ms,
          curve: Curves.easeOut,
        )
        .fadeOut(delay: 350.ms, duration: 300.ms);
  }
}

/// 스티커를 뺄 때의 연출. 회색 별이 떨어지고 "한 칸 뒤로!"가 뜬다. 무섭지 않게 짧고 부드럽게.
class StickerFallCelebration extends StatefulWidget {
  const StickerFallCelebration({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<StickerFallCelebration> createState() => _StickerFallCelebrationState();
}

class _StickerFallCelebrationState extends State<StickerFallCelebration> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1400), widget.onFinished);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0x55000000),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 150, color: Color(0xFFB0B4C0))
              .animate()
              .moveY(end: 160, duration: 900.ms, curve: Curves.easeIn)
              .rotate(end: 0.4, duration: 900.ms)
              .fadeOut(delay: 600.ms, duration: 300.ms),
          const SizedBox(height: 24),
          const OutlinedText(
            '한 칸 뒤로!',
            fontSize: 64,
            outlineColor: AppColors.ink,
          ).animate(delay: 900.ms).fadeIn(duration: 300.ms),
        ],
      ),
    );
  }
}
