import 'package:flutter_test/flutter_test.dart';
import 'package:plantpulse/main.dart';

void main() {
  testWidgets('App loads', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(seen: false));
    expect(find.byType(MyApp), findsOneWidget);
  });
}