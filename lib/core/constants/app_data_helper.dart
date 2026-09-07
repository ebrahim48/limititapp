import 'package:flutter/material.dart';
import 'package:limit_it_app/core/models/appinfo_model.dart';
import 'package:limit_it_app/core/models/daily_usage.dart';
import 'package:limit_it_app/core/services/app_usage_service.dart';


class AppDataHelper {
  /// Convert AppUsageData list to DailyUsageApp list for chart display
  static List<DailyUsageApp> convertToDailyUsageApps(List<AppUsageData> appUsageList) {
    // Nothing measured yet means nothing to chart — callers show an empty
    // state rather than invented bars.
    if (appUsageList.isEmpty) return const [];

    // Take all apps for the chart (no limit)
    final topApps = appUsageList;

    // Define color palette for the chart bars
    final colors = [
      const Color(0xFF4C7C5B),
      const Color(0xFFE74C3C),
      const Color(0xFFF1C40F),
      const Color(0xFF2C2C2C),
      const Color(0xFF214432),
    ];

    return topApps.asMap().entries.map((entry) {
      final index = entry.key;
      final app = entry.value;

      // Calculate bar height (scale to max 10 units for 10 hours on Y-axis)
      final usageHours = app.usageTimeMs / (1000 * 60 * 60);
      final height = (usageHours / 10) * 10; // Scale: 1 unit = 1 hour, max 10 hours

      return DailyUsageApp(
        name: app.name,
        icon: '', // We'll handle real icons separately since they're Uint8List
        percentage: app.percentageString,
        height: height.clamp(0.5, 10.0), // Minimum 0.5 for visibility, max 10
        color: colors[index % colors.length],
      );
    }).toList();
  }

  /// Convert a usage list to the AppInfo rows the PDF report prints.
  static List<AppInfo> convertToYourApps(List<AppUsageData> appUsageList) =>
      appUsageList.map(convertToYourApp).toList();

  /// Convert AppUsageData to AppInfo for display in YourAppCard
  static AppInfo convertToYourApp(AppUsageData appUsage) {
    // Calculate usage time in minutes
    final usageMinutes = (appUsage.usageTimeMs / (1000 * 60)).round();
    final opensCount = appUsage.openCount;
    
    // Format usage string: "45 mins • 4 Opens"
    final usageString = '$usageMinutes mins • $opensCount Opens';
    
    // Calculate percentage (relative to total usage)
    final percentage = appUsage.percentageString;

    return AppInfo(
      name: appUsage.name,
      icon: '', // Will use real icon from memory
      usage: usageString,
      percentage: percentage,
      appIconBytes: appUsage.icon, // Pass the actual app icon bitmap bytes
    );
  }

}
