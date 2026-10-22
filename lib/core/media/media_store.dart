import 'dart:io';

import 'package:path/path.dart' as p;

/// 사진첩에서 고른 파일을 앱 안으로 복사해 둔다. 원본을 지워도 그림이 남게 하려고다.
class MediaStore {
  MediaStore(this.directory, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final Directory directory;
  final DateTime Function() _clock;

  /// [sourcePath]를 복사하고, 복사본의 경로를 돌려준다. 파일 이름에는 [prefix]를 붙인다.
  Future<String> saveCopy(String sourcePath, {required String prefix}) async {
    await directory.create(recursive: true);
    final extension = p.extension(sourcePath).toLowerCase();
    final name = '${prefix}_${_clock().millisecondsSinceEpoch}$extension';
    final target = p.join(directory.path, name);
    await File(sourcePath).copy(target);
    return target;
  }

  /// 앱 안의 복사본을 지운다. 경로가 없거나 이미 없으면 아무 일도 하지 않는다.
  Future<void> deleteCopy(String? path) async {
    if (path == null || path.isEmpty) {
      return;
    }
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
