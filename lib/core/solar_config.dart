class SolarConfig {
  static const double tariffPerUnit = 7.2;
  static const double derate = 0.75;
  static const double costPerWatt = 23.0;
  static const double coalKgPerKwh = 0.55;
  static const double co2KgPerKwh = 0.675;
  static const double co2PerTreeKg = 22.0;
  static const int daysPerMonth = 30;
  static const bool subsidyRooftopOnly = false;

  // Appliance connected load in Watts
  static const Map<String, int> applianceWatts = {
    'fan': 75,
    'light': 30,
    'tv': 75,
    'ac': 1200,
    'washing': 400,
    'fridge': 200,
    'kettle': 1500,
    'induction': 1600,
    'pump': 750,
    'geyser': 2000,
  };

  /// Module footprint (m2 per module)
  static double footprint(int watt, bool rooftop) {
    if (watt == 550) return rooftop ? 3.22 : 4.85;
    if (watt == 500) return rooftop ? 3.00 : 4.45;
    throw ArgumentError('Unsupported module power: $watt');
  }

  /// PM Surya Ghar Subsidy slab applied to systemKw
  static double subsidyFor(double kw) {
    if (kw <= 2.0) return kw * 30000.0;
    if (kw <= 3.0) return (kw - 2.0) * 18000.0 + 60000.0;
    return 78000.0;
  }
}
