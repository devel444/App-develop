import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/repositories/child_repository.dart';
import 'package:sticker_world/data/repositories/routine_repository.dart';
import 'package:sticker_world/data/repositories/settings_repository.dart';
import 'package:sticker_world/data/repositories/sticker_repository.dart';
import 'package:sticker_world/domain/routine_rules.dart';

import '../support/test_database.dart';

void main() {
  // 2026-10-22 목요일
  late AppDatabase db;
  late FakeClock clock;
  late StickerRepository stickers;
  late SettingsRepository settings;
  late RoutineRepository routines;
  late int childId;

  setUp(() async {
    db = createTestDatabase();
    clock = FakeClock();
    childId = await ChildRepository(db).create(name: '지우');
    settings = SettingsRepository(db);
    stickers = StickerRepository(db, clock: clock.call);
    routines = RoutineRepository(
      db,
      stickers: stickers,
      settings: settings,
      clock: clock.call,
    );
  });

  tearDown(() => db.close());

  Future<int> addRoutine(
    String title, {
    int daysMask = RoutineDays.all,
    String slot = 'morning',
    String kind = 'normal',
  }) {
    return routines.create(
      childId: childId,
      title: title,
      iconKey: 'star',
      kind: kind,
      timeSlot: slot,
      daysMask: daysMask,
    );
  }

  test('체크하면 기록이 남고, 같은 날 다시 눌러도 한 번만 남는다', () async {
    final brush = await addRoutine('양치하기');
    await addRoutine('이불 정리');

    final first = await routines.complete(routineId: brush, source: 'child');
    final again = await routines.complete(routineId: brush, source: 'child');

    expect(first.alreadyDone, isFalse);
    expect(again.alreadyDone, isTrue);
    expect(await db.select(db.routineLogs).get(), hasLength(1));
  });

  test('오늘 할 일을 모두 끝내면 올클리어가 되고, 보너스는 엄마·아빠 확인을 기다린다', () async {
    final a = await addRoutine('양치하기');
    final b = await addRoutine('이불 정리');

    await routines.complete(routineId: a, source: 'child');
    final last = await routines.complete(routineId: b, source: 'child');

    expect(last.cleared, isTrue);
    expect(last.bonusPending, isTrue);
    expect((await stickers.view(childId)).balance, 0);
    final pending = await routines.watchPendingBonuses(childId).first;
    expect(pending, hasLength(1));
  });

  test('보너스를 확정하면 스티커 1개가 붙고, 두 번 확정해도 한 번만 붙는다', () async {
    final a = await addRoutine('양치하기');
    await routines.complete(routineId: a, source: 'child');
    final pending = (await routines.watchPendingBonuses(childId).first).single;

    await routines.confirmBonus(pending.id);
    await routines.confirmBonus(pending.id);

    final view = await stickers.view(childId);
    expect(view.balance, 1);
    expect(view.stack, hasLength(1));
    expect((await routines.watchPendingBonuses(childId).first), isEmpty);
  });

  test('보너스 설정이 자동이면 올클리어 때 바로 스티커가 붙는다', () async {
    await settings.set('all_clear_bonus', 'auto');
    final a = await addRoutine('양치하기');

    final result = await routines.complete(routineId: a, source: 'child');

    expect(result.cleared, isTrue);
    expect(result.bonusPending, isFalse);
    expect((await stickers.view(childId)).balance, 1);
  });

  test('오늘 해야 하는 요일이 아닌 루틴은 올클리어에 세지 않는다', () async {
    final monday = await addRoutine('월요일 줄넘기', daysMask: 1);
    final today = await addRoutine('양치하기');

    final result = await routines.complete(routineId: today, source: 'child');

    expect(result.cleared, isTrue);
    expect(monday, isNonNegative);
  });

  test('루틴이 하나도 없으면 올클리어가 되지 않는다', () async {
    final result = await routines.create(
      childId: childId,
      title: '숨김',
      iconKey: 'star',
      kind: 'normal',
      timeSlot: 'morning',
      daysMask: 1,
    );
    expect(result, isPositive);

    final none = await routines.watchClearDates(childId).first;
    expect(none, isEmpty);
  });

  test('체크를 지우면 다시 할 일이 된다', () async {
    final a = await addRoutine('양치하기');
    await routines.complete(routineId: a, source: 'child');

    await routines.uncomplete(a);

    expect(await db.select(db.routineLogs).get(), isEmpty);
  });

  test('루틴 순서를 바꾸면 sortOrder가 새 순서대로 된다', () async {
    final a = await addRoutine('양치하기');
    final b = await addRoutine('이불 정리');

    await routines.reorder([b, a]);

    final all = await routines.watchAll().first;
    expect(all.map((r) => r.title), ['이불 정리', '양치하기']);
  });

  test('기록이 있는 루틴은 지우지 않고 숨긴다', () async {
    final a = await addRoutine('양치하기');
    await routines.complete(routineId: a, source: 'child');

    final deleted = await routines.remove(a);

    expect(deleted, isFalse);
    final row = await (db.select(
      db.routines,
    )..where((t) => t.id.equals(a))).getSingle();
    expect(row.isActive, isFalse);
  });

  test('보너스 설정이 끄기면 올클리어만 기록되고 대기는 없다', () async {
    await settings.set('all_clear_bonus', 'off');
    final a = await addRoutine('양치하기');

    final result = await routines.complete(routineId: a, source: 'child');

    expect(result.cleared, isTrue);
    expect(result.bonusPending, isFalse);
    expect(await routines.watchPendingBonuses(childId).first, isEmpty);
  });
}
