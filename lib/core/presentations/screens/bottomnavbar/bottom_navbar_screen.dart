import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/core/presentations/screens/Home/app_protection_screen.dart';
import 'package:limit_it_app/core/presentations/screens/statistics/statistics_screen.dart';
import 'package:limit_it_app/core/presentations/screens/settings2/settings_home_screen.dart';
import 'package:limit_it_app/core/presentations/screens/premium/premium_screen.dart';
import 'package:limit_it_app/core/services/app_blocker_service.dart';
import '../../widgets/ui/ui.dart';

/// Root shell — Home · Statistics · Premium · Settings.
class BottomNavBarScreen extends StatefulWidget {
  const BottomNavBarScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<BottomNavBarScreen> createState() => _BottomNavBarScreenState();
}

class _BottomNavBarScreenState extends State<BottomNavBarScreen> {
  late int currentIndex = widget.initialIndex;

  final List<Widget> screens = [
    const AppProtectionScreen(),
    const StatisticsScreen(),
    const PremiumScreen(),
    const SettingsHomeScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _autoStartMonitoringIfPermissionsGranted();
  }

  /// Automatically start monitoring service if permissions are already granted
  Future<void> _autoStartMonitoringIfPermissionsGranted() async {
    final appBlockerService = Get.find<AppBlockerService>();

    // Check if monitoring is already active
    final isMonitoring = await appBlockerService.isMonitoringActive();
    if (isMonitoring) {
      // Monitoring already running, nothing to do
      return;
    }

    // Check if all permissions are granted
    final hasAllPermissions = await appBlockerService.hasAllPermissions();
    if (hasAllPermissions) {
      // Permissions are granted but service isn't running, start it automatically
      await appBlockerService.startMonitoring();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: AppBottomNav(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
      ),
    );
  }
}
