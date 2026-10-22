import 'package:drift/drift.dart';
import 'package:sticker_world/data/db/app_database.dart';

/// 선물 목록과 교환권. 선물 추가·수정은 부모 PIN을 확인한 화면에서만 호출한다.
class RewardRepository {
  RewardRepository(this._db);

  final AppDatabase _db;

  Stream<List<Reward>> watchActive() {
    return (_db.select(_db.rewards)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([
            (t) => OrderingTerm.asc(t.cost),
            (t) => OrderingTerm.asc(t.id),
          ]))
        .watch();
  }

  Stream<List<Reward>> watchAll() {
    return (_db.select(_db.rewards)..orderBy([
          (t) => OrderingTerm.asc(t.cost),
          (t) => OrderingTerm.asc(t.id),
        ]))
        .watch();
  }

  Future<int> create({required String name, required int cost}) {
    return _db
        .into(_db.rewards)
        .insert(RewardsCompanion.insert(name: name, cost: cost));
  }

  Future<void> update({
    required int id,
    required String name,
    required int cost,
    required bool isActive,
  }) {
    return (_db.update(_db.rewards)..where((t) => t.id.equals(id))).write(
      RewardsCompanion(
        name: Value(name),
        cost: Value(cost),
        isActive: Value(isActive),
      ),
    );
  }

  /// 교환 기록이 없으면 지우고, 있으면 목록에서만 숨긴다 (교환권이 깨지지 않게).
  /// 지웠으면 true, 숨겼으면 false.
  Future<bool> remove(int id) {
    return _db.transaction(() async {
      final used =
          await (_db.select(_db.redemptions)
                ..where((t) => t.rewardId.equals(id))
                ..limit(1))
              .get();
      if (used.isEmpty) {
        await (_db.delete(_db.rewards)..where((t) => t.id.equals(id))).go();
        return true;
      }
      await (_db.update(_db.rewards)..where((t) => t.id.equals(id))).write(
        const RewardsCompanion(isActive: Value(false)),
      );
      return false;
    });
  }

  Stream<List<Redemption>> watchRedemptions(int childId) {
    return (_db.select(_db.redemptions)
          ..where((t) => t.childId.equals(childId))
          ..orderBy([(t) => OrderingTerm.desc(t.id)]))
        .watch();
  }

  /// 선물을 실제로 받았을 때 (부모가 PIN을 맞춘 뒤 누른다).
  Future<void> markDelivered(int redemptionId, DateTime when) {
    return (_db.update(_db.redemptions)
          ..where((t) => t.id.equals(redemptionId)))
        .write(RedemptionsCompanion(deliveredAt: Value(when)));
  }
}
