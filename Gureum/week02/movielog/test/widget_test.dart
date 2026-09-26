import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:movielog/movie_log_app.dart';

void main() {
  testWidgets('회원가입 입력 항목과 비활성 버튼이 표시된다', (tester) async {
    await tester.pumpWidget(const MovieLogApp());

    expect(find.text('MovieLog 시작하기'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '가입하기'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('유효한 입력과 약관 동의 후 가입 버튼이 활성화된다', (tester) async {
    await tester.pumpWidget(const MovieLogApp());

    await tester.enterText(find.byType(TextFormField).at(0), '구름');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'cloud@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), '12345678');
    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '가입하기'),
    );
    expect(button.onPressed, isNotNull);
  });
}
