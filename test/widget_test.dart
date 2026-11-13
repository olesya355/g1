
import 'package:flutter_test/flutter_test.dart';
import 'package:lab5/main.dart';

void main() {
  testWidgets('Проверка запуска приложения', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MyApp(),
    );

    expect(find.text('Расчёт ускорения'), findsOneWidget);
  });
}
