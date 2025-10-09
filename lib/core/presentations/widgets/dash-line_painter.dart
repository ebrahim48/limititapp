import 'package:flutter/material.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textColor3D3D3D
      ..strokeWidth = 1;

    const dashWidth = 5;
    const dashSpace = 3;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
