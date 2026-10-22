import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sticker_world/domain/duolingo_rules.dart';

/// 듀오링고 프로필을 가져온다. 비공식 공개 엔드포인트라서 언제든 바뀔 수 있다.
/// 아이 비밀번호는 쓰지 않는다 (CLAUDE.md). 프로필이 공개 상태여야 한다.
abstract interface class DuolingoApi {
  Future<DuolingoProfile> fetchProfile(String username);
}

class DuolingoWebApi implements DuolingoApi {
  DuolingoWebApi({http.Client? client}) : _client = client ?? http.Client();

  static const _base = 'https://www.duolingo.com/2017-06-30/users';
  static const _fields = 'streak,streakData,totalXp';

  final http.Client _client;

  @override
  Future<DuolingoProfile> fetchProfile(String username) async {
    final uri = Uri.parse(_base)
        .replace(queryParameters: {'username': username, 'fields': _fields});
    final response = await _client
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw DuolingoApiException('듀오링고 응답 코드 ${response.statusCode}');
    }
    return parseProfile(response.body);
  }

  /// 응답 JSON을 읽는다. 테스트에서도 쓴다.
  static DuolingoProfile parseProfile(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const DuolingoApiException('응답 형식을 알 수 없어요.');
    }
    final users = decoded['users'];
    if (users is! List ||
        users.isEmpty ||
        users.first is! Map<String, dynamic>) {
      throw const DuolingoApiException('아이디에 맞는 프로필을 찾지 못했어요.');
    }
    final user = users.first as Map<String, dynamic>;

    final streakData = user['streakData'];
    final currentStreak = streakData is Map<String, dynamic>
        ? streakData['currentStreak']
        : null;
    final endDate = currentStreak is Map<String, dynamic>
        ? currentStreak['endDate'] as String?
        : null;

    return DuolingoProfile(
      raw: const JsonEncoder.withIndent('  ').convert(user),
      totalXp: user['totalXp'] as int?,
      streak: user['streak'] as int?,
      streakEndDate: endDate,
    );
  }
}

class DuolingoApiException implements Exception {
  const DuolingoApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
