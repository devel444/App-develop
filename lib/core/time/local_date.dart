/// 기기 시간대 기준 날짜 문자열 'YYYY-MM-DD'. 달력과 하루 단위 기록에 쓴다.
String localDateKey(DateTime time) {
  final local = time.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}
