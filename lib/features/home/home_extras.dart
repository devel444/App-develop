import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sticker_world/core/assets/asset_resolver.dart';
import 'package:sticker_world/core/router/routes.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/time/local_date.dart';
import 'package:sticker_world/core/widgets/jelly_button.dart';
import 'package:sticker_world/core/widgets/outlined_text.dart';
import 'package:sticker_world/core/widgets/white_frame_card.dart';
import 'package:sticker_world/data/providers.dart';
import 'package:sticker_world/features/home/home_landscape.dart';
import 'package:sticker_world/features/world/world_layout.dart';
import 'package:sticker_world/domain/home_greeting.dart';

/// 시간대 인사말 (홈 이름 아래).
class HomeGreeting extends StatelessWidget {
  const HomeGreeting({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      greetingFor(DateTime.now()),
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 26,
        color: AppColors.white,
        shadows: [Shadow(color: Color(0x80000000), offset: Offset(0, 2))],
      ),
    );
  }
}

/// 오늘 할 일 진행률 막대 (몇 개 남았는지). 할 일이 없으면 아무것도 그리지 않는다.
class TodayProgressBar extends ConsumerWidget {
  const TodayProgressBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(dailyProgressProvider);
    if (progress.total == 0) {
      return const SizedBox.shrink();
    }
    final message = progress.finished
        ? '오늘 할 일을 모두 끝냈어요!'
        : '오늘 할 일 ${progress.left}개 남았어요';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          OutlinedText(message, fontSize: 24, outlineWidth: 2),
          const SizedBox(height: 6),
          Container(
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFFE3D6BC),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: AppColors.ink, width: 3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.fraction,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 오늘 처음 열었을 때 칭찬 문구 팝업을 띄운다 (하루 한 번, 절반쯤만).
/// 화면에는 아무것도 그리지 않는다.
class PraiseOnce extends ConsumerWidget {
  const PraiseOnce({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<String?>>(dailyPraiseProvider, (_, next) {
      final text = next.value;
      if (text == null || !context.mounted) {
        return;
      }
      showDialog<void>(
        context: context,
        builder: (dialogContext) => Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: WhiteFrameCard(
              headerTitle: '오늘의 칭찬',
              headerColor: AppColors.pink,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 40, color: AppColors.ink),
                  ),
                  const SizedBox(height: 20),
                  JellyButton(
                    color: AppColors.gold,
                    height: 80,
                    semanticLabel: '좋아요',
                    onTap: () => Navigator.of(dialogContext).pop(),
                    child: const Center(
                      child: OutlinedText('좋아요!', fontSize: 34),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
    return const SizedBox.shrink();
  }
}

/// 일요일 저녁 이번 주 리포트 안내. "보기"를 누르면 기록 탭으로, "닫기"를 누르면 이번 주에는 다시 안 뜬다.
class WeeklyReportBanner extends ConsumerWidget {
  const WeeklyReportBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final show = ref.watch(weeklyReportBannerProvider).value ?? false;
    if (!show) {
      return const SizedBox.shrink();
    }

    Future<void> markSeen() async {
      await ref
          .read(settingsRepositoryProvider)
          .set('report_seen_week', weekStartKey(DateTime.now()));
      ref.invalidate(weeklyReportBannerProvider);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.gold,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(color: AppColors.goldDeep, offset: Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                '이번 주 리포트가 나왔어요!',
                style: TextStyle(fontSize: 24, color: AppColors.ink),
              ),
            ),
            TextButton(
              onPressed: markSeen,
              child: const Text('닫기', style: TextStyle(color: AppColors.ink)),
            ),
            FilledButton(
              onPressed: () async {
                await markSeen();
                if (context.mounted) {
                  context.go(Routes.records);
                }
              },
              child: const Text('보기'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 홈 뒤 배경. 지금 월드의 사진(또는 개인용 world{n}.png)이 있으면 그것을, 없으면 기본 풍경을 그린다.
/// 스테이지(월드)가 넘어가면 배경도 함께 바뀐다.
class HomeBackground extends ConsumerWidget {
  const HomeBackground({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(ledgerProvider).value?.balance ?? 0;
    final world = WorldLayout.worldFor(balance);
    final photo = ref.watch(worldPhotoProvider(world)).value;
    final custom = AssetResolver.custom('world${world + 1}.png');
    const landscape = CustomPaint(painter: HomeLandscapePainter());

    if (photo == null && custom == null) {
      return const SizedBox.expand(child: landscape);
    }
    final image = photo != null
        ? Image.file(
            File(photo),
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => landscape,
          )
        : Image.asset(custom!, fit: BoxFit.cover);
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          image,
          const ColoredBox(color: Color(0x33FFFFFF)),
        ],
      ),
    );
  }
}
