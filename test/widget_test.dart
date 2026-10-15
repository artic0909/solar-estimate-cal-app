import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_estimate_calculator/main.dart';

void main() {
  testWidgets('App works seamlessly in Tablet Landscape mode',
      (WidgetTester tester) async {
    // Landscape tablet (1280x800)
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SolarEstimateApp());
    expect(find.text('WEBS'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 4));
    expect(find.text('CALCULATE MY SAVINGS'), findsOneWidget);

    await tester.tap(find.text('CALCULATE MY SAVINGS'));
    await tester.pumpAndSettle();

    expect(find.text('Customer Details'), findsOneWidget);

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

    await tester.tap(find.text('PROCEED TO CALCULATOR'));
    await tester.pumpAndSettle();

    expect(find.text('Proposal for Amit Patel'), findsOneWidget);
  });

  testWidgets('App works seamlessly in Tablet Portrait mode',
      (WidgetTester tester) async {
    // Portrait tablet (800x1280)
    tester.view.physicalSize = const Size(800, 1280);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SolarEstimateApp());
    expect(find.text('WEBS'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 4));
    expect(find.text('CALCULATE MY SAVINGS'), findsOneWidget);

    // Verify portrait layout elements
    expect(find.text('Offline Mode'), findsOneWidget);

    await tester.tap(find.text('CALCULATE MY SAVINGS'));
    await tester.pumpAndSettle();

    // Verify user form in portrait
    expect(find.text('Customer Details'), findsOneWidget);
    expect(find.text('CSV Local Storage'), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter full name (e.g. Rahul Sharma)'),
        'Priya Roy');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter mobile number (e.g. 9876543210)'),
        '9123456789');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter email address (e.g. name@example.com)'),
        'priya@example.com');
    await tester.pumpAndSettle();

    await tester.tap(find.text('PROCEED TO CALCULATOR'));
    await tester.pumpAndSettle();

    expect(find.text('Proposal for Priya Roy'), findsOneWidget);
  });
}
