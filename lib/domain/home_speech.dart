import 'dart:math';

/// 홈 캐릭터가 말풍선으로 하는 말. 홈을 열 때마다 한 줄을 고른다 (아이 눈높이, 짧게).
const homeSpeechLines = [
  '오늘도 만나서 반가워!',
  '스티커 하나하나가 내 보물이야!',
  '잘하고 있어, 멋져!',
  '오늘 할 일도 같이 해볼까?',
  '맵에서 다음 칸이 기다리고 있어!',
  '칭찬 스티커 모으면 선물이 와!',
  '열쇠를 모아서 선물 가게에 가자!',
  '너 덕분에 오늘도 신나!',
  '웃는 얼굴이 제일 예뻐!',
  '같이 스티커 월드를 달려 보자!',
];

/// 말풍선에 쓸 한 줄을 고른다.
String pickHomeSpeech(Random random) {
  return homeSpeechLines[random.nextInt(homeSpeechLines.length)];
}
