import 'package:flutter/material.dart';
import '../widgets/doodle_arrow.dart';
import '../widgets/websol_logo.dart';
import 'user_form_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _navigateToCalculator(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const UserFormScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isLandscape = size.width >= 750 && size.width > size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: isLandscape
          ? _buildLandscapeLayout(context, size)
          : _buildPortraitLayout(context, size),
    );
  }

  /// 1. Tablet Landscape Layout (Split side-by-side view)
  Widget _buildLandscapeLayout(BuildContext context, Size size) {
    return Stack(
      children: [
        // Right Side High-Resolution Solar Rooftop Image
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
              // Soft gradient fading smoothly on the left edge only
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.white,
                      Color(0xD9FFFFFF), // 85% white
                      Color(0x22FFFFFF), // soft transparent
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.14, 0.32, 0.50],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Decorative Orange Wave at Bottom Right
        Positioned(
          right: 0,
          bottom: 0,
          width: size.width * 0.32,
          height: 120,
          child: CustomPaint(
            painter: _OrangeCornerWavePainter(),
          ),
        ),

        // Foreground Content
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 52.0,
              vertical: 28.0,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    size.height - (MediaQuery.paddingOf(context).vertical + 56),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top: Prominent Websol Logo
                  const WebsolLogo(
                    fontSize: 48,
                    showTagline: true,
                  ),

                  const SizedBox(height: 32),

                  // Middle: Main Hero Content
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: size.width * 0.52,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeadline(fontSize: 50),
                        const SizedBox(height: 18),
                        _buildSubtitle(fontSize: 18),
                        const SizedBox(height: 12),
                        _buildDescription(fontSize: 16),
                        const SizedBox(height: 32),
                        _buildCtaSection(context),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildOfflineFooter(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 2. Tablet Portrait Layout (Balanced vertical composition)
  Widget _buildPortraitLayout(BuildContext context, Size size) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: Logo & Offline Chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const WebsolLogo(
                  fontSize: 38,
                  showTagline: true,
                ),
                _buildOfflineChip(),
              ],
            ),

            const SizedBox(height: 20),

            // Hero Solar Photo Card (Crisp, prominent solar panels visual)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9.5,
                      child: Image.asset(
                        'assets/images/solar_panels_hero.jpg',
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/hero_banner.png',
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                    // Sun flare warm overlay & corner orange ribbon
                    Positioned(
                      right: 0,
                      bottom: 0,
                      width: 130,
                      height: 65,
                      child: CustomPaint(
                        painter: _OrangeCornerWavePainter(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Headlines (Rendered on clean white background for 100% clarity)
            _buildHeadline(fontSize: 38),
            const SizedBox(height: 14),
            _buildSubtitle(fontSize: 16),
            const SizedBox(height: 10),
            _buildDescription(fontSize: 15),

            const SizedBox(height: 28),

            // CTA Button & Playful Callout
            _buildCtaSection(context),

            const SizedBox(height: 28),

            _buildOfflineFooter(),
          ],
        ),
      ),
    );
  }

  // --- Reusable UI Elements ---

  Widget _buildHeadline({required double fontSize}) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          height: 1.1,
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
    );
  }

  Widget _buildSubtitle({required double fontSize}) {
    return Text(
      'Your Electricity Bill. Your Solar Potential. Your Savings.',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF0F5B9E),
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildDescription({required double fontSize}) {
    return Text(
      'Discover your estimated savings with rooftop solar using our interactive Solar Calculator.',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF475569),
        height: 1.45,
      ),
    );
  }

  Widget _buildCtaSection(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 20,
      runSpacing: 16,
      children: [
        ElevatedButton(
          onPressed: () => _navigateToCalculator(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF36A21),
            foregroundColor: Colors.white,
            elevation: 6,
            shadowColor: const Color(0xFFF36A21).withValues(alpha: 0.45),
            padding: const EdgeInsets.symmetric(
              horizontal: 34,
              vertical: 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'CALCULATE MY SAVINGS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(width: 10),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        const DoodleCallout(),
      ],
    );
  }

  Widget _buildOfflineChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 14, color: Color(0xFF64748B)),
          SizedBox(width: 6),
          Text(
            'Offline Mode',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineFooter() {
    return Row(
      children: const [
        Icon(
          Icons.offline_pin_rounded,
          size: 16,
          color: Color(0xFF64748B),
        ),
        SizedBox(width: 6),
        Text(
          '100% Offline Mode • Instant Tablet Estimates',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

/// Painter for the orange wave corner accent at the bottom-right of the banner
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
