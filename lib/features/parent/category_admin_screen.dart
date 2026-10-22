import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/jelly_button.dart';
import 'package:sticker_world/core/widgets/outlined_text.dart';
import 'package:sticker_world/core/widgets/pattern_background.dart';
import 'package:sticker_world/core/widgets/pill_row.dart';
import 'package:sticker_world/core/widgets/screen_frame.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/providers.dart';
import 'package:sticker_world/features/stamp/stamp_widgets.dart';

/// 칭찬 카테고리와 잘못 종류 관리. 이름을 바꾸거나 끌 수 있다. 기록은 그대로 남는다.
class CategoryAdminScreen extends StatelessWidget {
  const CategoryAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ScreenFrame(
          title: '칭찬 · 잘못 종류',
          color: AppColors.mint,
          pattern: BgPattern.stripes,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            children: const [
              _KindSection(kind: 'praise', title: '칭찬 카테고리'),
              SizedBox(height: 20),
              _KindSection(kind: 'misdeed', title: '잘못 종류'),
            ],
          ),
        ),
        const BackFab(),
      ],
    );
  }
}

class _KindSection extends ConsumerWidget {
  const _KindSection({required this.kind, required this.title});

  final String kind;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories =
        ref.watch(allCategoriesProvider(kind)).value ?? const <Category>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 26, color: AppColors.white),
          ),
        ),
        for (final category in categories)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: PillRow(
              accent: Color(category.colorValue),
              leading: const Icon(Icons.label_rounded, color: AppColors.ink),
              title: category.name,
              subtitle: category.isActive
                  ? '스티커 화면에 보여요 · 눌러서 이름 바꾸기'
                  : '꺼 둠 · 기록은 그대로 남아요',
              trailing: Switch(
                value: category.isActive,
                onChanged: (on) => ref
                    .read(catalogRepositoryProvider)
                    .setCategoryActive(category.id, active: on),
              ),
              onTap: () => _rename(context, ref, category),
            ),
          ),
        JellyButton(
          color: AppColors.gold,
          height: 72,
          semanticLabel: '$title 추가',
          onTap: () => _add(context, ref),
          child: const Center(child: OutlinedText('+ 추가', fontSize: 28)),
        ),
      ],
    );
  }

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    final name = await _askName(
      context,
      title: '이름 바꾸기',
      initial: category.name,
    );
    if (name != null) {
      await ref
          .read(catalogRepositoryProvider)
          .renameCategory(category.id, name);
    }
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final name = await _askName(context, title: '새 항목 이름');
    if (name != null) {
      await ref
          .read(catalogRepositoryProvider)
          .addCategory(
            kind: kind,
            name: name,
            colorValue: AppColors.purple.toARGB32(),
          );
    }
  }
}

/// 이름을 물어본다. 비어 있거나 취소하면 null.
Future<String?> _askName(
  BuildContext context, {
  required String title,
  String initial = '',
}) async {
  final controller = TextEditingController(text: initial);
  final result = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        style: const TextStyle(fontSize: 24),
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
  final trimmed = result?.trim() ?? '';
  return trimmed.isEmpty ? null : trimmed;
}
