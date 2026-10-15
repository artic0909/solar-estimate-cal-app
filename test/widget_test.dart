import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_estimate_calculator/main.dart';

void main() {
  testWidgets('App loads splash, navigates to welcome screen, then to calculator',
      (WidgetTester tester) async {
    // Set tablet landscape viewport
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
