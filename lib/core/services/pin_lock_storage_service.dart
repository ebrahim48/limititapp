import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Model for PIN lock settings
class PinLockSettings {
  final bool isEnabled;
  final String? pinCode;
  final Set<String> selectedAppKeys;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PinLockSettings({
    this.isEnabled = false,
    this.pinCode,
    this.selectedAppKeys = const {},
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'pinCode': pinCode,
      'selectedAppKeys': selectedAppKeys.toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory PinLockSettings.fromJson(Map<String, dynamic> json) {
    return PinLockSettings(
      isEnabled: json['isEnabled'] ?? false,
      pinCode: json['pinCode'],
      selectedAppKeys: (json['selectedAppKeys'] as List<dynamic>?)?.map((e) => e.toString()).toSet() ?? {},
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  PinLockSettings copyWith({
    bool? isEnabled,
    String? pinCode,
    Set<String>? selectedAppKeys,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PinLockSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      pinCode: pinCode ?? this.pinCode,
      selectedAppKeys: selectedAppKeys ?? this.selectedAppKeys,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Service to manage PIN lock settings using SharedPreferences
class PinLockStorageService {
  static const String _keyPinLockSettings = 'pin_lock_settings';

  // Singleton pattern
  static PinLockStorageService? _instance;

  PinLockStorageService._();

  static PinLockStorageService get instance {
    _instance ??= PinLockStorageService._();
    return _instance!;
  }

  /// Get PIN lock settings
  Future<PinLockSettings> getPinLockSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_keyPinLockSettings);

      if (jsonString == null || jsonString.isEmpty) {
        return PinLockSettings();
      }

      final Map<String, dynamic> json = jsonDecode(jsonString);
      return PinLockSettings.fromJson(json);
    } catch (e) {
      debugPrint('Error loading PIN lock settings: $e');
      return PinLockSettings();
    }
  }

  /// Save PIN lock settings
  Future<bool> savePinLockSettings(PinLockSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Update timestamp
      final updatedSettings = settings.copyWith(
        updatedAt: DateTime.now(),
        createdAt: settings.createdAt ?? DateTime.now(),
      );

      final String jsonString = jsonEncode(updatedSettings.toJson());
      return await prefs.setString(_keyPinLockSettings, jsonString);
    } catch (e) {
      debugPrint('Error saving PIN lock settings: $e');
      return false;
    }
  }

  /// Check if PIN lock is enabled
  Future<bool> isPinLockEnabled() async {
    try {
      final settings = await getPinLockSettings();
      return settings.isEnabled;
    } catch (e) {
      debugPrint('Error checking PIN lock status: $e');
      return false;
    }
  }

  /// Enable or disable PIN lock
  Future<bool> setPinLockEnabled(bool enabled) async {
    try {
      final settings = await getPinLockSettings();
      final updatedSettings = settings.copyWith(isEnabled: enabled);
      return await savePinLockSettings(updatedSettings);
    } catch (e) {
      debugPrint('Error setting PIN lock enabled: $e');
      return false;
    }
  }

  /// Get stored PIN code
  Future<String?> getPinCode() async {
    try {
      final settings = await getPinLockSettings();
      return settings.pinCode;
    } catch (e) {
      debugPrint('Error getting PIN code: $e');
      return null;
    }
  }

  /// Save PIN code
  Future<bool> savePinCode(String pinCode) async {
    try {
      final settings = await getPinLockSettings();
      final updatedSettings = settings.copyWith(
        pinCode: pinCode,
        isEnabled: true,
      );
      return await savePinLockSettings(updatedSettings);
    } catch (e) {
      debugPrint('Error saving PIN code: $e');
      return false;
    }
  }

  /// Get selected app keys for PIN lock
  Future<Set<String>> getSelectedAppKeys() async {
    try {
      final settings = await getPinLockSettings();
      return settings.selectedAppKeys;
    } catch (e) {
      debugPrint('Error getting selected app keys: $e');
      return {};
    }
  }

  /// Save selected app keys
  Future<bool> saveSelectedAppKeys(Set<String> appKeys) async {
    try {
      final settings = await getPinLockSettings();
      final updatedSettings = settings.copyWith(selectedAppKeys: appKeys);
      return await savePinLockSettings(updatedSettings);
    } catch (e) {
      debugPrint('Error saving selected app keys: $e');
      return false;
    }
  }

  /// Check if an app is protected by PIN lock
  Future<bool> isAppProtected(String appKey) async {
    try {
      final settings = await getPinLockSettings();
      return settings.selectedAppKeys.contains(appKey);
    } catch (e) {
      debugPrint('Error checking if app is protected: $e');
      return false;
    }
  }

  /// Add app to PIN lock protection
  Future<bool> addProtectedApp(String appKey) async {
    try {
      final settings = await getPinLockSettings();
      final updatedKeys = Set<String>.from(settings.selectedAppKeys)..add(appKey);
      final updatedSettings = settings.copyWith(selectedAppKeys: updatedKeys);
      return await savePinLockSettings(updatedSettings);
    } catch (e) {
      debugPrint('Error adding protected app: $e');
      return false;
    }
  }

  /// Remove app from PIN lock protection
  Future<bool> removeProtectedApp(String appKey) async {
    try {
      final settings = await getPinLockSettings();
      final updatedKeys = Set<String>.from(settings.selectedAppKeys)..remove(appKey);
      final updatedSettings = settings.copyWith(selectedAppKeys: updatedKeys);
      return await savePinLockSettings(updatedSettings);
    } catch (e) {
      debugPrint('Error removing protected app: $e');
      return false;
    }
  }

  /// Clear all PIN lock settings
  Future<bool> clearPinLockSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_keyPinLockSettings);
    } catch (e) {
      debugPrint('Error clearing PIN lock settings: $e');
      return false;
    }
  }

  /// Verify PIN code
  Future<bool> verifyPinCode(String pinCode) async {
    try {
      final storedPin = await getPinCode();
      return storedPin == pinCode;
    } catch (e) {
      debugPrint('Error verifying PIN code: $e');
      return false;
    }
  }
}
