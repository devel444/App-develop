import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sticker_world/core/assets/asset_resolver.dart';
import 'package:sticker_world/core/audio/sound_player.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/jelly_button.dart';
import 'package:sticker_world/core/widgets/outlined_text.dart';
import 'package:sticker_world/core/widgets/pattern_background.dart';
import 'package:sticker_world/core/widgets/pill_row.dart';
import 'package:sticker_world/core/widgets/screen_frame.dart';
import 'package:sticker_world/core/widgets/white_frame_card.dart';
import 'package:sticker_world/data/providers.dart';
import 'package:sticker_world/features/stamp/stamp_widgets.dart';

/// 한 칸: 파일 이름, 쓰이는 곳, 아직 재생·표시 코드가 없는지, 기본 상태 문구.
class CustomSlot {
  const CustomSlot(
    this.fileName,
    this.usedFor, {
    this.comingSoon = false,
    this.fallback = '기본 그림을 쓰고 있어요',
  });

  final String fileName;
  final String usedFor;

  /// 이 파일을 실제로 재생·표시하는 코드가 아직 없을 때 true.
  final bool comingSoon;

  /// 파일이 없을 때 보여 줄 문구.
  final String fallback;
}

/// 개인용 파일 목록. 이름은 PLAN.md 9장 표를 따르고, 지금 연결된 것만 "준비 중"이 아니다.
const customSlots = [
  CustomSlot('character.png', '홈 가운데 큰 캐릭터 (사진첩에서도 고를 수 있어요)'),
  CustomSlot('sfx_jump.mp3', '캐릭터를 누르면 나는 점프 소리', fallback: '기본 소리를 쓰고 있어요'),
  CustomSlot('sfx_coin.mp3', '배지를 누르면 나는 동전 소리', fallback: '기본 소리를 쓰고 있어요'),
  CustomSlot('character_jump.png', '올클리어·스티커 받을 때 점프', comingSoon: true),
  CustomSlot('token.png', '맵 위 내 위치 토큰', comingSoon: true),
  CustomSlot('emblem.png', '빨간 띠 가운데 엠블럼', comingSoon: true),
  CustomSlot('castle.png', '홈 왼쪽 배경 성', comingSoon: true),
  CustomSlot('world1.png', '맵 1번 월드 배경', comingSoon: true),
  CustomSlot('world2.png', '맵 2번 월드 배경', comingSoon: true),
  CustomSlot('world3.png', '맵 3번 월드 배경', comingSoon: true),
  CustomSlot('world4.png', '맵 4번 월드 배경', comingSoon: true),
  CustomSlot('world5.png', '맵 5번 월드 배경', comingSoon: true),
  CustomSlot('sfx_stamp.mp3', '도장 쿵 소리', comingSoon: true),
  CustomSlot('sfx_remove.mp3', '스티커 빼기 소리', comingSoon: true),
  CustomSlot('sfx_clear.mp3', '올클리어 소리', comingSoon: true),
  CustomSlot('sfx_powerup.mp3', '배지 획득 소리', comingSoon: true),
  CustomSlot('sfx_tap.mp3', '버튼 터치 소리', comingSoon: true),
  CustomSlot('celebrate.json', '올클리어 캐릭터 움직임 (Lottie)', comingSoon: true),
];

/// 캐릭터·꾸미기: 사진 고르기, 효과음 켜기·끄기, 개인용 파일 상태를 보여 준다.
class CustomizeScreen extends ConsumerStatefulWidget {
  const CustomizeScreen({super.key});

  @override
  ConsumerState<CustomizeScreen> createState() => _CustomizeScreenState();
}

