import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/models/appinfo_model.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';

class YourAppCard extends StatelessWidget {
  final AppInfo app;
  const YourAppCard({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 328.w,
      height: 80.h,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF888888), width: 1),
      ),
      child: Row(
        children: [

          Container(
            width: 48.w,
            height: 48.h,
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: SvgPicture.asset(
              app.icon,
              fit: BoxFit.contain,
            ),
          ),

          SizedBox(width: 12.w),

          // App Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(
                  text: app.name,
                  fontsize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor3D3D3D,
                ),
                CustomText(
                  text: app.usage,
                  fontsize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF5D5D5D),
                ),
              ],
            ),
          ),

          // Circular Progress
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 32.w,
                height: 32.h,
                child: CircularProgressIndicator(
                  value: 0.45,
                  backgroundColor: const Color(0xFF5D5D5D).withOpacity(0.4),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFDDA742)),
                  strokeWidth: 3,
                ),
              ),
              CustomText(
                text: app.percentage,
                fontsize: 8.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
