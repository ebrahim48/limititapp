import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Model for blocked app
class BlockedApp {
  final String packageName;
  final String appName;
  final DateTime blockedAt;

  BlockedApp({
    required this.packageName,
    required this.appName,
    required this.blockedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'packageName': packageName,
      'appName': appName,
      'blockedAt': blockedAt.toIso8601String(),
    };
  }

  factory BlockedApp.fromJson(Map<String, dynamic> json) {
    return BlockedApp(
      packageName: json['packageName'],
      appName: json['appName'],
      blockedAt: DateTime.parse(json['blockedAt']),
    );
  }
}

/// Service to manage blocked apps using SharedPreferences
class BlockedAppsService {
  static const String _keyBlockedApps = 'blocked_apps';

  /// Get all blocked apps
  static Future<List<BlockedApp>> getBlockedApps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_keyBlockedApps);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => BlockedApp.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading blocked apps: $e');
      return [];
    }
  }

  /// Check if an app is blocked
  static Future<bool> isAppBlocked(String packageName) async {
    try {
      final blockedApps = await getBlockedApps();
      return blockedApps.any((app) => app.packageName == packageName);
    } catch (e) {
      debugPrint('Error checking if app is blocked: $e');
      return false;
    }
  }

  /// Block an app
  static Future<bool> blockApp(String packageName, String appName) async {
    try {
      final blockedApps = await getBlockedApps();

      // Check if already blocked
      if (blockedApps.any((app) => app.packageName == packageName)) {
        debugPrint('App $appName is already blocked');
        return true;
      }

      // Add to blocked list
      blockedApps.add(BlockedApp(
        packageName: packageName,
        appName: appName,
        blockedAt: DateTime.now(),
      ));

      return await _saveBlockedApps(blockedApps);
    } catch (e) {
      debugPrint('Error blocking app: $e');
      return false;
    }
  }

  /// Unblock an app
  static Future<bool> unblockApp(String packageName) async {
    try {
      final blockedApps = await getBlockedApps();

      // Remove from blocked list
      blockedApps.removeWhere((app) => app.packageName == packageName);

      return await _saveBlockedApps(blockedApps);
    } catch (e) {
      debugPrint('Error unblocking app: $e');
      return false;
    }
  }

  /// Get list of blocked package names (for native integration)
  static Future<List<String>> getBlockedPackageNames() async {
    try {
      final blockedApps = await getBlockedApps();
      return blockedApps.map((app) => app.packageName).toList();
    } catch (e) {
      debugPrint('Error getting blocked package names: $e');
      return [];
    }
  }

  /// Clear all blocked apps
  static Future<bool> clearAllBlockedApps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_keyBlockedApps);
    } catch (e) {
      debugPrint('Error clearing blocked apps: $e');
      return false;
    }
  }

  /// Save blocked apps to SharedPreferences
  static Future<bool> _saveBlockedApps(List<BlockedApp> blockedApps) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert to JSON
      final List<Map<String, dynamic>> jsonList =
          blockedApps.map((app) => app.toJson()).toList();
      final String jsonString = jsonEncode(jsonList);

      return await prefs.setString(_keyBlockedApps, jsonString);
    } catch (e) {
      debugPrint('Error saving blocked apps: $e');
      return false;
    }
  }
}
