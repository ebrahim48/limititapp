import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:limit_it_app/core/constants/app_strings.dart';
import 'dart:ui';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import '../../../../global/custom_assets/assets.gen.dart';
import '../../../constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 18.h,
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
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
          ),

          Container(
            width: 158.w,
            height: 219.h,
            decoration: BoxDecoration(
              color: AppColors.textColor803D20.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Assets.images.splash.image(
                      width: 63.w,
                      height: 63.h,
                    ),
                    SizedBox(width: 4.w),
                    CustomText(
                      text: AppString.limitIt,
                      fontsize: 48.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}