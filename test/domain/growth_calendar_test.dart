import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/domain/growth_calendar.dart';
import 'package:sticker_world/domain/growth_report.dart';

GrowthEvent _event(
  int id,
  String type,
  int amount,
  String date, {
  int? related,
}) {
  return GrowthEvent(
    id: id,
    type: type,
    amount: amount,
    localDate: date,
    createdAt: DateTime.parse('${date}T09:00:00'),
    relatedEventId: related,
  );
}

void main() {
  final events = [
    _event(1, 'earn', 1, '2026-10-03'),
    _event(2, 'earn', 1, '2026-10-03'),
    _event(3, 'remove', -1, '2026-10-03'),
    _event(4, 'warn', 0, '2026-10-05'),
    _event(5, 'earn', 1, '2026-10-07'),
    _event(6, 'undo', -1, '2026-10-07', related: 5),
    _event(7, 'bonus', 1, '2026-10-22'),
    _event(8, 'earn', 1, '2026-09-30'),
    _event(9, 'remove', -1, '2026-11-01'),
  ];

  final month = GrowthCalendar.month(
    events: events,
    clearDates: const {'2026-10-03', '2026-10-30', '2026-09-03'},
    diaryDates: const {'2026-10-05', '2026-10-31'},
    year: 2026,
    month: 10,
  );

  test('날짜마다 받은 수, 뺀 수, 경고를 센다', () {
    final day = month['2026-10-03']!;

    expect(day.earned, 2);
    expect(day.removed, 1);
    expect(day.warned, 0);
    expect(day.cleared, isTrue);
    expect(day.diary, isFalse);
  });

  test('경고와 일기 점은 따로 찍힌다', () {
    final day = month['2026-10-05']!;

    expect(day.earned, 0);
    expect(day.warned, 1);
    expect(day.diary, isTrue);
  });

  test('되돌린 받기는 그날 칸에서 빠진다', () {
    expect(month.containsKey('2026-10-07'), isFalse);
  });

  test('보너스는 받은 수에 들어가고, 올클리어만 있는 날도 칸이 생긴다', () {
    expect(month['2026-10-22']!.earned, 1);

    final clearOnly = month['2026-10-30']!;
    expect(clearOnly.cleared, isTrue);
    expect(clearOnly.earned, 0);
  });

  test('다른 달 기록은 이 달 칸에 들어오지 않는다', () {
    expect(month.containsKey('2026-09-30'), isFalse);
    expect(month.containsKey('2026-11-01'), isFalse);
    expect(month.containsKey('2026-09-03'), isFalse);
    expect(month.containsKey('2026-10-31'), isTrue);
  });
}
