import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/repositories/catalog_repository.dart';
import 'package:sticker_world/data/repositories/child_repository.dart';

import '../support/test_database.dart';

void main() {
  late AppDatabase db;
  late CatalogRepository catalog;

  setUp(() {
    db = createTestDatabase();
    catalog = CatalogRepository(db);
  });

  tearDown(() => db.close());

  test('새 칭찬 카테고리는 맨 뒤에 붙고, 이름 앞뒤 공백은 빠진다', () async {
    final before = await catalog.categories('praise');

    await catalog.addCategory(
      kind: 'praise',
      name: '  그림 그리기  ',
      colorValue: 0xFF000000,
    );

    final after = await catalog.categories('praise');
    expect(after, hasLength(before.length + 1));
    expect(after.last.name, '그림 그리기');
    expect(after.last.kind, 'praise');
  });

  test('카테고리를 끄면 스티커 목록에서 빠지고, 관리 목록에는 남는다', () async {
    final praise = await catalog.categories('praise');
    final target = praise.first;

    await catalog.setCategoryActive(target.id, active: false);

    expect(
      (await catalog.categories('praise')).map((c) => c.id),
      isNot(contains(target.id)),
    );
    final all = await catalog.watchAllCategories('praise').first;
    final kept = all.firstWhere((c) => c.id == target.id);
    expect(kept.isActive, isFalse);
  });

  test('이름을 바꿔도 같은 카테고리 번호를 유지한다', () async {
    final target = (await catalog.categories('misdeed')).first;

    await catalog.renameCategory(target.id, '게임 시간 약속 (저녁)');

    final renamed = (await catalog.categories('misdeed'))
        .firstWhere((c) => c.id == target.id);
    expect(renamed.name, '게임 시간 약속 (저녁)');
  });

  test('아이 이름을 바꾸면 공백을 정리해서 저장한다', () async {
    final childId = await ChildRepository(db).create(name: '지우');

    await ChildRepository(db).rename(childId: childId, name: ' 지우야 ');

    final child = await ChildRepository(db).current();
    expect(child?.name, '지우야');
  });
}
