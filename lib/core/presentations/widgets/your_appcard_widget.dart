import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/models/appinfo_model.dart';
import 'package:limit_it_app/core/presentations/widgets/app_icon_widget.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/services/app_usage_service.dart';
import 'package:limit_it_app/core/services/blocked_apps_service.dart';
import 'package:limit_it_app/core/services/app_blocker_service.dart';
import 'package:limit_it_app/core/presentations/screens/permissions/permissions_setup_screen.dart';

class YourAppCard extends StatefulWidget {
  final AppInfo? app;
  final AppUsageData? appData;
  final bool showBlockButton; // New parameter to control block button visibility

  const YourAppCard({
    super.key,
    this.app,
    this.appData,
    this.showBlockButton = true, // Default to true for backward compatibility
  }) : assert(app != null || appData != null, 'Either app or appData must be provided');

  @override
  State<YourAppCard> createState() => _YourAppCardState();
}

class _YourAppCardState extends State<YourAppCard> {
  bool _isBlocked = false;

  @override
  void initState() {
    super.initState();
    _loadBlockedState();
  }

  /// Load the blocked state from storage
  Future<void> _loadBlockedState() async {
    final blockedAppsService = Get.find<BlockedAppsService>();
    // Always use appData's package name if available (it has the real package name)
    // If using app (dummy data), we can't block reliably without package name
    final String packageName = widget.appData?.packageName ?? '';
    
    if (packageName.isNotEmpty) {
      final bool isBlocked = await blockedAppsService.isAppBlocked(packageName);

      if (mounted) {
        setState(() {
          _isBlocked = isBlocked;
        });
      }
    }
  }

  /// Check and ensure monitoring is active before blocking
  /// Returns true if monitoring is ready, false otherwise
  Future<bool> _ensureMonitoringActive() async {
    final appBlockerService = Get.find<AppBlockerService>();

    // Check if monitoring service is already running
    final isMonitoring = await appBlockerService.isMonitoringActive();
    if (isMonitoring) {
      return true; // All good, monitoring is active
    }

    // Monitoring is not active, check if permissions are granted
    final hasAllPermissions = await appBlockerService.hasAllPermissions();

    if (!hasAllPermissions) {
      // Permissions are missing, show dialog to navigate to permissions screen
      if (mounted) {
        _showPermissionsRequiredDialog();
      }
      return false;
    }

    // Permissions are granted but service isn't running, start it
    if (mounted) {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Starting monitoring service...'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    final started = await appBlockerService.startMonitoring();
    if (!started) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to start monitoring service'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }

    // Wait a moment for service to fully initialize
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  /// Show dialog explaining permissions are required
  void _showPermissionsRequiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permissions Required'),
          content: const Text(
            'To block apps, you need to grant Overlay and Accessibility permissions. '
            'Would you like to go to the permissions setup screen?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to permissions screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PermissionsSetupScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF214432),
              ),
              child: const Text('Grant Permissions', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  /// Toggle block state
  Future<void> _toggleBlock() async {
    final String appName = widget.appData?.name ?? widget.app!.name;
    // Always use appData's package name (it has the real package name)
    // If appData is null, we can't block reliably
    final String packageName = widget.appData?.packageName ?? '';
    
    // If no package name available (using dummy data), show message and return
    if (packageName.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This app cannot be blocked. Please use real app data.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // If trying to block an app, ensure monitoring is active first
    if (!_isBlocked) {
      final monitoringReady = await _ensureMonitoringActive();
      if (!monitoringReady) {
        // Monitoring couldn't be started, abort the block operation
        return;
      }
    }

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
      final usageMinutes = (widget.appData!.usageTimeMs / (1000 * 60)).round();
      usage = '$usageMinutes mins • ${widget.appData!.openCount} Opens';
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
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            tween: Tween(begin: 0.0, end: progressValue),
            builder: (context, value, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 32.w,
                    height: 32.h,
                    child: CircularProgressIndicator(
                      value: value,
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
              );
            },
          ),

          SizedBox(width: 8.w),

          // Block button (only show if showBlockButton is true)
          if (widget.showBlockButton)
            GestureDetector(
              onTap: _toggleBlock,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: _isBlocked ? const Color(0xFFFF5252) : const Color(0xFF214432),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: child,
                    );
                  },
                  child: Icon(
                    _isBlocked ? Icons.lock_open : Icons.block,
                    key: ValueKey(_isBlocked),
                    color: Colors.white,
                    size: 18.sp,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Build app icon widget
  Widget _buildAppIcon() {
    if (widget.appData != null) {
      return AppIconWidget(
        packageName: widget.appData!.packageName,
        preloadedIcon: widget.appData!.icon,
        size: 48,
        borderRadius: 12,
      );
    }

    if (widget.app?.appIconBytes != null) {
      return AppIconWidget(
        packageName: '',
        preloadedIcon: widget.app!.appIconBytes,
        size: 48,
        borderRadius: 12,
      );
    }

    if (widget.app?.icon != null && widget.app!.icon.isNotEmpty) {
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

    return AppIconWidget(packageName: '', size: 48, borderRadius: 12);
  }
}
