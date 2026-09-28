import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/core/services/app_limit_storage_service.dart';
import 'package:limit_it_app/core/services/app_usage_service.dart';
import 'package:limit_it_app/core/services/usage_history_service.dart';

enum StatsRange { week, month }

/// Aggregates everything the Statistics tab shows.
///
/// Numbers come from the device (`AppUsageService`) and the saved protections
/// (`AppLimitStorageService`); each load also appends today's snapshot to
/// [UsageHistoryService] so week / month trends become real over time.
class StatsController extends GetxController {
  final RxBool isLoading = true.obs;

  /// Today's totals
  final RxInt screenTimeMinutes = 0.obs;
  final RxInt blockedOpens = 0.obs;
  final RxInt savedMinutes = 0.obs;
  final RxInt goalMinutes = 0.obs;

  /// Per-app usage for today, biggest first.
  final RxList<AppUsageData> todayUsage = <AppUsageData>[].obs;

  /// Saved minutes per protected app, biggest first.
  final RxList<AppSaving> savedByApp = <AppSaving>[].obs;

  /// Stored history, oldest first.
  final RxList<DailyStats> history = <DailyStats>[].obs;

  final RxInt currentStreak = 0.obs;
  final RxInt bestStreak = 0.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;

    try {
      final storage = AppLimitStorageService.instance;

      final usage = await AppUsageService.instance.getTodayAppUsage();
      final limits = await storage.getAppLimits();
      final goal = await storage.getDailyScreenTime() ?? 0;

      final usageByPackage = {for (final u in usage) u.packageName: u};

      var opensBlocked = 0;
      var minutesSaved = 0;
      final savings = <AppSaving>[];

      for (final limit in limits) {
        final today = await storage.getAppUsageToday(limit.packageName);
        final device = usageByPackage[limit.packageName];

        // The stored counters only exist once something has written them for
        // today; the device's own UsageStats launch count is the real number
        // and is what keeps these totals live.
        final opens = today?['opensCount'] ?? device?.openCount ?? 0;
        final usedMinutes =
            today?['usageMinutes'] ?? ((device?.usageTimeMs ?? 0) ~/ 60000);

        if (limit.maxDailyOpens > 0 && opens > limit.maxDailyOpens) {
          opensBlocked += opens - limit.maxDailyOpens;
        }

        // Time kept back = whatever the app would have run past its limit.
        final allowance = limit.maxSessionDurationMinutes;
        final saved = allowance > 0 && usedMinutes > allowance
            ? usedMinutes - allowance
            : 0;

        minutesSaved += saved;
        if (saved > 0) {
          savings.add(
            AppSaving(
              packageName: limit.packageName,
              appName: limit.appName,
              icon: limit.appIcon ?? device?.icon,
              savedMinutes: saved,
            ),
          );
        }
      }

      final totalMinutes =
          usage.fold<int>(0, (sum, u) => sum + (u.usageTimeMs ~/ 60000));

      savings.sort((a, b) => b.savedMinutes.compareTo(a.savedMinutes));
      final sortedUsage = [...usage]
        ..sort((a, b) => b.usageTimeMs.compareTo(a.usageTimeMs));

      screenTimeMinutes.value = totalMinutes;
      blockedOpens.value = opensBlocked;
      savedMinutes.value = minutesSaved;
      goalMinutes.value = goal;
      todayUsage.assignAll(sortedUsage);
      savedByApp.assignAll(savings);

      await UsageHistoryService.instance.recordToday(
        DailyStats(
          date: DateTime.now(),
          screenTimeMinutes: totalMinutes,
          blockedOpens: opensBlocked,
          savedMinutes: minutesSaved,
          goalMinutes: goal,
        ),
      );

      history.assignAll(await UsageHistoryService.instance.getHistory());
      currentStreak.value = await UsageHistoryService.instance.currentStreak();
      bestStreak.value = await UsageHistoryService.instance.bestStreak();
    } catch (e) {
      debugPrint('Error loading stats: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// The last 7 days (week) or the current calendar month, oldest first.
  Future<List<DailyStats>> seriesFor(StatsRange range, {DateTime? month}) {
    final now = DateTime.now();
    if (range == StatsRange.week) {
      return UsageHistoryService.instance
          .getRange(now.subtract(const Duration(days: 6)), now);
    }

    final anchor = month ?? now;
    final first = DateTime(anchor.year, anchor.month, 1);
    final last = DateTime(anchor.year, anchor.month + 1, 0);
    return UsageHistoryService.instance
        .getRange(first, last.isAfter(now) ? now : last);
  }

  /// Percentage change against the previous period; negative means reduced.
  static double reduction(List<DailyStats> current, List<DailyStats> previous) {
    final currentTotal =
        current.fold<int>(0, (sum, s) => sum + s.screenTimeMinutes);
    final previousTotal =
        previous.fold<int>(0, (sum, s) => sum + s.screenTimeMinutes);
    if (previousTotal == 0) return 0;
    return ((currentTotal - previousTotal) / previousTotal) * 100;
  }

  /// "21h 45m"
  static String formatMinutes(int minutes) {
    if (minutes < 60) return '${minutes}m';
    return '${minutes ~/ 60}h ${minutes % 60}m';
  }
}

/// One row of the "Saved by app" list.
class AppSaving {
  const AppSaving({
    required this.packageName,
    required this.appName,
    required this.savedMinutes,
    this.icon,
  });

  final String packageName;
  final String appName;
  final int savedMinutes;
  final dynamic icon;
}
