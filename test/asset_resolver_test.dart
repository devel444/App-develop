import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/core/assets/asset_resolver.dart';

void main() {
  tearDown(() => AssetResolver.debugSetCustomAssets({}));

  test('커스텀 파일이 없으면 null이라서 기본 그림을 쓴다', () {
    AssetResolver.debugSetCustomAssets({});

    expect(AssetResolver.custom('character.png'), isNull);
  });

  test('커스텀 파일이 있으면 그 에셋 경로를 돌려준다', () {
    AssetResolver.debugSetCustomAssets({'assets/custom/character.png'});

    expect(
      AssetResolver.custom('character.png'),
      'assets/custom/character.png',
    );
    expect(AssetResolver.custom('emblem.png'), isNull);
  });
}
