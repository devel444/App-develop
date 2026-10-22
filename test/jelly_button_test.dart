import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/jelly_button.dart';

void main() {
  testWidgets('젤리 버튼은 눌리면 onTap을 한 번 부른다', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: JellyButton(
            color: AppColors.red,
            width: 200,
            onTap: () => taps++,
            child: const Center(child: Text('붙이기')),
          ),
        ),
      ),
    );

    await tester.tap(find.text('붙이기'));
    await tester.pumpAndSettle();

    expect(taps, 1);
  });

  testWidgets('onTap이 없으면 눌러도 아무 일도 없다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: JellyButton(
            color: AppColors.red,
            width: 200,
            child: const Center(child: Text('잠금')),
          ),
        ),
      ),
    );

    await tester.tap(find.text('잠금'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
