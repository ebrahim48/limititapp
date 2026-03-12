import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service to handle runtime permissions (Android 13+)
class NotificationPermissionService {
  static NotificationPermissionService? _instance;

  NotificationPermissionService._();

  static NotificationPermissionService get instance {
    _instance ??= NotificationPermissionService._();
    return _instance!;
  }

  /// Check if notification permission is granted (Android 13+)
  Future<bool> hasNotificationPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      debugPrint('Notification permission status: $status');
      return status.isGranted;
    }
    return true; // iOS and other platforms handle notifications differently
  }

  /// Request notification permission
  Future<bool> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      debugPrint('Notification permission requested: $status');
      return status.isGranted;
    }
    return true;
  }

  /// Check and request notification permission if needed
  Future<bool> ensureNotificationPermission() async {
    if (await hasNotificationPermission()) {
      return true;
    }
    return await requestNotificationPermission();
  }
}
