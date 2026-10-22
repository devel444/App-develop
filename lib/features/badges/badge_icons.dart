import 'package:flutter/material.dart';

/// 배지 데이터의 iconKey를 그림으로 바꾼다. 모르는 키는 기본 메달 그림.
IconData badgeIconOf(String iconKey) {
  return switch (iconKey) {
    'star' => Icons.star_rounded,
    'flag' => Icons.flag_rounded,
    'crown' => Icons.workspace_premium_rounded,
    'book' => Icons.menu_book_rounded,
    'heart' => Icons.favorite_rounded,
    'bolt' => Icons.bolt_rounded,
    'gift' => Icons.card_giftcard_rounded,
    'trophy' => Icons.emoji_events_rounded,
    _ => Icons.military_tech_rounded,
  };
}

/// 메달 안 그림 색 (금색 위에 올라가는 짙은 갈색).
const badgeMedalIconColor = Color(0xFF8A5A00);
