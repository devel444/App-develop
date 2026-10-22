import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/core/assets/asset_resolver.dart';
import 'package:sticker_world/core/time/local_date.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/providers.dart';
import 'package:sticker_world/domain/growth_report.dart';
import 'package:sticker_world/features/records/records_screen.dart';

/// 기록 탭 화면 테스트. DB 대신 고정 값을 쓴다 (Drift 스트림은 가짜 시간에서 멈출 수 있다).
Widget _recordsApp() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day, 10);
  return ProviderScope(
    overrides: [
      currentChildProvider.overrideWith(
        (ref) => Stream.value(
          ChildrenData(
            id: 1,
            name: '지우',
            duolingoPackage: 'com.duolingo',
            createdAt: today,
          ),
        ),
      ),
      stickerHistoryProvider.overrideWith(
        (ref) => Stream.value([
          GrowthEvent(
            id: 1,
            type: 'earn',
            amount: 1,
            localDate: localDateKey(today),
            createdAt: today,
            categoryId: 1,
            memo: '받아쓰기 100점',
          ),
        ]),
      ),
      categoryNamesProvider.overrideWith(
        (ref) async => {1: '공부', 11: '게임 시간 약속'},
      ),
      clearDatesProvider.overrideWith((ref) => Stream.value(const <String>{})),
      diaryEntriesProvider.overrideWith((ref) => Stream.value(const [])),
      routinesProvider.overrideWith((ref) => Stream.value(const [])),
      routineLogsProvider.overrideWith((ref, date) => Stream.value(const [])),
      diaryOnProvider.overrideWith((ref, date) => Stream.value(null)),
      duolingoLatestProvider.overrideWith((ref) => Stream.value(null)),
      reportCommentProvider.overrideWith((ref, key) => Stream.value(null)),
    ],
    child: const MaterialApp(home: RecordsScreen()),
  );
}

void main() {
  setUpAll(() async {
    await AssetResolver.init();
  });

  testWidgets('기록 탭은 달력을 먼저 보여 주고, 옆으로 넘기면 리포트가 나온다', (tester) async {
    tester.view.physicalSize = const Size(800, 1280);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_recordsApp());
    await tester.pumpAndSettle();

    expect(find.text('기록'), findsWidgets);
    expect(find.text('토'), findsWidgets);
    expect(find.text('지금 잘하고 있는 점'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.fling(find.byType(PageView), const Offset(-600, 0), 1200);
    await tester.pumpAndSettle();

    expect(find.text('지금 잘하고 있는 점'), findsWidgets);
    expect(find.text('고쳐나가야 할 점'), findsWidgets);
    expect(find.text('엄마·아빠 한마디'), findsWidgets);
    expect(find.text('아직 한마디가 없어요'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
