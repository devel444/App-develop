import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/domain/growth_report.dart';

// 기준일 2026-10-22 목요일. 이번 주 = 10-19 ~ 10-22, 지난주 = 10-12 ~ 10-18.
final _now = DateTime(2026, 10, 22, 12);

const _names = {1: '공부', 2: '착한 일', 11: '게임 시간 약속', 12: '거짓말', 13: '기타'};

GrowthEvent _earn(int id, String date, int category, {String? memo}) {
  return GrowthEvent(
    id: id,
    type: 'earn',
    amount: 1,
    localDate: date,
    createdAt: DateTime.parse('${date}T10:00:00'),
    categoryId: category,
    memo: memo,
  );
}

GrowthEvent _remove(
  int id,
  String date,
  int category, {
  int hour = 19,
  String? promise,
}) {
  return GrowthEvent(
    id: id,
    type: 'remove',
    amount: -1,
    localDate: date,
    createdAt: DateTime.parse(
      '${date}T${hour.toString().padLeft(2, '0')}:00:00',
    ),
    categoryId: category,
    memo: '이유',
    nextPromise: promise,
  );
}

GrowthEvent _warn(int id, String date, int category, {int hour = 19}) {
  return GrowthEvent(
    id: id,
    type: 'warn',
    amount: 0,
    localDate: date,
    createdAt: DateTime.parse(
      '${date}T${hour.toString().padLeft(2, '0')}:00:00',
    ),
    categoryId: category,
    memo: '경고',
  );
}

GrowthEvent _undo(int id, String date, int related, int amount) {
  return GrowthEvent(
    id: id,
    type: 'undo',
    amount: amount,
    localDate: date,
    createdAt: DateTime.parse('${date}T10:01:00'),
    relatedEventId: related,
  );
}

List<String> _texts(List<ReportLine> lines) => [for (final l in lines) l.text];

