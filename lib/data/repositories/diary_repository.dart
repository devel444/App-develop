import 'package:drift/drift.dart';
import 'package:sticker_world/data/db/app_database.dart';

/// 일기. 하루에 한 편 (localDate가 유일). 아이가 쓰고, 엄마·아빠가 답장을 단다.
class DiaryRepository {
  DiaryRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  Stream<DiaryEntry?> watchOn(String localDate) {
    return (_db.select(
      _db.diaryEntries,
    )..where((t) => t.localDate.equals(localDate))).watchSingleOrNull();
  }

  /// 최신 날짜가 위로 오도록.
  Stream<List<DiaryEntry>> watchAll(int childId) {
    return (_db.select(_db.diaryEntries)
          ..where((t) => t.childId.equals(childId))
          ..orderBy([(t) => OrderingTerm.desc(t.localDate)]))
        .watch();
  }

  /// 저장(같은 날이면 고친다). 답장은 그대로 둔다.
  /// 제목과 내용이 모두 비어 있으면 저장하지 않는다.
  Future<void> save({
    required int childId,
    required String localDate,
    required String? weather,
    required int? mood,
    required String title,
    required String body,
  }) {
    if (title.trim().isEmpty && body.trim().isEmpty) {
      throw ArgumentError('제목이나 내용 중 하나는 적어 주세요.');
    }
    final now = _clock();
    return _db.transaction(() async {
      final existing = await (_db.select(
        _db.diaryEntries,
      )..where((t) => t.localDate.equals(localDate))).getSingleOrNull();
      if (existing == null) {
        await _db
            .into(_db.diaryEntries)
            .insert(
              DiaryEntriesCompanion.insert(
                childId: childId,
                localDate: localDate,
                weather: Value(weather),
                mood: Value(mood),
                title: Value(title.trim()),
                body: Value(body.trim()),
                createdAt: Value(now),
                updatedAt: Value(now),
              ),
            );
      } else {
        await (_db.update(
          _db.diaryEntries,
        )..where((t) => t.id.equals(existing.id))).write(
          DiaryEntriesCompanion(
            weather: Value(weather),
            mood: Value(mood),
            title: Value(title.trim()),
            body: Value(body.trim()),
            updatedAt: Value(now),
          ),
        );
      }
    });
  }

  /// 엄마·아빠의 답장. 빈 글이면 답장을 지운다.
  Future<void> reply(int entryId, String text) {
    final trimmed = text.trim();
    return (_db.update(
      _db.diaryEntries,
    )..where((t) => t.id.equals(entryId))).write(
      DiaryEntriesCompanion(
        parentReply: Value(trimmed.isEmpty ? null : trimmed),
        parentRepliedAt: Value(trimmed.isEmpty ? null : _clock()),
      ),
    );
  }
}
