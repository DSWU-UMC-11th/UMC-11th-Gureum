import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/data/models/common_response.dart';
import 'package:movielog/data/models/create_member_request.dart';
import 'package:movielog/data/models/rating_request.dart';
import 'package:movielog/data/models/sign_up_models.dart';

void main() {
  test('회원가입 요청은 이메일과 닉네임만 trim하고 비밀번호는 보존한다', () {
    const request = CreateMemberRequest(
      email: ' user@example.com ',
      password: ' Password1! ',
      nickname: ' 구름 ',
    );
    expect(request.toJson(), {
      'email': 'user@example.com',
      'password': ' Password1! ',
      'nickname': '구름',
    });
  });

  test('공통 응답의 result를 SignUpResult로 한 번만 파싱한다', () {
    final response = CommonResponse<SignUpResult>.fromJson({
      'isSuccess': true,
      'code': 'MEMBER201',
      'message': '회원가입 성공',
      'result': {'memberId': 77, 'email': 'user@example.com', 'nickname': '구름'},
    }, (value) => SignUpResult.fromJson(value as Map<String, dynamic>));
    expect(response.result?.memberId, 77);
  });

  test('평점 요청은 정수 1~5만 허용하고 빈 comment는 생략한다', () {
    expect(validateServerScore(5), 5);
    expect(() => validateServerScore(4.5), throwsArgumentError);
    const request = CreateRatingRequest(movieId: 550, score: 5, comment: ' ');
    expect(request.toJson(), {'movieId': 550, 'score': 5});
  });
}
