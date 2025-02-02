import 'package:flutter/material.dart';

/// Helper to assist with toggling between light and dark mode
class ThemeManager {
  static final ValueNotifier<ThemeMode> themeNotifier =
  ValueNotifier(ThemeMode.light);

  static void toggleTheme() {
    themeNotifier.value =
    themeNotifier.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}
