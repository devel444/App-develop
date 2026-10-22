import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/features/pin/pin_pad.dart';

void main() {
  testWidgets('숫자 0~9가 모두 보이고, 4자리를 누르면 한 번 알려 준다', (tester) async {
    tester.view.physicalSize = const Size(800, 1280);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final entered = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PinPad(random: Random(3), onCompleted: entered.add),
        ),
      ),
    );

    for (var digit = 0; digit <= 9; digit++) {
      expect(find.byKey(ValueKey('pin-$digit')), findsOneWidget);
    }

    for (final digit in ['1', '2', '3', '4']) {
      await tester.tap(find.byKey(ValueKey('pin-$digit')));
      await tester.pump();
    }

    expect(entered, ['1234']);
  });

  testWidgets('지우기 버튼은 마지막 숫자를 지운다', (tester) async {
    tester.view.physicalSize = const Size(800, 1280);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final entered = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PinPad(random: Random(5), onCompleted: entered.add),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('pin-7')));
    await tester.tap(find.byKey(const ValueKey('pin-8')));
    await tester.tap(find.byKey(const ValueKey('pin-backspace')));
    await tester.tap(find.byKey(const ValueKey('pin-9')));
    await tester.tap(find.byKey(const ValueKey('pin-1')));
    await tester.tap(find.byKey(const ValueKey('pin-2')));
    await tester.tap(find.byKey(const ValueKey('pin-3')));

    expect(entered, ['7912']);
  });
}
