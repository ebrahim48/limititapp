import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_thumber.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';

class CustomScreenTimeSlider extends StatelessWidget {
  final int totalScreenTimeMinutes;

  const CustomScreenTimeSlider({
    super.key,
    required this.totalScreenTimeMinutes,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate slider value based on screen time (max 8 hours = 480 minutes)
    final double sliderValue =
        totalScreenTimeMinutes > 0
            ? (totalScreenTimeMinutes / 480).clamp(0.0, 1.0)
            : 0.0;

    // Format the screen time display
    String formattedTime;
    if (totalScreenTimeMinutes >= 60) {
      int hours = totalScreenTimeMinutes ~/ 60;
      int minutes = totalScreenTimeMinutes % 60;
      if (minutes == 0) {
        formattedTime = '$hours ${hours == 1 ? 'hr' : 'hrs'}';
      } else {
        formattedTime = '$hours ${hours == 1 ? 'hr' : 'hrs'} $minutes mins';
      }
    } else {
      formattedTime = '$totalScreenTimeMinutes mins';
    }

    return Container(
      width: 345.w,
      height: 100.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF888888), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                textAlign: TextAlign.start,
                text: context.l10n.screenTimeToday,
                fontsize: 13.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textColor3D3D3D,
              ),
              CustomText(
                textAlign: TextAlign.start,
                text: formattedTime,
                fontsize: 13.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textColor3D3D3D,
              ),
            ],
          ),
          SizedBox(height: 8.h),

          /// Custom Slider (disabled - display only)
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 8,
              activeTrackColor: AppColors.primaryColor4C956C,
              inactiveTrackColor: AppColors.textColor3D3D3D,
              overlayShape: SliderComponentShape.noOverlay,
              thumbShape: CustomCircleThumb(),
            ),
            child: Slider(
              value: sliderValue,
              onChanged: null, // Disabled - null makes it non-interactive
            ),
          ),
        ],
      ),
    );
  }
}
