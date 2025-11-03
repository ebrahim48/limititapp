import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:limit_it_app/core/models/app_limit_model.dart';
import 'package:flutter/foundation.dart';

/// Service to manage app limits in SharedPreferences
class AppLimitStorageService {
  static const String _keyAppLimits = 'app_limits';
  static const String _keyDailyScreenTime = 'daily_screen_time';
  static const String _keyAppUsageToday = 'app_usage_today_';
  static const String _keyLastResetDate = 'last_reset_date';

  // Singleton pattern
  static AppLimitStorageService? _instance;

  AppLimitStorageService._();

  static AppLimitStorageService get instance {
    _instance ??= AppLimitStorageService._();
    return _instance!;
  }

  /// Save app limits to SharedPreferences
  Future<bool> saveAppLimits(List<AppLimitModel> limits) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert limits to JSON
      final List<Map<String, dynamic>> jsonList = limits.map((limit) => limit.toJson()).toList();
      final String jsonString = jsonEncode(jsonList);

      return await prefs.setString(_keyAppLimits, jsonString);
    } catch (e) {
      debugPrint('Error saving app limits: $e');
      return false;
    }
  }

  /// Get all app limits from SharedPreferences
  Future<List<AppLimitModel>> getAppLimits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_keyAppLimits);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => AppLimitModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading app limits: $e');
      return [];
    }
  }

  /// Get app limit for a specific package
  Future<AppLimitModel?> getAppLimit(String packageName) async {
    try {
      final limits = await getAppLimits();
      return limits.cast<AppLimitModel?>().firstWhere(
        (limit) => limit?.packageName == packageName,
        orElse: () => null,
      );
    } catch (e) {
      debugPrint('Error getting app limit: $e');
      return null;
    }
  }

  /// Delete a specific app limit
  Future<bool> deleteAppLimit(String packageName) async {
    try {
      final limits = await getAppLimits();
      limits.removeWhere((limit) => limit.packageName == packageName);
      return await saveAppLimits(limits);
    } catch (e) {
      debugPrint('Error deleting app limit: $e');
      return false;
    }
  }

  /// Clear all app limits
  Future<bool> clearAllLimits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_keyAppLimits);
    } catch (e) {
      debugPrint('Error clearing app limits: $e');
      return false;
    }
  }

  /// Save daily screen time limit (in minutes)
  Future<bool> saveDailyScreenTime(int minutes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setInt(_keyDailyScreenTime, minutes);
    } catch (e) {
      debugPrint('Error saving daily screen time: $e');
      return false;
    }
  }

  /// Get daily screen time limit (in minutes)
  Future<int?> getDailyScreenTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyDailyScreenTime);
    } catch (e) {
      debugPrint('Error getting daily screen time: $e');
      return null;
    }
  }

  /// Track app usage for today
  Future<bool> saveAppUsageToday(String packageName, int opensCount, int usageMinutes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String key = '$_keyAppUsageToday$packageName';

      final Map<String, dynamic> usage = {
        'opensCount': opensCount,
        'usageMinutes': usageMinutes,
        'date': DateTime.now().toIso8601String(),
      };

      return await prefs.setString(key, jsonEncode(usage));
    } catch (e) {
      debugPrint('Error saving app usage today: $e');
      return false;
    }
  }

  /// Get app usage for today
  Future<Map<String, int>?> getAppUsageToday(String packageName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String key = '$_keyAppUsageToday$packageName';
      final String? jsonString = prefs.getString(key);

      if (jsonString == null) {
        return null;
      }

      final Map<String, dynamic> usage = jsonDecode(jsonString);

      // Check if it's from today
      final DateTime savedDate = DateTime.parse(usage['date']);
      final DateTime now = DateTime.now();

      if (savedDate.year == now.year &&
          savedDate.month == now.month &&
          savedDate.day == now.day) {
        return {
          'opensCount': usage['opensCount'],
          'usageMinutes': usage['usageMinutes'],
        };
      }

      // If not from today, return null (will be reset)
      return null;
    } catch (e) {
      debugPrint('Error getting app usage today: $e');
      return null;
    }
  }

  /// Reset daily usage counters (should be called at midnight)
  Future<bool> resetDailyUsage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get all keys
      final keys = prefs.getKeys();

      // Remove all app usage keys
      for (var key in keys) {
        if (key.startsWith(_keyAppUsageToday)) {
          await prefs.remove(key);
        }
      }

      // Update last reset date
      await prefs.setString(_keyLastResetDate, DateTime.now().toIso8601String());

      return true;
    } catch (e) {
      debugPrint('Error resetting daily usage: $e');
      return false;
    }
  }

  /// Check if we need to reset daily usage
  Future<bool> shouldResetDailyUsage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? lastResetString = prefs.getString(_keyLastResetDate);

      if (lastResetString == null) {
        return true; // First time, should reset
      }

      final DateTime lastReset = DateTime.parse(lastResetString);
      final DateTime now = DateTime.now();

      // Check if it's a new day
      return lastReset.year != now.year ||
             lastReset.month != now.month ||
             lastReset.day != now.day;
    } catch (e) {
      debugPrint('Error checking reset daily usage: $e');
      return false;
    }
  }
}
