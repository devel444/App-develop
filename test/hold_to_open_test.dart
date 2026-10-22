import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/core/widgets/hold_to_open.dart';

void main() {
  testWidgets('3초를 다 누르고 있으면 한 번 열린다', (tester) async {
    var opened = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: HoldToOpen(
            onOpen: () => opened++,
            child: const SizedBox(width: 60, height: 60),
          ),
        ),
      ),
    );

    final center = tester.getCenter(find.byType(HoldToOpen));
    final gesture = await tester.startGesture(center);
    // 첫 프레임이 시작 시각을 잡고, 그 뒤 3초를 지나야 다 찬다.
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(opened, 1);
  });

  testWidgets('중간에 손을 떼면 열리지 않는다', (tester) async {
    var opened = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: HoldToOpen(
            onOpen: () => opened++,
            child: const SizedBox(width: 60, height: 60),
          ),
        ),
      ),
    );

    final center = tester.getCenter(find.byType(HoldToOpen));
    final gesture = await tester.startGesture(center);
    await tester.pump(const Duration(seconds: 2));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(opened, 0);
  });
}
