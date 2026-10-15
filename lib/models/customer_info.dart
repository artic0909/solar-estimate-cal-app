class CustomerInfo {
  final String fullName;
  final String phoneNumber;
  final String emailAddress;
  final DateTime createdAt;

  CustomerInfo({
    required this.fullName,
    required this.phoneNumber,
    required this.emailAddress,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'emailAddress': emailAddress,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  List<String> toCsvRow() {
    return [
      fullName,
      phoneNumber,
      emailAddress,
      createdAt.toIso8601String(),
    ];
  }

  static List<String> get csvHeaders => [
        'Full Name',
        'Phone Number',
        'Email Address',
        'Date & Time',
      ];
}
