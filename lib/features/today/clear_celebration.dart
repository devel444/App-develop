import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/jelly_button.dart';
import 'package:sticker_world/core/widgets/outlined_text.dart';
import 'package:sticker_world/core/widgets/white_frame_card.dart';

/// 올클리어 축하: 색종이가 떨어지고 "COURSE CLEAR!"가 뜬다. 확인을 눌러야 닫힌다.
class ClearCelebration extends StatelessWidget {
  const ClearCelebration({
    super.key,
    required this.bonusPending,
    required this.onDone,
  });

  final bool bonusPending;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xCC1B3A14),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < 42; i++) _Confetti(index: i),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const OutlinedText(
                    'COURSE',
                    fontSize: 84,
                    fontFamily: 'LilitaOne',
                    color: AppColors.gold,
                  )
                  .animate()
                  .scale(
                    begin: const Offset(2, 2),
                    end: const Offset(1, 1),
                    duration: 350.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: 150.ms),
              const OutlinedText(
                    'CLEAR!',
                    fontSize: 110,
                    fontFamily: 'LilitaOne',
                  )
                  .animate(delay: 150.ms)
                  .scale(
                    begin: const Offset(2, 2),
                    end: const Offset(1, 1),
                    duration: 350.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: 150.ms),
              const SizedBox(height: 24),
              WhiteFrameCard(
                    headerTitle: '오늘 할 일을 다 했어!',
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          bonusPending
                              ? '보너스 스티커는 엄마·아빠가 확인하면 붙어요.'
                              : '정말 멋져요!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            height: 1.4,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 20),
                        JellyButton(
                          color: AppColors.gold,
                          height: 80,
                          semanticLabel: '야호! 확인',
                          onTap: onDone,
                          child: const Center(
                            child: OutlinedText('야호! 확인', fontSize: 30),
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate(delay: 500.ms)
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.3, end: 0, duration: 300.ms),
            ],
          ),
        ],
      ),
    );
  }
}

/// 색종이 한 장. 위에서 떨어지며 돈다.
class _Confetti extends StatelessWidget {
  const _Confetti({required this.index});

  final int index;

  static const _colors = [
    AppColors.gold,
    AppColors.red,
    AppColors.blue,
    AppColors.pink,
    AppColors.green,
    AppColors.white,
  ];

  @override
  Widget build(BuildContext context) {
    final random = Random(index);
    final x = (random.nextDouble() - 0.5) * 520;
    final startY = -560 + random.nextDouble() * 80;
    final delay = random.nextInt(900);

    return Transform.translate(
      offset: Offset(x, startY),
      child:
          Container(
                width: 14 + random.nextInt(10).toDouble(),
                height: 22,
                decoration: BoxDecoration(
                  color: _colors[index % _colors.length],
                  borderRadius: BorderRadius.circular(4),
                ),
              )
              .animate(delay: delay.ms, onPlay: (c) => c.repeat())
              .moveY(
                begin: 0,
                end: 1300,
                duration: 2200.ms,
                curve: Curves.easeIn,
              )
              .rotate(end: 2, duration: 2200.ms),
    );
  }
}
