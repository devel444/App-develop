import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sticker_world/core/router/routes.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/time/local_date.dart';
import 'package:sticker_world/core/widgets/jelly_button.dart';
import 'package:sticker_world/core/widgets/outlined_text.dart';
import 'package:sticker_world/core/widgets/pattern_background.dart';
import 'package:sticker_world/core/widgets/screen_frame.dart';
import 'package:sticker_world/core/widgets/white_frame_card.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/providers.dart';
import 'package:sticker_world/domain/routine_rules.dart';
import 'package:sticker_world/domain/sticker_rules.dart';
import 'package:sticker_world/features/pin/parent_pin_screen.dart';
import 'package:sticker_world/features/today/clear_celebration.dart';
import 'package:sticker_world/features/today/routine_icons.dart';
import 'package:sticker_world/features/today/timer_dialog.dart';

/// 오늘의 할 일: 시간대별 루틴 체크, 올클리어 축하, 보너스 확인.
class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  bool _showClear = false;
  bool _bonusPending = false;
  String? _message;

  Future<void> _complete(Routine routine, {required String source}) async {
    setState(() => _message = null);
    try {
      final result = await ref
          .read(routineRepositoryProvider)
          .complete(routineId: routine.id, source: source);
      if (!mounted) {
        return;
      }
      if (result.cleared) {
        setState(() {
          _bonusPending = result.bonusPending;
          _showClear = true;
        });
      }
    } on StickerRuleException catch (error) {
      if (mounted) {
        setState(() => _message = error.message);
      }
    }
  }

  Future<void> _onTap(Routine routine, bool done) async {
    if (done) {
      return;
    }
    switch (routine.kind) {
      case 'normal':
        await _complete(routine, source: 'child');
      case 'parent_check' || 'duolingo':
        if (await requireParentPin(context) && mounted) {
          await _complete(routine, source: 'parent');
        }
      case 'diary':
        if (mounted) {
          context.go(Routes.diary);
        }
      case 'timer':
        final minutes = routine.timerMinutes ?? 5;
        final finished = await showRoutineTimer(context, minutes);
        if (finished && mounted) {
          await _complete(routine, source: 'child');
        }
    }
  }

  Future<void> _uncheck(Routine routine) async {
    if (!await requireParentPin(context) || !mounted) {
      return;
    }
    await ref.read(routineRepositoryProvider).uncomplete(routine.id);
  }

  Future<void> _confirmBonus(DailyClear clear) async {
    if (!await requireParentPin(context) || !mounted) {
      return;
    }
    try {
      await ref.read(routineRepositoryProvider).confirmBonus(clear.id);
    } on StickerRuleException catch (error) {
      if (mounted) {
        setState(() => _message = error.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final date = localDateKey(now);
    final routines = ref.watch(routinesProvider).value ?? const <Routine>[];
    final logs =
        ref.watch(routineLogsProvider(date)).value ?? const <RoutineLog>[];
    final pending =
        ref.watch(pendingBonusesProvider).value ?? const <DailyClear>[];
    final clearDates = ref.watch(clearDatesProvider).value ?? const <String>{};

    final dueToday = routines
        .where((r) => r.isActive && RoutineDays.includes(r.daysMask, now))
        .toList();
    final doneIds = {for (final log in logs) log.routineId};
    final doneCount = dueToday.where((r) => doneIds.contains(r.id)).length;
    final streak = clearStreak(clearDates, now);

    return Stack(
      fit: StackFit.expand,
      children: [
        ScreenFrame(
          title: '오늘의 할 일',
          color: AppColors.green,
          pattern: BgPattern.stripes,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            children: [
              _Header(
                date: now,
                done: doneCount,
                total: dueToday.length,
                streak: streak,
              ),
              if (_message != null) ...[
                const SizedBox(height: 12),
                _Notice(
                  text: _message!,
                  onClose: () => setState(() => _message = null),
                ),
              ],
              for (final clear in pending)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _BonusCard(
                    count: pending.length,
                    onConfirm: () => _confirmBonus(clear),
                  ),
                ),
              const SizedBox(height: 16),
              if (dueToday.isEmpty)
                const WhiteFrameCard(
                  headerTitle: '오늘 할 일이 없어요',
                  child: Text(
                    '엄마·아빠가 루틴을 추가하면\n여기에 보여요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, color: AppColors.ink),
                  ),
                ),
              for (final slot in routineSlots) ...[
                if (dueToday.any((r) => r.timeSlot == slot.$1)) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: OutlinedText(
                      slot.$2,
                      fontSize: 34,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  for (final routine in dueToday.where(
                    (r) => r.timeSlot == slot.$1,
                  ))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _RoutineTile(
                        routine: routine,
                        done: doneIds.contains(routine.id),
                        onTap: () =>
                            _onTap(routine, doneIds.contains(routine.id)),
                        onLongPress: doneIds.contains(routine.id)
                            ? () => _uncheck(routine)
                            : null,
                      ),
                    ),
                ],
              ],
              const SizedBox(height: 16),
              JellyButton(
                color: AppColors.white,
                height: 80,
                semanticLabel: '루틴 관리',
                onTap: () => pinThenPush(context, Routes.routines),
                child: const Center(
                  child: Text(
                    '루틴 관리 (엄마·아빠)',
                    style: TextStyle(fontSize: 26, color: AppColors.ink),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_showClear)
          ClearCelebration(
            bonusPending: _bonusPending,
            onDone: () => setState(() => _showClear = false),
          ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.date,
    required this.done,
    required this.total,
    required this.streak,
  });

  final DateTime date;
  final int done;
  final int total;
  final int streak;

  static const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : done / total;
    final finished = total > 0 && done == total;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.ink, width: 4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${date.month}월 ${date.day}일 ${_weekdays[date.weekday - 1]}요일',
                  style: const TextStyle(fontSize: 28, color: AppColors.ink),
                ),
              ),
              Text(
                finished ? '모두 완료!' : '$done / $total 완료',
                style: const TextStyle(fontSize: 28, color: AppColors.green),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 22,
            decoration: BoxDecoration(
              color: const Color(0xFFE3D6BC),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: AppColors.ink, width: 3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
          ),
          if (streak > 0)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                '연속 $streak일 올클리어!',
                style: const TextStyle(fontSize: 22, color: AppColors.orange),
              ),
            ),
        ],
      ),
    );
  }
}

