import 'solar_config.dart';
import 'sunhour_table.dart';
import '../models/solar_input.dart';
import '../models/solar_result.dart';

class SolarCalculator {
  /// Calculate SolarResult using the exact formulas from Solar_Calculator.xlsx
  static SolarResult calculate({
    required Map<String, int> counts,
    required int otherWatts,
    required int moduleWatt,
    required bool rooftop,
    required bool residential,
    required double bill,
    required double sunhour,
  }) {
    var totalWatts = otherWatts;
    SolarConfig.applianceWatts.forEach((k, w) {
      totalWatts += (counts[k] ?? 0) * w;
    });

    final int modules = (totalWatts / moduleWatt).ceil();
    final double systemKw = modules * moduleWatt / 1000.0;
    final double cost = SolarConfig.costPerWatt * moduleWatt * modules;
    final double subsidy = (residential && (!SolarConfig.subsidyRooftopOnly || rooftop))
        ? SolarConfig.subsidyFor(systemKw)
        : 0.0;
    final double daily = modules * moduleWatt * sunhour / 1000.0 * SolarConfig.derate;
    final double saving = daily * SolarConfig.tariffPerUnit * SolarConfig.daysPerMonth;
    final double co2 = daily * 365.0 * SolarConfig.co2KgPerKwh / 1000.0;
    final bool surplus = bill <= saving;

    return SolarResult(
      loadKw: totalWatts / 1000.0,
      systemKw: systemKw,
      spaceM2: modules * SolarConfig.footprint(moduleWatt, rooftop),
      cost: cost,
      subsidy: subsidy,
      effectiveCost: cost - subsidy,
      dailyUnits: daily,
      monthlySaving: saving,
      coalMT: daily * 365.0 * SolarConfig.coalKgPerKwh / 1000.0,
      co2MT: co2,
      trees: co2 / SolarConfig.co2PerTreeKg * 1000.0,
      modules: modules,
      revisedBill: surplus ? null : bill - saving,
      billReduction: surplus ? null : saving / bill,
    );
  }

  /// Convenience calculation helper directly taking a [SolarInput]
  static SolarResult calculateFromInput(SolarInput input) {
    final double sunhour = sunhourTable[input.state] ??
        (throw ArgumentError('Unknown state or UT name: "${input.state}"'));

    return calculate(
      counts: input.counts,
      otherWatts: input.otherWatts,
      moduleWatt: input.moduleWatt,
      rooftop: input.isRooftop,
      residential: input.isResidential,
      bill: input.monthlyBill,
      sunhour: sunhour,
    );
  }
}
