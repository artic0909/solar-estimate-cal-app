import 'package:flutter_test/flutter_test.dart';
import 'package:solar_estimate_calculator/main.dart';

void main() {
  testWidgets('App loads splash screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SolarEstimateApp());

    // Expect splash screen elements
    expect(find.text('WEBS'), findsOneWidget);
    expect(find.text("Powering Tomorrow's Energy"), findsOneWidget);

    // Pump past the splash screen timer (2600ms) and transition animation
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Expect tablet layout after splash completes
    expect(find.text('Tablet Layout Ready'), findsOneWidget);
  });
}
