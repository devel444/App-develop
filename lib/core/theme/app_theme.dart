import 'package:flutter/material.dart';
import 'package:sticker_world/core/theme/app_colors.dart';

/// 앱 전체 테마. 글꼴은 번들한 Jua를 기본으로 쓴다.
/// 한글 본문에 Jua에 없는 글자가 생기면 기기 기본 한글 폰트로 넘어간다.
ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Jua',
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.red),
    scaffoldBackgroundColor: AppColors.sky,
  );
}
