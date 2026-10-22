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
}
