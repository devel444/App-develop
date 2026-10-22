import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/jelly_button.dart';
import 'package:sticker_world/core/widgets/outlined_text.dart';
import 'package:sticker_world/core/widgets/pattern_background.dart';
import 'package:sticker_world/core/widgets/screen_frame.dart';
import 'package:sticker_world/core/widgets/white_frame_card.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/providers.dart';
import 'package:sticker_world/domain/sticker_rules.dart';
import 'package:sticker_world/features/stamp/stamp_celebration.dart';
import 'package:sticker_world/features/stamp/stamp_widgets.dart';
import 'package:sticker_world/features/stamp/undo_card.dart';

enum _StampPhase { form, celebrating, result }

/// 스티커 붙이기 (PIN은 이미 맞춘 뒤에 들어온다).
/// 카테고리 → 개수 → 한마디 → 도장 쿵! → 되돌리기 카드.
class StampScreen extends ConsumerStatefulWidget {
  const StampScreen({super.key});

  @override
  ConsumerState<StampScreen> createState() => _StampScreenState();
}

class _StampScreenState extends ConsumerState<StampScreen> {
  final _memoController = TextEditingController();
  int? _categoryId;
  String _categoryName = '';
  int _amount = 1;
  String? _error;
  bool _busy = false;
  _StampPhase _phase = _StampPhase.form;
  int _undoSeconds = 10;

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _stamp() async {
    final childId = ref.read(currentChildProvider).value?.id;
    final categoryId = _categoryId;
    if (childId == null || categoryId == null) {
      return;
    }
    final memo = _memoController.text.trim();

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(stickerRepositoryProvider)
          .earn(
            childId: childId,
            categoryId: categoryId,
            amount: _amount,
            memo: memo.isEmpty ? null : memo,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _phase = _StampPhase.celebrating;
      });
    } on StickerRuleException catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = error.message;
        });
      }
    }
  }

  Future<void> _undo() async {
    final childId = ref.read(currentChildProvider).value?.id;
    if (childId == null) {
      return;
    }
    await ref
        .read(stickerRepositoryProvider)
        .undoLast(childId: childId, undoSeconds: _undoSeconds);
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        ref.watch(categoriesProvider('praise')).value ?? const <Category>[];
    final templates = ref.watch(praiseTextsProvider).value ?? const <String>[];
    _undoSeconds =
        ref.watch(stickerSettingsProvider).value?.undoSeconds ?? _undoSeconds;

    return Stack(
      fit: StackFit.expand,
      children: [
        ScreenFrame(
          title: '스티커 붙이기',
          color: AppColors.blue,
          pattern: BgPattern.dots,
          child: switch (_phase) {
            _StampPhase.form => _form(categories, templates),
            _StampPhase.celebrating => _form(categories, templates),
            _StampPhase.result => _result(),
          },
        ),
        if (_phase == _StampPhase.celebrating)
          StampCelebration(
            onFinished: () {
              if (mounted) {
                setState(() => _phase = _StampPhase.result);
              }
            },
          ),
        const BackFab(),
      ],
    );
  }

  Widget _form(List<Category> categories, List<String> templates) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        children: [
          WhiteFrameCard(
            headerTitle: '무엇을 잘했나요?',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final category in categories)
                  SizedBox(
                    width: 220,
                    height: 84,
                    child: ChoiceButton(
                      label: category.name,
                      selected: _categoryId == category.id,
                      color: Color(category.colorValue),
                      onTap: () => setState(() {
                        _categoryId = category.id;
                        _categoryName = category.name;
                      }),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          WhiteFrameCard(
            headerTitle: '몇 개 붙일까요?',
            child: Row(
              children: [
                for (final amount in [1, 2, 3])
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: ChoiceButton(
                        label: '+$amount',
                        selected: _amount == amount,
                        onTap: () => setState(() => _amount = amount),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          WhiteFrameCard(
            headerTitle: '칭찬 한마디 (선택)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final text in templates)
                      SizedBox(
                        height: 60,
                        width: 200,
                        child: ChoiceButton(
                          label: text,
                          height: 60,
                          selected: _memoController.text == text,
                          color: AppColors.mint,
                          onTap: () => setState(() {
                            _memoController.text = text;
                          }),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _memoController,
                  style: const TextStyle(fontSize: 24),
                  decoration: const InputDecoration(
                    hintText: '직접 쓰기',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, color: AppColors.white),
              ),
            ),
          const SizedBox(height: 20),
          JellyButton(
            color: AppColors.red,
            height: 104,
            semanticLabel: '도장 쿵!',
            onTap: _categoryId == null || _busy ? null : _stamp,
            child: const Center(child: OutlinedText('도장 쿵!', fontSize: 48)),
          ),
          if (_categoryId == null)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: HintText('먼저 무엇을 잘했는지 골라 주세요.'),
            ),
        ],
      ),
    );
  }

  Widget _result() {
    final memo = _memoController.text.trim();
    final message = memo.isEmpty
        ? '$_categoryName 스티커 +$_amount 예요!'
        : '$_categoryName 스티커 +$_amount\n"$memo"';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: UndoCard(
          message: message,
          seconds: _undoSeconds,
          onUndo: () async {
            await _undo();
          },
          onDone: () => context.pop(true),
        ),
      ),
    );
  }
}
