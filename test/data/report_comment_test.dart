import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/repositories/child_repository.dart';
import 'package:sticker_world/data/repositories/report_comment_repository.dart';
import 'package:sticker_world/data/repositories/sticker_repository.dart';

import '../support/test_database.dart';

void main() {
  late AppDatabase db;
  late FakeClock clock;
  late int childId;
  late ReportCommentRepository comments;

  setUp(() async {
    db = createTestDatabase();
    clock = FakeClock();
    childId = await ChildRepository(db).create(name: '지우');
    comments = ReportCommentRepository(db, clock: clock.call);
  });

  tearDown(() => db.close());

  Future<String?> current(String periodType, String key) async {
    return (await comments.watch(childId, periodType, key).first)?.content;
  }

  test('한마디를 쓰면 기간별로 하나씩 남고, 다시 쓰면 고쳐진다', () async {
    await comments.save(
      childId: childId,
      periodType: 'week',
      periodKey: '2026-10-19',
      content: '  받아쓰기 잘했어  ',
    );
    await comments.save(
      childId: childId,
      periodType: 'week',
      periodKey: '2026-10-19',
      content: '숙제도 스스로 했네',
    );
    await comments.save(
      childId: childId,
      periodType: 'month',
      periodKey: '2026-10',
      content: '10월 최고!',
    );

    expect(await current('week', '2026-10-19'), '숙제도 스스로 했네');
    expect(await current('month', '2026-10'), '10월 최고!');
    expect(await db.select(db.reportComments).get(), hasLength(2));
  });

  test('빈 글로 저장하면 한마디가 지워진다', () async {
    await comments.save(
      childId: childId,
      periodType: 'all',
      periodKey: 'all',
      content: '사랑해',
    );

    await comments.save(
      childId: childId,
      periodType: 'all',
      periodKey: 'all',
      content: '   ',
    );

    expect(await current('all', 'all'), isNull);
    expect(await db.select(db.reportComments).get(), isEmpty);
  });

  test('스티커 장부 기록이 리포트용 값으로 바뀌어 나온다 (되돌린 기록 포함)', () async {
    final stickers = StickerRepository(db, clock: clock.call);
    final praise = (await db.select(db.categories).get())
        .where((c) => c.kind == 'praise')
        .first
        .id;

    final earnId = await stickers.earn(
      childId: childId,
      categoryId: praise,
      memo: '받아쓰기 100점',
    );
    await stickers.undoLast(childId: childId, undoSeconds: 10);

    final history = await stickers.watchHistory(childId).first;
    expect(history.map((e) => e.type), ['earn', 'undo']);
    final earn = history.firstWhere((e) => e.id == earnId);
    expect(earn.categoryId, praise);
    expect(earn.memo, '받아쓰기 100점');
    expect(earn.localDate, isNotEmpty);
    expect(history.last.relatedEventId, earnId);
  });
}
