import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/features/world/world_layout.dart';

void main() {
  test('잔액에 맞는 월드를 고른다', () {
    expect(WorldLayout.worldFor(0), 0);
    expect(WorldLayout.worldFor(1), 0);
    expect(WorldLayout.worldFor(20), 0);
    expect(WorldLayout.worldFor(21), 1);
    expect(WorldLayout.worldFor(37), 1);
    expect(WorldLayout.worldFor(100), 4);
  });

  test('한 월드 안에서 1~20번 칸이 빠짐없이 한 번씩 있다', () {
    final numbers = <int>[];
    for (var row = 0; row < WorldLayout.rows; row++) {
      for (var col = 0; col < WorldLayout.columns; col++) {
        numbers.add(WorldLayout.cellNumber(world: 1, row: row, col: col));
      }
    }

    numbers.sort();
    expect(numbers, List.generate(20, (i) => 21 + i));
  });

  test('줄마다 방향이 바뀐다 (ㄹ자 길)', () {
    // 첫 줄은 왼→오른, 둘째 줄은 오른→왼
    expect(WorldLayout.cellNumber(world: 0, row: 0, col: 0), 1);
    expect(WorldLayout.cellNumber(world: 0, row: 0, col: 4), 5);
    expect(WorldLayout.cellNumber(world: 0, row: 1, col: 4), 6);
    expect(WorldLayout.cellNumber(world: 0, row: 1, col: 0), 10);
  });

  test('칸 번호에서 위치를 거꾸로 찾을 수 있다', () {
    for (var cell = 1; cell <= 20; cell++) {
      final pos = WorldLayout.positionOf(cell);
      expect(
        WorldLayout.cellNumber(world: 0, row: pos.row, col: pos.col),
        cell,
      );
    }
  });
}
