class SolarInput {
  final String name;
  final String mobile;
  final String email;
  final String state;
  final double monthlyBill;
  final String solarApplication; // 'Residential' or 'Commercial'
  final String installationType; // 'Rooftop' or 'Ground Mounted'
  final Map<String, int> counts; // fan, light, tv, ac, washing, fridge, kettle, induction, pump, geyser
  final int otherWatts;
  final int moduleWatt; // 550 default, or 500

  const SolarInput({
    this.name = '',
    this.mobile = '',
    this.email = '',
    this.state = 'West Bengal',
    this.monthlyBill = 0.0,
    this.solarApplication = 'Residential',
    this.installationType = 'Rooftop',
    this.counts = const {},
    this.otherWatts = 0,
    this.moduleWatt = 550,
  });

  bool get isRooftop => installationType.toLowerCase().contains('rooftop');
  bool get isResidential => solarApplication.toLowerCase().contains('residential');

  int get totalLoadWatts {
    var total = otherWatts;
    counts.forEach((key, count) {
      final w = _applianceWatt(key);
      total += count * w;
    });
    return total;
  }

  static int _applianceWatt(String key) {
    switch (key.toLowerCase()) {
      case 'fan':
        return 75;
      case 'light':
        return 30;
      case 'tv':
        return 75;
      case 'ac':
        return 1200;
      case 'washing':
        return 400;
      case 'fridge':
        return 200;
      case 'kettle':
        return 1500;
      case 'induction':
        return 1600;
      case 'pump':
        return 750;
      case 'geyser':
        return 2000;
      default:
        return 0;
    }
  }

  SolarInput copyWith({
    String? name,
    String? mobile,
    String? email,
    String? state,
    double? monthlyBill,
    String? solarApplication,
    String? installationType,
    Map<String, int>? counts,
    int? otherWatts,
    int? moduleWatt,
  }) {
    return SolarInput(
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      state: state ?? this.state,
      monthlyBill: monthlyBill ?? this.monthlyBill,
      solarApplication: solarApplication ?? this.solarApplication,
      installationType: installationType ?? this.installationType,
      counts: counts ?? this.counts,
      otherWatts: otherWatts ?? this.otherWatts,
      moduleWatt: moduleWatt ?? this.moduleWatt,
    );
  }
}
