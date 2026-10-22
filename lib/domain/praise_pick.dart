import 'dart:math';

/// 칭찬 문구 팝업을 이번에 띄울지 정하고, 띄울 문구를 고른다.
/// 절반쯤 띄운다. 문구가 없으면 띄우지 않는다.
String? pickPraise(List<String> texts, Random random) {
  if (texts.isEmpty || !random.nextBool()) {
    return null;
  }
  return texts[random.nextInt(texts.length)];
}
