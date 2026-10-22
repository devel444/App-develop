import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:sticker_world/data/db/app_database.dart';

/// 전체 기록을 JSON 한 덩어리로 내보내고 되돌린다.
/// 복원은 지금 데이터를 모두 지우고 백업 내용으로 바꾸는 방식이다 (한 번의 트랜잭션).
/// 이 클래스는 PIN을 확인하지 않는다. 호출하는 화면이 먼저 PIN을 확인해야 한다.
class BackupService {
  BackupService(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  static const appName = 'sticker_world';
  static const formatVersion = 1;

  final AppDatabase _db;
  final DateTime Function() _clock;

  Future<String> exportJson() async {
    final tables = <String, List<Map<String, Object?>>>{
      'children': await _dump(_db.children),
      'categories': await _dump(_db.categories),
      'rewards': await _dump(_db.rewards),
      'stickerEvents': await _dump(_db.stickerEvents),
      'redemptions': await _dump(_db.redemptions),
      'routines': await _dump(_db.routines),
      'routineLogs': await _dump(_db.routineLogs),
      'dailyClears': await _dump(_db.dailyClears),
      'diaryEntries': await _dump(_db.diaryEntries),
      'badges': await _dump(_db.badges),
      'badgeAwards': await _dump(_db.badgeAwards),
      'reportComments': await _dump(_db.reportComments),
      'duolingoSnapshots': await _dump(_db.duolingoSnapshots),
      'praiseTemplates': await _dump(_db.praiseTemplates),
      'appSettings': await _dump(_db.appSettings),
    };
    return jsonEncode({
      'app': appName,
      'version': formatVersion,
      'exportedAt': _clock().toIso8601String(),
      'tables': tables,
    });
  }

  /// 백업 내용으로 되돌린다. 형식이 맞지 않으면 아무것도 바꾸지 않고 [FormatException]을 던진다.
  Future<void> restoreJson(String json) async {
    final tables = _parse(json);

    await _db.transaction(() async {
      // 자식 표부터 지운다 (참조하는 쪽이 먼저).
      await _db.delete(_db.badgeAwards).go();
      await _db.delete(_db.reportComments).go();
      await _db.delete(_db.duolingoSnapshots).go();
      await _db.delete(_db.diaryEntries).go();
      await _db.delete(_db.dailyClears).go();
      await _db.delete(_db.routineLogs).go();
      await _db.delete(_db.redemptions).go();
      await _db.delete(_db.stickerEvents).go();
      await _db.delete(_db.routines).go();
      await _db.delete(_db.rewards).go();
      await _db.delete(_db.categories).go();
      await _db.delete(_db.badges).go();
      await _db.delete(_db.praiseTemplates).go();
      await _db.delete(_db.appSettings).go();
      await _db.delete(_db.children).go();

      // 부모 표부터 넣는다.
      await _restore(_db.children, tables, 'children', ChildrenData.fromJson);
      await _restore(_db.categories, tables, 'categories', Category.fromJson);
      await _restore(_db.rewards, tables, 'rewards', Reward.fromJson);
      await _restore(_db.routines, tables, 'routines', Routine.fromJson);
      await _restore(
        _db.stickerEvents,
        tables,
        'stickerEvents',
        StickerEvent.fromJson,
      );
      await _restore(
        _db.redemptions,
        tables,
        'redemptions',
        Redemption.fromJson,
      );
      await _restore(
        _db.routineLogs,
        tables,
        'routineLogs',
        RoutineLog.fromJson,
      );
      await _restore(
        _db.dailyClears,
        tables,
        'dailyClears',
        DailyClear.fromJson,
      );
      await _restore(
        _db.diaryEntries,
        tables,
        'diaryEntries',
        DiaryEntry.fromJson,
      );
      await _restore(_db.badges, tables, 'badges', Badge.fromJson);
      await _restore(
        _db.badgeAwards,
        tables,
        'badgeAwards',
        BadgeAward.fromJson,
      );
      await _restore(
        _db.reportComments,
        tables,
        'reportComments',
        ReportComment.fromJson,
      );
      await _restore(
        _db.duolingoSnapshots,
        tables,
        'duolingoSnapshots',
        DuolingoSnapshot.fromJson,
      );
      await _restore(
        _db.praiseTemplates,
        tables,
        'praiseTemplates',
        PraiseTemplate.fromJson,
      );
      await _restore(
        _db.appSettings,
        tables,
        'appSettings',
        AppSetting.fromJson,
      );
    });
  }

  Future<List<Map<String, Object?>>> _dump<T extends DataClass>(
    TableInfo<Table, T> table,
  ) async {
    final rows = await _db.select(table).get();
    return [for (final row in rows) row.toJson()];
  }

  Future<void> _restore<T extends Insertable<T>>(
    TableInfo<Table, T> table,
    Map<String, Object?> tables,
    String name,
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    final rows = tables[name];
    if (rows == null) {
      return;
    }
    for (final row in rows as List<Object?>) {
      await _db.into(table).insert(fromJson(row! as Map<String, dynamic>));
    }
  }

  static Map<String, Object?> _parse(String json) {
    final Object? decoded;
    try {
      decoded = jsonDecode(json);
    } on FormatException {
      throw const FormatException('백업 내용을 읽을 수 없어요.');
    }
    if (decoded is! Map<String, dynamic> ||
        decoded['app'] != appName ||
        decoded['tables'] is! Map) {
      throw const FormatException('스티커 월드 백업 파일이 아니에요.');
    }
    final version = decoded['version'];
    if (version is! int || version > formatVersion) {
      throw const FormatException('새 버전 앱에서 만든 백업이라 열 수 없어요.');
    }
    return Map<String, Object?>.from(decoded['tables'] as Map);
  }
}
