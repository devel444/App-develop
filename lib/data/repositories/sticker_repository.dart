import 'package:drift/drift.dart';
import 'package:sticker_world/core/time/local_date.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/domain/sticker_rules.dart';

/// 지금 잔액과 누적 받은 개수. 화면 상단·홈에 보여 준다.
class StickerSummary {
  const StickerSummary({required this.balance, required this.totalEarned});

  static const empty = StickerSummary(balance: 0, totalEarned: 0);

  final int balance;
  final int totalEarned;
}

/// 스티커 장부. 행을 지우거나 고치지 않고, 붙이기·빼기를 새 행으로 쌓는다.
/// 이 클래스는 PIN을 확인하지 않는다. 호출하는 화면이 먼저 PIN을 확인해야 한다.
class StickerRepository {
  StickerRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  Future<int> balance(int childId) async {
    return _sumAmount(await _eventsOf(childId).get());
  }

  Future<StickerSummary> summary(int childId) async {
    return _summarize(await _eventsOf(childId).get());
  }

  Stream<StickerSummary> watchSummary(int childId) {
    return _eventsOf(childId).watch().map(_summarize);
  }

  Future<void> earn({
    required int childId,
    required int categoryId,
    int amount = 1,
    String? memo,
    String? nextPromise,
  }) {
    return _db.transaction(() async {
      StickerRules.checkEarn(balance: await balance(childId), amount: amount);
      await _insert(
        childId: childId,
        type: 'earn',
        amount: amount,
        categoryId: categoryId,
        memo: memo,
        nextPromise: nextPromise,
      );
    });
  }

  Future<void> remove({
    required int childId,
    required int categoryId,
    int amount = 1,
    required String memo,
    String? nextPromise,
  }) {
    return _db.transaction(() async {
      StickerRules.checkRemove(
        balance: await balance(childId),
        amount: amount,
        memo: memo,
      );
      await _insert(
        childId: childId,
        type: 'remove',
        amount: -amount,
        categoryId: categoryId,
        memo: memo,
        nextPromise: nextPromise,
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

  Future<void> _insert({
    required int childId,
    required String type,
    required int amount,
    int? categoryId,
    String? memo,
    String? nextPromise,
  }) async {
    final now = _clock();
    await _db
        .into(_db.stickerEvents)
        .insert(
          StickerEventsCompanion.insert(
            childId: childId,
            eventType: type,
            amount: amount,
            categoryId: Value(categoryId),
            memo: Value(memo),
            nextPromise: Value(nextPromise),
            createdAt: Value(now),
            localDate: localDateKey(now),
          ),
        );
  }

  static int _sumAmount(List<StickerEvent> events) {
    return events.fold(0, (sum, event) => sum + event.amount);
  }

  static StickerSummary _summarize(List<StickerEvent> events) {
    final earned = events
        .where((event) => event.amount > 0)
        .fold(0, (sum, event) => sum + event.amount);
    return StickerSummary(balance: _sumAmount(events), totalEarned: earned);
  }
}
