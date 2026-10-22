import 'package:sticker_world/core/time/local_date.dart';

/// 기록 탭의 리포트 기간. 이번 주·이번 달은 직전 같은 길이 기간과 비교하고, 전체는 비교하지 않는다.
enum ReportPeriod {
  week('이번 주', '지난주'),
  month('이번 달', '지난달'),
  all('전체', '');

  const ReportPeriod(this.label, this.previousLabel);

  final String label;

  /// 비교 문장에 쓰는 말.
  final String previousLabel;
}

/// 'YYYY-MM-DD' 기간. 양 끝을 포함한다.
class DateSpan {
  const DateSpan(this.start, this.end);

  final String start;
  final String end;

  bool contains(String localDate) =>
      localDate.compareTo(start) >= 0 && localDate.compareTo(end) <= 0;
}

/// 리포트가 보는 기간, 비교할 직전 기간, 부모 한마디를 묶는 키.
class ReportWindow {
  const ReportWindow({
    required this.period,
    required this.current,
    required this.key,
    this.previous,
  });

  final ReportPeriod period;
  final DateSpan current;

  /// 전체 기간이면 null.
  final DateSpan? previous;

  /// 부모 한마디 기간 키. 이번 주는 그 주 월요일, 이번 달은 'YYYY-MM', 전체는 'all'.
  final String key;

  static ReportWindow of(ReportPeriod period, DateTime now) {
    final today = localDateKey(now);
    final day = DateTime(now.year, now.month, now.day);
    switch (period) {
      case ReportPeriod.week:
        final monday = day.subtract(
          Duration(days: day.weekday - DateTime.monday),
        );
        final lastMonday = monday.subtract(const Duration(days: 7));
        final lastSunday = monday.subtract(const Duration(days: 1));
        return ReportWindow(
          period: period,
          current: DateSpan(localDateKey(monday), today),
          previous: DateSpan(
            localDateKey(lastMonday),
            localDateKey(lastSunday),
          ),
          key: localDateKey(monday),
        );
      case ReportPeriod.month:
        final first = DateTime(now.year, now.month);
        final lastFirst = DateTime(now.year, now.month - 1);
        final lastDay = DateTime(now.year, now.month, 0);
        return ReportWindow(
          period: period,
          current: DateSpan(localDateKey(first), today),
          previous: DateSpan(localDateKey(lastFirst), localDateKey(lastDay)),
          key: '${now.year}-${now.month.toString().padLeft(2, '0')}',
        );
      case ReportPeriod.all:
        return const ReportWindow(
          period: ReportPeriod.all,
          current: DateSpan('0000-01-01', '9999-12-31'),
          key: 'all',
        );
    }
  }
}

/// 장부 한 줄을 리포트용으로 줄인 값. DB 행과 분리해서 순수 Dart로 테스트한다.
class GrowthEvent {
  const GrowthEvent({
    required this.id,
    required this.type,
    required this.amount,
    required this.localDate,
    required this.createdAt,
    this.categoryId,
    this.memo,
    this.nextPromise,
    this.relatedEventId,
  });

  final int id;

  /// earn | remove | warn | undo | bonus | redeem | adjust
  final String type;

  final int amount;
  final String localDate;
  final DateTime createdAt;
  final int? categoryId;
  final String? memo;
  final String? nextPromise;
  final int? relatedEventId;
}

/// 되돌리기 행이 가리키는 원래 기록 id 모음.
Set<int> undoneIdsOf(Iterable<GrowthEvent> events) {
  return {
    for (final event in events)
      if (event.type == 'undo' && event.relatedEventId != null)
        event.relatedEventId!,
  };
}

/// 지금 남아 있는 기록. 되돌리기 행과 되돌려진 기록은 뺀다.
List<GrowthEvent> liveEventsOf(List<GrowthEvent> events) {
  final undone = undoneIdsOf(events);
  return [
    for (final event in events)
      if (event.type != 'undo' && !undone.contains(event.id)) event,
  ];
}

enum ReportTone { good, warn, neutral }

/// 리포트의 한 문장. 아이에게 보이므로 혼내는 말은 쓰지 않는다.
class ReportLine {
  const ReportLine(this.text, {this.tone = ReportTone.neutral});

  final String text;
  final ReportTone tone;
}

class GrowthReport {
  const GrowthReport({
    required this.period,
    required this.stickersEarned,
    required this.stickersRemoved,
    required this.praiseCount,
    required this.misdeedCount,
    required this.good,
    required this.fix,
    this.nextPromise,
  });

