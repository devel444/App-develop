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
import 'package:sticker_world/data/repositories/sticker_repository.dart';

enum _RemovePhase { form, falling, result }

/// 스티커 빼기 (PIN은 이미 맞춘 뒤에 들어온다). 사유는 꼭 적어야 한다.
/// 옐로카드 설정이 켜져 있으면 이번 주 첫 번째 잘못은 경고만 남긴다.
class RemoveScreen extends ConsumerStatefulWidget {
  const RemoveScreen({super.key});

  @override
  ConsumerState<RemoveScreen> createState() => _RemoveScreenState();
}

class _RemoveScreenState extends ConsumerState<RemoveScreen> {
  final _memoController = TextEditingController();
  final _promiseController = TextEditingController();
  int? _categoryId;
  String _categoryName = '';
  int _amount = 1;
  bool _warnOnly = false;
  String? _error;
  bool _busy = false;
  _RemovePhase _phase = _RemovePhase.form;
  MisdeedOutcome? _outcome;
  int _undoSeconds = 10;

  @override
  void dispose() {
    _memoController.dispose();
    _promiseController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final childId = ref.read(currentChildProvider).value?.id;
    final categoryId = _categoryId;
    if (childId == null || categoryId == null) {
      return;
    }
    final memo = _memoController.text.trim();
    if (memo.isEmpty) {
      setState(() => _error = '무엇을 잘못했는지 적어 주세요.');
      return;
    }
    final promise = _promiseController.text.trim();
    final yellowCardOn =
        ref.read(stickerSettingsProvider).value?.yellowCardOn ?? false;

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(stickerRepositoryProvider)
          .recordMisdeed(
            childId: childId,
            categoryId: categoryId,
            amount: _amount,
            memo: memo,
            nextPromise: promise.isEmpty ? null : promise,
            warnOnly: _warnOnly,
            yellowCardOn: yellowCardOn,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _outcome = result.outcome;
        _phase = result.outcome == MisdeedOutcome.removed
            ? _RemovePhase.falling
            : _RemovePhase.result;
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
        ref.watch(categoriesProvider('misdeed')).value ?? const <Category>[];
    _undoSeconds =
        ref.watch(stickerSettingsProvider).value?.undoSeconds ?? _undoSeconds;

    return Stack(
      fit: StackFit.expand,
      children: [
        ScreenFrame(
          title: '스티커 빼기',
          color: AppColors.coral,
          pattern: BgPattern.stripes,
          child: switch (_phase) {
            _RemovePhase.form => _form(categories),
            _RemovePhase.falling => _form(categories),
            _RemovePhase.result => _result(),
          },
        ),
        if (_phase == _RemovePhase.falling)
          StickerFallCelebration(
            onFinished: () {
              if (mounted) {
                setState(() => _phase = _RemovePhase.result);
              }
            },
          ),
        const BackFab(),
      ],
    );
  }

  Widget _form(List<Category> categories) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        children: [
          WhiteFrameCard(
            headerTitle: '어떤 약속을 못 지켰나요?',
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
                      color: AppColors.misdeed,
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
            headerTitle: '몇 개 뺄까요?',
            child: Row(
              children: [
                for (final amount in [1, 2])
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: ChoiceButton(
                        label: '-$amount',
                        selected: !_warnOnly && _amount == amount,
                        color: AppColors.misdeed,
                        onTap: () => setState(() {
                          _amount = amount;
                          _warnOnly = false;
                        }),
                      ),
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: ChoiceButton(
                      label: '경고만',
                      selected: _warnOnly,
                      color: AppColors.orange,
                      onTap: () => setState(() => _warnOnly = true),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          WhiteFrameCard(
            headerTitle: '무엇이 있었나요?',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _memoController,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 24),
                  decoration: const InputDecoration(
                    hintText: '예: 게임 30분 약속했는데 1시간 했어요',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() => _error = null),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _promiseController,
                  style: const TextStyle(fontSize: 24),
                  decoration: const InputDecoration(
                    hintText: '다음엔 이렇게 해 볼까? (선택)',
                    border: OutlineInputBorder(),
                  ),
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
            color: AppColors.ink,
            height: 104,
            semanticLabel: '기록하고 빼기',
            onTap: _categoryId == null || _busy ? null : _submit,
            child: const Center(child: OutlinedText('기록하고 빼기', fontSize: 40)),
          ),
          if (_categoryId == null)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: HintText('먼저 어떤 약속인지 골라 주세요.'),
            ),
        ],
      ),
    );
  }

  Widget _result() {
    if (_outcome == MisdeedOutcome.warned) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: WhiteFrameCard(
            headerTitle: '옐로카드 한 장!',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '이번에는 스티커가 그대로예요.\n같은 약속을 또 어기면 그때는 한 칸 뒤로 가요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, color: AppColors.ink),
                ),
                const SizedBox(height: 20),
                JellyButton(
                  color: AppColors.gold,
                  height: 80,
                  semanticLabel: '확인',
                  onTap: () => context.pop(true),
                  child: const Center(child: OutlinedText('확인', fontSize: 30)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: UndoCard(
          message: '$_categoryName 기록했어요.\n괜찮아, 다시 모으면 돼.',
          seconds: _undoSeconds,
          onUndo: _undo,
          onDone: () => context.pop(true),
        ),
      ),
    );
  }
}
