import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/domain/character_roster.dart';

void main() {
  test('처음에는 8칸이 모두 기본 이름이고, 첫 칸이 쓰는 캐릭터다', () {
    final roster = CharacterRoster.empty;

    expect(roster.slots, hasLength(characterSlotCount));
    expect(roster.slots.first.name, '캐릭터 1');
    expect(roster.slots.last.name, '캐릭터 8');
    expect(roster.activeSlot.index, 0);
    expect(roster.activeSlot.photo, isNull);
  });

  test('쓰는 칸을 바꾸면 그 칸의 사진과 이름이 따라온다', () {
    final roster = CharacterRoster(
      active: 2,
      slots: [
        for (var i = 0; i < characterSlotCount; i++)
          CharacterSlot(
            index: i,
            name: defaultCharacterName(i),
            photo: i == 2 ? '/app/media/character3.png' : null,
          ),
      ],
    );

    expect(roster.activeSlot.name, '캐릭터 3');
    expect(roster.activeSlot.photo, '/app/media/character3.png');
  });
}