  final ReportPeriod period;

  /// 받은 스티커 (받기 + 보너스).
  final int stickersEarned;

  /// 뺀 스티커 수.
  final int stickersRemoved;

  /// 칭찬 기록 횟수.
  final int praiseCount;

  /// 잘못 기록 횟수 (빼기 + 경고).
  final int misdeedCount;

  /// 지금 잘하고 있는 점 (최대 3개).
  final List<ReportLine> good;

  /// 고쳐나가야 할 점 (최대 3개).
  final List<ReportLine> fix;

  /// 가장 최근 '다음엔 이렇게' 메모.
  final String? nextPromise;
}

/// PLAN.md 4장의 규칙으로 리포트 문장을 만든다. AI 없이 세는 것이 전부다.
abstract final class GrowthReportBuilder {
  static GrowthReport build({
    required List<GrowthEvent> events,
    required ReportWindow window,
    required Map<int, String> categoryNames,
    int? duolingoStreak,
    int? routineStreak,
  }) {
    final live = liveEventsOf(events);
    final inNow = live
        .where((e) => window.current.contains(e.localDate))
        .toList();
    final before = window.previous;
    final cur = _Tally.of(inNow);
    final prev = before == null
        ? null
        : _Tally.of(live.where((e) => before.contains(e.localDate)));
    final period = window.period;

    String nameOf(int id) => categoryNames[id] ?? '기타';

    final good = <_Scored>[];
    final topPraise = _ranked(cur.praise);
    if (topPraise.isNotEmpty) {
      final top = topPraise.first;
      good.add(
        _Scored(
          top.value,
          ReportLine(
            '${nameOf(top.key)} 칭찬을 제일 많이 받았어요 (${top.value}개)',
            tone: ReportTone.good,
          ),
        ),
      );
    }
    if (prev != null) {
      for (final entry in cur.praise.entries) {
        final gain = entry.value - (prev.praise[entry.key] ?? 0);
        if (gain >= 3) {
          good.add(
            _Scored(
              gain,
              ReportLine(
                '${nameOf(entry.key)} 칭찬이 ${period.previousLabel}보다 $gain개 늘었어요',
                tone: ReportTone.good,
              ),
            ),
          );
        }
      }
    }
    final repeated = [
      for (final memo in _ranked(cur.memos))
        if (memo.value >= 2) memo,
    ].take(2).toList();
    if (repeated.isNotEmpty) {
      final quoted = repeated.map((m) => '"${m.key}"').join(', ');
      good.add(
        _Scored(
          repeated.first.value,
          ReportLine('자주 들은 칭찬: $quoted', tone: ReportTone.good),
        ),
      );
    }
    if (duolingoStreak != null && duolingoStreak >= 3) {
      good.add(
        _Scored(
          duolingoStreak,
          ReportLine('듀오링고 $duolingoStreak일 연속!', tone: ReportTone.good),
        ),
      );
    }
    if (routineStreak != null && routineStreak >= 3) {
      good.add(
        _Scored(
          routineStreak,
          ReportLine('할 일 $routineStreak일 연속 올클리어!', tone: ReportTone.good),
        ),
      );
    }
    if (prev != null) {
      final lead = period == ReportPeriod.week ? '이번 주엔' : '이번 달엔';
      for (final kind in _ranked(prev.misdeed)) {
        if (!cur.misdeed.containsKey(kind.key)) {
          good.add(
            _Scored(
              2,
              ReportLine(
                '$lead ${_subjectOf(nameOf(kind.key))} 한 번도 없었어요!',
                tone: ReportTone.good,
              ),
            ),
          );
        }
      }
    }

    final fix = <_Scored>[];
    for (final kind in _ranked(cur.misdeed)) {
      final count = kind.value;
      var text = '${nameOf(kind.key)} · $count번';
      var tone = ReportTone.neutral;
      if (prev != null) {
        final was = prev.misdeed[kind.key] ?? 0;
        if (count < was) {
          text = '$text · ${period.previousLabel}보다 줄었어요';
          tone = ReportTone.good;
        } else if (count > was) {
          text = '$text · ${period.previousLabel}보다 늘었어요';
          tone = ReportTone.warn;
        } else {
          text = '$text · 지난번과 그대로예요';
        }
      }
      fix.add(_Scored(count, ReportLine(text, tone: tone)));
    }
    final hours = _ranked(cur.misdeedHours);
    if (hours.isNotEmpty && hours.first.value >= 2) {
      final top = hours.first;
      fix.add(_Scored(top.value, ReportLine('주로 ${_timeOf(top.key)}에 있었어요')));
    }

    String? promise;
    var promiseId = -1;
    for (final event in inNow) {
      final text = event.nextPromise?.trim();
      if (text != null && text.isNotEmpty && event.id > promiseId) {
        promiseId = event.id;
        promise = text;
      }
    }

    return GrowthReport(
      period: period,
      stickersEarned: cur.earned,
      stickersRemoved: cur.removed,
      praiseCount: cur.praiseCount,
      misdeedCount: cur.misdeedCount,
      good: good.isEmpty
          ? const [ReportLine('차근차근 함께 모아 봐요!', tone: ReportTone.good)]
          : _top(good, 3),
      fix: cur.misdeedCount == 0
          ? const [ReportLine('약속을 아주 잘 지키고 있어요!', tone: ReportTone.good)]
          : _top(fix, 3),
      nextPromise: promise,
    );
  }

