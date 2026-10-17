import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_estimate_calculator/main.dart';

void main() {
  testWidgets('Splash screen transitions directly to single-page SolarHomeScreen in landscape mode',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SolarEstimateApp());

    // 1. Splash Screen
    expect(find.text('WEBSOL'), findsOneWidget);
    expect(find.text('Solar Estimation Suite'), findsOneWidget);

    // Settle splash timer
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // 2. Section 1: Top Hero
    expect(find.text('CALCULATE MY SAVINGS'), findsOneWidget);
    expect(find.text('Think you know'), findsOneWidget);
    expect(find.text('your solar savings?'), findsOneWidget);

    // 3. Section 2: Tell Us About Your Home
    expect(find.text('TELL US ABOUT YOUR HOME'), findsOneWidget);
    expect(find.text('State/UT'), findsOneWidget);
    expect(find.text('Monthly Electricity Bill (Rs.)'), findsOneWidget);
    expect(find.text('Solar Application'), findsOneWidget);
    expect(find.text('Residential'), findsOneWidget);
    expect(find.text('Commercial'), findsOneWidget);
    expect(find.text('Installation Type'), findsOneWidget);
    expect(find.text('Household Appliances'), findsOneWidget);
    expect(find.text('Fan'), findsWidgets);
    expect(find.text('Light'), findsWidgets);
    expect(find.text('TV'), findsWidgets);
    expect(find.text('AC'), findsWidgets);
    expect(find.text('Washing machine'), findsWidgets);
    expect(find.text('Fridge'), findsWidgets);
    expect(find.text('Electric kettle'), findsWidgets);
    expect(find.text('Induction cooker'), findsWidgets);
    expect(find.text('Submersible pump'), findsWidgets);
    expect(find.text('Geyser'), findsWidgets);
    expect(find.text('GET MY ESTIMATE'), findsOneWidget);
    expect(find.text('CLEAR'), findsOneWidget);

    // Results are hidden initially until user inputs bill + load and taps GET MY ESTIMATE
    expect(find.text('YOUR SOLAR ESTIMATE'), findsNothing);

    // Enter bill and load into respective fields
    final billField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.hintText?.contains('5000') == true);
    await tester.ensureVisible(billField);
    await tester.enterText(billField, '5000');

    final loadField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.hintText?.contains('200') == true);
    await tester.ensureVisible(loadField);
    await tester.enterText(loadField, '4915');
    await tester.pumpAndSettle();

    // Ensure button is visible in scroll view, then tap "GET MY ESTIMATE"
    await tester.ensureVisible(find.text('GET MY ESTIMATE'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('GET MY ESTIMATE'));
    await tester.pumpAndSettle();

    // 4. Section 3: Solar Estimate Metrics
    expect(find.text('YOUR SOLAR ESTIMATE'), findsOneWidget);
    expect(find.text('₹ 3,905'), findsWidgets);
    expect(find.text('₹ 1,095'), findsWidgets);
    expect(find.text('₹ 1,13,850'), findsWidgets);
    expect(find.text('₹ 78,000'), findsWidgets);

    // 5. Section 4: Environmental Impact
    expect(find.text('YOUR IMPACT GOES BEYOND SAVINGS'), findsOneWidget);
    expect(find.text('3.63'), findsWidgets);
    expect(find.text('4.45'), findsWidgets);
    expect(find.text('202'), findsWidgets);

    // 6. Customer Details Form (Full Name, Phone Number, Email)
    expect(find.text('CUSTOMER DETAILS'), findsOneWidget);
    expect(find.text('Full Name *'), findsOneWidget);
    expect(find.text('Phone Number (10 digits) *'), findsOneWidget);
    expect(find.text('Email ID *'), findsOneWidget);
    expect(find.text('SAVE RESULT'), findsNothing);
    expect(find.text('I agree to let Websol use my data to estimate my electricity savings.'), findsOneWidget);
    expect(find.text('SHARE / EXPORT EXCEL'), findsNothing);

    // 7. Section 5: Footer & Brand
    expect(find.text('READY TO EXPLORE\nYOUR SOLAR FUTURE?'), findsOneWidget);
    expect(find.text('Scan the QR code to connect with Websol'), findsOneWidget);
    expect(find.text('CLEANER ENERGY'), findsOneWidget);
    expect(find.text('GREENER TOMORROW'), findsOneWidget);
  });

  testWidgets('Single-page SolarHomeScreen in portrait mode',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1280);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SolarEstimateApp());
    await tester.pumpAndSettle(const Duration(seconds: 4));

    expect(find.text('CALCULATE MY SAVINGS'), findsOneWidget);
    expect(find.text('TELL US ABOUT YOUR HOME'), findsOneWidget);

    // Results are hidden initially until user enters bill + load and taps GET MY ESTIMATE
    expect(find.text('YOUR SOLAR ESTIMATE'), findsNothing);

    // Enter bill and load
    final billField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.hintText?.contains('5000') == true);
    await tester.ensureVisible(billField);
    await tester.enterText(billField, '5000');

    final loadField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.hintText?.contains('200') == true);
    await tester.ensureVisible(loadField);
    await tester.enterText(loadField, '4915');
    await tester.pumpAndSettle();

    // Ensure button is visible in scroll view, then tap "GET MY ESTIMATE"
    await tester.ensureVisible(find.text('GET MY ESTIMATE'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('GET MY ESTIMATE'));
    await tester.pumpAndSettle();

    expect(find.text('YOUR SOLAR ESTIMATE'), findsOneWidget);
    expect(find.text('Estimated Monthly\nSavings'), findsOneWidget);
    expect(find.text('Bill\nReduction'), findsOneWidget);
    expect(find.text('Revised Monthly\nBill'), findsOneWidget);
    expect(find.text('Approx. Cost\nof Modules'), findsOneWidget);
    expect(find.text('Govt. Subsidy\n(PM Surya Ghar)'), findsOneWidget);

    expect(find.text('YOUR IMPACT GOES BEYOND SAVINGS'), findsOneWidget);
    expect(find.text('3.63'), findsWidgets);
    expect(find.text('4.45'), findsWidgets);
    expect(find.text('202'), findsWidgets);

    expect(find.text('CUSTOMER DETAILS'), findsOneWidget);
    expect(find.text('Full Name *'), findsOneWidget);
    expect(find.text('Phone Number (10 digits) *'), findsOneWidget);
    expect(find.text('Email ID *'), findsOneWidget);
    expect(find.text('SHARE / EXPORT EXCEL'), findsNothing);

    expect(find.text('READY TO EXPLORE\nYOUR SOLAR FUTURE?'), findsOneWidget);
    expect(find.text('Scan the QR code to connect with Websol'), findsOneWidget);
  });

  testWidgets('Clicking GET MY ESTIMATE disables/freezes button and auto-saves in background',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SolarEstimateApp());
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Disclaimer text is present right above GET MY ESTIMATE
    expect(find.text('I agree to let Websol use my data to estimate my electricity savings.'), findsOneWidget);

    // Enter bill and load
    final billField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.hintText?.contains('5000') == true);
    await tester.ensureVisible(billField);
    await tester.enterText(billField, '5000');

    final loadField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.hintText?.contains('200') == true);
    await tester.ensureVisible(loadField);
    await tester.enterText(loadField, '4915');
    await tester.pumpAndSettle();

    // Verify GET MY ESTIMATE button is enabled initially
    final estimateBtnFinder = find.widgetWithText(ElevatedButton, 'GET MY ESTIMATE');
    ElevatedButton estimateBtn = tester.widget<ElevatedButton>(estimateBtnFinder);
    expect(estimateBtn.onPressed, isNotNull);

    // Tap GET MY ESTIMATE
    await tester.ensureVisible(estimateBtnFinder);
    await tester.tap(estimateBtnFinder);
    await tester.pumpAndSettle();

    // Verify results are displayed
    expect(find.text('YOUR SOLAR ESTIMATE'), findsOneWidget);

    // SAVE RESULT button is completely removed
    expect(find.text('SAVE RESULT'), findsNothing);

    // Verify GET MY ESTIMATE is now frozen/disabled (onPressed is null)
    estimateBtn = tester.widget<ElevatedButton>(estimateBtnFinder);
    expect(estimateBtn.onPressed, isNull);
  });

  testWidgets('GET MY ESTIMATE freezes until CLEAR button is pressed to unlock it',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SolarEstimateApp());
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Fill customer info and calculator fields
    final nameField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.hintText?.contains('full name') == true);
    final phoneField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.hintText?.contains('10-digit') == true);
    final emailField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.hintText?.contains('email address') == true);
    final billField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.hintText?.contains('5000') == true);
    final loadField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.hintText?.contains('200') == true);

    await tester.ensureVisible(nameField);
    await tester.enterText(nameField, 'Supriyo Das');
    await tester.ensureVisible(phoneField);
    await tester.enterText(phoneField, '9876543210');
    await tester.ensureVisible(emailField);
    await tester.enterText(emailField, 'supriyo@example.com');
    await tester.ensureVisible(billField);
    await tester.enterText(billField, '5000');
    await tester.ensureVisible(loadField);
    await tester.enterText(loadField, '4915');
    await tester.pump();

    // Click GET MY ESTIMATE
    final estimateBtnFinder = find.widgetWithText(ElevatedButton, 'GET MY ESTIMATE');
    await tester.ensureVisible(estimateBtnFinder);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(estimateBtnFinder);
    await tester.pump(const Duration(seconds: 4));

    // Verify button is frozen
    ElevatedButton estimateBtn = tester.widget<ElevatedButton>(estimateBtnFinder);
    expect(estimateBtn.onPressed, isNull);

    // Verify form fields are STILL intact
    expect(find.text('Supriyo Das'), findsOneWidget);
    expect(find.text('9876543210'), findsOneWidget);
    expect(find.text('supriyo@example.com'), findsOneWidget);
    expect(find.text('5000'), findsOneWidget);
    expect(find.text('4915'), findsOneWidget);

    // Tap CLEAR button
    await tester.ensureVisible(find.text('CLEAR'));
    await tester.pump();
    await tester.tap(find.text('CLEAR'));
    await tester.pump(const Duration(seconds: 4));

    // Form fields must now be reset
    expect(find.text('Supriyo Das'), findsNothing);
    expect(find.text('9876543210'), findsNothing);
    expect(find.text('supriyo@example.com'), findsNothing);
    expect(find.text('YOUR SOLAR ESTIMATE'), findsNothing);

    // Button must now be unlocked (onPressed is not null)
    estimateBtn = tester.widget<ElevatedButton>(estimateBtnFinder);
    expect(estimateBtn.onPressed, isNotNull);
  });
}
