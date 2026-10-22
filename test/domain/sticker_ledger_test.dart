import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/domain/sticker_ledger.dart';

LedgerEvent _event(
  int id,
  String type,
  int amount, {
  int? category,
  int? related,
}) {
  return LedgerEvent(
    id: id,
    type: type,
    amount: amount,
    categoryId: category,
    relatedEventId: related,
    createdAt: DateTime(2026, 10, 22, 9),
  );
}

void main() {
  test('빈 장부는 0개', () {
    expect(StickerLedger.replay([]).balance, 0);
    expect(StickerLedger.replay([]).stack, isEmpty);
  });

  test('받은 순서대로 스티커 카테고리가 쌓인다', () {
    final view = StickerLedger.replay([
      _event(1, 'earn', 2, category: 10),
      _event(2, 'earn', 1, category: 20),
    ]);

    expect(view.balance, 3);
    expect(view.stack, [10, 10, 20]);
  });

  test('빼면 맨 위(가장 나중) 스티커부터 떨어진다', () {
    final view = StickerLedger.replay([
      _event(1, 'earn', 2, category: 10),
      _event(2, 'earn', 1, category: 20),
      _event(3, 'remove', -1, category: 30),
    ]);

    expect(view.balance, 2);
    expect(view.stack, [10, 10]);
  });

  test('되돌린 받기는 누적에서 빠진다', () {
    final view = StickerLedger.replay([
      _event(1, 'earn', 2, category: 10),
      _event(2, 'undo', -2, related: 1),
    ]);

    expect(view.balance, 0);
    expect(view.totalEarned, 0);
    expect(view.stack, isEmpty);
  });

  test('되돌린 빼기는 떨어졌던 스티커를 원래 자리로 되돌린다', () {
    final view = StickerLedger.replay([
      _event(1, 'earn', 2, category: 10),
      _event(2, 'remove', -1, category: 30),
      _event(3, 'undo', 1, related: 2),
    ]);

    expect(view.balance, 2);
    expect(view.stack, [10, 10]);
  });

  test('경고는 잔액과 스티커를 바꾸지 않는다', () {
    final view = StickerLedger.replay([
      _event(1, 'earn', 2, category: 10),
      _event(2, 'warn', 0, category: 30),
    ]);

    expect(view.balance, 2);
    expect(view.stack, [10, 10]);
  });

  test('되돌릴 수 있는 기록은 가장 최근의 받기·빼기 하나다', () {
    final view = StickerLedger.replay([
      _event(1, 'earn', 2, category: 10),
      _event(2, 'remove', -1, category: 30),
      _event(3, 'warn', 0, category: 30),
    ]);

    expect(view.lastUndoableId, 2);
  });

  test('되돌린 기록은 다시 되돌릴 수 없다', () {
    final view = StickerLedger.replay([
      _event(1, 'earn', 2, category: 10),
      _event(2, 'undo', -2, related: 1),
    ]);

    expect(view.lastUndoableId, isNull);
  });

  test('스티커 목록 길이는 항상 잔액과 같다', () {
    final view = StickerLedger.replay([
      _event(1, 'earn', 5, category: 10),
      _event(2, 'remove', -2, category: 30),
      _event(3, 'earn', 1, category: 20),
      _event(4, 'undo', -1, related: 3),
      _event(5, 'remove', -1, category: 30),
      _event(6, 'undo', 1, related: 5),
    ]);

    expect(view.balance, 3);
    expect(view.stack.length, view.balance);
  });

  test('교환은 맨 위 스티커를 가격만큼 빼고, 되돌릴 기록이 되지 않는다', () {
    final view = StickerLedger.replay([
      _event(1, 'earn', 3, category: 10),
      _event(2, 'earn', 2, category: 20),
      _event(3, 'redeem', -4),
    ]);

    expect(view.balance, 1);
    expect(view.stack, [10]);
    expect(view.lastUndoableId, isNull);
    expect(view.totalEarned, 5);
  });
}
