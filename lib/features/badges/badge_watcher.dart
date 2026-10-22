import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/gold_medal.dart';
import 'package:sticker_world/core/widgets/jelly_button.dart';
import 'package:sticker_world/core/widgets/outlined_text.dart';
import 'package:sticker_world/core/widgets/white_frame_card.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/providers.dart';
import 'package:sticker_world/features/badges/badge_icons.dart';

/// 앱 전체에서 배지 판정을 켜고, 새로 얻은 배지를 한 개씩 팝업으로 보여 준다.
/// 탭 틀 위에 한 번 씌운다. 팝업은 전체 화면 위에 뜬다.
class BadgeWatcher extends ConsumerStatefulWidget {
  const BadgeWatcher({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<BadgeWatcher> createState() => _BadgeWatcherState();
}

class _BadgeWatcherState extends ConsumerState<BadgeWatcher> {
  bool _showing = false;

  @override
  Widget build(BuildContext context) {
    ref
      ..watch(badgeCheckProvider)
      ..listen(badgePopupQueueProvider, (_, _) => _showNext());
    return widget.child;
  }

  /// 줄에 남은 배지를 차례로 보여 준다. 한 번에 한 장만 뜬다.
  Future<void> _showNext() async {
    if (_showing) {
      return;
    }
    _showing = true;
    try {
      while (mounted) {
        final queue = ref.read(badgePopupQueueProvider);
        if (queue.isEmpty) {
          break;
        }
        final badge = queue.first;
        ref.read(badgePopupQueueProvider.notifier).removeFirst();
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => BadgePopup(badge: badge),
        );
      }
    } finally {
      _showing = false;
    }
  }
}

/// 배지 획득 팝업. 메달이 탄성 있게 커지며 나온다.
class BadgePopup extends StatelessWidget {
  const BadgePopup({super.key, required this.badge});

  final Badge badge;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: WhiteFrameCard(
          headerTitle: '새 배지!',
          headerColor: AppColors.gold,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.3, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.elasticOut,
                builder: (context, scale, child) =>
                    Transform.scale(scale: scale, child: child),
                child: GoldMedal(
                  size: 180,
                  child: Icon(
                    badgeIconOf(badge.iconKey),
                    size: 90,
                    color: badgeMedalIconColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                badge.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 40, color: AppColors.ink),
              ),
              if (badge.bonusAmount > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '보너스 스티커 +${badge.bonusAmount}',
                    style: const TextStyle(
                      fontSize: 24,
                      color: AppColors.misdeed,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              JellyButton(
                color: AppColors.gold,
                height: 84,
                semanticLabel: '좋아요',
                onTap: () => Navigator.of(context).pop(),
                child: const Center(child: OutlinedText('좋아요!', fontSize: 36)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
