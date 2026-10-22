import 'package:sticker_world/core/time/local_date.dart';
import 'package:sticker_world/data/duolingo/duolingo_api.dart';
import 'package:sticker_world/data/duolingo/usage_source.dart';
import 'package:sticker_world/data/repositories/duolingo_repository.dart';
import 'package:sticker_world/domain/duolingo_rules.dart';

/// 듀오링고 자동 체크 순서 (PLAN.md 3장):
/// 웹 프로필 → 태블릿 사용 시간 → 둘 다 안 되면 '확인 불가' (엄마·아빠가 수동으로 누른다).
class DuolingoSync {
  DuolingoSync({
    required this.api,
    required this.usage,
    required this.repository,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final DuolingoApi api;
  final UsageSource usage;
  final DuolingoRepository repository;
  final DateTime Function() _clock;

  Future<DuolingoJudgement> check({
    required int childId,
    required String? username,
    required String packageName,
    required int usageMinMinutes,
  }) async {
    final today = localDateKey(_clock());
    var webWorked = false;

    final name = username?.trim() ?? '';
    if (name.isNotEmpty) {
      try {
        final profile = await api.fetchProfile(name);
        webWorked = true;
        final previous = await repository.previousXp(childId, today);
        await repository.saveSnapshot(
          childId: childId,
          method: 'web',
          ok: true,
          profile: profile,
          when: _clock(),
        );
        final judgement = DuolingoRules.judgeWeb(
          profile: profile,
          previousXp: previous,
          today: today,
        );
        if (judgement.isDone) {
          return judgement;
        }
      } on Exception {
        await repository.saveSnapshot(
          childId: childId,
          method: 'web',
          ok: false,
          when: _clock(),
        );
      }
    }

    final minutes = await usage.minutesToday(packageName);
    if (minutes != null) {
      final judgement = DuolingoRules.judgeUsage(
        minutes: minutes,
        minMinutes: usageMinMinutes,
      );
      return judgement;
    }

    if (webWorked) {
      return const DuolingoJudgement(
        status: DuolingoStatus.notYet,
        method: 'web',
        reason: '듀오링고 기록에서 오늘 학습이 아직 안 보여요.',
      );
    }
    return const DuolingoJudgement(
      status: DuolingoStatus.unknown,
      method: 'manual',
      reason: '확인할 수 없어요. 엄마·아빠가 직접 눌러 주세요.',
    );
  }
}
