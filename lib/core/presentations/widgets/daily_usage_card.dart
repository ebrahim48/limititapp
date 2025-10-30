import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/models/daily_usage.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/presentations/widgets/dash-line_painter.dart';
import 'package:limit_it_app/core/presentations/widgets/time_range_widget.dart';
import 'package:limit_it_app/core/services/app_usage_service.dart';
import 'package:flutter/foundation.dart';

class DailyUsageCard extends StatelessWidget {
  final List<DailyUsageApp> dailyApps;
  final List<AppUsageData>? appUsageData; // Real usage data for icons
  final bool isLoading;

  const DailyUsageCard({
    super.key,
    required this.dailyApps,
    this.appUsageData,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 345.w,
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
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 20.r,
                      color: const Color(0xFF5D5D5D),
                    ),
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
                child: Stack(children: [_buildDashedLines(), _buildBars()]),
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
        children:
            ['10 hr', '8 hr', '6 hr', '2 hr', '0 hr']
                .map(
                  (label) => SizedBox(
                    height: 16.h,
                    child: CustomText(
                      text: label,
                      fontsize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textColor3D3D3D,
                    ),
                  ),
                )
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
          (index) => CustomPaint(
            size: Size(double.infinity, 1),
            painter: DashedLinePainter(),
          ),
        ),
      ),
    );
  }

  Widget _buildBars() {
    if (isLoading) {
      return SizedBox(
        height: 153.h,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(5, (index) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 40.w,
                  height: (5 + (index * 2)).h * 8,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(4.r),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: 24.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
              ],
            );
          }),
        ),
      );
    }

    return SizedBox(
      height: 153.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:
            dailyApps.asMap().entries.map((entry) {
              final index = entry.key;
              final app = entry.value;

              // Get real app icon if available
              Uint8List? realIcon;
              if (appUsageData != null && index < appUsageData!.length) {
                realIcon = appUsageData![index].icon;
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 40.w,
                    height: app.height * 10.h,
                    decoration: BoxDecoration(
                      color: app.color,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(4.r),
                      ),
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
                  // Display real icon or fallback to placeholder
                  _buildAppIcon(realIcon, app.icon, app.name),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget _buildAppIcon(Uint8List? realIcon, String svgPath, String appName) {
    if (realIcon != null) {
      // Display real app icon from bytes
      return ClipRRect(
        borderRadius: BorderRadius.circular(6.r),
        child: Image.memory(
          realIcon,
          width: 24.w,
          height: 24.h,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderIcon(appName);
          },
        ),
      );
    } else if (svgPath.isNotEmpty) {
      // Display SVG icon
      return SvgPicture.asset(svgPath, width: 24.w, height: 24.h);
    } else {
      // Display placeholder
      return _buildPlaceholderIcon(appName);
    }
  }

  Widget _buildPlaceholderIcon(String appName) {
    return Container(
      width: 24.w,
      height: 24.h,
      decoration: BoxDecoration(
        color: const Color(0xFF5D5D5D),
        borderRadius: BorderRadius.circular(6.r),
      ),
      alignment: Alignment.center,
      child: CustomText(
        text: appName.isNotEmpty ? appName[0].toUpperCase() : '?',
        fontsize: 12.sp,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }
}
