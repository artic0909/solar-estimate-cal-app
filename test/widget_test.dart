import 'package:flutter_test/flutter_test.dart';
import 'package:solar_estimate_calculator/main.dart';

void main() {
  testWidgets('App loads splash, navigates to welcome screen, then to calculator',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SolarEstimateApp());

    // Expect splash screen elements
    expect(find.text('WEBS'), findsOneWidget);

    // Pump past splash screen timer and animation
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Expect welcome screen headline & CTA button
    expect(find.text('CALCULATE MY SAVINGS'), findsOneWidget);
    expect(find.text('Think you know'), findsOneWidget);

    // Tap CTA button
    await tester.tap(find.text('CALCULATE MY SAVINGS'));
    await tester.pumpAndSettle();

    // Expect tablet layout
    expect(find.text('Tablet Layout Ready'), findsOneWidget);
  });
}
