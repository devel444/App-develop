import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sticker_world/core/audio/sound_player.dart';
import 'package:sticker_world/core/assets/asset_resolver.dart';
import 'package:sticker_world/core/router/routes.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/data/providers.dart';
import 'package:sticker_world/domain/home_speech.dart';
import 'package:sticker_world/domain/sticker_ledger.dart';
import 'package:sticker_world/features/home/speech_bubble.dart';
import 'package:sticker_world/features/pin/parent_pin_screen.dart';
import 'package:sticker_world/core/widgets/coin_icon.dart';
import 'package:sticker_world/core/widgets/gold_medal.dart';
import 'package:sticker_world/core/widgets/hold_to_open.dart';
import 'package:sticker_world/core/widgets/jelly_button.dart';
import 'package:sticker_world/core/widgets/outlined_text.dart';
import 'package:sticker_world/features/home/default_character.dart';
import 'package:sticker_world/features/home/home_extras.dart';
import 'package:sticker_world/features/world/character_picker.dart';

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
/// 좁은 태블릿(8인치)에서는 위아래 고정 요소를 줄이고 캐릭터 자리를 넓힌다.
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
    final compact = homeIsCompact(context);
    final gap = compact ? 8.0 : 16.0;

    return Stack(
      fit: StackFit.expand,
      children: [
        const HomeBackground(),
        const PraiseOnce(),
        SafeArea(
          bottom: false,
          child: Column(
            children: [
              _TopBar(name: name),
              _ScoreBand(
                totalCoins: summary.totalEarned,
                keysEarned: keysEarned,
              ),
              const WeeklyReportBanner(),
              Expanded(child: _Hero(name: name)),
              _GoldPanel(balance: summary.balance, medalsEarned: medalsEarned),
              // 금색 패널의 그림자가 버튼에 닿지 않도록 띄운다.
              SizedBox(height: compact ? 20 : 28),
              const _ActionRow(),
              SizedBox(height: gap),
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
    final compact = homeIsCompact(context);
    final side = compact ? 56.0 : 72.0;
    return SizedBox(
      height: side,
      child: Row(
        children: [
          SizedBox(width: side),
          Expanded(
            child: Center(
              child: OutlinedText('$name의 스티커 월드', fontSize: compact ? 26 : 34),
            ),
          ),
          SizedBox(
            width: side,
            height: side,
            child: HoldToOpen(
              onOpen: () => openParentMode(context),
              child: Icon(
                Icons.notifications_rounded,
                color: AppColors.white,
                size: compact ? 30 : 40,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 빨간 띠: 코인 수 · 캐릭터 고르기 버튼 · 선물 열쇠.
class _ScoreBand extends StatelessWidget {
  const _ScoreBand({required this.totalCoins, required this.keysEarned});

  final int totalCoins;
  final int keysEarned;

  @override
  Widget build(BuildContext context) {
    final compact = homeIsCompact(context);
    return Container(
      height: compact ? 68 : 96,
      color: AppColors.red,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: _Pill(
              child: Row(
                children: [
                  CoinIcon(size: compact ? 36 : 46),
                  SizedBox(width: compact ? 6 : 10),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: OutlinedText(
                        '$totalCoins',
                        fontFamily: 'LilitaOne',
                        fontSize: compact ? 34 : 44,
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
          // 가운데 버튼을 누르면 캐릭터 8칸 중 고르는 창이 열린다.
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => showCharacterPicker(context),
            child: const _CharacterButton(),
          ),
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
    final compact = homeIsCompact(context);
    return Container(
      height: compact ? 48 : 64,
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
    final compact = homeIsCompact(context);
    final size = compact ? 34.0 : 50.0;
    return Container(
      width: size,
      height: size,
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
        size: compact ? 18 : 28,
        color: opened ? AppColors.white : const Color(0xFF9A6F75),
      ),
    );
  }
}

/// 빨간 띠 가운데의 캐릭터 고르기 버튼. 지금 캐릭터 얼굴과 "캐릭터 고르기" 글자로 버튼이라는 걸 보여 준다.
class _CharacterButton extends ConsumerWidget {
  const _CharacterButton();

  static const _defaultFace = FittedBox(
    fit: BoxFit.contain,
    child: DefaultCharacter(),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compact = homeIsCompact(context);
    final photo = ref.watch(characterRosterProvider).value?.activeSlot.photo;
    final height = compact ? 62.0 : 88.0;
    final face = compact ? 46.0 : 66.0;
    final labelStyle = TextStyle(
      fontSize: compact ? 18 : 24,
      height: 1.1,
      color: AppColors.white,
    );

    return Container(
      height: height,
      padding: EdgeInsets.only(left: 6, right: compact ? 10 : 16),
      decoration: BoxDecoration(
        color: AppColors.red,
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: AppColors.white, width: 5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: face,
            height: face,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
            ),
            child: photo == null
                ? _defaultFace
                : Image.file(
                    File(photo),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _defaultFace,
                  ),
          ),
          SizedBox(width: compact ? 8 : 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('캐릭터', style: labelStyle),
              Text('고르기', style: labelStyle),
            ],
          ),
        ],
      ),
    );
  }
}

/// 가운데: 왼쪽에 캐릭터(원형 링), 오른쪽에 이름표와 캐릭터의 말풍선.
/// 좁은 화면에서는 링을 남는 높이까지 키운다 (FittedBox가 위아래로 늘린다).
class _Hero extends ConsumerStatefulWidget {
  const _Hero({required this.name});

  final String name;

  @override
  ConsumerState<_Hero> createState() => _HeroState();
}

class _HeroState extends ConsumerState<_Hero> {
  // 홈을 열 때 한 번 고른 말을 그대로 보여 준다 (화면을 다시 그릴 때마다 바뀌지 않게).
  late final String _speech = pickHomeSpeech(ref.read(randomProvider));

  @override
  Widget build(BuildContext context) {
    final compact = homeIsCompact(context);
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              // 캐릭터는 가운데보다 조금 왼쪽에 선다.
              Expanded(
                flex: 11,
                child: Center(
                  child: FittedBox(
                    fit: compact ? BoxFit.contain : BoxFit.scaleDown,
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
              Expanded(
                flex: 9,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: compact ? 16 : 22,
                          vertical: compact ? 2 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x8C1E5A8C),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: OutlinedText(
                          widget.name,
                          fontSize: compact ? 28 : 40,
                          outlineWidth: 3,
                        ),
                      ),
                      SizedBox(height: compact ? 10 : 16),
                      SpeechBubble(text: _speech),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const HomeGreeting(),
        SizedBox(height: compact ? 4 : 8),
        const TodayProgressBar(),
        SizedBox(height: compact ? 4 : 10),
      ],
    );
  }
}

/// 캐릭터: 부모가 고른 사진 → 개인용 파일 → 기본 그림 순. 누르면 점프 소리가 난다.
class _Character extends ConsumerWidget {
  const _Character();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photo = ref.watch(characterRosterProvider).value?.activeSlot.photo;
    final custom = AssetResolver.custom('character.png');
    const fallback = FittedBox(
      fit: BoxFit.scaleDown,
      child: DefaultCharacter(),
    );

    final Widget picture;
    if (photo != null) {
      picture = Image.file(
        File(photo),
        height: 300,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => fallback,
      );
    } else if (custom != null) {
      picture = Image.asset(custom, height: 300, fit: BoxFit.contain);
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
    final compact = homeIsCompact(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 28 : 40),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.gold,
          borderRadius: BorderRadius.circular(compact ? 26 : 34),
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
                height: compact ? 72 : 104,
                child: Center(
                  // 좁은 화면에서는 숫자 줄 전체를 줄여서 맞춘다.
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CoinIcon(size: compact ? 44 : 60),
                        SizedBox(width: compact ? 10 : 14),
                        OutlinedText(
                          '$balance / $_stickerMax',
                          fontFamily: 'LilitaOne',
                          fontSize: compact ? 40 : 56,
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
                padding: EdgeInsets.symmetric(
                  vertical: compact ? 8 : 14,
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
                            size: compact ? 56 : 84,
                            locked: i >= medalsEarned,
                            child: Icon(
                              _medalIcons[i],
                              size: compact ? 30 : 44,
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
    final compact = homeIsCompact(context);
    final height = compact ? 80.0 : 112.0;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 28 : 40),
      child: Row(
        children: [
          Expanded(
            flex: 16,
            child: JellyButton(
              color: AppColors.red,
              height: height,
              semanticLabel: '스티커 붙이기',
              onTap: () => pinThenPush(context, Routes.stamp),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: OutlinedText('스티커 붙이기', fontSize: compact ? 24 : 34),
                ),
              ),
            ),
          ),
          SizedBox(width: compact ? 10 : 14),
          Expanded(
            flex: 10,
            child: JellyButton(
              color: AppColors.white,
              height: height,
              semanticLabel: '스티커 빼기',
              onTap: () => pinThenPush(context, Routes.remove),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '스티커 빼기',
                    style: TextStyle(
                      fontSize: compact ? 19 : 26,
                      color: AppColors.red,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: compact ? 10 : 14),
          Expanded(
            flex: 10,
            child: JellyButton(
              color: AppColors.pink,
              height: height,
              semanticLabel: '선물가게',
              onTap: () => context.push(Routes.shop),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: OutlinedText('선물가게', fontSize: compact ? 20 : 28),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
