import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/models/appinfo_model.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/services/app_usage_service.dart';
import 'package:limit_it_app/core/services/blocked_apps_service.dart';
import 'package:limit_it_app/core/services/app_blocker_service.dart';

class YourAppCard extends StatefulWidget {
  final AppInfo? app;
  final AppUsageData? appData;

  const YourAppCard({super.key, this.app, this.appData})
      : assert(app != null || appData != null, 'Either app or appData must be provided');

  @override
  State<YourAppCard> createState() => _YourAppCardState();
}

class _YourAppCardState extends State<YourAppCard> {
  bool _isBlocked = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBlockedState();
  }

  /// Load the blocked state from storage
  Future<void> _loadBlockedState() async {
    final blockedAppsService = Get.find<BlockedAppsService>();
    final String packageName = widget.appData?.packageName ?? widget.app!.name.toLowerCase();
    final bool isBlocked = await blockedAppsService.isAppBlocked(packageName);

    if (mounted) {
      setState(() {
        _isBlocked = isBlocked;
        _isLoading = false;
      });
    }
  }

  /// Toggle block state
  Future<void> _toggleBlock() async {
    final String appName = widget.appData?.name ?? widget.app!.name;
    final String packageName = widget.appData?.packageName ?? widget.app!.name.toLowerCase();

    // Store previous state for undo
    final bool previousState = _isBlocked;

    // Update UI immediately for better UX
    setState(() {
      _isBlocked = !_isBlocked;
    });

    // Persist the change
    final blockedAppsService = Get.find<BlockedAppsService>();
    bool success;
    if (_isBlocked) {
      success = await blockedAppsService.blockApp(packageName, appName);
    } else {
      success = await blockedAppsService.unblockApp(packageName);
    }

    if (!success) {
      // Revert on failure
      if (mounted) {
        setState(() {
          _isBlocked = previousState;
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${_isBlocked ? 'block' : 'unblock'} $appName'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Update native monitoring service with new blocked apps list
    final appBlockerService = Get.find<AppBlockerService>();
    final blockedPackages = await blockedAppsService.getBlockedPackageNames();
    await appBlockerService.updateBlockedApps(blockedPackages);

    // Show confirmation message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isBlocked ? '$appName is now blocked' : '$appName is now unblocked',
          ),
          backgroundColor: _isBlocked ? const Color(0xFFFF5252) : const Color(0xFF214432),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Undo',
            textColor: Colors.white,
            onPressed: () async {
              // Undo the action
              if (_isBlocked) {
                await blockedAppsService.unblockApp(packageName);
              } else {
                await blockedAppsService.blockApp(packageName, appName);
              }
              final updatedPackages = await blockedAppsService.getBlockedPackageNames();
              await appBlockerService.updateBlockedApps(updatedPackages);

              if (mounted) {
                setState(() {
                  _isBlocked = !_isBlocked;
                });
              }
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get display values based on which data is available
    final String name = widget.appData?.name ?? widget.app!.name;

    // Build usage string with open count
    String usage;
    if (widget.appData != null) {
      usage = "${widget.appData!.usageString} • ${widget.appData!.openCount} Opens";
    } else {
      usage = widget.app!.usage;
    }

    final String percentage = widget.appData?.percentageString ?? widget.app!.percentage;
    final double progressValue = widget.appData != null
        ? (widget.appData!.percentage / 100).clamp(0.0, 1.0)
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

          SizedBox(width: 8.w),

          // Block button
          GestureDetector(
            onTap: _toggleBlock,
            child: Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: _isBlocked ? const Color(0xFFFF5252) : const Color(0xFF214432),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                _isBlocked ? Icons.lock_open : Icons.block,
                color: Colors.white,
                size: 18.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build app icon widget
  Widget _buildAppIcon() {
    // If we have actual app data with icon bytes, show it
    if (widget.appData?.icon != null) {
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
            widget.appData!.icon!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultIcon();
            },
          ),
        ),
      );
    }

    // Fallback to SVG icon if available
    if (widget.app?.icon != null) {
      return Container(
        width: 48.w,
        height: 48.h,
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: SvgPicture.asset(widget.app!.icon, fit: BoxFit.contain),
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
