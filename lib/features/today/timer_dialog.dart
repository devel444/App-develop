import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/outlined_text.dart';

/// 타이머 루틴: 남은 시간을 보여 주고, 다 되면 true로 닫힌다.
Future<bool> showRoutineTimer(BuildContext context, int minutes) async {
  final finished = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _TimerDialog(total: Duration(minutes: minutes)),
  );
  return finished ?? false;
}

class _TimerDialog extends StatefulWidget {
  const _TimerDialog({required this.total});

  final Duration total;

  @override
  State<_TimerDialog> createState() => _TimerDialogState();
}

class _TimerDialogState extends State<_TimerDialog> {
  late Duration _left = widget.total;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_left <= const Duration(seconds: 1)) {
        timer.cancel();
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        setState(() => _left -= const Duration(seconds: 1));
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _left.inMinutes.toString().padLeft(2, '0');
    final seconds = (_left.inSeconds % 60).toString().padLeft(2, '0');

    return Dialog(
      backgroundColor: AppColors.cream,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '열심히 하고 있어요!',
              style: TextStyle(fontSize: 30, color: AppColors.ink),
            ),
            const SizedBox(height: 20),
            OutlinedText(
              '$minutes:$seconds',
              fontFamily: 'LilitaOne',
              fontSize: 96,
              color: AppColors.ink,
              outlineColor: AppColors.white,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('그만하기', style: TextStyle(fontSize: 24)),
            ),
          ],
        ),
      ),
    );
  }
}
