import 'package:drift/drift.dart';
import 'package:sticker_world/core/time/local_date.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/domain/sticker_ledger.dart';
import 'package:sticker_world/domain/sticker_rules.dart';

enum MisdeedOutcome { removed, warned }

class MisdeedResult {
  const MisdeedResult(this.outcome, this.eventId);

  final MisdeedOutcome outcome;
  final int eventId;
}

/// 스티커 장부. 행을 지우거나 고치지 않고, 받기·빼기·되돌리기를 새 행으로 쌓는다.
/// 이 클래스는 PIN을 확인하지 않는다. 호출하는 화면이 먼저 PIN을 확인해야 한다.
class StickerRepository {
  StickerRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  Future<LedgerView> view(int childId) async {
    return StickerLedger.replay(await _ledger(childId));
  }

  Stream<LedgerView> watchView(int childId) {
    return _eventsOf(childId)
        .watch()
        .map((rows) => StickerLedger.replay(rows.map(_toLedgerEvent).toList()));
  }

  /// 받기. 방금 쓴 기록 id를 돌려준다 (되돌리기에 쓴다).
  Future<int> earn({
    required int childId,
    required int categoryId,
    int amount = 1,
    String? memo,
    String? nextPromise,
  }) {
    return _db.transaction(() async {
      final balance = (await view(childId)).balance;
      StickerRules.checkEarn(balance: balance, amount: amount);
      return _insert(
        childId: childId,
        type: 'earn',
        amount: amount,
        categoryId: categoryId,
        memo: memo,
        nextPromise: nextPromise,
      );
    });
  }

  /// 잘못한 일 기록. 옐로카드 설정이 켜져 있고 이번 주에 같은 잘못이 처음이면 경고만 남긴다.
  /// [warnOnly]가 true면 설정과 상관없이 경고만 남긴다 ('경고만' 버튼).
  Future<MisdeedResult> recordMisdeed({
    required int childId,
    required int categoryId,
    int amount = 1,
    required String memo,
    String? nextPromise,
    bool warnOnly = false,
    bool yellowCardOn = false,
  }) {
    return _db.transaction(() async {
      if (memo.trim().isEmpty) {
        throw const StickerRuleException('무엇을 잘못했는지 적어 주세요.');
      }
      final now = _clock();
      final events = await _ledger(childId);

      final firstThisWeek = !_hasOffenceThisWeek(events, categoryId, now);
      if (warnOnly || (yellowCardOn && firstThisWeek)) {
        final id = await _insert(
          childId: childId,
          type: 'warn',
          amount: 0,
          categoryId: categoryId,
          memo: memo,
          nextPromise: nextPromise,
        );
        return MisdeedResult(MisdeedOutcome.warned, id);
      }

      final balance = StickerLedger.replay(events).balance;
      StickerRules.checkRemove(balance: balance, amount: amount, memo: memo);
      final id = await _insert(
        childId: childId,
        type: 'remove',
        amount: -amount,
        categoryId: categoryId,
        memo: memo,
        nextPromise: nextPromise,
      );
      return MisdeedResult(MisdeedOutcome.removed, id);
    });
  }

  /// 가장 최근 받기·빼기를 되돌린다. 기록 후 [undoSeconds] 안에만 된다.
  /// 되돌리기도 새 행으로 남는다.
  Future<void> undoLast({required int childId, required int undoSeconds}) {
    return _db.transaction(() async {
      final events = await _ledger(childId);
      final targetId = StickerLedger.replay(events).lastUndoableId;
      if (targetId == null) {
        throw const StickerRuleException('되돌릴 기록이 없어요.');
      }
      final target = events.firstWhere((event) => event.id == targetId);

      final age = _clock().difference(target.createdAt);
      if (age > Duration(seconds: undoSeconds)) {
        throw const StickerRuleException('되돌리기 시간이 지났어요.');
      }

      await _insert(
        childId: childId,
        type: 'undo',
        amount: -target.amount,
        categoryId: target.categoryId,
        relatedEventId: target.id,
      );
    });
  }

  SimpleSelectStatement<$StickerEventsTable, StickerEvent> _eventsOf(
    int childId,
  ) {
    return _db.select(_db.stickerEvents)
      ..where((t) => t.childId.equals(childId))
      ..orderBy([(t) => OrderingTerm.asc(t.id)]);
  }

  Future<List<LedgerEvent>> _ledger(int childId) async {
    final rows = await _eventsOf(childId).get();
    return rows.map(_toLedgerEvent).toList();
  }

  Future<int> _insert({
    required int childId,
    required String type,
    required int amount,
    int? categoryId,
    String? memo,
    String? nextPromise,
    int? relatedEventId,
  }) {
    final now = _clock();
    return _db
        .into(_db.stickerEvents)
        .insert(
          StickerEventsCompanion.insert(
            childId: childId,
            eventType: type,
            amount: amount,
            categoryId: Value(categoryId),
            memo: Value(memo),
            nextPromise: Value(nextPromise),
            relatedEventId: Value(relatedEventId),
            createdAt: Value(now),
            localDate: localDateKey(now),
          ),
        );
  }

  /// 이번 주(월요일부터)에 이 잘못으로 경고나 빼기가 있었는지. 되돌린 기록은 세지 않는다.
  static bool _hasOffenceThisWeek(
    List<LedgerEvent> events,
    int categoryId,
    DateTime now,
  ) {
    final undone = {
      for (final event in events)
        if (event.type == 'undo' && event.relatedEventId != null)
          event.relatedEventId!,
    };
    final weekStart = weekStartKey(now);
    return events.any(
      (event) =>
          (event.type == 'warn' || event.type == 'remove') &&
          event.categoryId == categoryId &&
          !undone.contains(event.id) &&
          localDateKey(event.createdAt).compareTo(weekStart) >= 0,
    );
  }

  static LedgerEvent _toLedgerEvent(StickerEvent row) {
    return LedgerEvent(
      id: row.id,
      type: row.eventType,
      amount: row.amount,
      createdAt: row.createdAt,
      categoryId: row.categoryId,
      relatedEventId: row.relatedEventId,
    );
  }
}
