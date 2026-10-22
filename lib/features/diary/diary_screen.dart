import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/time/local_date.dart';
import 'package:sticker_world/core/widgets/jelly_button.dart';
import 'package:sticker_world/core/widgets/outlined_text.dart';
import 'package:sticker_world/core/widgets/pattern_background.dart';
import 'package:sticker_world/core/widgets/screen_frame.dart';
import 'package:sticker_world/core/widgets/white_frame_card.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/providers.dart';
import 'package:sticker_world/features/diary/diary_options.dart';
import 'package:sticker_world/features/pin/parent_pin_screen.dart';
import 'package:sticker_world/features/records/record_labels.dart';
import 'package:sticker_world/features/stamp/stamp_widgets.dart';
import 'package:sticker_world/features/today/clear_celebration.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// 일기 탭. 오늘 쓰기와 지난 일기를 고를 수 있다.
class DiaryScreen extends ConsumerStatefulWidget {
  const DiaryScreen({super.key});

  @override
  ConsumerState<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends ConsumerState<DiaryScreen> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  final _speech = SpeechToText();
  bool _showPast = false;
  bool _loaded = false;
  String? _weather;
  int? _mood;
  bool _saving = false;
  bool _listening = false;
  String _speechBase = '';
  String? _message;
  bool _showClear = false;
  bool _bonusPending = false;

  String get _today => localDateKey(DateTime.now());

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _speech.stop();
    super.dispose();
  }

  void _fill(DiaryEntry? entry) {
    _loaded = true;
    if (entry == null) {
      return;
    }
    _title.text = entry.title;
    _body.text = entry.body;
    _weather = entry.weather;
    _mood = entry.mood;
  }

  Future<void> _save() async {
    final child = ref.read(currentChildProvider).value;
    if (child == null) {
      return;
    }
    setState(() {
      _saving = true;
      _message = null;
    });
    try {
      await ref
          .read(diaryRepositoryProvider)
          .save(
            childId: child.id,
            localDate: _today,
            weather: _weather,
            mood: _mood,
            title: _title.text,
            body: _body.text,
          );
    } on ArgumentError catch (error) {
      setState(() {
        _saving = false;
        _message = '${error.message}';
      });
      return;
    }

    final completion = await ref
        .read(routineRepositoryProvider)
        .completeFirstDue(childId: child.id, kind: 'diary', source: 'auto');
    if (!mounted) {
      return;
    }
    setState(() {
      _saving = false;
      _message = completion == null || completion.alreadyDone
          ? '저장했어요!'
          : '저장했어요! 일기 쓰기를 체크했어요.';
      if (completion?.cleared ?? false) {
        _bonusPending = completion!.bonusPending;
        _showClear = true;
      }
    });
  }

  Future<void> _toggleSpeech() async {
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      return;
    }
    final ready = await _speech.initialize(
      onError: (_) {
        if (mounted) {
          setState(() => _listening = false);
        }
      },
    );
    if (!ready) {
      setState(() => _message = '이 태블릿에서는 말로 쓰기를 쓸 수 없어요.');
      return;
    }
    _speechBase = _body.text.trim();
    setState(() => _listening = true);
    await _speech.listen(
      listenOptions: SpeechListenOptions(localeId: 'ko_KR'),
      onResult: (result) {
        final spoken = result.recognizedWords;
        final text = _speechBase.isEmpty ? spoken : '$_speechBase $spoken';
        _body.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      },
    );
  }

  Future<void> _reply(DiaryEntry entry) async {
    if (!await requireParentPin(context) || !mounted) {
      return;
    }
    final controller = TextEditingController(text: entry.parentReply ?? '');
    final text = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('엄마·아빠 답장'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          style: const TextStyle(fontSize: 22),
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('보내기'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (text != null) {
      await ref.read(diaryRepositoryProvider).reply(entry.id, text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final todayAsync = ref.watch(diaryOnProvider(_today));
    ref.listen<AsyncValue<DiaryEntry?>>(diaryOnProvider(_today), (
      previous,
      next,
    ) {
      if (!_loaded && next.hasValue) {
        setState(() => _fill(next.value));
      }
    });
    final entries =
        ref.watch(diaryEntriesProvider).value ?? const <DiaryEntry>[];

    return Stack(
      fit: StackFit.expand,
      children: [
        ScreenFrame(
          title: '일기',
          color: AppColors.orange,
          pattern: BgPattern.dots,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _Tab(
                        label: '오늘 쓰기',
                        selected: !_showPast,
                        onTap: () => setState(() => _showPast = false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Tab(
                        label: '지난 일기',
                        selected: _showPast,
                        onTap: () => setState(() => _showPast = true),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _showPast
                    ? _PastList(
                        entries: entries,
                        today: _today,
                        onOpen: (entry) => _showDetail(entry),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: _editor(todayAsync.value),
                      ),
              ),
            ],
          ),
        ),
        if (_showClear)
          ClearCelebration(
            bonusPending: _bonusPending,
            onDone: () => setState(() => _showClear = false),
          ),
        const BackFab(),
      ],
    );
  }

  Widget _editor(DiaryEntry? today) {
    final stickers =
        ref.watch(stickerEventsOnProvider(_today)).value ?? const [];
    final names =
        ref.watch(categoryNamesProvider).value ?? const <int, String>{};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${DateTime.now().month}월 ${DateTime.now().day}일 오늘의 일기',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 30, color: AppColors.ink),
        ),
        const SizedBox(height: 12),
        WhiteFrameCard(
          headerTitle: '날씨와 기분',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  for (final w in diaryWeathers)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceButton(
                          label: w.$2,
                          height: 72,
                          selected: _weather == w.$1,
                          color: AppColors.blue,
                          onTap: () => setState(() => _weather = w.$1),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final m in diaryMoods)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: _MoodButton(
                          icon: m.$3,
                          label: m.$2,
                          selected: _mood == m.$1,
                          onTap: () => setState(() => _mood = m.$1),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        WhiteFrameCard(
          headerTitle: '오늘 있었던 일',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _title,
                style: const TextStyle(fontSize: 26),
                decoration: const InputDecoration(
                  hintText: '제목',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              _LinedBody(controller: _body),
              const SizedBox(height: 12),
              JellyButton(
                color: _listening ? AppColors.red : AppColors.mint,
                height: 72,
                semanticLabel: _listening ? '말하기 멈추기' : '말로 쓰기',
                onTap: _toggleSpeech,
                child: Center(
                  child: OutlinedText(
                    _listening ? '말하는 중… 누르면 멈춰요' : '말로 쓰기',
                    fontSize: 26,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (stickers.isNotEmpty) ...[
          const SizedBox(height: 16),
          WhiteFrameCard(
            headerTitle: '오늘의 스티커',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final event in stickers)
                  _StickerChip(
                    label: _chipLabel(event, names),
                    type: event.eventType,
                  ),
              ],
            ),
          ),
        ],
        if (today?.parentReply != null) ...[
          const SizedBox(height: 16),
          _ReplyBubble(text: today!.parentReply!),
        ],
        const SizedBox(height: 16),
        if (_message != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: HintText(_message!),
          ),
        JellyButton(
          color: AppColors.red,
          height: 96,
          semanticLabel: '일기 저장하기',
          onTap: _saving ? null : _save,
          child: const Center(child: OutlinedText('일기 저장하기', fontSize: 36)),
        ),
      ],
    );
  }

  String _chipLabel(StickerEvent event, Map<int, String> names) {
    return stickerRecordLabel(
      type: event.eventType,
      amount: event.amount,
      categoryId: event.categoryId,
      names: names,
    );
  }

  Future<void> _showDetail(DiaryEntry entry) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(entry.title.isEmpty ? '(제목 없음)' : entry.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${entry.localDate} · ${weatherName(entry.weather)}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 12),
              Text(
                entry.body,
                style: const TextStyle(fontSize: 22, height: 1.5),
              ),
              if (entry.parentReply != null) ...[
                const SizedBox(height: 16),
                _ReplyBubble(text: entry.parentReply!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _reply(entry);
            },
            child: const Text('엄마·아빠 답장 쓰기'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceButton(
      label: label,
      height: 72,
      selected: selected,
      color: AppColors.gold,
      onTap: onTap,
    );
  }
}

class _MoodButton extends StatelessWidget {
  const _MoodButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return JellyButton(
      color: selected ? AppColors.gold : AppColors.white,
      height: 96,
      semanticLabel: label,
      onTap: onTap,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: AppColors.ink),
            Text(
              label,
              style: const TextStyle(fontSize: 18, color: AppColors.ink),
            ),
          ],
        ),
      ),
    );
  }
}

