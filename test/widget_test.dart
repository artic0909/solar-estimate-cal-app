import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_estimate_calculator/main.dart';

void main() {
  testWidgets('App loads splash, navigates to welcome screen, user form, and calculator',
      (WidgetTester tester) async {
    // Set tablet landscape viewport
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SolarEstimateApp());

    // 1. Expect splash screen elements
    expect(find.text('WEBS'), findsOneWidget);

    // Pump past splash screen timer and animation
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // 2. Expect welcome screen headline & CTA button
    expect(find.text('CALCULATE MY SAVINGS'), findsOneWidget);
    expect(find.text('Think you know'), findsOneWidget);

    // Tap CTA button
    await tester.tap(find.text('CALCULATE MY SAVINGS'));
    await tester.pumpAndSettle();

    // 3. Expect User Form Screen with Full Name, Phone number, Email Address
    expect(find.text('Customer Details'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);

    // Fill form fields
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter full name (e.g. Rahul Sharma)'),
        'Amit Patel');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter mobile number (e.g. 9876543210)'),
        '9876543210');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter email address (e.g. name@example.com)'),
        'amit.patel@example.com');
    await tester.pumpAndSettle();

    // Submit form
    await tester.tap(find.text('PROCEED TO CALCULATOR'));
    await tester.pumpAndSettle();

    // 4. Expect proposal for customer in tablet workspace
    expect(find.text('Proposal for Amit Patel'), findsOneWidget);
  });
}
