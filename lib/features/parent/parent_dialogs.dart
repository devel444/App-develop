import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sticker_world/core/router/routes.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/providers.dart';

/// 부모 모드 '확인할 일' 종류.
enum PendingKind { bonus, voucher, diary }

Future<void> showPendingDialog(BuildContext context, PendingKind kind) {
  return showDialog<void>(
    context: context,
    builder: (_) => _PendingDialog(kind: kind),
  );
}

/// 아이 이름 고치기.
Future<void> renameChildDialog(BuildContext context, WidgetRef ref) async {
  final child = ref.read(currentChildProvider).value;
  if (child == null) {
    return;
  }
  final controller = TextEditingController(text: child.name);
  final name = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('아이 이름'),
      content: TextField(
        controller: controller,
        autofocus: true,
        style: const TextStyle(fontSize: 26),
        decoration: const InputDecoration(border: OutlineInputBorder()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(controller.text),
          child: const Text('저장'),
        ),
      ],
    ),
  );
  controller.dispose();
  if (name != null && name.trim().isNotEmpty) {
    await ref
        .read(childRepositoryProvider)
        .rename(childId: child.id, name: name);
  }
}

/// 앱 고정 안내. 기기마다 메뉴 이름이 달라서 큰 틀만 적는다.
Future<void> showPinningGuide(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('앱 고정 안내'),
      content: const SingleChildScrollView(
        child: Text(
          '아이가 다른 앱으로 나가지 못하게 화면을 고정할 수 있어요.\n\n'
          '1. 스티커 월드를 연 뒤 최근 앱 버튼(네모)을 눌러요.\n'
          '2. 앱 카드의 핀 모양 또는 "고정" 메뉴를 눌러요.\n'
          '3. 메뉴가 없으면 설정에서 "화면 고정" 또는 "앱 고정"을 찾아 켜요.\n\n'
          '풀 때는 뒤로 버튼과 최근 앱 버튼을 함께 누르고 있으면 돼요. '
          '기기마다 다를 수 있어요.',
          style: TextStyle(fontSize: 20, height: 1.4),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('알았어요'),
        ),
      ],
    ),
  );
}

class _PendingDialog extends ConsumerWidget {
  const _PendingDialog({required this.kind});

  final PendingKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = switch (kind) {
      PendingKind.bonus => _bonusRows(ref),
      PendingKind.voucher => _voucherRows(ref),
      PendingKind.diary => _diaryRows(context, ref),
    };
    return AlertDialog(
      title: Text(switch (kind) {
        PendingKind.bonus => '보너스 대기',
        PendingKind.voucher => '교환권 전달',
        PendingKind.diary => '답장 안 한 일기',
      }),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: rows.isEmpty
                ? const [Text('모두 처리했어요!', style: TextStyle(fontSize: 22))]
                : rows,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('닫기'),
        ),
      ],
    );
  }

  List<Widget> _bonusRows(WidgetRef ref) {
    final bonuses =
        ref.watch(pendingBonusesProvider).value ?? const <DailyClear>[];
    return [
      for (final bonus in bonuses)
        _ActionRow(
          text: '${bonus.localDate} 올클리어 보너스',
          buttonLabel: '스티커 붙이기',
          onPressed: () =>
              ref.read(routineRepositoryProvider).confirmBonus(bonus.id),
        ),
    ];
  }

  List<Widget> _voucherRows(WidgetRef ref) {
    final names = {
      for (final reward
          in ref.watch(allRewardsProvider).value ?? const <Reward>[])
        reward.id: reward.name,
    };
    final vouchers = [
      for (final redemption
          in ref.watch(redemptionsProvider).value ?? const <Redemption>[])
        if (redemption.deliveredAt == null) redemption,
    ];
    return [
      for (final redemption in vouchers)
        _ActionRow(
          text:
              '${redemption.voucherNo} · ${names[redemption.rewardId] ?? '선물'}',
          buttonLabel: '건네줬어요',
          onPressed: () => ref
              .read(rewardRepositoryProvider)
              .markDelivered(redemption.id, DateTime.now()),
        ),
    ];
  }

  List<Widget> _diaryRows(BuildContext context, WidgetRef ref) {
    final entries = [
      for (final entry
          in ref.watch(diaryEntriesProvider).value ?? const <DiaryEntry>[])
        if (entry.body.isNotEmpty && entry.parentReply == null) entry,
    ];
    final router = GoRouter.of(context);
    final navigator = Navigator.of(context);
    return [
      for (final entry in entries)
        _ActionRow(
          text:
              '${entry.localDate} · ${entry.title.isEmpty ? '(제목 없음)' : entry.title}',
          buttonLabel: '답장 쓰기',
          onPressed: () async {
            navigator.pop();
            router.go(Routes.diary);
          },
        ),
    ];
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.text,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String text;
  final String buttonLabel;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 20, color: AppColors.ink),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(onPressed: onPressed, child: Text(buttonLabel)),
        ],
      ),
    );
  }
}
