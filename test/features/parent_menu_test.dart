import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sticker_world/core/assets/asset_resolver.dart';
import 'package:sticker_world/core/widgets/outlined_text.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/providers.dart';
import 'package:sticker_world/features/parent/parent_menu_screen.dart';

Widget _menuApp({required List<DailyClear> bonuses}) {
  final router = GoRouter(
    initialLocation: '/parent',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Text('홈 화면')),
      ),
      GoRoute(path: '/parent', builder: (_, _) => const ParentMenuScreen()),
      GoRoute(
        path: '/diary',
        builder: (_, _) => const Scaffold(body: Text('일기 탭')),
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
      stickerSettingsProvider.overrideWith(
        (ref) async =>
            const StickerSettings(undoSeconds: 10, yellowCardOn: false),
      ),
      pendingBonusesProvider.overrideWith((ref) => Stream.value(bonuses)),
      redemptionsProvider.overrideWith((ref) => Stream.value(const [])),
      diaryEntriesProvider.overrideWith((ref) => Stream.value(const [])),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  setUpAll(() async {
    await AssetResolver.init();
  });

  testWidgets('부모 모드 메뉴에 설정 항목이 모두 보이고, 확인할 일이 없으면 그 칸은 없다', (tester) async {
    tester.view.physicalSize = const Size(800, 1280);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_menuApp(bonuses: const []));
    await tester.pumpAndSettle();

    expect(find.text('부모 모드'), findsWidgets);
    for (final label in [
      '아이 이름 고치기',
      '칭찬 · 잘못 종류',
      '옐로카드',
      '배지 켜기 · 끄기',
      '백업 · 되돌리기',
      '비밀번호 바꾸기',
      '앱 고정 안내',
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    // 잠그고 나가기는 외곽선 글자라 Text가 아니다. 버튼 칸이 있는지만 본다.
    expect(find.byType(OutlinedText), findsWidgets);
    expect(find.text('확인할 일'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('보너스가 기다리면 확인할 일 칸에 보인다', (tester) async {
    tester.view.physicalSize = const Size(800, 1280);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _menuApp(
        bonuses: [
          DailyClear(
            id: 1,
            childId: 1,
            localDate: '2026-10-22',
            clearedAt: DateTime(2026, 10, 22, 19),
            bonusStatus: 'pending',
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('확인할 일'), findsOneWidget);
    expect(find.text('보너스 대기 1개'), findsOneWidget);
  });

  testWidgets('2분 동안 손대지 않으면 홈으로 자동으로 잠긴다', (tester) async {
    tester.view.physicalSize = const Size(800, 1280);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_menuApp(bonuses: const []));
    await tester.pump();

    await tester.pump(const Duration(minutes: 1, seconds: 50));
    await tester.tapAt(const Offset(400, 600));
    await tester.pump(const Duration(minutes: 1, seconds: 50));
    expect(find.text('홈 화면'), findsNothing, reason: '터치로 시간이 다시 셌다');

    await tester.pump(const Duration(seconds: 15));
    await tester.pumpAndSettle();
    expect(find.text('홈 화면'), findsOneWidget);
  });
}
