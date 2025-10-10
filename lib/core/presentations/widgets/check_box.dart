import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CircularCheckbox extends StatelessWidget {
  final bool isSelected;
  const CircularCheckbox({super.key, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24.w,
      height: 24.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? const Color(0xFF4C956C) : Colors.transparent,
        border: Border.all(
          color: isSelected ? const Color(0xFF4C956C) : const Color(0xFFD1D1D1),
          width: 2,
        ),
      ),
    );
  }
}
