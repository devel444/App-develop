import 'package:drift/native.dart';
import 'package:sticker_world/data/db/app_database.dart';

/// 테스트마다 새 메모리 DB를 쓴다. 기본값 시드도 같이 들어간다.
AppDatabase createTestDatabase() => AppDatabase(NativeDatabase.memory());

/// 시간을 손으로 옮길 수 있는 시계 (잠금 시간 테스트용).
class FakeClock {
  DateTime now = DateTime(2026, 10, 22, 9);

  DateTime call() => now;

  void advance(Duration by) => now = now.add(by);
}
