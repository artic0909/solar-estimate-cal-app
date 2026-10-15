import 'package:flutter/material.dart';

class DoodleCallout extends StatelessWidget {
  const DoodleCallout({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Text with doodle burst
        Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 18.0, top: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Think you know',
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F5B9E),
                      height: 1.15,
                    ),
                  ),
                  Text(
                    'your solar savings?',
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F5B9E),
                      height: 1.15,
                    ),
                  ),
                  Text(
                    "Let's calculate!",
                    style: TextStyle(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F5B9E),
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            // Playful burst rays at top right
            Positioned(
              right: 0,
              top: 0,
              child: CustomPaint(
                size: const Size(16, 16),
                painter: _SunburstRaysPainter(),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // Curved arrow pointing left towards the CTA button
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: CustomPaint(
            size: const Size(60, 26),
            painter: _CurvedArrowPainter(),
          ),
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
    // Curves from right down and loops left
    path.moveTo(size.width * 0.75, 2);
    path.quadraticBezierTo(
      size.width * 0.45,
      size.height * 0.85,
      4,
      size.height * 0.5,
    );

    canvas.drawPath(path, paint);

    // Arrowhead pointing towards left/button
    final arrowPath = Path();
    arrowPath.moveTo(2, size.height * 0.5);
    arrowPath.lineTo(12, size.height * 0.15);
    arrowPath.moveTo(2, size.height * 0.5);
    arrowPath.lineTo(10, size.height * 0.9);

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

    // 3 small celebratory burst rays
    canvas.drawLine(const Offset(3, 14), const Offset(0, 7), paint);
    canvas.drawLine(const Offset(8, 14), const Offset(8, 4), paint);
    canvas.drawLine(const Offset(13, 13), const Offset(16, 7), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
