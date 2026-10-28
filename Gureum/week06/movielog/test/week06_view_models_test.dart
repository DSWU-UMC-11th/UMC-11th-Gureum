import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/data/models/rating_dto.dart';
import 'package:movielog/data/services/member_check_service.dart';
import 'package:movielog/view_models/sign_up_view_model.dart';
import 'package:movielog/widgets/movielog_button.dart';

class _FakeMemberCheckService extends MemberCheckService {
  _FakeMemberCheckService({required this.nicknameAvailable}) : super(Dio());
  bool nicknameAvailable;
  int nicknameCalls = 0;

  @override
  Future<bool> checkNickname(String nickname) async {
    nicknameCalls++;
    return nicknameAvailable;
  }
}

void main() {
  test('RatingDto는 nullable comment와 숫자 점수를 변환한다', () {
    final rating = RatingDto.fromJson({
      'ratingId': 1,
      'movieId': 550,
      'score': 4,
      'comment': null,
      'createdAt': '2026-09-06T12:14:03.000Z',
      'updatedAt': '2026-09-06T12:14:03.000Z',
    });

    expect(rating.score, 4.0);
    expect(rating.comment, isNull);
  });

  test('중복이었던 닉네임을 다시 입력하면 API 재호출 없이 에러가 복원된다', () async {
    final service = _FakeMemberCheckService(nicknameAvailable: false);
    final viewModel = SignUpViewModel(service);

    viewModel.onNicknameChanged('구름');
    await viewModel.checkNickname();
    expect(viewModel.nicknameStatus, CheckStatus.duplicated);
    expect(service.nicknameCalls, 1);

    viewModel.onNicknameChanged('새구름');
    expect(viewModel.nicknameStatus, CheckStatus.idle);
    viewModel.onNicknameChanged('구름');

    expect(viewModel.nicknameStatus, CheckStatus.duplicated);
    expect(service.nicknameCalls, 1);
  });

  testWidgets('MovieLogButton은 로딩 중 버튼을 비활성화하고 인디케이터를 표시한다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MovieLogButton(label: '중복 확인', isLoading: true, onPressed: () {}),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
  });
}
