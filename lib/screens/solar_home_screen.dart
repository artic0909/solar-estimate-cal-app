import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/websol_logo.dart';
import '../widgets/doodle_arrow.dart';
import '../widgets/qr_code_widget.dart';

class SolarHomeScreen extends StatefulWidget {
  const SolarHomeScreen({super.key});

  @override
  State<SolarHomeScreen> createState() => _SolarHomeScreenState();
}

class _SolarHomeScreenState extends State<SolarHomeScreen> {
  // Customer details form state
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Input form state (defaults matching reference image)
  String _selectedState = 'Select State';
  final TextEditingController _billController = TextEditingController(text: '');
  String _propertyType = 'Residential';
  String _installationType = 'Rooftop';

  // Appliance counts
  int _fansCount = 0;
  int _lightsCount = 0;
  int _acsCount = 0;
  int _fridgeCount = 0;
  int _tvCount = 0;
  int _otherCount = 0;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _calculatorKey = GlobalKey();

  static const List<String> _indianStates = [
    'Select State',
    'Andhra Pradesh',
    'Assam',
    'Bihar',
    'Delhi',
    'Gujarat',
    'Haryana',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Tamil Nadu',
    'Telangana',
    'Uttar Pradesh',
    'West Bengal',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _billController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Top Hero Section
            _buildHeroSection(context),

            // Main Content Area with max constraint for clean tablet layout
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1160),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),

                      // 2. TELL US ABOUT YOUR HOME Section
                      Container(
                        key: _calculatorKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHomeSectionHeader(),
                            const SizedBox(height: 16),
                            _buildCustomerDetailsCard(context),
                            const SizedBox(height: 20),
                            _buildCalculationCard(context),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // 3. Results Card ("YOUR SOLAR ESTIMATE")
                      _buildSolarEstimateCard(context),

                      const SizedBox(height: 28),

                      // 4. Environmental Impact Card ("YOUR IMPACT GOES BEYOND SAVINGS")
                      _buildImpactCard(context),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // 5. Footer & Explore Solar Future Section
            _buildFooterSection(context),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SECTION 1: TOP HERO SECTION
  // ==========================================
  Widget _buildHeroSection(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= 850;

    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          // Right Side: Solar Rooftop Photo with Sun Flare and Gradient Fade
          if (isWide)
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              width: size.width * 0.58,
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
                  // Left-edge soft white gradient blend
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.white,
                          Color(0xD9FFFFFF),
                          Color(0x22FFFFFF),
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.16, 0.38, 0.60],
                      ),
                    ),
                  ),
                  // Orange wave corner accent at bottom right
                  Positioned(
                    right: 0,
                    bottom: 0,
                    width: size.width * 0.28,
                    height: 100,
                    child: CustomPaint(
                      painter: _OrangeCornerWavePainter(),
                    ),
                  ),
                ],
              ),
            ),

          // Foreground Hero Content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 44.0 : 20.0,
                vertical: 24.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWide ? (size.width * 0.50) : size.width,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand Logo
                    const WebsolLogo(
                      fontSize: 44,
                      showTagline: true,
                    ),

                    const SizedBox(height: 28),

                    // Headline
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          letterSpacing: 0.5,
                          fontFamily: 'sans-serif',
                        ),
                        children: [
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

                    const SizedBox(height: 14),

                    // Subtitle
                    const Text(
                      'Your Electricity Bill. Your Solar Potential. Your Savings.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F5B9E),
                        letterSpacing: 0.2,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Description
                    const Text(
                      'Discover your estimated savings with rooftop solar using our interactive Solar Calculator.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF475569),
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 26),

                    // CTA Button & Playful Callout
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 18,
                      runSpacing: 14,
                      children: [
                        ElevatedButton(
                          onPressed: _scrollToCalculator,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF36A21),
                            foregroundColor: Colors.white,
                            elevation: 5,
                            shadowColor: const Color(0xFFF36A21).withValues(alpha: 0.4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'CALCULATE MY SAVINGS',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                        ),
                        const DoodleCallout(),
                      ],
                    ),

                    // Photo card fallback for narrow screens
                    if (!isWide) ...[
                      const SizedBox(height: 24),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            Image.asset(
                              'assets/images/solar_panels_hero.jpg',
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              width: 120,
                              height: 60,
                              child: CustomPaint(
                                painter: _OrangeCornerWavePainter(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
  // SECTION 2A: SECTION TITLE ("TELL US ABOUT YOUR HOME")
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
            child: const Icon(
              Icons.home_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'TELL US ABOUT YOUR HOME',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0E3B6C),
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "A few simple details and we'll show you your potential savings.",
                  style: TextStyle(
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
    );
  }

  // ==========================================
  // SECTION 2B: CUSTOMER DETAILS CARD
  // ==========================================
  Widget _buildCustomerDetailsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E3B6C).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  size: 18,
                  color: Color(0xFF0E3B6C),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'CUSTOMER DETAILS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0E3B6C),
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 720;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildNameField()),
                    const SizedBox(width: 20),
                    Expanded(child: _buildPhoneField()),
                    const SizedBox(width: 20),
                    Expanded(child: _buildEmailField()),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNameField(),
                    const SizedBox(height: 16),
                    _buildPhoneField(),
                    const SizedBox(height: 16),
                    _buildEmailField(),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldTitle(
          icon: Icons.person_rounded,
          title: 'Full Name',
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'Enter full name',
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
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

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldTitle(
          icon: Icons.phone_android_outlined,
          title: 'Phone Number',
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: '10-digit number',
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 14, right: 8),
              child: Text(
                '+91',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0E3B6C),
                ),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
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

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldTitle(
          icon: Icons.email_outlined,
          title: 'Email ID',
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'Enter email address',
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
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

  // ==========================================
  // SECTION 2C: CALCULATION FORM CARD (HALF-AND-HALF)
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
          // Two-column Form Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isTwoColumn = constraints.maxWidth >= 700;

              if (isTwoColumn) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column
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
                    const SizedBox(width: 36),
                    // Right Column
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInstallationTypeField(),
                          const SizedBox(height: 20),
                          _buildHouseholdAppliancesField(),
                        ],
                      ),
                    ),
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
                    const SizedBox(height: 22),
                    _buildInstallationTypeField(),
                    const SizedBox(height: 22),
                    _buildHouseholdAppliancesField(),
                  ],
                );
              }
            },
          ),

          const SizedBox(height: 32),

          // Large Centered "GET MY ESTIMATE →" Button
          Center(
            child: SizedBox(
              width: 290,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Solar estimate calculated! View your personalized results below.',
                      ),
                      backgroundColor: const Color(0xFF0E3B6C),
                      duration: const Duration(seconds: 3),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF36A21),
                  foregroundColor: Colors.white,
                  elevation: 5,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shadowColor: const Color(0xFFF36A21).withValues(alpha: 0.45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'GET MY ESTIMATE',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
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
        Icon(icon, size: 16, color: const Color(0xFF0E3B6C)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
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
        _buildFieldTitle(
          icon: Icons.location_on_outlined,
          title: 'State',
        ),
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
                    style: TextStyle(
                      fontSize: 14,
                      color: state == 'Select State' ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                      fontWeight: state == 'Select State' ? FontWeight.w500 : FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedState = val);
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
        _buildFieldTitle(
          icon: Icons.receipt_long_outlined,
          title: 'Monthly Electricity Bill (₹)',
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _billController,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'Enter amount',
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
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
        _buildFieldTitle(
          icon: Icons.domain_rounded,
          title: 'Property Type',
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _propertyType = 'Residential'),
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
                      fontSize: 13,
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
                onTap: () => setState(() => _propertyType = 'Commercial'),
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
                      fontSize: 13,
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
        _buildFieldTitle(
          icon: Icons.solar_power_outlined,
          title: 'Installation Type',
        ),
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
              value: _installationType,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
              items: const [
                DropdownMenuItem(value: 'Rooftop', child: Text('Rooftop', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                DropdownMenuItem(value: 'Ground Mounted', child: Text('Ground Mounted', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _installationType = val);
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
            const Icon(Icons.kitchen_outlined, size: 16, color: Color(0xFF0E3B6C)),
            const SizedBox(width: 6),
            const Text(
              'Household Appliances',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                '(Optional – for better accuracy)',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // 2x3 Grid of appliances
        Row(
          children: [
            Expanded(
              child: _buildApplianceItem(
                icon: Icons.air_rounded,
                label: 'Fans',
                count: _fansCount,
                onChanged: (val) => setState(() => _fansCount = val),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildApplianceItem(
                icon: Icons.lightbulb_outline_rounded,
                label: 'Lights',
                count: _lightsCount,
                onChanged: (val) => setState(() => _lightsCount = val),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildApplianceItem(
                icon: Icons.ac_unit_rounded,
                label: 'ACs',
                count: _acsCount,
                onChanged: (val) => setState(() => _acsCount = val),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildApplianceItem(
                icon: Icons.kitchen_rounded,
                label: 'Refrigerator',
                count: _fridgeCount,
                onChanged: (val) => setState(() => _fridgeCount = val),
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
                onChanged: (val) => setState(() => _tvCount = val),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildApplianceItem(
                icon: Icons.power_rounded,
                label: 'Other',
                count: _otherCount,
                onChanged: (val) => setState(() => _otherCount = val),
              ),
            ),
          ],
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
          Icon(icon, size: 16, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
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
              items: List.generate(11, (index) => index).map((i) {
                return DropdownMenuItem<int>(
                  value: i,
                  child: Text(
                    '$i',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
  Widget _buildSolarEstimateCard(BuildContext context) {
    return Container(
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
                child: const Icon(
                  Icons.wb_sunny_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'YOUR SOLAR ESTIMATE',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0E3B6C),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      "Based on your inputs, here's what you could save and achieve.",
                      style: TextStyle(
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

          const SizedBox(height: 24),

          // 5 Metric Cards (Responsive Layout)
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final isMedium = constraints.maxWidth >= 550;

              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: _buildSavingsMetricCard()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildBillReductionMetricCard()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildRevisedBillMetricCard()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildInstallationCostMetricCard()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildSubsidyMetricCard()),
                  ],
                );
              } else if (isMedium) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildSavingsMetricCard()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildBillReductionMetricCard()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildRevisedBillMetricCard()),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildInstallationCostMetricCard()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildSubsidyMetricCard()),
                      ],
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildSavingsMetricCard(),
                    const SizedBox(height: 12),
                    _buildBillReductionMetricCard(),
                    const SizedBox(height: 12),
                    _buildRevisedBillMetricCard(),
                    const SizedBox(height: 12),
                    _buildInstallationCostMetricCard(),
                    const SizedBox(height: 12),
                    _buildSubsidyMetricCard(),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // 1. Estimated Monthly Savings
  Widget _buildSavingsMetricCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
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
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF9A3412),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '₹ 3,905',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFFEA580C),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'approx.',
            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  // 2. Electricity Bill Reduction (with circular ring indicator)
  Widget _buildBillReductionMetricCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: 0.78,
                  strokeWidth: 4.5,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0F5B9E)),
                ),
                const Text(
                  '78%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0E3B6C),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Electricity Bill\nReduction',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0E3B6C),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'up to',
            style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
          ),
          const Text(
            '78%',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0E3B6C),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Revised Monthly Electricity Bill
  Widget _buildRevisedBillMetricCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
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
            'Revised Monthly\nElectricity Bill',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0369A1),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '₹ 1,094',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F5B9E),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'approx.',
            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  // 4. Estimated Solar Installation Cost
  Widget _buildInstallationCostMetricCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
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
            'Estimated Solar\nInstallation Cost',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0E3B6C),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '₹ 1,13,850',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0E3B6C),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'approx.',
            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  // 5. Applicable Government Subsidy
  Widget _buildSubsidyMetricCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
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
            'Applicable\nGovernment Subsidy',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF15803D),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '₹ 78,000',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF15803D),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'approx.\n(subject to eligibility)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: Color(0xFF64748B), height: 1.2),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 4: ENVIRONMENTAL IMPACT CARD
  // ==========================================
  Widget _buildImpactCard(BuildContext context) {
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
          // Header with Green Leaf
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
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF14532D),
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // 3 Impact Metrics Row
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;

              if (isWide) {
                return Row(
                  children: [
                    Expanded(
                      child: _buildImpactMetric(
                        icon: Icons.park_rounded,
                        isCustomIcon: false,
                        label: 'Equivalent Trees Planted',
                        value: '3.63',
                        unit: 'per year',
                      ),
                    ),
                    Container(width: 1, height: 48, color: const Color(0xFFBBF7D0)),
                    Expanded(
                      child: _buildImpactMetric(
                        icon: Icons.cloud_outlined,
                        isCustomIcon: true, // CO2 badge
                        label: 'Annual CO₂ Emissions\nReduction',
                        value: '4.45',
                        unit: 'MT per year',
                      ),
                    ),
                    Container(width: 1, height: 48, color: const Color(0xFFBBF7D0)),
                    Expanded(
                      child: _buildImpactMetric(
                        icon: Icons.landscape_rounded,
                        isCustomIcon: false,
                        label: 'Annual Coal Savings',
                        value: '202',
                        unit: 'kg per year',
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
                      value: '3.63',
                      unit: 'per year',
                    ),
                    const Divider(color: Color(0xFFBBF7D0)),
                    _buildImpactMetric(
                      icon: Icons.cloud_outlined,
                      isCustomIcon: true,
                      label: 'Annual CO₂ Emissions Reduction',
                      value: '4.45',
                      unit: 'MT per year',
                    ),
                    const Divider(color: Color(0xFFBBF7D0)),
                    _buildImpactMetric(
                      icon: Icons.landscape_rounded,
                      isCustomIcon: false,
                      label: 'Annual Coal Savings',
                      value: '202',
                      unit: 'kg per year',
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
          // Icon
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
                  fontSize: 12,
                ),
              ),
            )
          else
            Icon(icon, size: 36, color: const Color(0xFF15803D)),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 11,
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
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF14532D),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        unit,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
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
  // SECTION 5: FOOTER CTA & BRAND BANNER
  // ==========================================
  Widget _buildFooterSection(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Upper Footer with Skyline Silhouette, Text, and QR Code
          Stack(
            children: [
              // Rooftop solar skyline silhouette along bottom left
              Positioned(
                left: 0,
                bottom: 0,
                width: 320,
                height: 90,
                child: Opacity(
                  opacity: 0.18,
                  child: Image.asset(
                    'assets/images/solar_panels_hero.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.bottomLeft,
                    errorBuilder: (context, error, stackTrace) => const SizedBox(),
                  ),
                ),
              ),

              // Orange corner wave on bottom right
              Positioned(
                right: 0,
                bottom: 0,
                width: 220,
                height: 80,
                child: CustomPaint(
                  painter: _OrangeCornerWavePainter(),
                ),
              ),

              // Foreground content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 650;

                        if (isWide) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Left Text
                              Expanded(
                                flex: 6,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'READY TO EXPLORE\nYOUR SOLAR FUTURE?',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF0E3B6C),
                                        height: 1.15,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      "Powering Tomorrow's Energy",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFFF36A21),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Discover how Websol can help power a more sustainable tomorrow.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Vertical Divider
                              Container(
                                height: 75,
                                width: 2,
                                color: const Color(0xFFF59E0B),
                                margin: const EdgeInsets.symmetric(horizontal: 28),
                              ),

                              // Right QR Code & Text
                              Row(
                                children: const [
                                  WebsolQrCode(size: 82),
                                  SizedBox(width: 14),
                                  SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Scan the QR code to connect with Websol',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0E3B6C),
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'READY TO EXPLORE\nYOUR SOLAR FUTURE?',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0E3B6C),
                                  height: 1.15,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Powering Tomorrow's Energy",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFF36A21),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Discover how Websol can help power a more sustainable tomorrow.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: const [
                                  WebsolQrCode(size: 78),
                                  SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      'Scan the QR code to connect with Websol',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0E3B6C),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Bottom-most Deep Navy Bar
          Container(
            width: double.infinity,
            color: const Color(0xFF091E36),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 32, height: 1, color: const Color(0xFF38BDF8)),
                const SizedBox(width: 12),
                const Text(
                  'CLEANER ENERGY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    '|',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
                const Text(
                  'GREENER TOMORROW',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(width: 12),
                Container(width: 32, height: 1, color: const Color(0xFF38BDF8)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter for the orange wave corner accent
class _OrangeCornerWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF36A21)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.7,
      size.width * 0.7,
      size.height * 0.25,
    );
    path.quadraticBezierTo(
      size.width * 0.85,
      0,
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
