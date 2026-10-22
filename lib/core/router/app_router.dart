import 'package:go_router/go_router.dart';
import 'package:sticker_world/core/router/routes.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/features/diary/diary_screen.dart';
import 'package:sticker_world/features/duolingo/duolingo_settings_screen.dart';
import 'package:sticker_world/features/home/home_screen.dart';
import 'package:sticker_world/features/stamp/remove_screen.dart';
import 'package:sticker_world/features/today/routine_admin_screen.dart';
import 'package:sticker_world/features/today/today_screen.dart';
import 'package:sticker_world/features/shop/reward_admin_screen.dart';
import 'package:sticker_world/features/shop/shop_screen.dart';
import 'package:sticker_world/features/stamp/stamp_screen.dart';
import 'package:sticker_world/features/world/map_screen.dart';
import 'package:sticker_world/features/onboarding/onboarding_screen.dart';
import 'package:sticker_world/features/pin/parent_pin_screen.dart';
import 'package:sticker_world/features/pin/recovery_screen.dart';
import 'package:sticker_world/features/placeholder/placeholder_screen.dart';
import 'package:sticker_world/features/records/records_screen.dart';
import 'package:sticker_world/features/shell/main_shell.dart';

GoRouter buildRouter({required String initialLocation}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: Routes.onboarding,
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(path: Routes.pin, builder: (_, _) => const ParentPinScreen()),
      GoRoute(
        path: Routes.pinRecovery,
        builder: (_, _) => const RecoveryScreen(),
      ),
      // 하단 탭 5개. 탭마다 화면 상태가 따로 남는다.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.today,
                builder: (_, _) => const TodayScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.map, builder: (_, _) => const MapScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.diary,
                builder: (_, _) => const DiaryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.records,
                builder: (_, _) => const RecordsScreen(),
              ),
            ],
          ),
        ],
      ),
      // 전체 화면으로 여는 화면들 (하단 탭 바를 가린다).
      GoRoute(path: Routes.stamp, builder: (_, _) => const StampScreen()),
      GoRoute(path: Routes.remove, builder: (_, _) => const RemoveScreen()),
      GoRoute(path: Routes.shop, builder: (_, _) => const ShopScreen()),
      GoRoute(
        path: Routes.rewards,
        builder: (_, _) => const RewardAdminScreen(),
      ),
      GoRoute(
        path: Routes.routines,
        builder: (_, _) => const RoutineAdminScreen(),
      ),
      GoRoute(
        path: Routes.duolingo,
        builder: (_, _) => const DuolingoSettingsScreen(),
      ),
      GoRoute(
        path: Routes.badges,
        builder: (_, _) => const PlaceholderScreen(
          title: '배지 도감',
          color: AppColors.gold,
          note: 'P8 단계에서 만들어요.\n모은 배지와 아직 못 모은 배지',
        ),
      ),
      GoRoute(
        path: Routes.parent,
        builder: (_, _) => const PlaceholderScreen(
          title: '부모 모드',
          color: AppColors.purple,
          note: 'P9 단계에서 만들어요.\n캐릭터 꾸미기, 설정, 백업',
        ),
      ),
    ],
  );
}
