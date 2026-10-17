import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/websol_logo.dart';
import 'solar_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;

  late final Animation<double> _cardScale;
  late final Animation<double> _cardOpacity;
  late final Animation<double> _logoSlide;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _statusOpacity;

  Timer? _navigationTimer;
  Timer? _statusTimer;
  String _statusText = 'Initializing Solar Engine...';

  @override
  void initState() {
    super.initState();

    // 1. Entrance animation (staggered)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _cardOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );

    _cardScale = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.1, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _logoSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _taglineOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.45, 0.85, curve: Curves.easeIn),
    );

    _statusOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.65, 1.0, curve: Curves.easeIn),
    );

    // 2. Ambient breathing sun energy aura
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _entranceController.forward();

    // Status step progression for modern tech feel
    _statusTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _statusText = 'Ready for Solar Estimates';
        });
      }
    });

    // Auto navigation to home tablet view
    _navigationTimer = Timer(const Duration(milliseconds: 2800), () {
      _navigateToHome();
    });
  }

  void _navigateToHome() {
    if (!mounted) return;
    _navigationTimer?.cancel();
    _statusTimer?.cancel();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SolarHomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _statusTimer?.cancel();
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.width >= 600;
    final logoSize = isTablet ? 72.0 : 46.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: InkWell(
        onTap: _navigateToHome, // Tap anytime to skip
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Stack(
          children: [
            // 1. Subtle High-Tech Solar Cell Grid Background
            Positioned.fill(
              child: CustomPaint(
                painter: _SolarGridBackgroundPainter(
                  pulse: _pulseController,
                ),
              ),
            ),

            // 2. Radiant Solar Aura Flare
            Center(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final glowScale = 0.85 + (_pulseController.value * 0.3);
                  return Transform.scale(
                    scale: glowScale,
                    child: Container(
                      width: isTablet ? 520 : 320,
                      height: isTablet ? 520 : 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFF36A21).withValues(alpha: 0.16),
                            const Color(0xFF0F5B9E).withValues(alpha: 0.06),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.45, 1.0],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 3. Center Modern Card with Animated Logo
            Center(
              child: FadeTransition(
                opacity: _cardOpacity,
                child: ScaleTransition(
                  scale: _cardScale,
                  child: Container(
                    width: isTablet ? 560 : size.width * 0.9,
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 48 : 24,
                      vertical: isTablet ? 48 : 36,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                          blurRadius: 40,
                          offset: const Offset(0, 16),
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: const Color(0xFFF36A21).withValues(alpha: 0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated Logo with subtle upward glide
                        AnimatedBuilder(
                          animation: _logoSlide,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _logoSlide.value),
                              child: child,
                            );
                          },
                          child: WebsolLogo(
                            fontSize: logoSize,
                            showTagline: false,
                            alignment: Alignment.center,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Modern Subtitle Badge
                        FadeTransition(
                          opacity: _taglineOpacity,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              "Solar Estimation Calculator",
                              style: TextStyle(
                                fontSize: isTablet ? 13 : 11.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F5B9E),
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Modern Glowing Progress Bar
                        SizedBox(
                          width: isTablet ? 220 : 160,
                          height: 4,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: AnimatedBuilder(
                              animation: _entranceController,
                              builder: (context, child) {
                                return LinearProgressIndicator(
                                  value: _entranceController.value,
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFFF36A21),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Micro-Status Pill with pulsing green beacon
                        FadeTransition(
                          opacity: _statusOpacity,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    return Container(
                                      width: 7,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF10B981),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF10B981).withValues(
                                              alpha: 0.3 + (_pulseController.value * 0.6),
                                            ),
                                            blurRadius: 6,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _statusText,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF64748B),
                                    letterSpacing: 0.3,
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
              ),
            ),

            // 4. Modern Bottom Tablet Metadata Strip
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: FadeTransition(
                opacity: _statusOpacity,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildFeatureTag(
                      icon: Icons.solar_power_rounded,
                      label: 'Solar Estimation Suite',
                    ),
                    _buildFeatureTag(
                      icon: Icons.table_chart_rounded,
                      label: 'Local CSV Export',
                    ),
                    _buildFeatureTag(
                      icon: Icons.tablet_rounded,
                      label: 'Tablet First',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTag({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for subtle modern solar wafer matrix grid
class _SolarGridBackgroundPainter extends CustomPainter {
  final Animation<double> pulse;

  _SolarGridBackgroundPainter({required this.pulse}) : super(repaint: pulse);

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF0F5B9E).withValues(alpha: 0.04)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const gridSize = 48.0;

    // Draw faint grid matrix
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // Subtle decorative solar circuit corner accents
    final accentPaint = Paint()
      ..color = const Color(0xFFF36A21).withValues(alpha: 0.08)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    // Top right solar node
    path.moveTo(size.width - 80, 20);
    path.lineTo(size.width - 20, 20);
    path.lineTo(size.width - 20, 80);

    // Bottom left solar node
    path.moveTo(20, size.height - 80);
    path.lineTo(20, size.height - 20);
    path.lineTo(80, size.height - 20);

    canvas.drawPath(path, accentPaint);

    // Subtle sun dots at intersections
    final dotPaint = Paint()
      ..color = const Color(0xFFF36A21).withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width - 20, 20), 3, dotPaint);
    canvas.drawCircle(Offset(20, size.height - 20), 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _SolarGridBackgroundPainter oldDelegate) => true;
}
