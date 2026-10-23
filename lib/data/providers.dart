import 'dart:io';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sticker_world/core/audio/sound_player.dart';
import 'package:sticker_world/core/media/media_store.dart';
import 'package:sticker_world/core/time/local_date.dart';
import 'package:sticker_world/data/backup/backup_files.dart';
import 'package:sticker_world/data/backup/backup_service.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/repositories/catalog_repository.dart';
import 'package:sticker_world/data/duolingo/duolingo_api.dart';
import 'package:sticker_world/data/duolingo/duolingo_sync.dart';
import 'package:sticker_world/data/duolingo/usage_source.dart';
import 'package:sticker_world/data/repositories/badge_repository.dart';
import 'package:sticker_world/data/repositories/child_repository.dart';
import 'package:sticker_world/data/repositories/diary_repository.dart';
import 'package:sticker_world/data/repositories/duolingo_repository.dart';
import 'package:sticker_world/data/repositories/report_comment_repository.dart';
import 'package:sticker_world/data/repositories/reward_repository.dart';
import 'package:sticker_world/data/repositories/routine_repository.dart';
import 'package:sticker_world/data/repositories/settings_repository.dart';
import 'package:sticker_world/data/repositories/sticker_repository.dart';
import 'package:sticker_world/domain/badge_rules.dart';
import 'package:sticker_world/domain/character_roster.dart';
import 'package:sticker_world/domain/daily_progress.dart';
import 'package:sticker_world/domain/praise_pick.dart';
import 'package:sticker_world/domain/weekly_report_banner.dart';
import 'package:sticker_world/domain/growth_report.dart';
import 'package:sticker_world/domain/pin_service.dart';
import 'package:sticker_world/domain/sticker_ledger.dart';

/// DB는 main에서 열어서 넘긴다 (테스트에서는 메모리 DB로 바꾼다).
final databaseProvider = Provider<AppDatabase>((_) {
  throw UnimplementedError('databaseProvider는 main에서 열어서 넘겨야 해요.');
});

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(databaseProvider)),
);

final childRepositoryProvider = Provider<ChildRepository>(
  (ref) => ChildRepository(ref.watch(databaseProvider)),
);

final stickerRepositoryProvider = Provider<StickerRepository>(
  (ref) => StickerRepository(ref.watch(databaseProvider)),
);

final pinServiceProvider = Provider<PinService>(
  (ref) => PinService(ref.watch(settingsRepositoryProvider)),
);

/// 지금 등록된 아이. 아직 없으면 null.
final currentChildProvider = StreamProvider<ChildrenData?>(
  (ref) => ref.watch(childRepositoryProvider).watchCurrent(),
);

/// 아이의 장부 계산 결과 (잔액, 누적 받은 개수, 맵에 보이는 스티커 순서). 아이가 없으면 비어 있다.
final ledgerProvider = StreamProvider<LedgerView>((ref) {
  final child = ref.watch(currentChildProvider).value;
  if (child == null) {
    return Stream.value(LedgerView.empty);
  }
  return ref.watch(stickerRepositoryProvider).watchView(child.id);
});

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => CatalogRepository(ref.watch(databaseProvider)),
);

final categoriesProvider = FutureProvider.family<List<Category>, String>(
  (ref, kind) => ref.watch(catalogRepositoryProvider).categories(kind),
);

/// 카테고리 id → 색 값(ARGB). 맵에서 스티커 색을 고를 때 쓴다.
final categoryColorsProvider = FutureProvider<Map<int, int>>((ref) async {
  final praise = await ref.watch(categoriesProvider('praise').future);
  final misdeed = await ref.watch(categoriesProvider('misdeed').future);
  return {
    for (final c in [...praise, ...misdeed]) c.id: c.colorValue,
  };
});

final praiseTextsProvider = FutureProvider<List<String>>(
  (ref) => ref.watch(catalogRepositoryProvider).praiseTexts(),
);

/// 되돌리기 제한 시간과 옐로카드 설정 (설정 테이블에서 읽는다).
final stickerSettingsProvider = FutureProvider<StickerSettings>((ref) async {
  final settings = ref.watch(settingsRepositoryProvider);
  return StickerSettings(
    undoSeconds: await settings.getInt('undo_seconds', fallback: 10),
    yellowCardOn: (await settings.get('yellow_card_on')) == '1',
  );
});

class StickerSettings {
  const StickerSettings({
    required this.undoSeconds,
    required this.yellowCardOn,
  });

  final int undoSeconds;
  final bool yellowCardOn;
}

final rewardRepositoryProvider = Provider<RewardRepository>(
  (ref) => RewardRepository(ref.watch(databaseProvider)),
);

