import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/data/providers.dart';
import 'package:sticker_world/domain/character_roster.dart';

/// 맵의 캐릭터 토큰을 누르면 뜬다. 8칸 중 하나를 고르면 홈과 맵의 캐릭터가 바뀐다.
Future<void> showCharacterPicker(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const _CharacterPickerDialog(),
  );
}

class _CharacterPickerDialog extends ConsumerWidget {
  const _CharacterPickerDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roster =
        ref.watch(characterRosterProvider).value ?? CharacterRoster.empty;

    return AlertDialog(
      title: const Text('캐릭터 고르기'),
      content: SizedBox(
        width: 560,
        height: 300,
        child: GridView.count(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            for (final slot in roster.slots)
              _SlotChoice(
                slot: slot,
                selected: slot.index == roster.active,
                onTap: () async {
                  await ref
                      .read(settingsRepositoryProvider)
                      .set('character_active', '${slot.index}');
                  ref.invalidate(characterRosterProvider);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
          ],
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
}

class _SlotChoice extends StatelessWidget {
  const _SlotChoice({
    required this.slot,
    required this.selected,
    required this.onTap,
  });

  final CharacterSlot slot;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final photo = slot.photo;
    return Semantics(
      button: true,
      selected: selected,
      label: '${slot.name} ${selected ? '지금 쓰는 캐릭터' : ''}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 84,
              height: 84,
              clipBehavior: Clip.antiAlias,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cream,
                border: Border.all(
                  color: selected ? AppColors.gold : AppColors.ink,
                  width: selected ? 6 : 2,
                ),
              ),
              child: photo == null
                  ? Text(
                      '${slot.index + 1}',
                      style: const TextStyle(
                        fontSize: 36,
                        color: AppColors.ink,
                      ),
                    )
                  : Image.file(
                      File(photo),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Text(
                        '${slot.index + 1}',
                        style: const TextStyle(
                          fontSize: 36,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 4),
            Text(
              slot.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, color: AppColors.ink),
            ),
          ],
        ),
      ),
    );
  }
}
