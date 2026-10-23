import 'package:sticker_world/domain/character_roster.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sticker_world/core/assets/asset_resolver.dart';
import 'package:sticker_world/core/router/routes.dart';
import 'package:sticker_world/core/theme/app_theme.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/providers.dart';
import 'package:sticker_world/domain/sticker_ledger.dart';
import 'package:sticker_world/features/home/home_screen.dart';

Widget _homeWithRouter() {
  final router = GoRouter(
    routes: [
      GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),
      GoRoute(
        path: Routes.shop,
        builder: (_, _) => const Scaffold(body: Text('선물 가게 화면')),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      currentChildProvider.overrideWith(
        (ref) => Stream.value(
          ChildrenData(
            id: 1,
            name: '지우',
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

  testWidgets('열쇠를 누르면 선물 가게로 간다', (tester) async {
    tester.view.physicalSize = const Size(800, 1280);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_homeWithRouter());
    await tester.pumpAndSettle();
    expect(find.text('선물 가게 화면'), findsNothing);

    await tester.tap(find.byIcon(Icons.key_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('선물 가게 화면'), findsOneWidget);
  });
}
