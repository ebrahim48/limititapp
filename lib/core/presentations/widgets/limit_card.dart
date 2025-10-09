import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/models/limit_option_model.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';

class LimitCard extends StatelessWidget {
  final LimitOption option;
  final VoidCallback? onTap;

  const LimitCard({
    super.key,
    required this.option,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 156.w,
        height: 85.h,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFD1D1D1), width: 1),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  option.icon.svg(
                    width: 32.w,
                    height: 32.h,
                    color: AppColors.textColor3D3D3D,
                  ),
                  SizedBox(height: 2.h),
                  CustomText(
                    textAlign: TextAlign.center,
                    text: option.title,
                    fontsize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textColor3D3D3D,
                  ),
                ],
              ),
            ),

            /// Pro badge
            if (option.isPro)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF214432),
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  child: CustomText(
                    text: 'pro',
                    fontsize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
