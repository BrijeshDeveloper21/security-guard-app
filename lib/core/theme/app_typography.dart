import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:security_app/core/theme/app_colors.dart';

class AppTypography {
  static TextStyle displayLarge(bool isDark) => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        letterSpacing: -0.5,
      );

  static TextStyle displayMedium(bool isDark) => GoogleFonts.inter(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        letterSpacing: -0.5,
      );

  static TextStyle titleLarge(bool isDark) => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  static TextStyle titleMedium(bool isDark) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  static TextStyle bodyLarge(bool isDark) => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  static TextStyle bodyMedium(bool isDark) => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      );

  // Large readable text specifically optimized for Security Guard rapid recognition
  static TextStyle guardBigAction() => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: 0.5,
      );

  static TextStyle guardCounter() => GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        letterSpacing: -1,
      );
}
