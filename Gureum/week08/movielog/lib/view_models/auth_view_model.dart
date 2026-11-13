import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/auth/token_storage.dart';
import '../core/network/api_error.dart';
import '../data/models/auth_models.dart';
import '../data/services/auth_api_service.dart';

enum AuthStatus {
  initializing,
  signedOut,
  authenticating,
  signedIn,
  retryRequired,
}

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._api, this._storage);

  final AuthGateway _api;
  final TokenStorage _storage;
  AuthStatus status = AuthStatus.initializing;
  MemberProfile? member;
  String? message;
  bool sessionExpired = false;
  int _sessionVersion = 0;
  bool _disposed = false;

  Future<void> restoreSession() async {
    final version = ++_sessionVersion;
    status = AuthStatus.initializing;
    member = null;
    message = null;
    _notify();
    try {
      final token = await _storage.readAccessToken();
      if (!_isCurrent(version)) return;
      if (token == null || token.isEmpty) {
        status = AuthStatus.signedOut;
      } else {
        final verifiedMember = await _api.fetchMe();
        if (!_isCurrent(version)) return;
        member = verifiedMember;
        status = AuthStatus.signedIn;
      }
    } on DioException catch (error) {
      if (!_isCurrent(version)) return;
      if (isExpiredSession(error)) {
        await _clearSession(expired: true);
        return;
      }
      // 일시적인 네트워크 실패에서는 유효할 수 있는 토큰을 삭제하지 않는다.
      status = AuthStatus.retryRequired;
      message = '로그인 상태를 확인하지 못했어요. 다시 시도해 주세요.';
    }
    if (_isCurrent(version)) _notify();
  }

  Future<void> login(String email, String password) async {
    final version = ++_sessionVersion;
    status = AuthStatus.authenticating;
    message = null;
    _notify();
    try {
      await _api.login(email, password);
      if (!_isCurrent(version)) return;
      // 토큰 문자열만으로 로그인 완료로 보지 않고 서버의 내 정보로 검증한다.
      final verifiedMember = await _api.fetchMe();
      if (!_isCurrent(version)) return;
      member = verifiedMember;
      status = AuthStatus.signedIn;
    } on DioException catch (error) {
      if (!_isCurrent(version)) return;
      status = AuthStatus.signedOut;
      message = apiErrorMessage(error);
    }
    if (_isCurrent(version)) _notify();
  }

  Future<void> logout() async {
    ++_sessionVersion; // 이전 세션의 늦은 응답을 무효화한다.
    await _clearSession(expired: false);
  }

  Future<void> _clearSession({required bool expired}) async {
    await _storage.deleteAccessToken();
    member = null;
    status = AuthStatus.signedOut;
    sessionExpired = expired;
    _notify();
  }

  bool consumeSessionExpired() {
    final value = sessionExpired;
    sessionExpired = false;
    return value;
  }

  bool _isCurrent(int version) => !_disposed && version == _sessionVersion;
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
