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
    expect(find.text('SAVE RESULT'), findsOneWidget);
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

  testWidgets('Validation: without name, phone, and email, data never saves and shows alert in top right',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SolarEstimateApp());
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Enter bill and load
    final billField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.hintText?.contains('5000') == true);
    await tester.ensureVisible(billField);
    await tester.enterText(billField, '5000');

    final loadField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.hintText?.contains('200') == true);
    await tester.ensureVisible(loadField);
    await tester.enterText(loadField, '4915');
    await tester.pumpAndSettle();

    // Calculate estimate first
    await tester.ensureVisible(find.text('GET MY ESTIMATE'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('GET MY ESTIMATE'));
    await tester.pumpAndSettle();

    // Tap SAVE RESULT without entering customer info
    await tester.ensureVisible(find.text('SAVE RESULT'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SAVE RESULT'));
    await tester.pumpAndSettle();

    // Verify error alert is shown
    expect(find.text('Customer Name Required'), findsOneWidget);
    expect(find.text("Please enter the customer's full name."), findsOneWidget);
  });

  testWidgets('Save result preserves form data until CLEAR button is pressed',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SolarEstimateApp());
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Fill customer info
    // Fill customer info and calculator fields
    final textFields = find.byType(TextField);
    await tester.ensureVisible(textFields.at(0));
    await tester.enterText(textFields.at(0), 'Supriyo Das');
    await tester.ensureVisible(textFields.at(1));
    await tester.enterText(textFields.at(1), '9876543210');
    await tester.ensureVisible(textFields.at(2));
    await tester.enterText(textFields.at(2), 'supriyo@example.com');
    await tester.ensureVisible(textFields.at(3));
    await tester.enterText(textFields.at(3), '5000');
    await tester.ensureVisible(textFields.at(4));
    await tester.enterText(textFields.at(4), '4915');
    await tester.pump();

    // Click GET MY ESTIMATE
    await tester.ensureVisible(find.text('GET MY ESTIMATE'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('GET MY ESTIMATE'));
    await tester.pump(const Duration(seconds: 4));

    // Tap SAVE RESULT
    await tester.ensureVisible(find.text('SAVE RESULT'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('SAVE RESULT'));
    await tester.runAsync(() async {
      await Future.delayed(const Duration(seconds: 1));
    });
    await tester.pump();



    // Verify form fields are STILL intact (NOT erased on save)
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
  });
}
