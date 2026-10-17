import 'package:flutter/material.dart';

enum TopAlertType { success, error, warning, info }

/// Stub for TopAlert retained for API compatibility; all alert popups are disabled.
class TopAlert {
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    TopAlertType type = TopAlertType.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    // Disabled - no alerts
  }

  static void dismiss() {
    // Disabled - no alerts
  }
}
