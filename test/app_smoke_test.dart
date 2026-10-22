import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/app.dart';
import 'package:sticker_world/core/assets/asset_resolver.dart';

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

        await tester.pumpWidget(const ProviderScope(child: StickerWorldApp()));
        await tester.pump();

        expect(find.text('지우의 스티커 월드'), findsWidgets);
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

    await tester.pumpWidget(const ProviderScope(child: StickerWorldApp()));
    await tester.pump();

    await tester.tap(find.text('맵'));
    await tester.pumpAndSettle();

    expect(find.text('곧 만들어요'), findsWidgets);
    expect(find.text('스티커 월드'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
