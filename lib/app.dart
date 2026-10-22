import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sticker_world/core/router/app_router.dart';
import 'package:sticker_world/core/router/routes.dart';
import 'package:sticker_world/core/theme/app_theme.dart';

/// 처음 여는 화면. main에서 부모 PIN이 있는지 보고 정한다.
final initialLocationProvider = Provider<String>((_) => Routes.home);

final routerProvider = Provider<GoRouter>(
  (ref) => buildRouter(initialLocation: ref.watch(initialLocationProvider)),
);

class StickerWorldApp extends ConsumerWidget {
  const StickerWorldApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: '지우의 스티커 월드',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
