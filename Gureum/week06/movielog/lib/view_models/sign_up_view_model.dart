import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/services/member_check_service.dart';
import '../validators/input_validators.dart';

enum CheckStatus { idle, checking, available, duplicated, error }

class SignUpViewModel extends ChangeNotifier {
  SignUpViewModel(this._service);
  final MemberCheckService _service;

  CheckStatus nicknameStatus = CheckStatus.idle;
  CheckStatus emailStatus = CheckStatus.idle;
  String? nicknameErrorText;
  String? emailErrorText;
  String _nickname = '';
  String _email = '';
  String? _duplicatedNickname;
  String? _duplicatedEmail;
  int _nicknameVersion = 0;
  int _emailVersion = 0;
  bool _disposed = false;

  bool get canCheckNickname =>
      InputValidators.nickname(_nickname) == null &&
      nicknameStatus != CheckStatus.checking &&
      nicknameStatus != CheckStatus.duplicated;
  bool get canCheckEmail =>
      InputValidators.email(_email) == null &&
      emailStatus != CheckStatus.checking &&
      emailStatus != CheckStatus.duplicated;
  bool get checksComplete =>
      nicknameStatus == CheckStatus.available &&
      emailStatus == CheckStatus.available;

  void onNicknameChanged(String value) {
    _nickname = value.trim();
    _nicknameVersion++;
    if (_duplicatedNickname == _nickname) {
      nicknameStatus = CheckStatus.duplicated;
      nicknameErrorText = '이미 사용 중인 닉네임입니다.';
    } else {
      nicknameStatus = CheckStatus.idle;
      nicknameErrorText = null;
    }
    _notify();
  }

  void onEmailChanged(String value) {
    _email = value.trim();
    _emailVersion++;
    if (_duplicatedEmail == _email) {
      emailStatus = CheckStatus.duplicated;
      emailErrorText = '이미 사용 중인 이메일입니다.';
    } else {
      emailStatus = CheckStatus.idle;
      emailErrorText = null;
    }
    _notify();
  }

  Future<void> checkNickname() async {
    final requested = _nickname;
    if (!canCheckNickname) return;
    final version = ++_nicknameVersion;
    nicknameStatus = CheckStatus.checking;
    nicknameErrorText = null;
    _notify();
    try {
      final available = await _service.checkNickname(requested);
      if (_disposed || version != _nicknameVersion || requested != _nickname) {
        return;
      }
      nicknameStatus = available
          ? CheckStatus.available
          : CheckStatus.duplicated;
      nicknameErrorText = available ? null : '이미 사용 중인 닉네임입니다.';
      if (!available) _duplicatedNickname = requested;
    } on DioException {
      if (_disposed || version != _nicknameVersion) return;
      nicknameStatus = CheckStatus.error;
      nicknameErrorText = '중복 확인에 실패했습니다. 다시 시도해 주세요.';
    }
    _notify();
  }

  Future<void> checkEmail() async {
    final requested = _email;
    if (!canCheckEmail) return;
    final version = ++_emailVersion;
    emailStatus = CheckStatus.checking;
    emailErrorText = null;
    _notify();
    try {
      final available = await _service.checkEmail(requested);
      if (_disposed || version != _emailVersion || requested != _email) return;
      emailStatus = available ? CheckStatus.available : CheckStatus.duplicated;
      emailErrorText = available ? null : '이미 사용 중인 이메일입니다.';
      if (!available) _duplicatedEmail = requested;
    } on DioException {
      if (_disposed || version != _emailVersion) return;
      emailStatus = CheckStatus.error;
      emailErrorText = '중복 확인에 실패했습니다. 다시 시도해 주세요.';
    }
    _notify();
  }

  void showVerificationState(CheckStatus status) {
    nicknameStatus = status;
    if (status == CheckStatus.duplicated && _nickname.isNotEmpty) {
      _duplicatedNickname = _nickname;
    }
    nicknameErrorText = switch (status) {
      CheckStatus.duplicated => '이미 사용 중인 닉네임입니다.',
      CheckStatus.error => '중복 확인에 실패했습니다. 다시 시도해 주세요.',
      _ => null,
    };
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _nicknameVersion++;
    _emailVersion++;
    super.dispose();
  }
}
