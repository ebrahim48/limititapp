import 'package:get/get.dart';
import 'package:limit_it_app/core/models/app_bock_item.dart';
import 'package:limit_it_app/core/services/blocked_apps_service.dart';
import 'package:limit_it_app/core/services/app_limit_storage_service.dart';
import 'package:limit_it_app/core/services/app_usage_service.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';
import 'package:limit_it_app/core/models/app_limit_model.dart';
import 'package:flutter/foundation.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';

class SchedulesLimitsController extends GetxController {
  final RxBool isExpanded = true.obs;
  final RxInt blockedAppsCount = 0.obs;
  final RxBool isLoading = true.obs;

  final RxList<AppBlockItem> appBlocks = <AppBlockItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadBlockedApps();
  }

  /// Load blocked apps dynamically from SharedPreferences
  Future<void> loadBlockedApps() async {
    try {
      isLoading(true);

      final blockedAppsService = BlockedAppsService.instance;
      final appLimitStorageService = AppLimitStorageService.instance;
      final appUsageService = AppUsageService.instance;

      // Get blocked apps
      final blockedApps = await blockedAppsService.getBlockedApps();
      blockedAppsCount.value = blockedApps.length;

      // Get all installed apps to get real icons
      final allInstalledApps = await appUsageService.getAllInstalledApps();
      
      // Create a map for quick lookup by package name
      final appIconMap = <String, Uint8List?>{};
      for (final app in allInstalledApps) {
        appIconMap[app.packageName] = app.icon;
      }

      // Today's real minutes / launch counts straight off the device.
      final todayUsage = {
        for (final app in await appUsageService.getTodayAppUsage())
          app.packageName: app,
      };

      // Get app limits to get schedule information
      final appLimits = await appLimitStorageService.getAppLimits();

      // Build app blocks list from blocked apps
      final newAppBlocks = <AppBlockItem>[];

      for (final blockedApp in blockedApps) {
        // Debug log
        debugPrint('\n=== Processing Blocked App ===');
        debugPrint('App Name: ${blockedApp.appName}');
        debugPrint('Package: ${blockedApp.packageName}');
        
        // Try to find corresponding app limit for schedule info
        final appLimit = appLimits.where(
          (limit) => limit.packageName == blockedApp.packageName,
        ).firstOrNull;

        // Get usage info from today's usage
        String usageInfo = appL10n.noUsageToday;
        final usageToday = _usageLine(
          await appLimitStorageService.getAppUsageToday(blockedApp.packageName),
          todayUsage[blockedApp.packageName],
        );
        if (usageToday != null) usageInfo = usageToday;

        // Get schedule times from app limit or use defaults
        String startTime = '10:00 PM';
        String endTime = '06:00 AM';

        if (appLimit != null && appLimit.scheduleStartTime != null) {
          // Convert from 24h format to 12h AM/PM format
          startTime = _formatTimeTo12Hour(appLimit.scheduleStartTime!.value);
          endTime = _formatTimeTo12Hour(appLimit.scheduleEndTime?.value ?? '23:00');
        }

        // Get app icon - try from installed apps map first, then fallback to mapping by package name
        Uint8List? appIcon = appIconMap[blockedApp.packageName];
        if (appIcon == null) {
          debugPrint('No real icon found, using icon mapping for: ${blockedApp.packageName}');
          appIcon = null; // Will use SVG icon mapping in widget
        }

        newAppBlocks.add(
          AppBlockItem(
            name: blockedApp.appName,
            icon: appIcon ?? _getAppIcon(blockedApp.packageName),
            usage: usageInfo,
            isEnabled: (appLimit?.isActive?.value ?? true).obs,
            startTime: startTime.obs,
            endTime: endTime.obs,
            packageName: blockedApp.packageName,
          ),
        );
      }

      // If no blocked apps but we have app limits, show those instead
      if (newAppBlocks.isEmpty && appLimits.isNotEmpty) {
        debugPrint('No blocked apps found, loading from app limits');
        blockedAppsCount.value = appLimits.length;

        for (final appLimit in appLimits) {
          // Get usage info from today's usage
          String usageInfo = appL10n.noUsageToday;
          final usageToday = _usageLine(
            await appLimitStorageService.getAppUsageToday(appLimit.packageName),
            todayUsage[appLimit.packageName],
          );
          if (usageToday != null) usageInfo = usageToday;

          // Get schedule times from app limit or use defaults
          String startTime = '10:00 PM';
          String endTime = '06:00 AM';

          if (appLimit.scheduleStartTime != null) {
            startTime = _formatTimeTo12Hour(appLimit.scheduleStartTime!.value);
            endTime = _formatTimeTo12Hour(appLimit.scheduleEndTime?.value ?? '23:00');
          }

          // Get app icon - try from installed apps map first, then fallback to mapping by package name
          Uint8List? appIcon = appIconMap[appLimit.packageName];
          if (appIcon == null) {
            debugPrint('No real icon found for limit, using icon mapping for: ${appLimit.packageName}');
          }

          newAppBlocks.add(
            AppBlockItem(
              name: appLimit.appName,
              icon: appIcon ?? _getAppIcon(appLimit.packageName),
              usage: usageInfo,
              isEnabled: (appLimit.isActive?.value ?? true).obs,
              startTime: startTime.obs,
              endTime: endTime.obs,
              packageName: appLimit.packageName,
            ),
          );
        }
      }

      // If still no apps, show empty state
      if (newAppBlocks.isEmpty) {
        debugPrint('No blocked apps or app limits found');
      }

      appBlocks.assignAll(newAppBlocks);
      isLoading(false);
    } catch (e) {
      debugPrint('Error loading blocked apps: $e');
      isLoading(false);
    }
  }

  /// "45 mins • 12 Opens" for the card subtitle.
  ///
  /// The stored counters only exist once something has written them for today,
  /// so the device's own UsageStats numbers are the reliable source and the
  /// stored ones are treated as an override.
  String? _usageLine(Map<String, int>? stored, AppUsageData? device) {
    final minutes = stored?['usageMinutes'] ?? ((device?.usageTimeMs ?? 0) ~/ 60000);
    final opens = stored?['opensCount'] ?? device?.openCount ?? 0;

    if (minutes <= 0 && opens <= 0) return null;
    return '$minutes mins • $opens Opens';
  }

  /// Convert 24h format to 12h AM/PM format
  String _formatTimeTo12Hour(String time24h) {
    try {
      final parts = time24h.split(':');
      int hour = int.parse(parts[0]);
      final minute = parts[1];

      final period = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12;
      if (hour == 0) hour = 12;

      return '$hour:$minute $period';
    } catch (e) {
      return '10:00 PM'; // Default fallback
    }
  }

  /// Get app icon based on package name
  dynamic _getAppIcon(String packageName) {
    // Debug log the package name
    debugPrint('Getting icon for package: $packageName');
    
    // Map common package names to icons - check if package name contains these keywords
    final iconMap = {
      'facebook': Assets.icons.facebook,
      'instagram': Assets.icons.instagram,
      'snapchat': Assets.icons.snapshot,
      'youtube': Assets.icons.youtube,
      'twitter': Assets.icons.twitter,
      'tiktok': Assets.icons.tiktalk,
      'netflix': Assets.icons.netflix,
    };

    // Convert package name to lowercase for case-insensitive matching
    final lowerPackageName = packageName.toLowerCase();

    // Try to find matching icon by checking if package name contains the keyword
    for (final entry in iconMap.entries) {
      if (lowerPackageName.contains(entry.key)) {
        debugPrint('✓ Found match for keyword "${entry.key}" - returning icon');
        return entry.value;
      }
    }

    // Debug: show what didn't match
    debugPrint('✗ No match found, using fallback Facebook icon');
    
    // Default icon if not found - use a generic icon
    return Assets.icons.facebook;
  }

  /// Save schedules for enabled apps
  Future<void> saveSchedules() async {
    try {
      final appLimitStorageService = AppLimitStorageService.instance;
      final appLimits = await appLimitStorageService.getAppLimits();

      for (final app in appBlocks) {
        // Convert 12h AM/PM to 24h format
        final start24h = _convertTo24Hour(app.startTime.value);
        final end24h = _convertTo24Hour(app.endTime.value);

        // Find and update the corresponding app limit
        final existingLimitIndex = appLimits.indexWhere(
          (limit) => limit.packageName == app.packageName,
        );

        if (existingLimitIndex != -1) {
          // Update existing limit
          appLimits[existingLimitIndex] = appLimits[existingLimitIndex].copyWith(
            scheduleStartTime: start24h,
            scheduleEndTime: end24h,
            isActive: app.isEnabled.value,
          );
        } else {
          // Create new limit if not exists
          appLimits.add(
            AppLimitModel(
              packageName: app.packageName ?? '',
              appName: app.name,
              maxDailyOpens: 10,
              maxSessionDurationMinutes: 30,
              activeDays: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'],
              scheduleStartTime: start24h.obs,
              scheduleEndTime: end24h.obs,
              isActive: app.isEnabled.value.obs,
            ),
          );
        }

        debugPrint('${app.name}: ${app.isEnabled.value ? 'Enabled' : 'Disabled'} | $start24h - $end24h');
      }

      // Save updated limits
      await appLimitStorageService.saveAppLimits(appLimits);
    } catch (e) {
      debugPrint('Error saving schedules: $e');
    }
  }

  /// Convert 12h AM/PM format to 24h format
  String _convertTo24Hour(String time12h) {
    try {
      final parts = time12h.split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      final minute = timeParts[1];
      final period = parts[1].toUpperCase();

      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      return '${hour.toString().padLeft(2, '0')}:$minute';
    } catch (e) {
      return '22:00'; // Default fallback
    }
  }

  /// Refresh the blocked apps list
  Future<void> refresh() async {
    await loadBlockedApps();
  }
}
