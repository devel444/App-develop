import 'package:drift/drift.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/repositories/duolingo_repository.dart';
import 'package:sticker_world/data/repositories/sticker_repository.dart';
import 'package:sticker_world/domain/badge_rules.dart';
import 'package:sticker_world/domain/sticker_rules.dart';

/// 배지 도감과 배지 판정. 한 아이당 배지는 한 번만 얻는다.
/// 이 클래스는 PIN을 확인하지 않는다 (배지는 아이가 받는 것이라 PIN이 필요 없다).
class BadgeRepository {
  BadgeRepository(this._db, this._stickers, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final StickerRepository _stickers;
  final DateTime Function() _clock;

  /// 켜져 있는 배지 목록 (도감에 보이는 순서).
  Stream<List<Badge>> watchCatalog() {
    return (_db.select(
      _db.badges,
    )..where((t) => t.isActive.equals(true))).watch();
  }

  /// 부모 설정용: 꺼 둔 배지까지 모두.
  Stream<List<Badge>> watchAllBadges() {
    return (_db.select(
      _db.badges,
    )..orderBy([(t) => OrderingTerm.asc(t.code)])).watch();
  }

  /// 끄면 조건이 맞아도 얻지 않는다. 이미 얻은 배지는 그대로 둔다.
  Future<void> setBadgeActive(String code, {required bool active}) {
    return (_db.update(_db.badges)..where((t) => t.code.equals(code))).write(
      BadgesCompanion(isActive: Value(active)),
    );
  }

  /// 얻은 배지. 최근에 얻은 것이 위로 온다.
  Stream<List<BadgeAward>> watchAwards(int childId) {
    return (_db.select(_db.badgeAwards)
          ..where((t) => t.childId.equals(childId))
          ..orderBy([(t) => OrderingTerm.desc(t.awardedAt)]))
        .watch();
  }

  /// 지금 시점의 배지 숫자. 아이가 없으면 null.
  Future<BadgeStats?> statsFor(int childId) async {
    final child = await (_db.select(
      _db.children,
    )..where((t) => t.id.equals(childId))).getSingleOrNull();
    if (child == null) {
      return null;
    }
    final events = await _stickers.history(childId);
    final clears = await (_db.select(
      _db.dailyClears,
    )..where((t) => t.childId.equals(childId))).get();
    final diaries = await (_db.select(
      _db.diaryEntries,
    )..where((t) => t.childId.equals(childId))).get();
    final duolingo = await DuolingoRepository(_db).latest(childId);
    final categories = await _db.select(_db.categories).get();

    return BadgeStats.from(
      events: events,
      clearDates: {for (final clear in clears) clear.localDate},
      diaryCount: diaries.length,
      duoStreak: duolingo != null && duolingo.ok ? duolingo.streak : null,
      createdAt: child.createdAt,
      categoryNames: {
        for (final category in categories) category.id: category.name,
      },
      now: _clock(),
    );
  }

  /// 조건을 채운 배지를 얻게 한다. 새로 얻은 배지만 돌려준다 (팝업용).
  /// 보너스 스티커가 설정된 배지는 함께 붙인다 (가득 차 있으면 건너뛴다).
  Future<List<Badge>> evaluate({required int childId}) async {
    final badges = await (_db.select(
      _db.badges,
    )..where((t) => t.isActive.equals(true))).get();
    final awarded = await (_db.select(
      _db.badgeAwards,
    )..where((t) => t.childId.equals(childId))).get();
    final done = {for (final award in awarded) award.badgeCode};
    final pending = [
      for (final badge in badges)
        if (!done.contains(badge.code)) badge,
    ];
    if (pending.isEmpty) {
      return const [];
    }
    final stats = await statsFor(childId);
    if (stats == null) {
      return const [];
    }

    final newly = <Badge>[];
    for (final badge in pending) {
      final rule = BadgeRule.tryParse(badge.ruleJson);
      if (rule == null || !rule.isMet(stats)) {
        continue;
      }
      if (await _awardOnce(childId, badge.code)) {
        newly.add(badge);
      }
    }

    for (final badge in newly) {
      if (badge.bonusAmount <= 0) {
        continue;
      }
      try {
        await _stickers.grantBonus(
          childId: childId,
          amount: badge.bonusAmount,
          memo: '배지: ${badge.name}',
        );
      } on StickerRuleException {
        // 스티커가 가득 차 있으면 배지만 얻고 보너스는 건너뛴다.
      }
    }
    return newly;
  }

  /// 같은 배지가 이미 있으면 아무 것도 하지 않는다. 얻었으면 true.
  Future<bool> _awardOnce(int childId, String code) {
    return _db.transaction(() async {
      final existing =
          await (_db.select(_db.badgeAwards)..where(
                (t) => t.childId.equals(childId) & t.badgeCode.equals(code),
              ))
              .getSingleOrNull();
      if (existing != null) {
        return false;
      }
      await _db
          .into(_db.badgeAwards)
          .insert(
            BadgeAwardsCompanion.insert(
              badgeCode: code,
              childId: childId,
              awardedAt: Value(_clock()),
            ),
          );
      return true;
    });
  }
}
