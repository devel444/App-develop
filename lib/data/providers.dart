import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/repositories/child_repository.dart';
import 'package:sticker_world/data/repositories/settings_repository.dart';
import 'package:sticker_world/data/repositories/sticker_repository.dart';
import 'package:sticker_world/domain/pin_service.dart';

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

/// 아이의 잔액과 누적 받은 개수. 아이가 없으면 0.
final stickerSummaryProvider = StreamProvider<StickerSummary>((ref) {
  final child = ref.watch(currentChildProvider).value;
  if (child == null) {
    return Stream.value(StickerSummary.empty);
  }
  return ref.watch(stickerRepositoryProvider).watchSummary(child.id);
});
