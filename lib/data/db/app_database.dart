import 'package:drift/drift.dart';
import 'package:sticker_world/data/db/seed_data.dart';
import 'package:sticker_world/data/db/tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Children,
    Categories,
    Rewards,
    StickerEvents,
    Redemptions,
    Routines,
    RoutineLogs,
    DailyClears,
    DiaryEntries,
    Badges,
    BadgeAwards,
    ReportComments,
    DuolingoSnapshots,
    PraiseTemplates,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await seedDefaults(this);
    },
  );
}