class _RoutineTile extends StatelessWidget {
  const _RoutineTile({
    required this.routine,
    required this.done,
    required this.onTap,
    this.onLongPress,
  });

  final Routine routine;
  final bool done;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  String get _subtitle {
    if (done) {
      return '완료! 잘했어요';
    }
    return switch (routine.kind) {
      'normal' => '눌러서 체크해요',
      'parent_check' => '엄마·아빠 확인이 필요해요',
      'duolingo' => '듀오링고를 하고 엄마·아빠가 확인해요',
      'diary' => '일기를 저장하면 자동으로 체크돼요',
      'timer' => '${routine.timerMinutes ?? 5}분 동안 해요',
      _ => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final tile = JellyButton(
      color: done ? AppColors.mint : AppColors.white,
      height: 104,
      borderRadius: BorderRadius.circular(40),
      semanticLabel: routine.title,
      onTap: done ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? AppColors.green : AppColors.white,
                border: Border.all(color: AppColors.ink, width: 3),
              ),
              child: done
                  ? const Icon(
                      Icons.check_rounded,
                      size: 40,
                      color: AppColors.white,
                    )
                  : Icon(
                      routineIcon(routine.iconKey),
                      size: 36,
                      color: AppColors.ink,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    routine.title,
                    style: const TextStyle(fontSize: 30, color: AppColors.ink),
                  ),
                  Text(
                    _subtitle,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF3A4A3A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (onLongPress == null) {
      return tile;
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: onLongPress,
      child: tile,
    );
  }
}

class _BonusCard extends StatelessWidget {
  const _BonusCard({required this.count, required this.onConfirm});

  final int count;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return WhiteFrameCard(
      headerTitle: '보너스 스티커 $count개',
      headerColor: AppColors.gold,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '올클리어 보너스예요.\n엄마·아빠가 확인하면 스티커가 붙어요.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, color: AppColors.ink),
          ),
          const SizedBox(height: 12),
          JellyButton(
            color: AppColors.gold,
            height: 72,
            semanticLabel: '보너스 확인',
            onTap: onConfirm,
            child: const Center(child: OutlinedText('엄마·아빠 확인', fontSize: 28)),
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text, required this.onClose});

  final String text;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, color: AppColors.misdeed),
        ),
      ),
    );
  }
}
