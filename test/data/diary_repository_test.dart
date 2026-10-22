import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/repositories/child_repository.dart';
import 'package:sticker_world/data/repositories/diary_repository.dart';
import 'package:sticker_world/data/repositories/routine_repository.dart';
import 'package:sticker_world/data/repositories/settings_repository.dart';
import 'package:sticker_world/data/repositories/sticker_repository.dart';
import 'package:sticker_world/domain/routine_rules.dart';

import '../support/test_database.dart';

void main() {
  // 2026-10-22 목요일
  late AppDatabase db;
  late FakeClock clock;
  late DiaryRepository diary;
  late RoutineRepository routines;
  late int childId;
  const today = '2026-10-22';

  setUp(() async {
    db = createTestDatabase();
    clock = FakeClock();
    childId = await ChildRepository(db).create(name: '지우');
    final stickers = StickerRepository(db, clock: clock.call);
    diary = DiaryRepository(db, clock: clock.call);
    routines = RoutineRepository(
      db,
      stickers: stickers,
      settings: SettingsRepository(db),
      clock: clock.call,
    );
  });

  tearDown(() => db.close());

  Future<void> writeToday({String title = '오늘', String body = '재미있었다'}) {
    return diary.save(
      childId: childId,
      localDate: today,
      weather: 'sunny',
      mood: 5,
      title: title,
      body: body,
    );
  }

  test('같은 날 두 번 저장하면 한 편으로 고쳐진다', () async {
    await writeToday(title: '처음');
    await writeToday(title: '고친 제목', body: '고친 내용');

    final rows = await db.select(db.diaryEntries).get();
    expect(rows, hasLength(1));
    final entry = await diary.watchOn(today).first;
    expect(entry?.title, '고친 제목');
    expect(entry?.body, '고친 내용');
  });

  test('제목과 내용이 모두 비어 있으면 저장하지 않는다', () async {
    expect(
      () => writeToday(title: '  ', body: ''),
      throwsA(isA<ArgumentError>()),
    );

    expect(await db.select(db.diaryEntries).get(), isEmpty);
  });

  test('내용만 있어도 저장된다', () async {
    await writeToday(title: '', body: '그림을 그렸다');

    final entry = await diary.watchOn(today).first;
    expect(entry?.body, '그림을 그렸다');
  });

  test('다시 쓸 때 엄마·아빠 답장은 그대로 남는다', () async {
    await writeToday();
    final entry = (await diary.watchOn(today).first)!;
    await diary.reply(entry.id, '잘 썼네!');

    await writeToday(body: '조금 고쳤다');

    final after = (await diary.watchOn(today).first)!;
    expect(after.parentReply, '잘 썼네!');
    expect(after.body, '조금 고쳤다');
  });

  test('답장을 보내면 남고, 빈 글로 보내면 지워진다', () async {
    await writeToday();
    final entry = (await diary.watchOn(today).first)!;

    await diary.reply(entry.id, '  사랑해  ');
    expect((await diary.watchOn(today).first)?.parentReply, '사랑해');

    await diary.reply(entry.id, '   ');
    expect((await diary.watchOn(today).first)?.parentReply, isNull);
  });

  test('watchAll은 최신 날짜가 위로 오고 다른 아이 기록은 빠진다', () async {
    final otherId = await ChildRepository(db).create(name: '동생');
    await diary.save(
      childId: childId,
      localDate: '2026-10-20',
      weather: null,
      mood: null,
      title: '어제 전',
      body: '',
    );
    await writeToday();
    await diary.save(
      childId: otherId,
      localDate: today,
      weather: null,
      mood: null,
      title: '동생 일기',
      body: '',
    );

    final mine = await diary.watchAll(childId).first;
    expect(mine.map((e) => e.localDate), [today, '2026-10-20']);
  });

  test('일기 쓰기 루틴이 있으면 저장 뒤 자동으로 체크된다', () async {
    await routines.create(
      childId: childId,
      title: '일기 쓰기',
      iconKey: 'star',
      kind: 'diary',
      timeSlot: 'evening',
      daysMask: RoutineDays.all,
    );
    await writeToday();

    final result = await routines.completeFirstDue(
      childId: childId,
      kind: 'diary',
      source: 'auto',
    );

    expect(result?.alreadyDone, isFalse);
    expect(result?.cleared, isTrue);
    expect(await db.select(db.routineLogs).get(), hasLength(1));
  });

  test('일기 쓰기 루틴이 없으면 자동 체크는 아무 것도 하지 않는다', () async {
    await writeToday();

    final result = await routines.completeFirstDue(
      childId: childId,
      kind: 'diary',
      source: 'auto',
    );

    expect(result, isNull);
    expect(await db.select(db.routineLogs).get(), isEmpty);
  });
}
