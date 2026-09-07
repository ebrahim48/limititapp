import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/presentations/screens/limits/limit_screen_time.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_delete_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/services/app_usage_service.dart';
import 'package:limit_it_app/core/presentations/widgets/app_icon_widget.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';

class LimitScreenTimeCard extends StatelessWidget {
  final AppLimitWithUsage data;
  final VoidCallback onDelete;

  const LimitScreenTimeCard({
    super.key,
    required this.data,
    required this.onDelete,
  });

  String _getUsageString() {
    if (data.usageData == null) {
      return '0 mins • 0/${data.limit.maxDailyOpens} Opens';
    }

    final usageTime = AppUsageService.instance.formatUsageTime(
      data.usageData!.usageTimeMs,
    );
    final openCount = data.usageData!.openCount;
    final maxOpens = data.limit.maxDailyOpens;

    return '$usageTime • $openCount/$maxOpens Opens';
  }

  String _getPercentageString() {
    if (data.usageData == null || data.limit.maxSessionDurationMinutes == 0) {
      return '0%';
    }

    // Calculate percentage based on session duration limit
    final usageMinutes = data.usageData!.usageTimeMs / (1000 * 60);
    final percentage = (usageMinutes / data.limit.maxSessionDurationMinutes) * 100;

    return '${percentage.clamp(0, 100).toStringAsFixed(0)}%';
  }

  String _getLimitInfoString() {
    final sessionLimit = data.limit.maxSessionDurationMinutes;
    final openLimit = data.limit.maxDailyOpens;

    String sessionStr = sessionLimit < 60
        ? '$sessionLimit mins'
        : '${(sessionLimit / 60).toStringAsFixed(1)} hrs';

    return 'Limit: $sessionStr • $openLimit opens';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 345.w,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF888888), width: 1),
      ),
      child: Row(
        children: [
          // App Icon
          AppIconWidget(
            packageName: data.usageData?.packageName ?? '',
            appName: data.usageData?.name,
            preloadedIcon: data.usageData?.icon,
            size: 48,
            borderRadius: 12,
          ),

          SizedBox(width: 12.w),

          // App Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(
                  text: data.limit.appName,
                  fontsize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor3D3D3D,
                ),
                SizedBox(height: 2.h),
                CustomText(
                  text: _getUsageString(),
                  fontsize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF5D5D5D),
                ),
                SizedBox(height: 2.h),
                CustomText(
                  text: _getLimitInfoString(),
                  fontsize: 11.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF888888),
                ),
              ],
            ),
          ),

          // Percentage (optional, if you want to show it)
          Container(
            margin: EdgeInsets.only(right: 8.w),
            child: CustomText(
              text: _getPercentageString(),
              fontsize: 14.sp,
              fontWeight: FontWeight.w600,
              color: _getPercentageColor(),
            ),
          ),

          // More Options Menu
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            iconSize: 24.w,
            icon: Assets.icons.moreVert.svg(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            onSelected: (value) {
              if (value == 'edit') {
                context.pushNamed(
                  AppRoutes.editUsageLimitScreen,
                  extra: {'packageName': data.limit.packageName},
                );
              } else if (value == 'delete') {
                _showDeleteConfirmationDialog(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit, color: Colors.black54, size: 18),
                    SizedBox(width: 8.w),
                    const Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: Colors.redAccent, size: 18),
                    SizedBox(width: 8.w),
                    const Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPercentageColor() {
    if (data.usageData == null || data.limit.maxSessionDurationMinutes == 0) {
      return Colors.green;
    }

    final usageMinutes = data.usageData!.usageTimeMs / (1000 * 60);
    final percentage = (usageMinutes / data.limit.maxSessionDurationMinutes) * 100;

    if (percentage >= 90) {
      return Colors.red;
    } else if (percentage >= 70) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          backgroundColor: AppColors.textColorFFFFFF,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 40.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomText(
                  text: 'Remove Screen Time\nLimit?',
                  fontsize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor3D3D3D,
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CustomDeleteTwoButton(
                        title: 'Cancel',
                        bgColor: AppColors.textColorE7E7E7,
                        textColor: AppColors.textColor3D3D3D,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: CustomDeleteTwoButton(
                        title: 'Delete',
                        bgColor: AppColors.textColorA70D0D,
                        textColor: AppColors.textColorFFFFFF,
                        onTap: () {
                          Navigator.pop(context);
                          onDelete();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