  /// 점수 높은 순, 같은 점수면 먼저 만들어진 순.
  static List<ReportLine> _top(List<_Scored> items, int max) {
    final indexed = [for (var i = 0; i < items.length; i++) (i, items[i])];
    indexed.sort((a, b) {
      final byScore = b.$2.score.compareTo(a.$2.score);
      return byScore != 0 ? byScore : a.$1.compareTo(b.$1);
    });
    return [for (final pair in indexed.take(max)) pair.$2.line];
  }

  static List<MapEntry<K, int>> _ranked<K extends Comparable<dynamic>>(
    Map<K, int> counts,
  ) {
    return counts.entries.toList()..sort((a, b) {
      return b.value != a.value
          ? b.value.compareTo(a.value)
          : a.key.compareTo(b.key);
    });
  }

  /// 받침이 있으면 '이', 없으면 '가'.
  static String _subjectOf(String name) {
    if (name.isEmpty) {
      return name;
    }
    final code = name.runes.last;
    final hasFinal =
        code >= 0xAC00 && code <= 0xD7A3 && (code - 0xAC00) % 28 != 0;
    return '$name${hasFinal ? '이' : '가'}';
  }

  /// 시각을 '저녁 7~8시' 꼴로 (아이 눈높이).
  static String _timeOf(int hour) {
    final slot = switch (hour) {
      < 5 => '새벽',
      < 12 => '아침',
      < 17 => '낮',
      < 21 => '저녁',
      _ => '밤',
    };
    return '$slot ${_clockHour(hour)}~${_clockHour(hour + 1)}시';
  }

  static int _clockHour(int hour) => hour % 12 == 0 ? 12 : hour % 12;
}

class _Scored {
  const _Scored(this.score, this.line);

  final int score;
  final ReportLine line;
}

/// 기간 안의 횟수 모음.
class _Tally {
  final praise = <int, int>{};
  final misdeed = <int, int>{};
  final misdeedHours = <int, int>{};
  final memos = <String, int>{};
  int earned = 0;
  int removed = 0;
  int praiseCount = 0;
  int misdeedCount = 0;

  static _Tally of(Iterable<GrowthEvent> events) {
    final tally = _Tally();
    for (final event in events) {
      switch (event.type) {
        case 'earn':
          tally.earned += event.amount;
          tally.praiseCount++;
          _count(tally.praise, event.categoryId);
          final memo = event.memo?.trim();
          if (memo != null && memo.isNotEmpty) {
            tally.memos.update(memo, (n) => n + 1, ifAbsent: () => 1);
          }
        case 'bonus':
          tally.earned += event.amount;
        case 'remove':
          tally.removed += -event.amount;
          tally.misdeedCount++;
          _count(tally.misdeed, event.categoryId);
          _countHour(tally, event);
        case 'warn':
          tally.misdeedCount++;
          _count(tally.misdeed, event.categoryId);
          _countHour(tally, event);
      }
    }
    return tally;
  }

  static void _count(Map<int, int> counts, int? key) {
    if (key == null) {
      return;
    }
    counts.update(key, (n) => n + 1, ifAbsent: () => 1);
  }

  static void _countHour(_Tally tally, GrowthEvent event) {
    tally.misdeedHours.update(
      event.createdAt.toLocal().hour,
      (n) => n + 1,
      ifAbsent: () => 1,
    );
  }
}
