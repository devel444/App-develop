import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/time/local_date.dart';
import 'package:sticker_world/core/widgets/jelly_button.dart';
import 'package:sticker_world/core/widgets/outlined_text.dart';
import 'package:sticker_world/core/widgets/white_frame_card.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/providers.dart';
import 'package:sticker_world/domain/growth_calendar.dart';
import 'package:sticker_world/domain/growth_report.dart';
import 'package:sticker_world/features/records/record_labels.dart';
import 'package:sticker_world/features/stamp/stamp_widgets.dart';

const _weekdayNames = ['월', '화', '수', '목', '금', '토', '일'];

/// 기록 탭 1페이지: 달력. 날짜를 고르면 아래에 그날 기록이 나온다.
class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  late String _selected = localDateKey(DateTime.now());

  void _moveMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
      _selected = localDateKey(_month);
    });
  }

  @override
  Widget build(BuildContext context) {
    final history =
        ref.watch(stickerHistoryProvider).value ?? const <GrowthEvent>[];
    final clears = ref.watch(clearDatesProvider).value ?? const <String>{};
    final diaries =
        ref.watch(diaryEntriesProvider).value ?? const <DiaryEntry>[];
    final diaryDates = {for (final entry in diaries) entry.localDate};
    final days = GrowthCalendar.month(
      events: history,
      clearDates: clears,
      diaryDates: diaryDates,
      year: _month.year,
      month: _month.month,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MonthHeader(
            month: _month,
            onPrevious: () => _moveMonth(-1),
            onNext: () => _moveMonth(1),
          ),
          const SizedBox(height: 12),
          WhiteFrameCard(
            child: _MonthGrid(
              month: _month,
              days: days,
              selected: _selected,
              onTap: (date) => setState(() => _selected = date),
            ),
          ),
          const SizedBox(height: 16),
          _DayDetail(
            date: _selected,
            history: history,
            cleared: clears.contains(_selected),
          ),
        ],
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _NavButton(
          icon: Icons.chevron_left_rounded,
          label: '이전 달',
          onTap: onPrevious,
        ),
        Expanded(
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: OutlinedText(
                '${month.year}년 ${month.month}월',
                fontSize: 36,
              ),
            ),
          ),
        ),
        _NavButton(
          icon: Icons.chevron_right_rounded,
          label: '다음 달',
          onTap: onNext,
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: JellyButton(
        color: AppColors.gold,
        height: 72,
        semanticLabel: label,
        onTap: onTap,
        child: Center(child: Icon(icon, size: 44, color: AppColors.ink)),
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.days,
    required this.selected,
    required this.onTap,
  });

  final DateTime month;
  final Map<String, DayRecord> days;
  final String selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final lead = DateTime(month.year, month.month).weekday - DateTime.monday;
    final count = DateTime(month.year, month.month + 1, 0).day;
    final cells = <int?>[
      for (var i = 0; i < lead; i++) null,
      for (var day = 1; day <= count; day++) day,
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return Column(
      children: [
        Row(
          children: [
            for (final name in _weekdayNames)
              Expanded(
                child: Center(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 20,
                      color: switch (name) {
                        '토' => AppColors.blue,
                        '일' => AppColors.misdeed,
                        _ => AppColors.ink,
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        for (var start = 0; start < cells.length; start += 7)
          Row(
            children: [
              for (final day in cells.sublist(start, start + 7))
                Expanded(
                  child: day == null
                      ? const SizedBox(height: 84)
                      : _dayCell(day),
                ),
            ],
          ),
      ],
    );
  }

  Widget _dayCell(int day) {
    final date = localDateKey(DateTime(month.year, month.month, day));
    return _DayCell(
      day: day,
      date: date,
      record: days[date],
      selected: selected == date,
      today: localDateKey(DateTime.now()) == date,
      onTap: onTap,
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.date,
    required this.record,
    required this.selected,
    required this.today,
    required this.onTap,
  });

  final int day;
  final String date;
  final DayRecord? record;
  final bool selected;
  final bool today;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final rec = record ?? const DayRecord();
    return Semantics(
      button: true,
      label: '$day일 기록',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(date),
        child: Container(
          height: 84,
          margin: const EdgeInsets.all(2),
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: selected ? AppColors.gold : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: today ? Border.all(color: AppColors.ink, width: 2) : null,
          ),
          child: Column(
            children: [
              Text(
                '$day',
                style: TextStyle(
                  fontSize: 20,
                  color: AppColors.ink,
                  fontWeight: today ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (rec.earned > 0)
                        Text(
                          '+${rec.earned}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.green,
                          ),
                        ),
                      if (rec.removed > 0)
                        Text(
                          '−${rec.removed}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.misdeed,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (rec.cleared)
                      const Icon(
                        Icons.flag_rounded,
                        size: 16,
                        color: AppColors.red,
                      ),
                    if (rec.warned > 0)
                      const Icon(
                        Icons.circle,
                        size: 10,
                        color: AppColors.orange,
                      ),
                    if (rec.diary)
                      const Icon(Icons.circle, size: 10, color: AppColors.pink),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 고른 날의 기록: 스티커 기록(시간순), 할 일 체크, 올클리어, 일기.
class _DayDetail extends ConsumerWidget {
  const _DayDetail({
    required this.date,
    required this.history,
    required this.cleared,
  });

  final String date;
  final List<GrowthEvent> history;
  final bool cleared;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final names =
        ref.watch(categoryNamesProvider).value ?? const <int, String>{};
    final routineTitles = {
      for (final routine
          in ref.watch(routinesProvider).value ?? const <Routine>[])
        routine.id: routine.title,
    };
    final logs =
        ref.watch(routineLogsProvider(date)).value ?? const <RoutineLog>[];
    final diary = ref.watch(diaryOnProvider(date)).value;
    final undone = undoneIdsOf(history);
    final dayEvents = [
      for (final event in history)
        if (event.localDate == date && event.type != 'undo') event,
    ];
    final parsed = DateTime.parse(date);

    final rows = <Widget>[
      for (final event in dayEvents)
        _DetailLine(text: _eventLine(event, names, undone.contains(event.id))),
      for (final log in logs)
        _DetailLine(text: '✓ ${routineTitles[log.routineId] ?? ''}'),
      if (cleared) const _DetailLine(text: '✓ 올클리어 했어요!'),
    ];

    return WhiteFrameCard(
      headerTitle: '${parsed.day}일 (${_weekdayNames[parsed.weekday - 1]})',
      headerColor: AppColors.pink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (rows.isEmpty && diary == null) const HintText('이 날은 기록이 없어요'),
          ...rows,
          if (diary != null) ...[
            if (rows.isNotEmpty) const SizedBox(height: 12),
            Text(
              '일기 · ${diary.title.isEmpty ? '(제목 없음)' : diary.title}',
              style: const TextStyle(fontSize: 24, color: AppColors.ink),
            ),
            const SizedBox(height: 6),
            Text(diary.body, style: const TextStyle(fontSize: 22, height: 1.4)),
            if (diary.parentReply != null) ...[
              const SizedBox(height: 10),
              Text(
                '엄마·아빠 답장: ${diary.parentReply}',
                style: const TextStyle(fontSize: 22, color: AppColors.misdeed),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// 시간순 기록 한 줄: '문구 · 메모 (되돌렸어요)'.
String _eventLine(GrowthEvent event, Map<int, String> names, bool undone) {
  final label = stickerRecordLabel(
    type: event.type,
    amount: event.amount,
    categoryId: event.categoryId,
    names: names,
  );
  final memo = event.memo;
  final withMemo = memo == null || memo.isEmpty ? label : '$label · $memo';
  return undone ? '$withMemo (되돌렸어요)' : withMemo;
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 22, color: AppColors.ink),
      ),
    );
  }
}
