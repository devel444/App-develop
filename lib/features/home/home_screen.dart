import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sticker_world/core/assets/asset_resolver.dart';
import 'package:sticker_world/core/router/routes.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/coin_icon.dart';
import 'package:sticker_world/core/widgets/gold_medal.dart';
import 'package:sticker_world/core/widgets/hold_to_open.dart';
import 'package:sticker_world/core/widgets/jelly_button.dart';
import 'package:sticker_world/core/widgets/outlined_text.dart';
import 'package:sticker_world/features/home/default_character.dart';
import 'package:sticker_world/features/home/home_landscape.dart';

// P0: 화면 구조만 만든다. 아래 값은 임시이며 P1에서 DB 값으로 바꾼다.
const _totalCoins = 128;
const _stickerCount = 37;
const _stickerMax = 100;
const _keysEarned = 1; // 열쇠 3칸(30·50·100개 선물) 중 열린 칸 수
const _medalsEarned = 3; // 배지 5칸 중 얻은 개수
const _medalIcons = [
  Icons.star_rounded,
  Icons.flag_rounded,
  Icons.favorite_rounded,
  Icons.bolt_rounded,
  Icons.emoji_events_rounded,
];

/// 홈: USJ 앱 메인 화면 구조 (PLAN.md 2-0).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const Positioned.fill(
          child: CustomPaint(painter: HomeLandscapePainter()),
        ),
        SafeArea(
          bottom: false,
          child: Column(
            children: [
              const _TopBar(),
              const _ScoreBand(),
              const Expanded(child: _Hero()),
              const _GoldPanel(),
              const SizedBox(height: 16),
              const _ActionRow(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Row(
        children: [
          const SizedBox(width: 72),
          const Expanded(
            child: Center(child: OutlinedText('지우의 스티커 월드', fontSize: 34)),
          ),
          SizedBox(
            width: 72,
            height: 72,
            child: HoldToOpen(
              onOpen: () => context.push(Routes.parent),
              child: const Icon(
                Icons.notifications_rounded,
                color: AppColors.white,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 빨간 띠: 코인 수 · 엠블럼 · 선물 열쇠.
class _ScoreBand extends StatelessWidget {
  const _ScoreBand();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      color: AppColors.red,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: _Pill(
              child: Row(
                children: [
                  const CoinIcon(size: 46),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: const OutlinedText(
                        '$_totalCoins',
                        fontFamily: 'LilitaOne',
                        fontSize: 44,
                        color: AppColors.ink,
                        outlineColor: AppColors.white,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          const _Emblem(),
          const SizedBox(width: 12),
          Expanded(
            child: _Pill(
              child: Row(
                children: [
                  for (var i = 0; i < 3; i++)
                    Expanded(
                      child: Center(child: _KeySlot(opened: i < _keysEarned)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6B3BC),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFC4161B), width: 4),
      ),
      child: child,
    );
  }
}

class _KeySlot extends StatelessWidget {
  const _KeySlot({required this.opened});

  final bool opened;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: opened ? const Color(0xFFF5A623) : const Color(0xFFB98D93),
        border: Border.all(
          color: opened ? const Color(0xFF8A4A00) : const Color(0xFF9A6F75),
          width: 3,
        ),
      ),
      child: Icon(
        Icons.key_rounded,
        size: 28,
        color: opened ? AppColors.white : const Color(0xFF9A6F75),
      ),
    );
  }
}

class _Emblem extends StatelessWidget {
  const _Emblem();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.red,
        border: Border.all(color: AppColors.white, width: 5),
      ),
      child: Container(
        width: 66,
        height: 66,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white,
        ),
        child: const Text(
          '지',
          style: TextStyle(fontSize: 40, color: AppColors.red),
        ),
      ),
    );
  }
}

/// 가운데: 캐릭터(원형 링 위), 이름표.
class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            // 화면이 작으면 링과 캐릭터를 같이 줄인다.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: 300,
                height: 300,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 300,
                      height: 300,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1E8FE0),
                      ),
                    ),
                    Container(
                      width: 236,
                      height: 236,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF5CC8F5),
                      ),
                    ),
                    const _Character(),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0x8C1E5A8C),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const OutlinedText('지우', fontSize: 40, outlineWidth: 3),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _Character extends StatelessWidget {
  const _Character();

  @override
  Widget build(BuildContext context) {
    final custom = AssetResolver.custom('character.png');
    if (custom != null) {
      return Image.asset(custom, height: 260, fit: BoxFit.contain);
    }
    return const FittedBox(fit: BoxFit.scaleDown, child: DefaultCharacter());
  }
}

/// 금색 패널: 보유 스티커 수(누르면 맵) · 배지 5칸(누르면 배지 도감).
class _GoldPanel extends StatelessWidget {
  const _GoldPanel();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.gold,
          borderRadius: BorderRadius.circular(34),
          boxShadow: const [
            BoxShadow(color: AppColors.goldDeep, offset: Offset(0, 8)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context.go(Routes.map),
              child: const SizedBox(
                height: 104,
                child: Center(
                  // 좁은 화면에서는 숫자 줄 전체를 줄여서 맞춘다.
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CoinIcon(size: 60),
                        SizedBox(width: 14),
                        OutlinedText(
                          '$_stickerCount / $_stickerMax',
                          fontFamily: 'LilitaOne',
                          fontSize: 56,
                          color: AppColors.ink,
                          outlineColor: AppColors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(height: 4, color: AppColors.goldDeep),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context.push(Routes.badges),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (var i = 0; i < _medalIcons.length; i++)
                      Expanded(
                        // 좁은 화면에서는 메달을 줄여서 한 줄에 맞춘다.
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: GoldMedal(
                            size: 84,
                            locked: i >= _medalsEarned,
                            child: Icon(
                              _medalIcons[i],
                              size: 44,
                              color: const Color(0xFF8A5A00),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 맨 아래 큰 버튼 3개: 스티커 붙이기 · 빼기 · 선물가게.
class _ActionRow extends StatelessWidget {
  const _ActionRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          Expanded(
            flex: 16,
            child: JellyButton(
              color: AppColors.red,
              height: 112,
              semanticLabel: '스티커 붙이기',
              onTap: () => context.push(Routes.stamp),
              child: const Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: OutlinedText('스티커 붙이기', fontSize: 34),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 10,
            child: JellyButton(
              color: AppColors.white,
              height: 112,
              semanticLabel: '스티커 빼기',
              onTap: () => context.push(Routes.remove),
              child: const Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '스티커 빼기',
                    style: TextStyle(fontSize: 26, color: AppColors.red),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 10,
            child: JellyButton(
              color: AppColors.pink,
              height: 112,
              semanticLabel: '선물가게',
              onTap: () => context.push(Routes.shop),
              child: const Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: OutlinedText('선물가게', fontSize: 28),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
