import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sticker_world/core/router/routes.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/jelly_button.dart';
import 'package:sticker_world/core/widgets/outlined_text.dart';
import 'package:sticker_world/core/widgets/pattern_background.dart';
import 'package:sticker_world/core/widgets/pill_row.dart';
import 'package:sticker_world/core/widgets/screen_frame.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/providers.dart';
import 'package:sticker_world/features/parent/parent_dialogs.dart';

/// 부모 모드 메뉴 (PIN을 맞춘 뒤에만 열린다). 2분 동안 손대지 않으면 저절로 잠긴다.
class ParentMenuScreen extends ConsumerStatefulWidget {
  const ParentMenuScreen({super.key});

  static const autoLockAfter = Duration(minutes: 2);

  @override
  ConsumerState<ParentMenuScreen> createState() => _ParentMenuScreenState();
}

class _ParentMenuScreenState extends ConsumerState<ParentMenuScreen> {
  Timer? _autoLock;

  @override
  void initState() {
    super.initState();
    _restartAutoLock();
  }

  @override
  void dispose() {
    _autoLock?.cancel();
    super.dispose();
  }

  void _restartAutoLock() {
    _autoLock?.cancel();
    _autoLock = Timer(ParentMenuScreen.autoLockAfter, _lock);
  }

  void _lock() {
    if (mounted) {
      context.go(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = ref.watch(currentChildProvider).value;
    final yellowCardOn =
        ref.watch(stickerSettingsProvider).value?.yellowCardOn ?? false;
    final bonuses =
        ref.watch(pendingBonusesProvider).value ?? const <DailyClear>[];
    final vouchers = [
      for (final redemption
          in ref.watch(redemptionsProvider).value ?? const <Redemption>[])
        if (redemption.deliveredAt == null) redemption,
    ];
    final unanswered = [
      for (final entry
          in ref.watch(diaryEntriesProvider).value ?? const <DiaryEntry>[])
        if (entry.body.isNotEmpty && entry.parentReply == null) entry,
    ];

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _restartAutoLock(),
      child: ScreenFrame(
        title: '부모 모드',
        color: AppColors.purple,
        pattern: BgPattern.dots,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          children: [
            if (bonuses.isNotEmpty ||
                vouchers.isNotEmpty ||
                unanswered.isNotEmpty) ...[
              const _Heading('확인할 일'),
              if (bonuses.isNotEmpty)
                _row(
                  icon: Icons.card_giftcard_rounded,
                  accent: AppColors.gold,
                  title: '보너스 대기 ${bonuses.length}개',
                  subtitle: '올클리어 보너스를 붙여 줘요',
                  onTap: () => showPendingDialog(context, PendingKind.bonus),
                ),
              if (vouchers.isNotEmpty)
                _row(
                  icon: Icons.confirmation_number_rounded,
                  accent: AppColors.orange,
                  title: '교환권 ${vouchers.length}개 아직 안 받았어요',
                  subtitle: '아이에게 건네주면 눌러요',
                  onTap: () => showPendingDialog(context, PendingKind.voucher),
                ),
              if (unanswered.isNotEmpty)
                _row(
                  icon: Icons.mail_rounded,
                  accent: AppColors.pink,
                  title: '답장 안 한 일기 ${unanswered.length}편',
                  subtitle: '일기 탭에서 답장을 써요',
                  onTap: () => showPendingDialog(context, PendingKind.diary),
                ),
              const SizedBox(height: 12),
            ],
            const _Heading('아이'),
            _row(
              icon: Icons.face_rounded,
              accent: AppColors.yellow,
              title: '아이 이름 고치기',
              subtitle: child?.name ?? '',
              onTap: () => renameChildDialog(context, ref),
            ),
            _row(
              icon: Icons.task_alt_rounded,
              accent: AppColors.green,
              title: '할 일 관리',
              subtitle: '매일 할 일과 요일, 시간',
              onTap: () => context.push(Routes.routines),
            ),
            _row(
              icon: Icons.card_giftcard_rounded,
              accent: AppColors.gold,
              title: '선물 관리',
              subtitle: '선물 이름과 가격',
              onTap: () => context.push(Routes.rewards),
            ),
            _row(
              icon: Icons.sports_esports_rounded,
              accent: AppColors.blue,
              title: '듀오링고 설정',
              subtitle: '자동 체크 방법',
              onTap: () => context.push(Routes.duolingo),
            ),
            const _Heading('규칙'),
            _row(
              icon: Icons.category_rounded,
              accent: AppColors.mint,
              title: '칭찬 · 잘못 종류',
              subtitle: '이름 바꾸기, 끄고 켜기',
              onTap: () => context.push(Routes.parentCategories),
            ),
            _row(
              icon: Icons.warning_amber_rounded,
              accent: AppColors.orange,
              title: '옐로카드',
              subtitle: '같은 잘못은 주에 처음 한 번 경고만',
              trailing: Switch(
                value: yellowCardOn,
                onChanged: (on) => _setYellowCard(on),
              ),
              onTap: () => _setYellowCard(!yellowCardOn),
            ),
            _row(
              icon: Icons.workspace_premium_rounded,
              accent: AppColors.gold,
              title: '배지 켜기 · 끄기',
              subtitle: '꺼 둔 배지는 얻지 않아요',
              onTap: () => context.push(Routes.parentBadges),
            ),
            const _Heading('꾸미기 · 보관'),
            _row(
              icon: Icons.palette_rounded,
              accent: AppColors.pink,
              title: '캐릭터 · 꾸미기',
              subtitle: '직접 넣은 그림과 소리',
              onTap: () => context.push(Routes.parentCustom),
            ),
            _row(
              icon: Icons.backup_rounded,
              accent: AppColors.blue,
              title: '백업 · 되돌리기',
              subtitle: '기록을 파일로 보관해요',
              onTap: () => context.push(Routes.parentBackup),
            ),
            _row(
              icon: Icons.lock_reset_rounded,
              accent: AppColors.purple,
              title: '비밀번호 바꾸기',
              subtitle: '새 4자리 번호와 복구 코드',
              onTap: () => context.push(Routes.parentPin),
            ),
            _row(
              icon: Icons.push_pin_rounded,
              accent: AppColors.yellow,
              title: '앱 고정 안내',
              subtitle: '아이가 다른 앱으로 못 나가게',
              onTap: () => showPinningGuide(context),
            ),
            const SizedBox(height: 16),
            JellyButton(
              color: AppColors.white,
              height: 80,
              semanticLabel: '잠그고 나가기',
              onTap: _lock,
              child: const Center(child: OutlinedText('잠그고 나가기', fontSize: 30)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setYellowCard(bool on) async {
    await ref
        .read(settingsRepositoryProvider)
        .set('yellow_card_on', on ? '1' : '0');
    ref.invalidate(stickerSettingsProvider);
  }

  Widget _row({
    required IconData icon,
    required Color accent,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PillRow(
        accent: accent,
        leading: Icon(icon, size: 44, color: AppColors.ink),
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 0, 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 24, color: AppColors.white),
      ),
    );
  }
}
