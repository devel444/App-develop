import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticker_world/core/router/routes.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/jelly_button.dart';
import 'package:sticker_world/core/widgets/outlined_text.dart';
import 'package:sticker_world/core/widgets/page_arrows.dart';
import 'package:sticker_world/core/widgets/pattern_background.dart';
import 'package:sticker_world/core/widgets/screen_frame.dart';
import 'package:sticker_world/core/widgets/white_frame_card.dart';
import 'package:sticker_world/data/providers.dart';
import 'package:sticker_world/domain/sticker_ledger.dart';
import 'package:sticker_world/features/pin/parent_pin_screen.dart';
import 'package:sticker_world/features/world/world_board.dart';
import 'package:sticker_world/features/world/world_layout.dart';

const _worldColors = [
  Color(0xFFBDEFA4),
  Color(0xFFFFE08A),
  Color(0xFFB5E6F8),
  Color(0xFFE3F1FF),
  Color(0xFFF9C9DE),
];

/// 맵 탭: 100칸 스티커 월드. 좌우 화살표로 월드를 넘긴다.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  int? _page;

  @override
  Widget build(BuildContext context) {
    final ledger = ref.watch(ledgerProvider).value ?? LedgerView.empty;
    final colors = ref.watch(categoryColorsProvider).value ?? const {};
    final rewards = ref.watch(activeRewardsProvider).value ?? const [];
    final giftCosts = [for (final reward in rewards) reward.cost];
    final page = _page ?? WorldLayout.worldFor(ledger.balance);
    final worldName = WorldLayout.worldNames[page];

    return ScreenFrame(
      title: 'W${page + 1} · $worldName',
      color: AppColors.blue,
      pattern: BgPattern.dots,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: PageArrows(
                onPrevious: page > 0
                    ? () => setState(() => _page = page - 1)
                    : null,
                onNext: page < WorldLayout.worldCount - 1
                    ? () => setState(() => _page = page + 1)
                    : null,
                child: Center(
                  child: WhiteFrameCard(
                    headerTitle: worldName,
                    headerColor: _worldColors[page],
                    child: WorldBoard(
                      world: page,
                      balance: ledger.balance,
                      stack: ledger.stack,
                      colorOf: (id) => Color(colors[id] ?? 0xFF7A7A8C),
                      giftCells: giftCosts.toSet(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          PageDots(count: WorldLayout.worldCount, index: page),
          const SizedBox(height: 12),
          _StatusLine(balance: ledger.balance, giftCosts: giftCosts),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
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
                  flex: 2,
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
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// 지금 몇 번 칸인지, 다음 선물까지 몇 개 남았는지.
class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.balance, required this.giftCosts});

  final int balance;
  final List<int> giftCosts;

  @override
  Widget build(BuildContext context) {
    final String text;
    if (balance >= WorldLayout.worldCount * WorldLayout.worldSize) {
      text = '가득 찼어요! 선물가게에서 선물을 골라 보세요.';
    } else {
      final next = (giftCosts.where((cost) => cost > balance).toList()..sort());
      text = next.isEmpty
          ? '지금 $balance개!'
          : '지금 $balance개 · 다음 선물까지 ${next.first - balance}개!';
    }
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 22, color: AppColors.white),
    );
  }
}
