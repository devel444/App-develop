import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/domain/duolingo_rules.dart';

void main() {
  const today = '2026-10-22';

  DuolingoProfile profile({int? xp, String? endDate}) =>
      DuolingoProfile(raw: '{}', totalXp: xp, streakEndDate: endDate);

  test('연속 기록 마지막 날이 오늘이면 완료', () {
    final j = DuolingoRules.judgeWeb(
      profile: profile(endDate: today),
      previousXp: null,
      today: today,
    );
    expect(j.isDone, isTrue);
    expect(j.method, 'web');
  });

  test('어제까지 저장한 XP보다 늘었으면 완료', () {
    final j = DuolingoRules.judgeWeb(
      profile: profile(xp: 1200, endDate: '2026-10-20'),
      previousXp: 1100,
      today: today,
    );
    expect(j.isDone, isTrue);
  });

  test('XP가 그대로이고 기록도 어제면 아직 안 한 것', () {
    final j = DuolingoRules.judgeWeb(
      profile: profile(xp: 1100, endDate: '2026-10-21'),
      previousXp: 1100,
      today: today,
    );
    expect(j.status, DuolingoStatus.notYet);
  });

  test('비교할 이전 XP가 없으면 XP로는 완료라고 하지 않는다', () {
    final j = DuolingoRules.judgeWeb(
      profile: profile(xp: 1100),
      previousXp: null,
      today: today,
    );
    expect(j.isDone, isFalse);
  });

  test('태블릿 사용이 기준 분 이상이면 완료', () {
    final done = DuolingoRules.judgeUsage(minutes: 6, minMinutes: 5);
    final not = DuolingoRules.judgeUsage(minutes: 2, minMinutes: 5);

    expect(done.isDone, isTrue);
    expect(done.method, 'usage');
    expect(not.isDone, isFalse);
  });
}
