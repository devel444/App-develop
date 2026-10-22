import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/jelly_button.dart';
import 'package:sticker_world/core/widgets/outlined_text.dart';
import 'package:sticker_world/core/widgets/pattern_background.dart';
import 'package:sticker_world/core/widgets/screen_frame.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/providers.dart';
import 'package:sticker_world/domain/routine_rules.dart';
import 'package:sticker_world/features/stamp/stamp_widgets.dart';
import 'package:sticker_world/features/today/routine_icons.dart';

/// 루틴 관리 (엄마·아빠 PIN 후): 추가, 고치기, 순서 바꾸기, 숨기기.
class RoutineAdminScreen extends ConsumerWidget {
  const RoutineAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routinesProvider).value ?? const <Routine>[];

    return Stack(
      fit: StackFit.expand,
      children: [
        ScreenFrame(
          title: '루틴 관리',
          color: AppColors.green,
          pattern: BgPattern.stripes,
          child: Column(
            children: [
              Expanded(
                child: routines.isEmpty
                    ? const Center(child: HintText('아직 루틴이 없어요. 아래에서 추가해 주세요.'))
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                        itemCount: routines.length,
                        onReorderItem: (oldIndex, newIndex) {
                          final ids = [for (final r in routines) r.id];
                          final moved = ids.removeAt(oldIndex);
                          ids.insert(newIndex, moved);
                          ref.read(routineRepositoryProvider).reorder(ids);
                        },
                        itemBuilder: (context, index) {
                          final routine = routines[index];
                          return Padding(
                            key: ValueKey(routine.id),
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _RoutineRow(
                              routine: routine,
                              onTap: () => _edit(context, ref, routine),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: JellyButton(
                  color: AppColors.gold,
                  height: 88,
                  semanticLabel: '루틴 추가',
                  onTap: () => _edit(context, ref, null),
                  child: const Center(
                    child: OutlinedText('+ 루틴 추가', fontSize: 34),
                  ),
                ),
              ),
            ],
          ),
        ),
        const BackFab(),
      ],
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, Routine? routine) {
    return showDialog<void>(
      context: context,
      builder: (_) => _RoutineDialog(routine: routine, ref: ref),
    );
  }
}

class _RoutineRow extends StatelessWidget {
  const _RoutineRow({required this.routine, required this.onTap});

  final Routine routine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kindName = routineKinds.firstWhere((k) => k.$1 == routine.kind).$2;
    final slotName = routineSlots
        .firstWhere((s) => s.$1 == routine.timeSlot)
        .$2;

    return JellyButton(
      color: routine.isActive ? AppColors.white : const Color(0xFFD8D8E0),
      height: 96,
      borderRadius: BorderRadius.circular(36),
      semanticLabel: '${routine.title} 고치기',
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Row(
          children: [
            Icon(routineIcon(routine.iconKey), size: 40, color: AppColors.ink),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    routine.title,
                    style: const TextStyle(fontSize: 26, color: AppColors.ink),
                  ),
                  Text(
                    '$slotName · ${RoutineDays.label(routine.daysMask)} · $kindName${routine.isActive ? '' : ' · 숨김'}',
                    style: const TextStyle(
                      fontSize: 17,
                      color: Color(0xFF3A4A3A),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.drag_handle_rounded, color: AppColors.ink),
          ],
        ),
      ),
    );
  }
}

class _RoutineDialog extends StatefulWidget {
  const _RoutineDialog({required this.routine, required this.ref});

  final Routine? routine;
  final WidgetRef ref;

  @override
  State<_RoutineDialog> createState() => _RoutineDialogState();
}

