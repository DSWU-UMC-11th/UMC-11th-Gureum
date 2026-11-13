import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/core/auth/token_storage.dart';
import 'package:movielog/data/models/auth_models.dart';
import 'package:movielog/data/services/auth_api_service.dart';
import 'package:movielog/view_models/auth_view_model.dart';

class FakeStorage implements TokenStorage {
  FakeStorage(this.token);
  String? token;
  int deletes = 0;
  @override
  Future<void> deleteAccessToken() async {
    token = null;
    deletes++;
  }

  @override
  Future<String?> readAccessToken() async => token;
  @override
  Future<void> writeAccessToken(String value) async => token = value;
}

class FakeGateway implements AuthGateway {
  FakeGateway({this.fetchError, this.fetchCompleter});
  final DioException? fetchError;
  final Completer<MemberProfile>? fetchCompleter;
  static final profile = MemberProfile(
    email: 'a@b.com',
    nickname: '구름',
    createdAt: DateTime(2026),
  );
  @override
  Future<MemberProfile> fetchMe() async {
    if (fetchCompleter != null) return fetchCompleter!.future;
    if (fetchError != null) throw fetchError!;
    return profile;
  }

  @override
  Future<LoginResult> login(String email, String password) async =>
      const LoginResult(nickname: '구름', accessToken: 'jwt');
  @override
  Future<void> logout() async {}
  @override
  Future<MemberProfile> updateNickname(String nickname) async => profile;
}

DioException apiError(String code) => DioException(
  requestOptions: RequestOptions(path: '/v7/members/me'),
  response: Response(
    requestOptions: RequestOptions(path: '/v7/members/me'),
    data: {'code': code, 'message': code},
  ),
);

void main() {
  test('저장 토큰은 GET me 검증 뒤에만 signedIn이 된다', () async {
    final vm = AuthViewModel(FakeGateway(), FakeStorage('jwt'));
    await vm.restoreSession();
    expect(vm.status, AuthStatus.signedIn);
    expect(vm.member?.nickname, '구름');
  });

  test('네트워크 실패는 토큰을 삭제하지 않고 재시도 상태가 된다', () async {
    final storage = FakeStorage('jwt');
    final error = DioException(
      requestOptions: RequestOptions(path: '/v7/members/me'),
      type: DioExceptionType.connectionError,
    );
    final vm = AuthViewModel(FakeGateway(fetchError: error), storage);
    await vm.restoreSession();
    expect(vm.status, AuthStatus.retryRequired);
    expect(storage.token, 'jwt');
    expect(storage.deletes, 0);
  });

  test('만료 토큰은 삭제하고 signedOut으로 전환한다', () async {
    final storage = FakeStorage('jwt');
    final vm = AuthViewModel(
      FakeGateway(fetchError: apiError('AUTH401_3')),
      storage,
    );
    await vm.restoreSession();
    expect(vm.status, AuthStatus.signedOut);
    expect(storage.token, isNull);
    expect(vm.consumeSessionExpired(), isTrue);
  });

  test('로그아웃 뒤 이전 세션의 늦은 응답을 무시한다', () async {
    final completer = Completer<MemberProfile>();
    final storage = FakeStorage('jwt');
    final vm = AuthViewModel(FakeGateway(fetchCompleter: completer), storage);
    final pending = vm.restoreSession();
    await Future<void>.delayed(Duration.zero);
    await vm.logout();
    completer.complete(FakeGateway.profile);
    await pending;
    expect(vm.status, AuthStatus.signedOut);
    expect(vm.member, isNull);
  });
}
