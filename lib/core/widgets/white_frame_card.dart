import 'package:flutter/material.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/outlined_text.dart';

/// 흰 테두리 카드 (USJ 앱 카드). 위쪽 색 띠에 제목을 넣을 수 있다.
class WhiteFrameCard extends StatelessWidget {
  const WhiteFrameCard({
    super.key,
    required this.child,
    this.headerTitle,
    this.headerColor = AppColors.gold,
    this.background = AppColors.cream,
  });

  final Widget child;
  final String? headerTitle;
  final Color headerColor;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final title = headerTitle;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(42),
        boxShadow: const [
          BoxShadow(color: Color(0x26000000), offset: Offset(0, 8)),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: ColoredBox(
          color: background,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null)
                Container(
                  height: 80,
                  color: headerColor,
                  alignment: Alignment.center,
                  child: OutlinedText(title, fontSize: 34),
                ),
              Padding(padding: const EdgeInsets.all(20), child: child),
            ],
          ),
        ),
      ),
    );
  }
}
