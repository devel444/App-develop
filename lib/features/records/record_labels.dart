/// 스티커 기록 한 줄 문구. 달력 상세와 일기의 오늘 칩에서 같이 쓴다.
String stickerRecordLabel({
  required String type,
  required int amount,
  required int? categoryId,
  required Map<int, String> names,
}) {
  final name = categoryId == null ? '올클리어' : (names[categoryId] ?? '');
  return switch (type) {
    'earn' => '$name +$amount',
    'bonus' => '보너스 +$amount',
    'remove' => '$name −${-amount}',
    'warn' => '$name 경고',
    'redeem' => '선물 교환',
    _ => name,
  };
}
