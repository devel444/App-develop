/// 스티커 규칙 (CLAUDE.md: 잔액은 항상 0~100).
abstract final class StickerRules {
  static const maxStickers = 100;

  /// 붙이기 전에 확인한다. 넘으면 [StickerRuleException]을 던진다.
  static void checkEarn({required int balance, required int amount}) {
    if (amount <= 0) {
      throw const StickerRuleException('붙일 개수는 1개 이상이어야 해요.');
    }
    if (balance + amount > maxStickers) {
      throw const StickerRuleException(
        '스티커는 최대 100개까지 모을 수 있어요. 선물가게에서 선물을 골라 보세요!',
      );
    }
  }

  /// 빼기 전에 확인한다. 사유(메모)는 꼭 있어야 한다.
  static void checkRemove({
    required int balance,
    required int amount,
    required String? memo,
  }) {
    if (amount <= 0) {
      throw const StickerRuleException('뺄 개수는 1개 이상이어야 해요.');
    }
    if (memo == null || memo.trim().isEmpty) {
      throw const StickerRuleException('무엇을 잘못했는지 적어 주세요.');
    }
    if (balance - amount < 0) {
      throw const StickerRuleException('가진 스티커보다 많이 뺄 수는 없어요.');
    }
  }
}

class StickerRuleException implements Exception {
  const StickerRuleException(this.message);

  final String message;

  @override
  String toString() => message;
}
