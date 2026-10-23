import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sticker_world/core/assets/asset_resolver.dart';
import 'package:sticker_world/core/router/routes.dart';
import 'package:sticker_world/core/theme/app_theme.dart';
import 'package:sticker_world/core/widgets/gold_medal.dart';
import 'package:sticker_world/core/widgets/jelly_button.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/providers.dart';
import 'package:sticker_world/domain/character_roster.dart';
import 'package:sticker_world/domain/sticker_ledger.dart';
import 'package:sticker_world/features/home/home_screen.dart';

Widget _home() {
  final router = GoRouter(
    routes: [GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen())],
  );
  return ProviderScope(
    overrides: [
      currentChildProvider.overrideWith(
        (ref) => Stream.value(
          ChildrenData(
            id: 1,
            name: '도율',
            duolingoPackage: 'com.duolingo',
            createdAt: DateTime(2026, 10, 22),
          ),
        ),
      ),
      ledgerProvider.overrideWith((ref) => Stream.value(LedgerView.empty)),
      activeRewardsProvider.overrideWith((ref) => Stream.value(const [])),
      routinesProvider.overrideWith((ref) => Stream.value(const [])),
      routineLogsProvider.overrideWith((ref, date) => Stream.value(const [])),
      pendingBonusesProvider.overrideWith((ref) => Stream.value(const [])),
      clearDatesProvider.overrideWith((ref) => Stream.value(const <String>{})),
      badgeAwardsProvider.overrideWith((ref) => Stream.value(const [])),
      characterRosterProvider.overrideWith(
        (ref) async => CharacterRoster.empty,
      ),
      worldPhotoProvider.overrideWith((ref, world) async => null),
      dailyPraiseProvider.overrideWith((ref) async => null),
      weeklyReportBannerProvider.overrideWith((ref) async => false),
    ],
    child: MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
  );
}

void main() {
  setUpAll(() async {
    await AssetResolver.init();
  });

  // 8인치(세로)와 그보다 큰 화면에서 레이아웃이 넘치지 않고,
  // 금색 패널(그림자 포함)이 아래 버튼에 닿지 않아야 한다.
  for (final size in const [Size(600, 960), Size(800, 1280)]) {
    testWidgets(
      '홈 ${size.width.toInt()}x${size.height.toInt()}: 금색 패널과 버튼 사이가 떨어져 있다',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_home());
        await tester.pumpAndSettle();

        final medalBottom = tester.getRect(find.byType(GoldMedal).last).bottom;
        final buttonTop = tester.getRect(find.byType(JellyButton).first).top;
        // 패널 아래 여백 14 + 그림자 8보다 넉넉해야 한다.
        expect(buttonTop - medalBottom, greaterThanOrEqualTo(20));
      },
    );
  }
}
