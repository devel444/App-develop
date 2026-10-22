import 'package:drift/drift.dart';
import 'package:sticker_world/data/db/app_database.dart';

class ChildRepository {
  ChildRepository(this._db);

  final AppDatabase _db;

  /// 지금은 아이 한 명만 쓴다. 여러 명이 되면 이 함수만 바꾸면 된다.
  Future<ChildrenData?> current() {
    return (_db.select(_db.children)..limit(1)).getSingleOrNull();
  }

  Stream<ChildrenData?> watchCurrent() {
    return (_db.select(_db.children)..limit(1)).watchSingleOrNull();
  }

  Future<int> create({required String name}) {
    return _db.into(_db.children).insert(ChildrenCompanion.insert(name: name));
  }

  Future<void> rename({required int childId, required String name}) {
    return (_db.update(_db.children)..where((t) => t.id.equals(childId))).write(
      ChildrenCompanion(name: Value(name.trim())),
    );
  }

  /// 듀오링고 아이디와 앱 패키지를 저장한다. 비밀번호는 저장하지 않는다.
  Future<void> updateDuolingo({
    required int childId,
    required String? username,
    required String packageName,
  }) {
    return (_db.update(_db.children)..where((t) => t.id.equals(childId))).write(
      ChildrenCompanion(
        duolingoUsername: Value(
          username?.trim().isEmpty ?? true ? null : username!.trim(),
        ),
        duolingoPackage: Value(packageName.trim()),
      ),
    );
  }
}
