import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/services/app_blocker_service.dart';
import 'package:limit_it_app/core/services/app_limit_storage_service.dart';

class PermissionsSetupScreen extends StatefulWidget {
  const PermissionsSetupScreen({super.key});

  @override
  State<PermissionsSetupScreen> createState() => _PermissionsSetupScreenState();
}

class _PermissionsSetupScreenState extends State<PermissionsSetupScreen> with WidgetsBindingObserver {
  bool _hasOverlayPermission = false;
  bool _hasAccessibilityPermission = false;
  bool _isChecking = true;
  bool _isStartingMonitoring = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-check permissions when user returns to app
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    setState(() => _isChecking = true);

    final appBlockerService = Get.find<AppBlockerService>();
    final permissions = await appBlockerService.checkAllPermissions();

    setState(() {
      _hasOverlayPermission = permissions['overlay'] ?? false;
      _hasAccessibilityPermission = permissions['accessibility'] ?? false;
      _isChecking = false;
    });
  }

  Future<void> _requestOverlayPermission() async {
    final appBlockerService = Get.find<AppBlockerService>();
    await appBlockerService.requestOverlayPermission();
    // Permission check will happen automatically when user returns
  }

  Future<void> _requestAccessibilityPermission() async {
    final appBlockerService = Get.find<AppBlockerService>();
    await appBlockerService.requestAccessibilityPermission();
    // Permission check will happen automatically when user returns
  }

  Future<void> _startMonitoringAndFinish() async {
    setState(() => _isStartingMonitoring = true);

    // Check if we have saved app limits
    final appLimitStorageService = Get.find<AppLimitStorageService>();
    final appLimits = await appLimitStorageService.getAppLimits();

    if (appLimits.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No app limits configured. Please set up app limits first.'),
          backgroundColor: Colors.orange,
        ),
      );
      setState(() => _isStartingMonitoring = false);
      return;
    }

    // Start monitoring service
    final appBlockerService = Get.find<AppBlockerService>();
    final started = await appBlockerService.startMonitoring();

    if (!mounted) return;

    if (started) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('App monitoring started successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back or to home
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to start monitoring. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isStartingMonitoring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool allPermissionsGranted = _hasOverlayPermission && _hasAccessibilityPermission;

    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: 'Setup Permissions',
          fontsize: 20.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textColor3D3D3D,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              CustomText(
                text: 'Grant Required Permissions',
                fontsize: 24.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor2C2C2C,
              ),
              SizedBox(height: 12.h),
              CustomText(
                text: 'LimitIt needs these permissions to monitor and block apps when limits are reached.',
                fontsize: 14.sp,
                color: const Color(0xFF5D5D5D),
                maxline: 3,
              ),
              SizedBox(height: 32.h),

              // Permission cards
              if (_isChecking)
                const Center(child: CircularProgressIndicator())
              else ...[
                _buildPermissionCard(
                  icon: Icons.visibility,
                  title: 'Overlay Permission',
                  description: 'Allows LimitIt to display blocking screen over other apps',
                  isGranted: _hasOverlayPermission,
                  onRequest: _requestOverlayPermission,
                ),
                SizedBox(height: 16.h),
                _buildPermissionCard(
                  icon: Icons.accessibility_new,
                  title: 'Accessibility Service',
                  description: 'Monitors which apps you open to enforce limits',
                  isGranted: _hasAccessibilityPermission,
                  onRequest: _requestAccessibilityPermission,
                ),
              ],

              const Spacer(),

              // Start button
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: allPermissionsGranted && !_isStartingMonitoring
                      ? _startMonitoringAndFinish
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF214432),
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                  ),
                  child: _isStartingMonitoring
                      ? const CircularProgressIndicator(color: Colors.white)
                      : CustomText(
                          text: allPermissionsGranted ? 'Start Monitoring' : 'Grant All Permissions First',
                          fontsize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: allPermissionsGranted ? Colors.white : Colors.grey.shade600,
                        ),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isGranted,
    required VoidCallback onRequest,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isGranted ? const Color(0xFFDEEDE2) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isGranted ? const Color(0xFF214432) : const Color(0xFFD1D1D1),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: isGranted ? const Color(0xFF214432) : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isGranted ? Icons.check : icon,
              color: isGranted ? Colors.white : Colors.grey.shade600,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: title,
                  fontsize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor3D3D3D,
                ),
                SizedBox(height: 4.h),
                CustomText(
                  text: description,
                  fontsize: 12.sp,
                  color: const Color(0xFF5D5D5D),
                  maxline: 2,
                ),
              ],
            ),
          ),
          if (!isGranted)
            TextButton(
              onPressed: onRequest,
              child: CustomText(
                text: 'Grant',
                fontsize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF214432),
              ),
            ),
        ],
      ),
    );
  }
}
