import 'package:flutter/material.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/jelly_button.dart';

class JellyTabSpec {
  const JellyTabSpec({
    required this.label,
    required this.icon,
    required this.color,
    this.labelColor = AppColors.white,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color labelColor;
}

/// 하단 탭 5개. 선택된 탭은 연한 색과 위쪽 흰 막대로 표시한다 (크기는 모두 같다).
class JellyTabBar extends StatelessWidget {
  const JellyTabBar({
    super.key,
    required this.specs,
    required this.currentIndex,
    required this.onTap,
  });

  final List<JellyTabSpec> specs;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 156,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < specs.length; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _TabButton(
                      spec: specs[i],
                      selected: i == currentIndex,
                      onTap: () => onTap(i),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.spec,
    required this.selected,
    required this.onTap,
  });

  final JellyTabSpec spec;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Color.lerp(spec.color, AppColors.white, 0.45)!
        : spec.color;
    final labelColor = selected ? AppColors.ink : spec.labelColor;

    // 모든 탭은 같은 크기·같은 자리에 둔다. 선택된 탭은 밝은 색과 위쪽 막대로만 표시한다.
    return JellyButton(
      color: color,
      height: 138,
      semanticLabel: spec.label,
      onTap: onTap,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: Stack(
        children: [
          if (selected)
            Positioned(
              top: 14,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 56,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(spec.icon, size: 44, color: labelColor),
                Text(
                  spec.label,
                  style: TextStyle(
                    fontSize: 24,
                    color: labelColor,
                    shadows: selected
                        ? null
                        : const [
                            Shadow(
                              offset: Offset(0, 2),
                              color: Color(0x73000000),
                            ),
                          ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
