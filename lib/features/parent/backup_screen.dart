import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticker_world/core/time/local_date.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/jelly_button.dart';
import 'package:sticker_world/core/widgets/outlined_text.dart';
import 'package:sticker_world/core/widgets/pattern_background.dart';
import 'package:sticker_world/core/widgets/screen_frame.dart';
import 'package:sticker_world/core/widgets/white_frame_card.dart';
import 'package:sticker_world/data/providers.dart';
import 'package:sticker_world/features/stamp/stamp_widgets.dart';

/// 백업·되돌리기. 지금 백업은 복사와 파일 저장을 함께 한다.
/// 되돌리기는 지금 기록을 모두 백업 내용으로 바꾸므로 항상 한 번 더 묻는다.
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  final _paste = TextEditingController();
  List<File> _files = const [];
  String? _message;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _reloadFiles();
  }

  @override
  void dispose() {
    _paste.dispose();
    super.dispose();
  }

  Future<void> _reloadFiles() async {
    final files = await ref.read(backupFilesProvider.future);
    final list = await files.list();
    if (mounted) {
      setState(() => _files = list);
    }
  }

  Future<void> _backupNow() async {
    setState(() {
      _busy = true;
      _message = null;
    });
    final json = await ref.read(backupServiceProvider).exportJson();
    final files = await ref.read(backupFilesProvider.future);
    await files.write(localDateKey(DateTime.now()), json);
    await Clipboard.setData(ClipboardData(text: json));
    await _reloadFiles();
    if (mounted) {
      setState(() {
        _busy = false;
        _message = '백업 파일을 만들고 복사해 두었어요.';
      });
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    setState(() => _paste.text = data?.text ?? '');
  }

  Future<void> _restore(String json) async {
    final ok = await _confirm();
    if (!ok || !mounted) {
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await ref.read(backupServiceProvider).restoreJson(json);
      if (mounted) {
        setState(() => _message = '되돌렸어요. 기록이 백업 내용으로 바뀌었어요.');
      }
    } on FormatException catch (error) {
      if (mounted) {
        setState(() => _message = error.message);
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _restoreFile(File file) async {
    await _restore(await file.readAsString());
  }

  Future<bool> _confirm() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('정말 되돌릴까요?'),
        content: const Text(
          '지금 기록이 모두 백업 내용으로 바뀌어요.\n되돌린 뒤에는 지금 기록을 다시 살릴 수 없어요.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('되돌리기'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ScreenFrame(
          title: '백업 · 되돌리기',
          color: AppColors.blue,
          pattern: BgPattern.dots,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            children: [
              WhiteFrameCard(
                headerTitle: '지금 백업하기',
                headerColor: AppColors.blue,
                child: JellyButton(
                  color: AppColors.gold,
                  height: 80,
                  semanticLabel: '지금 백업하기',
                  onTap: _busy ? null : _backupNow,
                  child: const Center(
                    child: OutlinedText('백업하기', fontSize: 30),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              WhiteFrameCard(
                headerTitle: '자동 백업',
                headerColor: AppColors.blue,
                child: _files.isEmpty
                    ? const HintText('아직 자동 백업이 없어요. 앱을 열면 하루에 한 번 만들어요.')
                    : Column(
                        children: [
                          for (final file in _files)
                            _FileRow(
                              name: file.uri.pathSegments.last,
                              enabled: !_busy,
                              onRestore: () => _restoreFile(file),
                            ),
                        ],
                      ),
              ),
              const SizedBox(height: 16),
              WhiteFrameCard(
                headerTitle: '붙여넣어 되돌리기',
                headerColor: AppColors.blue,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _paste,
                      onChanged: (_) => setState(() {}),
                      maxLines: 4,
                      style: const TextStyle(fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: '백업 내용을 여기에 붙여 넣어요',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    JellyButton(
                      color: AppColors.white,
                      height: 72,
                      semanticLabel: '클립보드에서 붙여넣기',
                      onTap: _busy ? null : _pasteFromClipboard,
                      child: const Center(
                        child: Text(
                          '클립보드에서 붙여넣기',
                          style: TextStyle(fontSize: 22, color: AppColors.ink),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    JellyButton(
                      color: AppColors.red,
                      height: 72,
                      semanticLabel: '이 내용으로 되돌리기',
                      onTap: _busy || _paste.text.trim().isEmpty
                          ? null
                          : () => _restore(_paste.text),
                      child: const Center(
                        child: OutlinedText('이 내용으로 되돌리기', fontSize: 26),
                      ),
                    ),
                  ],
                ),
              ),
              if (_message != null) ...[
                const SizedBox(height: 16),
                HintText(_message!),
              ],
            ],
          ),
        ),
        const BackFab(),
      ],
    );
  }
}

class _FileRow extends StatelessWidget {
  const _FileRow({
    required this.name,
    required this.enabled,
    required this.onRestore,
  });

  final String name;
  final bool enabled;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 20, color: AppColors.ink),
            ),
          ),
          FilledButton(
            onPressed: enabled ? onRestore : null,
            child: const Text('이 날로 되돌리기'),
          ),
        ],
      ),
    );
  }
}
