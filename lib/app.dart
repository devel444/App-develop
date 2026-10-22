import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sticker_world/core/router/app_router.dart';
import 'package:sticker_world/core/theme/app_theme.dart';

final routerProvider = Provider<GoRouter>((_) => buildRouter());

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
