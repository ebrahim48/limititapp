import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';

class BackgroundBlurLayers extends StatelessWidget {
  const BackgroundBlurLayers({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(

          left: 109.w,
          child: Container(
            width: 259.w,
            height: 195.h,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
            width: 158.w,
            height: 219.h,
            decoration: BoxDecoration(
              color: AppColors.textColor803D20.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
      ],
    );
  }
}
