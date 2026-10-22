import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/domain/badge_rules.dart';
import 'package:sticker_world/domain/growth_report.dart';

GrowthEvent _event(
  int id,
  String type,
  int amount,
  String date, {
  int? categoryId,
  int? related,
}) {
  return GrowthEvent(
    id: id,
    type: type,
    amount: amount,
    localDate: date,
    createdAt: DateTime.parse('${date}T09:00:00'),
    categoryId: categoryId,
    relatedEventId: related,
  );
}

const _names = {1: '공부', 2: '착한 일', 11: '게임 시간 약속'};

BadgeStats _stats({
  List<GrowthEvent> events = const [],
  Set<String> clears = const {},
  int diary = 0,
  int? duo,
  DateTime? createdAt,
}) {
  return BadgeStats.from(
    events: events,
    clearDates: clears,
    diaryCount: diary,
    duoStreak: duo,
    createdAt: createdAt,
    categoryNames: _names,
    now: DateTime(2026, 10, 22, 12),
  );
}

void main() {
  group('배지 조건 읽기', () {
    test('숫자 조건은 이름과 목표로 나뉜다', () {
      final rule = BadgeRule.tryParse('{"rule": "study>=10"}');

      expect(rule?.metric, 'study');
      expect(rule?.target, 10);
    });

    test('지난달 빼기 0번은 예/아니오 조건이다', () {
      final rule = BadgeRule.tryParse('{"rule": "month_remove_zero"}');

      expect(rule?.metric, BadgeRule.monthRemoveZero);
      expect(rule?.target, 1);
    });

    test('읽을 수 없는 조건은 null이라 판정하지 않는다', () {
      expect(BadgeRule.tryParse('{"rule": "unknown"}'), isNull);
      expect(BadgeRule.tryParse('{"other": 1}'), isNull);
      expect(BadgeRule.tryParse('not json'), isNull);
    });
  });

  test('되돌린 받기는 세지 않고, 공부·착한 일 칭찬은 이름으로 센다', () {
    final events = [
      _event(1, 'earn', 1, '2026-10-03', categoryId: 1),
      _event(2, 'earn', 1, '2026-10-04', categoryId: 1),
      _event(3, 'earn', 1, '2026-10-05', categoryId: 2),
      _event(4, 'undo', -1, '2026-10-05', related: 3),
    ];

    final stats = _stats(events: events);

    expect(stats.value('study'), 2);
    expect(stats.value('kind'), 0);
    expect(stats.totalEarned, 2);
    expect(stats.balance, 2);
  });

  test('오늘 받은 스티커, 선물 교환, 올클리어 연속 일수', () {
    final events = [
      for (var i = 1; i <= 5; i++)
        _event(i, 'earn', 1, '2026-10-22', categoryId: 1),
      _event(6, 'redeem', -5, '2026-10-20'),
    ];

    final stats = _stats(
      events: events,
      clears: const {'2026-10-20', '2026-10-21', '2026-10-22'},
    );

    expect(stats.value('today_earn'), 5);
    expect(stats.value('redeemed'), 1);
    expect(stats.value('redeemed_cost'), 5);
    expect(stats.value('clear_days'), 3);
    expect(stats.value('clear_streak'), 3);
  });

  test('듀오링고 연속과 일기 수는 그대로 넘어온다', () {
    final stats = _stats(duo: 8, diary: 2);

    expect(stats.value('duo_streak'), 8);
    expect(stats.value('diary'), 2);
    expect(_stats().value('duo_streak'), 0);
  });

  test('지난달 내내 있었고 지난달에 받은 게 있는데 빼기는 0번이면 약속 지킴이', () {
    final kept = _stats(
      createdAt: DateTime(2026, 8, 1),
      events: [_event(1, 'earn', 1, '2026-09-15', categoryId: 1)],
    );
    final removed = _stats(
      createdAt: DateTime(2026, 8, 1),
      events: [
        _event(1, 'earn', 1, '2026-09-15', categoryId: 1),
        _event(2, 'remove', -1, '2026-09-20', categoryId: 11),
      ],
    );
    final newChild = _stats(
      createdAt: DateTime(2026, 9, 20),
      events: [_event(1, 'earn', 1, '2026-09-21', categoryId: 1)],
    );

    expect(kept.monthRemoveZero, isTrue);
    expect(removed.monthRemoveZero, isFalse);
    expect(newChild.monthRemoveZero, isFalse);
  });

  test('진행도 힌트는 목표를 넘지 않고 아이 눈높이 말로 보여 준다', () {
    final stats = _stats(
      events: [
        for (var i = 1; i <= 12; i++)
          _event(i, 'earn', 1, '2026-10-03', categoryId: 1),
      ],
    );

    expect(const BadgeRule('study', 10).hint(stats), '공부 칭찬 10 / 10');
    expect(const BadgeRule('study', 30).hint(stats), '공부 칭찬 12 / 30');
    expect(
      const BadgeRule('month_remove_zero', 1).hint(stats),
      '지난달 빼기 0번이면 받아요',
    );
  });
}
