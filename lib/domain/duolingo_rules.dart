/// 듀오링고 프로필에서 읽은 값 (필요한 것만).
class DuolingoProfile {
  const DuolingoProfile({
    required this.raw,
    this.totalXp,
    this.streak,
    this.streakEndDate,
  });

  /// 응답 원문. 디버그 화면에서 보여 준다.
  final String raw;
  final int? totalXp;
  final int? streak;

  /// 마지막으로 연속 기록에 올라간 날 'YYYY-MM-DD'.
  final String? streakEndDate;
}

enum DuolingoStatus { done, notYet, unknown }

class DuolingoJudgement {
  const DuolingoJudgement({
    required this.status,
    required this.method,
    required this.reason,
  });

  final DuolingoStatus status;

  /// web | usage | manual
  final String method;

  /// 사람이 읽는 이유 (화면에 보여 준다).
  final String reason;

  bool get isDone => status == DuolingoStatus.done;
}

/// 듀오링고 완료 판정 (PLAN.md 3장).
abstract final class DuolingoRules {
  /// 방법 A: 웹 프로필.
  /// - 연속 기록 마지막 날이 오늘이면 완료.
  /// - 어제까지 저장해 둔 XP보다 지금 XP가 늘었으면 완료.
  static DuolingoJudgement judgeWeb({
    required DuolingoProfile profile,
    required int? previousXp,
    required String today,
  }) {
    if (profile.streakEndDate == today) {
      return const DuolingoJudgement(
        status: DuolingoStatus.done,
        method: 'web',
        reason: '듀오링고 연속 기록에 오늘이 올라갔어요.',
      );
    }
    final xp = profile.totalXp;
    if (xp != null && previousXp != null && xp > previousXp) {
      return const DuolingoJudgement(
        status: DuolingoStatus.done,
        method: 'web',
        reason: '듀오링고 경험치(XP)가 늘었어요.',
      );
    }
    return const DuolingoJudgement(
      status: DuolingoStatus.notYet,
      method: 'web',
      reason: '듀오링고 기록에서 오늘 학습이 아직 안 보여요.',
    );
  }

  /// 방법 B: 태블릿에서 듀오링고 앱을 쓴 시간.
  static DuolingoJudgement judgeUsage({
    required int minutes,
    required int minMinutes,
  }) {
    if (minutes >= minMinutes) {
      return DuolingoJudgement(
        status: DuolingoStatus.done,
        method: 'usage',
        reason: '오늘 태블릿에서 듀오링고를 $minutes분 했어요.',
      );
    }
    return DuolingoJudgement(
      status: DuolingoStatus.notYet,
      method: 'usage',
      reason: '태블릿 사용 시간이 $minutes분이에요. $minMinutes분 이상이면 완료예요.',
    );
  }
}
