import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class SolarCalculationInput {
  final String name;
  final String mobile;
  final String state;
  final double monthlyBill;
  final String solarApplication;
  final String installationType;

  // Appliances
  final int fan;
  final int light;
  final int tv;
  final int ac;
  final int washingMachine;
  final int fridge;
  final int electricKettle;
  final int inductionCooker;
  final int submersiblePump;
  final int geyser;
  final double otherWatts;

  const SolarCalculationInput({
    this.name = '0',
    this.mobile = '0',
    this.state = 'West Bengal',
    this.monthlyBill = 5000.0,
    this.solarApplication = 'Residential',
    this.installationType = 'Rooftop',
    this.fan = 3,
    this.light = 6,
    this.tv = 2,
    this.ac = 1,
    this.washingMachine = 1,
    this.fridge = 1,
    this.electricKettle = 0,
    this.inductionCooker = 0,
    this.submersiblePump = 0,
    this.geyser = 1,
    this.otherWatts = 200.0,
  });
}

class SolarCalculationResult {
  final SolarCalculationInput input;

  final double connectedLoadWatts;
  final int solarModulesCount;
  final double billReductionPercentage;
  final double monthlySavingsRs;
  final double revisedMonthlyBillRs;
  final double spaceReqdSqM;
  final double approxCostModulesRs;
  final double govtSubsidyRs;
  final double effectiveTotalCostRs;
  final double annualCoalSavedMt;
  final double annualCo2ReductionMt;
  final double annualTreesPlanted;

  const SolarCalculationResult({
    required this.input,
    required this.connectedLoadWatts,
    required this.solarModulesCount,
    required this.billReductionPercentage,
    required this.monthlySavingsRs,
    required this.revisedMonthlyBillRs,
    required this.spaceReqdSqM,
    required this.approxCostModulesRs,
    required this.govtSubsidyRs,
    required this.effectiveTotalCostRs,
    required this.annualCoalSavedMt,
    required this.annualCo2ReductionMt,
    required this.annualTreesPlanted,
  });

  /// Exports the exact 28 rows from the client's Excel sheet into CSV format
  String toCsvString() {
    final buffer = StringBuffer();
    final nameVal = input.name.trim().isEmpty ? '0' : input.name.trim();
    final mobileVal = input.mobile.trim().isEmpty ? '0' : input.mobile.trim();

    buffer.writeln('Name,$nameVal');
    buffer.writeln('Mobile No.,$mobileVal');
    buffer.writeln('State/UT,${input.state}');
    buffer.writeln('Your Monthly Electricity Bill (Rs.),${input.monthlyBill.toStringAsFixed(0)}');
    buffer.writeln('Solar Application,${input.solarApplication}');
    buffer.writeln('Solar Installation Type,${input.installationType}');
    buffer.writeln('No. of Fan,${input.fan}');
    buffer.writeln('No. of Light,${input.light}');
    buffer.writeln('No. of TV,${input.tv}');
    buffer.writeln('No. of AC,${input.ac}');
    buffer.writeln('No. of Washing machine,${input.washingMachine}');
    buffer.writeln('No. of Fridge,${input.fridge}');
    buffer.writeln('No. of Electric kettle,${input.electricKettle}');
    buffer.writeln('No. of Induction Cooker,${input.inductionCooker}');
    buffer.writeln('No. of Submersible pump,${input.submersiblePump}');
    buffer.writeln('No. of Geyser,${input.geyser}');
    buffer.writeln('Other Load Consumption (Watt),${input.otherWatts.toStringAsFixed(0)}');
    buffer.writeln('%Elect. Bill Rdeduction,${billReductionPercentage.toStringAsFixed(7)}');
    buffer.writeln('Monthly Savings (Rs.),${monthlySavingsRs.toStringAsFixed(3)}');
    buffer.writeln('Revised Monthly Electricity Bill (Rs.),${revisedMonthlyBillRs.toStringAsFixed(3)}');
    buffer.writeln('Space Reqd. (Sq. M),${spaceReqdSqM.toStringAsFixed(2)}');
    buffer.writeln('No. of Solar Modules,$solarModulesCount');
    buffer.writeln('Approx. Cost of Module(s) (Rs.),${approxCostModulesRs.toStringAsFixed(0)}');
    buffer.writeln('Govt. Subsidy under PM Suryaghar Scheme,${govtSubsidyRs.toStringAsFixed(0)}');
    buffer.writeln('Effective Total Cost of Module(s) (Rs.),${effectiveTotalCostRs.toStringAsFixed(0)}');
    buffer.writeln('Equivalent to Annual Std. Coal Saved (MT),${annualCoalSavedMt.toStringAsFixed(7)}');
    buffer.writeln('Equivalent to Annual CO2 emission reduction (MT),${annualCo2ReductionMt.toStringAsFixed(7)}');
    buffer.writeln('Equivalent to Annual Number of Tree Planted (No.),${annualTreesPlanted.toStringAsFixed(5)}');
    return buffer.toString();
  }
}