/// 줄 노트 배경의 내용 입력칸.
class _LinedBody extends StatelessWidget {
  const _LinedBody({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _LinesPainter())),
          TextField(
            controller: controller,
            expands: true,
            maxLines: null,
            textAlignVertical: TextAlignVertical.top,
            style: const TextStyle(fontSize: 24, height: 1.8),
            decoration: const InputDecoration(
              hintText: '오늘 있었던 일을 적어 보세요',
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }
}

class _LinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCBD5EA)
      ..strokeWidth = 2;
    for (var y = 43.0; y < size.height; y += 43.2) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_LinesPainter oldDelegate) => false;
}

class _StickerChip extends StatelessWidget {
  const _StickerChip({required this.label, required this.type});

  final String label;
  final String type;

  @override
  Widget build(BuildContext context) {
    final color = switch (type) {
      'remove' => AppColors.misdeed,
      'warn' => AppColors.orange,
      'bonus' => AppColors.gold,
      _ => AppColors.categoryLife,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 18, color: AppColors.white),
      ),
    );
  }
}

class _ReplyBubble extends StatelessWidget {
  const _ReplyBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.pink, width: 4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '엄마·아빠 답장',
            style: TextStyle(fontSize: 20, color: AppColors.misdeed),
          ),
          const SizedBox(height: 6),
          Text(text, style: const TextStyle(fontSize: 22, height: 1.4)),
        ],
      ),
    );
  }
}

class _PastList extends StatelessWidget {
  const _PastList({
    required this.entries,
    required this.today,
    required this.onOpen,
  });

  final List<DiaryEntry> entries;
  final String today;
  final void Function(DiaryEntry) onOpen;

  @override
  Widget build(BuildContext context) {
    final past = entries.where((e) => e.localDate != today).toList();
    if (past.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: WhiteFrameCard(
          headerTitle: '아직 지난 일기가 없어요',
          child: Text(
            '오늘 일기를 쓰면 다음 날부터\n여기에 모여요.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, color: AppColors.ink),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: past.length,
      itemBuilder: (context, index) {
        final entry = past[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: JellyButton(
            color: AppColors.white,
            height: 96,
            borderRadius: BorderRadius.circular(36),
            semanticLabel: '${entry.localDate} 일기',
            onTap: () => onOpen(entry),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: [
                  Icon(moodIcon(entry.mood), size: 40, color: AppColors.ink),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.title.isEmpty ? '(제목 없음)' : entry.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 26,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          '${entry.localDate}${entry.parentReply == null ? '' : ' · 답장 있음'}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Color(0xFF3A4A3A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    weatherIcon(entry.weather),
                    size: 32,
                    color: AppColors.blue,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
