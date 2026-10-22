import 'package:audioplayers/audioplayers.dart';
import 'package:sticker_world/core/assets/asset_resolver.dart';

/// 짧은 효과음 종류. 이름은 assets/custom 의 파일 이름과 맞춘다 (sfx_jump.mp3, sfx_coin.mp3).
enum Sfx { jump, coin }

/// 실제로 소리를 내는 쪽. 테스트에서는 기록만 하는 가짜로 바꾼다.
abstract interface class SfxOutput {
  /// [assetPath]는 assets/ 아래 경로다 (예: default/sfx_coin.wav).
  Future<void> playAsset(String assetPath);

  Future<void> dispose();
}

class AudioPlayerOutput implements SfxOutput {
  final AudioPlayer _player = AudioPlayer();

  @override
  Future<void> playAsset(String assetPath) async {
    await _player.stop();
    await _player.play(AssetSource(assetPath));
  }

  @override
  Future<void> dispose() => _player.dispose();
}

/// 효과음 재생. 소리 켜기가 꺼져 있으면 아무 소리도 내지 않는다.
class SoundPlayer {
  SoundPlayer(this._output, {required this.isOn});

  final SfxOutput _output;
  final Future<bool> Function() isOn;

  static const _names = {Sfx.jump: 'sfx_jump', Sfx.coin: 'sfx_coin'};

  /// 개인용 파일(mp3 우선, 없으면 wav)이 있으면 그 경로, 없으면 기본 효과음 경로.
  static String pathFor(Sfx sfx) {
    final name = _names[sfx]!;
    final custom =
        AssetResolver.custom('$name.mp3') ?? AssetResolver.custom('$name.wav');
    if (custom != null) {
      return custom.replaceFirst('assets/', '');
    }
    return 'default/$name.wav';
  }

  Future<void> play(Sfx sfx) async {
    if (!await isOn()) {
      return;
    }
    try {
      await _output.playAsset(pathFor(sfx));
    } on Object {
      // 소리가 안 나도 놀이는 계속돼야 한다. 기기 오류는 무시한다.
    }
  }
}
