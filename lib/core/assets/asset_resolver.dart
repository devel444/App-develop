import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// PLAN.md 9장: `assets/custom/`에 같은 이름의 파일이 있으면 그 파일을 쓰고,
/// 없으면 호출한 쪽이 기본 그림(코드로 그린 위젯 등)을 그린다.
abstract final class AssetResolver {
  static const customDir = 'assets/custom/';

  static Set<String> _customAssets = {};

  /// 앱 시작 시 한 번 호출한다. 빌드에 포함된 커스텀 파일 목록을 읽는다.
  static Future<void> init() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    _customAssets = manifest
        .listAssets()
        .where((path) => path.startsWith(customDir))
        .toSet();
  }

  /// 커스텀 파일이 있으면 에셋 경로, 없으면 null.
  static String? custom(String fileName) {
    final path = '$customDir$fileName';
    return _customAssets.contains(path) ? path : null;
  }

  @visibleForTesting
  static void debugSetCustomAssets(Set<String> paths) {
    _customAssets = paths;
  }
}
