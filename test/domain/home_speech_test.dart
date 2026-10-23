import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/domain/home_speech.dart';

void main() {
  test('말풍선 문구는 목록 안에서만 고른다', () {
    final random = Random(1);
    for (var i = 0; i < 50; i++) {
      expect(homeSpeechLines, contains(pickHomeSpeech(random)));
    }
  });

  test('같은 난수 순서면 같은 문구가 나온다 (테스트 가능하게)', () {
    expect(pickHomeSpeech(Random(7)), pickHomeSpeech(Random(7)));
  });
}
