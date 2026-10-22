import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticker_world/core/router/routes.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/time/local_date.dart';
import 'package:sticker_world/core/widgets/coin_icon.dart';
import 'package:sticker_world/core/widgets/jelly_button.dart';
import 'package:sticker_world/core/widgets/outlined_text.dart';
import 'package:sticker_world/core/widgets/pattern_background.dart';
import 'package:sticker_world/core/widgets/screen_frame.dart';
import 'package:sticker_world/core/widgets/white_frame_card.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/providers.dart';
import 'package:sticker_world/data/repositories/sticker_repository.dart';
import 'package:sticker_world/domain/sticker_rules.dart';
import 'package:sticker_world/features/pin/parent_pin_screen.dart';
import 'package:sticker_world/features/shop/gift_picture.dart';
import 'package:sticker_world/features/shop/redeem_celebration.dart';
import 'package:sticker_world/features/shop/ticket_card.dart';
import 'package:sticker_world/features/stamp/stamp_widgets.dart';

/// 선물가게: 모은 스티커로 선물을 고르고, 교환권을 확인한다.
/// 교환과 "받았어요"는 부모 PIN을 맞춘 뒤에만 된다.
class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  RedeemResult? _celebrating;
  String? _message;

  Future<void> _redeem(Reward reward) async {
    final ok = await requireParentPin(context);
    if (!ok || !mounted) {
      return;
    }
    final childId = ref.read(currentChildProvider).value?.id;
    if (childId == null) {
      return;
    }
    try {
      final result = await ref
          .read(stickerRepositoryProvider)
          .redeem(childId: childId, rewardId: reward.id);
      if (mounted) {
        setState(() {
          _message = null;
          _celebrating = result;
        });
      }
    } on StickerRuleException catch (error) {
      if (mounted) {
        setState(() => _message = error.message);
      }
    }
  }

  Future<void> _markDelivered(Redemption redemption) async {
    final ok = await requireParentPin(context);
    if (!ok || !mounted) {
      return;
    }
    await ref
        .read(rewardRepositoryProvider)
        .markDelivered(redemption.id, DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final balance = ref.watch(ledgerProvider).value?.balance ?? 0;
    final rewards = ref.watch(activeRewardsProvider).value ?? const <Reward>[];
    final redemptions =
        ref.watch(redemptionsProvider).value ?? const <Redemption>[];
    final rewardNames = {
      for (final reward
          in ref.watch(allRewardsProvider).value ?? const <Reward>[])
        reward.id: reward.name,
    };

    return Stack(
      fit: StackFit.expand,
      children: [
        ScreenFrame(
          title: '선물가게',
          color: AppColors.pink,
          pattern: BgPattern.dots,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              children: [
                _BalanceLine(balance: balance),
                if (_message != null) ...[
                  const SizedBox(height: 12),
                  _Notice(
                    text: _message!,
                    onClose: () => setState(() => _message = null),
                  ),
                ],
                const SizedBox(height: 16),
                if (rewards.isEmpty)
                  const WhiteFrameCard(
                    headerTitle: '아직 선물이 없어요',
                    child: Text(
                      '엄마·아빠가 선물을 추가하면\n여기에 보여요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, color: AppColors.ink),
                    ),
                  ),
                for (final reward in rewards)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _RewardCard(
                      reward: reward,
                      balance: balance,
                      onRedeem: () => _redeem(reward),
                    ),
                  ),
                const SizedBox(height: 8),
                const OutlinedText('내 교환권', fontSize: 34),
                for (final redemption in redemptions)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _VoucherRow(
                      redemption: redemption,
                      rewardName: rewardNames[redemption.rewardId] ?? '선물',
                      onDelivered: () => _markDelivered(redemption),
                    ),
                  ),
                if (redemptions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: HintText('아직 교환한 선물이 없어요.'),
                  ),
                const SizedBox(height: 24),
                JellyButton(
                  color: AppColors.white,
                  height: 80,
                  semanticLabel: '선물 관리',
                  onTap: () => pinThenPush(context, Routes.rewards),
                  child: const Center(
                    child: Text(
                      '선물 관리 (엄마·아빠)',
                      style: TextStyle(fontSize: 26, color: AppColors.ink),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_celebrating != null)
          RedeemCelebration(
            result: _celebrating!,
            onDone: () => setState(() => _celebrating = null),
          ),
        const BackFab(),
      ],
    );
  }
}

class _BalanceLine extends StatelessWidget {
  const _BalanceLine({required this.balance});

  final int balance;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CoinIcon(size: 44),
        const SizedBox(width: 12),
        OutlinedText('지금 $balance개', fontFamily: 'LilitaOne', fontSize: 40),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text, required this.onClose});

  final String text;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return WhiteFrameCard(
      headerTitle: '잠깐만요',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, color: AppColors.misdeed),
          ),
          const SizedBox(height: 12),
          JellyButton(
            color: AppColors.gold,
            height: 64,
            semanticLabel: '닫기',
            onTap: onClose,
            child: const Center(child: OutlinedText('닫기', fontSize: 26)),
          ),
        ],
      ),
    );
  }
}

