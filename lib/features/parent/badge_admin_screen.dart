import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/gold_medal.dart';
import 'package:sticker_world/core/widgets/pattern_background.dart';
import 'package:sticker_world/core/widgets/pill_row.dart';
import 'package:sticker_world/core/widgets/screen_frame.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/providers.dart';
import 'package:sticker_world/features/badges/badge_icons.dart';
import 'package:sticker_world/features/stamp/stamp_widgets.dart';

/// 배지 켜기·끄기. 끈 배지는 조건이 맞아도 얻지 않는다. 이미 얻은 배지는 그대로 남는다.
class BadgeAdminScreen extends ConsumerWidget {
  const BadgeAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badges = ref.watch(allBadgesProvider).value ?? const <Badge>[];

    return Stack(
      fit: StackFit.expand,
      children: [
        ScreenFrame(
          title: '배지 켜기 · 끄기',
          color: AppColors.gold,
          pattern: BgPattern.stripes,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            children: [
              for (final badge in badges)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: PillRow(
                    accent: AppColors.gold,
                    leading: GoldMedal(
                      size: 56,
                      child: Icon(
                        badgeIconOf(badge.iconKey),
                        size: 28,
                        color: badgeMedalIconColor,
                      ),
                    ),
                    title: badge.name,
                    subtitle: [
                      badge.isActive ? '켜짐' : '꺼 둠 · 새로 얻지 않아요',
                      badge.category,
                      if (badge.isHidden) '아이에게는 숨겨진 배지',
                    ].join(' · '),
                    trailing: Switch(
                      value: badge.isActive,
                      onChanged: (on) => ref
                          .read(badgeRepositoryProvider)
                          .setBadgeActive(badge.code, active: on),
                    ),
                    onTap: () => ref
                        .read(badgeRepositoryProvider)
                        .setBadgeActive(badge.code, active: !badge.isActive),
                  ),
                ),
            ],
          ),
        ),
        const BackFab(),
      ],
    );
  }
}
