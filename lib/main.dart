import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sticker_world/app.dart';
import 'package:sticker_world/core/assets/asset_resolver.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 태블릿은 세로로만 쓴다 (듀오링고와 같은 방향).
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await AssetResolver.init();
  runApp(const ProviderScope(child: StickerWorldApp()));
}
