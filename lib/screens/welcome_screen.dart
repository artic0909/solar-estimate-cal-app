import 'package:flutter/material.dart';
import '../widgets/doodle_arrow.dart';
import '../widgets/tablet_scaffold.dart';
import '../widgets/websol_logo.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _navigateToCalculator(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const TabletScaffold(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTabletLandscape = size.width >= 750 && size.width > size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Right Side High-Resolution Solar Rooftop Image
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            width: isTabletLandscape ? size.width * 0.60 : size.width,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Clear, prominent solar panels
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

          // 2. Decorative Orange Wave at Bottom Right (Matching Banner)
          Positioned(
            right: 0,
            bottom: 0,
            width: size.width * 0.32,
            height: 120,
            child: CustomPaint(
              painter: _OrangeCornerWavePainter(),
            ),
          ),

          // 3. Foreground Content (Logo, Headlines, CTA, Doodle)
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isTabletLandscape ? 52.0 : 24.0,
                vertical: 28.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height - (MediaQuery.paddingOf(context).vertical + 56),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top: Prominent, larger Websol Logo
                    WebsolLogo(
                      fontSize: isTabletLandscape ? 48 : 36,
                      showTagline: true,
                    ),

                    const SizedBox(height: 32),

                    // Middle: Main Hero Content
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isTabletLandscape ? size.width * 0.52 : double.infinity,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Headline
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: isTabletLandscape ? 50 : 34,
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

                          const SizedBox(height: 18),

                          // Subtitle
                          Text(
                            'Your Electricity Bill. Your Solar Potential. Your Savings.',
                            style: TextStyle(
                              fontSize: isTabletLandscape ? 18 : 15,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F5B9E),
                              letterSpacing: 0.2,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Description
                          Text(
                            'Discover your estimated savings with rooftop solar using our interactive Solar Calculator.',
                            style: TextStyle(
                              fontSize: isTabletLandscape ? 16 : 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF475569),
                              height: 1.45,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // CTA Button & Playful Annotation
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 20,
                            runSpacing: 16,
                            children: [
                              // "CALCULATE MY SAVINGS ->" Button
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

                              // Playful handwritten callout
                              const DoodleCallout(),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Bottom info label
                    Row(
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
