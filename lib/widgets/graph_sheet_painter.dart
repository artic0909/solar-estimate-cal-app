import 'package:flutter/material.dart';

/// Painter for modern engineering / blueprint graph sheet lines
class GraphSheetPainter extends CustomPainter {
  const GraphSheetPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const majorGridSize = 40.0;
    const minorGridSize = 10.0;

    // 1. Minor grid lines (ultra-subtle)
    final minorPaint = Paint()
      ..color = const Color(0xFF0F5B9E).withValues(alpha: 0.025)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;

    for (double x = 0; x <= size.width; x += minorGridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), minorPaint);
    }
    for (double y = 0; y <= size.height; y += minorGridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), minorPaint);
    }

    // 2. Major grid lines
    final majorPaint = Paint()
      ..color = const Color(0xFF0F5B9E).withValues(alpha: 0.06)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (double x = 0; x <= size.width; x += majorGridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), majorPaint);
    }
    for (double y = 0; y <= size.height; y += majorGridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), majorPaint);
    }

    // 3. Technical crosshair '+' accents at every 80px
    final crossPaint = Paint()
      ..color = const Color(0xFFF36A21).withValues(alpha: 0.18)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const crosshairStep = 80.0;
    const crossSize = 3.5;

    for (double x = crosshairStep; x < size.width; x += crosshairStep) {
      for (double y = crosshairStep; y < size.height; y += crosshairStep) {
        canvas.drawLine(
          Offset(x - crossSize, y),
          Offset(x + crossSize, y),
          crossPaint,
        );
        canvas.drawLine(
          Offset(x, y - crossSize),
          Offset(x, y + crossSize),
          crossPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
