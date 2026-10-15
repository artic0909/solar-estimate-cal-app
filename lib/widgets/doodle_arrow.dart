import 'package:flutter/material.dart';

class DoodleCallout extends StatelessWidget {
  const DoodleCallout({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Curved arrow pointing towards the CTA button
        CustomPaint(
          size: const Size(42, 28),
          painter: _CurvedArrowPainter(),
        ),
        const SizedBox(width: 8),
        // Hand-styled annotation text
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Think you know',
                  style: TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F5B9E),
                    height: 1.1,
                  ),
                ),
                const SizedBox(width: 4),
                // Small doodle burst rays
                CustomPaint(
                  size: const Size(12, 12),
                  painter: _SunburstRaysPainter(),
                ),
              ],
            ),
            Text(
              'your solar savings?',
              style: TextStyle(
                fontSize: 15,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F5B9E),
                height: 1.15,
              ),
            ),
            Text(
              "Let's calculate!",
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F5B9E),
                height: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CurvedArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0F5B9E)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    // Starts from right (near text) curving down and pointing left towards button
    path.moveTo(size.width, 4);
    path.quadraticBezierTo(
      size.width * 0.45,
      2,
      size.width * 0.25,
      size.height * 0.55,
    );
    path.quadraticBezierTo(
      size.width * 0.1,
      size.height * 0.9,
      0,
      size.height * 0.7,
    );

    canvas.drawPath(path, paint);

    // Arrowhead pointing left
    final arrowPath = Path();
    arrowPath.moveTo(0, size.height * 0.7);
    arrowPath.lineTo(8, size.height * 0.45);
    arrowPath.moveTo(0, size.height * 0.7);
    arrowPath.lineTo(8, size.height * 0.92);

    canvas.drawPath(arrowPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SunburstRaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF36A21)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    // Small decorative rays
    canvas.drawLine(const Offset(2, 10), const Offset(0, 4), paint);
    canvas.drawLine(const Offset(6, 11), const Offset(6, 2), paint);
    canvas.drawLine(const Offset(10, 10), const Offset(12, 5), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
