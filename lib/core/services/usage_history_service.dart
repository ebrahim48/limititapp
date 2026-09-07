import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One stored day of aggregated stats.
class DailyStats {
  const DailyStats({
    required this.date,
    required this.screenTimeMinutes,
    required this.blockedOpens,
    required this.savedMinutes,
    required this.goalMinutes,
  });

  final DateTime date;

  /// Total foreground time across all apps that day.
  final int screenTimeMinutes;

  /// Opens the protections prevented.
  final int blockedOpens;

  /// Minutes kept back by the protections.
  final int savedMinutes;

  /// Daily screen-time goal that was in effect.
  final int goalMinutes;

  bool get goalMet => goalMinutes > 0 && screenTimeMinutes <= goalMinutes;

  Map<String, dynamic> toJson() => {
        'date': _dayKey(date),
        'screenTimeMinutes': screenTimeMinutes,
        'blockedOpens': blockedOpens,
        'savedMinutes': savedMinutes,
        'goalMinutes': goalMinutes,
      };

  factory DailyStats.fromJson(Map<String, dynamic> json) => DailyStats(
        date: DateTime.parse(json['date'] as String),
        screenTimeMinutes: (json['screenTimeMinutes'] as num?)?.toInt() ?? 0,
        blockedOpens: (json['blockedOpens'] as num?)?.toInt() ?? 0,
        savedMinutes: (json['savedMinutes'] as num?)?.toInt() ?? 0,
        goalMinutes: (json['goalMinutes'] as num?)?.toInt() ?? 0,
      );

  static String _dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

/// Keeps a rolling history of daily stats in SharedPreferences so the
/// Statistics screens can show real week / month trends instead of samples.
class UsageHistoryService {
  static const String _key = 'usage_history';
  static const int _maxDays = 400;

  UsageHistoryService._();

  static UsageHistoryService? _instance;
  static UsageHistoryService get instance =>
      _instance ??= UsageHistoryService._();

  Future<List<DailyStats>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return [];

      final list = jsonDecode(raw) as List<dynamic>;
      final stats = list
          .map((e) => DailyStats.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      return stats;
    } catch (e) {
      debugPrint('Error reading usage history: $e');
      return [];
    }
  }

  /// Writes today's numbers, replacing any entry already stored for today.
  Future<void> recordToday(DailyStats stats) async {
    try {
      final history = await getHistory();
      final todayKey = DailyStats._dayKey(stats.date);
      history.removeWhere((s) => DailyStats._dayKey(s.date) == todayKey);
      history.add(stats);
      history.sort((a, b) => a.date.compareTo(b.date));

      final trimmed = history.length > _maxDays
          ? history.sublist(history.length - _maxDays)
          : history;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode(trimmed.map((s) => s.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Error writing usage history: $e');
    }
  }

  /// The days in [from, to] inclusive, missing days filled with zeroes so the
  /// charts always have a complete series.
  Future<List<DailyStats>> getRange(DateTime from, DateTime to) async {
    final history = await getHistory();
    final byDay = {for (final s in history) DailyStats._dayKey(s.date): s};

    final result = <DailyStats>[];
    var cursor = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);

    while (!cursor.isAfter(end)) {
      result.add(
        byDay[DailyStats._dayKey(cursor)] ??
            DailyStats(
              date: cursor,
              screenTimeMinutes: 0,
              blockedOpens: 0,
              savedMinutes: 0,
              goalMinutes: 0,
            ),
      );
      cursor = cursor.add(const Duration(days: 1));
    }
    return result;
  }

  /// Current run of consecutive days (ending today) where the goal was met.
  Future<int> currentStreak() async {
    final history = await getHistory();
    if (history.isEmpty) return 0;

    var streak = 0;
    for (final stats in history.reversed) {
      if (!stats.goalMet) break;
      streak++;
    }
    return streak;
  }

  /// Longest run of consecutive goal-met days ever recorded.
  Future<int> bestStreak() async {
    final history = await getHistory();
    var best = 0;
    var run = 0;
    for (final stats in history) {
      if (stats.goalMet) {
        run++;
        if (run > best) best = run;
      } else {
        run = 0;
      }
    }
    return best;
  }
}
