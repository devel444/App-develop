import 'package:flutter/services.dart';

/// 태블릿에서 다른 앱을 쓴 시간 (방법 B). 안드로이드의 '사용 기록 접근' 권한이 필요하다.
abstract interface class UsageSource {
  /// 오늘 [packageName] 앱을 쓴 분. 권한이 없으면 null.
  Future<int?> minutesToday(String packageName);

  Future<bool> hasAccess();

  /// 설정 화면에서 권한을 허용하도록 연다.
  Future<void> openSettings();
}

/// 안드로이드 쪽 MainActivity.kt 의 'sticker_world/usage' 채널과 이야기한다.
class UsageChannel implements UsageSource {
  static const _channel = MethodChannel('sticker_world/usage');

  @override
  Future<int?> minutesToday(String packageName) async {
    try {
      return await _channel.invokeMethod<int>('minutesToday', {
        'package': packageName,
      });
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  @override
  Future<bool> hasAccess() async {
    try {
      return (await _channel.invokeMethod<bool>('hasAccess')) ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<void> openSettings() async {
    try {
      await _channel.invokeMethod<void>('openSettings');
    } on PlatformException {
      // 설정 화면을 열 수 없으면 아무것도 하지 않는다.
    } on MissingPluginException {
      // 안드로이드가 아니면 아무것도 하지 않는다.
    }
  }
}
