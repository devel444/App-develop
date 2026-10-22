import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/domain/daily_progress.dart';
import 'package:sticker_world/domain/home_greeting.dart';
import 'package:sticker_world/domain/praise_pick.dart';
import 'package:sticker_world/domain/weekly_report_banner.dart';

void main() {
  group('시간대 인사말', () {
    test('아침, 낮, 저녁, 밤마다 다른 말을 한다', () {
      expect(greetingFor(DateTime(2026, 10, 22, 8)), contains('좋은 아침'));
      expect(greetingFor(DateTime(2026, 10, 22, 14)), contains('오후'));
      expect(greetingFor(DateTime(2026, 10, 22, 19)), contains('저녁'));
      expect(greetingFor(DateTime(2026, 10, 22, 23)), contains('잘 시간'));
      expect(greetingFor(DateTime(2026, 10, 22, 3)), contains('잘 시간'));
    });
  });

  group('오늘 할 일 진행률', () {
    // 2026-10-22 목요일
    final now = DateTime(2026, 10, 22, 9);
    const thursday = 8; // 목 = 비트 8

    test('오늘 해야 하는 켜진 루틴만 센다', () {
      final progress = DailyProgress.count(
        routines: [
          (id: 1, daysMask: 127, isActive: true),
          (id: 2, daysMask: 127, isActive: true),
          (id: 3, daysMask: 1, isActive: true), // 월요일만
          (id: 4, daysMask: 127, isActive: false), // 숨김
        ],
        loggedIds: {1},
        now: now,
      );

      expect(progress.total, 2);
      expect(progress.done, 1);
      expect(progress.left, 1);
      expect(progress.fraction, 0.5);
      expect(progress.finished, isFalse);
    });

    test('다 끝내면 finished, 할 일이 없으면 0', () {
      final done = DailyProgress.count(
        routines: [(id: 1, daysMask: thursday, isActive: true)],
        loggedIds: {1},
        now: now,
      );
      final none = DailyProgress.count(
        routines: const [],
        loggedIds: const {},
        now: now,
      );

      expect(done.finished, isTrue);
      expect(none.fraction, 0);
      expect(none.finished, isFalse);
    });
  });

  group('일요일 저녁 리포트 안내', () {
    test('일요일 18시 이후에, 이번 주를 아직 안 닫았을 때만 띄운다', () {
      final sundayEvening = DateTime(2026, 10, 25, 19);
      final sundayMorning = DateTime(2026, 10, 25, 9);
      final monday = DateTime(2026, 10, 26, 19);

      expect(
        shouldShowWeeklyReport(now: sundayEvening, seenWeekKey: null),
        isTrue,
      );
      expect(
        shouldShowWeeklyReport(now: sundayMorning, seenWeekKey: null),
        isFalse,
      );
      expect(shouldShowWeeklyReport(now: monday, seenWeekKey: null), isFalse);
    });

    test('닫은 주에는 다시 뜨지 않는다', () {
      final sundayEvening = DateTime(2026, 10, 25, 19);

      expect(
        shouldShowWeeklyReport(now: sundayEvening, seenWeekKey: '2026-10-19'),
        isFalse,
      );
      expect(
        shouldShowWeeklyReport(now: sundayEvening, seenWeekKey: '2026-10-12'),
        isTrue,
      );
    });
  });

  group('칭찬 문구 팝업', () {
    test('문구가 없으면 띄우지 않는다', () {
      expect(pickPraise(const [], Random(1)), isNull);
    });

    test('띄울 때는 목록 안의 문구를 고르고, 절반쯤만 띄운다', () {
      const texts = ['받아쓰기 100점!', '고마워요!'];
      final random = Random(7);
      var shown = 0;
      for (var i = 0; i < 400; i++) {
        final pick = pickPraise(texts, random);
        if (pick != null) {
          expect(texts, contains(pick));
          shown++;
        }
      }
      expect(shown, greaterThan(140));
      expect(shown, lessThan(260));
    });
  });
}
