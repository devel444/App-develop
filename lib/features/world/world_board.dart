import 'package:flutter/material.dart';
import 'package:sticker_world/core/theme/app_colors.dart';
import 'package:sticker_world/core/widgets/outlined_text.dart';
import 'package:sticker_world/features/world/world_layout.dart';

const _cell = 76.0;
const _gapX = 14.0;
const _gapY = 30.0;
const _boardWidth =
    WorldLayout.columns * _cell + (WorldLayout.columns - 1) * _gapX;
const _boardHeight = WorldLayout.rows * _cell + (WorldLayout.rows - 1) * _gapY;

/// 한 월드(20칸)의 판. 채운 칸은 받은 칭찬 색으로, 지금 위치에는 캐릭터 토큰이 선다.
class WorldBoard extends StatelessWidget {
  const WorldBoard({
    super.key,
    required this.world,
    required this.balance,
    required this.stack,
    required this.colorOf,
    this.giftCells = const {},
  });

  final int world;
  final int balance;

  /// 맵에 보이는 스티커 순서. 값은 칭찬 카테고리 id.
  final List<int> stack;

  /// 카테고리 id → 색. 없으면 기본 색을 쓴다.
  final Color Function(int categoryId) colorOf;

  /// 선물 가격 칸 번호들. 선물 목록에서 온다.
  final Set<int> giftCells;

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
              isCurrent: number == balance,
            ),
          ),
        );
      }
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
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
    );
  }
}

class _CellTile extends StatelessWidget {
  const _CellTile({
    required this.number,
    required this.filled,
    required this.isGift,
    required this.isCurrent,
    this.color,
  });

  final int number;
  final bool filled;
  final bool isGift;
  final bool isCurrent;
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
          if (isCurrent) Positioned(top: -54, child: _token()),
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

  Widget _token() {
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.red,
        border: Border.all(color: AppColors.white, width: 4),
        boxShadow: const [
          BoxShadow(color: Color(0x59000000), offset: Offset(0, 4)),
        ],
      ),
      child: const Text(
        '지',
        style: TextStyle(fontSize: 26, color: AppColors.white),
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
