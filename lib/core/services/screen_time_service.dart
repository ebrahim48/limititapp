import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:limit_it_app/core/models/app_limit_model.dart';

/// What Apple's Screen Time currently holds for us.
///
/// Only counts — `FamilyActivityPicker` hands back opaque tokens, so iOS never
/// tells us *which* apps the user picked. The names, icons and usage numbers
/// exist, but only inside views iOS draws for us (see
/// `screen_time_native_views.dart`); they never reach Dart.
class ScreenTimeSelection {
  const ScreenTimeSelection({
    required this.applications,
    required this.categories,
    required this.webDomains,
    required this.shielded,
  });

  final int applications;
  final int categories;
  final int webDomains;

  /// `true` while the shield is applied — the apps are blocked right now.
  final bool shielded;

  static const ScreenTimeSelection empty = ScreenTimeSelection(
    applications: 0,
    categories: 0,
    webDomains: 0,
    shielded: false,
  );

  int get total => applications + categories + webDomains;
  bool get isEmpty => total == 0;

  factory ScreenTimeSelection.fromMap(Map<Object?, Object?> map) {
    int intOf(String key) => (map[key] as num?)?.toInt() ?? 0;
    return ScreenTimeSelection(
      applications: intOf('applications'),
      categories: intOf('categories'),
      webDomains: intOf('webDomains'),
      shielded: map['shielded'] == true,
    );
  }
}

/// Dart side of the Screen Time bridge (see `ios/Runner/ScreenTimeChannel.swift`).
///
/// iOS only. Android blocks through its own accessibility service, so every
/// call here answers "unsupported" there.
class ScreenTimeService {
  static const MethodChannel _channel =
      MethodChannel('com.limitit.digitalbalance/screen_time');

  static ScreenTimeService? _instance;

  ScreenTimeService._();

  static ScreenTimeService get instance => _instance ??= ScreenTimeService._();

  /// iOS 16+ with the FamilyControls framework available.
  Future<bool> isSupported() async {
    if (!Platform.isIOS) return false;
    return await _invoke<bool>('isSupported') ?? false;
  }

  /// `true` when the DeviceActivityReport extension ships with this build.
  ///
  /// Without it the usage view renders an empty rectangle, so the caller hides
  /// it rather than showing a blank card.
  Future<bool> hasUsageReport() async {
    if (!Platform.isIOS) return false;
    return await _invoke<bool>('hasUsageReport') ?? false;
  }

  /// The user has granted Screen Time access.
  Future<bool> isAuthorized() async {
    if (!Platform.isIOS) return false;
    return await _invoke<bool>('isAuthorized') ?? false;
  }

  /// Shows Apple's Screen Time permission prompt.
  ///
  /// Throws [ScreenTimeException] when the user declines or the entitlement is
  /// missing, so the caller can tell the two apart from a plain `false`.
  Future<void> requestAuthorization() async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod<bool>('requestAuthorization');
    } on PlatformException catch (e) {
      throw ScreenTimeException(e.message ?? 'Screen Time authorization failed');
    } on MissingPluginException {
      throw const ScreenTimeException('Screen Time is not available here');
    }
  }

  /// Opens Apple's app picker. Returns `null` when the user cancels.
  ///
  /// A [draft] pick starts empty and is held for the next protection
  /// [syncRules] creates, without touching the Block-now selection.
  Future<ScreenTimeSelection?> pickApps({bool draft = false}) async {
    if (!Platform.isIOS) return null;
    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>(
        'pickApps',
        {'draft': draft},
      );
      return result == null ? null : ScreenTimeSelection.fromMap(result);
    } on PlatformException catch (e) {
      throw ScreenTimeException(e.message ?? 'Could not open the app picker');
    } on MissingPluginException {
      throw const ScreenTimeException('Screen Time is not available here');
    }
  }

  /// Blocks the picked apps. iOS draws the block screen itself.
  Future<ScreenTimeSelection> applyShield() async => _selectionCall('applyShield');

  /// Lifts the block.
  Future<ScreenTimeSelection> clearShield() async => _selectionCall('clearShield');

  Future<ScreenTimeSelection> summary() async => _selectionCall('summary');

  /// Prefix of the ids the wizard gives iOS protections. Apple never reveals
  /// which apps a pick holds, so the rule id stands in for a package name.
  static const String rulePrefix = 'ios-rule-';

  static String newRuleId() =>
      '$rulePrefix${DateTime.now().millisecondsSinceEpoch}';

  /// Hands every iOS protection to the native side, which schedules and
  /// shields them. Sent whole after each change: a rule left out is deleted.
  Future<void> syncRules(List<AppLimitModel> limits) async {
    if (!Platform.isIOS) return;
    final rules = [
      for (final limit in limits)
        if (limit.packageName.startsWith(rulePrefix))
          {
            'id': limit.packageName,
            'type': limit.protectionType.name,
            'isActive': limit.isActive?.value ?? true,
            'activeDays': limit.activeDays,
            'delaySeconds': limit.delaySeconds,
            'dailyLimitMinutes': limit.maxSessionDurationMinutes,
            'maxOpens': limit.maxDailyOpens,
            'blockStart': limit.scheduleStartTime?.value,
            'blockEnd': limit.scheduleEndTime?.value,
            'message': limit.customMessage,
          },
    ];
    await _invoke<List<Object?>>('syncRules', {'rules': rules});
  }

  Future<ScreenTimeSelection> _selectionCall(String method) async {
    if (!Platform.isIOS) return ScreenTimeSelection.empty;
    final result = await _invoke<Map<Object?, Object?>>(method);
    return result == null
        ? ScreenTimeSelection.empty
        : ScreenTimeSelection.fromMap(result);
  }

  Future<T?> _invoke<T>(String method, [Object? arguments]) async {
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } on MissingPluginException {
      return null;
    } on PlatformException catch (e) {
      debugPrint('Screen Time "$method" failed: ${e.message}');
      return null;
    }
  }
}

class ScreenTimeException implements Exception {
  const ScreenTimeException(this.message);

  final String message;

  @override
  String toString() => message;
}
