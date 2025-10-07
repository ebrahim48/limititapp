import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ThemeController extends GetxController {
  // Default theme is Light mode
  Rx<ThemeMode> themeMode = ThemeMode.dark.obs;

  // Toggle between light and dark mode
  void toggleTheme() {
    themeMode.value = themeMode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}
