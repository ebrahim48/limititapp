import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/models/daily_usage.dart';
import 'package:limit_it_app/core/presentations/widgets/app_icon_widget.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/presentations/widgets/dash-line_painter.dart';
import 'package:limit_it_app/core/presentations/widgets/time_range_widget.dart';


class DailyUsageCard extends StatelessWidget {
  final List<DailyUsageApp> dailyApps;
  const DailyUsageCard({super.key, required this.dailyApps});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 328.w,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF888888), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: 'Daily Usage',
                fontsize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textColor3D3D3D,
              ),
              GestureDetector(
                onTap: () => showTimeRangeSelector(context),
                child: Row(
                  children: [
                    CustomText(
                      text: 'Today',
                      fontsize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF5D5D5D),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.keyboard_arrow_down, size: 20.r, color: const Color(0xFF5D5D5D)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildYAxisLabels(),
              SizedBox(width: 8.w),
              Expanded(
                child: Stack(
                  children: [
                    _buildDashedLines(),
                    _buildBars(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYAxisLabels() {
    return SizedBox(
      height: 130.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: ['10 hr', '8 hr', '6 hr', '2 hr', '0 hr']
            .map((label) => SizedBox(
          height: 16.h,
          child: CustomText(
            text: label,
            fontsize: 10.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textColor3D3D3D,
          ),
        ))
            .toList(),
      ),
    );
  }

  Widget _buildDashedLines() {
    return Positioned.fill(
      top: 0,
      bottom: 27,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          5,
              (index) => CustomPaint(size: Size(double.infinity, 1), painter: DashedLinePainter()),
        ),
      ),
    );
  }

  Widget _buildBars() {
    return
      SizedBox(
        height: 153.h,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: dailyApps.map((app) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 40.w,
                  height: app.height * 10.h,
                  decoration: BoxDecoration(
                    color: app.color,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
                  ),
                  alignment: Alignment.center,
                  child: CustomText(
                    text: app.percentage,
                    fontsize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColorF6F6F6,
                  ),
                ),
                SizedBox(height: 8.h),
                SvgPicture.asset(
                  app.icon,
                  width: 24.w,
                  height: 24.h,
                ),
              ],
            );
          }).toList(),
        ),
      );

  }
}
