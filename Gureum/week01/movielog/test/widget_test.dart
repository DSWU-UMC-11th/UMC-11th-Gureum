import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/movie_log_app.dart';

void main() {
  testWidgets('시작 화면에 로고 문구와 버튼이 표시된다', (tester) async {
    await tester.pumpWidget(const MovieLogApp());

    expect(find.text('영화의 순간을\n기록하세요'), findsOneWidget);
    expect(find.text('시작하기'), findsOneWidget);
  });
}
