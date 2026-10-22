/// 장부 한 줄. DB 행과 분리해서 규칙을 순수 Dart로 테스트할 수 있게 했다.
class LedgerEvent {
  const LedgerEvent({
    required this.id,
    required this.type,
    required this.amount,
    required this.createdAt,
    this.categoryId,
    this.relatedEventId,
  });

  final int id;

  /// earn | remove | warn | undo | bonus | redeem | adjust
  final String type;

  /// 받으면 양수, 빼면 음수, 되돌리기는 원래 기록의 반대 값.
  final int amount;
  final DateTime createdAt;
  final int? categoryId;
  final int? relatedEventId;
}

/// 장부를 처음부터 다시 계산한 결과.
class LedgerView {
  const LedgerView({
    required this.balance,
    required this.totalEarned,
    required this.stack,
    required this.lastUndoableId,
  });

  static const empty = LedgerView(
    balance: 0,
    totalEarned: 0,
    stack: [],
    lastUndoableId: null,
  );

  final int balance;

  /// 되돌리지 않은 받기의 합. 빼기와 상관없이 늘어만 간다.
  final int totalEarned;

  /// 지금 맵에 보이는 스티커 순서. 각 값은 그 스티커를 받은 칭찬 카테고리 id.
  /// 길이는 항상 [balance]와 같다.
  final List<int> stack;

  /// 지금 되돌릴 수 있는 가장 최근 기록 id. 없으면 null.
  final int? lastUndoableId;
}

/// 장부 규칙: 받기·빼기·되돌리기를 순서대로 다시 계산한다.
abstract final class StickerLedger {
  static LedgerView replay(List<LedgerEvent> events) {
    final sorted = [...events]..sort((a, b) => a.id.compareTo(b.id));
    final byId = {for (final event in sorted) event.id: event};

    // 되돌린 기록 id 모으기 (먼저 한 번 훑는다).
    final undone = <int>{
      for (final event in sorted)
        if (event.type == 'undo' && event.relatedEventId != null)
          event.relatedEventId!,
    };

    final stack = <int>[];
    final poppedByRemove = <int, List<int>>{};
    var balance = 0;
    var totalEarned = 0;

    for (final event in sorted) {
      switch (event.type) {
        case 'earn':
          final category = event.categoryId ?? 0;
          stack.addAll(List.filled(event.amount, category));
          balance += event.amount;
          if (!undone.contains(event.id)) {
            totalEarned += event.amount;
          }
        case 'remove':
          final count = -event.amount;
          final popped = _pop(stack, count);
          poppedByRemove[event.id] = popped;
          balance += event.amount;
        case 'undo':
          final original = byId[event.relatedEventId];
          if (original != null) {
            if (original.type == 'earn') {
              _pop(stack, original.amount);
            } else if (original.type == 'remove') {
              stack.addAll(poppedByRemove[original.id] ?? const []);
            }
          }
          balance += event.amount;
        default:
          // warn·bonus·redeem·adjust 는 이 단계에서 잔액을 바꾸지 않는다.
          balance += event.amount;
      }
    }

    int? lastUndoable;
    for (final event in sorted) {
      if ((event.type == 'earn' || event.type == 'remove') &&
          !undone.contains(event.id)) {
        lastUndoable = event.id;
      }
    }

    return LedgerView(
      balance: balance,
      totalEarned: totalEarned,
      stack: stack,
      lastUndoableId: lastUndoable,
    );
  }

  static List<int> _pop(List<int> stack, int count) {
    final take = count < stack.length ? count : stack.length;
    final removed = stack.sublist(stack.length - take);
    stack.removeRange(stack.length - take, stack.length);
    return removed;
  }
}
