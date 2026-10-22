import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/features/shop/ticket_card.dart';

void main() {
  testWidgets('교환권은 이름과 번호를 보여 주고, 버튼을 누르면 눌린다', (tester) async {
    var pressed = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 700,
              child: TicketCard(
                title: '아이스크림',
                subtitle: 'No.001 · 20개',
                trailing: TextButton(
                  onPressed: () => pressed++,
                  child: const Text('받았어요'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('아이스크림'), findsOneWidget);
    expect(find.text('No.001 · 20개'), findsOneWidget);
    await tester.tap(find.text('받았어요'));
    expect(pressed, 1);
    expect(tester.takeException(), isNull);
  });
}
