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
    expect(find.text('WEBS'), findsOneWidget);
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

    // Results are hidden initially until user taps GET MY ESTIMATE
    expect(find.text('YOUR SOLAR ESTIMATE'), findsNothing);

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
    expect(find.text('Email ID (Optional)'), findsOneWidget);
    expect(find.text('SAVE RESULT'), findsOneWidget);

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

    // Results are hidden initially until user taps GET MY ESTIMATE
    expect(find.text('YOUR SOLAR ESTIMATE'), findsNothing);

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
    expect(find.text('Email ID (Optional)'), findsOneWidget);

    expect(find.text('READY TO EXPLORE\nYOUR SOLAR FUTURE?'), findsOneWidget);
    expect(find.text('Scan the QR code to connect with Websol'), findsOneWidget);
  });
}
