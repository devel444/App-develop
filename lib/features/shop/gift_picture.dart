import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sticker_world/core/theme/app_colors.dart';

/// 선물 그림. 사진을 골랐으면 그 사진을, 없으면 선물 아이콘을 동그랗게 보여 준다.
class GiftPicture extends StatelessWidget {
  const GiftPicture({super.key, required this.imagePath, this.size = 96});

  final String? imagePath;
  final double size;

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: path == null
            ? _placeholder()
            : Image.file(
                File(path),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _placeholder(),
              ),
      ),
    );
  }

  Widget _placeholder() {
    return ColoredBox(
      color: const Color(0xFFE9EEF8),
      child: Center(
        child: Icon(
          Icons.card_giftcard_rounded,
          size: size * 0.58,
          color: AppColors.pink,
        ),
      ),
    );
  }
}
