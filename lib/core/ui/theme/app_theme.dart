import 'package:flutter/material.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light = ThemeData(
    useMaterial3: true,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.scaffold,
    fontFamily: AppTypography.fontFamily,

    // Цветовая схема Material
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      background: AppColors.background,
      error: AppColors.error,
      brightness: Brightness.light,
    ),

    textTheme: AppTypography.textTheme,

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        textStyle: AppTypography.textTheme.titleLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(60),
        ),
        elevation: 0,
      ),
    ),

    // Поля ввода
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.greyBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      hintStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
      ),
      labelStyle: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
      ),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.scaffold,
      elevation: 0,
      foregroundColor: AppColors.textPrimary,
      centerTitle: true,
    ),

    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.error,
      contentTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
    ),
  );
}