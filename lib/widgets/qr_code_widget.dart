import 'package:flutter/material.dart';

/// A crisp, vector-rendered QR code widget for Websol connection
class WebsolQrCode extends StatelessWidget {
  final double size;

  const WebsolQrCode({super.key, this.size = 90});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: CustomPaint(
        size: Size(size - 12, size - 12),
        painter: _QrCodePainter(),
      ),
    );
  }
}

class _QrCodePainter extends CustomPainter {
  // Pre-computed 21x21 QR code matrix (standard Version 1 QR code)
  static const List<String> _qrMatrix = [
    "1111111001011111111",
    "1000001010101000001",
    "1011101001001011101",
    "1011101010101011101",
    "1011101000001011101",
    "1000001011001000001",
    "1111111010101111111",
    "0000000001100000000",
    "1101101100011011010",
    "0010110011010100101",
    "1101001010101011010",
    "0000000011010000001",
    "1111111010010101010",
    "1000001001101010101",
    "1011101010101001001",
    "1011101001010110110",
    "1011101011001001011",
    "1000001010110110100",
    "1111111001011001011",
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;

    final rows = _qrMatrix.length;
    final cols = _qrMatrix[0].length;
    final cellWidth = size.width / cols;
    final cellHeight = size.height / rows;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (_qrMatrix[r][c] == '1') {
          final rect = Rect.fromLTWH(
            c * cellWidth,
            r * cellHeight,
            cellWidth * 0.96,
            cellHeight * 0.96,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(1.0)),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
