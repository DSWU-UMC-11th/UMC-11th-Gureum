import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/movie_log_app.dart';
import 'package:movielog/router/app_router.dart';

void main() {
  testWidgets('시작 화면에서 회원가입 화면으로 이동한다', (tester) async {
    AppRouter.router.go('/start');
    await tester.pumpWidget(const MovieLogApp());
    await tester.pumpAndSettle();

    expect(find.text('영화의 순간을\n기록하세요'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, '시작하기'));
    await tester.pumpAndSettle();
    expect(find.text('MovieLog 시작하기'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
  });

  testWidgets('영화 목록에서 카드가 표시된다', (tester) async {
    AppRouter.router.go('/movies');
    await tester.pumpWidget(const MovieLogApp());
    await tester.pumpAndSettle();

    expect(find.text('영화'), findsWidgets);
    expect(find.text('별빛 아래 우리'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