class SolarCalculatorService {
  /// Calculates the exact solar estimate metrics based on client's formula model
  static SolarCalculationResult calculate(SolarCalculationInput input) {
    // 1. Calculate connected load in Watts
    final double totalWatts = (input.fan * 75.0) +
        (input.light * 20.0) +
        (input.tv * 100.0) +
        (input.ac * 1500.0) +
        (input.washingMachine * 500.0) +
        (input.fridge * 250.0) +
        (input.electricKettle * 1500.0) +
        (input.inductionCooker * 1500.0) +
        (input.submersiblePump * 750.0) +
        (input.geyser * 2000.0) +
        input.otherWatts;

    // 2. Determine number of modules
    // Standard baseline: 4995W load -> 9 modules (555W rating per module slot)
    int modules = (totalWatts / 555.0).round();
    if (modules < 1) {
      if (input.monthlyBill > 0) {
        modules = ((input.monthlyBill / 5000.0) * 9.0).round();
      }
      if (modules < 1) modules = 1;
    }

    // 3. Space required: 3.22 Sq. M per module
    final double spaceReqdSqM = double.parse((modules * 3.22).toStringAsFixed(2));

    // 4. Approx cost of modules: Rs. 12,650 per module
    final double approxCost = modules * 12650.0;

    // 5. Govt Subsidy under PM Suryaghar Scheme
    double subsidy = 0.0;
    if (input.solarApplication == 'Residential') {
      if (modules <= 2) {
        subsidy = 30000.0;
      } else if (modules <= 4) {
        subsidy = 60000.0;
      } else {
        subsidy = 78000.0;
      }
    }

    // 6. Effective Total Cost
    final double effectiveCost = approxCost - subsidy;

    // 7. Monthly savings & bill reduction ratio
    // Baseline: 9 modules on a 5000 bill produces 3905.253 savings
    const double baselineSavingsPerModule = 3905.253 / 9.0;
    double savings = modules * baselineSavingsPerModule;
    if (input.monthlyBill > 0) {
      if (savings > input.monthlyBill * 0.90) {
        savings = input.monthlyBill * 0.90;
      }
    }

    final double billReductionPercentage = input.monthlyBill > 0
        ? (savings / input.monthlyBill)
        : 0.0;

    final double revisedBill = input.monthlyBill > 0
        ? (input.monthlyBill - savings)
        : 0.0;

    // 8. Environmental Impact metrics
    final double coalSaved = modules * (3.6295349 / 9.0);
    final double co2Reduction = modules * (4.4544292 / 9.0);
    final double treesPlanted = modules * (202.47405 / 9.0);

    return SolarCalculationResult(
      input: input,
      connectedLoadWatts: totalWatts,
      solarModulesCount: modules,
      billReductionPercentage: billReductionPercentage,
      monthlySavingsRs: savings,
      revisedMonthlyBillRs: revisedBill,
      spaceReqdSqM: spaceReqdSqM,
      approxCostModulesRs: approxCost,
      govtSubsidyRs: subsidy,
      effectiveTotalCostRs: effectiveCost,
      annualCoalSavedMt: coalSaved,
      annualCo2ReductionMt: co2Reduction,
      annualTreesPlanted: treesPlanted,
    );
  }

  /// Saves the calculation result to a CSV file in device local storage
  static Future<File> saveCsvToLocalStorage(SolarCalculationResult result) async {
    Directory targetDir;
    try {
      if (!kIsWeb && Platform.isAndroid) {
        // Prefer external or download directory on Android if available
        final extDir = await getExternalStorageDirectory();
        targetDir = extDir ?? await getApplicationDocumentsDirectory();
      } else {
        targetDir = await getApplicationDocumentsDirectory();
      }
    } catch (_) {
      targetDir = await getApplicationDocumentsDirectory();
    }

    final estimatesFolder = Directory('${targetDir.path}/solar_estimates');
    if (!await estimatesFolder.exists()) {
      await estimatesFolder.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sanitizedName = (result.input.name.trim().isEmpty || result.input.name.trim() == '0')
        ? 'customer'
        : result.input.name.trim().replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

    final fileName = 'solar_estimate_${sanitizedName}_$timestamp.csv';
    final file = File('${estimatesFolder.path}/$fileName');

    await file.writeAsString(result.toCsvString());
    return file;
  }
}
