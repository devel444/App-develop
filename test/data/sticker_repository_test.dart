import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/repositories/child_repository.dart';
import 'package:sticker_world/data/repositories/sticker_repository.dart';
import 'package:sticker_world/domain/sticker_rules.dart';

import '../support/test_database.dart';

void main() {
  late AppDatabase db;
  late FakeClock clock;
  late StickerRepository stickers;
  late int childId;
  late int praiseId;
  late int misdeedId;
  late int otherMisdeedId;

  setUp(() async {
    db = createTestDatabase();
    clock = FakeClock();
    childId = await ChildRepository(db).create(name: '지우');
    stickers = StickerRepository(db, clock: clock.call);
    praiseId = await _categoryId(db, 'praise', '공부');
    misdeedId = await _categoryId(db, 'misdeed', '게임 시간 약속');
    otherMisdeedId = await _categoryId(db, 'misdeed', '거짓말');
  });

  tearDown(() => db.close());

  test('처음 잔액은 0이다', () async {
    expect((await stickers.view(childId)).balance, 0);
  });

  test('붙이면 잔액이 늘고 기록이 한 줄 생긴다', () async {
    await stickers.earn(
      childId: childId,
      categoryId: praiseId,
      memo: '받아쓰기 100점!',
    );

    expect((await stickers.view(childId)).balance, 1);
    final rows = await db.select(db.stickerEvents).get();
    expect(rows, hasLength(1));
    expect(rows.single.eventType, 'earn');
    expect(rows.single.memo, '받아쓰기 100점!');
  });

  test('날짜는 기기 기준 YYYY-MM-DD로 저장된다', () async {
    clock.now = DateTime(2026, 10, 22, 19, 30);
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
    expect((await stickers.view(childId)).balance, 100);
  });

  test('빼기는 사유가 없으면 거절한다', () async {
    await stickers.earn(childId: childId, categoryId: praiseId, amount: 3);

    await expectLater(
      stickers.recordMisdeed(
        childId: childId,
        categoryId: misdeedId,
        memo: '  ',
      ),
      throwsA(isA<StickerRuleException>()),
    );
    expect((await stickers.view(childId)).balance, 3);
  });

  test('가진 개수보다 많이 뺄 수 없다', () async {
    await stickers.earn(childId: childId, categoryId: praiseId, amount: 2);

    await expectLater(
      stickers.recordMisdeed(
        childId: childId,
        categoryId: misdeedId,
        amount: 3,
        memo: '많이 뺌',
      ),
      throwsA(isA<StickerRuleException>()),
    );
    expect((await stickers.view(childId)).balance, 2);
  });

  test('빼면 잔액이 줄고, 기록은 지우지 않고 음수 행을 추가한다', () async {
    await stickers.earn(childId: childId, categoryId: praiseId, amount: 5);
    await stickers.recordMisdeed(
      childId: childId,
      categoryId: misdeedId,
      memo: '게임 30분 약속했는데 1시간 했어요.',
    );

    expect((await stickers.view(childId)).balance, 4);
    final rows = await db.select(db.stickerEvents).get();
    expect(rows, hasLength(2));
    expect(rows.last.amount, -1);
    expect(rows.last.eventType, 'remove');
  });

  test('누적으로 받은 개수는 빼기와 상관없이 그대로다', () async {
    await stickers.earn(childId: childId, categoryId: praiseId, amount: 5);
    await stickers.recordMisdeed(
      childId: childId,
      categoryId: misdeedId,
      memo: '약속 어김',
    );

    final view = await stickers.view(childId);
    expect(view.balance, 4);
    expect(view.totalEarned, 5);
  });

  group('되돌리기', () {
    test('방금 붙인 스티커는 10초 안에 되돌릴 수 있다', () async {
      await stickers.earn(childId: childId, categoryId: praiseId, amount: 2);
      clock.advance(const Duration(seconds: 9));

      await stickers.undoLast(childId: childId, undoSeconds: 10);

      expect((await stickers.view(childId)).balance, 0);
      expect((await stickers.view(childId)).totalEarned, 0);
      // 되돌리기도 기록으로 남는다.
      expect(await db.select(db.stickerEvents).get(), hasLength(2));
    });

    test('10초가 지나면 되돌릴 수 없다', () async {
      await stickers.earn(childId: childId, categoryId: praiseId);
      clock.advance(const Duration(seconds: 11));

      await expectLater(
        stickers.undoLast(childId: childId, undoSeconds: 10),
        throwsA(isA<StickerRuleException>()),
      );
      expect((await stickers.view(childId)).balance, 1);
    });

    test('빼기도 되돌릴 수 있고, 빼기 전 스티커가 다시 돌아온다', () async {
      await stickers.earn(childId: childId, categoryId: praiseId, amount: 3);
      await stickers.recordMisdeed(
        childId: childId,
        categoryId: misdeedId,
        amount: 2,
        memo: '게임',
      );

      await stickers.undoLast(childId: childId, undoSeconds: 10);

      final view = await stickers.view(childId);
      expect(view.balance, 3);
      expect(view.stack, [praiseId, praiseId, praiseId]);
    });

    test('가장 최근 기록만 되돌릴 수 있다 (앞의 기록은 안 됨)', () async {
      await stickers.earn(childId: childId, categoryId: praiseId);
      await stickers.earn(childId: childId, categoryId: praiseId);

      await stickers.undoLast(childId: childId, undoSeconds: 10);
      await stickers.undoLast(childId: childId, undoSeconds: 10);
      await expectLater(
        stickers.undoLast(childId: childId, undoSeconds: 10),
        throwsA(isA<StickerRuleException>()),
      );
      expect((await stickers.view(childId)).balance, 0);
    });
  });

  group('옐로카드', () {
    test('옐로카드가 켜져 있으면 같은 잘못의 첫 번째는 경고만 남긴다', () async {
      await stickers.earn(childId: childId, categoryId: praiseId, amount: 3);

      final result = await stickers.recordMisdeed(
        childId: childId,
        categoryId: misdeedId,
        memo: '게임 시간 초과',
        yellowCardOn: true,
      );

      expect(result.outcome, MisdeedOutcome.warned);
      expect((await stickers.view(childId)).balance, 3);
    });

    test('같은 주에 같은 잘못이 두 번째면 스티커를 뺀다', () async {
      await stickers.earn(childId: childId, categoryId: praiseId, amount: 3);
      await stickers.recordMisdeed(
        childId: childId,
        categoryId: misdeedId,
        memo: '첫 번째',
        yellowCardOn: true,
      );

      final second = await stickers.recordMisdeed(
        childId: childId,
        categoryId: misdeedId,
        memo: '두 번째',
        yellowCardOn: true,
      );

      expect(second.outcome, MisdeedOutcome.removed);
      expect((await stickers.view(childId)).balance, 2);
    });

    test('다른 잘못이면 각각 처음으로 보고 경고만 남긴다', () async {
      await stickers.earn(childId: childId, categoryId: praiseId, amount: 3);
      await stickers.recordMisdeed(
        childId: childId,
        categoryId: misdeedId,
        memo: '게임',
        yellowCardOn: true,
      );

      final other = await stickers.recordMisdeed(
        childId: childId,
        categoryId: otherMisdeedId,
        memo: '거짓말',
        yellowCardOn: true,
      );

      expect(other.outcome, MisdeedOutcome.warned);
    });

    test('지난 주의 경고는 이번 주에 세지 않는다', () async {
      await stickers.earn(childId: childId, categoryId: praiseId, amount: 3);
      clock.now = DateTime(2026, 10, 14, 19); // 수요일
      await stickers.recordMisdeed(
        childId: childId,
        categoryId: misdeedId,
        memo: '지난 주',
        yellowCardOn: true,
      );

      clock.now = DateTime(2026, 10, 20, 19); // 다음 주 화요일
      final result = await stickers.recordMisdeed(
        childId: childId,
        categoryId: misdeedId,
        memo: '이번 주 첫 번째',
        yellowCardOn: true,
      );

      expect(result.outcome, MisdeedOutcome.warned);
    });

    test('경고만 버튼은 설정과 상관없이 스티커를 빼지 않는다', () async {
      await stickers.earn(childId: childId, categoryId: praiseId, amount: 3);

      final result = await stickers.recordMisdeed(
        childId: childId,
        categoryId: misdeedId,
        memo: '그냥 경고',
        warnOnly: true,
      );

      expect(result.outcome, MisdeedOutcome.warned);
      expect((await stickers.view(childId)).balance, 3);
    });
  });
}

Future<int> _categoryId(AppDatabase db, String kind, String name) async {
  final row = await (db.select(
    db.categories,
  )..where((t) => t.kind.equals(kind) & t.name.equals(name))).getSingle();
  return row.id;
}
