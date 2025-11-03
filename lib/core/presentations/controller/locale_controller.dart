import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends GetxController {
  // Default locale is Italian
  Rx<Locale> locale = const Locale('it', '').obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedLocale();
  }

  // Load saved locale from SharedPreferences
  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'it';
    locale.value = Locale(languageCode, '');
  }

  // Change locale and save to SharedPreferences
  Future<void> changeLocale(String languageCode) async {
    locale.value = Locale(languageCode, '');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
  }

  // Get current language name
  String get currentLanguageName {
    return locale.value.languageCode == 'it' ? 'Italian' : 'English';
  }
}