/// 선물 한 개: 이름, 가격, 얼마나 모았는지, 교환 버튼.
class _RewardCard extends StatelessWidget {
  const _RewardCard({
    required this.reward,
    required this.balance,
    required this.onRedeem,
  });

  final Reward reward;
  final int balance;
  final VoidCallback onRedeem;

  @override
  Widget build(BuildContext context) {
    final canRedeem = balance >= reward.cost;
    final progress = (balance / reward.cost).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: canRedeem ? AppColors.cream : AppColors.white,
        borderRadius: BorderRadius.circular(34),
        border: canRedeem ? Border.all(color: AppColors.gold, width: 5) : null,
        boxShadow: const [
          BoxShadow(color: Color(0x26000000), offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              GiftPicture(imagePath: reward.imagePath),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward.name,
                      style: const TextStyle(
                        fontSize: 30,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const CoinIcon(size: 26),
                        const SizedBox(width: 8),
                        Text(
                          '${reward.cost}개',
                          style: const TextStyle(
                            fontSize: 26,
                            color: Color(0xFF6B2A05),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFFE3D6BC),
              borderRadius: BorderRadius.circular(9),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: canRedeem ? AppColors.green : AppColors.gold,
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 80,
            child: JellyButton(
              color: canRedeem ? AppColors.red : const Color(0xFFB7BDCC),
              height: 80,
              semanticLabel: canRedeem
                  ? '${reward.name} 교환하기'
                  : '${reward.cost - balance}개 더 모으면 교환',
              onTap: canRedeem ? onRedeem : null,
              child: Center(
                child: Text(
                  canRedeem ? '교환하기' : '${reward.cost - balance}개 더 모으면!',
                  style: const TextStyle(fontSize: 26, color: AppColors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 교환권 한 장. 티켓 모양으로 보여 주고, 받기 전이면 부모가 "받았어요"를 누를 수 있다.
class _VoucherRow extends StatelessWidget {
  const _VoucherRow({
    required this.redemption,
    required this.rewardName,
    required this.onDelivered,
  });

  final Redemption redemption;
  final String rewardName;
  final VoidCallback onDelivered;

  @override
  Widget build(BuildContext context) {
    final delivered = redemption.deliveredAt != null;

    return TicketCard(
      title: rewardName,
      subtitle:
          '${redemption.voucherNo} · ${redemption.cost}개 · ${localDateKey(redemption.createdAt)}',
      color: delivered ? AppColors.cream : AppColors.white,
      trailing: delivered
          ? const Center(
              child: Text(
                '받았어요 ✓',
                style: TextStyle(fontSize: 22, color: AppColors.green),
              ),
            )
          : JellyButton(
              color: AppColors.mint,
              height: 72,
              semanticLabel: '받았어요',
              onTap: onDelivered,
              child: const Center(
                child: Text(
                  '받았어요',
                  style: TextStyle(fontSize: 24, color: AppColors.ink),
                ),
              ),
            ),
    );
  }
}
