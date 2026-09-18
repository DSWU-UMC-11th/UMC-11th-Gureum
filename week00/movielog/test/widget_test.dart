import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/main.dart' as app;

void main() {
  testWidgets('MovieLog greeting is displayed', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    expect(find.text('Hello MovieLog!'), findsOneWidget);
  });
}
