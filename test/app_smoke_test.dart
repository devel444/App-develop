import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/app.dart';
import 'package:sticker_world/core/assets/asset_resolver.dart';
import 'package:sticker_world/core/router/routes.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/providers.dart';
import 'package:sticker_world/domain/sticker_ledger.dart';

/// 홈 화면 테스트용 공급자. DB 대신 고정값을 쓴다.
/// Drift 스트림은 가짜 시간 안에서 끝나지 않을 수 있다. DB 동작은 온보딩·데이터 테스트에서 확인한다.
Widget _homeApp() => ProviderScope(
  overrides: [
    currentChildProvider.overrideWith(
      (ref) => Stream.value(
        ChildrenData(
          id: 1,
          name: '친구',
          duolingoPackage: 'com.duolingo',
          createdAt: DateTime(2026, 10, 22),
        ),
      ),
    ),
    categoryColorsProvider.overrideWith((ref) async => <int, int>{}),
    activeRewardsProvider.overrideWith((ref) => Stream.value(const [])),
    ledgerProvider.overrideWith((ref) => Stream.value(LedgerView.empty)),
    initialLocationProvider.overrideWithValue(Routes.home),
  ],
  child: const StickerWorldApp(),
);

void main() {
  setUpAll(() async {
    await AssetResolver.init();
  });

  for (final size in const [Size(800, 1280), Size(412, 892)]) {
    testWidgets(
      '세로 ${size.width.toInt()}x${size.height.toInt()}에서 홈과 탭 5개가 넘치지 않고 뜬다',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_homeApp());
        await tester.pump();

        expect(find.text('친구의 스티커 월드'), findsWidgets);
        expect(find.text('스티커 붙이기'), findsWidgets);
        expect(find.text('스티커 빼기'), findsOneWidget);
        for (final label in ['홈', '할 일', '맵', '일기', '기록']) {
          expect(find.text(label), findsOneWidget, reason: '탭 "$label"');
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('맵 탭을 누르면 맵 화면으로 바뀐다', (tester) async {
    tester.view.physicalSize = const Size(800, 1280);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_homeApp());
    await tester.pump();

    await tester.tap(find.text('맵'));
    await tester.pumpAndSettle();

    expect(find.text('W1 · 풀밭'), findsWidgets);
    expect(find.text('스티커 붙이기'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
