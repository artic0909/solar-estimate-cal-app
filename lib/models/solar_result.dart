class SolarResult {
  final double loadKw;
  final double systemKw;
  final double spaceM2;
  final double cost;
  final double subsidy;
  final double effectiveCost;
  final double dailyUnits;
  final double monthlySaving;
  final double coalMT;
  final double co2MT;
  final double trees;
  final int modules;
  final double? revisedBill; // null means surplus
  final double? billReduction; // null means surplus

  const SolarResult({
    required this.loadKw,
    required this.systemKw,
    required this.spaceM2,
    required this.cost,
    required this.subsidy,
    required this.effectiveCost,
    required this.dailyUnits,
    required this.monthlySaving,
    required this.coalMT,
    required this.co2MT,
    required this.trees,
    required this.modules,
    this.revisedBill,
    this.billReduction,
  });

  bool get isSurplus => revisedBill == null;

  static const String surplusRevisedBillMessage =
      'You will get benefit of Surplus Amount in Next Month Bill';
  static const String surplusBillReductionMessage =
      'You are now generating Surplus Energy';
}
