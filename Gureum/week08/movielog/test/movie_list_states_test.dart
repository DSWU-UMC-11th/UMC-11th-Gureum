import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/widgets/movie_list_states.dart';

Widget _app(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('Loading 상태는 진행 표시를 보여준다', (tester) async {
    await tester.pumpWidget(_app(const MovieListLoading()));
    expect(find.byKey(const Key('movie-list-loading')), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });

  testWidgets('Empty 상태는 안내와 전체 보기 버튼을 보여준다', (tester) async {
    await tester.pumpWidget(_app(MovieListEmpty(onShowAll: () {})));
    expect(find.text('조건에 맞는 영화가 없습니다.'), findsOneWidget);
    expect(find.text('전체 보기'), findsOneWidget);
  });

  testWidgets('Error 상태는 재시도 버튼을 제공한다', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      _app(MovieListError(onRetry: () => retried = true)),
    );
    await tester.tap(find.text('다시 시도'));
    expect(retried, isTrue);
  });
}
