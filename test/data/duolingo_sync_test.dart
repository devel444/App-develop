import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_world/data/db/app_database.dart';
import 'package:sticker_world/data/duolingo/duolingo_api.dart';
import 'package:sticker_world/data/duolingo/duolingo_sync.dart';
import 'package:sticker_world/data/duolingo/usage_source.dart';
import 'package:sticker_world/data/repositories/child_repository.dart';
import 'package:sticker_world/data/repositories/duolingo_repository.dart';
import 'package:sticker_world/domain/duolingo_rules.dart';

import '../support/test_database.dart';

class _FakeApi implements DuolingoApi {
  _FakeApi({this.profile, this.error});

  final DuolingoProfile? profile;
  final Exception? error;
  int calls = 0;

  @override
  Future<DuolingoProfile> fetchProfile(String username) async {
    calls++;
    if (error != null) {
      throw error!;
    }
    return profile!;
  }
}

class _FakeUsage implements UsageSource {
  _FakeUsage(this.minutes);

  final int? minutes;

  @override
  Future<int?> minutesToday(String packageName) async => minutes;

  @override
  Future<bool> hasAccess() async => minutes != null;

  @override
  Future<void> openSettings() async {}
}

void main() {
  // 2026-10-22
  late AppDatabase db;
  late FakeClock clock;
  late DuolingoRepository repository;
  late int childId;

  setUp(() async {
    db = createTestDatabase();
    clock = FakeClock();
    repository = DuolingoRepository(db);
    childId = await ChildRepository(db).create(name: '지우');
  });

  tearDown(() => db.close());

  DuolingoSync syncWith({DuolingoApi? api, UsageSource? usage}) {
    return DuolingoSync(
      api: api ?? _FakeApi(error: Exception('연결 안 됨')),
      usage: usage ?? _FakeUsage(null),
      repository: repository,
      clock: clock.call,
    );
  }

  Future<DuolingoJudgement> check(
    DuolingoSync sync, {
    String? username = 'jiwoo',
  }) {
    return sync.check(
      childId: childId,
      username: username,
      packageName: 'com.duolingo',
      usageMinMinutes: 5,
    );
  }

  test('웹 프로필에 오늘 기록이 있으면 웹으로 완료', () async {
    final api = _FakeApi(
      profile: DuolingoProfile(
        raw: '{}',
        totalXp: 900,
        streakEndDate: '2026-10-22',
      ),
    );

    final result = await check(syncWith(api: api));

    expect(result.isDone, isTrue);
    expect(result.method, 'web');
    final latest = await repository.latest(childId);
    expect(latest!.ok, isTrue);
    expect(latest.totalXp, 900);
  });

  test('웹이 안 되면 태블릿 사용 시간으로 완료한다', () async {
    final result = await check(syncWith(usage: _FakeUsage(8)));

    expect(result.isDone, isTrue);
    expect(result.method, 'usage');
    final latest = await repository.latest(childId);
    expect(latest!.ok, isFalse);
  });

  test('웹도 태블릿도 확인이 안 되면 확인 불가', () async {
    final result = await check(syncWith());

    expect(result.status, DuolingoStatus.unknown);
  });

  test('웹은 되는데 오늘 기록이 없으면 아직 안 한 것', () async {
    final api = _FakeApi(
      profile: DuolingoProfile(
        raw: '{}',
        totalXp: 900,
        streakEndDate: '2026-10-21',
      ),
    );

    final result = await check(syncWith(api: api));

    expect(result.status, DuolingoStatus.notYet);
  });

  test('아이디가 비어 있으면 웹은 건너뛰고 태블릿만 본다', () async {
    final api = _FakeApi(profile: DuolingoProfile(raw: '{}', totalXp: 1));

    final result = await check(
      syncWith(api: api, usage: _FakeUsage(0)),
      username: '',
    );

    expect(api.calls, 0);
    expect(result.status, DuolingoStatus.notYet);
    expect(result.method, 'usage');
  });

  test('전날 저장한 XP보다 늘면 완료로 본다', () async {
    // 어제 저장된 기록
    clock.now = DateTime(2026, 10, 21, 20);
    await repository.saveSnapshot(
      childId: childId,
      method: 'web',
      ok: true,
      profile: DuolingoProfile(raw: '{}', totalXp: 1000),
      when: clock.now,
    );
    clock.now = DateTime(2026, 10, 22, 9);
    final api = _FakeApi(profile: DuolingoProfile(raw: '{}', totalXp: 1040));

    final result = await check(syncWith(api: api));

    expect(result.isDone, isTrue);
    expect(result.method, 'web');
  });
}
