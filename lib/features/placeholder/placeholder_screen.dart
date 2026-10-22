import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/jelly_button.dart';
import 'package:sticker_world/core/widgets/pattern_background.dart';
import 'package:sticker_world/core/widgets/screen_frame.dart';
import 'package:sticker_world/core/widgets/white_frame_card.dart';

/// 아직 만들지 않은 화면의 자리. 어느 단계에서 만들지 안내한다.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.note,
    this.color = AppColors.blue,
    this.pattern = BgPattern.dots,
  });

  final String title;
  final String note;
  final Color color;
  final BgPattern pattern;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ScreenFrame(
          title: title,
          color: color,
          pattern: pattern,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: WhiteFrameCard(
                headerTitle: '곧 만들어요',
                child: Text(
                  note,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    height: 1.5,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (context.canPop())
          Positioned(
            left: 16,
            top: 16,
            child: JellyButton(
              width: 72,
              height: 72,
              color: AppColors.white,
              borderRadius: BorderRadius.circular(36),
              semanticLabel: '뒤로',
              onTap: () => context.pop(),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 40,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
