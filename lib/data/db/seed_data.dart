import 'package:flutter/material.dart' show Color;
import 'package:drift/drift.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/data/db/app_database.dart';

/// 처음 설치할 때 넣는 기본값 (PLAN.md 11장 P1: 카테고리·잘못 종류·문구·배지).
Future<void> seedDefaults(AppDatabase db) async {
  await db.batch((batch) {
    batch.insertAll(db.categories, [
      _category('praise', '공부', 'study', AppColors.categoryStudy, 0),
      _category('praise', '생활습관', 'life', AppColors.categoryLife, 1),
      _category('praise', '착한 일', 'kind', AppColors.categoryKind, 2),
      _category('praise', '운동', 'sport', AppColors.categorySport, 3),
      _category('praise', '기타', 'etc', Color(0xFF7A7A8C), 4),
      _category('misdeed', '게임 시간 약속', 'game', AppColors.misdeed, 0),
      _category('misdeed', '말다툼·싸움', 'fight', AppColors.misdeed, 1),
      _category('misdeed', '거짓말', 'lie', AppColors.misdeed, 2),
      _category('misdeed', '정리 안 함', 'tidy', AppColors.misdeed, 3),
      _category('misdeed', '고운 말 안 씀', 'words', AppColors.misdeed, 4),
      _category('misdeed', '기타', 'etc', AppColors.misdeed, 5),
    ]);

    batch.insertAll(db.praiseTemplates, [
      for (final (index, text) in _praiseTexts.indexed)
        PraiseTemplatesCompanion.insert(content: text, sortOrder: Value(index)),
    ]);

    batch.insertAll(db.badges, _badgeSeeds);

    batch.insertAll(db.appSettings, [
      for (final entry in _settingDefaults.entries)
        AppSettingsCompanion.insert(key: entry.key, value: entry.value),
    ]);
  });
}

CategoriesCompanion _category(
  String kind,
  String name,
  String iconKey,
  Color color,
  int sortOrder,
) {
  return CategoriesCompanion.insert(
    kind: kind,
    name: name,
    iconKey: iconKey,
    colorValue: color.toARGB32(),
    sortOrder: Value(sortOrder),
  );
}

const _praiseTexts = [
  '받아쓰기 100점!',
  '스스로 했어요',
  '동생을 도와줬어요',
  '약속을 지켰어요',
  '고마워요!',
  '정말 멋져요',
];

final _badgeSeeds = [
  _badge('first_sticker', '스티커', '첫 스티커', 'star', 'total_earned>=1'),
  _badge('world_1', '스티커', '월드 1 도착', 'flag', 'balance>=20'),
  _badge('world_2', '스티커', '월드 2 도착', 'flag', 'balance>=40'),
  _badge('world_3', '스티커', '월드 3 도착', 'flag', 'balance>=60'),
  _badge('world_4', '스티커', '월드 4 도착', 'flag', 'balance>=80'),
  _badge('world_5', '스티커', '100개 달성', 'crown', 'balance>=100'),
  _badge('study_1', '스티커', '공부왕 I', 'book', 'study>=10'),
  _badge('study_2', '스티커', '공부왕 II', 'book', 'study>=30'),
  _badge('study_3', '스티커', '공부왕 III', 'book', 'study>=60'),
  _badge('kind_5', '스티커', '착한 마음', 'heart', 'kind>=5'),
  _badge('sport_5', '스티커', '운동 시작', 'bolt', 'sport>=5'),
  _badge('first_gift', '선물', '첫 선물', 'gift', 'redeemed>=1'),
  _badge('patient_100', '선물', '참을성 왕', 'trophy', 'redeemed_cost>=100'),
  _badge('first_clear', '할 일', '첫 올클리어', 'flag', 'clear_days>=1'),
  _badge('clear_3', '할 일', '3일 연속 클리어', 'flag', 'clear_streak>=3'),
  _badge('clear_7', '할 일', '7일 연속 클리어', 'flag', 'clear_streak>=7'),
  _badge('clear_30', '할 일', '30일 연속 클리어', 'flag', 'clear_streak>=30'),
  _badge('duo_7', '듀오링고', '듀오링고 7일', 'bolt', 'duo_streak>=7'),
  _badge('duo_30', '듀오링고', '듀오링고 30일', 'bolt', 'duo_streak>=30'),
  _badge('duo_100', '듀오링고', '듀오링고 100일', 'bolt', 'duo_streak>=100'),
  _badge('diary_1', '일기', '일기 1편', 'book', 'diary>=1'),
  _badge('diary_10', '일기', '일기 10편', 'book', 'diary>=10'),
  _badge('diary_30', '일기', '일기 30편', 'book', 'diary>=30'),
  _badge('promise_keeper', '약속', '약속 지킴이', 'heart', 'month_remove_zero'),
  _badge(
    'hidden_five_today',
    '숨김',
    '하루 다섯 개',
    'star',
    'today_earn>=5',
    hidden: true,
  ),
];

BadgesCompanion _badge(
  String code,
  String category,
  String name,
  String iconKey,
  String rule, {
  bool hidden = false,
}) {
  return BadgesCompanion.insert(
    code: code,
    category: category,
    name: name,
    iconKey: iconKey,
    colorValue: AppColors.gold.toARGB32(),
    ruleJson: '{"rule": "$rule"}',
    isHidden: Value(hidden),
  );
}

/// 설정 기본값. 잠금·PIN 관련 키는 PinService가 채운다.
const _settingDefaults = {
  'max_stickers': '100',
  'undo_seconds': '10',
  'sound_on': '1',
  'tts_on': '1',
  'all_clear_bonus': 'pending',
  'bonus_amount': '1',
  'yellow_card_on': '0',
  'usage_min_minutes': '5',
  'pin_failed': '0',
  'pin_locked_until': '0',
  'recovery_failed': '0',
  'recovery_locked_until': '0',
};
