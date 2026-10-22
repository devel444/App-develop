import 'package:sticker_world/domain/growth_report.dart';

/// 하루치 요약. 달력 칸에 찍는다.
class DayRecord {
  const DayRecord({
    this.earned = 0,
    this.removed = 0,
    this.warned = 0,
    this.cleared = false,
    this.diary = false,
  });

  /// 받은 스티커 (받기 + 보너스).
  final int earned;

  /// 뺀 스티커.
  final int removed;

  /// 경고만 남긴 횟수.
  final int warned;

  /// 올클리어 깃발.
  final bool cleared;

  /// 일기를 썼는지.
  final bool diary;
}

/// 달력 집계. 되돌린 기록은 세지 않는다.
abstract final class GrowthCalendar {
  /// 한 달치 날짜별 요약. 키는 'YYYY-MM-DD'이고, 기록이 있는 날만 들어 있다.
  static Map<String, DayRecord> month({
    required List<GrowthEvent> events,
    required Set<String> clearDates,
    required Set<String> diaryDates,
    required int year,
    required int month,
  }) {
    final prefix = '$year-${month.toString().padLeft(2, '0')}-';
    final earned = <String, int>{};
    final removed = <String, int>{};
    final warned = <String, int>{};

    for (final event in liveEventsOf(events)) {
      if (!event.localDate.startsWith(prefix)) {
        continue;
      }
      final day = event.localDate;
      switch (event.type) {
        case 'earn':
        case 'bonus':
          earned.update(
            day,
            (n) => n + event.amount,
            ifAbsent: () => event.amount,
          );
        case 'remove':
          removed.update(
            day,
            (n) => n - event.amount,
            ifAbsent: () => -event.amount,
          );
        case 'warn':
          warned.update(day, (n) => n + 1, ifAbsent: () => 1);
      }
    }

    final days = {
      ...earned.keys,
      ...removed.keys,
      ...warned.keys,
      ...clearDates.where((d) => d.startsWith(prefix)),
      ...diaryDates.where((d) => d.startsWith(prefix)),
    };
    return {
      for (final day in days)
        day: DayRecord(
          earned: earned[day] ?? 0,
          removed: removed[day] ?? 0,
          warned: warned[day] ?? 0,
          cleared: clearDates.contains(day),
          diary: diaryDates.contains(day),
        ),
    };
  }
}
