import 'package:go_router/go_router.dart';
import 'package:sticker_world/core/router/routes.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/pattern_background.dart';
import 'package:sticker_world/features/home/home_screen.dart';
import 'package:sticker_world/features/placeholder/placeholder_screen.dart';
import 'package:sticker_world/features/shell/main_shell.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: Routes.home,
    routes: [
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
                builder: (_, _) => const PlaceholderScreen(
                  title: '오늘의 할 일',
                  color: AppColors.green,
                  pattern: BgPattern.stripes,
                  note: 'P4 단계에서 만들어요.\n루틴 체크, 듀오링고 자동 체크, 올클리어 축하',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.map,
                builder: (_, _) => const PlaceholderScreen(
                  title: '스티커 월드',
                  color: AppColors.blue,
                  note: 'P2 단계에서 만들어요.\n100칸 월드 맵과 스티커 붙이기·빼기',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.diary,
                builder: (_, _) => const PlaceholderScreen(
                  title: '일기',
                  color: AppColors.orange,
                  note: 'P6 단계에서 만들어요.\n날씨·기분 고르기, 말로 쓰기, 엄마·아빠 답장',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.records,
                builder: (_, _) => const PlaceholderScreen(
                  title: '기록',
                  color: AppColors.pink,
                  note: 'P7 단계에서 만들어요.\n달력과 성장 리포트',
                ),
              ),
            ],
          ),
        ],
      ),
      // 전체 화면으로 여는 화면들 (하단 탭 바를 가린다).
      GoRoute(
        path: Routes.stamp,
        builder: (_, _) => const PlaceholderScreen(
          title: '스티커 붙이기',
          color: AppColors.blue,
          note: 'P2 단계에서 만들어요.\n엄마·아빠 PIN → 카테고리 → 도장 쿵!',
        ),
      ),
      GoRoute(
        path: Routes.remove,
        builder: (_, _) => const PlaceholderScreen(
          title: '스티커 빼기',
          color: AppColors.coral,
          note: 'P2 단계에서 만들어요.\nPIN → 잘못 종류 → 사유 기록(필수)',
        ),
      ),
      GoRoute(
        path: Routes.shop,
        builder: (_, _) => const PlaceholderScreen(
          title: '선물가게',
          color: AppColors.pink,
          note: 'P3 단계에서 만들어요.\n선물 교환과 교환권',
        ),
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
          note: 'P1(PIN)과 P9(캐릭터·꾸미기)에서 만들어요.',
        ),
      ),
    ],
  );
}
