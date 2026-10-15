import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/customer_info.dart';
import '../models/solar_data.dart';

class CalculatorFormView extends StatefulWidget {
  final CustomerInfo customer;
  final Function(SolarData)? onEstimateGenerated;

  const CalculatorFormView({
    super.key,
    required this.customer,
    this.onEstimateGenerated,
  });

  @override
  State<CalculatorFormView> createState() => _CalculatorFormViewState();
}

class _CalculatorFormViewState extends State<CalculatorFormView> {
  final _formKey = GlobalKey<FormState>();
  final _billController = TextEditingController();

  String? _selectedState;
  String _propertyType = 'Residential'; // 'Residential' or 'Commercial'
  String _installationType = 'Rooftop';

  // Household Appliances Counts
  int _fansCount = 0;
  int _lightsCount = 0;
  int _acsCount = 0;
  int _fridgeCount = 0;
  int _tvCount = 0;
  int _otherCount = 0;

  static const List<String> _indianStates = [
    'West Bengal',
    'Maharashtra',
    'Delhi',
    'Gujarat',
    'Karnataka',
    'Tamil Nadu',
    'Uttar Pradesh',
    'Rajasthan',
    'Telangana',
    'Andhra Pradesh',
    'Kerala',
    'Punjab',
    'Haryana',
    'Madhya Pradesh',
    'Bihar',
    'Odisha',
    'Assam',
    'Jharkhand',
    'Chhattisgarh',
    'Uttarakhand',
    'Himachal Pradesh',
    'Goa',
    'Other States/UT',
  ];

  static const List<String> _installationOptions = [
    'Rooftop',
    'Ground Mounted',
    'Tin Shed / Metal Roof',
    'Carport / Canopy',
  ];

  @override
  void dispose() {
    _billController.dispose();
    super.dispose();
  }

