import 'customer_info.dart';

class SolarData {
  final CustomerInfo customer;
  final String state;
  final double monthlyElectricityBill;
  final String propertyType; // Residential or Commercial
  final String installationType; // Rooftop, Ground Mounted, etc.

  // Household Appliances
  final int fans;
  final int lights;
  final int acs;
  final int refrigerators;
  final int tvs;
  final int others;

  final DateTime createdAt;

  SolarData({
    required this.customer,
    required this.state,
    required this.monthlyElectricityBill,
    this.propertyType = 'Residential',
    this.installationType = 'Rooftop',
    this.fans = 0,
    this.lights = 0,
    this.acs = 0,
    this.refrigerators = 0,
    this.tvs = 0,
    this.others = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Solar estimation calculations
  /// Recommended system size in kW based on bill
  double get recommendedKw {
    // Average tariff in India approx Rs 7.5/unit; 1 kW produces approx 120 units/month
    final estimatedUnitsPerMonth = monthlyElectricityBill / 7.5;
    final kw = estimatedUnitsPerMonth / 120.0;
    return (kw * 10).round() / 10; // rounded to 1 decimal
  }

  /// Estimated monthly savings in INR
  double get estimatedMonthlySavings {
    return (monthlyElectricityBill * 0.88).roundToDouble();
  }

  /// Estimated annual savings in INR
  double get estimatedAnnualSavings {
    return estimatedMonthlySavings * 12;
  }

  /// Export as CSV row
  List<String> toCsvRow() {
    return [
      customer.fullName,
      customer.phoneNumber,
      customer.emailAddress,
      state,
      monthlyElectricityBill.toStringAsFixed(2),
      propertyType,
      installationType,
      fans.toString(),
      lights.toString(),
      acs.toString(),
      refrigerators.toString(),
      tvs.toString(),
      others.toString(),
      recommendedKw.toStringAsFixed(1),
      estimatedMonthlySavings.toStringAsFixed(0),
      estimatedAnnualSavings.toStringAsFixed(0),
      createdAt.toIso8601String(),
    ];
  }

  static List<String> get csvHeaders => [
        'Full Name',
        'Phone Number',
        'Email Address',
        'State',
        'Monthly Bill (INR)',
        'Property Type',
        'Installation Type',
        'Fans',
        'Lights',
        'ACs',
        'Refrigerators',
        'TVs',
        'Other Appliances',
        'Recommended kW',
        'Est Monthly Savings',
        'Est Annual Savings',
        'Created At',
      ];
}
