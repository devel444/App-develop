import 'package:flutter/material.dart';

/// 루틴 아이콘. 데이터에는 키 이름만 저장한다.
const routineIcons = <String, IconData>{
  'brush': Icons.brush_rounded,
  'bed': Icons.bed_rounded,
  'book': Icons.menu_book_rounded,
  'run': Icons.directions_run_rounded,
  'pencil': Icons.edit_note_rounded,
  'music': Icons.music_note_rounded,
  'school': Icons.school_rounded,
  'star': Icons.star_rounded,
};

IconData routineIcon(String key) => routineIcons[key] ?? Icons.star_rounded;

/// 루틴 종류. 키, 이름, 설명.
const routineKinds = <(String, String, String)>[
  ('normal', '체크', '눌러서 체크해요'),
  ('parent_check', '엄마·아빠 확인', '엄마·아빠 비밀번호 후 체크'),
  ('duolingo', '듀오링고', '듀오링고를 하면 체크돼요'),
  ('diary', '일기', '일기를 저장하면 체크돼요'),
  ('timer', '타이머', '정해진 시간 동안 해요'),
];

/// 시간대. 키, 이름.
const routineSlots = <(String, String)>[
  ('morning', '아침'),
  ('afternoon', '오후'),
  ('evening', '저녁'),
];

const timerChoices = [2, 5, 10, 20, 30];
