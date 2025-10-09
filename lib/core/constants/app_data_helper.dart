import 'package:flutter/material.dart';
import 'package:limit_it_app/core/models/appinfo_model.dart';
import 'package:limit_it_app/core/models/daily_usage.dart';


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




}