  void _calculateEstimate() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedState == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select your state to continue.'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
        return;
      }

      final billAmount = double.tryParse(_billController.text.trim()) ?? 0.0;
      if (billAmount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid monthly electricity bill amount.'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
        return;
      }

      final solarData = SolarData(
        customer: widget.customer,
        state: _selectedState!,
        monthlyElectricityBill: billAmount,
        propertyType: _propertyType,
        installationType: _installationType,
        fans: _fansCount,
        lights: _lightsCount,
        acs: _acsCount,
        refrigerators: _fridgeCount,
        tvs: _tvCount,
        others: _otherCount,
      );

      if (widget.onEstimateGenerated != null) {
        widget.onEstimateGenerated!(solarData);
      } else {
        _showEstimateResultDialog(solarData);
      }
    }
  }

  void _showEstimateResultDialog(SolarData data) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF36A21).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.solar_power_rounded,
                  color: Color(0xFFF36A21),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estimated Solar Potential',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0E3B6C),
                      ),
                    ),
                    Text(
                      'Prepared for ${data.customer.fullName}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildResultMetric(
                        label: 'Recommended System',
                        value: '${data.recommendedKw} kW',
                        color: const Color(0xFF0F5B9E),
                      ),
                      Container(width: 1, height: 40, color: const Color(0xFFCBD5E1)),
                      _buildResultMetric(
                        label: 'Monthly Savings',
                        value: '₹${data.estimatedMonthlySavings.toStringAsFixed(0)}',
                        color: const Color(0xFF10B981),
                      ),
                      Container(width: 1, height: 40, color: const Color(0xFFCBD5E1)),
                      _buildResultMetric(
                        label: 'Annual Savings',
                        value: '₹${data.estimatedAnnualSavings.toStringAsFixed(0)}',
                        color: const Color(0xFFF36A21),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.save_alt_rounded, size: 16, color: Color(0xFFB45309)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Record is ready to be stored locally in CSV format.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Edit Details'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Estimate for ${data.customer.fullName} successfully recorded!',
                    ),
                    backgroundColor: const Color(0xFF10B981),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF36A21),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Save & Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResultMetric({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isLandscape = size.width >= 750 && size.width > size.height;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isLandscape ? 36.0 : 20.0,
        vertical: 24.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Client Proposal Strip
              _buildCustomerBanner(),

              const SizedBox(height: 20),

              // Main Form Card (Matching the Reference UI)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isLandscape ? 40 : 24,
                  vertical: 32,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Icon + TELL US ABOUT YOUR HOME
                      _buildHeader(),

                      const SizedBox(height: 32),

                      // Layout: 2-Column Split in Landscape, Stacked in Portrait
                      if (isLandscape)
                        _buildLandscapeFormColumns()
                      else
                        _buildPortraitFormSections(),

                      const SizedBox(height: 36),

                      // Bottom CTA: GET MY ESTIMATE ->
                      Center(
                        child: SizedBox(
                          width: isLandscape ? 380 : double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _calculateEstimate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF36A21),
                              foregroundColor: Colors.white,
                              elevation: 5,
                              shadowColor: const Color(0xFFF36A21)
                                  .withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'GET MY ESTIMATE',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Icon(Icons.arrow_forward_rounded, size: 22),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Top Customer Banner showing forwarded user information
  Widget _buildCustomerBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF36A21).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 18,
              color: Color(0xFFF36A21),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Wrap(
              spacing: 16,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  widget.customer.fullName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  '📞 ${widget.customer.phoneNumber}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
                Text(
                  '✉️ ${widget.customer.emailAddress}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: const Text(
              'Step 2 of 2',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F5B9E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Header with orange home circle
  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: Color(0xFFF36A21),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.home_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'TELL US ABOUT YOUR HOME',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0E3B6C),
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "A few simple details and we'll show you your potential savings.",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Landscape 2-Column Split View
  Widget _buildLandscapeFormColumns() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column
        Expanded(
          flex: 48,
          child: _buildLeftColumnFields(),
        ),

        // Vertical Divider
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 28),
          width: 1,
          height: 390,
          color: const Color(0xFFE2E8F0),
        ),

        // Right Column
        Expanded(
          flex: 52,
          child: _buildRightColumnFields(),
        ),
      ],
    );
  }

  /// Portrait Stacked Sections
  Widget _buildPortraitFormSections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLeftColumnFields(),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
        ),
        _buildRightColumnFields(),
      ],
    );
  }

  /// Left Column: State, Monthly Electricity Bill, Property Type
  Widget _buildLeftColumnFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. State
        _buildFieldTitle(
          icon: Icons.location_on_outlined,
          title: 'State',
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedState,
          hint: const Text(
            'Select State',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF64748B)),
          decoration: _buildInputBoxDecoration(),
          items: _indianStates.map((state) {
            return DropdownMenuItem<String>(
              value: state,
              child: Text(
                state,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _selectedState = val;
            });
          },
          validator: (val) => val == null ? 'Please select state' : null,
        ),

        const SizedBox(height: 24),

        // 2. Monthly Electricity Bill (₹)
        _buildFieldTitle(
          icon: Icons.receipt_long_outlined,
          title: 'Monthly Electricity Bill (₹)',
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _billController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          decoration: _buildInputBoxDecoration(
            hintText: 'Enter amount',
            prefixText: '₹ ',
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Please enter monthly electricity bill';
            }
            return null;
          },
        ),

        const SizedBox(height: 24),

        // 3. Property Type (Residential / Commercial Toggle)
        _buildFieldTitle(
          icon: Icons.apartment_rounded,
          title: 'Property Type',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPropertyTypePill(
                label: 'Residential',
                isSelected: _propertyType == 'Residential',
                onTap: () {
                  setState(() {
                    _propertyType = 'Residential';
                  });
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildPropertyTypePill(
                label: 'Commercial',
                isSelected: _propertyType == 'Commercial',
                onTap: () {
                  setState(() {
                    _propertyType = 'Commercial';
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Right Column: Installation Type, Household Appliances Grid
  Widget _buildRightColumnFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Installation Type
        _buildFieldTitle(
          icon: Icons.solar_power_outlined,
          title: 'Installation Type',
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _installationType,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF64748B)),
          decoration: _buildInputBoxDecoration(),
          items: _installationOptions.map((type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(
                type,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _installationType = val;
              });
            }
          },
        ),

        const SizedBox(height: 24),

        // 2. Household Appliances
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            _buildFieldTitle(
              icon: Icons.kitchen_outlined,
              title: 'Household Appliances',
            ),
            const Text(
              '(Optional – for better accuracy)',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // 2-Column Grid of Appliances
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildApplianceCard(
                    icon: Icons.toys_outlined,
                    name: 'Fans',
                    count: _fansCount,
                    onChanged: (val) => setState(() => _fansCount = val),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildApplianceCard(
                    icon: Icons.lightbulb_outlined,
                    name: 'Lights',
                    count: _lightsCount,
                    onChanged: (val) => setState(() => _lightsCount = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildApplianceCard(
                    icon: Icons.ac_unit_outlined,
                    name: 'ACs',
                    count: _acsCount,
                    onChanged: (val) => setState(() => _acsCount = val),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildApplianceCard(
                    icon: Icons.kitchen_outlined,
                    name: 'Refrigerator',
                    count: _fridgeCount,
                    onChanged: (val) => setState(() => _fridgeCount = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildApplianceCard(
                    icon: Icons.tv_outlined,
                    name: 'TV',
                    count: _tvCount,
                    onChanged: (val) => setState(() => _tvCount = val),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildApplianceCard(
                    icon: Icons.power_outlined,
                    name: 'Other',
                    count: _otherCount,
                    onChanged: (val) => setState(() => _otherCount = val),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// Field Title with Leading Icon
  Widget _buildFieldTitle({
    required IconData icon,
    required String title,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0E3B6C)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0E3B6C),
            ),
          ),
        ),
      ],
    );
  }

  /// Property Type Selectable Pill
  Widget _buildPropertyTypePill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF36A21) : Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isSelected ? const Color(0xFFF36A21) : const Color(0xFFCBD5E1),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFF36A21).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  /// Appliance Counter Card matching the reference
  Widget _buildApplianceCard({
    required IconData icon,
    required String name,
    required int count,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF0E3B6C)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Dropdown Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: count,
                isDense: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: Color(0xFF64748B),
                ),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
                items: List.generate(11, (index) {
                  return DropdownMenuItem<int>(
                    value: index,
                    child: Text('$index'),
                  );
                }),
                onChanged: (val) {
                  if (val != null) {
                    onChanged(val);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shared Input Box Decoration
  InputDecoration _buildInputBoxDecoration({
    String? hintText,
    String? prefixText,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      prefixText: prefixText,
      prefixStyle: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 15,
        fontWeight: FontWeight.w800,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF36A21), width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.8),
      ),
    );
  }
}