class _RoutineDialogState extends State<_RoutineDialog> {
  late final TextEditingController _title = TextEditingController(
    text: widget.routine?.title ?? '',
  );
  late String _icon = widget.routine?.iconKey ?? 'star';
  late String _kind = widget.routine?.kind ?? 'normal';
  late String _slot = widget.routine?.timeSlot ?? 'morning';
  late int _days = widget.routine?.daysMask ?? RoutineDays.all;
  late int _timer = widget.routine?.timerMinutes ?? 5;
  late bool _active = widget.routine?.isActive ?? true;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _error = '루틴 이름을 적어 주세요.');
      return;
    }
    if (_days == 0) {
      setState(() => _error = '요일을 하나 이상 고라 주세요.');
      return;
    }
    final repo = widget.ref.read(routineRepositoryProvider);
    final routine = widget.routine;
    final timerMinutes = _kind == 'timer' ? _timer : null;
    if (routine == null) {
      final childId = widget.ref.read(currentChildProvider).value?.id;
      if (childId == null) {
        setState(() => _error = '아이 정보가 없어요.');
        return;
      }
      await repo.create(
        childId: childId,
        title: title,
        iconKey: _icon,
        kind: _kind,
        timeSlot: _slot,
        daysMask: _days,
        timerMinutes: timerMinutes,
      );
    } else {
      await repo.update(
        Routine(
          id: routine.id,
          childId: routine.childId,
          title: title,
          iconKey: _icon,
          kind: _kind,
          timerMinutes: timerMinutes,
          daysMask: _days,
          timeSlot: _slot,
          sortOrder: routine.sortOrder,
          isActive: _active,
        ),
      );
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _delete() async {
    final routine = widget.routine;
    if (routine == null) {
      return;
    }
    final deleted = await widget.ref
        .read(routineRepositoryProvider)
        .remove(routine.id);
    if (!mounted) {
      return;
    }
    if (!deleted) {
      setState(() => _error = '체크한 기록이 있어서 목록에서만 숨겼어요.');
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.routine == null ? '루틴 추가' : '루틴 고치기'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _title,
              style: const TextStyle(fontSize: 24),
              decoration: const InputDecoration(
                labelText: '할 일 이름',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            const Text('아이콘'),
            Wrap(
              spacing: 8,
              children: [
                for (final entry in routineIcons.entries)
                  ChoiceChip(
                    avatar: Icon(entry.value, size: 20),
                    label: const Text(''),
                    selected: _icon == entry.key,
                    onSelected: (_) => setState(() => _icon = entry.key),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            const Text('어떻게 할까요?'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final kind in routineKinds)
                  ChoiceChip(
                    label: Text(kind.$2),
                    selected: _kind == kind.$1,
                    onSelected: (_) => setState(() => _kind = kind.$1),
                  ),
              ],
            ),
            if (_kind == 'timer') ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final minutes in timerChoices)
                    ChoiceChip(
                      label: Text('$minutes분'),
                      selected: _timer == minutes,
                      onSelected: (_) => setState(() => _timer = minutes),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            const Text('언제 할까요?'),
            Wrap(
              spacing: 8,
              children: [
                for (final slot in routineSlots)
                  ChoiceChip(
                    label: Text(slot.$2),
                    selected: _slot == slot.$1,
                    onSelected: (_) => setState(() => _slot = slot.$1),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            const Text('무슨 요일에 할까요?'),
            Wrap(
              spacing: 6,
              children: [
                for (var i = 0; i < 7; i++)
                  FilterChip(
                    label: Text(RoutineDays.dayNames[i]),
                    selected: _days & (1 << i) != 0,
                    onSelected: (_) =>
                        setState(() => _days = RoutineDays.toggle(_days, i)),
                  ),
              ],
            ),
            if (widget.routine != null)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('오늘 할 일에 보이기'),
                value: _active,
                onChanged: (value) => setState(() => _active = value),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: const TextStyle(color: AppColors.misdeed),
                ),
              ),
          ],
        ),
      ),
      actions: [
        if (widget.routine != null)
          TextButton(
            onPressed: _delete,
            child: const Text(
              '지우기',
              style: TextStyle(color: AppColors.misdeed),
            ),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        FilledButton(onPressed: _save, child: const Text('저장')),
      ],
    );
  }
}
