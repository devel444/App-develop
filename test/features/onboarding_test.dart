import 'package:sticker_world/core/widgets/jelly_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/data/providers.dart';
import 'package:sticker_world/features/onboarding/onboarding_screen.dart';

import '../support/test_database.dart';

final _recoveryCodePattern = RegExp(r'^[A-Z2-9]{4}-[A-Z2-9]{4}-[A-Z2-9]{4}$');

void main() {
  testWidgets('처음 실행: 이름 → 비밀번호 두 번 → 복구 코드가 보이고 아이가 저장된다', (tester) async {
    tester.view.physicalSize = const Size(800, 1280);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = createTestDatabase();
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: OnboardingScreen()),
      ),
    );

    await tester.enterText(find.byType(TextField), '지우');
    await tester.tap(find.byType(JellyButton));
    await tester.pumpAndSettle();

    for (final digit in ['1', '2', '3', '4']) {
      await tester.tap(find.byKey(ValueKey('pin-$digit')));
      await tester.pump();
    }
    await tester.pumpAndSettle();

    for (final digit in ['1', '2', '3', '4']) {
      await tester.tap(find.byKey(ValueKey('pin-$digit')));
      await tester.pump();
    }
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();

    final codeText = tester
        .widgetList<Text>(find.byType(Text))
        .map((text) => text.data ?? '')
        .where(_recoveryCodePattern.hasMatch);
    expect(codeText, hasLength(1));

    final children = await tester.runAsync(() => db.select(db.children).get());
    expect(children!.single.name, '지우');
  });

  testWidgets('이름을 비워 두면 다음으로 넘어가지 않는다', (tester) async {
    tester.view.physicalSize = const Size(800, 1280);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = createTestDatabase();
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: OnboardingScreen()),
      ),
    );

    await tester.tap(find.byType(JellyButton));
    await tester.pump();

    expect(find.text('아이 이름을 입력해 주세요.'), findsOneWidget);
    expect(find.byKey(const ValueKey('pin-1')), findsNothing);
  });
}
