import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/jelly_button.dart';
import 'package:sticker_world/core/widgets/outlined_text.dart';
import 'package:sticker_world/core/widgets/pattern_background.dart';
import 'package:sticker_world/core/widgets/screen_frame.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/providers.dart';
import 'package:sticker_world/features/shop/gift_picture.dart';
import 'package:sticker_world/features/stamp/stamp_widgets.dart';

/// 선물 가격으로 고를 수 있는 값.
const rewardCostChoices = [10, 15, 20, 30, 40, 50, 70, 100];

/// 선물 관리 (부모 PIN을 맞춘 뒤에 들어온다). 추가·이름·가격·숨기기·지우기.
class RewardAdminScreen extends ConsumerWidget {
  const RewardAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewards = ref.watch(allRewardsProvider).value ?? const <Reward>[];

    return Stack(
      fit: StackFit.expand,
      children: [
        ScreenFrame(
          title: '선물 관리',
          color: AppColors.pink,
          pattern: BgPattern.dots,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            children: [
              for (final reward in rewards)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: JellyButton(
                    color: reward.isActive
                        ? AppColors.mint
                        : const Color(0xFFD8D8E0),
                    height: 96,
                    borderRadius: BorderRadius.circular(40),
                    semanticLabel: '${reward.name} 고치기',
                    onTap: () => _editReward(context, ref, reward),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              reward.name,
                              style: const TextStyle(
                                fontSize: 28,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          Text(
                            reward.isActive
                                ? '${reward.cost}개'
                                : '${reward.cost}개 · 숨김',
                            style: const TextStyle(
                              fontSize: 24,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              JellyButton(
                color: AppColors.gold,
                height: 88,
                semanticLabel: '선물 추가',
                onTap: () => _editReward(context, ref, null),
                child: const Center(
                  child: OutlinedText('+ 선물 추가', fontSize: 34),
                ),
              ),
            ],
          ),
        ),
        const BackFab(),
      ],
    );
  }

  Future<void> _editReward(
    BuildContext context,
    WidgetRef ref,
    Reward? reward,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _RewardDialog(reward: reward, ref: ref),
    );
  }
}

class _RewardDialog extends StatefulWidget {
  const _RewardDialog({required this.reward, required this.ref});

  final Reward? reward;
  final WidgetRef ref;

  @override
  State<_RewardDialog> createState() => _RewardDialogState();
}

class _RewardDialogState extends State<_RewardDialog> {
  late final TextEditingController _name = TextEditingController(
    text: widget.reward?.name ?? '',
  );
  late int _cost = widget.reward?.cost ?? 30;
  late bool _active = widget.reward?.isActive ?? true;
  late String? _imagePath = widget.reward?.imagePath;
  String? _error;

  /// 사진첩에서 고르고, 앱 안으로 복사해 둔다.
  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      imageQuality: 85,
    );
    if (picked == null) {
      return;
    }
    final store = await widget.ref.read(mediaStoreProvider.future);
    final saved = await store.saveCopy(picked.path, prefix: 'gift');
    if (mounted) {
      setState(() => _imagePath = saved);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = '선물 이름을 적어 주세요.');
      return;
    }
    final repo = widget.ref.read(rewardRepositoryProvider);
    final reward = widget.reward;
    final int id;
    if (reward == null) {
      id = await repo.create(name: name, cost: _cost);
    } else {
      id = reward.id;
      await repo.update(
        id: reward.id,
        name: name,
        cost: _cost,
        isActive: _active,
      );
    }
    if (_imagePath != reward?.imagePath) {
      await repo.setImagePath(id, _imagePath);
      final store = await widget.ref.read(mediaStoreProvider.future);
      await store.deleteCopy(reward?.imagePath);
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _delete() async {
    final reward = widget.reward;
    if (reward == null) {
      return;
    }
    final deleted = await widget.ref
        .read(rewardRepositoryProvider)
        .remove(reward.id);
    if (!mounted) {
      return;
    }
    if (!deleted) {
      setState(() => _error = '교환한 기록이 있어서 목록에서만 숨겼어요.');
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.reward == null ? '선물 추가' : '선물 고치기'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _name,
              style: const TextStyle(fontSize: 24),
              decoration: const InputDecoration(
                labelText: '선물 이름',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                GiftPicture(imagePath: _imagePath, size: 72),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: _pickPhoto,
                    child: Text(_imagePath == null ? '사진 고르기' : '사진 바꾸기'),
                  ),
                ),
                if (_imagePath != null)
                  TextButton(
                    onPressed: () => setState(() => _imagePath = null),
                    child: const Text('사진 빼기'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('몇 개로 살 수 있을까요?'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final cost in rewardCostChoices)
                  ChoiceChip(
                    label: Text('$cost개'),
                    selected: _cost == cost,
                    onSelected: (_) => setState(() => _cost = cost),
                  ),
              ],
            ),
            if (widget.reward != null)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('가게에 보이기'),
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
        if (widget.reward != null)
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
