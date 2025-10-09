import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_thumber.dart';

class CustomScreenTimeSlider extends StatefulWidget {
  const CustomScreenTimeSlider({super.key});

  @override
  State<CustomScreenTimeSlider> createState() => _CustomScreenTimeSliderState();
}

class _CustomScreenTimeSliderState extends State<CustomScreenTimeSlider> {
  double soundVolume = 0.83;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 328.w,
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
                text: "Screen time Today",
                fontsize: 13.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textColor3D3D3D,
              ),
              CustomText(
                textAlign: TextAlign.start,
                text: "${(soundVolume * 120).round()} Mins",
                fontsize: 13.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textColor3D3D3D,
              ),
            ],
          ),
          SizedBox(height: 8.h),

          /// Custom Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 8.h,
              trackShape: const RoundedRectSliderTrackShape(),
              activeTrackColor: AppColors.primaryColor4C956C,
              inactiveTrackColor: AppColors.textColor3D3D3D,
              overlayShape: SliderComponentShape.noOverlay,
              thumbShape: CustomCircleThumb(),
            ),
            child: Slider(
              value: soundVolume,
              onChanged: (val) {
                setState(() => soundVolume = val);
              },
            ),
          ),
        ],
      ),
    );
  }
}