/// 지금 살 수 있게 열려 있는 선물. 가격 순서.
final activeRewardsProvider = StreamProvider<List<Reward>>(
  (ref) => ref.watch(rewardRepositoryProvider).watchActive(),
);

/// 부모 화면에서 보는 전체 선물 (숨긴 것 포함).
final allRewardsProvider = StreamProvider<List<Reward>>(
  (ref) => ref.watch(rewardRepositoryProvider).watchAll(),
);

/// 아이의 교환권 목록 (최신 순).
final redemptionsProvider = StreamProvider<List<Redemption>>((ref) {
  final child = ref.watch(currentChildProvider).value;
  if (child == null) {
    return Stream.value(const []);
  }
  return ref.watch(rewardRepositoryProvider).watchRedemptions(child.id);
});

final routineRepositoryProvider = Provider<RoutineRepository>(
  (ref) => RoutineRepository(
    ref.watch(databaseProvider),
    stickers: ref.watch(stickerRepositoryProvider),
    settings: ref.watch(settingsRepositoryProvider),
  ),
);

/// 루틴 전체 (숨긴 것 포함), 보이는 순서대로.
final routinesProvider = StreamProvider<List<Routine>>(
  (ref) => ref.watch(routineRepositoryProvider).watchAll(),
);

/// 특정 날짜(YYYY-MM-DD)에 체크된 루틴 기록.
final routineLogsProvider = StreamProvider.family<List<RoutineLog>, String>(
  (ref, date) => ref.watch(routineRepositoryProvider).watchLogs(date),
);

/// 엄마·아빠 확인을 기다리는 올클리어 보너스.
final pendingBonusesProvider = StreamProvider<List<DailyClear>>((ref) {
  final child = ref.watch(currentChildProvider).value;
  if (child == null) {
    return Stream.value(const []);
  }
  return ref.watch(routineRepositoryProvider).watchPendingBonuses(child.id);
});

/// 올클리어한 날짜들 (연속 일수용).
final clearDatesProvider = StreamProvider<Set<String>>((ref) {
  final child = ref.watch(currentChildProvider).value;
  if (child == null) {
    return Stream.value(const <String>{});
  }
  return ref
      .watch(routineRepositoryProvider)
      .watchClearDates(child.id)
      .map((dates) => dates.toSet());
});

final duolingoApiProvider = Provider<DuolingoApi>((_) => DuolingoWebApi());

final usageSourceProvider = Provider<UsageSource>((_) => UsageChannel());

final duolingoRepositoryProvider = Provider<DuolingoRepository>(
  (ref) => DuolingoRepository(ref.watch(databaseProvider)),
);

final duolingoSyncProvider = Provider<DuolingoSync>(
  (ref) => DuolingoSync(
    api: ref.watch(duolingoApiProvider),
    usage: ref.watch(usageSourceProvider),
    repository: ref.watch(duolingoRepositoryProvider),
  ),
);

final diaryRepositoryProvider = Provider<DiaryRepository>(
  (ref) => DiaryRepository(ref.watch(databaseProvider)),
);

/// 특정 날짜의 일기 한 편 (없으면 null).
final diaryOnProvider = StreamProvider.family<DiaryEntry?, String>(
  (ref, date) => ref.watch(diaryRepositoryProvider).watchOn(date),
);

/// 아이의 일기 전체 (최신 날짜 위).
final diaryEntriesProvider = StreamProvider<List<DiaryEntry>>((ref) {
  final child = ref.watch(currentChildProvider).value;
  if (child == null) {
    return Stream.value(const []);
  }
  return ref.watch(diaryRepositoryProvider).watchAll(child.id);
});

/// 특정 날짜에 생긴 스티커 기록.
final stickerEventsOnProvider =
    StreamProvider.family<List<StickerEvent>, String>((ref, date) {
      final child = ref.watch(currentChildProvider).value;
      if (child == null) {
        return Stream.value(const []);
      }
      return ref.watch(stickerRepositoryProvider).watchEventsOn(child.id, date);
    });

/// 카테고리 id → 이름 (칭찬·잘못 모두).
final categoryNamesProvider = FutureProvider<Map<int, String>>((ref) async {
  final praise = await ref.watch(categoriesProvider('praise').future);
  final misdeed = await ref.watch(categoriesProvider('misdeed').future);
  return {
    for (final c in [...praise, ...misdeed]) c.id: c.name,
  };
});

/// 아이의 스티커 장부 전체 (달력·리포트용, 날짜 오름차순).
final stickerHistoryProvider = StreamProvider<List<GrowthEvent>>((ref) {
  final child = ref.watch(currentChildProvider).value;
  if (child == null) {
    return Stream.value(const []);
  }
  return ref.watch(stickerRepositoryProvider).watchHistory(child.id);
});

