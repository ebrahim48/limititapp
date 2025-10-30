import 'package:flutter/material.dart';
import 'package:limit_it_app/core/models/appinfo_model.dart';
import 'package:limit_it_app/core/models/daily_usage.dart';
import 'package:limit_it_app/core/services/app_usage_service.dart';


class AppDataHelper {
  static final List<DailyUsageApp> dailyApps = [
    DailyUsageApp(
      name: 'Facebook',
      icon: 'assets/icons/facebook.svg',
      percentage: '45%',
      height: 8,
      color: const Color(0xFF4C7C5B),
    ),
    DailyUsageApp(
      name: 'Instagram',
      icon: 'assets/icons/instagram.svg',
      percentage: '59%',
      height: 10,
      color: const Color(0xFFE74C3C),
    ),
    DailyUsageApp(
      name: 'Snapchat',
      icon: 'assets/icons/snapshot.svg',
      percentage: '19%',
      height: 5.5,
      color: const Color(0xFFF1C40F),
    ),
    DailyUsageApp(
      name: 'Netflix',
      icon: 'assets/icons/netflix.svg',
      percentage: '09%',
      height: 3.5,
      color: const Color(0xFF2C2C2C),
    ),
    DailyUsageApp(
      name: 'TikTok',
      icon: 'assets/icons/tiktalk.svg',
      percentage: '72%',
      height: 7.2,
      color: const Color(0xFF214432),
    ),
  ];

  static final List<AppInfo> yourApps = [
    AppInfo(
      name: 'Twitter',
      icon: 'assets/icons/twitter.svg',
      usage: '45 mins • 4/10 Opens',
      percentage: '45%',
    ),
    AppInfo(
      name: 'YouTube',
      icon: 'assets/icons/youtube.svg',
      usage: '45 mins • 4/10 Opens',
      percentage: '45%',
    ),
    AppInfo(
      name: 'Facebook',
      icon: 'assets/icons/facebook.svg',
      usage: '45 mins • 4/10 Opens',
      percentage: '45%',
    ),
  ];

  /// Convert AppUsageData list to DailyUsageApp list for chart display
  static List<DailyUsageApp> convertToDailyUsageApps(List<AppUsageData> appUsageList) {
    if (appUsageList.isEmpty) {
      return dailyApps; // Return default data if no usage data
    }

    // Take top 5 apps for the chart
    final topApps = appUsageList.take(5).toList();

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


}
