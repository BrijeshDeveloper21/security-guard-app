import 'package:flutter/material.dart';
import 'package:security_app/core/theme/app_colors.dart';
import 'package:security_app/core/theme/app_typography.dart';

class AppTheme {
  static ThemeData get highContrastTheme {
    final base = lightTheme;
    const highContrastBorder = BorderSide(color: Colors.black, width: 2);
    final highContrastScheme = ColorScheme.highContrastLight().copyWith(
      primary: const Color(0xFF0037B3),
      onPrimary: Colors.white,
      secondary: Colors.black,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      onSurfaceVariant: Colors.black,
      error: const Color(0xFFB00020),
      onError: Colors.white,
      outline: Colors.black,
      outlineVariant: const Color(0xFF555555),
    );

    return base.copyWith(
      brightness: Brightness.light,
      colorScheme: highContrastScheme,
      scaffoldBackgroundColor: Colors.white,
      canvasColor: Colors.white,
      textTheme: base.textTheme.apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
      ),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        titleTextStyle: base.appBarTheme.titleTextStyle?.copyWith(
          color: Colors.black,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      cardTheme: base.cardTheme.copyWith(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: highContrastBorder,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0037B3),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          side: const BorderSide(color: Colors.black, width: 2),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 54),
          side: highContrastBorder,
        ),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        enabledBorder: const OutlineInputBorder(borderSide: highContrastBorder),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF0037B3), width: 3),
        ),
        labelStyle: const TextStyle(color: Colors.black),
        hintStyle: const TextStyle(color: Color(0xFF333333)),
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.black,
        thickness: 2,
        space: 24,
      ),
    );
  }

  static InputDecorationTheme get dialogInputTheme {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: AppColors.borderDark),
    );

    return const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardDark,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
      ),
      labelStyle: TextStyle(color: AppColors.textSecondaryDark),
      hintStyle: TextStyle(color: AppColors.textMutedDark),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surfaceDark,
        error: AppColors.statusRejected,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.titleLarge(true),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          side: const BorderSide(color: AppColors.borderDark, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondaryDark),
        hintStyle: const TextStyle(color: AppColors.textMutedDark),
      ),
      useMaterial3: true,
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgLight,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surfaceLight,
        error: AppColors.statusRejected,
        onSurface: AppColors.textPrimaryLight,
        onSurfaceVariant: AppColors.textSecondaryLight,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        shadowColor: AppColors.shadowLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.titleLarge(false),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 54),
          side: const BorderSide(color: AppColors.borderLight, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondaryLight),
        hintStyle: const TextStyle(color: AppColors.textMutedLight),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 24,
      ),
      useMaterial3: true,
    );
  }
}
