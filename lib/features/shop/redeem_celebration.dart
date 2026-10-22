import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/jelly_button.dart';
import 'package:sticker_world/core/widgets/outlined_text.dart';
import 'package:sticker_world/core/widgets/white_frame_card.dart';
import 'package:sticker_world/core/widgets/coin_icon.dart';
import 'package:sticker_world/data/repositories/sticker_repository.dart';

/// 교환 연출: 코인이 선물 상자로 날아가고, 상자가 열리면 교환권이 나온다.
/// 교환권은 "확인"을 누를 때까지 그대로 보인다.
class RedeemCelebration extends StatelessWidget {
  const RedeemCelebration({
    super.key,
    required this.result,
    required this.onDone,
  });

  final RedeemResult result;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final coinCount = result.cost.clamp(1, 12);

    return Container(
      color: const Color(0xCC1E1B33),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 260,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                for (var i = 0; i < coinCount; i++)
                  CoinIcon(size: 44)
                      .animate(delay: (i * 70).ms)
                      .move(
                        begin: Offset(((i % 5) - 2) * 60.0, -180),
                        end: const Offset(0, 40),
                        duration: 700.ms,
                        curve: Curves.easeIn,
                      )
                      .fadeOut(delay: 650.ms, duration: 120.ms),
                const Icon(
                      Icons.card_giftcard_rounded,
                      size: 150,
                      color: AppColors.gold,
                    )
                    .animate(delay: 800.ms)
                    .scale(
                      begin: const Offset(0.2, 0.2),
                      end: const Offset(1, 1),
                      duration: 450.ms,
                      curve: Curves.bounceOut,
                    )
                    .fadeIn(duration: 150.ms),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _VoucherTicket(result: result, onDone: onDone)
              .animate(delay: 1400.ms)
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.3, end: 0, duration: 300.ms),
        ],
      ),
    );
  }
}

/// 교환권. 번호, 선물 이름, 쓴 스티커 개수를 보여 준다.
class _VoucherTicket extends StatelessWidget {
  const _VoucherTicket({required this.result, required this.onDone});

  final RedeemResult result;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return WhiteFrameCard(
      headerTitle: '교환권',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            result.voucherNo,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, color: AppColors.misdeed),
          ),
          const SizedBox(height: 8),
          Text(
            result.rewardName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 40, color: AppColors.ink),
          ),
          const SizedBox(height: 8),
          Text(
            '스티커 ${result.cost}개를 썼어요.\n엄마·아빠가 선물을 주면 "받았어요"를 눌러요.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              height: 1.4,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 16),
          JellyButton(
            color: AppColors.gold,
            height: 80,
            semanticLabel: '확인',
            onTap: onDone,
            child: const Center(child: OutlinedText('확인', fontSize: 30)),
          ),
        ],
      ),
    );
  }
}
