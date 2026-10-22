import 'package:flutter/material.dart';

/// 날씨 선택지 (저장 값, 이름, 아이콘).
const diaryWeathers = <(String, String, IconData)>[
  ('sunny', '맑음', Icons.wb_sunny_rounded),
  ('cloudy', '흐림', Icons.cloud_rounded),
  ('rain', '비', Icons.grain_rounded),
  ('snow', '눈', Icons.ac_unit_rounded),
];

/// 기분 선택지 (저장 값 1~5, 이름, 아이콘). 5가 가장 좋은 기분.
const diaryMoods = <(int, String, IconData)>[
  (5, '최고', Icons.sentiment_very_satisfied_rounded),
  (4, '좋아', Icons.sentiment_satisfied_rounded),
  (3, '보통', Icons.sentiment_neutral_rounded),
  (2, '속상', Icons.sentiment_dissatisfied_rounded),
  (1, '화나', Icons.sentiment_very_dissatisfied_rounded),
];

IconData weatherIcon(String? key) {
  for (final w in diaryWeathers) {
    if (w.$1 == key) {
      return w.$3;
    }
  }
  return Icons.wb_cloudy_outlined;
}

IconData moodIcon(int? mood) {
  for (final m in diaryMoods) {
    if (m.$1 == mood) {
      return m.$3;
    }
  }
  return Icons.sentiment_neutral_rounded;
}

String weatherName(String? key) {
  for (final w in diaryWeathers) {
    if (w.$1 == key) {
      return w.$2;
    }
  }
  return '';
}