class _CustomizeScreenState extends ConsumerState<CustomizeScreen> {
  bool? _soundOn;
  bool _busy = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _loadSound();
  }

  Future<void> _loadSound() async {
    final on = await ref
        .read(settingsRepositoryProvider)
        .getInt('sound_on', fallback: 1);
    if (mounted) {
      setState(() => _soundOn = on == 1);
    }
  }

  Future<void> _setSound(bool on) async {
    setState(() => _soundOn = on);
    await ref.read(settingsRepositoryProvider).set('sound_on', on ? '1' : '0');
  }

  /// 사진첩에서 캐릭터 사진을 고르고, 앱 안 복사본을 설정에 적는다.
  Future<void> _pickCharacter() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 88,
    );
    if (picked == null) {
      return;
    }
    setState(() => _busy = true);
    final settings = ref.read(settingsRepositoryProvider);
    final store = await ref.read(mediaStoreProvider.future);
    final previous = await settings.get('character_photo');
    final saved = await store.saveCopy(picked.path, prefix: 'character');
    await settings.set('character_photo', saved);
    await store.deleteCopy(previous);
    ref.invalidate(characterPhotoProvider);
    if (mounted) {
      setState(() {
        _busy = false;
        _message = '캐릭터 사진을 바꿨어요. 홈에서 확인해 보세요.';
      });
    }
  }

  /// 기본 캐릭터로 되돌린다. 복사해 둔 사진은 지운다.
  Future<void> _resetCharacter() async {
    final settings = ref.read(settingsRepositoryProvider);
    final store = await ref.read(mediaStoreProvider.future);
    final previous = await settings.get('character_photo');
    await settings.set('character_photo', '');
    await store.deleteCopy(previous);
    ref.invalidate(characterPhotoProvider);
    if (mounted) {
      setState(() => _message = '기본 캐릭터로 되돌렸어요.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = ref.watch(characterPhotoProvider).value != null;

    return Stack(
      fit: StackFit.expand,
      children: [
        ScreenFrame(
          title: '캐릭터 · 꾸미기',
          color: AppColors.pink,
          pattern: BgPattern.dots,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            children: [
              WhiteFrameCard(
                headerTitle: '캐릭터 사진',
                headerColor: AppColors.pink,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '태블릿 사진첩에서 캐릭터로 쓸 사진을 골라요. 배경이 투명한 그림이면 더 예뻐요.',
                      style: TextStyle(
                        fontSize: 20,
                        height: 1.4,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 14),
                    JellyButton(
                      color: AppColors.gold,
                      height: 72,
                      semanticLabel: '캐릭터 사진 고르기',
                      onTap: _busy ? null : _pickCharacter,
                      child: const Center(
                        child: OutlinedText('사진 고르기', fontSize: 28),
                      ),
                    ),
                    if (hasPhoto) ...[
                      const SizedBox(height: 10),
                      JellyButton(
                        color: AppColors.white,
                        height: 64,
                        semanticLabel: '기본 캐릭터로 되돌리기',
                        onTap: _busy ? null : _resetCharacter,
                        child: const Center(
                          child: Text(
                            '기본 캐릭터로 되돌리기',
                            style: TextStyle(
                              fontSize: 22,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (_message != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _message!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          color: AppColors.misdeed,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              WhiteFrameCard(
                headerTitle: '효과음',
                headerColor: AppColors.pink,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PillRow(
                      accent: AppColors.yellow,
                      leading: const Icon(
                        Icons.volume_up_rounded,
                        color: AppColors.ink,
                      ),
                      title: '효과음 켜기',
                      subtitle: '캐릭터 누르기, 배지 누르기',
                      trailing: Switch(
                        value: _soundOn ?? true,
                        onChanged: _soundOn == null ? null : _setSound,
                      ),
                      onTap: _soundOn == null
                          ? null
                          : () => _setSound(!_soundOn!),
                    ),
                    const SizedBox(height: 12),
                    JellyButton(
                      color: AppColors.white,
                      height: 64,
                      semanticLabel: '점프 소리 들어 보기',
                      onTap: () => ref.read(soundPlayerProvider).play(Sfx.jump),
                      child: const Center(
                        child: Text(
                          '점프 소리 들어 보기',
                          style: TextStyle(fontSize: 22, color: AppColors.ink),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    JellyButton(
                      color: AppColors.white,
                      height: 64,
                      semanticLabel: '동전 소리 들어 보기',
                      onTap: () => ref.read(soundPlayerProvider).play(Sfx.coin),
                      child: const Center(
                        child: Text(
                          '동전 소리 들어 보기',
                          style: TextStyle(fontSize: 22, color: AppColors.ink),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const WhiteFrameCard(
                headerTitle: '직접 넣는 파일',
                headerColor: AppColors.pink,
                child: Text(
                  'PC의 assets/custom 폴더에 같은 이름으로 넣고 앱을 다시 빌드하면 그 파일이 쓰여요. '
                  '아래에서 "적용 중"이 보이면 성공이에요. 소리는 mp3 또는 wav를 쓸 수 있어요.',
                  style: TextStyle(
                    fontSize: 20,
                    height: 1.4,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              for (final slot in customSlots)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SlotRow(slot: slot),
                ),
            ],
          ),
        ),
        const BackFab(),
      ],
    );
  }
}

class _SlotRow extends StatelessWidget {
  const _SlotRow({required this.slot});

  final CustomSlot slot;

  @override
  Widget build(BuildContext context) {
    final applied = AssetResolver.custom(slot.fileName) != null;
    final status = switch ((applied, slot.comingSoon)) {
      (true, true) => '파일은 있어요 · 재생 준비 중',
      (true, false) => '적용 중',
      (false, true) => '준비 중',
      (false, false) => slot.fallback,
    };
    return PillRow(
      accent: applied ? AppColors.green : AppColors.white,
      leading: Icon(
        applied ? Icons.check_circle_rounded : Icons.brush_rounded,
        color: AppColors.ink,
      ),
      title: slot.fileName,
      subtitle: '${slot.usedFor} · $status',
    );
  }
}
