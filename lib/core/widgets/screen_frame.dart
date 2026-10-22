import 'package:flutter/material.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/outlined_text.dart';
import 'package:sticker_world/core/widgets/pattern_background.dart';

/// 탭 화면 공통 틀: 색 배경 + 무늬 + 외곽선 제목 + 본문.
class ScreenFrame extends StatelessWidget {
  const ScreenFrame({
    super.key,
    required this.title,
    required this.child,
    this.color = AppColors.blue,
    this.pattern = BgPattern.dots,
  });

  final String title;
  final Widget child;
  final Color color;
  final BgPattern pattern;

  @override
  Widget build(BuildContext context) {
    return PatternBackground(
      color: color,
      pattern: pattern,
      // TextField가 Material 조상을 요구하므로 투명한 Material로 감싼다.
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                child: OutlinedText(title, fontSize: 52),
              ),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
