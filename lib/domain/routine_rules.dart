import 'package:sticker_world/core/time/local_date.dart';

/// 요일 규칙 (PLAN.md 6장, days_mask): 월=1, 화=2, … 일=64.
abstract final class RoutineDays {
  static const all = 127;
  static const weekdays = 31; // 월~금
  static const weekend = 96; // 토·일

  static const _names = ['월', '화', '수', '목', '금', '토', '일'];

  /// 그 날짜가 요일 마스크에 들어 있는지.
  static bool includes(int mask, DateTime date) {
    return (mask & bitFor(date)) != 0;
  }

  static int bitFor(DateTime date) => 1 << (date.weekday - 1);

  /// 사람이 읽는 요일 표시. 예: 매일, 평일, 주말, 화·목
  static String label(int mask) {
    if (mask == all) {
      return '매일';
    }
    if (mask == weekdays) {
      return '평일';
    }
    if (mask == weekend) {
      return '주말';
    }
    final picked = [
      for (var i = 0; i < _names.length; i++)
        if (mask & (1 << i) != 0) _names[i],
    ];
    return picked.isEmpty ? '요일 없음' : picked.join('·');
  }

  /// 요일 칩을 눌렀을 때 마스크를 뒤집는다.
  static int toggle(int mask, int dayIndex) => mask ^ (1 << dayIndex);

  static List<String> get dayNames => _names;
}

/// 오늘을 포함해서 며칠 연속으로 올클리어했는지.
/// 오늘을 아직 못 끝냈다면 어제부터 센다 (오늘 끝나면 늘어난다).
int clearStreak(Set<String> clearDates, DateTime today) {
  var day = DateTime(today.year, today.month, today.day);
  if (!clearDates.contains(localDateKey(day))) {
    day = day.subtract(const Duration(days: 1));
  }
  var count = 0;
  while (clearDates.contains(localDateKey(day))) {
    count++;
    day = day.subtract(const Duration(days: 1));
  }
  return count;
}
