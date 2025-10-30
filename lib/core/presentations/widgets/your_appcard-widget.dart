import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/models/appinfo_model.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/services/app_usage_service.dart';

class YourAppCard extends StatelessWidget {
  final AppInfo? app;
  final AppUsageData? appData;

  const YourAppCard({super.key, this.app, this.appData})
      : assert(app != null || appData != null, 'Either app or appData must be provided');

  @override
  Widget build(BuildContext context) {
    // Get display values based on which data is available
    final String name = appData?.name ?? app!.name;

    // Build usage string with open count
    String usage;
    if (appData != null) {
      usage = "${appData!.usageString} • ${appData!.openCount} Opens";
    } else {
      usage = app!.usage;
    }

    final String percentage = appData?.percentageString ?? app!.percentage;
    final double progressValue = appData != null
        ? (appData!.percentage / 100).clamp(0.0, 1.0)
        : 0.45;

    return Container(
      width: 345.w,
      height: 80.h,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF888888), width: 1),
      ),
      child: Row(
        children: [
          // App Icon
          _buildAppIcon(),

          SizedBox(width: 12.w),

          // App Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(
                  text: name,
                  fontsize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor3D3D3D,
                ),
                CustomText(
                  text: usage,
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
                  value: progressValue,
                  backgroundColor: const Color(0xFF5D5D5D).withValues(alpha: 0.4),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFDDA742)),
                  strokeWidth: 3,
                ),
              ),
              CustomText(
                text: percentage,
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

  /// Build app icon widget
  Widget _buildAppIcon() {
    // If we have actual app data with icon bytes, show it
    if (appData?.icon != null) {
      return Container(
        width: 48.w,
        height: 48.h,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Image.memory(
            appData!.icon!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultIcon();
            },
          ),
        ),
      );
    }

    // Fallback to SVG icon if available
    if (app?.icon != null) {
      return Container(
        width: 48.w,
        height: 48.h,
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: SvgPicture.asset(app!.icon, fit: BoxFit.contain),
      );
    }

    // Default icon
    return _buildDefaultIcon();
  }

  /// Build default icon for apps without icons
  Widget _buildDefaultIcon() {
    return Container(
      width: 48.w,
      height: 48.h,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade200,
      ),
      child: Icon(
        Icons.apps,
        color: Colors.grey.shade600,
        size: 24.sp,
      ),
    );
  }
}
