import 'package:dio/dio.dart';

import '../../core/auth/token_storage.dart';
import '../models/auth_models.dart';

abstract interface class AuthGateway {
  Future<LoginResult> login(String email, String password);
  Future<MemberProfile> fetchMe();
  Future<MemberProfile> updateNickname(String nickname);
  Future<void> logout();
}

class AuthApiService implements AuthGateway {
  const AuthApiService(this._dio, this._storage);
  final Dio _dio;
  final TokenStorage _storage;

  @override
  Future<LoginResult> login(String email, String password) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/v7/auth/login',
      data: {'email': email, 'password': password},
    );
    final result = LoginResult.fromJson(
      response.data!['result'] as Map<String, dynamic>,
    );
    await _storage.writeAccessToken(result.accessToken);
    return result;
  }

  @override
  Future<MemberProfile> fetchMe() async {
    final response = await _dio.get<Map<String, dynamic>>('/v7/members/me');
    return MemberProfile.fromJson(
      response.data!['result'] as Map<String, dynamic>,
    );
  }

  @override
  Future<MemberProfile> updateNickname(String nickname) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/v7/members/me',
      data: {'nickname': nickname},
    );
    return MemberProfile.fromJson(
      response.data!['result'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> logout() => _storage.deleteAccessToken();
}

Dio createAuthenticatedMovieLogClient(TokenStorage storage) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://workbook.devnoco.com',
      headers: {'accept': 'application/json'},
    ),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final protected =
            options.uri.host == 'workbook.devnoco.com' &&
            options.path.startsWith('/v7/') &&
            options.path != '/v7/auth/login';
        if (protected) {
          final token = await storage.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        handler.next(options);
      },
    ),
  );
  return dio;
}
