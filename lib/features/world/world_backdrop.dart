import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticker_world/core/assets/asset_resolver.dart';
import 'package:sticker_world/data/providers.dart';

/// 월드 판 뒤의 배경. 순서: 부모가 고른 사진 → 개인용 world{n}.png → 월드 색 그라데이션.
/// 사진 위에는 살짝 흰 막을 덮어서 칸 글씨가 잘 보이게 한다.
class WorldBackdrop extends ConsumerWidget {
  const WorldBackdrop({
    super.key,
    required this.world,
    required this.tint,
    required this.child,
  });

  /// 0부터 세는 월드 번호.
  final int world;

  /// 사진이 없을 때 쓰는 월드 색.
  final Color tint;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photo = ref.watch(worldPhotoProvider(world)).value;
    final custom = AssetResolver.custom('world${world + 1}.png');
    final gradient = _gradient();

    Widget background = DecoratedBox(
      decoration: BoxDecoration(gradient: gradient),
    );
    var hasImage = false;
    if (photo != null) {
      hasImage = true;
      background = Image.file(
        File(photo),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            DecoratedBox(decoration: BoxDecoration(gradient: gradient)),
      );
    } else if (custom != null) {
      hasImage = true;
      background = Image.asset(custom, fit: BoxFit.cover);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          Positioned.fill(child: background),
          if (hasImage)
            const Positioned.fill(child: ColoredBox(color: Color(0x33FFFFFF))),
          Padding(padding: const EdgeInsets.all(8), child: child),
        ],
      ),
    );
  }

  LinearGradient _gradient() {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.white, tint.withValues(alpha: 0.6)],
    );
  }
}
