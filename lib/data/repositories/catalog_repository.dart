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

  /// 부모 설정용: 꺼 둔 카테고리까지 모두 (정렬 순서대로).
  Stream<List<Category>> watchAllCategories(String kind) {
    return (_db.select(_db.categories)
          ..where((t) => t.kind.equals(kind))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  /// 새 카테고리. 맨 뒤에 붙는다.
  Future<int> addCategory({
    required String kind,
    required String name,
    required int colorValue,
  }) async {
    final last =
        await (_db.select(_db.categories)
              ..where((t) => t.kind.equals(kind))
              ..orderBy([(t) => OrderingTerm.desc(t.sortOrder)])
              ..limit(1))
            .getSingleOrNull();
    return _db
        .into(_db.categories)
        .insert(
          CategoriesCompanion.insert(
            kind: kind,
            name: name.trim(),
            iconKey: 'star',
            colorValue: colorValue,
            sortOrder: Value((last?.sortOrder ?? 0) + 1),
          ),
        );
  }

  Future<void> renameCategory(int id, String name) {
    return (_db.update(_db.categories)..where((t) => t.id.equals(id))).write(
      CategoriesCompanion(name: Value(name.trim())),
    );
  }

  /// 끄면 스티커 화면에서 안 보이고, 기록은 그대로 남는다.
  Future<void> setCategoryActive(int id, {required bool active}) {
    return (_db.update(_db.categories)..where((t) => t.id.equals(id))).write(
      CategoriesCompanion(isActive: Value(active)),
    );
  }
}
