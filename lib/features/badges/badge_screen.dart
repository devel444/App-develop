import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/time/local_date.dart';
import 'package:sticker_world/core/widgets/gold_medal.dart';
import 'package:sticker_world/core/widgets/pattern_background.dart';
import 'package:sticker_world/core/widgets/screen_frame.dart';
import 'package:sticker_world/core/widgets/white_frame_card.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/providers.dart';
import 'package:sticker_world/domain/badge_rules.dart';
import 'package:sticker_world/features/badges/badge_icons.dart';
import 'package:sticker_world/features/stamp/stamp_widgets.dart';

const _filters = ['전체', '스티커', '할 일', '듀오링고', '일기'];

/// 배지 도감. 최근 배지를 크게 보여 주고, 아래에 모든 배지를 메달로 늘어놓는다.
class BadgeScreen extends ConsumerStatefulWidget {
  const BadgeScreen({super.key});

  @override
  ConsumerState<BadgeScreen> createState() => _BadgeScreenState();
}

class _BadgeScreenState extends ConsumerState<BadgeScreen> {
  String _filter = '전체';

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(badgeCatalogProvider).value ?? const <Badge>[];
    // 최근 순으로 온다.
    final awards = ref.watch(badgeAwardsProvider).value ?? const <BadgeAward>[];
    final stats = ref.watch(badgeStatsProvider).value;

    final byCode = {for (final badge in catalog) badge.code: badge};
    final awardedAt = {
      for (final award in awards) award.badgeCode: award.awardedAt,
    };
    final latest = awards.isEmpty ? null : awards.first;
    final latestBadge = latest == null ? null : byCode[latest.badgeCode];
    final shown = [
      for (final badge in catalog)
        if (_filter == '전체' || badge.category == _filter) badge,
    ];

    return Stack(
      fit: StackFit.expand,
      children: [
        ScreenFrame(
          title: '배지 도감',
          color: AppColors.gold,
          pattern: BgPattern.stripes,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _LatestCard(
                  badge: latestBadge,
                  awardedAt: latest?.awardedAt,
                  earned: awards.length,
                  total: catalog.length,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 72,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    for (final filter in _filters)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: SizedBox(
                          width: 150,
                          child: ChoiceButton(
                            label: filter,
                            height: 60,
                            selected: _filter == filter,
                            color: AppColors.gold,
                            onTap: () => setState(() => _filter = filter),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.count(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.6,
                  children: [
                    for (final badge in shown)
                      _BadgeTile(
                        badge: badge,
                        awardedAt: awardedAt[badge.code],
                        hint: _hintOf(badge, stats),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const BackFab(),
      ],
    );
  }

  static String _hintOf(Badge badge, BadgeStats? stats) {
    final rule = BadgeRule.tryParse(badge.ruleJson);
    return rule == null ? '' : rule.hint(stats);
  }
}

class _LatestCard extends StatelessWidget {
  const _LatestCard({
    required this.badge,
    required this.awardedAt,
    required this.earned,
    required this.total,
  });

  final Badge? badge;
  final DateTime? awardedAt;
  final int earned;
  final int total;

  @override
  Widget build(BuildContext context) {
    final badge = this.badge;
    return WhiteFrameCard(
      headerTitle: '최근에 얻은 배지',
      headerColor: AppColors.gold,
      child: badge == null
          ? const HintText('아직 배지가 없어요. 스티커를 모아 봐요!')
          : Row(
              children: [
                GoldMedal(
                  size: 120,
                  child: Icon(
                    badgeIconOf(badge.iconKey),
                    size: 60,
                    color: badgeMedalIconColor,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        badge.name,
                        style: const TextStyle(
                          fontSize: 34,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${awardedAt == null ? '' : localDateKey(awardedAt!)} · $earned / $total개 모았어요',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Color(0xFF3A4A3A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

/// 얻은 배지는 색 메달과 이름, 못 얻은 배지는 '?'과 진행도 힌트, 숨긴 배지는 '숨겨진 배지'.
class _BadgeTile extends StatelessWidget {
  const _BadgeTile({
    required this.badge,
    required this.awardedAt,
    required this.hint,
  });

  final Badge badge;
  final DateTime? awardedAt;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final earned = awardedAt != null;
    final String title;
    final String caption;
    if (earned) {
      title = badge.name;
      caption = localDateKey(awardedAt!);
    } else if (badge.isHidden) {
      title = '?';
      caption = '숨겨진 배지';
    } else {
      title = '?';
      caption = hint;
    }

    return Semantics(
      label: earned ? '${badge.name} 얻었어요' : '아직 못 얻은 배지',
      child: Column(
        children: [
          GoldMedal(
            size: 96,
            locked: !earned,
            child: earned
                ? Icon(
                    badgeIconOf(badge.iconKey),
                    size: 48,
                    color: badgeMedalIconColor,
                  )
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, color: AppColors.ink),
          ),
          Text(
            caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Color(0xFF3A4A3A)),
          ),
        ],
      ),
    );
  }
}
