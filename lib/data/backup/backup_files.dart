import 'dart:io';

import 'package:path/path.dart' as p;

/// 자동 백업 파일 보관소. 하루에 한 파일씩 만들고, 최근 [keepCount]개만 남긴다.
class BackupFiles {
  BackupFiles(this.directory, {this.keepCount = 14});

  final Directory directory;
  final int keepCount;

  static final _namePattern = RegExp(
    r'^sticker_world_(\d{4}-\d{2}-\d{2})\.json$',
  );

  /// 오늘 날짜('YYYY-MM-DD')의 백업이 이미 있는지.
  Future<bool> hasDay(String dateKey) async {
    return File(_pathFor(dateKey)).exists();
  }

  /// 날짜별 백업을 쓰고, 오래된 파일을 지운다.
  Future<File> write(String dateKey, String json) async {
    await directory.create(recursive: true);
    final file = File(_pathFor(dateKey));
    await file.writeAsString(json, flush: true);
    await _prune();
    return file;
  }

  /// 보관된 백업 목록. 최근 날짜가 위로 온다.
  Future<List<File>> list() async {
    if (!await directory.exists()) {
      return const [];
    }
    final files = [
      await for (final entity in directory.list())
        if (entity is File && _namePattern.hasMatch(p.basename(entity.path)))
          entity,
    ];
    files.sort((a, b) => _dateOf(b).compareTo(_dateOf(a)));
    return files;
  }

  Future<void> _prune() async {
    final files = await list();
    for (final file in files.skip(keepCount)) {
      await file.delete();
    }
  }

  String _pathFor(String dateKey) {
    return p.join(directory.path, 'sticker_world_$dateKey.json');
  }

  static String _dateOf(File file) {
    final match = _namePattern.firstMatch(p.basename(file.path));
    return match?.group(1) ?? '';
  }
}
