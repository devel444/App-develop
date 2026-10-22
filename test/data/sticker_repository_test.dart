import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/repositories/child_repository.dart';
import 'package:sticker_world/data/repositories/sticker_repository.dart';
import 'package:sticker_world/domain/sticker_rules.dart';

import '../support/test_database.dart';

void main() {
  late AppDatabase db;
  late StickerRepository stickers;
  late int childId;
  late int praiseId;
  late int misdeedId;

  setUp(() async {
    db = createTestDatabase();
    childId = await ChildRepository(db).create(name: '지우');
    stickers = StickerRepository(
      db,
      clock: () => DateTime(2026, 10, 22, 19, 30),
    );
    praiseId = await _categoryId(db, 'praise', '공부');
    misdeedId = await _categoryId(db, 'misdeed', '게임 시간 약속');
  });

  tearDown(() => db.close());

  test('처음 잔액은 0이다', () async {
    expect(await stickers.balance(childId), 0);
  });

  test('붙이면 잔액이 늘고 기록이 한 줄 생긴다', () async {
    await stickers.earn(
      childId: childId,
      categoryId: praiseId,
      memo: '받아쓰기 100점!',
    );

    expect(await stickers.balance(childId), 1);
    final rows = await db.select(db.stickerEvents).get();
    expect(rows, hasLength(1));
    expect(rows.single.eventType, 'earn');
    expect(rows.single.memo, '받아쓰기 100점!');
  });

  test('날짜는 기기 기준 YYYY-MM-DD로 저장된다', () async {
    await stickers.earn(childId: childId, categoryId: praiseId);

    final row = (await db.select(db.stickerEvents).get()).single;
    expect(row.localDate, '2026-10-22');
  });

  test('100개를 넘게 붙이면 거절하고 잔액은 그대로다', () async {
    await stickers.earn(childId: childId, categoryId: praiseId, amount: 100);

    await expectLater(
      stickers.earn(childId: childId, categoryId: praiseId),
      throwsA(isA<StickerRuleException>()),
    );
    expect(await stickers.balance(childId), 100);
  });

  test('빼기는 사유가 없으면 거절한다', () async {
    await stickers.earn(childId: childId, categoryId: praiseId, amount: 3);

    await expectLater(
      stickers.remove(childId: childId, categoryId: misdeedId, memo: '  '),
      throwsA(isA<StickerRuleException>()),
    );
    expect(await stickers.balance(childId), 3);
  });

  test('가진 개수보다 많이 뺄 수 없다', () async {
    await stickers.earn(childId: childId, categoryId: praiseId, amount: 2);

    await expectLater(
      stickers.remove(
        childId: childId,
        categoryId: misdeedId,
        amount: 3,
        memo: '많이 뺌',
      ),
      throwsA(isA<StickerRuleException>()),
    );
    expect(await stickers.balance(childId), 2);
  });

  test('빼면 잔액이 줄고, 기록은 지우지 않고 음수 행을 추가한다', () async {
    await stickers.earn(childId: childId, categoryId: praiseId, amount: 5);
    await stickers.remove(
      childId: childId,
      categoryId: misdeedId,
      memo: '게임 30분 약속했는데 1시간 했어요.',
    );

    expect(await stickers.balance(childId), 4);
    final rows = await db.select(db.stickerEvents).get();
    expect(rows, hasLength(2));
    expect(rows.last.amount, -1);
    expect(rows.last.eventType, 'remove');
  });

  test('누적으로 받은 개수는 빼기와 상관없이 그대로다', () async {
    await stickers.earn(childId: childId, categoryId: praiseId, amount: 5);
    await stickers.remove(
      childId: childId,
      categoryId: misdeedId,
      memo: '약속 어김',
    );

    final summary = await stickers.summary(childId);
    expect(summary.balance, 4);
    expect(summary.totalEarned, 5);
  });
}

Future<int> _categoryId(AppDatabase db, String kind, String name) async {
  final row = await (db.select(
    db.categories,
  )..where((t) => t.kind.equals(kind) & t.name.equals(name))).getSingle();
  return row.id;
}
