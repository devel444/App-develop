import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/repositories/child_repository.dart';
import 'package:sticker_world/data/repositories/reward_repository.dart';
import 'package:sticker_world/data/repositories/sticker_repository.dart';
import 'package:sticker_world/domain/sticker_rules.dart';

import '../support/test_database.dart';

void main() {
  late AppDatabase db;
  late FakeClock clock;
  late StickerRepository stickers;
  late RewardRepository rewards;
  late int childId;
  late int praiseId;
  late int misdeedId;

  setUp(() async {
    db = createTestDatabase();
    clock = FakeClock();
    childId = await ChildRepository(db).create(name: '지우');
    stickers = StickerRepository(db, clock: clock.call);
    rewards = RewardRepository(db);
    praiseId = await _categoryId(db, 'praise', '공부');
    misdeedId = await _categoryId(db, 'misdeed', '게임 시간 약속');
  });

  tearDown(() => db.close());

  test('가격만큼 스티커가 빠지고 교환권 번호가 매겨진다', () async {
    final jelly = await rewards.create(name: '젤리 세트', cost: 30);
    await stickers.earn(childId: childId, categoryId: praiseId, amount: 35);

    final result = await stickers.redeem(childId: childId, rewardId: jelly);

    expect(result.voucherNo, 'No.001');
    expect(result.cost, 30);
    final view = await stickers.view(childId);
    expect(view.balance, 5);
    expect(view.stack, hasLength(5));
    expect(view.totalEarned, 35); // 누적은 교환과 상관없이 그대로
  });

  test('두 번째 교환권은 No.002', () async {
    final jelly = await rewards.create(name: '젤리 세트', cost: 10);
    await stickers.earn(childId: childId, categoryId: praiseId, amount: 25);

    await stickers.redeem(childId: childId, rewardId: jelly);
    final second = await stickers.redeem(childId: childId, rewardId: jelly);

    expect(second.voucherNo, 'No.002');
    expect((await stickers.view(childId)).balance, 5);
  });

  test('모자라면 몇 개 더 모아야 하는지 알려 주고 교환하지 않는다', () async {
    final lego = await rewards.create(name: '레고 자동차', cost: 50);
    await stickers.earn(childId: childId, categoryId: praiseId, amount: 37);

    await expectLater(
      stickers.redeem(childId: childId, rewardId: lego),
      throwsA(
        isA<StickerRuleException>().having(
          (e) => e.message,
          'message',
          '13개 더 모으면 살 수 있어요.',
        ),
      ),
    );
    expect((await stickers.view(childId)).balance, 37);
    expect(await db.select(db.redemptions).get(), isEmpty);
  });

  test('숨긴 선물은 교환할 수 없다', () async {
    final jelly = await rewards.create(name: '젤리 세트', cost: 10);
    await rewards.update(id: jelly, name: '젤리 세트', cost: 10, isActive: false);
    await stickers.earn(childId: childId, categoryId: praiseId, amount: 20);

    await expectLater(
      stickers.redeem(childId: childId, rewardId: jelly),
      throwsA(isA<StickerRuleException>()),
    );
  });

  test('교환한 뒤에는 되돌릴 수 없다', () async {
    final jelly = await rewards.create(name: '젤리 세트', cost: 10);
    await stickers.earn(childId: childId, categoryId: praiseId, amount: 20);
    await stickers.redeem(childId: childId, rewardId: jelly);

    await expectLater(
      stickers.undoLast(childId: childId, undoSeconds: 10),
      throwsA(isA<StickerRuleException>()),
    );
    expect((await stickers.view(childId)).balance, 10);
  });

  test('교환 뒤에는 빼기로 줄어든 스티커를 되돌릴 수 없다는 것도 지킨다', () async {
    final jelly = await rewards.create(name: '젤리 세트', cost: 10);
    await stickers.earn(childId: childId, categoryId: praiseId, amount: 20);
    await stickers.redeem(childId: childId, rewardId: jelly);
    await stickers.recordMisdeed(
      childId: childId,
      categoryId: misdeedId,
      memo: '게임',
    );

    await stickers.undoLast(childId: childId, undoSeconds: 10);

    expect((await stickers.view(childId)).balance, 10);
  });

  test('받았다고 표시하면 받음 상태가 된다', () async {
    final jelly = await rewards.create(name: '젤리 세트', cost: 10);
    await stickers.earn(childId: childId, categoryId: praiseId, amount: 10);
    final result = await stickers.redeem(childId: childId, rewardId: jelly);

    await rewards.markDelivered(result.redemptionId, clock.now);

    final row = await (db.select(
      db.redemptions,
    )..where((t) => t.id.equals(result.redemptionId))).getSingle();
    expect(row.deliveredAt, isNotNull);
  });

  test('교환 기록이 있는 선물은 지우지 않고 숨긴다', () async {
    final jelly = await rewards.create(name: '젤리 세트', cost: 10);
    await stickers.earn(childId: childId, categoryId: praiseId, amount: 10);
    await stickers.redeem(childId: childId, rewardId: jelly);

    final deleted = await rewards.remove(jelly);

    expect(deleted, isFalse);
    final row = await (db.select(
      db.rewards,
    )..where((t) => t.id.equals(jelly))).getSingle();
    expect(row.isActive, isFalse);
  });

  test('교환 기록이 없는 선물은 지운다', () async {
    final jelly = await rewards.create(name: '젤리 세트', cost: 10);

    final deleted = await rewards.remove(jelly);

    expect(deleted, isTrue);
    expect(await db.select(db.rewards).get(), isEmpty);
  });
}

Future<int> _categoryId(AppDatabase db, String kind, String name) async {
  final row = await (db.select(
    db.categories,
  )..where((t) => t.kind.equals(kind) & t.name.equals(name))).getSingle();
  return row.id;
}
