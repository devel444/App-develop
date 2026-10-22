import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/jelly_button.dart';
import 'package:sticker_world/core/widgets/white_frame_card.dart';
import 'package:sticker_world/data/providers.dart';
import 'package:sticker_world/domain/growth_report.dart';
import 'package:sticker_world/domain/routine_rules.dart';
import 'package:sticker_world/features/pin/parent_pin_screen.dart';
import 'package:sticker_world/features/stamp/stamp_widgets.dart';

/// 기록 탭 2페이지: 성장 리포트. 잘하고 있는 점과 고쳐나가야 할 점을 규칙으로 만든다.
class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({super.key});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  ReportPeriod _period = ReportPeriod.week;

  Future<void> _writeComment(
    ReportPeriod period,
    String periodKey,
    String? current,
  ) async {
    if (!await requireParentPin(context) || !mounted) {
      return;
    }
    final childId = ref.read(currentChildProvider).value?.id;
    if (childId == null) {
      return;
    }
    final controller = TextEditingController(text: current ?? '');
    final text = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('엄마·아빠 한마디'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          style: const TextStyle(fontSize: 22),
          decoration: const InputDecoration(
            hintText: '이번 기간을 칭찬하는 말을 적어 주세요',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('저장'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (text != null) {
      await ref
          .read(reportCommentRepositoryProvider)
          .save(
            childId: childId,
            periodType: period.name,
            periodKey: periodKey,
            content: text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final window = ReportWindow.of(_period, now);
    final history =
        ref.watch(stickerHistoryProvider).value ?? const <GrowthEvent>[];
    final names =
        ref.watch(categoryNamesProvider).value ?? const <int, String>{};
    final clears = ref.watch(clearDatesProvider).value ?? const <String>{};
    final duolingo = ref.watch(duolingoLatestProvider).value;
    final report = GrowthReportBuilder.build(
      events: history,
      window: window,
      categoryNames: names,
      duolingoStreak: duolingo != null && duolingo.ok ? duolingo.streak : null,
      routineStreak: clearStreak(clears, now),
    );
    final comment = ref
        .watch(reportCommentProvider((_period.name, window.key)))
        .value;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              for (final period in ReportPeriod.values)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceButton(
                      label: period.label,
                      height: 64,
                      selected: _period == period,
                      onTap: () => setState(() => _period = period),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          WhiteFrameCard(
            headerTitle: '숫자로 보기',
            headerColor: AppColors.green,
            child: Column(
              children: [
                Row(
                  children: [
                    _Stat(value: report.stickersEarned, label: '받은 스티커'),
                    _Stat(value: report.stickersRemoved, label: '뺀 스티커'),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '칭찬 ${report.praiseCount}번 : 잘못 ${report.misdeedCount}번',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 26, color: AppColors.ink),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          WhiteFrameCard(
            headerTitle: '지금 잘하고 있는 점',
            headerColor: AppColors.gold,
            child: Column(
              children: [
                for (final line in report.good)
                  _LineRow(
                    line: line,
                    leading: const Icon(
                      Icons.star_rounded,
                      size: 32,
                      color: AppColors.gold,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          WhiteFrameCard(
            headerTitle: '고쳐나가야 할 점',
            headerColor: AppColors.orange,
            child: Column(
              children: [
                for (final line in report.fix)
                  _LineRow(line: line, leading: _fixIcon(line.tone)),
                if (report.nextPromise != null) ...[
                  const SizedBox(height: 12),
                  _PromiseBubble(text: report.nextPromise!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          WhiteFrameCard(
            headerTitle: '엄마·아빠 한마디',
            headerColor: AppColors.pink,
            child: Column(
              children: [
                Text(
                  comment?.content ?? '아직 한마디가 없어요',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, color: AppColors.ink),
                ),
                const SizedBox(height: 16),
                JellyButton(
                  color: AppColors.white,
                  height: 72,
                  semanticLabel: '엄마·아빠 한마디 쓰기',
                  onTap: () =>
                      _writeComment(_period, window.key, comment?.content),
                  child: const Center(
                    child: Text(
                      '한마디 쓰기 (엄마·아빠)',
                      style: TextStyle(fontSize: 24, color: AppColors.ink),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _fixIcon(ReportTone tone) {
    return switch (tone) {
      ReportTone.good => const Icon(
        Icons.trending_down_rounded,
        size: 32,
        color: AppColors.green,
      ),
      ReportTone.warn => const Icon(
        Icons.trending_up_rounded,
        size: 32,
        color: AppColors.misdeed,
      ),
      ReportTone.neutral => const Icon(
        Icons.fiber_manual_record_rounded,
        size: 20,
        color: AppColors.ink,
      ),
    };
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: const TextStyle(fontSize: 44, color: AppColors.ink),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 20, color: Color(0xFF3A4A3A)),
          ),
        ],
      ),
    );
  }
}

class _LineRow extends StatelessWidget {
  const _LineRow({required this.line, required this.leading});

  final ReportLine line;
  final Widget leading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leading,
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              line.text,
              style: const TextStyle(fontSize: 24, color: AppColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromiseBubble extends StatelessWidget {
  const _PromiseBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.blue, width: 4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '다음 약속',
            style: TextStyle(fontSize: 20, color: AppColors.blue),
          ),
          const SizedBox(height: 6),
          Text(text, style: const TextStyle(fontSize: 24, height: 1.4)),
        ],
      ),
    );
  }
}
