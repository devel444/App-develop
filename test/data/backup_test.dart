import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/data/backup/backup_files.dart';
import 'package:sticker_world/data/backup/backup_service.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/repositories/child_repository.dart';
import 'package:sticker_world/data/repositories/diary_repository.dart';
import 'package:sticker_world/data/repositories/reward_repository.dart';
import 'package:sticker_world/data/repositories/routine_repository.dart';
import 'package:sticker_world/data/repositories/settings_repository.dart';
import 'package:sticker_world/data/repositories/sticker_repository.dart';
import 'package:sticker_world/domain/routine_rules.dart';

import '../support/test_database.dart';

void main() {
  late AppDatabase source;
  late FakeClock clock;
  late int childId;
  late StickerRepository stickers;

  setUp(() async {
    source = createTestDatabase();
    clock = FakeClock();
    childId = await ChildRepository(source).create(name: '지우');
    stickers = StickerRepository(source, clock: clock.call);
    final praise = (await source.select(source.categories).get())
        .firstWhere((c) => c.kind == 'praise')
        .id;
    await stickers.earn(childId: childId, categoryId: praise, memo: '받아쓰기');
    await stickers.earn(childId: childId, categoryId: praise);
    await RewardRepository(source).create(name: '아이스크림', cost: 2);
    await RoutineRepository(
      source,
      stickers: stickers,
      settings: SettingsRepository(source),
      clock: clock.call,
    ).create(
      childId: childId,
      title: '양치하기',
      iconKey: 'star',
      kind: 'normal',
      timeSlot: 'morning',
      daysMask: RoutineDays.all,
    );
    await DiaryRepository(source, clock: clock.call).save(
      childId: childId,
      localDate: '2026-10-22',
      weather: 'sunny',
      mood: 5,
      title: '오늘',
      body: '재미있었다',
    );
  });

  tearDown(() => source.close());

  test('내보낸 백업을 빈 기기에 되돌리면 같은 내용이 된다', () async {
    final exported = await BackupService(
      source,
      clock: clock.call,
    ).exportJson();

    final target = createTestDatabase();
    addTearDown(target.close);
    await BackupService(target, clock: clock.call).restoreJson(exported);
    final again = await BackupService(target, clock: clock.call).exportJson();

    expect(_tables(again), _tables(exported));
    expect(await target.select(target.stickerEvents).get(), hasLength(2));
  });

  test('되돌리면 지금 데이터는 백업 내용으로 바뀐다 (기존 기록은 남지 않는다)', () async {
    final exported = await BackupService(
      source,
      clock: clock.call,
    ).exportJson();
    await stickers.earn(
      childId: childId,
      categoryId: (await source.select(source.categories).get()).first.id,
    );

    await BackupService(source, clock: clock.call).restoreJson(exported);

    expect(await source.select(source.stickerEvents).get(), hasLength(2));
  });

  test('백업 파일이 아니면 아무것도 바꾸지 않고 알려 준다', () async {
    final before = await BackupService(source, clock: clock.call).exportJson();

    await expectLater(
      BackupService(source, clock: clock.call).restoreJson('아무 글'),
      throwsA(isA<FormatException>()),
    );
    await expectLater(
      BackupService(
        source,
        clock: clock.call,
      ).restoreJson(jsonEncode({'app': 'other', 'version': 1, 'tables': {}})),
      throwsA(isA<FormatException>()),
    );
    await expectLater(
      BackupService(source, clock: clock.call).restoreJson(
        jsonEncode({'app': 'sticker_world', 'version': 99, 'tables': {}}),
      ),
      throwsA(isA<FormatException>()),
    );

    expect(
      await BackupService(source, clock: clock.call).exportJson().then(_tables),
      _tables(before),
    );
  });

  test('자동 백업은 날짜별로 한 파일이고, 최근 14개만 남는다', () async {
    final dir = Directory.systemTemp.createTempSync('backup_files_test');
    addTearDown(() => dir.deleteSync(recursive: true));
    final files = BackupFiles(dir);

    expect(await files.hasDay('2026-10-01'), isFalse);
    for (var day = 1; day <= 16; day++) {
      final key = '2026-10-${day.toString().padLeft(2, '0')}';
      await files.write(key, '{}');
    }

    final listed = await files.list();
    expect(listed, hasLength(14));
    expect(listed.first.path, endsWith('sticker_world_2026-10-16.json'));
    expect(await files.hasDay('2026-10-16'), isTrue);
    expect(await files.hasDay('2026-10-01'), isFalse);
  });
}

/// 백업에서 표 내용만 골라 비교한다 (내보낸 시각은 다르니 뺀다).
String _tables(String json) => jsonEncode(jsonDecode(json)['tables']);
