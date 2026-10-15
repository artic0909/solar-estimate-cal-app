import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'widgets/tablet_scaffold.dart';

void main() {
  runApp(const SolarEstimateApp());
}

class SolarEstimateApp extends StatelessWidget {
  const SolarEstimateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solar Estimate Calculator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const TabletScaffold(),
    );
  }
}
