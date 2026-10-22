/// 100칸 스티커판의 배치 규칙 (PLAN.md 2-1).
/// 100칸은 월드 5개(한 월드 20칸)로 나뉘고, 월드 하나는 5칸 × 4줄 'ㄹ자' 길이다.
abstract final class WorldLayout {
  static const worldSize = 20;
  static const worldCount = 5;
  static const columns = 5;
  static const rows = 4;

  static const worldNames = ['풀밭', '사막', '바다', '얼음', '성'];

  /// 잔액에 맞는 월드 번호(0부터). 0개면 첫 월드.
  static int worldFor(int balance) {
    if (balance <= 0) {
      return 0;
    }
    final index = (balance - 1) ~/ worldSize;
    return index.clamp(0, worldCount - 1);
  }

  /// 월드 안의 줄(row)과 칸(col)에 해당하는 칸 번호 (1~100).
  /// 줄마다 방향이 바뀐다. 짝수 줄은 왼→오른, 홀수 줄은 오른→왼.
  static int cellNumber({
    required int world,
    required int row,
    required int col,
  }) {
    final index = row.isEven ? col : columns - 1 - col;
    return world * worldSize + row * columns + index + 1;
  }

  /// 칸 번호 n이 속한 줄과 칸 (n은 월드 안에서 1~20 기준으로 계산한다).
  static ({int row, int col}) positionOf(int cellInWorld) {
    final zero = cellInWorld - 1;
    final row = zero ~/ columns;
    final index = zero % columns;
    final col = row.isEven ? index : columns - 1 - index;
    return (row: row, col: col);
  }
}
