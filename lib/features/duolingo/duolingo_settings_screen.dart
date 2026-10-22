import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/jelly_button.dart';
import 'package:sticker_world/core/widgets/outlined_text.dart';
import 'package:sticker_world/core/widgets/pattern_background.dart';
import 'package:sticker_world/core/widgets/screen_frame.dart';
import 'package:sticker_world/core/widgets/white_frame_card.dart';
import 'package:sticker_world/data/providers.dart';
import 'package:sticker_world/features/stamp/stamp_widgets.dart';

/// 듀오링고 설정 (엄마·아빠 PIN 후): 아이디, 확인 테스트, 태블릿 사용 기록 권한.
/// 비밀번호는 묻지도 저장하지도 않는다.
class DuolingoSettingsScreen extends ConsumerStatefulWidget {
  const DuolingoSettingsScreen({super.key});

  @override
  ConsumerState<DuolingoSettingsScreen> createState() =>
      _DuolingoSettingsScreenState();
}

class _DuolingoSettingsScreenState
    extends ConsumerState<DuolingoSettingsScreen> {
  TextEditingController? _username;
  TextEditingController? _package;
  int _minutes = 5;
  bool _loaded = false;
  bool _hasAccess = false;
  String? _notice;

  @override
  void initState() {
    super.initState();
    _loadAccess();
  }

  @override
  void dispose() {
    _username?.dispose();
    _package?.dispose();
    super.dispose();
  }

  Future<void> _loadAccess() async {
    final access = await ref.read(usageSourceProvider).hasAccess();
    final minutes = await ref
        .read(settingsRepositoryProvider)
        .getInt('usage_min_minutes', fallback: 5);
    if (mounted) {
      setState(() {
        _hasAccess = access;
        _minutes = minutes;
      });
    }
  }

  void _fillOnce() {
    if (_loaded) {
      return;
    }
    final child = ref.read(currentChildProvider).value;
    if (child == null) {
      return;
    }
    _loaded = true;
    _username = TextEditingController(text: child.duolingoUsername ?? '');
    _package = TextEditingController(text: child.duolingoPackage);
  }

  Future<void> _save() async {
    final child = ref.read(currentChildProvider).value;
    if (child == null || _username == null || _package == null) {
      return;
    }
    await ref
        .read(childRepositoryProvider)
        .updateDuolingo(
          childId: child.id,
          username: _username!.text,
          packageName: _package!.text,
        );
    await ref
        .read(settingsRepositoryProvider)
        .set('usage_min_minutes', '$_minutes');
    if (mounted) {
      setState(() => _notice = '저장했어요.');
    }
  }

  Future<void> _test() async {
    final child = ref.read(currentChildProvider).value;
    if (child == null) {
      return;
    }
    final username = _username?.text.trim() ?? '';
    String raw;
    try {
      raw = (await ref.read(duolingoApiProvider).fetchProfile(username)).raw;
    } on Exception catch (error) {
      raw = '가져오지 못했어요: $error';
    }
    final judgement = await ref
        .read(duolingoSyncProvider)
        .check(
          childId: child.id,
          username: username,
          packageName: _package?.text.trim() ?? 'com.duolingo',
          usageMinMinutes: _minutes,
        );
    if (!mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('확인 결과'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(judgement.reason, style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 12),
                const Text(
                  '듀오링고 응답',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SelectableText(
                  raw,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _fillOnce();

    return Stack(
      fit: StackFit.expand,
      children: [
        ScreenFrame(
          title: '듀오링고 설정',
          color: AppColors.orange,
          pattern: BgPattern.dots,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              children: [
                WhiteFrameCard(
                  headerTitle: '듀오링고 아이디',
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _username,
                        style: const TextStyle(fontSize: 26),
                        decoration: const InputDecoration(
                          labelText: '아이디(사용자 이름)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '비밀번호는 묻지도 저장하지도 않아요.\n듀오링고 프로필이 공개 상태여야 확인할 수 있어요.',
                        style: TextStyle(fontSize: 18, color: AppColors.ink),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _package,
                        style: const TextStyle(fontSize: 22),
                        decoration: const InputDecoration(
                          labelText: '태블릿 앱 이름(패키지)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                WhiteFrameCard(
                  headerTitle: '완료로 볼 최소 시간',
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final minutes in const [3, 5, 10, 20])
                        SizedBox(
                          width: 130,
                          height: 70,
                          child: ChoiceButton(
                            label: '$minutes분',
                            selected: _minutes == minutes,
                            onTap: () => setState(() => _minutes = minutes),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                WhiteFrameCard(
                  headerTitle: '태블릿 사용 기록',
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _hasAccess ? '허용되어 있어요.' : '아직 허용하지 않았어요.',
                        style: const TextStyle(
                          fontSize: 24,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 12),
                      JellyButton(
                        color: AppColors.mint,
                        height: 70,
                        semanticLabel: '사용 기록 권한 열기',
                        onTap: () async {
                          await ref.read(usageSourceProvider).openSettings();
                          await _loadAccess();
                        },
                        child: const Center(
                          child: OutlinedText('권한 설정 열기', fontSize: 26),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                JellyButton(
                  color: AppColors.gold,
                  height: 80,
                  semanticLabel: '저장',
                  onTap: _save,
                  child: const Center(child: OutlinedText('저장', fontSize: 30)),
                ),
                const SizedBox(height: 12),
                JellyButton(
                  color: AppColors.white,
                  height: 80,
                  semanticLabel: '지금 확인해 보기',
                  onTap: _test,
                  child: const Center(
                    child: Text(
                      '지금 확인해 보기',
                      style: TextStyle(fontSize: 26, color: AppColors.ink),
                    ),
                  ),
                ),
                if (_notice != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: HintText(_notice!),
                  ),
              ],
            ),
          ),
        ),
        const BackFab(),
      ],
    );
  }
}
