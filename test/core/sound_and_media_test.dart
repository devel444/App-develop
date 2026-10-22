import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/core/assets/asset_resolver.dart';
import 'package:sticker_world/core/audio/sound_player.dart';
import 'package:sticker_world/core/media/media_store.dart';
import 'package:sticker_world/data/repositories/reward_repository.dart';

import '../support/test_database.dart';

/// 재생 요청만 기록하는 가짜 소리 출력.
class _RecordingOutput implements SfxOutput {
  final played = <String>[];

  @override
  Future<void> playAsset(String assetPath) async => played.add(assetPath);

  @override
  Future<void> dispose() async {}
}

void main() {
  tearDown(() => AssetResolver.debugSetCustomAssets({}));

  group('효과음', () {
    test('개인용 파일이 없으면 기본 효과음을 낸다', () async {
      final output = _RecordingOutput();
      final player = SoundPlayer(output, isOn: () async => true);

      await player.play(Sfx.coin);
      await player.play(Sfx.jump);

      expect(output.played, ['default/sfx_coin.wav', 'default/sfx_jump.wav']);
    });

    test('같은 이름의 개인용 파일이 있으면 그 파일을 쓴다 (mp3 우선)', () async {
      AssetResolver.debugSetCustomAssets({
        'assets/custom/sfx_jump.mp3',
        'assets/custom/sfx_coin.wav',
        'assets/custom/sfx_coin.mp3',
      });
      final output = _RecordingOutput();
      final player = SoundPlayer(output, isOn: () async => true);

      await player.play(Sfx.jump);
      await player.play(Sfx.coin);

      expect(output.played, ['custom/sfx_jump.mp3', 'custom/sfx_coin.mp3']);
    });

    test('소리 켜기가 꺼져 있으면 아무 소리도 내지 않는다', () async {
      final output = _RecordingOutput();
      final player = SoundPlayer(output, isOn: () async => false);

      await player.play(Sfx.coin);

      expect(output.played, isEmpty);
    });

    test('기기 오류가 나도 놀이는 멈추지 않는다', () async {
      final output = _ThrowingOutput();
      final player = SoundPlayer(output, isOn: () async => true);

      await expectLater(player.play(Sfx.jump), completes);
    });
  });

  group('사진 복사본', () {
    late Directory dir;

    setUp(() {
      dir = Directory.systemTemp.createTempSync('media_store_test');
    });

    tearDown(() => dir.deleteSync(recursive: true));

    test('고른 사진을 앱 안으로 복사하고, 지우면 복사본만 사라진다', () async {
      final source = File('${dir.path}/picked.png')..writeAsStringSync('그림');
      final store = MediaStore(
        Directory('${dir.path}/media'),
        clock: () => DateTime(2026, 10, 22, 9),
      );

      final saved = await store.saveCopy(source.path, prefix: 'gift');

      expect(saved, endsWith('.png'));
      expect(File(saved).readAsStringSync(), '그림');
      expect(source.existsSync(), isTrue, reason: '원본은 그대로 둔다');

      await store.deleteCopy(saved);
      expect(File(saved).existsSync(), isFalse);
      await store.deleteCopy(null);
    });
  });

  test('선물 사진 경로는 저장하고 다시 빼낼 수 있다', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repo = RewardRepository(db);
    final id = await repo.create(name: '아이스크림', cost: 20);

    await repo.setImagePath(id, '/app/media/gift_1.jpg');
    expect(
      (await repo.watchAll().first).single.imagePath,
      '/app/media/gift_1.jpg',
    );

    await repo.setImagePath(id, null);
    expect((await repo.watchAll().first).single.imagePath, isNull);
  });
}

class _ThrowingOutput implements SfxOutput {
  @override
  Future<void> playAsset(String assetPath) async {
    throw StateError('no audio device');
  }

  @override
  Future<void> dispose() async {}
}
