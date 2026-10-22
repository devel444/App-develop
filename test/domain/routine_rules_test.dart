import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/domain/routine_rules.dart';

void main() {
  // 2026-10-22 은 목요일
  final thursday = DateTime(2026, 10, 22);

  test('요일 표시: 매일, 평일, 주말, 골라 쓴 요일', () {
    expect(RoutineDays.label(RoutineDays.all), '매일');
    expect(RoutineDays.label(RoutineDays.weekdays), '평일');
    expect(RoutineDays.label(RoutineDays.weekend), '주말');
    expect(RoutineDays.label(2 | 8), '화·목');
    expect(RoutineDays.label(0), '요일 없음');
  });

  test('목요일 날짜는 목요일 비트에 들어간다', () {
    expect(RoutineDays.includes(RoutineDays.weekdays, thursday), isTrue);
    expect(RoutineDays.includes(RoutineDays.weekend, thursday), isFalse);
    expect(RoutineDays.includes(2 | 8, thursday), isTrue);
  });

  test('요일 칩을 누르면 켜지고 꺼진다', () {
    final mask = RoutineDays.toggle(0, 3); // 목
    expect(mask, 8);
    expect(RoutineDays.toggle(mask, 3), 0);
  });

  group('연속 클리어', () {
    test('오늘까지 3일 연속이면 3', () {
      final dates = {'2026-10-20', '2026-10-21', '2026-10-22'};
      expect(clearStreak(dates, thursday), 3);
    });

    test('오늘을 아직 못 끝냈으면 어제까지 센다', () {
      final dates = {'2026-10-20', '2026-10-21'};
      expect(clearStreak(dates, thursday), 2);
    });

    test('중간에 빠지면 거기서 끊긴다', () {
      final dates = {'2026-10-19', '2026-10-21', '2026-10-22'};
      expect(clearStreak(dates, thursday), 2);
    });

    test('한 번도 못 했으면 0', () {
      expect(clearStreak({}, thursday), 0);
    });
  });
}
