import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/core/theme/app_theme.dart';
import 'package:sticker_world/core/widgets/white_frame_card.dart';
import 'package:sticker_world/data/providers.dart';
import 'package:sticker_world/domain/character_roster.dart';
import 'package:sticker_world/domain/sticker_ledger.dart';
import 'package:sticker_world/features/world/map_screen.dart';

Widget _map() {
  return ProviderScope(
    overrides: [
      ledgerProvider.overrideWith((ref) => Stream.value(LedgerView.empty)),
      categoryColorsProvider.overrideWith((ref) async => const {}),
      activeRewardsProvider.overrideWith((ref) => Stream.value(const [])),
      characterRosterProvider.overrideWith(
        (ref) async => CharacterRoster.empty,
      ),
      worldPhotoProvider.overrideWith((ref, world) async => null),
    ],
    child: MaterialApp(theme: buildAppTheme(), home: const MapScreen()),
  );
}

void main() {
  // 8인치 태블릿(세로)과 그보다 큰 화면에서 1월드 20칸이 모두 카드 안에 보여야 한다.
  for (final size in const [Size(600, 960), Size(800, 1280)]) {
    testWidgets(
      '맵 ${size.width.toInt()}x${size.height.toInt()}: 20칸이 카드 안에 모두 보인다',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_map());
        await tester.pumpAndSettle();

        final card = tester.getRect(find.byType(WhiteFrameCard));
        for (final number in ['1', '20']) {
          final cell = tester.getRect(find.text(number));
          expect(
            cell.top,
            greaterThanOrEqualTo(card.top),
            reason: '칸 $number 위',
          );
          expect(
            cell.bottom,
            lessThanOrEqualTo(card.bottom),
            reason: '칸 $number 아래',
          );
          expect(
            cell.left,
            greaterThanOrEqualTo(card.left),
            reason: '칸 $number 왼쪽',
          );
          expect(
            cell.right,
            lessThanOrEqualTo(card.right),
            reason: '칸 $number 오른쪽',
          );
        }
      },
    );
  }
}
