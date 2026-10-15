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

    // 3. Section 2: Tell Us About Your Home Form
    expect(find.text('TELL US ABOUT YOUR HOME'), findsOneWidget);
    expect(find.text('State'), findsOneWidget);
    expect(find.text('Monthly Electricity Bill (₹)'), findsOneWidget);
    expect(find.text('Property Type'), findsOneWidget);
    expect(find.text('Residential'), findsOneWidget);
    expect(find.text('Commercial'), findsOneWidget);
    expect(find.text('Installation Type'), findsOneWidget);
    expect(find.text('Household Appliances'), findsOneWidget);
    expect(find.text('Fans'), findsOneWidget);
    expect(find.text('Lights'), findsOneWidget);
    expect(find.text('ACs'), findsOneWidget);
    expect(find.text('Refrigerator'), findsOneWidget);
    expect(find.text('TV'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);
    expect(find.text('GET MY ESTIMATE'), findsOneWidget);

    // 4. Section 3: Solar Estimate Metrics
    expect(find.text('YOUR SOLAR ESTIMATE'), findsOneWidget);
    expect(find.text('₹ 3,905'), findsOneWidget);
    expect(find.text('₹ 1,094'), findsOneWidget);
    expect(find.text('₹ 1,13,850'), findsOneWidget);
    expect(find.text('₹ 78,000'), findsOneWidget);

    // 5. Section 4: Environmental Impact
    expect(find.text('YOUR IMPACT GOES BEYOND SAVINGS'), findsOneWidget);
    expect(find.text('3.63'), findsOneWidget);
    expect(find.text('4.45'), findsOneWidget);
    expect(find.text('202'), findsOneWidget);

    // 6. Section 5: Footer & Brand
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
    expect(find.text('YOUR SOLAR ESTIMATE'), findsOneWidget);
    expect(find.text('YOUR IMPACT GOES BEYOND SAVINGS'), findsOneWidget);
  });
}
