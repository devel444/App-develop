import 'package:sticker_world/core/time/local_date.dart';

/// 일요일 저녁(18시 이후)이 되면 이번 주 리포트 안내를 한 번 띄운다.
/// [seenWeekKey]는 마지막으로 안내를 닫은 주의 월요일 날짜('YYYY-MM-DD')다.
bool shouldShowWeeklyReport({
  required DateTime now,
  required String? seenWeekKey,
}) {
  final isSundayEvening = now.weekday == DateTime.sunday && now.hour >= 18;
  return isSundayEvening && seenWeekKey != weekStartKey(now);
}
