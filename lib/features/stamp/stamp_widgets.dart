import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/jelly_button.dart';
import 'package:sticker_world/core/widgets/outlined_text.dart';

/// 선택 버튼. 고르면 색이 진해진다. 아이도 누를 수 있게 64dp 이상으로 만든다.
class ChoiceButton extends StatelessWidget {
  const ChoiceButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.color = AppColors.gold,
    this.height = 80,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return JellyButton(
      color: selected ? color : AppColors.white,
      height: height,
      semanticLabel: label,
      onTap: onTap,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 26,
                color: selected ? AppColors.white : AppColors.ink,
                shadows: selected
                    ? const [
                        Shadow(color: Color(0x80000000), offset: Offset(0, 2)),
                      ]
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 화면 왼쪽 위 뒤로가기 버튼. 뒤로 갈 곳이 있을 때만 보인다.
class BackFab extends StatelessWidget {
  const BackFab({super.key});

  @override
  Widget build(BuildContext context) {
    if (!context.canPop()) {
      return const SizedBox.shrink();
    }
    return Positioned(
      left: 16,
      top: 16,
      child: JellyButton(
        width: 72,
        height: 72,
        color: AppColors.white,
        borderRadius: BorderRadius.circular(36),
        semanticLabel: '뒤로',
        onTap: () => context.pop(false),
        child: const Center(
          child: Icon(Icons.arrow_back_rounded, size: 40, color: AppColors.ink),
        ),
      ),
    );
  }
}

/// 제목 글씨가 있는 작은 안내 문구 (흰 글씨, 외곽선).
class HintText extends StatelessWidget {
  const HintText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return OutlinedText(text, fontSize: 22, outlineWidth: 2);
  }
}
