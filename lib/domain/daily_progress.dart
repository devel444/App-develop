import 'package:sticker_world/domain/routine_rules.dart';

/// 오늘 할 일 진행률. 오늘 해야 하는 루틴 중 몇 개를 끝냈는지 센다.
class DailyProgress {
  const DailyProgress({required this.done, required this.total});

  final int done;
  final int total;

  int get left => total - done;

  bool get finished => total > 0 && done == total;

  /// 0.0 ~ 1.0 (할 일이 없으면 0).
  double get fraction => total == 0 ? 0 : done / total;

  /// [routines]는 (id, 요일 비트, 켜짐 여부). [loggedIds]는 오늘 체크한 루틴 id.
  static DailyProgress count({
    required Iterable<({int id, int daysMask, bool isActive})> routines,
    required Set<int> loggedIds,
    required DateTime now,
  }) {
    final due = [
      for (final routine in routines)
        if (routine.isActive && RoutineDays.includes(routine.daysMask, now))
          routine.id,
    ];
    final done = due.where(loggedIds.contains).length;
    return DailyProgress(done: done, total: due.length);
  }
}