final reportCommentRepositoryProvider = Provider<ReportCommentRepository>(
  (ref) => ReportCommentRepository(ref.watch(databaseProvider)),
);

/// 부모 한마디. 키는 (periodType, periodKey) — 예: ('week', '2026-10-19').
final reportCommentProvider =
    StreamProvider.family<ReportComment?, (String, String)>((ref, key) {
      final child = ref.watch(currentChildProvider).value;
      if (child == null) {
        return Stream.value(null);
      }
      return ref
          .watch(reportCommentRepositoryProvider)
          .watch(child.id, key.$1, key.$2);
    });

/// 가장 최근 듀오링고 확인 기록 (리포트·배지의 연속 일수에 쓴다).
final duolingoLatestProvider = StreamProvider<DuolingoSnapshot?>((ref) {
  final child = ref.watch(currentChildProvider).value;
  if (child == null) {
    return Stream.value(null);
  }
  return ref.watch(duolingoRepositoryProvider).watchLatest(child.id);
});

final badgeRepositoryProvider = Provider<BadgeRepository>(
  (ref) => BadgeRepository(
    ref.watch(databaseProvider),
    ref.watch(stickerRepositoryProvider),
  ),
);

/// 켜져 있는 배지 전체 (도감용).
final badgeCatalogProvider = StreamProvider<List<Badge>>(
  (ref) => ref.watch(badgeRepositoryProvider).watchCatalog(),
);

/// 아이가 얻은 배지 (최근 순).
final badgeAwardsProvider = StreamProvider<List<BadgeAward>>((ref) {
  final child = ref.watch(currentChildProvider).value;
  if (child == null) {
    return Stream.value(const []);
  }
  return ref.watch(badgeRepositoryProvider).watchAwards(child.id);
});

/// 배지 조건 숫자. 기록이 바뀌면 다시 계산한다 (도감의 진행도 힌트용).
final badgeStatsProvider = FutureProvider<BadgeStats?>((ref) {
  ref
    ..watch(stickerHistoryProvider)
    ..watch(clearDatesProvider)
    ..watch(diaryEntriesProvider)
    ..watch(duolingoLatestProvider);
  final child = ref.watch(currentChildProvider).value;
  if (child == null) {
    return Future<BadgeStats?>.value();
  }
  return ref.watch(badgeRepositoryProvider).statsFor(child.id);
});

/// 얻었지만 아직 팝업으로 안 보여 준 배지.
class BadgePopupQueue extends Notifier<List<Badge>> {
  @override
  List<Badge> build() => const [];

  void add(List<Badge> badges) => state = [...state, ...badges];

  void removeFirst() {
    if (state.isNotEmpty) {
      state = state.sublist(1);
    }
  }
}

final badgePopupQueueProvider = NotifierProvider<BadgePopupQueue, List<Badge>>(
  BadgePopupQueue.new,
);

/// 기록이 바뀔 때마다 배지 판정을 돌리고, 새로 얻은 배지를 팝업 줄에 넣는다.
/// 배지 판정 화면(BadgeWatcher)이 이 값을 읽어서 켠다. 테스트에서는 끈다.
final badgeCheckProvider = Provider<bool>((ref) {
  void check() {
    final child = ref.read(currentChildProvider).value;
    if (child == null) {
      return;
    }
    ref.read(badgeRepositoryProvider).evaluate(childId: child.id).then((
      awarded,
    ) {
      if (awarded.isNotEmpty) {
        ref.read(badgePopupQueueProvider.notifier).add(awarded);
      }
    });
  }

  ref.listen(currentChildProvider, (_, _) => check(), fireImmediately: true);
  ref.listen(stickerHistoryProvider, (_, _) => check());
  ref.listen(clearDatesProvider, (_, _) => check());
  ref.listen(diaryEntriesProvider, (_, _) => check());
  ref.listen(duolingoLatestProvider, (_, _) => check());
  return true;
});

/// 부모 설정: 꺼 둔 칭찬·잘못 카테고리까지 (종류별).
final allCategoriesProvider = StreamProvider.family<List<Category>, String>(
  (ref, kind) => ref.watch(catalogRepositoryProvider).watchAllCategories(kind),
);

/// 부모 설정: 꺼 둔 배지까지 모두.
final allBadgesProvider = StreamProvider<List<Badge>>(
  (ref) => ref.watch(badgeRepositoryProvider).watchAllBadges(),
);

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(ref.watch(databaseProvider)),
);

