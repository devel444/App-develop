import 'package:drift/drift.dart';
import 'package:sticker_world/data/db/app_database.dart';

/// 카테고리와 칭찬 문구를 읽는다.
class CatalogRepository {
  CatalogRepository(this._db);

  final AppDatabase _db;

  /// kind는 'praise'(칭찬) 또는 'misdeed'(잘못).
  Future<List<Category>> categories(String kind) {
    return (_db.select(_db.categories)
          ..where((t) => t.kind.equals(kind) & t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  Future<List<String>> praiseTexts() async {
    final rows = await (_db.select(
      _db.praiseTemplates,
    )..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get();
    return rows.map((row) => row.content).toList();
  }
}
