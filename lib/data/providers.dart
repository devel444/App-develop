import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/repositories/catalog_repository.dart';
import 'package:sticker_world/data/duolingo/duolingo_api.dart';
import 'package:sticker_world/data/duolingo/duolingo_sync.dart';
import 'package:sticker_world/data/duolingo/usage_source.dart';
import 'package:sticker_world/data/repositories/child_repository.dart';
import 'package:sticker_world/data/repositories/duolingo_repository.dart';
import 'package:sticker_world/data/repositories/reward_repository.dart';
import 'package:sticker_world/data/repositories/routine_repository.dart';
import 'package:sticker_world/data/repositories/settings_repository.dart';
import 'package:sticker_world/data/repositories/sticker_repository.dart';
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
