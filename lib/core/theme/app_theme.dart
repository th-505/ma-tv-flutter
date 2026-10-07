import 'package:flutter/material.dart';

class AppColors {
  // Gold Palette
  static const Color gold50 = Color(0xFFFBF5E0);
  static const Color gold100 = Color(0xFFF5E6B8);
  static const Color gold200 = Color(0xFFEFD490);
  static const Color gold300 = Color(0xFFE5C16A);
  static const Color gold400 = Color(0xFFD4AF37); // Primary Brand Gold
  static const Color gold500 = Color(0xFFC9A227);
  static const Color gold600 = Color(0xFFB08A1E);
  static const Color gold700 = Color(0xFF8F6F16);
  static const Color gold800 = Color(0xFF6E5610);
  static const Color gold900 = Color(0xFF4D3C0B);

  // Dark Neutral Palette
  static const Color darkBg = Color(0xFF0A0A0B);
  static const Color darkSecondary = Color(0xFF131316);
  static const Color darkElevated = Color(0xFF1A1A1E);
  static const Color darkElevatedHover = Color(0xFF222227);
  static const Color darkSurface = Color(0xFF2A2A30);
  static const Color darkBorder = Color(0x1AFFFFFF);

  // Light Neutral Palette
  static const Color lightBg = Color(0xFFF8F9FA);
  static const Color lightSecondary = Color(0xFFFFFFFF);
  static const Color lightElevated = Color(0xFFEDEDF3);
  static const Color lightElevatedHover = Color(0xFFE2E2EC);
  static const Color lightSurface = Color(0xFFDADAE5);
  static const Color lightBorder = Color(0x1A000000);

  // Accents
  static const Color success = Color(0xFF3DD68C);
  static const Color warning = Color(0xFFF5A623);
  static const Color error = Color(0xFFE5484D);
  static const Color info = Color(0xFF3B82F6);
}

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.gold400,
      secondary: AppColors.gold300,
      surface: AppColors.darkElevated,
      error: AppColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBg,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.gold400,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
    ),
    fontFamily: 'Cairo',
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBg,
    colorScheme: const ColorScheme.light(
      primary: AppColors.gold600,
      secondary: AppColors.gold500,
      surface: AppColors.lightElevated,
      error: AppColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBg,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.gold700,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
    ),
    fontFamily: 'Cairo',
  );
}