void main() {
  group('기간', () {
    test('이번 주는 월요일부터 오늘까지, 지난주는 그 앞 한 주다', () {
      final window = ReportWindow.of(ReportPeriod.week, _now);

      expect(window.current.start, '2026-10-19');
      expect(window.current.end, '2026-10-22');
      expect(window.previous!.start, '2026-10-12');
      expect(window.previous!.end, '2026-10-18');
      expect(window.key, '2026-10-19');
    });

    test('이번 달은 1일부터 오늘까지, 지난달은 9월 전체다', () {
      final window = ReportWindow.of(ReportPeriod.month, _now);

      expect(window.current.start, '2026-10-01');
      expect(window.current.end, '2026-10-22');
      expect(window.previous!.start, '2026-09-01');
      expect(window.previous!.end, '2026-09-30');
      expect(window.key, '2026-10');
    });

    test('전체 기간은 비교할 직전 기간이 없다', () {
      final window = ReportWindow.of(ReportPeriod.all, _now);

      expect(window.previous, isNull);
      expect(window.current.contains('2019-03-01'), isTrue);
      expect(window.key, 'all');
    });
  });

  test('되돌린 기록은 받은 수에서 빠지고, 되돌리기 행은 세지 않는다', () {
    final events = [
      _earn(1, '2026-10-19', 1),
      _earn(2, '2026-10-20', 1),
      _earn(3, '2026-10-21', 2),
      _undo(4, '2026-10-21', 3, -1),
      _remove(5, '2026-10-21', 11),
    ];

    final report = GrowthReportBuilder.build(
      events: events,
      window: ReportWindow.of(ReportPeriod.week, _now),
      categoryNames: _names,
    );

    expect(report.stickersEarned, 2);
    expect(report.praiseCount, 2);
    expect(report.stickersRemoved, 1);
    expect(report.misdeedCount, 1);
  });

  test('지금 잘하고 있는 점: 가장 많이 받은 칭찬과 자주 들은 문구', () {
    final events = [
      _earn(1, '2026-10-19', 1, memo: '받아쓰기 100점'),
      _earn(2, '2026-10-20', 1, memo: '받아쓰기 100점'),
      _earn(3, '2026-10-21', 1),
      _earn(4, '2026-10-21', 2),
    ];

    // 전체 기간으로 봐야 지난주와 비교하는 문장이 끼지 않는다.
    final report = GrowthReportBuilder.build(
      events: events,
      window: ReportWindow.of(ReportPeriod.all, _now),
      categoryNames: _names,
    );

    expect(_texts(report.good), [
      '공부 칭찬을 제일 많이 받았어요 (3개)',
      '자주 들은 칭찬: "받아쓰기 100점"',
    ]);
  });

  test('지난주보다 3개 이상 늘어난 칭찬은 비교 문장으로 올라온다', () {
    final events = [
      _earn(1, '2026-10-13', 1),
      _earn(2, '2026-10-19', 1),
      _earn(3, '2026-10-20', 1),
      _earn(4, '2026-10-21', 1),
      _earn(5, '2026-10-22', 1),
    ];

    final report = GrowthReportBuilder.build(
      events: events,
      window: ReportWindow.of(ReportPeriod.week, _now),
      categoryNames: _names,
    );

    expect(_texts(report.good), contains('공부 칭찬이 지난주보다 3개 늘었어요'));
  });

  test('듀오링고와 할 일 연속 일수는 3일 이상일 때만 말한다', () {
    final window = ReportWindow.of(ReportPeriod.all, _now);

    final long = GrowthReportBuilder.build(
      events: const [],
      window: window,
      categoryNames: _names,
      duolingoStreak: 42,
      routineStreak: 5,
    );
    final short = GrowthReportBuilder.build(
      events: const [],
      window: window,
      categoryNames: _names,
      duolingoStreak: 2,
      routineStreak: 1,
    );

    expect(_texts(long.good), ['듀오링고 42일 연속!', '할 일 5일 연속 올클리어!']);
    expect(_texts(short.good), ['차근차근 함께 모아 봐요!']);
  });

  test('지난달에 있던 잘못이 이번 달에는 없으면 칭찬 문장이 된다', () {
    final events = [_remove(1, '2026-09-10', 12), _earn(2, '2026-10-03', 1)];

    final report = GrowthReportBuilder.build(
      events: events,
      window: ReportWindow.of(ReportPeriod.month, _now),
      categoryNames: _names,
    );

    expect(_texts(report.good), contains('이번 달엔 거짓말이 한 번도 없었어요!'));
    expect(_texts(report.fix), ['약속을 아주 잘 지키고 있어요!']);
  });

  test('받침 없는 이름은 가로 받친다', () {
    final events = [_remove(1, '2026-09-10', 13)];

    final report = GrowthReportBuilder.build(
      events: events,
      window: ReportWindow.of(ReportPeriod.month, _now),
      categoryNames: _names,
    );

    expect(_texts(report.good), contains('이번 달엔 기타가 한 번도 없었어요!'));
  });

  test('고쳐나가야 할 점: 점수 높은 순, 지난주보다 줄었는지 늘었는지 함께 말한다', () {
    final events = [
      _remove(1, '2026-10-12', 11),
      _remove(2, '2026-10-13', 11),
      _remove(3, '2026-10-19', 11),
      _warn(4, '2026-10-21', 12),
    ];

    final report = GrowthReportBuilder.build(
      events: events,
      window: ReportWindow.of(ReportPeriod.week, _now),
      categoryNames: _names,
    );

    // 시간대(19시 2번)가 가장 많이 겹쳐서 맨 위에 온다.
    expect(_texts(report.fix), [
      '주로 저녁 7~8시에 있었어요',
      '게임 시간 약속 · 1번 · 지난주보다 줄었어요',
      '거짓말 · 1번 · 지난주보다 늘었어요',
    ]);
    expect(report.fix[1].tone, ReportTone.good);
    expect(report.fix[2].tone, ReportTone.warn);
  });

  test('같은 시간대에 두 번 이상 있었으면 시간대를 말한다', () {
    final events = [
      _remove(1, '2026-10-19', 11, hour: 19),
      _remove(2, '2026-10-20', 11, hour: 19),
      _remove(3, '2026-10-21', 11, hour: 8),
    ];

    final report = GrowthReportBuilder.build(
      events: events,
      window: ReportWindow.of(ReportPeriod.week, _now),
      categoryNames: _names,
    );

    expect(_texts(report.fix), contains('주로 저녁 7~8시에 있었어요'));
  });

  test('다음 약속은 이번 기간에서 가장 최근 메모를 쓴다', () {
    final events = [
      _remove(1, '2026-10-19', 11, promise: '알람 울리면 끄기'),
      _remove(2, '2026-10-21', 11, promise: '타이머 맞추기'),
      _remove(3, '2026-10-22', 12),
    ];

    final report = GrowthReportBuilder.build(
      events: events,
      window: ReportWindow.of(ReportPeriod.week, _now),
      categoryNames: _names,
    );

    expect(report.nextPromise, '타이머 맞추기');
  });

  test('전체 기간에는 비교 문장이 없다', () {
    final events = [
      _earn(1, '2026-01-03', 1),
      _earn(2, '2026-10-03', 1),
      _remove(3, '2026-01-04', 11),
    ];

    final report = GrowthReportBuilder.build(
      events: events,
      window: ReportWindow.of(ReportPeriod.all, _now),
      categoryNames: _names,
    );

    final all = [..._texts(report.good), ..._texts(report.fix)].join(' ');
    expect(all, isNot(contains('지난')));
    expect(all, isNot(contains('늘었어요')));
    expect(all, isNot(contains('줄었어요')));
    expect(report.praiseCount, 2);
  });

  test('기록이 하나도 없으면 격려 한 줄만 나온다', () {
    final report = GrowthReportBuilder.build(
      events: const [],
      window: ReportWindow.of(ReportPeriod.week, _now),
      categoryNames: _names,
    );

    expect(_texts(report.good), ['차근차근 함께 모아 봐요!']);
    expect(_texts(report.fix), ['약속을 아주 잘 지키고 있어요!']);
    expect(report.nextPromise, isNull);
  });
}
