import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reminder preferences, persisted locally.
///
/// The switches decide which local notifications the app schedules; the
/// delivery itself is handled by the platform notification channel.
class RemindersController extends GetxController {
  static const String _keyDailyCheckIn = 'reminder_daily_checkin';
  static const String _keyCheckInHour = 'reminder_checkin_hour';
  static const String _keyCheckInMinute = 'reminder_checkin_minute';
  static const String _keyGoalAlert = 'reminder_goal_alert';
  static const String _keyWeeklyReport = 'reminder_weekly_report';
  static const String _keyBreakReminder = 'reminder_break';

  final RxBool dailyCheckIn = true.obs;
  final RxBool goalAlert = true.obs;
  final RxBool weeklyReport = false.obs;
  final RxBool breakReminder = false.obs;

  /// Time of the daily check-in nudge.
  final Rx<TimeOfDay> checkInTime =
      const TimeOfDay(hour: 23, minute: 0).obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    dailyCheckIn.value = prefs.getBool(_keyDailyCheckIn) ?? true;
    goalAlert.value = prefs.getBool(_keyGoalAlert) ?? true;
    weeklyReport.value = prefs.getBool(_keyWeeklyReport) ?? false;
    breakReminder.value = prefs.getBool(_keyBreakReminder) ?? false;
    checkInTime.value = TimeOfDay(
      hour: prefs.getInt(_keyCheckInHour) ?? 23,
      minute: prefs.getInt(_keyCheckInMinute) ?? 0,
    );
  }

  Future<void> setDailyCheckIn(bool value) async {
    dailyCheckIn.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDailyCheckIn, value);
  }

  Future<void> setGoalAlert(bool value) async {
    goalAlert.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyGoalAlert, value);
  }

  Future<void> setWeeklyReport(bool value) async {
    weeklyReport.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyWeeklyReport, value);
  }

  Future<void> setBreakReminder(bool value) async {
    breakReminder.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBreakReminder, value);
  }

  Future<void> setCheckInTime(TimeOfDay time) async {
    checkInTime.value = time;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCheckInHour, time.hour);
    await prefs.setInt(_keyCheckInMinute, time.minute);
  }
}
