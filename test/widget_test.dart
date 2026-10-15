import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_estimate_calculator/main.dart';

void main() {
  testWidgets('Full flow in Tablet Landscape mode with forwarded user data',
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

    // 1. User Form Screen
    expect(find.text('Customer Details'), findsOneWidget);

    // Enter User Data (Numbers only for phone)
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter full name'),
        'Amit Patel');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter 10-digit mobile number'),
        '9876543210');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter email address'),
        'amit.patel@example.com');
    await tester.pumpAndSettle();

    // Submit user form
    await tester.tap(find.text('PROCEED TO CALCULATOR'));
    await tester.pumpAndSettle();

    // 2. Calculator Screen ("TELL US ABOUT YOUR HOME")
    expect(find.text('TELL US ABOUT YOUR HOME'), findsOneWidget);
    // User data forwarded check
    expect(find.text('Amit Patel'), findsWidgets);
    expect(find.text('📞 9876543210'), findsOneWidget);
    expect(find.text('State'), findsOneWidget);
    expect(find.text('Monthly Electricity Bill (₹)'), findsOneWidget);
    expect(find.text('Property Type'), findsOneWidget);
    expect(find.text('Installation Type'), findsOneWidget);
    expect(find.text('Household Appliances'), findsOneWidget);
    expect(find.text('GET MY ESTIMATE'), findsOneWidget);

    // Verify offline labels are removed from UI
    expect(find.text('Offline'), findsNothing);
    expect(find.text('Offline Mode'), findsNothing);
    expect(find.text('100% Offline'), findsNothing);

    // Click GET MY ESTIMATE - verify NO popup dialog appears
    await tester.tap(find.text('GET MY ESTIMATE'));
    await tester.pump();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Full flow in Tablet Portrait mode with forwarded user data',
      (WidgetTester tester) async {
    // Portrait tablet (800x1280)
    tester.view.physicalSize = const Size(800, 1280);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SolarEstimateApp());
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Verify no offline text on welcome screen
    expect(find.text('Offline Mode'), findsNothing);
    expect(find.text('100% Offline Mode • Instant Tablet Estimates'), findsNothing);

    await tester.tap(find.text('CALCULATE MY SAVINGS'));
    await tester.pumpAndSettle();

    // Verify no offline text on user form
    expect(find.text('100% Offline'), findsNothing);

    // Fill user form in portrait
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter full name'),
        'Priya Roy');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter 10-digit mobile number'),
        '9123456789');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter email address'),
        'priya@example.com');
    await tester.pumpAndSettle();

    await tester.tap(find.text('PROCEED TO CALCULATOR'));
    await tester.pumpAndSettle();

    // Calculator screen in portrait
    expect(find.text('TELL US ABOUT YOUR HOME'), findsOneWidget);
    expect(find.text('Priya Roy'), findsWidgets);
    expect(find.text('GET MY ESTIMATE'), findsOneWidget);

    // Click GET MY ESTIMATE - verify NO popup dialog appears
    await tester.tap(find.text('GET MY ESTIMATE'));
    await tester.pump();
    expect(find.byType(AlertDialog), findsNothing);
  });
}
