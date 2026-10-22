import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/repositories/badge_repository.dart';
import 'package:sticker_world/data/repositories/child_repository.dart';
import 'package:sticker_world/data/repositories/diary_repository.dart';
import 'package:sticker_world/data/repositories/sticker_repository.dart';
import 'package:sticker_world/domain/badge_rules.dart';

import '../support/test_database.dart';

void main() {
  late AppDatabase db;
  late FakeClock clock;
  late int childId;
  late StickerRepository stickers;
  late BadgeRepository badges;
  late int praiseStudyId;

  setUp(() async {
    db = createTestDatabase();
    clock = FakeClock();
    childId = await ChildRepository(db).create(name: '지우');
    stickers = StickerRepository(db, clock: clock.call);
    badges = BadgeRepository(db, stickers, clock: clock.call);
    praiseStudyId = (await db.select(db.categories).get())
        .firstWhere((c) => c.name == '공부')
        .id;
  });

  tearDown(() => db.close());

  Future<Set<String>> earnedCodes() async {
    final rows = await (db.select(
      db.badgeAwards,
    )..where((t) => t.childId.equals(childId))).get();
    return {for (final row in rows) row.badgeCode};
  }

  Future<void> earnStudy(int count) async {
    for (var i = 0; i < count; i++) {
      await stickers.earn(childId: childId, categoryId: praiseStudyId);
    }
  }

  test('시드 배지 조건은 모두 읽을 수 있다', () async {
    final catalog = await db.select(db.badges).get();

    expect(catalog, isNotEmpty);
    for (final badge in catalog) {
      expect(BadgeRule.tryParse(badge.ruleJson), isNotNull, reason: badge.code);
    }
  });

  test('첫 스티커를 붙이면 첫 스티커 배지를 얻고, 다시 판정해도 한 번만 준다', () async {
    await earnStudy(1);

    final first = await badges.evaluate(childId: childId);
    final again = await badges.evaluate(childId: childId);

    expect(first.map((b) => b.code), contains('first_sticker'));
    expect(again, isEmpty);
    expect(await earnedCodes(), contains('first_sticker'));
    expect(await (db.select(db.badgeAwards)).get(), hasLength(first.length));
  });

  test('아직 조건이 안 된 배지는 얻지 않는다', () async {
    await earnStudy(1);

    await badges.evaluate(childId: childId);

    expect(await earnedCodes(), isNot(contains('world_1')));
    expect(await earnedCodes(), isNot(contains('study_1')));
  });

  test('공부 칭찬 10개면 공부왕 I, 하루에 5개 받으면 숨김 배지', () async {
    await earnStudy(10);

    final newly = await badges.evaluate(childId: childId);

    expect(
      newly.map((b) => b.code),
      containsAll(['study_1', 'hidden_five_today']),
    );
    expect(await earnedCodes(), containsAll(['study_1', 'hidden_five_today']));
  });

  test('꺼 둔 배지는 조건이 맞아도 얻지 않는다', () async {
    await (db.update(db.badges)..where((t) => t.code.equals('first_sticker')))
        .write(const BadgesCompanion(isActive: Value(false)));
    await earnStudy(1);

    final newly = await badges.evaluate(childId: childId);

    expect(newly.map((b) => b.code), isNot(contains('first_sticker')));
    expect(await earnedCodes(), isNot(contains('first_sticker')));
  });

  test('보너스가 설정된 배지를 얻으면 보너스 스티커가 붙는다', () async {
    await (db.update(db.badges)..where((t) => t.code.equals('first_sticker')))
        .write(const BadgesCompanion(bonusAmount: Value(2)));
    await earnStudy(1);

    await badges.evaluate(childId: childId);

    final view = await stickers.view(childId);
    expect(view.balance, 3);
    final bonus = await (db.select(
      db.stickerEvents,
    )..where((t) => t.eventType.equals('bonus'))).getSingle();
    expect(bonus.amount, 2);
    expect(bonus.memo, '배지: 첫 스티커');
  });

  test('일기를 쓰면 일기 배지를 얻는다', () async {
    await DiaryRepository(db, clock: clock.call).save(
      childId: childId,
      localDate: '2026-10-22',
      weather: null,
      mood: null,
      title: '오늘',
      body: '재미있었다',
    );

    final newly = await badges.evaluate(childId: childId);

    expect(newly.map((b) => b.code), contains('diary_1'));
  });

  test('도감용 숫자는 지금까지 기록으로 계산된다', () async {
    await earnStudy(3);

    final stats = await badges.statsFor(childId);

    expect(stats, isNotNull);
    expect(stats!.value('study'), 3);
    expect(stats.value('balance'), 3);
  });

  test('얻은 배지는 최근 순으로 보인다', () async {
    await earnStudy(10);
    await badges.evaluate(childId: childId);

    final awards = await badges.watchAwards(childId).first;

    expect(awards, isNotEmpty);
    for (var i = 1; i < awards.length; i++) {
      expect(
        awards[i - 1].awardedAt.isAfter(awards[i].awardedAt) ||
            awards[i - 1].awardedAt.isAtSameMomentAs(awards[i].awardedAt),
        isTrue,
      );
    }
  });
}
