import 'package:flutter/material.dart';
import 'app_colors.dart';

/// A utility class that defines the application's light and dark themes.
///
/// The `AppTheme` class provides two static theme configurations:
/// - `light`: A light theme using Material 3 design principles.
/// - `dark`: A dark theme using Material 3 design principles.
///
/// Both themes are customized with specific color schemes and app bar settings.
class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.accent,
      surface: AppColors.background,
      onSurface: AppColors.text,
      primaryContainer: AppColors.accent1,
      onPrimaryContainer: AppColors.primary,
      secondaryContainer: AppColors.accent,
      onSecondaryContainer: AppColors.secondary,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
    ),
  );

  static final dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.darkPrimary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkSecondary,
      tertiary: AppColors.darkAccent,
      surface: AppColors.darkBackground,
      onSurface: AppColors.darkText,
      primaryContainer: AppColors.darkAccent1,
      onPrimaryContainer: AppColors.darkPrimary,
      secondaryContainer: AppColors.darkAccent,
      onSecondaryContainer: AppColors.darkSecondary,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
    ),
  );
}
