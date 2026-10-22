/// 화면 경로 한곳 모음. 탭 5개는 하단 탭 바에 있고, 나머지는 전체 화면으로 열린다.
abstract final class Routes {
  static const onboarding = '/onboarding';
  static const home = '/';
  static const today = '/today';
  static const map = '/map';
  static const diary = '/diary';
  static const records = '/records';

  static const pin = '/pin';
  static const pinRecovery = '/pin/recovery';

  static const stamp = '/stamp';
  static const remove = '/remove';
  static const shop = '/shop';
  static const badges = '/badges';
  static const parent = '/parent';
  static const rewards = '/rewards';
  static const routines = '/routines';
  static const duolingo = '/duolingo';

  /// 부모 모드 안 화면들 (부모 모드 메뉴에서만 연다).
  static const parentPin = '/parent/pin';
  static const parentCategories = '/parent/categories';
  static const parentBadges = '/parent/badges';
  static const parentBackup = '/parent/backup';
  static const parentCustom = '/parent/custom';
}
