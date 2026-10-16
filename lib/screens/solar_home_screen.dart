import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/websol_logo.dart';
import '../widgets/doodle_arrow.dart';
import '../widgets/qr_code_widget.dart';
import '../widgets/top_alert.dart';
import '../core/sunhour_table.dart';
import '../models/solar_input.dart';
import '../models/solar_result.dart';
import '../providers/solar_calculator_provider.dart';

class SolarHomeScreen extends StatefulWidget {
  const SolarHomeScreen({super.key});

  @override
  State<SolarHomeScreen> createState() => _SolarHomeScreenState();
}

class _SolarHomeScreenState extends State<SolarHomeScreen> {
  // Lead / Customer details form state
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Calculation inputs state
  String _selectedState = 'West Bengal';
  final TextEditingController _billController = TextEditingController(text: '5000');
  String _propertyType = 'Residential';
  String _installationType = 'Rooftop';
  int _moduleWatt = 550;

  // Appliance counts (matching client spreadsheet defaults)
  int _fansCount = 3;
  int _lightsCount = 6;
  int _tvCount = 2;
  int _acsCount = 1;
  int _washingCount = 1;
  int _fridgeCount = 1;
  int _kettleCount = 0;
  int _inductionCount = 0;
  int _pumpCount = 0;
  int _geyserCount = 1;
  final TextEditingController _otherWattsController = TextEditingController(text: '200');

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _calculatorKey = GlobalKey();
  final GlobalKey _customerKey = GlobalKey();
  final GlobalKey _resultsKey = GlobalKey();
  final GlobalKey _leadKey = GlobalKey();

  static final List<String> _indianStates = sunhourTable.keys.toList()..sort();
  bool _hasCalculated = false;

  @override
  void initState() {
    super.initState();
    _hasCalculated = false;
  }

