import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/data/db/app_database.dart';

import '../support/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  test('칭찬 카테고리 5개, 잘못 종류 6개가 기본으로 들어간다', () async {
    final categories = await db.select(db.categories).get();

    expect(categories.where((c) => c.kind == 'praise').map((c) => c.name), [
      '공부',
      '생활습관',
      '착한 일',
      '운동',
      '기타',
    ]);
    expect(categories.where((c) => c.kind == 'misdeed').map((c) => c.name), [
      '게임 시간 약속',
      '말다툼·싸움',
      '거짓말',
      '정리 안 함',
      '고운 말 안 씀',
      '기타',
    ]);
  });

  test('칭찬 문구와 배지 목록이 들어간다', () async {
    final templates = await db.select(db.praiseTemplates).get();
    final badges = await db.select(db.badges).get();

    expect(templates, hasLength(6));
    expect(badges.length, greaterThanOrEqualTo(20));
    expect(badges.where((b) => b.isHidden), isNotEmpty);
  });

  test('설정 기본값이 들어간다 (최대 100개, 되돌리기 10초)', () async {
    final settings = {
      for (final row in await db.select(db.appSettings).get())
        row.key: row.value,
    };

    expect(settings['max_stickers'], '100');
    expect(settings['undo_seconds'], '10');
    expect(settings['pin_failed'], '0');
  });
}
