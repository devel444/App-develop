# CLAUDE.md

아이용 칭찬 스티커 + 오늘의 할 일 Flutter 앱 (Android 8인치 태블릿, 세로 고정, 개인 설치용).
전체 설계와 단계별 계획은 `PLAN.md`를 따른다.

## 규칙
- 구현은 `PLAN.md` 11장의 단계(P0~P9) 순서로, 한 단계씩 진행하고 단계마다 커밋한다.
- 스티커 기록은 장부(ledger) 방식: `sticker_events`를 삭제하지 않고, 되돌리기/정정도 새 이벤트로 남긴다.
- 잔액은 항상 0~100 범위. 붙이기/빼기/교환은 모두 부모 PIN 확인 후에만 가능.
- PIN은 평문 저장 금지(salt + SHA-256 해시).
- 듀오링고 비밀번호는 절대 저장하지 않는다. 비공식 API이므로 실패 시 대체 수단(UsageStats → 수동)으로 넘어간다.
- UI 문구는 한국어, 아이 눈높이(짧게, 큰 글씨, 터치 영역 최소 64dp).
- 닌텐도 공식 에셋을 코드에 직접 넣지 않는다. 에셋은 `assets/` 아래에서 교체 가능하게 둔다.

## 명령어
- 실행: `flutter run`
- 테스트: `flutter test`
- 분석: `flutter analyze`
- 코드 생성(drift): `dart run build_runner build --delete-conflicting-outputs`
- APK 빌드: `flutter build apk --release`
