import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/core/auth/token_storage.dart';
import 'package:movielog/core/network/api_error.dart';
import 'package:movielog/data/models/auth_models.dart';

class MemoryTokenStorage implements TokenStorage {
  String? token;
  @override
  Future<void> deleteAccessToken() async => token = null;
  @override
  Future<String?> readAccessToken() async => token;
  @override
  Future<void> writeAccessToken(String value) async => token = value;
}

void main() {
  test('토큰 저장소는 write/read/delete를 지원한다', () async {
    final storage = MemoryTokenStorage();
    await storage.writeAccessToken('secret');
    expect(await storage.readAccessToken(), 'secret');
    await storage.deleteAccessToken();
    expect(await storage.readAccessToken(), isNull);
  });

  test('로그인 응답은 memberId를 추정하지 않고 토큰만 파싱한다', () {
    final result = LoginResult.fromJson({
      'nickname': '구름',
      'accessToken': 'jwt',
    });
    expect(result.nickname, '구름');
    expect(result.accessToken, 'jwt');
  });

  test('보호 요청의 인증 오류만 만료 세션으로 분류한다', () {
    DioException error(String code) => DioException(
      requestOptions: RequestOptions(path: '/v7/members/me'),
      response: Response(
        requestOptions: RequestOptions(path: '/v7/members/me'),
        data: {'code': code},
      ),
    );
    expect(isExpiredSession(error('AUTH401_3')), isTrue);
    expect(isExpiredSession(error('AUTH401_1')), isFalse);
    expect(isExpiredSession(error('RATING403_1')), isFalse);
  });
}
