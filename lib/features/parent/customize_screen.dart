import 'package:flutter/material.dart';
import 'package:sticker_world/core/assets/asset_resolver.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/pattern_background.dart';
import 'package:sticker_world/core/widgets/pill_row.dart';
import 'package:sticker_world/core/widgets/screen_frame.dart';
import 'package:sticker_world/core/widgets/white_frame_card.dart';
import 'package:sticker_world/features/stamp/stamp_widgets.dart';

/// 한 칸: 파일 이름, 쓰이는 곳, 그림·소리가 이미 연결됐는지.
class CustomSlot {
  const CustomSlot(this.fileName, this.usedFor, {this.comingSoon = false});

  final String fileName;
  final String usedFor;

  /// 이 파일을 실제로 재생·표시하는 코드가 아직 없을 때 true.
  final bool comingSoon;
}

/// PLAN.md 9장 표와 같은 순서. badge_*.png 는 배지 코드별로 따로 붙인다.
const customSlots = [
  CustomSlot('character.png', '홈 가운데 큰 캐릭터'),
  CustomSlot('character_jump.png', '올클리어·스티커 받을 때 점프', comingSoon: true),
  CustomSlot('token.png', '맵 위 내 위치 토큰', comingSoon: true),
  CustomSlot('emblem.png', '빨간 띠 가운데 엠블럼', comingSoon: true),
  CustomSlot('castle.png', '홈 왼쪽 배경 성', comingSoon: true),
  CustomSlot('world1.png', '맵 1번 월드 배경', comingSoon: true),
  CustomSlot('world2.png', '맵 2번 월드 배경', comingSoon: true),
  CustomSlot('world3.png', '맵 3번 월드 배경', comingSoon: true),
  CustomSlot('world4.png', '맵 4번 월드 배경', comingSoon: true),
  CustomSlot('world5.png', '맵 5번 월드 배경', comingSoon: true),
  CustomSlot('sfx_coin.mp3', '스티커 붙이기 소리', comingSoon: true),
  CustomSlot('sfx_stamp.mp3', '도장 쿵 소리', comingSoon: true),
  CustomSlot('sfx_remove.mp3', '스티커 빼기 소리', comingSoon: true),
  CustomSlot('sfx_clear.mp3', '올클리어 소리', comingSoon: true),
  CustomSlot('sfx_powerup.mp3', '배지 획득 소리', comingSoon: true),
  CustomSlot('sfx_tap.mp3', '버튼 터치 소리', comingSoon: true),
  CustomSlot('celebrate.json', '올클리어 캐릭터 움직임 (Lottie)', comingSoon: true),
];

/// 캐릭터·꾸미기: 어떤 개인용 파일이 들어가 있는지 보여 주고, 넣는 방법을 안내한다.
class CustomizeScreen extends StatelessWidget {
  const CustomizeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              const WhiteFrameCard(
                headerTitle: '넣는 방법',
                headerColor: AppColors.pink,
                child: Text(
                  '1. 가족만 쓰는 그림·소리 파일을 같은 이름으로 만들어요.\n'
                  '2. PC의 assets/custom 폴더에 넣고 앱을 다시 빌드해요.\n'
                  '3. 여기에서 "적용 중"이 보이면 성공이에요.\n\n'
                  '사진첩에서 골라 바꾸는 기능은 다음 업데이트에서 만들어요. '
                  '소리 파일은 아직 재생 코드가 없어서 "준비 중"으로 보여요.',
                  style: TextStyle(
                    fontSize: 20,
                    height: 1.4,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
      (false, _) => '기본 그림을 쓰고 있어요',
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
