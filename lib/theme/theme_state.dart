import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:learning_admin_app/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends StateNotifier<ThemeData> {
  static const _themeKey = 'isDarkMode';

  ThemeNotifier() : super(lightmode) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;
    state = isDark ? darkmode : lightmode;
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = state.brightness == Brightness.dark;

    state = isDark ? lightmode : darkmode;
    await prefs.setBool(_themeKey, !isDark);
  }

  Future<void> enableDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    state = darkmode;
    await prefs.setBool(_themeKey, true);
  }

  Future<void> enableLightMode() async {
    final prefs = await SharedPreferences.getInstance();
    state = lightmode;
    await prefs.setBool(_themeKey, false);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>(
  (ref) => ThemeNotifier(),
);
