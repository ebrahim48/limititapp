import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_thumber.dart';


class CustomSoundSlider extends StatefulWidget {
  const CustomSoundSlider({super.key});

  @override
  State<CustomSoundSlider> createState() => _CustomSoundSliderState();
}

class _CustomSoundSliderState extends State<CustomSoundSlider> {
  double soundVolume = 0.83;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(text:
            "Min",
              fontsize: 13.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textColor3D3D3D,

            ),
            CustomText(text:
            "${(soundVolume * 120).round()} min",
              fontsize: 13.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textColor3D3D3D,
            ),
          ],
        ),
        const SizedBox(height: 8),

        /// Custom Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 12,
            trackShape: const RoundedRectSliderTrackShape(),
            activeTrackColor: AppColors.primaryColor4C956C,
            inactiveTrackColor: AppColors.textColor3D3D3D,
            overlayShape: SliderComponentShape.noOverlay,
            thumbShape:  CustomCircleThumb(),
          ),
          child: Slider(
            value: soundVolume,
            onChanged: (val) {
              setState(() => soundVolume = val);
            },
          ),
        ),
      ],
    );
  }
}