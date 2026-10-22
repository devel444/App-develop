/// 시간대에 맞는 인사말. 아침·낮·저녁·밤 순서로 나눈다.
String greetingFor(DateTime now) {
  final hour = now.hour;
  if (hour >= 5 && hour < 12) {
    return '좋은 아침! 오늘도 모아 볼까?';
  }
  if (hour >= 12 && hour < 18) {
    return '안녕! 오후에도 반짝반짝 모아요';
  }
  if (hour >= 18 && hour < 22) {
    return '좋은 저녁이에요! 오늘 하루도 멋졌어요';
  }
  return '잘 시간이에요. 내일 또 만나요!';
}
