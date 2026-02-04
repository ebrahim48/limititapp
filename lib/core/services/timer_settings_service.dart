import 'package:shared_preferences/shared_preferences.dart';
import '../models/timer_settings_model.dart';

class TimerSettingsService {
  static const String _timerSettingsKey = 'timer_settings';

  // Singleton instance
  static TimerSettingsService? _instance;
  static TimerSettingsService get instance => _instance ??= TimerSettingsService._internal();
  TimerSettingsService._internal();

  /// Save timer settings to SharedPreferences
  Future<bool> saveTimerSettings(TimerSettingsModel settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = settings.toJsonString();
      return await prefs.setString(_timerSettingsKey, jsonString);
    } catch (e) {
      print('Error saving timer settings: $e');
      return false;
    }
  }

  /// Get timer settings from SharedPreferences
  Future<TimerSettingsModel?> getTimerSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_timerSettingsKey);

      if (jsonString != null) {
        return TimerSettingsModel.fromJsonString(jsonString);
      }

      return null;
    } catch (e) {
      print('Error getting timer settings: $e');
      return null;
    }
  }

  /// Delete timer settings from SharedPreferences
  Future<bool> deleteTimerSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_timerSettingsKey);
    } catch (e) {
      print('Error deleting timer settings: $e');
      return false;
    }
  }

  /// Check if timer settings exist
  Future<bool> hasTimerSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_timerSettingsKey);
    } catch (e) {
      print('Error checking timer settings existence: $e');
      return false;
    }
  }

  /// Get the pre-opening countdown duration
  Future<String> getPreOpeningCountdown() async {
    try {
      final settings = await getTimerSettings();
      return settings?.preOpeningCountdown ?? '0 sec';
    } catch (e) {
      print('Error getting pre-opening countdown: $e');
      return '0 sec';
    }
  }

  /// Get the motivational quotes
  Future<List<MotivationalQuote>> getMotivationalQuotes() async {
    try {
      final settings = await getTimerSettings();
      return settings?.motivationalQuotes ?? [];
    } catch (e) {
      print('Error getting motivational quotes: $e');
      return [];
    }
  }
}