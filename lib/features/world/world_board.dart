import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/outlined_text.dart';
import 'package:sticker_world/features/world/world_layout.dart';

const _cell = 76.0;
const _gapX = 14.0;
const _gapY = 90.0;
const _boardWidth =
    WorldLayout.columns * _cell + (WorldLayout.columns - 1) * _gapX;
const _boardHeight = WorldLayout.rows * _cell + (WorldLayout.rows - 1) * _gapY;
const _tokenSize = 72.0;
const _tokenLift = 80.0;

/// 한 월드(20칸)의 판. 채운 칸은 받은 칭찬 색으로, 지금 위치에는 캐릭터 토큰이 선다.
class WorldBoard extends StatelessWidget {
  const WorldBoard({
    super.key,
    required this.world,
    required this.balance,
    required this.stack,
    required this.colorOf,
    this.giftCells = const {},
    this.characterPhoto,
    this.onCharacterTap,
    this.fitSize,
  });

  final int world;
  final int balance;

  /// 맵에 보이는 스티커 순서. 값은 칭찬 카테고리 id.
  final List<int> stack;

  /// 카테고리 id → 색. 없으면 기본 색을 쓴다.
  final Color Function(int categoryId) colorOf;

  /// 선물 가격 칸 번호들. 선물 목록에서 온다.
  final Set<int> giftCells;

  /// 지금 쓰는 캐릭터 사진 (없으면 '지' 글자 토큰).
  final String? characterPhoto;

  /// 토큰을 누르면 캐릭터 고르기 창을 연다.
  final VoidCallback? onCharacterTap;

  /// 판이 들어갈 수 있는 가로·세로 크기. 이보다 크면 판 전체를 줄인다. 없으면 원래 크기.
  final Size? fitSize;

  @override
  Widget build(BuildContext context) {
    final cells = <Widget>[];
    for (var row = 0; row < WorldLayout.rows; row++) {
      for (var col = 0; col < WorldLayout.columns; col++) {
        final number = WorldLayout.cellNumber(world: world, row: row, col: col);
        cells.add(
          Positioned(
            left: col * (_cell + _gapX),
            top: row * (_cell + _gapY),
            child: _CellTile(
              number: number,
              filled: number <= balance,
              color: number <= balance && number <= stack.length
                  ? colorOf(stack[number - 1])
                  : null,
              isGift: giftCells.contains(number),
            ),
          ),
        );
      }
    }

    // 캐릭터 토큰은 칸마다 따로 두지 않고 판 위에 하나만 둔다. 잔액이 바뀌면 새 칸까지 튀어 간다.
    final inWorld = balance - world * WorldLayout.worldSize;
    final onThisWorld = inWorld >= 1 && inWorld <= WorldLayout.worldSize;
    if (onThisWorld) {
      final at = WorldLayout.positionOf(inWorld);
      cells.add(
        AnimatedPositioned(
          duration: const Duration(milliseconds: 520),
          curve: Curves.easeOutBack,
          left: at.col * (_cell + _gapX) + (_cell - _tokenSize) / 2,
          top: at.row * (_cell + _gapY) - _tokenLift,
          child: _Token(photo: characterPhoto, onTap: onCharacterTap),
        ),
      );
    }

    // 판은 주어진 공간에 맞춰 통째로 줄인다. 8인치처럼 낮은 화면에서도 20칸이 모두 보인다.
    final fit = fitSize;
    final scale = fit == null
        ? 1.0
        : min(1.0, min(fit.width / _boardWidth, fit.height / _boardHeight));

    return SizedBox(
      width: _boardWidth * scale,
      height: _boardHeight * scale,
      child: FittedBox(
        child: SizedBox(
          width: _boardWidth,
          height: _boardHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _PathPainter(world: world)),
              ),
              ...cells,
            ],
          ),
        ),
      ),
    );
  }
}

class _CellTile extends StatelessWidget {
  const _CellTile({
    required this.number,
    required this.filled,
    required this.isGift,
    this.color,
  });

  final int number;
  final bool filled;
  final bool isGift;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _cell,
      height: _cell,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (isGift)
            _giftBlock()
          else if (filled)
            _starBlock()
          else
            _emptyBlock(),
        ],
      ),
    );
  }

  Widget _starBlock() {
    return Container(
      width: _cell,
      height: _cell,
      decoration: BoxDecoration(
        color: color ?? AppColors.categoryStudy,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x40000000), offset: Offset(0, 4)),
        ],
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.star_rounded, size: 44, color: AppColors.white),
    );
  }

  Widget _emptyBlock() {
    return Container(
      width: _cell,
      height: _cell,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6DA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD9A85A), width: 3),
      ),
      child: Text(
        '$number',
        style: const TextStyle(fontSize: 26, color: Color(0xFF8A5A1A)),
      ),
    );
  }

  Widget _giftBlock() {
    return Container(
      width: _cell,
      height: _cell,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? AppColors.gold : const Color(0xFFFBC531),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF8A4A00), width: 4),
        boxShadow: const [
          BoxShadow(color: Color(0x40000000), offset: Offset(0, 4)),
        ],
      ),
      child: OutlinedText(
        '?',
        fontFamily: 'LilitaOne',
        fontSize: 44,
        outlineColor: const Color(0xFF8A4A00),
        outlineWidth: 2,
      ),
    );
  }
}

/// 지금 칸에 선 캐릭터 토큰. 누르면 캐릭터 고르기 창이 열린다.
class _Token extends StatelessWidget {
  const _Token({this.photo, this.onTap});

  final String? photo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final path = photo;
    final face = path == null
        ? const Text(
            '지',
            style: TextStyle(fontSize: 30, color: AppColors.white),
          )
        : Image.file(
            File(path),
            fit: BoxFit.cover,
            width: _tokenSize,
            height: _tokenSize,
            errorBuilder: (_, _, _) => const Text(
              '지',
              style: TextStyle(fontSize: 30, color: AppColors.white),
            ),
          );

    return Semantics(
      button: onTap != null,
      label: '캐릭터 고르기',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: _tokenSize,
          height: _tokenSize,
          alignment: Alignment.center,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.red,
            border: Border.all(color: AppColors.white, width: 4),
            boxShadow: const [
              BoxShadow(color: Color(0x59000000), offset: Offset(0, 4)),
            ],
          ),
          child: face,
        ),
      ),
    );
  }
}

/// 칸들을 이어 주는 길. 칸 번호 순서대로 가운데를 잇는다.
class _PathPainter extends CustomPainter {
  const _PathPainter({required this.world});

  final int world;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    for (var index = 0; index < WorldLayout.worldSize; index++) {
      final pos = WorldLayout.positionOf(index + 1);
      final center = Offset(
        pos.col * (_cell + _gapX) + _cell / 2,
        pos.row * (_cell + _gapY) + _cell / 2,
      );
      if (index == 0) {
        path.moveTo(center.dx, center.dy);
      } else {
        path.lineTo(center.dx, center.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFE7B565)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 26
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_PathPainter oldDelegate) => oldDelegate.world != world;
}
