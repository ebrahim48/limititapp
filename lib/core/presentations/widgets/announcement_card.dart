import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 328.w,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFEDD69A),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Assets.images.banner.image(
              width: 80.w,
              height: 80.h,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  textAlign: TextAlign.start,
                  text: 'Big Announce for Figma\nmake',
                  fontsize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor3D3D3D,
                  maxline: 2,
                ),
                SizedBox(height: 4.h),
                CustomText(
                  textAlign: TextAlign.start,
                  text: 'Stay focused, take control\nof your time',
                  fontsize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF5D5D5D),
                  maxline: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
