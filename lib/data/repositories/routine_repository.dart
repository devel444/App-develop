import 'package:drift/drift.dart';
import 'package:sticker_world/core/time/local_date.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/repositories/settings_repository.dart';
import 'package:sticker_world/data/repositories/sticker_repository.dart';
import 'package:sticker_world/domain/routine_rules.dart';

/// 완료 결과. [cleared]는 이번 체크로 오늘 올클리어가 된 경우다.
class CompleteResult {
  const CompleteResult({
    this.alreadyDone = false,
    this.cleared = false,
    this.bonusPending = false,
  });

  final bool alreadyDone;
  final bool cleared;

  /// 올클리어 보너스가 엄마·아빠 확인을 기다리는지.
  final bool bonusPending;
}

/// 오늘의 할 일: 루틴 목록, 체크, 올클리어, 보너스 대기.
class RoutineRepository {
  RoutineRepository(
    this._db, {
    required this.stickers,
    required this.settings,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final StickerRepository stickers;
  final SettingsRepository settings;
  final DateTime Function() _clock;

  Stream<List<Routine>> watchAll() {
    return (_db.select(_db.routines)..orderBy([
          (t) => OrderingTerm.asc(t.sortOrder),
          (t) => OrderingTerm.asc(t.id),
        ]))
        .watch();
  }

  Stream<List<RoutineLog>> watchLogs(String localDate) {
    return (_db.select(
      _db.routineLogs,
    )..where((t) => t.localDate.equals(localDate))).watch();
  }

  /// 올클리어한 날짜들 (연속 일수 계산용).
  Stream<List<String>> watchClearDates(int childId) {
    return (_db.select(_db.dailyClears)
          ..where((t) => t.childId.equals(childId)))
        .watch()
        .map((rows) => rows.map((row) => row.localDate).toList());
  }

  Stream<List<DailyClear>> watchPendingBonuses(int childId) {
    return (_db.select(_db.dailyClears)..where(
          (t) => t.childId.equals(childId) & t.bonusStatus.equals('pending'),
        ))
        .watch();
  }

  Future<int> create({
    required int childId,
    required String title,
    required String iconKey,
    required String kind,
    required String timeSlot,
    int daysMask = RoutineDays.all,
    int? timerMinutes,
  }) async {
    final existing = await _db.select(_db.routines).get();
    final nextOrder =
        existing.fold<int>(
          -1,
          (max, row) => row.sortOrder > max ? row.sortOrder : max,
        ) +
        1;
    return _db
        .into(_db.routines)
        .insert(
          RoutinesCompanion.insert(
            childId: childId,
            title: title,
            iconKey: iconKey,
            kind: kind,
            timeSlot: timeSlot,
            daysMask: Value(daysMask),
            timerMinutes: Value(timerMinutes),
            sortOrder: Value(nextOrder),
          ),
        );
  }

  Future<void> update(Routine routine) {
    return (_db.update(
      _db.routines,
    )..where((t) => t.id.equals(routine.id))).write(
      RoutinesCompanion(
        title: Value(routine.title),
        iconKey: Value(routine.iconKey),
        kind: Value(routine.kind),
        timeSlot: Value(routine.timeSlot),
        daysMask: Value(routine.daysMask),
        timerMinutes: Value(routine.timerMinutes),
        isActive: Value(routine.isActive),
      ),
    );
  }

  /// 기록이 있는 루틴은 지우지 않고 숨긴다. 지웠으면 true.
  Future<bool> remove(int routineId) {
    return _db.transaction(() async {
      final logs =
          await (_db.select(_db.routineLogs)
                ..where((t) => t.routineId.equals(routineId))
                ..limit(1))
              .get();
      if (logs.isEmpty) {
        await (_db.delete(
          _db.routines,
        )..where((t) => t.id.equals(routineId))).go();
        return true;
      }
      await (_db.update(_db.routines)..where((t) => t.id.equals(routineId)))
          .write(const RoutinesCompanion(isActive: Value(false)));
      return false;
    });
  }

  /// 보이는 순서대로 받은 id 목록을 0, 1, 2… 순서로 저장한다.
  Future<void> reorder(List<int> idsInOrder) {
    return _db.transaction(() async {
      for (var i = 0; i < idsInOrder.length; i++) {
        await (_db.update(_db.routines)
              ..where((t) => t.id.equals(idsInOrder[i])))
            .write(RoutinesCompanion(sortOrder: Value(i)));
      }
    });
  }

  /// 체크. 아이가 누르면 source는 'child', 엄마·아빠가 PIN 후 누르면 'parent'.
  Future<CompleteResult> complete({
    required int routineId,
    required String source,
  }) {
    return _db.transaction(() async {
      final now = _clock();
      final date = localDateKey(now);

      final routine = await (_db.select(
        _db.routines,
      )..where((t) => t.id.equals(routineId))).getSingle();

      final alreadyLog =
          await (_db.select(_db.routineLogs)..where(
                (t) => t.routineId.equals(routineId) & t.localDate.equals(date),
              ))
              .getSingleOrNull();
      if (alreadyLog != null) {
        return const CompleteResult(alreadyDone: true);
      }

      await _db
          .into(_db.routineLogs)
          .insert(
            RoutineLogsCompanion.insert(
              routineId: routineId,
              localDate: date,
              source: source,
            ),
          );

      final dueToday = await _dueRoutinesOn(routine.childId, now);
      if (dueToday.isEmpty) {
        return const CompleteResult();
      }
      final doneIds =
          (await (_db.select(
                _db.routineLogs,
              )..where((t) => t.localDate.equals(date))).get())
              .map((log) => log.routineId)
              .toSet();
      final allDone = dueToday.every((r) => doneIds.contains(r.id));
      if (!allDone) {
        return const CompleteResult();
      }

      final alreadyCleared =
          await (_db.select(_db.dailyClears)..where(
                (t) =>
                    t.childId.equals(routine.childId) &
                    t.localDate.equals(date),
              ))
              .getSingleOrNull();
      if (alreadyCleared != null) {
        return const CompleteResult();
      }

      final mode = await settings.get('all_clear_bonus') ?? 'pending';
      final status = switch (mode) {
        'auto' => 'granted',
        'off' => 'none',
        _ => 'pending',
      };
      await _db
          .into(_db.dailyClears)
          .insert(
            DailyClearsCompanion.insert(
              childId: routine.childId,
              localDate: date,
              bonusStatus: Value(status),
            ),
          );
      if (status == 'granted') {
        await stickers.grantBonus(
          childId: routine.childId,
          amount: await _bonusAmount(),
        );
      }
      return CompleteResult(cleared: true, bonusPending: status == 'pending');
    });
  }

  /// 오늘 해야 하는 종류(kind)의 루틴 중 첫 번째를 체크한다 (예: 일기를 저장하면 'diary').
  /// 그런 루틴이 없으면 null.
  Future<CompleteResult?> completeFirstDue({
    required int childId,
    required String kind,
    required String source,
  }) async {
    final due = (await _dueRoutinesOn(
      childId,
      _clock(),
    )).where((r) => r.kind == kind).toList();
    if (due.isEmpty) {
      return null;
    }
    return complete(routineId: due.first.id, source: source);
  }

  /// 잘못 눌렀을 때 오늘 체크를 지운다 (엄마·아빠 PIN 후 호출).
  Future<void> uncomplete(int routineId) {
    final date = localDateKey(_clock());
    return (_db.delete(_db.routineLogs)..where(
          (t) => t.routineId.equals(routineId) & t.localDate.equals(date),
        ))
        .go();
  }

  /// 대기 중인 올클리어 보너스를 엄마·아빠가 확정한다 (PIN 후 호출).
  Future<void> confirmBonus(int dailyClearId) {
    return _db.transaction(() async {
      final row = await (_db.select(
        _db.dailyClears,
      )..where((t) => t.id.equals(dailyClearId))).getSingle();
      if (row.bonusStatus != 'pending') {
        return;
      }
      await stickers.grantBonus(
        childId: row.childId,
        amount: await _bonusAmount(),
      );
      await (_db.update(_db.dailyClears)
            ..where((t) => t.id.equals(dailyClearId)))
          .write(const DailyClearsCompanion(bonusStatus: Value('granted')));
    });
  }

  Future<List<Routine>> _dueRoutinesOn(int childId, DateTime day) async {
    final rows = await (_db.select(
      _db.routines,
    )..where((t) => t.childId.equals(childId) & t.isActive.equals(true))).get();
    return rows.where((r) => RoutineDays.includes(r.daysMask, day)).toList();
  }

  Future<int> _bonusAmount() async {
    return settings.getInt('bonus_amount', fallback: 1);
  }
}
