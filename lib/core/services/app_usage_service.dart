import 'dart:io';
import 'package:usage_stats/usage_stats.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart' as installed;
import 'package:flutter/foundation.dart';

class AppUsageService {
  // Singleton pattern
  static AppUsageService? _instance;

  AppUsageService._();

  static AppUsageService get instance {
    _instance ??= AppUsageService._();
    return _instance!;
  }

  /// Request usage stats permission (Android only)
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      // Check if permission is already granted
      bool? grantedResult = await UsageStats.checkUsagePermission();
      bool granted = grantedResult ?? false;

      if (!granted) {
        // Request permission - this will open settings
        await UsageStats.grantUsagePermission();
        // Check again after user returns from settings
        grantedResult = await UsageStats.checkUsagePermission();
        granted = grantedResult ?? false;
      }

      return granted;
    } else if (Platform.isIOS) {
      // iOS doesn't provide app usage stats through third-party apps
      // Return false to indicate iOS doesn't support this feature
      return false;
    }

    return false;
  }

  /// Check if permission is granted
  Future<bool> hasPermission() async {
    if (Platform.isAndroid) {
      return await UsageStats.checkUsagePermission() ?? false;
    }
    return false;
  }

  /// Get app usage data for today
  Future<List<AppUsageData>> getTodayAppUsage() async {
    try {
      if (!Platform.isAndroid) {
        return [];
      }

      // Check permission
      bool hasPermission = await UsageStats.checkUsagePermission() ?? false;
      if (!hasPermission) {
        return [];
      }

      // Get usage stats for today
      DateTime endDate = DateTime.now();
      DateTime startDate = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        0,
        0,
        0,
      );

      List<UsageInfo> usageStats = await UsageStats.queryUsageStats(
        startDate,
        endDate,
      );

      // Get usage events to count app launches
      List<EventUsageInfo> usageEvents = await UsageStats.queryEvents(
        startDate,
        endDate,
      );

      // Count app launches from events
      Map<String, int> launchCounts = {};
      for (var event in usageEvents) {
        // Event type 1 = MOVE_TO_FOREGROUND (app opened)
        if (event.eventType == '1' && event.packageName != null) {
          launchCounts[event.packageName!] = (launchCounts[event.packageName!] ?? 0) + 1;
        }
      }

      // Get installed apps info for filtering system apps
      List<installed.AppInfo> installedApps = await InstalledApps.getInstalledApps(
        excludeSystemApps: false,
        excludeNonLaunchableApps: false,
        withIcon: true,
      );

      // Create a set of launchable app package names
      Set<String> launchablePackages = installedApps.map((app) => app.packageName).toSet();

      // Filter out system apps, apps with no usage, and our own app
      List<UsageInfo> filteredStats = usageStats.where((info) {
        int time = int.tryParse(info.totalTimeInForeground ?? '0') ?? 0;
        String packageName = info.packageName ?? '';

        // Exclude our own app (limit_it_app)
        if (packageName == 'com.limitit.digitalbalance ') {
          return false;
        }

        // Only include apps that:
        // 1. Have usage time > 0
        // 2. Are in the installed apps list (launchable apps only)
        return time > 0 && launchablePackages.contains(packageName);
      }).toList();

      // Sort by usage time (descending)
      filteredStats.sort((a, b) {
        int timeA = int.tryParse(a.totalTimeInForeground ?? '0') ?? 0;
        int timeB = int.tryParse(b.totalTimeInForeground ?? '0') ?? 0;
        return timeB.compareTo(timeA);
      });

      // Use all filtered apps instead of limiting to top 10
      List<UsageInfo> topApps = filteredStats;

      // Calculate total usage time
      int totalUsageTime = 0;
      for (var app in topApps) {
        totalUsageTime += int.tryParse(app.totalTimeInForeground ?? '0') ?? 0;
      }

      // Convert to AppUsageData
      List<AppUsageData> appUsageList = [];

      for (var usageInfo in topApps) {
        try {
          // Find the app info
          installed.AppInfo? appInfo;
          try {
            appInfo = installedApps.firstWhere(
              (app) => app.packageName == usageInfo.packageName,
            );
          } catch (e) {
            // App not found in installed apps list
            appInfo = null;
          }

          int usageTimeMs = int.tryParse(usageInfo.totalTimeInForeground ?? '0') ?? 0;

          // Get app launch count from events
          int openCount = launchCounts[usageInfo.packageName] ?? 0;

          // Calculate percentage
          double percentage = totalUsageTime > 0
              ? (usageTimeMs / totalUsageTime) * 100
              : 0;

          appUsageList.add(AppUsageData(
            name: appInfo?.name ?? _getAppNameFromPackage(usageInfo.packageName ?? ''),
            packageName: usageInfo.packageName ?? '',
            icon: appInfo?.icon,
            usageTimeMs: usageTimeMs,
            percentage: percentage,
            openCount: openCount,
          ));
        } catch (e) {
          debugPrint('Error processing app ${usageInfo.packageName}: $e');
        }
      }

      return appUsageList;
    } catch (e) {
      debugPrint('Error getting app usage: $e');
      return [];
    }
  }

  /// Get app name from package name
  String _getAppNameFromPackage(String packageName) {
    List<String> parts = packageName.split('.');
    if (parts.isNotEmpty) {
      String name = parts.last;
      return name[0].toUpperCase() + name.substring(1);
    }
    return packageName;
  }

  /// Get ALL installed apps (regardless of usage)
  /// This shows every launchable app on the device
  Future<List<AppUsageData>> getAllInstalledApps() async {
    try {
      if (!Platform.isAndroid) {
        return [];
      }

      // Get all installed apps (excluding system apps)
      List<installed.AppInfo> installedApps = await InstalledApps.getInstalledApps(
        excludeSystemApps: false,
        excludeNonLaunchableApps: false,
        withIcon: true,
      );

      // Get today's usage data to merge
      Map<String, UsageInfo> usageMap = {};
      Map<String, int> launchCounts = {};

      bool hasPermission = await UsageStats.checkUsagePermission() ?? false;
      if (hasPermission) {
        DateTime endDate = DateTime.now();
        DateTime startDate = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          0,
          0,
          0,
        );

        List<UsageInfo> usageStats = await UsageStats.queryUsageStats(startDate, endDate);
        for (var usage in usageStats) {
          if (usage.packageName != null) {
            usageMap[usage.packageName!] = usage;
          }
        }

        List<EventUsageInfo> usageEvents = await UsageStats.queryEvents(startDate, endDate);
        for (var event in usageEvents) {
          if (event.eventType == '1' && event.packageName != null) {
            launchCounts[event.packageName!] = (launchCounts[event.packageName!] ?? 0) + 1;
          }
        }
      }

      // Calculate total usage time for percentage calculation
      int totalUsageTime = 0;
      for (var usage in usageMap.values) {
        totalUsageTime += int.tryParse(usage.totalTimeInForeground ?? '0') ?? 0;
      }

      // Convert all installed apps to AppUsageData (excluding our own app)
      List<AppUsageData> appList = [];
      for (var appInfo in installedApps) {
        try {
          String packageName = appInfo.packageName;
          
          // Skip our own app (limit_it_app)
          if (packageName == 'com.limitit.digitalbalance ') {
            continue;
          }
          
          int usageTimeMs = 0;
          int openCount = 0;
          double percentage = 0;

          // Check if this app has usage data
          if (usageMap.containsKey(packageName)) {
            usageTimeMs = int.tryParse(usageMap[packageName]!.totalTimeInForeground ?? '0') ?? 0;
            openCount = launchCounts[packageName] ?? 0;
            percentage = totalUsageTime > 0 ? (usageTimeMs / totalUsageTime) * 100 : 0;
          }

          appList.add(AppUsageData(
            name: appInfo.name,
            packageName: packageName,
            icon: appInfo.icon,
            usageTimeMs: usageTimeMs,
            percentage: percentage,
            openCount: openCount,
          ));
        } catch (e) {
          debugPrint('Error processing app ${appInfo.packageName}: $e');
        }
      }

      // Sort by usage time (apps with usage first, then alphabetically)
      appList.sort((a, b) {
        if (a.usageTimeMs > 0 && b.usageTimeMs == 0) return -1;
        if (a.usageTimeMs == 0 && b.usageTimeMs > 0) return 1;
        if (a.usageTimeMs > 0 && b.usageTimeMs > 0) {
          return b.usageTimeMs.compareTo(a.usageTimeMs);
        }
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      return appList;
    } catch (e) {
      debugPrint('Error getting installed apps: $e');
      return [];
    }
  }

  /// Format milliseconds to readable time
  String formatUsageTime(int milliseconds) {
    int seconds = (milliseconds / 1000).round();

    if (seconds < 60) {
      return '$seconds secs';
    } else if (seconds < 3600) {
      int minutes = (seconds / 60).round();
      return '$minutes mins';
    } else {
      int hours = (seconds / 3600).floor();
      int minutes = ((seconds % 3600) / 60).round();
      if (minutes == 0) {
        return '$hours ${hours == 1 ? 'hr' : 'hrs'}';
      }
      return '$hours ${hours == 1 ? 'hr' : 'hrs'} $minutes mins';
    }
  }
}

/// Model to hold app usage data
class AppUsageData {
  final String name;
  final String packageName;
  final Uint8List? icon;
  final int usageTimeMs;
  final double percentage;
  final int openCount;

  AppUsageData({
    required this.name,
    required this.packageName,
    this.icon,
    required this.usageTimeMs,
    required this.percentage,
    required this.openCount,
  });

  /// Get formatted usage string for display
  String get usageString {
    String time = AppUsageService.instance.formatUsageTime(usageTimeMs);
    return time;
  }

  /// Get formatted percentage
  String get percentageString {
    return '${percentage.toStringAsFixed(0)}%';
  }
}
