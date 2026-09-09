import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/presentations/screens/Home/home_screen.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/services/app_blocker_service.dart';
import 'package:limit_it_app/core/services/app_limit_storage_service.dart';
import 'package:limit_it_app/core/services/notification_permission_service.dart';

class PermissionsSetupScreen extends StatefulWidget {
  const PermissionsSetupScreen({super.key});

  @override
  State<PermissionsSetupScreen> createState() => _PermissionsSetupScreenState();
}

class _PermissionsSetupScreenState extends State<PermissionsSetupScreen>
    with WidgetsBindingObserver {
  bool _hasOverlayPermission = false;
  bool _hasAccessibilityPermission = false;
  bool _hasNotificationPermission = true;
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
      // Re-check permissions when user returns from settings
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    setState(() => _isChecking = true);

    final appBlockerService = Get.find<AppBlockerService>();
    final permissions = await appBlockerService.checkAllPermissions();

    // Check notification permission for Android 13+
    final notificationPermissionService = NotificationPermissionService.instance;
    final hasNotificationPermission = await notificationPermissionService.hasNotificationPermission();

    setState(() {
      _hasOverlayPermission = permissions['overlay'] ?? false;
      _hasAccessibilityPermission = permissions['accessibility'] ?? false;
      _hasNotificationPermission = hasNotificationPermission;
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

  Future<void> _requestNotificationPermission() async {
    final notificationPermissionService = NotificationPermissionService.instance;
    final granted = await notificationPermissionService.requestNotificationPermission();
    if (granted) {
      setState(() {
        _hasNotificationPermission = true;
      });
    }
  }

  Future<void> _startMonitoringAndFinish() async {
    setState(() => _isStartingMonitoring = true);

    // Start monitoring service
    final appBlockerService = Get.find<AppBlockerService>();
    final started = await appBlockerService.startMonitoring();

    if (!mounted) return;

    if (started) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.monitoringStartedSuccess),
          backgroundColor: Colors.green,
        ),
      );

      // Check if we have saved app limits to determine if user completed onboarding
      final appLimitStorageService = Get.find<AppLimitStorageService>();
      final appLimits = await appLimitStorageService.getAppLimits();

      if (appLimits.isEmpty) {
        // No app limits configured, user is in onboarding flow
        // Navigate to timer settings screen
        if (!mounted) return;
        context.pushNamed(AppRoutes.timerSettingsScreen);
      } else {
        // User already completed onboarding, just go back
        if (!mounted) return;
        Navigator.of(context).pop();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.failedToStartMonitoring),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isStartingMonitoring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool allPermissionsGranted =
        _hasOverlayPermission && _hasAccessibilityPermission && _hasNotificationPermission;

    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: context.l10n.setupPermissions,
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
                text: context.l10n.grantRequiredPermissions,
                fontsize: 24.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor2C2C2C,
              ),
              SizedBox(height: 12.h),
              CustomText(
                text: context.l10n.permissionsDescription,
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
                  title: context.l10n.overlayPermission,
                  description: context.l10n.overlayPermissionDesc,
                  isGranted: _hasOverlayPermission,
                  onRequest: _requestOverlayPermission,
                ),
                SizedBox(height: 16.h),
                _buildPermissionCard(
                  icon: Icons.accessibility_new,
                  title: context.l10n.accessibilityService,
                  description: context.l10n.accessibilityServiceDesc,
                  isGranted: _hasAccessibilityPermission,
                  onRequest: _requestAccessibilityPermission,
                ),
                SizedBox(height: 16.h),
                _buildPermissionCard(
                  icon: Icons.notifications_active,
                  title: context.l10n.notificationPermission,
                  description: context.l10n.notificationPermissionDesc,
                  isGranted: _hasNotificationPermission,
                  onRequest: _requestNotificationPermission,
                ),
              ],

              const Spacer(),

              // Start button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                  allPermissionsGranted && !_isStartingMonitoring
                      ? _startMonitoringAndFinish
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF214432),
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                  ),
                  child:
                  _isStartingMonitoring
                      ? const CircularProgressIndicator(color: Colors.white)
                      : CustomText(
                    text:
                    allPermissionsGranted
                        ? context.l10n.startMonitoring
                        : context.l10n.grantAllPermissionsFirst,
                    fontsize: 16,
                    fontWeight: FontWeight.w500,
                    color:
                    allPermissionsGranted
                        ? Colors.white
                        : Colors.grey.shade600,
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
                text: context.l10n.grant,
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