import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticker_world/app.dart';
import 'package:sticker_world/core/assets/asset_resolver.dart';
import 'package:sticker_world/core/router/routes.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/providers.dart';
import 'package:sticker_world/data/repositories/settings_repository.dart';
import 'package:sticker_world/domain/pin_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 태블릿은 세로로만 쓴다 (듀오링고와 같은 방향).
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await AssetResolver.init();

  final database = AppDatabase(driftDatabase(name: 'sticker_world'));
  final hasPin = await PinService(SettingsRepository(database)).hasPin();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        initialLocationProvider.overrideWithValue(
          hasPin ? Routes.home : Routes.onboarding,
        ),
      ],
      child: const StickerWorldApp(),
    ),
  );
}
