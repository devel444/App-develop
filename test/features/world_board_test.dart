import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/features/world/world_board.dart';

void main() {
  testWidgets('37개를 가진 아이의 월드 2에는 캐릭터 토큰과 선물 칸이 보인다', (tester) async {
    tester.view.physicalSize = const Size(800, 1280);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: WorldBoard(
              world: 1,
              balance: 37,
              stack: List.filled(37, 1),
              colorOf: (_) => AppColors.categoryStudy,
            ),
          ),
        ),
      ),
    );

    // 37번 칸에 캐릭터 토큰
    expect(find.text('지'), findsOneWidget);
    // 채운 칸 개수: 21~37 중 선물 칸 30을 뺀 16칸은 별, 30은 선물 블록
    expect(find.byIcon(Icons.star_rounded), findsNWidgets(16));
    // 아직 못 채운 칸은 번호가 보인다 (38~40)
    expect(find.text('38'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('0개면 토큰은 보이지 않는다', (tester) async {
    tester.view.physicalSize = const Size(800, 1280);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: WorldBoard(
              world: 0,
              balance: 0,
              stack: const [],
              colorOf: (_) => AppColors.categoryStudy,
            ),
          ),
        ),
      ),
    );

    expect(find.text('지'), findsNothing);
    expect(find.byIcon(Icons.star_rounded), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
