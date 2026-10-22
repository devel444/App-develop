import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sticker_world/core/assets/asset_resolver.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/providers.dart';
import 'package:sticker_world/domain/badge_rules.dart';
import 'package:sticker_world/features/badges/badge_screen.dart';

Badge _badge(
  String code,
  String category,
  String name, {
  String rule = '{"rule": "total_earned>=1"}',
  bool hidden = false,
}) {
  return Badge(
    code: code,
    category: category,
    name: name,
    iconKey: 'star',
    colorValue: 0xFFF5B800,
    ruleJson: rule,
    isHidden: hidden,
    isActive: true,
    bonusAmount: 0,
  );
}

Widget _badgeApp() {
  final stats = BadgeStats.from(
    events: const [],
    clearDates: const {},
    diaryCount: 0,
    duoStreak: null,
    createdAt: null,
    categoryNames: const {},
    now: DateTime(2026, 10, 22),
  );
  return ProviderScope(
    overrides: [
      badgeCatalogProvider.overrideWith(
        (ref) => Stream.value([
          _badge('first_sticker', '스티커', '첫 스티커'),
          _badge('world_1', '스티커', '월드 1 도착', rule: '{"rule": "balance>=20"}'),
          _badge('diary_1', '일기', '일기 1편', rule: '{"rule": "diary>=1"}'),
          _badge(
            'hidden_five_today',
            '숨김',
            '하루 다섯 개',
            rule: '{"rule": "today_earn>=5"}',
            hidden: true,
          ),
        ]),
      ),
      badgeAwardsProvider.overrideWith(
        (ref) => Stream.value([
          BadgeAward(
            id: 1,
            badgeCode: 'first_sticker',
            childId: 1,
            awardedAt: DateTime(2026, 10, 20, 9),
          ),
        ]),
      ),
      badgeStatsProvider.overrideWith((ref) async => stats),
    ],
    child: MaterialApp.router(
      routerConfig: GoRouter(
        routes: [GoRoute(path: '/', builder: (_, _) => const BadgeScreen())],
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    await AssetResolver.init();
  });

  testWidgets('얻은 배지는 이름이 보이고, 못 얻은 배지는 힌트와 함께 가려진다', (tester) async {
    tester.view.physicalSize = const Size(800, 1280);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_badgeApp());
    await tester.pumpAndSettle();

    expect(find.text('배지 도감'), findsWidgets);
    expect(find.text('첫 스티커'), findsWidgets);
    expect(find.text('모은 스티커 0 / 20'), findsOneWidget);
    expect(find.text('숨겨진 배지'), findsOneWidget);
    expect(find.text('월드 1 도착'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('필터를 고르면 그 분류의 배지만 남는다', (tester) async {
    tester.view.physicalSize = const Size(800, 1280);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_badgeApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('일기'));
    await tester.pumpAndSettle();

    expect(find.text('숨겨진 배지'), findsNothing);
    expect(find.text('모은 스티커 0 / 20'), findsNothing);
    expect(find.text('일기 0 / 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
