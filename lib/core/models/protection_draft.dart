import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/core/models/app_limit_model.dart';

/// The protection being built by the add-protection wizard.
///
/// Carried from the app picker through the config step to the review screen,
/// and turned into an [AppLimitModel] only when the user hits Activate.
class ProtectionDraft {
  const ProtectionDraft({
    required this.app,
    required this.type,
    this.delaySeconds = 10,
    this.dailyLimitMinutes = 30,
    this.maxOpens = 5,
    this.blockStart = const TimeOfDay(hour: 22, minute: 0),
    this.blockEnd = const TimeOfDay(hour: 7, minute: 0),
  });

  final SelectedAppInfo app;
  final ProtectionType type;
  final int delaySeconds;
  final int dailyLimitMinutes;
  final int maxOpens;
  final TimeOfDay blockStart;
  final TimeOfDay blockEnd;

  ProtectionDraft copyWith({
    int? delaySeconds,
    int? dailyLimitMinutes,
    int? maxOpens,
    TimeOfDay? blockStart,
    TimeOfDay? blockEnd,
  }) {
    return ProtectionDraft(
      app: app,
      type: type,
      delaySeconds: delaySeconds ?? this.delaySeconds,
      dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
      maxOpens: maxOpens ?? this.maxOpens,
      blockStart: blockStart ?? this.blockStart,
      blockEnd: blockEnd ?? this.blockEnd,
    );
  }

  static String formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  /// The draft as it is stored. Only the fields the chosen [type] uses are
  /// filled in, so a switch of type never leaves a stale limit behind.
  AppLimitModel toLimit({DateTime? createdAt, String? customMessage}) {
    return AppLimitModel(
      packageName: app.packageName,
      appName: app.appName,
      appIcon: app.appIcon,
      maxDailyOpens: type == ProtectionType.maxOpens ? maxOpens : 0,
      delaySeconds: type == ProtectionType.delayOpening ? delaySeconds : 0,
      maxSessionDurationMinutes:
          type == ProtectionType.dailyLimit ? dailyLimitMinutes : 0,
      activeDays: const ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'],
      scheduleStartTime: type == ProtectionType.timeBlock
          ? RxString(formatTime(blockStart))
          : null,
      scheduleEndTime: type == ProtectionType.timeBlock
          ? RxString(formatTime(blockEnd))
          : null,
      isActive: RxBool(true),
      protectionType: type,
      customMessage: customMessage,
      createdAt: createdAt,
    );
  }
}
