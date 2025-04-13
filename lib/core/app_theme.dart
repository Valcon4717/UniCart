import 'package:flutter/material.dart';
import 'app_colors.dart';

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