import 'package:drift/drift.dart';
import 'package:sticker_world/data/db/app_database.dart';

/// 엄마·아빠 한마디. 기간(주·달·전체)마다 하나씩 둔다.
/// 이 클래스는 PIN을 확인하지 않는다. 호출하는 화면이 먼저 PIN을 확인해야 한다.
class ReportCommentRepository {
  ReportCommentRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  Stream<ReportComment?> watch(
    int childId,
    String periodType,
    String periodKey,
  ) {
    return _select(childId, periodType, periodKey).watchSingleOrNull();
  }

  /// 저장(같은 기간이면 고친다). 빈 글이면 한마디를 지운다.
  Future<void> save({
    required int childId,
    required String periodType,
    required String periodKey,
    required String content,
  }) {
    final text = content.trim();
    return _db.transaction(() async {
      final existing = await _select(
        childId,
        periodType,
        periodKey,
      ).getSingleOrNull();
      if (text.isEmpty) {
        if (existing != null) {
          await (_db.delete(
            _db.reportComments,
          )..where((t) => t.id.equals(existing.id))).go();
        }
        return;
      }
      if (existing == null) {
        await _db
            .into(_db.reportComments)
            .insert(
              ReportCommentsCompanion.insert(
                childId: childId,
                periodType: periodType,
                periodKey: periodKey,
                content: text,
                updatedAt: Value(_clock()),
              ),
            );
      } else {
        await (_db.update(
          _db.reportComments,
        )..where((t) => t.id.equals(existing.id))).write(
          ReportCommentsCompanion(
            content: Value(text),
            updatedAt: Value(_clock()),
          ),
        );
      }
    });
  }

  SimpleSelectStatement<$ReportCommentsTable, ReportComment> _select(
    int childId,
    String periodType,
    String periodKey,
  ) {
    return _db.select(_db.reportComments)..where(
      (t) =>
          t.childId.equals(childId) &
          t.periodType.equals(periodType) &
          t.periodKey.equals(periodKey),
    );
  }
}
