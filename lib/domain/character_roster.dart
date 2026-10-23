/// 캐릭터 칸 수. 칸마다 사진과 이름을 따로 둔다. 고른 칸이 홈과 맵 토큰에 보인다.
const characterSlotCount = 8;

/// 이름을 적지 않았을 때 쓰는 기본 이름.
String defaultCharacterName(int index) => '캐릭터 ${index + 1}';

class CharacterSlot {
  const CharacterSlot({required this.index, required this.name, this.photo});

  final int index;
  final String name;

  /// 앱 안에 복사해 둔 사진 경로. 없으면 null (기본 그림을 쓴다).
  final String? photo;
}

class CharacterRoster {
  const CharacterRoster({required this.active, required this.slots});

  /// 아직 아무것도 설정하지 않았을 때.
  static final empty = CharacterRoster(
    active: 0,
    slots: [
      for (var i = 0; i < characterSlotCount; i++)
        CharacterSlot(index: i, name: defaultCharacterName(i)),
    ],
  );

  /// 지금 쓰는 칸 번호 (0부터).
  final int active;
  final List<CharacterSlot> slots;

  CharacterSlot get activeSlot => slots[active];
}
