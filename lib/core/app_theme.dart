import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Global Toggle
  static bool isDark = false;

  // Primary Slate / Navy (Stays the same in both themes)
  static const Color primary = Color(0xFF1E293B);
  static const Color primaryLight = Color(0xFF334155);

  // Accents for Finance (Stays the same)
  static const Color success = Color(0xFF10B981);
  static const Color danger = Color(0xFFE11D48);

  // Neutrals (Dynamic based on Dark Mode)
  static Color get background =>
      isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
  static Color get surface => isDark ? const Color(0xFF1E293B) : Colors.white;
  static Color get textMain => isDark ? Colors.white : const Color(0xFF0F172A);
  static Color get textMuted =>
      isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  static Color get border =>
      isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  static Color get appBarText => isDark ? Colors.white : primary;
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: Colors.white,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.appBarText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.appBarText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.appBarText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.appBarText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