/// 자동 백업 폴더: 앱 문서 폴더 아래 backups.
final backupFilesProvider = FutureProvider<BackupFiles>((_) async {
  final documents = await getApplicationDocumentsDirectory();
  return BackupFiles(Directory(p.join(documents.path, 'backups')));
});

/// 앱을 열 때 오늘 백업이 없으면 한 번 만든다. 만들었으면 날짜, 아니면 null.
final dailyBackupProvider = FutureProvider<String?>((ref) async {
  final child = ref.watch(currentChildProvider).value;
  if (child == null) {
    return null;
  }
  final files = await ref.watch(backupFilesProvider.future);
  final today = localDateKey(DateTime.now());
  if (await files.hasDay(today)) {
    return null;
  }
  final json = await ref.read(backupServiceProvider).exportJson();
  await files.write(today, json);
  return today;
});

/// 사진첩에서 고른 사진을 앱 안에 복사해 두는 곳 (앱 문서 폴더 아래 media).
final mediaStoreProvider = FutureProvider<MediaStore>((_) async {
  final documents = await getApplicationDocumentsDirectory();
  return MediaStore(Directory(p.join(documents.path, 'media')));
});

/// 효과음. 소리 켜기 설정을 매번 확인한다.
final soundPlayerProvider = Provider<SoundPlayer>((ref) {
  final output = AudioPlayerOutput();
  ref.onDispose(output.dispose);
  return SoundPlayer(
    output,
    isOn: () async =>
        await ref
            .read(settingsRepositoryProvider)
            .getInt('sound_on', fallback: 1) ==
        1,
  );
});

/// 캐릭터 8칸 (사진·이름)과 지금 쓰는 칸. 이전 버전의 캐릭터 사진은 1번 칸으로 옮겨 쓴다.
final characterRosterProvider = FutureProvider<CharacterRoster>((ref) async {
  final settings = ref.watch(settingsRepositoryProvider);
  final active = (await settings.getInt(
    'character_active',
    fallback: 0,
  )).clamp(0, characterSlotCount - 1);
  final slots = <CharacterSlot>[];
  for (var i = 0; i < characterSlotCount; i++) {
    final name = (await settings.get('character_name_$i'))?.trim();
    var photo = await settings.get('character_slot_$i');
    if (i == 0 && photo == null) {
      photo = await settings.get('character_photo');
    }
    slots.add(
      CharacterSlot(
        index: i,
        name: name == null || name.isEmpty ? defaultCharacterName(i) : name,
        photo: photo == null || photo.isEmpty ? null : photo,
      ),
    );
  }
  return CharacterRoster(active: active, slots: slots);
});

/// 무작위 값. 테스트에서는 정해진 값으로 바꾼다.
final randomProvider = Provider<Random>((_) => Random());

/// 오늘 처음 앱을 열었을 때 칭찬 문구 팝업 (하루 한 번, 절반쯤만 띄운다). 없으면 null.
final dailyPraiseProvider = FutureProvider<String?>((ref) async {
  final child = ref.watch(currentChildProvider).value;
  if (child == null) {
    return null;
  }
  final settings = ref.read(settingsRepositoryProvider);
  final today = localDateKey(DateTime.now());
  if (await settings.get('praise_day') == today) {
    return null;
  }
  await settings.set('praise_day', today);
  final texts = await ref.read(praiseTextsProvider.future);
  return pickPraise(texts, ref.read(randomProvider));
});

/// 오늘 할 일 진행률 (홈 · 할 일 탭).
final dailyProgressProvider = Provider<DailyProgress>((ref) {
  final routines = ref.watch(routinesProvider).value ?? const <Routine>[];
  final logs =
      ref.watch(routineLogsProvider(localDateKey(DateTime.now()))).value ??
      const <RoutineLog>[];
  return DailyProgress.count(
    routines: [
      for (final routine in routines)
        (
          id: routine.id,
          daysMask: routine.daysMask,
          isActive: routine.isActive,
        ),
    ],
    loggedIds: {for (final log in logs) log.routineId},
    now: DateTime.now(),
  );
});

/// 일요일 저녁 이번 주 리포트 안내를 띄울지. 닫으면 그 주에는 다시 안 뜬다.
final weeklyReportBannerProvider = FutureProvider<bool>((ref) async {
  final seen = await ref
      .watch(settingsRepositoryProvider)
      .get('report_seen_week');
  return shouldShowWeeklyReport(now: DateTime.now(), seenWeekKey: seen);
});

/// 월드 배경 사진 경로 (1~5 월드, 0부터). 없으면 null.
final worldPhotoProvider = FutureProvider.family<String?, int>((
  ref,
  world,
) async {
  final path = await ref
      .watch(settingsRepositoryProvider)
      .get('world_photo_$world');
  return path == null || path.isEmpty ? null : path;
});
