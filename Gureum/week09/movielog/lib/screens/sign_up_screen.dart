import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../validators/input_validators.dart';
import '../data/models/create_member_request.dart';
import '../view_models/learning_member_session.dart';
import '../view_models/sign_up_view_model.dart';
import '../widgets/movie_log_text_form_field.dart';
import '../widgets/movielog_button.dart';
import '../widgets/terms_agreement.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _agreedToTerms = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  bool _canSubmit(SignUpViewModel vm) =>
      vm.checksComplete &&
      InputValidators.password(_passwordController.text) == null &&
      _agreedToTerms &&
      !vm.isSubmitting;

  Future<void> _submit(SignUpViewModel vm) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    await vm.submit(
      CreateMemberRequest(
        email: _emailController.text,
        password: _passwordController.text,
        nickname: _nicknameController.text,
      ),
    );
    if (!mounted) return;
    if (vm.submitStatus == SubmitStatus.success && vm.createdMemberId != null) {
      context.read<LearningMemberSession>().setMember(
        id: vm.createdMemberId!,
        email: vm.createdEmail,
        nickname: vm.createdNickname,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원가입 성공 · memberId ${vm.createdMemberId}')),
      );
      context.go('/movies');
    } else if (vm.snackbarMessage != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(vm.snackbarMessage!)));
    }
  }

  String? _helper(CheckStatus status) =>
      status == CheckStatus.available ? '사용할 수 있습니다.' : null;

  @override
  Widget build(BuildContext context) => Consumer<SignUpViewModel>(
    builder: (context, vm, _) => PopScope(
      canPop: !vm.isSubmitting,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('MovieLog'),
          actions: [
            PopupMenuButton<CheckStatus>(
              tooltip: '중복 확인 상태 테스트',
              icon: const Icon(Icons.science_outlined),
              onSelected: context.read<SignUpViewModel>().showVerificationState,
              itemBuilder: (_) => const [
                PopupMenuItem(value: CheckStatus.idle, child: Text('확인 전')),
                PopupMenuItem(value: CheckStatus.checking, child: Text('통신 중')),
                PopupMenuItem(
                  value: CheckStatus.available,
                  child: Text('사용 가능'),
                ),
                PopupMenuItem(value: CheckStatus.duplicated, child: Text('중복')),
                PopupMenuItem(value: CheckStatus.error, child: Text('통신 실패')),
              ],
            ),
            PopupMenuButton<String>(
              tooltip: '회원가입 결과 확인',
              icon: const Icon(Icons.fact_check_outlined),
              onSelected: (value) {
                final message = value == 'success'
                    ? '회원가입 성공 · memberId 4 · c717390213@example.com'
                    : 'COMMON409 · 이미 사용 중인 이메일 또는 닉네임입니다.';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'success', child: Text('실제 가입 성공 확인')),
                PopupMenuItem(value: 'conflict', child: Text('최종 중복 409 확인')),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'MovieLog 시작하기',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      const Text('나만의 영화 기록을 위해 정보를 입력해주세요.'),
                      const SizedBox(height: 28),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: MovieLogTextFormField(
                              controller: _nicknameController,
                              focusNode: _nicknameFocusNode,
                              labelText: '닉네임',
                              hintText: '두 글자 이상 입력',
                              prefixIcon: Icons.person_outline,
                              validator: InputValidators.nickname,
                              errorText: vm.nicknameErrorText,
                              helperText: _helper(vm.nicknameStatus),
                              onChanged: (value) {
                                vm.onNicknameChanged(value);
                                setState(() {});
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          MovieLogButton(
                            label: '중복 확인',
                            isLoading:
                                vm.nicknameStatus == CheckStatus.checking,
                            onPressed: vm.canCheckNickname
                                ? vm.checkNickname
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: MovieLogTextFormField(
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              labelText: '이메일',
                              hintText: 'movielog@example.com',
                              prefixIcon: Icons.mail_outline,
                              validator: InputValidators.email,
                              errorText: vm.emailErrorText,
                              helperText: _helper(vm.emailStatus),
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (value) {
                                vm.onEmailChanged(value);
                                setState(() {});
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          MovieLogButton(
                            label: '중복 확인',
                            width: 96,
                            isLoading: vm.emailStatus == CheckStatus.checking,
                            onPressed: vm.canCheckEmail ? vm.checkEmail : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      MovieLogTextFormField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        labelText: '비밀번호',
                        hintText: '8자 이상 입력',
                        prefixIcon: Icons.lock_outline,
                        validator: InputValidators.password,
                        errorText: vm.passwordErrorText,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword ? '비밀번호 표시' : '비밀번호 숨기기',
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                        onChanged: (_) {
                          vm.onPasswordChanged();
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 8),
                      TermsAgreement(
                        value: _agreedToTerms,
                        onChanged: (value) =>
                            setState(() => _agreedToTerms = value),
                      ),
                      const SizedBox(height: 20),
                      MovieLogButton(
                        label: '가입하기',
                        width: double.infinity,
                        isLoading: vm.isSubmitting,
                        onPressed: _canSubmit(vm) ? () => _submit(vm) : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MovieLogButton(label: '내용 너비', onPressed: () {}),
                          const SizedBox(width: 8),
                          MovieLogButton(
                            label: '고정 96',
                            width: 96,
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
