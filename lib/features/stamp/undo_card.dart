import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/jelly_button.dart';
import 'package:sticker_world/core/widgets/outlined_text.dart';
import 'package:sticker_world/core/widgets/white_frame_card.dart';
import 'package:sticker_world/domain/sticker_rules.dart';

/// 기록 뒤에 뜨는 카드. 제한 시간 안에는 되돌릴 수 있고, 시간이 다 되면 [onDone]이 불린다.
class UndoCard extends StatefulWidget {
  const UndoCard({
    super.key,
    required this.message,
    required this.seconds,
    required this.onUndo,
    required this.onDone,
  });

  final String message;
  final int seconds;

  /// 되돌리기. 실패하면 [StickerRuleException]을 던진다.
  final Future<void> Function() onUndo;
  final VoidCallback onDone;

  @override
  State<UndoCard> createState() => _UndoCardState();
}

class _UndoCardState extends State<UndoCard> {
  late int _left = widget.seconds;
  Timer? _timer;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_left <= 1) {
        timer.cancel();
        widget.onDone();
      } else {
        setState(() => _left--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _undo() async {
    _timer?.cancel();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onUndo();
      if (mounted) {
        widget.onDone();
      }
    } on StickerRuleException catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = error.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WhiteFrameCard(
      headerTitle: '기록했어요',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, color: AppColors.ink),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, color: AppColors.misdeed),
              ),
            ),
          const SizedBox(height: 20),
          JellyButton(
            color: AppColors.gold,
            height: 80,
            semanticLabel: '되돌리기',
            onTap: _busy || _left <= 0 ? null : _undo,
            child: Center(child: OutlinedText('되돌리기 $_left초', fontSize: 30)),
          ),
          const SizedBox(height: 12),
          JellyButton(
            color: AppColors.red,
            height: 80,
            semanticLabel: '확인',
            onTap: _busy ? null : widget.onDone,
            child: const Center(child: OutlinedText('확인', fontSize: 30)),
          ),
        ],
      ),
    );
  }
}
