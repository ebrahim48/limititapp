import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Service to communicate with native Android app blocking functionality
class AppBlockerService {
  static const MethodChannel _channel = MethodChannel('com.example.limit_it_app/app_blocker');

  // Singleton pattern
  static AppBlockerService? _instance;

  AppBlockerService._();

  static AppBlockerService get instance {
    _instance ??= AppBlockerService._();
    return _instance!;
  }

  /// Start the app monitoring service
  Future<bool> startMonitoring() async {
    try {
      final result = await _channel.invokeMethod('startMonitoring');
      return result == true;
    } catch (e) {
      debugPrint('Error starting monitoring: $e');
      return false;
    }
  }

  /// Stop the app monitoring service
  Future<bool> stopMonitoring() async {
    try {
      final result = await _channel.invokeMethod('stopMonitoring');
      return result == true;
    } catch (e) {
      debugPrint('Error stopping monitoring: $e');
      return false;
    }
  }

  /// Check if overlay permission is granted
  Future<bool> hasOverlayPermission() async {
    try {
      final result = await _channel.invokeMethod('hasOverlayPermission');
      return result == true;
    } catch (e) {
      debugPrint('Error checking overlay permission: $e');
      return false;
    }
  }

  /// Request overlay permission from user
  Future<void> requestOverlayPermission() async {
    try {
      await _channel.invokeMethod('requestOverlayPermission');
    } catch (e) {
      debugPrint('Error requesting overlay permission: $e');
    }
  }

  /// Check if accessibility service is enabled
  Future<bool> hasAccessibilityPermission() async {
    try {
      final result = await _channel.invokeMethod('hasAccessibilityPermission');
      return result == true;
    } catch (e) {
      debugPrint('Error checking accessibility permission: $e');
      return false;
    }
  }

  /// Request accessibility permission from user
  Future<void> requestAccessibilityPermission() async {
    try {
      await _channel.invokeMethod('requestAccessibilityPermission');
    } catch (e) {
      debugPrint('Error requesting accessibility permission: $e');
    }
  }

  /// Check if monitoring is currently active
  Future<bool> isMonitoringActive() async {
    try {
      final result = await _channel.invokeMethod('isMonitoringActive');
      return result == true;
    } catch (e) {
      debugPrint('Error checking monitoring status: $e');
      return false;
    }
  }

  /// Check all required permissions
  Future<Map<String, bool>> checkAllPermissions() async {
    return {
      'overlay': await hasOverlayPermission(),
      'accessibility': await hasAccessibilityPermission(),
    };
  }

  /// Check if all permissions are granted
  Future<bool> hasAllPermissions() async {
    final permissions = await checkAllPermissions();
    return permissions.values.every((granted) => granted);
  }

  /// Update the list of blocked apps in the native monitoring service
  Future<bool> updateBlockedApps(List<String> blockedPackageNames) async {
    try {
      final result = await _channel.invokeMethod('updateBlockedApps', {
        'blockedApps': blockedPackageNames,
      });
      return result == true;
    } catch (e) {
      debugPrint('Error updating blocked apps: $e');
      return false;
    }
  }

  /// Get the current list of blocked apps from native service
  Future<List<String>> getBlockedApps() async {
    try {
      final result = await _channel.invokeMethod('getBlockedApps');
      if (result is List) {
        return result.cast<String>();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting blocked apps: $e');
      return [];
    }
  }
}
