import 'dart:convert';
import 'dart:math';

import 'package:sticker_world/core/time/local_date.dart';
import 'package:sticker_world/domain/growth_report.dart';
import 'package:sticker_world/domain/routine_rules.dart' as routine;

/// 배지 조건에 쓰는 숫자 모음. 장부·할 일·일기·듀오링고 기록에서 한 번에 센다.
class BadgeStats {
  const BadgeStats({
    required this.totalEarned,
    required this.balance,
    required this.categoryCounts,
    required this.redeemCount,
    required this.maxRedeemCost,
    required this.clearDays,
    required this.clearStreak,
    required this.duoStreak,
    required this.diaryCount,
    required this.monthRemoveZero,
    required this.todayEarn,
  });

  /// 되돌린 기록을 뺀 값으로 계산한다.
  factory BadgeStats.from({
    required List<GrowthEvent> events,
    required Set<String> clearDates,
    required int diaryCount,
    required int? duoStreak,
    required DateTime? createdAt,
    required Map<int, String> categoryNames,
    required DateTime now,
  }) {
    final today = localDateKey(now);
    final lastMonth = ReportWindow.of(ReportPeriod.month, now).previous!;

    var totalEarned = 0;
    var balance = 0;
    var redeemCount = 0;
    var maxRedeemCost = 0;
    var todayEarn = 0;
    var lastMonthRemoves = 0;
    var lastMonthEarns = 0;
    final categoryCounts = <String, int>{};

    for (final event in liveEventsOf(events)) {
      // 받기·보너스는 +, 빼기·교환은 -. 경고는 0이라 그대로 더해도 된다.
      balance += event.amount;
      switch (event.type) {
        case 'earn':
          totalEarned += event.amount;
          if (event.localDate == today) {
            todayEarn += event.amount;
          }
          final name = categoryNames[event.categoryId];
          if (name != null) {
            categoryCounts.update(name, (n) => n + 1, ifAbsent: () => 1);
          }
          if (lastMonth.contains(event.localDate)) {
            lastMonthEarns++;
          }
        case 'remove':
          if (lastMonth.contains(event.localDate)) {
            lastMonthRemoves++;
          }
        case 'redeem':
          redeemCount++;
          maxRedeemCost = max(maxRedeemCost, -event.amount);
      }
    }

    // 약속 지킴이: 지난달 내내 있었고, 지난달에 받은 게 있는데 빼기는 0번.
    final existedLastMonth =
        createdAt != null &&
        localDateKey(createdAt).compareTo(lastMonth.start) <= 0;

    return BadgeStats(
      totalEarned: totalEarned,
      balance: balance,
      categoryCounts: categoryCounts,
      redeemCount: redeemCount,
      maxRedeemCost: maxRedeemCost,
      clearDays: clearDates.length,
      clearStreak: routine.clearStreak(clearDates, now),
      duoStreak: duoStreak,
      diaryCount: diaryCount,
      monthRemoveZero:
          existedLastMonth && lastMonthRemoves == 0 && lastMonthEarns > 0,
      todayEarn: todayEarn,
    );
  }

  final int totalEarned;
  final int balance;

  /// 칭찬 카테고리 이름 → 받은 횟수.
  final Map<String, int> categoryCounts;
  final int redeemCount;
  final int maxRedeemCost;
  final int clearDays;
  final int clearStreak;
  final int? duoStreak;
  final int diaryCount;
  final bool monthRemoveZero;
  final int todayEarn;

  /// 조건 이름(metric)의 현재 값. 모르는 이름은 0이다.
  int value(String metric) {
    final categoryName = _categoryOfMetric[metric];
    if (categoryName != null) {
      return categoryCounts[categoryName] ?? 0;
    }
    return switch (metric) {
      'total_earned' => totalEarned,
      'balance' => balance,
      'redeemed' => redeemCount,
      'redeemed_cost' => maxRedeemCost,
      'clear_days' => clearDays,
      'clear_streak' => clearStreak,
      'duo_streak' => duoStreak ?? 0,
      'diary' => diaryCount,
      'month_remove_zero' => monthRemoveZero ? 1 : 0,
      'today_earn' => todayEarn,
      _ => 0,
    };
  }

  /// 공부·착한 일·운동은 시드 칭찬 카테고리 이름과 맞춘다.
  static const _categoryOfMetric = {
    'study': '공부',
    'kind': '착한 일',
    'sport': '운동',
  };
}

/// 배지 조건 한 줄. 장부에는 `{"rule": "study>=10"}` 꼴로 저장돼 있다.
class BadgeRule {
  const BadgeRule(this.metric, this.target);

  /// 'month_remove_zero' 는 목표 1 (예/아니오)로 본다.
  static const monthRemoveZero = 'month_remove_zero';

  final String metric;
  final int target;

  /// 읽을 수 없는 조건이면 null (그 배지는 판정하지 않는다).
  static BadgeRule? tryParse(String ruleJson) {
    final String raw;
    try {
      final decoded = jsonDecode(ruleJson);
      if (decoded is! Map || decoded['rule'] is! String) {
        return null;
      }
      raw = (decoded['rule'] as String).trim();
    } on FormatException {
      return null;
    }
    if (raw == monthRemoveZero) {
      return const BadgeRule(monthRemoveZero, 1);
    }
    final match = RegExp(r'^(\w+)>=(\d+)$').firstMatch(raw);
    if (match == null) {
      return null;
    }
    return BadgeRule(match.group(1)!, int.parse(match.group(2)!));
  }

  bool isMet(BadgeStats stats) => stats.value(metric) >= target;

  /// 아이에게 보이는 진행도 힌트. 예: '공부 칭찬 18 / 30'.
  String hint(BadgeStats? stats) {
    if (metric == monthRemoveZero) {
      return '지난달 빼기 0번이면 받아요';
    }
    final current = min(stats?.value(metric) ?? 0, target);
    return '${_labels[metric] ?? ''} $current / $target';
  }

  static const _labels = {
    'total_earned': '받은 스티커',
    'balance': '모은 스티커',
    'study': '공부 칭찬',
    'kind': '착한 일',
    'sport': '운동 칭찬',
    'redeemed': '선물 교환',
    'redeemed_cost': '비싼 선물',
    'clear_days': '올클리어 날',
    'clear_streak': '연속 올클리어',
    'duo_streak': '듀오링고 연속',
    'diary': '일기',
    'today_earn': '오늘 받은 스티커',
  };
}
