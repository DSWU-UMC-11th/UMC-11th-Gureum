import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/models/create_member_request.dart';
import '../data/services/sign_up_service.dart';
import '../validators/input_validators.dart';

enum CheckStatus { idle, checking, available, duplicated, error }

enum SubmitStatus { idle, submitting, success, error }

class SignUpViewModel extends ChangeNotifier {
  SignUpViewModel(this._service);
  final SignUpService _service;

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
  SubmitStatus submitStatus = SubmitStatus.idle;
  int? createdMemberId;
  String? createdEmail;
  String? createdNickname;
  String? passwordErrorText;
  String? snackbarMessage;

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

  bool get isSubmitting => submitStatus == SubmitStatus.submitting;

  void onNicknameChanged(String value) {
    _nickname = value.trim();
    _nicknameVersion++;
    snackbarMessage = null;
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
    snackbarMessage = null;
    if (_duplicatedEmail == _email) {
      emailStatus = CheckStatus.duplicated;
      emailErrorText = '이미 사용 중인 이메일입니다.';
    } else {
      emailStatus = CheckStatus.idle;
      emailErrorText = null;
    }
    _notify();
  }

  void onPasswordChanged() {
    passwordErrorText = null;
    snackbarMessage = null;
    _notify();
  }

  Future<void> submit(CreateMemberRequest request) async {
    if (isSubmitting || !checksComplete) return;
    submitStatus = SubmitStatus.submitting;
    createdMemberId = null;
    passwordErrorText = null;
    snackbarMessage = null;
    _notify();
    try {
      final response = await _service.signUp(request);
      final result = response.result;
      if (result == null) {
        throw StateError('회원가입 결과에 memberId가 없습니다.');
      }
      createdMemberId = result.memberId;
      createdEmail = result.email;
      createdNickname = result.nickname;
      submitStatus = SubmitStatus.success;
    } on DioException catch (error) {
      submitStatus = SubmitStatus.error;
      final message = writeSignUpErrorMessage(error);
      if (error.response?.statusCode == 400 && message.contains('비밀번호')) {
        passwordErrorText = message;
      } else {
        snackbarMessage = message;
      }
    } on StateError {
      submitStatus = SubmitStatus.error;
      snackbarMessage = '가입 결과를 확인하지 못했습니다. 새 요청 전에 서버 상태를 확인해 주세요.';
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
