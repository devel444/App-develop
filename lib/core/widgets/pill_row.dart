import 'package:flutter/material.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/jelly_button.dart';

/// 목록 한 줄 (USJ 랭킹 줄 스타일). 왼쪽 색 칸에 아이콘이나 번호, 오른쪽에 글.
/// 부모 칸이 가로로 꽉 차 있어야 한다 (Column의 자식 등).
class PillRow extends StatelessWidget {
  const PillRow({
    super.key,
    required this.accent,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.highlighted = false,
    this.onTap,
  });

  final Color accent;
  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool highlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final subtitleText = subtitle;

    return JellyButton(
      height: 82,
      color: highlighted ? AppColors.white : AppColors.mint,
      borderRadius: BorderRadius.circular(41),
      semanticLabel: title,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 110,
            color: accent,
            alignment: Alignment.center,
            child: leading,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 24, color: AppColors.ink),
                  ),
                  if (subtitleText != null)
                    Text(
                      subtitleText,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF3A4A3A),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (trailing != null)
            Padding(padding: const EdgeInsets.only(right: 20), child: trailing),
        ],
      ),
    );
  }
}
