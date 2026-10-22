import 'package:drift/drift.dart';
import 'package:sticker_world/core/time/local_date.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/domain/duolingo_rules.dart';

/// 듀오링고 확인 기록(스냅샷)과 아이의 듀오링고 아이디·패키지 설정.
class DuolingoRepository {
  DuolingoRepository(this._db);

  final AppDatabase _db;

  /// 오늘 이전에 저장해 둔 가장 최근 XP. 없으면 null.
  Future<int?> previousXp(int childId, String today) async {
    final rows =
        await (_db.select(_db.duolingoSnapshots)
              ..where((t) => t.childId.equals(childId) & t.ok.equals(true))
              ..orderBy([(t) => OrderingTerm.desc(t.id)]))
            .get();
    for (final row in rows) {
      if (row.totalXp != null &&
          localDateKey(row.checkedAt).compareTo(today) < 0) {
        return row.totalXp;
      }
    }
    return null;
  }

  Future<void> saveSnapshot({
    required int childId,
    required String method,
    required bool ok,
    DuolingoProfile? profile,
    DateTime? when,
  }) {
    return _db
        .into(_db.duolingoSnapshots)
        .insert(
          DuolingoSnapshotsCompanion.insert(
            childId: childId,
            checkedAt: Value(when ?? DateTime.now()),
            totalXp: Value(profile?.totalXp),
            streak: Value(profile?.streak),
            streakEndDate: Value(profile?.streakEndDate),
            method: method,
            ok: ok,
          ),
        );
  }

  Future<DuolingoSnapshot?> latest(int childId) {
    return _latestQuery(childId).getSingleOrNull();
  }

  /// 새 확인 기록이 생기면 바로 바뀌는 최신 기록.
  Stream<DuolingoSnapshot?> watchLatest(int childId) {
    return _latestQuery(childId).watchSingleOrNull();
  }

  SimpleSelectStatement<$DuolingoSnapshotsTable, DuolingoSnapshot> _latestQuery(
    int childId,
  ) {
    return _db.select(_db.duolingoSnapshots)
      ..where((t) => t.childId.equals(childId))
      ..orderBy([(t) => OrderingTerm.desc(t.id)])
      ..limit(1);
  }
}
