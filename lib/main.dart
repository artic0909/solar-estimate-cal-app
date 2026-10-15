import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'providers/solar_calculator_provider.dart';

void main() {
  runApp(const SolarEstimateApp());
}

class SolarEstimateApp extends StatelessWidget {
  const SolarEstimateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SolarCalculatorProvider(),
      child: MaterialApp(
        title: 'Websole Calculator',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const SplashScreen(),
      ),
    );
  }
}
