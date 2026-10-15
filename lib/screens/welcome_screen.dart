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
          // 1. Right Side / Background Solar Rooftop Image with Smooth Gradient
          Positioned.fill(
            child: Row(
              children: [
                // Left spacing for text content
                Expanded(
                  flex: isTabletLandscape ? 45 : 0,
                  child: Container(color: Colors.white),
                ),
                // Right photo section
                Expanded(
                  flex: isTabletLandscape ? 55 : 100,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/solar_rooftop_hero.jpg',
                        fit: BoxFit.cover,
                        alignment: Alignment.centerRight,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback to hero_banner asset if generated image fails
                          return Image.asset(
                            'assets/images/hero_banner.png',
                            fit: BoxFit.cover,
                            alignment: Alignment.centerRight,
                          );
                        },
                      ),
                      // Smooth gradient overlay so text is 100% legible
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.white,
                              Colors.white.withValues(alpha: 0.85),
                              Colors.white.withValues(alpha: 0.15),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.25, 0.6, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Decorative Orange Wave at Bottom Right
          Positioned(
            right: 0,
            bottom: 0,
            width: size.width * 0.35,
            height: 120,
            child: CustomPaint(
              painter: _OrangeCornerWavePainter(),
            ),
          ),

          // 3. Foreground Content (Logo, Headlines, CTA, Annotation)
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isTabletLandscape ? 48.0 : 24.0,
                vertical: 24.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height - (MediaQuery.paddingOf(context).vertical + 48),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top: Websol Logo
                    const WebsolLogo(
                      fontSize: 32,
                      showTagline: true,
                    ),

                    const SizedBox(height: 36),

                    // Middle: Main Hero Message
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isTabletLandscape ? size.width * 0.58 : double.infinity,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Headline
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: isTabletLandscape ? 48 : 34,
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
                          ),

                          const SizedBox(height: 20),

                          // Subtitle
                          Text(
                            'Your Electricity Bill. Your Solar Potential. Your Savings.',
                            style: TextStyle(
                              fontSize: isTabletLandscape ? 19 : 16,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F5B9E),
                              letterSpacing: 0.3,
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

                          // CTA Button & Playful Callout
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 24,
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
                                    horizontal: 32,
                                    vertical: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Text(
                                      'CALCULATE MY SAVINGS',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 22,
                                    ),
                                  ],
                                ),
                              ),

                              // Playful handwritten-style callout
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
