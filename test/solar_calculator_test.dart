import 'package:flutter_test/flutter_test.dart';
import 'package:solar_estimate_calculator/core/solar_calculator.dart';
import 'package:solar_estimate_calculator/models/solar_input.dart';

void main() {
  group('Solar Calculator Acceptance Tests', () {
    test('Matches client spreadsheet baseline for West Bengal with 9 modules', () {
      const input = SolarInput(
        name: 'John Doe',
        mobile: '9876543210',
        email: 'john@example.com',
        state: 'West Bengal',
        monthlyBill: 5000.0,
        solarApplication: 'Residential',
        installationType: 'Rooftop',
        moduleWatt: 550,
        counts: {
          'fan': 3,
          'light': 6,
          'tv': 2,
          'ac': 1,
          'washing': 1,
          'fridge': 1,
          'kettle': 0,
          'induction': 0,
          'pump': 0,
          'geyser': 1,
        },
        otherWatts: 200,
      );

      final result = SolarCalculator.calculateFromInput(input);

      // 1. Connected load
      expect(result.loadKw, closeTo(4.555, 0.001));

      // 2. Modules
      expect(result.modules, equals(9));

      // 3. System size
      expect(result.systemKw, closeTo(4.95, 0.01));

      // 4. Space required (m2)
      expect(result.spaceM2, closeTo(28.98, 0.01));

      // 5. Approx. cost
      expect(result.cost, closeTo(113850.0, 0.1));

      // 6. Subsidy (PM Surya Ghar max 78,000 for > 3kW)
      expect(result.subsidy, closeTo(78000.0, 0.1));

      // 7. Effective cost
      expect(result.effectiveCost, closeTo(35850.0, 0.1));

      // 8. Daily units
      expect(result.dailyUnits, closeTo(18.08, 0.01));

      // 9. Monthly savings
      expect(result.monthlySaving.round(), equals(3905));

      // 10. Revised bill
      expect(result.isSurplus, isFalse);
      expect(result.revisedBill!.round(), equals(1095));

      // 11. Bill reduction (78.1%)
      expect(result.billReduction! * 100.0, closeTo(78.1, 0.1));

      // 12. Coal saved
      expect(result.coalMT, closeTo(3.63, 0.01));

      // 13. CO2 reduction
      expect(result.co2MT, closeTo(4.45, 0.01));

      // 14. Trees
      expect(result.trees.round(), equals(202));
    });

    test('Surplus branch when bill is lower than solar savings', () {
      const input = SolarInput(
        state: 'West Bengal',
        monthlyBill: 1000.0,
        solarApplication: 'Residential',
        installationType: 'Rooftop',
        moduleWatt: 550,
        counts: {
          'fan': 3,
          'light': 6,
          'tv': 2,
          'ac': 1,
          'washing': 1,
          'fridge': 1,
          'kettle': 0,
          'induction': 0,
          'pump': 0,
          'geyser': 1,
        },
        otherWatts: 200,
      );

      final result = SolarCalculator.calculateFromInput(input);

      expect(result.isSurplus, isTrue);
      expect(result.revisedBill, isNull);
      expect(result.billReduction, isNull);
      expect(result.monthlySaving > 1000.0, isTrue);
    });

    test('Subsidy slab when systemKw is 2kW or less', () {
      // 1kW load: 2 modules of 550W = 1.1 kW
      const input = SolarInput(
        state: 'West Bengal',
        monthlyBill: 3000.0,
        solarApplication: 'Residential',
        installationType: 'Rooftop',
        moduleWatt: 550,
        counts: {
          'fan': 2,
          'light': 4,
          'tv': 1,
          'ac': 0,
          'washing': 0,
          'fridge': 1,
          'kettle': 0,
          'induction': 0,
          'pump': 0,
          'geyser': 0,
        },
        otherWatts: 0,
      );

      final result = SolarCalculator.calculateFromInput(input);

      // SystemKw <= 2: subsidy = systemKw * 30000
      expect(result.systemKw <= 2.0, isTrue);
      expect(result.subsidy, closeTo(result.systemKw * 30000.0, 0.1));
    });
  });
}
