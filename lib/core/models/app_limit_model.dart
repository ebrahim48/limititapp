import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';

/// How an app is protected. Drives the badge and the editor controls.
enum ProtectionType {
  /// "Pause 10s before opening"
  delayOpening,

  /// "Daily limit: 0h 30m"
  dailyLimit,

  /// "Max 4 openings/day"
  maxOpens,

  /// "Blocked 23:00–08:05"
  timeBlock;

  static ProtectionType fromName(String? name) {
    return ProtectionType.values.firstWhere(
      (t) => t.name == name,
      orElse: () => ProtectionType.dailyLimit,
    );
  }
}

/// Model to hold app limit configuration
class AppLimitModel {
  final String packageName;
  final String appName;
  final Uint8List? appIcon;
  final int maxDailyOpens; // Maximum opens per day
  final int delaySeconds; // Mindful pause before the app opens
  final int maxSessionDurationMinutes; // Maximum session duration in minutes
  final List<String> activeDays; // Days when limit is active (e.g., ['MON', 'TUE'])
  final RxString? scheduleStartTime; // Schedule start time (24h format: "22:00")
  final RxString? scheduleEndTime; // Schedule end time (24h format: "06:00")
  final RxBool? isActive; // Whether the schedule is currently active

  /// Which control the user configured for this app.
  final ProtectionType protectionType;

  /// Message shown on the pause screen; null falls back to the default.
  final String? customMessage;

  final DateTime createdAt;

  AppLimitModel({
    required this.packageName,
    required this.appName,
    this.appIcon,
    required this.maxDailyOpens,
    this.delaySeconds = 0,
    required this.maxSessionDurationMinutes,
    required this.activeDays,
    this.scheduleStartTime,
    this.scheduleEndTime,
    this.isActive,
    this.protectionType = ProtectionType.dailyLimit,
    this.customMessage,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert to JSON for storage (without icon bytes)
  Map<String, dynamic> toJson() {
    return {
      'packageName': packageName,
      'appName': appName,
      'maxDailyOpens': maxDailyOpens,
      'delaySeconds': delaySeconds,
      'maxSessionDurationMinutes': maxSessionDurationMinutes,
      'activeDays': activeDays,
      'scheduleStartTime': scheduleStartTime?.value,
      'scheduleEndTime': scheduleEndTime?.value,
      'isActive': isActive?.value,
      'protectionType': protectionType.name,
      'customMessage': customMessage,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory AppLimitModel.fromJson(Map<String, dynamic> json) {
    return AppLimitModel(
      packageName: json['packageName'],
      appName: json['appName'],
      maxDailyOpens: json['maxDailyOpens'],
      delaySeconds: json['delaySeconds'] as int? ?? 0,
      maxSessionDurationMinutes: json['maxSessionDurationMinutes'],
      activeDays: List<String>.from(json['activeDays'] ?? []),
      scheduleStartTime: json['scheduleStartTime'] != null 
          ? RxString(json['scheduleStartTime']) 
          : null,
      scheduleEndTime: json['scheduleEndTime'] != null 
          ? RxString(json['scheduleEndTime']) 
          : null,
      isActive: json['isActive'] != null 
          ? RxBool(json['isActive']) 
          : null,
      protectionType: ProtectionType.fromName(json['protectionType'] as String?),
      customMessage: json['customMessage'] as String?,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  /// Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Create from JSON string
  factory AppLimitModel.fromJsonString(String jsonString) {
    return AppLimitModel.fromJson(jsonDecode(jsonString));
  }

  /// Copy with method
  AppLimitModel copyWith({
    String? packageName,
    String? appName,
    Uint8List? appIcon,
    int? maxDailyOpens,
    int? delaySeconds,
    int? maxSessionDurationMinutes,
    List<String>? activeDays,
    String? scheduleStartTime,
    String? scheduleEndTime,
    bool? isActive,
    ProtectionType? protectionType,
    String? customMessage,
    DateTime? createdAt,
  }) {
    return AppLimitModel(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      appIcon: appIcon ?? this.appIcon,
      maxDailyOpens: maxDailyOpens ?? this.maxDailyOpens,
      delaySeconds: delaySeconds ?? this.delaySeconds,
      maxSessionDurationMinutes: maxSessionDurationMinutes ?? this.maxSessionDurationMinutes,
      activeDays: activeDays ?? this.activeDays,
      scheduleStartTime: scheduleStartTime != null 
          ? RxString(scheduleStartTime) 
          : this.scheduleStartTime,
      scheduleEndTime: scheduleEndTime != null 
          ? RxString(scheduleEndTime) 
          : this.scheduleEndTime,
      isActive: isActive != null 
          ? RxBool(isActive) 
          : this.isActive,
      protectionType: protectionType ?? this.protectionType,
      customMessage: customMessage ?? this.customMessage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Model for selected app to be passed between screens
class SelectedAppInfo {
  final String packageName;
  final String appName;
  final Uint8List? appIcon;

  SelectedAppInfo({
    required this.packageName,
    required this.appName,
    this.appIcon,
  });

  Map<String, dynamic> toJson() {
    return {
      'packageName': packageName,
      'appName': appName,
    };
  }

  factory SelectedAppInfo.fromJson(Map<String, dynamic> json) {
    return SelectedAppInfo(
      packageName: json['packageName'],
      appName: json['appName'],
    );
  }
}
