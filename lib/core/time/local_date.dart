/// 기기 시간대 기준 날짜 문자열 'YYYY-MM-DD'. 달력과 하루 단위 기록에 쓴다.
String localDateKey(DateTime time) {
  final local = time.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}

/// 그 주 월요일의 날짜 문자열 'YYYY-MM-DD'. 옐로카드는 주 단위로 센다.
String weekStartKey(DateTime time) {
  final local = time.toLocal();
  final monday = DateTime(
    local.year,
    local.month,
    local.day,
  ).subtract(Duration(days: local.weekday - DateTime.monday));
  return localDateKey(monday);
}
