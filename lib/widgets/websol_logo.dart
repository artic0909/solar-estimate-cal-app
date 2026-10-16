import 'package:flutter/material.dart';

class WebsolLogo extends StatelessWidget {
  final double fontSize;
  final bool showTagline;
  final bool useImage;
  final bool isDark;

  const WebsolLogo({
    super.key,
    this.fontSize = 52,
    this.showTagline = true,
    this.useImage = false,
    this.isDark = false,
  });

  static const Color orangePrimary = Color(0xFFF36A21);
  static const Color orangeAccent = Color(0xFFFF7A00);
  static const Color blueTagline = Color(0xFF0F5B9E);

  @override
  Widget build(BuildContext context) {
    if (useImage) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/websol_logo.png',
            width: fontSize * 5.2,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => _buildModernLogo(),
          ),
        ],
      );
    }

    return _buildModernLogo();
  }

  Widget _buildModernLogo() {
    final titleStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      color: orangePrimary,
      letterSpacing: 2.0,
      height: 1.0,
      fontFamily: 'sans-serif',
      shadows: [
        Shadow(
          color: orangePrimary.withValues(alpha: 0.25),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('WEBSOL', style: titleStyle),
        if (showTagline) ...[
          SizedBox(height: fontSize * 0.14),
          Text(
            "Powering Tomorrow's Energy",
            style: TextStyle(
              fontSize: fontSize * 0.28,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFF60A5FA) : blueTagline,
              letterSpacing: 0.8,
              fontFamily: 'sans-serif',
            ),
          ),
        ],
      ],
    );
  }
}
