import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  ThemeController() {
    _loadTheme();
  }

  void toggleTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.name);
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('themeMode');
    if (saved != null) {
      _themeMode = ThemeMode.values.firstWhere((e) => e.name == saved);
      notifyListeners();
    }
  }
}