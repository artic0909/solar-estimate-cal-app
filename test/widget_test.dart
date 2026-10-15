import 'package:flutter_test/flutter_test.dart';
import 'package:solar_estimate_calculator/main.dart';

void main() {
  testWidgets('App loads tablet layout smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SolarEstimateApp());

    expect(find.text('Tablet Layout Ready'), findsOneWidget);
  });
}
