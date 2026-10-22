import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sticker_world/data/duolingo/duolingo_api.dart';

const _sample = '''
{"users":[{"id":1,"username":"jiwoo","totalXp":1234,"streak":42,
"streakData":{"currentStreak":{"startDate":"2026-09-11","length":42,"endDate":"2026-10-22"}}}]}
''';

void main() {
  test('응답에서 XP, 연속 일수, 마지막 날을 읽는다', () {
    final profile = DuolingoWebApi.parseProfile(_sample);

    expect(profile.totalXp, 1234);
    expect(profile.streak, 42);
    expect(profile.streakEndDate, '2026-10-22');
    expect(profile.raw, contains('jiwoo'));
  });

  test('연속 기록이 없어도 XP만 읽을 수 있다', () {
    final profile = DuolingoWebApi.parseProfile('{"users":[{"totalXp":10}]}');

    expect(profile.totalXp, 10);
    expect(profile.streakEndDate, isNull);
  });

  test('사용자가 없으면 알기 쉬운 오류를 낸다', () {
    expect(
      () => DuolingoWebApi.parseProfile('{"users":[]}'),
      throwsA(isA<DuolingoApiException>()),
    );
  });

  test('요청은 아이디와 필요한 항목만 보내고, 비밀번호는 보내지 않는다', () async {
    late Uri requested;
    final client = MockClient((request) async {
      requested = request.url;
      return http.Response(_sample, 200);
    });
    final api = DuolingoWebApi(client: client);

    await api.fetchProfile('jiwoo');

    expect(requested.host, 'www.duolingo.com');
    expect(requested.queryParameters['username'], 'jiwoo');
    expect(requested.queryParameters.keys, isNot(contains('password')));
    expect(requested.queryParameters['fields'], contains('streakData'));
  });

  test('응답 코드가 200이 아니면 예외를 던진다', () async {
    final client = MockClient((_) async => http.Response('nope', 404));
    final api = DuolingoWebApi(client: client);

    await expectLater(
      api.fetchProfile('jiwoo'),
      throwsA(isA<DuolingoApiException>()),
    );
  });

  test('json 형식이 아니면 예외를 던진다', () {
    expect(
      () => DuolingoWebApi.parseProfile(jsonEncode([1, 2])),
      throwsA(isA<DuolingoApiException>()),
    );
  });
}
