import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/jelly_tab_bar.dart';

/// 하단 탭 5개의 순서. 라우터의 branches 순서와 같아야 한다.
const mainTabSpecs = [
  JellyTabSpec(
    label: '홈',
    icon: Icons.home_rounded,
    color: AppColors.yellow,
    labelColor: AppColors.ink,
  ),
  JellyTabSpec(
    label: '할 일',
    icon: Icons.task_alt_rounded,
    color: AppColors.green,
  ),
  JellyTabSpec(label: '맵', icon: Icons.place_rounded, color: AppColors.blue),
  JellyTabSpec(label: '일기', icon: Icons.edit_rounded, color: AppColors.orange),
  JellyTabSpec(
    label: '기록',
    icon: Icons.calendar_month_rounded,
    color: AppColors.pink,
  ),
];

/// 탭 5개를 감싸는 틀. 각 탭의 상태는 go_router가 따로 보관한다.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final current = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: JellyTabBar(
        specs: mainTabSpecs,
        currentIndex: current,
        onTap: (index) =>
            navigationShell.goBranch(index, initialLocation: index == current),
      ),
    );
  }
}
