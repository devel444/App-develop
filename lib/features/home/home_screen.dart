import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sticker_world/core/audio/sound_player.dart';
import 'package:sticker_world/core/assets/asset_resolver.dart';
import 'package:sticker_world/core/router/routes.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/data/providers.dart';
import 'package:sticker_world/domain/sticker_ledger.dart';
import 'package:sticker_world/features/pin/parent_pin_screen.dart';
import 'package:sticker_world/core/widgets/coin_icon.dart';
import 'package:sticker_world/core/widgets/gold_medal.dart';
import 'package:sticker_world/core/widgets/hold_to_open.dart';
import 'package:sticker_world/core/widgets/jelly_button.dart';
import 'package:sticker_world/core/widgets/outlined_text.dart';
import 'package:sticker_world/features/home/default_character.dart';
import 'package:sticker_world/features/home/home_landscape.dart';

// 열쇠 3칸 = 선물 3개의 가격. 지금 잔액이 가격 이상이면 열쇠가 열린다.
// 배지 칸 5개는 얻은 배지 수만큼 금색으로 켜진다 (아이콘은 자리 표시).
const _stickerMax = 100;
const _medalIcons = [
  Icons.star_rounded,
  Icons.flag_rounded,
  Icons.favorite_rounded,
  Icons.bolt_rounded,
  Icons.emoji_events_rounded,
];

/// 홈: USJ 앱 메인 화면 구조 (PLAN.md 2-0).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(currentChildProvider).value?.name ?? '친구';
    final summary = ref.watch(ledgerProvider).value ?? LedgerView.empty;
    // 열쇠 3칸 = 가격이 가장 싼 선물 3개. 잔액이 가격 이상이면 열린다.
    final rewards = ref.watch(activeRewardsProvider).value ?? const [];
    final keyCosts = [for (final reward in rewards.take(3)) reward.cost];
    final keysEarned = keyCosts.where((cost) => summary.balance >= cost).length;
    final medalsEarned = ref.watch(badgeAwardsProvider).value?.length ?? 0;

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
              _TopBar(name: name),
              _ScoreBand(
                totalCoins: summary.totalEarned,
                keysEarned: keysEarned,
                name: name,
              ),
              Expanded(child: _Hero(name: name)),
              _GoldPanel(balance: summary.balance, medalsEarned: medalsEarned),
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
  const _TopBar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Row(
        children: [
          const SizedBox(width: 72),
          Expanded(
            child: Center(child: OutlinedText('$name의 스티커 월드', fontSize: 34)),
          ),
          SizedBox(
            width: 72,
            height: 72,
            child: HoldToOpen(
              onOpen: () => openParentMode(context),
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
  const _ScoreBand({
    required this.totalCoins,
    required this.keysEarned,
    required this.name,
  });

  final int totalCoins;
  final int keysEarned;
  final String name;

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
                      child: OutlinedText(
                        '$totalCoins',
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
          _Emblem(initial: name.isEmpty ? '' : name.substring(0, 1)),
          const SizedBox(width: 12),
          // 열쇠를 누르면 선물 가게로 간다. 열린 열쇠는 바로 살 수 있다는 뜻이고,
          // 잠긴 열쇠는 가게에서 다음 선물까지 얼마나 남았는지 보여 준다.
          Expanded(
            child: Semantics(
              button: true,
              label: '선물 열쇠 $keysEarned개 열림, 선물 가게 열기',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.push(Routes.shop),
                child: _Pill(
                  child: Row(
                    children: [
                      for (var i = 0; i < 3; i++)
                        Expanded(
                          child: Center(
                            child: _KeySlot(opened: i < keysEarned),
                          ),
                        ),
                    ],
                  ),
                ),
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
  const _Emblem({required this.initial});

  final String initial;

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
        child: Text(
          initial,
          style: const TextStyle(fontSize: 40, color: AppColors.red),
        ),
      ),
    );
  }
}

/// 가운데: 캐릭터(원형 링 위), 이름표.
class _Hero extends StatelessWidget {
  const _Hero({required this.name});

  final String name;

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
          child: OutlinedText(name, fontSize: 40, outlineWidth: 3),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

/// 캐릭터: 부모가 고른 사진 → 개인용 파일 → 기본 그림 순. 누르면 점프 소리가 난다.
class _Character extends ConsumerWidget {
  const _Character();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photo = ref.watch(characterPhotoProvider).value;
    final custom = AssetResolver.custom('character.png');
    const fallback = FittedBox(
      fit: BoxFit.scaleDown,
      child: DefaultCharacter(),
    );

    final Widget picture;
    if (photo != null) {
      picture = Image.file(
        File(photo),
        height: 260,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => fallback,
      );
    } else if (custom != null) {
      picture = Image.asset(custom, height: 260, fit: BoxFit.contain);
    } else {
      picture = fallback;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => ref.read(soundPlayerProvider).play(Sfx.jump),
      child: picture,
    );
  }
}

/// 금색 패널: 보유 스티커 수(누르면 맵) · 배지 5칸(누르면 배지 도감).
class _GoldPanel extends StatelessWidget {
  const _GoldPanel({required this.balance, required this.medalsEarned});

  final int balance;
  final int medalsEarned;

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
              child: SizedBox(
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
                          '$balance / $_stickerMax',
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
                            locked: i >= medalsEarned,
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
              onTap: () => pinThenPush(context, Routes.stamp),
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
              onTap: () => pinThenPush(context, Routes.remove),
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
