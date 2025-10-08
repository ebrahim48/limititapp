
import 'package:flutter/material.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';

class CustomCircleThumb extends SliderComponentShape {
   CustomCircleThumb();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(24, 24);
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final Canvas canvas = context.canvas;

    // Outer Orange Circle
    final Paint outerPaint = Paint()..color = AppColors.primaryColor4C956C;
    canvas.drawCircle(center, 12, outerPaint);

    // Inner Blue Circle
    final Paint innerPaint = Paint()..color = AppColors.primaryColor4C956C;
    canvas.drawCircle(center, 8, innerPaint);
  }
}