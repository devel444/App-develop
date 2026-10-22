import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/features/stamp/stamp_celebration.dart';

void main() {
  testWidgets('도장 연출은 끝나면 onFinished를 한 번 부른다', (tester) async {
    var finished = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: StampCelebration(onFinished: () => finished++)),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));
    expect(finished, 0);

    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump();
    expect(finished, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('빼기 연출은 끝나면 onFinished를 한 번 부른다', (tester) async {
    var finished = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StickerFallCelebration(onFinished: () => finished++),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump();
    expect(finished, 1);
    expect(tester.takeException(), isNull);
  });
}