  @override
  void dispose() {
    TopAlert.dismiss();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _billController.dispose();
    _otherWattsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  SolarInput _buildCurrentInput() {
    final bill = double.tryParse(_billController.text.trim()) ?? 0.0;
    final otherW = int.tryParse(_otherWattsController.text.trim()) ?? 0;

    return SolarInput(
      name: _nameController.text.trim(),
      mobile: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      state: _selectedState,
      monthlyBill: bill,
      solarApplication: _propertyType,
      installationType: _installationType,
      moduleWatt: _moduleWatt,
      counts: {
        'fan': _fansCount,
        'light': _lightsCount,
        'tv': _tvCount,
        'ac': _acsCount,
        'washing': _washingCount,
        'fridge': _fridgeCount,
        'kettle': _kettleCount,
        'induction': _inductionCount,
        'pump': _pumpCount,
        'geyser': _geyserCount,
      },
      otherWatts: otherW,
    );
  }

  void _syncAndCalculate({bool notifyUI = true}) {
    final provider = context.read<SolarCalculatorProvider>();
    provider.setInput(_buildCurrentInput(), recalculate: true);
  }

  void _scrollToCustomerDetails() {
    final ctx = _customerKey.currentContext ?? _calculatorKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _handleSaveLead() async {
    final rawName = _nameController.text.trim();
    final rawMobile = _phoneController.text.trim();
    final rawEmail = _emailController.text.trim();

    // 1. Check if user calculated estimate first
    final provider = context.read<SolarCalculatorProvider>();
    if (!_hasCalculated || provider.result == null) {
      TopAlert.show(
        context,
        title: 'Estimate Not Calculated',
        message: 'Please click "GET MY ESTIMATE" first before saving.',
        type: TopAlertType.warning,
      );
      _scrollToCalculator();
      return;
    }

    // 2. Validate Customer Name
    if (rawName.isEmpty) {
      TopAlert.show(
        context,
        title: 'Customer Name Required',
        message: 'Please enter the customer\'s full name.',
        type: TopAlertType.error,
      );
      _scrollToCustomerDetails();
      return;
    }

    // 3. Validate Phone Number (10 digits)
    if (rawMobile.isEmpty) {
      TopAlert.show(
        context,
        title: 'Phone Number Required',
        message: 'Please enter customer 10-digit mobile number.',
        type: TopAlertType.error,
      );
      _scrollToCustomerDetails();
      return;
    }
    if (rawMobile.length != 10) {
      TopAlert.show(
        context,
        title: 'Invalid Mobile Number',
        message: 'Mobile number must be exactly 10 digits.',
        type: TopAlertType.error,
      );
      _scrollToCustomerDetails();
      return;
    }

    // 4. Validate Email Address
    if (rawEmail.isEmpty) {
      TopAlert.show(
        context,
        title: 'Email Address Required',
        message: 'Please enter customer email address.',
        type: TopAlertType.error,
      );
      _scrollToCustomerDetails();
      return;
    }
    final emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailPattern.hasMatch(rawEmail)) {
      TopAlert.show(
        context,
        title: 'Invalid Email Address',
        message: 'Please enter a valid email address (e.g. name@domain.com).',
        type: TopAlertType.error,
      );
      _scrollToCustomerDetails();
      return;
    }

    // Set input with strictly validated customer details
    final currentInput = _buildCurrentInput().copyWith(
      name: rawName,
      mobile: rawMobile,
      email: rawEmail,
    );
    provider.setInput(currentInput, recalculate: true);

    final success = await provider.saveCurrentLead();

    if (mounted) {
      if (success) {
        // Reset lead form fields as requested
        setState(() {
          _nameController.clear();
          _phoneController.clear();
          _emailController.clear();
        });

        TopAlert.show(
          context,
          title: 'Saved Successfully',
          message: 'Estimate saved directly to Downloads/Websol_Leads.xlsx',
          type: TopAlertType.success,
        );
      } else {
        TopAlert.show(
          context,
          title: 'Save Failed',
          message: provider.errorMessage ?? 'Failed to save result to Excel file.',
          type: TopAlertType.error,
        );
      }
    }
  }

  void _handleClearForm() {
    setState(() {
      _hasCalculated = false;
      _nameController.clear();
      _phoneController.clear();
      _emailController.clear();
      _billController.clear();
      _otherWattsController.clear();
      _selectedState = 'West Bengal';
      _propertyType = 'Residential';
      _installationType = 'Rooftop';
      _moduleWatt = 550;
      _fansCount = 0;
      _lightsCount = 0;
      _tvCount = 0;
      _acsCount = 0;
      _washingCount = 0;
      _fridgeCount = 0;
      _kettleCount = 0;
      _inductionCount = 0;
      _pumpCount = 0;
      _geyserCount = 0;
    });

    context.read<SolarCalculatorProvider>().clearAll();

    TopAlert.show(
      context,
      title: 'Form Reset',
      message: 'All calculator and customer details have been reset.',
      type: TopAlertType.info,
    );

    _scrollToCustomerDetails();
  }

  void _scrollToCalculator() {
    final context = _calculatorKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _scrollToResults() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _resultsKey.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  String _formatIndianCurrency(num value) {
    final s = value.round().toString();
    if (s.length <= 3) return s;
    final last3 = s.substring(s.length - 3);
    String rest = s.substring(0, s.length - 3);
    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    return '${parts.join(',')},$last3';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SolarCalculatorProvider>();
    final result = provider.result;
    final size = MediaQuery.sizeOf(context);
    final isPortrait = size.height > size.width || size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Top Hero Section
            _buildHeroSection(context, isPortrait: isPortrait),

            // Main Content Area with max constraint for clean tablet layout
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1160),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      SizedBox(height: isPortrait ? 16 : 24),

                      // 2. TELL US ABOUT YOUR HOME Section
                      Container(
                        key: _calculatorKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHomeSectionHeader(),
                            const SizedBox(height: 16),
                            Container(
                              key: _customerKey,
                              child: _buildCustomerDetailsCard(context),
                            ),
                            const SizedBox(height: 20),
                            _buildCalculationCard(context),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // 3. Results Card ("YOUR SOLAR ESTIMATE")
                      if (_hasCalculated && result != null) ...[
                        _buildSolarEstimateCard(context, result),
                        const SizedBox(height: 24),

                        // 4. Environmental Impact Card
                        _buildImpactCard(context, result),
                        const SizedBox(height: 28),

                        // 5. Save Estimate Banner / Local Excel Action
                        Container(
                          key: _leadKey,
                          child: _buildResultsSaveCard(context, provider),
                        ),
                      ],

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // 6. Footer & Brand Section
            _buildFooterSection(context),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SECTION 1: TOP HERO SECTION
  // ==========================================
  Widget _buildHeroSection(BuildContext context, {bool isPortrait = false}) {
    final size = MediaQuery.sizeOf(context);

    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          // Solar panels hero image with white gradient blend & orange corner wave
          // Always visible in both landscape and portrait!
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            width: size.width * (isPortrait ? 0.52 : 0.58),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/solar_panels_hero.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/hero_banner.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.centerRight,
                    );
                  },
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.white,
                        Color(0xF0FFFFFF),
                        Color(0x33FFFFFF),
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.16, 0.40, 0.65],
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  width: size.width * (isPortrait ? 0.22 : 0.28),
                  height: isPortrait ? 65 : 100,
                  child: CustomPaint(
                    painter: _OrangeCornerWavePainter(),
                  ),
                ),
              ],
            ),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isPortrait ? 24.0 : 44.0,
                vertical: isPortrait ? 14.0 : 24.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: size.width * (isPortrait ? 0.58 : 0.50),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WebsolLogo(fontSize: isPortrait ? 28 : 38, showTagline: true),
                    SizedBox(height: isPortrait ? 10 : 26),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: isPortrait ? 23 : (size.width < 900 ? 29 : 34),
                          fontWeight: FontWeight.w900,
                          height: 1.08,
                          letterSpacing: 0.5,
                          fontFamily: 'sans-serif',
                        ),
                        children: const [
                          TextSpan(
                            text: 'WHAT COULD\n',
                            style: TextStyle(color: Color(0xFF0E3B6C)),
                          ),
                          TextSpan(
                            text: 'SOLAR SAVE YOU?',
                            style: TextStyle(color: Color(0xFFF36A21)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isPortrait ? 8 : 14),
                    Text(
                      'Your Electricity Bill. Your Solar Potential. Your Savings.',
                      style: TextStyle(
                        fontSize: isPortrait ? 11.5 : 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F5B9E),
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(height: isPortrait ? 4 : 8),
                    Text(
                      'Discover your estimated savings with rooftop solar using our interactive Solar Calculator.',
                      style: TextStyle(
                        fontSize: isPortrait ? 10.5 : 12.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF475569),
                        height: 1.35,
                      ),
                    ),
                    SizedBox(height: isPortrait ? 14 : 24),
                    // Non-wrapping Row so DoodleCallout stays right beside the button in one sleek line
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _scrollToCalculator,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF36A21),
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shadowColor: const Color(0xFFF36A21).withValues(alpha: 0.4),
                              padding: EdgeInsets.symmetric(
                                horizontal: isPortrait ? 18 : 28,
                                vertical: isPortrait ? 12 : 18,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'CALCULATE MY SAVINGS',
                                  style: TextStyle(
                                    fontSize: isPortrait ? 11 : 13,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.7,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: isPortrait ? 18 : 20),
                              ],
                            ),
                          ),
                          SizedBox(width: isPortrait ? 10 : 18),
                          DoodleCallout(compact: isPortrait),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 2A: SECTION TITLE
  // ==========================================
  Widget _buildHomeSectionHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFF36A21),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x33F36A21),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.home_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'TELL US ABOUT YOUR HOME',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0E3B6C),
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "A few simple details and we'll show you your potential savings.",
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 2B: CUSTOMER DETAILS CARD
  // ==========================================
  Widget _buildCustomerDetailsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF0E3B6C),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'CUSTOMER DETAILS',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0E3B6C),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Enter customer contact information',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 500;
              final gap = constraints.maxWidth >= 720 ? 18.0 : 12.0;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildNameInput()),
                    SizedBox(width: gap),
                    Expanded(child: _buildPhoneInput()),
                    SizedBox(width: gap),
                    Expanded(child: _buildEmailInput()),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNameInput(),
                    const SizedBox(height: 16),
                    _buildPhoneInput(),
                    const SizedBox(height: 16),
                    _buildEmailInput(),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 2C: CALCULATION FORM CARD
  // ==========================================
  Widget _buildCalculationCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isTwoColumn = constraints.maxWidth >= 500;
              final colGap = constraints.maxWidth >= 750 ? 32.0 : 20.0;

              if (isTwoColumn) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Section: Left Details & Right Appliances
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column (Property & Grid details)
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStateField(),
                              const SizedBox(height: 20),
                              _buildMonthlyBillField(),
                              const SizedBox(height: 20),
                              _buildPropertyTypeField(),
                            ],
                          ),
                        ),
                        SizedBox(width: colGap),
                        // Right Column (10 Appliances)
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHouseholdAppliancesField(),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Side-by-Side Row: Installation Type & Other Load (Watt) - starting & ending same!
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _buildInstallationTypeField(),
                        ),
                        SizedBox(width: colGap),
                        Expanded(
                          flex: 5,
                          child: _buildOtherWattsField(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Full-width Module Power (W)
                    _buildModuleWattField(),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStateField(),
                    const SizedBox(height: 18),
                    _buildMonthlyBillField(),
                    const SizedBox(height: 18),
                    _buildPropertyTypeField(),
                    const SizedBox(height: 20),
                    _buildHouseholdAppliancesField(),
                    const SizedBox(height: 20),
                    _buildInstallationTypeField(),
                    const SizedBox(height: 20),
                    _buildOtherWattsField(),
                    const SizedBox(height: 20),
                    _buildModuleWattField(),
                  ],
                );
              }
            },
          ),

          const SizedBox(height: 32),

          // Action Buttons: "GET MY ESTIMATE →" & "CLEAR"
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 14,
              children: [
                SizedBox(
                  width: 270,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      final bill = double.tryParse(_billController.text.trim()) ?? 0.0;
                      if (bill <= 0) {
                        TopAlert.show(
                          context,
                          title: 'Invalid Electricity Bill',
                          message: 'Monthly electricity bill must be greater than 0.',
                          type: TopAlertType.error,
                        );
                        return;
                      }

                      final input = _buildCurrentInput();
                      if (input.totalLoadWatts <= 0) {
                        TopAlert.show(
                          context,
                          title: 'Appliances Required',
                          message: 'Please specify at least one appliance or load.',
                          type: TopAlertType.error,
                        );
                        return;
                      }

                      setState(() {
                        _hasCalculated = true;
                      });
                      _syncAndCalculate(notifyUI: true);
                      _scrollToResults();

                      final result = context.read<SolarCalculatorProvider>().result;
                      if (result != null) {
                        TopAlert.show(
                          context,
                          title: 'Estimate Calculated',
                          message: '${result.modules} modules • ₹ ${_formatIndianCurrency(result.monthlySaving)} estimated monthly savings.',
                          type: TopAlertType.success,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF36A21),
                      foregroundColor: Colors.white,
                      elevation: 5,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shadowColor: const Color(0xFFF36A21).withValues(alpha: 0.45),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'GET MY ESTIMATE',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  width: 140,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _handleClearForm,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF475569),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF64748B)),
                        SizedBox(width: 6),
                        Text(
                          'CLEAR',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Form Input Helpers ---
  Widget _buildFieldTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFF0E3B6C)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldTitle(icon: Icons.location_on_outlined, title: 'State/UT'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedState,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
              items: _indianStates.map((state) {
                return DropdownMenuItem<String>(
                  value: state,
                  child: Text(
                    state,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedState = val);
                  _syncAndCalculate();
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyBillField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldTitle(icon: Icons.receipt_long_outlined, title: 'Monthly Electricity Bill (Rs.)'),
        const SizedBox(height: 8),
        TextField(
          controller: _billController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => _syncAndCalculate(),
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'Enter amount (e.g. 5000)',
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF36A21), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldTitle(icon: Icons.domain_rounded, title: 'Solar Application'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() => _propertyType = 'Residential');
                  _syncAndCalculate();
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _propertyType == 'Residential' ? const Color(0xFFF36A21) : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: _propertyType == 'Residential' ? const Color(0xFFF36A21) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Residential',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: _propertyType == 'Residential' ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() => _propertyType = 'Commercial');
                  _syncAndCalculate();
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _propertyType == 'Commercial' ? const Color(0xFFF36A21) : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: _propertyType == 'Commercial' ? const Color(0xFFF36A21) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Commercial',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: _propertyType == 'Commercial' ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInstallationTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldTitle(icon: Icons.solar_power_outlined, title: 'Installation Type'),
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _installationType,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
              items: const [
                DropdownMenuItem(value: 'Rooftop', child: Text('Rooftop', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600))),
                DropdownMenuItem(value: 'Ground Mounted', child: Text('Ground Mounted', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600))),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _installationType = val);
                  _syncAndCalculate();
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModuleWattField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldTitle(icon: Icons.electric_meter_outlined, title: 'Module Power (W)'),
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _moduleWatt,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
              items: const [
                DropdownMenuItem(value: 550, child: Text('550 W (Default Mono-PERC / TopCon)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600))),
                DropdownMenuItem(value: 500, child: Text('500 W (Standard)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600))),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _moduleWatt = val);
                  _syncAndCalculate();
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHouseholdAppliancesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.kitchen_outlined, size: 15, color: Color(0xFF0E3B6C)),
            const SizedBox(width: 6),
            const Text(
              'Household Appliances',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '(Counts from Solar_Calculator.xlsx)',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // 5 rows x 2 columns = 10 appliances
        Row(
          children: [
            Expanded(
              child: _buildApplianceItem(
                icon: Icons.air_rounded,
                label: 'Fan',
                count: _fansCount,
                onChanged: (val) {
                  setState(() => _fansCount = val);
                  _syncAndCalculate();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildApplianceItem(
                icon: Icons.lightbulb_outline_rounded,
                label: 'Light',
                count: _lightsCount,
                onChanged: (val) {
                  setState(() => _lightsCount = val);
                  _syncAndCalculate();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildApplianceItem(
                icon: Icons.tv_rounded,
                label: 'TV',
                count: _tvCount,
                onChanged: (val) {
                  setState(() => _tvCount = val);
                  _syncAndCalculate();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildApplianceItem(
                icon: Icons.ac_unit_rounded,
                label: 'AC',
                count: _acsCount,
                onChanged: (val) {
                  setState(() => _acsCount = val);
                  _syncAndCalculate();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildApplianceItem(
                icon: Icons.local_laundry_service_outlined,
                label: 'Washing machine',
                count: _washingCount,
                onChanged: (val) {
                  setState(() => _washingCount = val);
                  _syncAndCalculate();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildApplianceItem(
                icon: Icons.kitchen_rounded,
                label: 'Fridge',
                count: _fridgeCount,
                onChanged: (val) {
                  setState(() => _fridgeCount = val);
                  _syncAndCalculate();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildApplianceItem(
                icon: Icons.coffee_maker_outlined,
                label: 'Electric kettle',
                count: _kettleCount,
                onChanged: (val) {
                  setState(() => _kettleCount = val);
                  _syncAndCalculate();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildApplianceItem(
                icon: Icons.microwave_outlined,
                label: 'Induction cooker',
                count: _inductionCount,
                onChanged: (val) {
                  setState(() => _inductionCount = val);
                  _syncAndCalculate();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildApplianceItem(
                icon: Icons.water_drop_outlined,
                label: 'Submersible pump',
                count: _pumpCount,
                onChanged: (val) {
                  setState(() => _pumpCount = val);
                  _syncAndCalculate();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildApplianceItem(
                icon: Icons.hot_tub_rounded,
                label: 'Geyser',
                count: _geyserCount,
                onChanged: (val) {
                  setState(() => _geyserCount = val);
                  _syncAndCalculate();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOtherWattsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldTitle(icon: Icons.bolt_rounded, title: 'Other Load (Watt)'),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: TextField(
            controller: _otherWattsController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => _syncAndCalculate(),
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'e.g. 200',
              hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              suffixText: 'Watt',
              suffixStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF0E3B6C)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFF36A21), width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApplianceItem({
    required IconData icon,
    required String label,
    required int count,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: count,
              isDense: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Color(0xFF64748B)),
              items: List.generate(21, (index) => index).map((i) {
                return DropdownMenuItem<int>(
                  value: i,
                  child: Text(
                    '$i',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 3: YOUR SOLAR ESTIMATE RESULTS CARD
  // ==========================================
  Widget _buildSolarEstimateCard(BuildContext context, SolarResult result) {
    return Container(
      key: _resultsKey,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6FD),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDCE8F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Sun Icon
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFF36A21),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'YOUR SOLAR ESTIMATE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0E3B6C),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      "Based on your inputs, here's what you could save and achieve.",
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // If Surplus, show surplus banner
          if (result.isSurplus) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.bolt_rounded, color: Color(0xFF15803D), size: 24),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You are now generating Surplus Energy! You will get benefit of Surplus Amount in Next Month Bill.',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF14532D),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // 5 Metric Cards (Always single row on tablet portrait & landscape)
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 500;
              final isCompact = constraints.maxWidth < 850;
              final spacing = isCompact ? 8.0 : 12.0;

              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: _buildSavingsMetricCard(result, isCompact: isCompact)),
                    SizedBox(width: spacing),
                    Expanded(child: _buildBillReductionMetricCard(result, isCompact: isCompact)),
                    SizedBox(width: spacing),
                    Expanded(child: _buildRevisedBillMetricCard(result, isCompact: isCompact)),
                    SizedBox(width: spacing),
                    Expanded(child: _buildInstallationCostMetricCard(result, isCompact: isCompact)),
                    SizedBox(width: spacing),
                    Expanded(child: _buildSubsidyMetricCard(result, isCompact: isCompact)),
                  ],
                );
              } else {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(width: 140, child: _buildSavingsMetricCard(result, isCompact: true)),
                      const SizedBox(width: 8),
                      SizedBox(width: 140, child: _buildBillReductionMetricCard(result, isCompact: true)),
                      const SizedBox(width: 8),
                      SizedBox(width: 140, child: _buildRevisedBillMetricCard(result, isCompact: true)),
                      const SizedBox(width: 8),
                      SizedBox(width: 140, child: _buildInstallationCostMetricCard(result, isCompact: true)),
                      const SizedBox(width: 8),
                      SizedBox(width: 140, child: _buildSubsidyMetricCard(result, isCompact: true)),
                    ],
                  ),
                );
              }
            },
          ),

          const SizedBox(height: 18),

          // Secondary System Specs Summary Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceAround,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 20,
              runSpacing: 10,
              children: [
                _buildSpecItem(
                  icon: Icons.solar_power_rounded,
                  label: 'Solar Modules',
                  value: '${result.modules} Modules (${result.systemKw.toStringAsFixed(2)} kW)',
                ),
                _buildSpecItem(
                  icon: Icons.crop_free_rounded,
                  label: 'Space Required',
                  value: '${result.spaceM2.toStringAsFixed(2)} m²',
                ),
                _buildSpecItem(
                  icon: Icons.price_check_rounded,
                  label: 'Effective Total Cost',
                  value: 'Rs. ${_formatIndianCurrency(result.effectiveCost)}',
                  highlight: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem({
    required IconData icon,
    required String label,
    required String value,
    bool highlight = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: highlight ? const Color(0xFF16A34A) : const Color(0xFF0E3B6C)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: highlight ? const Color(0xFF16A34A) : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  // 1. Estimated Monthly Savings
  Widget _buildSavingsMetricCard(SolarResult result, {bool isCompact = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 8 : 14, vertical: isCompact ? 14 : 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF36A21).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.account_balance_wallet_outlined, size: 20, color: Color(0xFFEA580C)),
          ),
          const SizedBox(height: 10),
          const Text(
            'Estimated Monthly\nSavings',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF9A3412),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '₹ ${_formatIndianCurrency(result.monthlySaving)}',
              style: TextStyle(
                fontSize: isCompact ? 16 : 18,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFEA580C),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'approx.',
            style: TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  // 2. Electricity Bill Reduction
  Widget _buildBillReductionMetricCard(SolarResult result, {bool isCompact = false}) {
    final bool isSurplus = result.isSurplus;
    final percVal = isSurplus ? 100 : (result.billReduction! * 100.0).toStringAsFixed(1);
    final progress = isSurplus ? 1.0 : result.billReduction!.clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 8 : 14, vertical: isCompact ? 14 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: isCompact ? 48 : 58,
            height: isCompact ? 48 : 58,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: isCompact ? 48 : 58,
                  height: isCompact ? 48 : 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSurplus
                        ? const Color(0xFF16A34A).withValues(alpha: 0.08)
                        : const Color(0xFF0F5B9E).withValues(alpha: 0.08),
                  ),
                ),
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4.5,
                  strokeCap: StrokeCap.round,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isSurplus ? const Color(0xFF16A34A) : const Color(0xFF0F5B9E),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      isSurplus ? '100%' : '$percVal%',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: isSurplus ? const Color(0xFF16A34A) : const Color(0xFF0E3B6C),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Bill\nReduction',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0E3B6C),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSurplus ? 'Surplus Energy' : 'up to',
            style: const TextStyle(fontSize: 9, color: Color(0xFF64748B)),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              isSurplus ? 'Surplus' : '$percVal%',
              style: TextStyle(
                fontSize: isSurplus ? 15 : (isCompact ? 16 : 18),
                fontWeight: FontWeight.w900,
                color: isSurplus ? const Color(0xFF16A34A) : const Color(0xFF0E3B6C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Revised Monthly Electricity Bill
  Widget _buildRevisedBillMetricCard(SolarResult result, {bool isCompact = false}) {
    final bool isSurplus = result.isSurplus;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 8 : 14, vertical: isCompact ? 14 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.description_outlined, size: 20, color: Color(0xFF0284C7)),
          ),
          const SizedBox(height: 10),
          const Text(
            'Revised Monthly\nBill',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0369A1),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              isSurplus ? '₹ 0' : '₹ ${_formatIndianCurrency(result.revisedBill!)}',
              style: TextStyle(
                fontSize: isCompact ? 16 : 18,
                fontWeight: FontWeight.w900,
                color: isSurplus ? const Color(0xFF16A34A) : const Color(0xFF0F5B9E),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isSurplus ? 'Surplus credited' : 'approx.',
            style: const TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  // 4. Estimated Solar Installation Cost
  Widget _buildInstallationCostMetricCard(SolarResult result, {bool isCompact = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 8 : 14, vertical: isCompact ? 14 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0E3B6C).withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.savings_outlined, size: 20, color: Color(0xFF0E3B6C)),
          ),
          const SizedBox(height: 10),
          const Text(
            'Approx. Cost\nof Modules',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0E3B6C),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '₹ ${_formatIndianCurrency(result.cost)}',
              style: TextStyle(
                fontSize: isCompact ? 16 : 18,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0E3B6C),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'approx.',
            style: TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  // 5. Applicable Government Subsidy
  Widget _buildSubsidyMetricCard(SolarResult result, {bool isCompact = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 8 : 14, vertical: isCompact ? 14 : 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.account_balance_outlined, size: 20, color: Color(0xFF16A34A)),
          ),
          const SizedBox(height: 10),
          const Text(
            'Govt. Subsidy\n(PM Surya Ghar)',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF15803D),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '₹ ${_formatIndianCurrency(result.subsidy)}',
              style: TextStyle(
                fontSize: isCompact ? 16 : 18,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF15803D),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'PM Surya Ghar',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 9, color: Color(0xFF64748B), height: 1.2),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 4: ENVIRONMENTAL IMPACT CARD
  // ==========================================
  Widget _buildImpactCard(BuildContext context, SolarResult result) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF2FBF5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCFCE7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFF16A34A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.eco_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'YOUR IMPACT GOES BEYOND SAVINGS',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF14532D),
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 480;

              if (isWide) {
                return Row(
                  children: [
                    Expanded(
                      child: _buildImpactMetric(
                        icon: Icons.park_rounded,
                        isCustomIcon: false,
                        label: 'Equivalent Trees Planted',
                        value: result.trees.round().toString(),
                        unit: 'trees per year',
                      ),
                    ),
                    Container(width: 1, height: 48, color: const Color(0xFFBBF7D0)),
                    Expanded(
                      child: _buildImpactMetric(
                        icon: Icons.cloud_outlined,
                        isCustomIcon: true,
                        label: 'Annual CO₂ Emissions\nReduction',
                        value: result.co2MT.toStringAsFixed(2),
                        unit: 'MT per year',
                      ),
                    ),
                    Container(width: 1, height: 48, color: const Color(0xFFBBF7D0)),
                    Expanded(
                      child: _buildImpactMetric(
                        icon: Icons.landscape_rounded,
                        isCustomIcon: false,
                        label: 'Annual Coal Savings',
                        value: result.coalMT.toStringAsFixed(2),
                        unit: 'MT per year',
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildImpactMetric(
                      icon: Icons.park_rounded,
                      isCustomIcon: false,
                      label: 'Equivalent Trees Planted',
                      value: result.trees.round().toString(),
                      unit: 'trees per year',
                    ),
                    const Divider(color: Color(0xFFBBF7D0)),
                    _buildImpactMetric(
                      icon: Icons.cloud_outlined,
                      isCustomIcon: true,
                      label: 'Annual CO₂ Emissions Reduction',
                      value: result.co2MT.toStringAsFixed(2),
                      unit: 'MT per year',
                    ),
                    const Divider(color: Color(0xFFBBF7D0)),
                    _buildImpactMetric(
                      icon: Icons.landscape_rounded,
                      isCustomIcon: false,
                      label: 'Annual Coal Savings',
                      value: result.coalMT.toStringAsFixed(2),
                      unit: 'MT per year',
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImpactMetric({
    required IconData icon,
    required bool isCustomIcon,
    required String label,
    required String value,
    required String unit,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isCustomIcon)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'CO₂',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 10.5,
                ),
              ),
            )
          else
            Icon(icon, size: 32, color: const Color(0xFF15803D)),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF166534),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF14532D),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        unit,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 5: SAVE RESULT BUTTON (BELOW ESTIMATE RESULTS)
  // ==========================================
  Widget _buildResultsSaveCard(BuildContext context, SolarCalculatorProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: [
          Center(
            child: SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: provider.isSavingLead ? null : _handleSaveLead,
                icon: provider.isSavingLead
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Icon(Icons.save_rounded, size: 20),
                label: const Text(
                  'SAVE RESULT',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF36A21),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: const Color(0xFFF36A21).withValues(alpha: 0.4),
                  padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.folder_open_rounded, size: 15, color: Color(0xFF64748B)),
              SizedBox(width: 6),
              Text(
                'Stored directly on tablet in Downloads/Websol_Leads.xlsx',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldTitle(icon: Icons.person_rounded, title: 'Full Name *'),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'Enter full name',
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0E3B6C), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldTitle(icon: Icons.phone_android_outlined, title: 'Phone Number (10 digits) *'),
        const SizedBox(height: 8),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: '10-digit number',
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 14, right: 8),
              child: Text(
                '+91',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0E3B6C),
                ),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0E3B6C), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldTitle(icon: Icons.email_outlined, title: 'Email ID *'),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'Enter email address',
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0E3B6C), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // SECTION 6: FOOTER & BRAND
  // ==========================================
  Widget _buildFooterSection(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: 1,
            color: const Color(0xFFE2E8F0),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 500;
                    final isCompact = constraints.maxWidth < 750;
                    final gap = isCompact ? 20.0 : 32.0;

                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: _buildFooterLeftContent(isCompact: isCompact)),
                          SizedBox(width: gap),
                          _buildFooterQrCard(),
                        ],
                      );
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFooterLeftContent(isCompact: true),
                          const SizedBox(height: 24),
                          Center(child: _buildFooterQrCard()),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
          ),
          _buildBrandStrip(),
        ],
      ),
    );
  }

  Widget _buildFooterLeftContent({bool isCompact = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'READY TO EXPLORE\nYOUR SOLAR FUTURE?',
          style: TextStyle(
            fontSize: isCompact ? 17 : 21,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF0E3B6C),
            height: 1.15,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Powering Tomorrow’s Energy',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFFF36A21),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Discover how Websol can help power a more sustainable tomorrow.',
          style: TextStyle(
            fontSize: 11,
            color: Color(0xFF64748B),
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildFooterQrCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          WebsolQrCode(
            size: 64,
          ),
          SizedBox(width: 14),
          Text(
            'Scan the QR code to connect with Websol',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0E3B6C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandStrip() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0E3B6C),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'CLEANER ENERGY',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.circle, size: 6, color: Color(0xFFF36A21)),
          ),
          Text(
            'GREENER TOMORROW',
            style: TextStyle(
              color: Color(0xFFF36A21),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrangeCornerWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF36A21)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
      size.width * 0.45,
      size.height * 0.95,
      size.width * 0.65,
      size.height * 0.55,
    );
    path.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.15,
      size.width,
      0,
    );
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
