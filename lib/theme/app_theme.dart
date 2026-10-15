import 'package:flutter/material.dart';

class AppTheme {
  // Brand colors suitable for Solar Estimate Calculator
  static const Color primarySolar = Color(0xFFF59E0B); // Amber / Sun
  static const Color primaryDark = Color(0xFF0F172A);  // Deep slate navy
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color cardLight = Colors.white;

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primarySolar,
      primary: const Color(0xFFD97706),
      secondary: const Color(0xFF0284C7),
      surface: surfaceLight,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surfaceLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        iconTheme: IconThemeData(color: primaryDark),
        titleTextStyle: TextStyle(
          color: primaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.white,
        selectedIconTheme: const IconThemeData(color: Color(0xFFD97706), size: 26),
        unselectedIconTheme: IconThemeData(color: Colors.blueGrey.shade400, size: 24),
        selectedLabelTextStyle: const TextStyle(
          color: Color(0xFFD97706),
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: Colors.blueGrey.shade500,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        indicatorColor: const Color(0xFFFEF3C7),
      ),
      cardTheme: CardThemeData(
        color: cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.blueGrey.shade100, width: 1),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primarySolar,
      primary: primarySolar,
      surface: const Color(0xFF0F172A),
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF0B1120),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: Color(0xFF0F172A),
        indicatorColor: Color(0xFF78350F),
      ),
    );
  }
}
