import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A controller for managing the application's theme mode.
///
/// Properties:
/// - [_themeMode]: The current theme mode of the application.
/// - [themeMode]: A getter to access the current theme mode.
///
/// Methods:
/// - [toggleTheme]: Updates the theme mode and persists the selection.
/// - [_loadTheme]: Loads the saved theme mode from shared preferences during initialization.
///
/// Throws:
/// - [Exception]: If an error occurs while accessing shared preferences.
class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  ThemeController() {
    _loadTheme();
  }

  /// Toggles the theme mode between light, dark, and system modes.
  void toggleTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.name);
  }

  /// Loads the saved theme mode from shared preferences.
  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('themeMode');
    if (saved != null) {
      _themeMode = ThemeMode.values.firstWhere((e) => e.name == saved);
      notifyListeners();
    }
  }
}
