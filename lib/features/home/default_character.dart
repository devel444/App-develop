import 'package:flutter/material.dart';

/// 기본 캐릭터 (코드로 그린 임시 그림).
/// `assets/custom/character.png`가 있으면 홈에서는 그 그림을 대신 쓴다 (PLAN.md 9장).
class DefaultCharacter extends StatelessWidget {
  const DefaultCharacter({super.key});

  static const _overalls = Color(0xFF2B5FD9);
  static const _shirt = Color(0xFFE4231B);
  static const _skin = Color(0xFFFFDDBE);
  static const _nose = Color(0xFFF2B98E);
  static const _shoe = Color(0xFF7A4A1E);
  static const _gold = Color(0xFFFFC93B);
  static const _ink = Color(0xFF2E2A44);
  static const _mouth = Color(0xFFB3161B);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 260,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 팔
          Positioned(
            left: 22,
            top: 120,
            child: _box(34, 70, _shirt, radius: 17),
          ),
          Positioned(
            left: 164,
            top: 120,
            child: _box(34, 70, _shirt, radius: 17),
          ),
          // 다리와 신발
          Positioned(
            left: 52,
            bottom: 0,
            child: _box(50, 70, _overalls, radius: 18),
          ),
          Positioned(
            left: 118,
            bottom: 0,
            child: _box(50, 70, _overalls, radius: 18),
          ),
          Positioned(
            left: 44,
            bottom: 0,
            child: _box(66, 24, _shoe, radius: 12),
          ),
          Positioned(
            left: 110,
            bottom: 0,
            child: _box(66, 24, _shoe, radius: 12),
          ),
          // 옷
          Positioned(
            left: 52,
            top: 108,
            child: _box(116, 44, _shirt, radius: 20),
          ),
          Positioned(
            left: 46,
            top: 140,
            child: _box(128, 76, _overalls, radius: 28),
          ),
          Positioned(left: 70, top: 156, child: _box(16, 16, _gold, radius: 8)),
          Positioned(
            left: 134,
            top: 156,
            child: _box(16, 16, _gold, radius: 8),
          ),
          // 얼굴
          Positioned(
            left: 50,
            top: 32,
            child: _box(120, 110, _skin, radius: 60),
          ),
          Positioned(left: 103, top: 92, child: _box(14, 14, _nose, radius: 7)),
          Positioned(left: 84, top: 78, child: _box(12, 14, _ink, radius: 6)),
          Positioned(left: 124, top: 78, child: _box(12, 14, _ink, radius: 6)),
          Positioned(
            left: 92,
            top: 104,
            child: _box(
              36,
              16,
              _mouth,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
          ),
          // 모자
          Positioned(
            left: 46,
            top: 14,
            child: _box(
              128,
              58,
              _shirt,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(64),
              ),
            ),
          ),
          Positioned(left: 36, top: 62, child: _box(96, 14, _shirt, radius: 7)),
        ],
      ),
    );
  }

  static Widget _box(
    double width,
    double height,
    Color color, {
    double radius = 0,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius ?? BorderRadius.circular(radius),
      ),
    );
  }
}
