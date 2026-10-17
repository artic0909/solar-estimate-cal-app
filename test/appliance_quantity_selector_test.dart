import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_estimate_calculator/widgets/appliance_quantity_selector.dart';

void main() {
  testWidgets('ApplianceQuantitySelector initial value and increment/decrement', (WidgetTester tester) async {
    int currentVal = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return ApplianceQuantitySelector(
                count: currentVal,
                onChanged: (newVal) {
                  setState(() => currentVal = newVal);
                },
              );
            },
          ),
        ),
      ),
    );

    // Initial state: 0
    expect(find.text('0'), findsOneWidget);

    // Decrement button when count is 0 must NOT go to -1
    final minusBtn = find.byIcon(Icons.remove_rounded);
    await tester.tap(minusBtn);
    await tester.pump();
    expect(currentVal, 0);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('-1'), findsNothing);

    // Increment button should increase count to 1
    final plusBtn = find.byIcon(Icons.add_rounded);
    await tester.tap(plusBtn);
    await tester.pump();
    expect(currentVal, 1);
    expect(find.text('1'), findsOneWidget);

    // Increment again to 2
    await tester.tap(plusBtn);
    await tester.pump();
    expect(currentVal, 2);
    expect(find.text('2'), findsOneWidget);

    // Decrement should decrease count to 1
    await tester.tap(minusBtn);
    await tester.pump();
    expect(currentVal, 1);
    expect(find.text('1'), findsOneWidget);

    // Decrement to 0
    await tester.tap(minusBtn);
    await tester.pump();
    expect(currentVal, 0);
    expect(find.text('0'), findsOneWidget);

    // Decrement again must NOT decrease below 0
    await tester.tap(minusBtn);
    await tester.pump();
    expect(currentVal, 0);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('-1'), findsNothing);
  });

  testWidgets('ApplianceQuantitySelector typing in text field does not allow negative numbers', (WidgetTester tester) async {
    int currentVal = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return ApplianceQuantitySelector(
                count: currentVal,
                onChanged: (newVal) {
                  setState(() => currentVal = newVal);
                },
              );
            },
          ),
        ),
      ),
    );

    final textField = find.byType(TextField);

    // Attempting to enter negative number '-5'
    await tester.enterText(textField, '-5');
    await tester.pump();
    // digitsOnly formatter strips '-' leaving '5'
    expect(currentVal >= 0, isTrue);
    expect(find.text('-5'), findsNothing);

    // Entering a positive number '12'
    await tester.enterText(textField, '12');
    await tester.pump();
    expect(currentVal, 12);
    expect(find.text('12'), findsOneWidget);
  });
}
