import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticker_world/data/providers.dart';
import 'package:sticker_world/data/repositories/routine_repository.dart';
import 'package:sticker_world/domain/routine_rules.dart';
import 'package:sticker_world/domain/duolingo_rules.dart';

/// 마지막 듀오링고 확인 결과 (할 일 탭에 보여 준다).
class DuolingoView {
  const DuolingoView({this.judgement, this.checkedAt, this.busy = false});

  final DuolingoJudgement? judgement;
  final DateTime? checkedAt;
  final bool busy;
}

/// 자동 체크 한 번의 결과. 완료였다면 루틴 체크 결과도 같이 온다 (올클리어 연출용).
class AutoCheckOutcome {
  const AutoCheckOutcome({required this.judgement, this.completion});

  final DuolingoJudgement judgement;
  final CompleteResult? completion;
}

class DuolingoStatusNotifier extends Notifier<DuolingoView> {
  @override
  DuolingoView build() => const DuolingoView();

  /// 오늘 듀오링고 루틴이 있을 때만 확인한다 (없으면 인터넷도 안 쓴다).
  /// 완료로 확인되면 듀오링고 루틴을 자동으로 체크한다.
  Future<AutoCheckOutcome?> refresh() async {
    if (state.busy) {
      return null;
    }
    // 확인이 어떻게 실패하든 할 일 탭은 계속 쓸 수 있어야 한다.
    try {
      return await _check();
    } catch (_) {
      state = DuolingoView(
        judgement: state.judgement,
        checkedAt: state.checkedAt,
      );
      return null;
    }
  }

  Future<AutoCheckOutcome?> _check() async {
    final child = ref.read(currentChildProvider).value;
    if (child == null) {
      return null;
    }
    final now = DateTime.now();
    final routines = await ref.read(routineRepositoryProvider).watchAll().first;
    final dueDuolingo = routines
        .where(
          (r) =>
              r.kind == 'duolingo' &&
              r.isActive &&
              RoutineDays.includes(r.daysMask, now),
        )
        .toList();
    if (dueDuolingo.isEmpty) {
      return null;
    }

    state = DuolingoView(
      judgement: state.judgement,
      checkedAt: state.checkedAt,
      busy: true,
    );
    final minutes = await ref
        .read(settingsRepositoryProvider)
        .getInt('usage_min_minutes', fallback: 5);
    final judgement = await ref
        .read(duolingoSyncProvider)
        .check(
          childId: child.id,
          username: child.duolingoUsername,
          packageName: child.duolingoPackage,
          usageMinMinutes: minutes,
        );
    state = DuolingoView(judgement: judgement, checkedAt: now);

    if (!judgement.isDone) {
      return AutoCheckOutcome(judgement: judgement);
    }
    final completion = await ref
        .read(routineRepositoryProvider)
        .complete(routineId: dueDuolingo.first.id, source: 'auto');
    return AutoCheckOutcome(judgement: judgement, completion: completion);
  }
}

final duolingoStatusProvider =
    NotifierProvider<DuolingoStatusNotifier, DuolingoView>(
      DuolingoStatusNotifier.new,
    );

/// 할 일 탭에 보여 줄 듀오링고 줄 글.
String duolingoStatusText(DuolingoView view) {
  final judgement = view.judgement;
  if (judgement == null) {
    return view.busy ? '듀오링고 기록을 확인하고 있어요…' : '듀오링고를 하면 자동으로 체크돼요';
  }
  return switch (judgement.status) {
    DuolingoStatus.done => '듀오링고 완료! 자동으로 체크했어요',
    DuolingoStatus.notYet => '아직 안 했어요. 하면 자동으로 체크돼요',
    DuolingoStatus.unknown => '확인할 수 없어요. 엄마·아빠가 눌러 주세요',
  };
}
