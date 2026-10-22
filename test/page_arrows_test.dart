import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/core/widgets/page_arrows.dart';

void main() {
  testWidgets('오른쪽 화살표를 누르면 onNext가 불린다', (tester) async {
    var next = 0;
    var previous = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PageArrows(
            onNext: () => next++,
            onPrevious: () => previous++,
            child: const Center(child: Text('월드 2')),
          ),
        ),
      ),
    );

    await tester.tap(find.bySemanticsLabel('다음'));
    await tester.pump();

    expect(next, 1);
    expect(previous, 0);
  });
}
