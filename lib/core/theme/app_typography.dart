import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// 2026 Quiet Luxury Typography utilizing Outfit, Inter & JetBrains Mono
class AppTypography {
  AppTypography._();

  // Outfit for Headings & Titles
  static TextStyle displayLarge(bool isDark) => GoogleFonts.outfit(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  static TextStyle headlineLarge(bool isDark) => GoogleFonts.outfit(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  static TextStyle headlineMedium(bool isDark) => GoogleFonts.outfit(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  static TextStyle headlineSmall(bool isDark) => GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  static TextStyle titleLarge(bool isDark) => GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  static TextStyle titleMedium(bool isDark) => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  static TextStyle titleSmall(bool isDark) => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  // Inter for Body & UI Controls
  static TextStyle bodyLarge(bool isDark) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  static TextStyle bodyMedium(bool isDark) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      );

  static TextStyle bodySmall(bool isDark) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.3,
        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
      );

  static TextStyle labelLarge(bool isDark) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  static TextStyle labelMedium(bool isDark) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      );

  static TextStyle labelSmall(bool isDark) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
      );

  static TextStyle badgeText(bool isDark) => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.0,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  // JetBrains Mono for Currency, Numbers & Specs with Tabular Figures
  static TextStyle moneyLarge(bool isDark) => GoogleFonts.jetBrainsMono(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: AppColors.primaryAmber,
      );

  static TextStyle moneyMedium(bool isDark) => GoogleFonts.jetBrainsMono(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: AppColors.primaryAmber,
      );

  static TextStyle moneySmall(bool isDark) => GoogleFonts.jetBrainsMono(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: AppColors.primaryAmber,
      );

  static TextStyle statValue(bool isDark) => GoogleFonts.jetBrainsMono(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  static TextStyle monoSpec(bool isDark) => GoogleFonts.jetBrainsMono(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      );

  static TextStyle monoSmall(bool isDark) => GoogleFonts.jetBrainsMono(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      );

  static TextStyle monoTiny(bool isDark) => GoogleFonts.jetBrainsMono(
        fontSize: 9.5,
        fontWeight: FontWeight.w700,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
      );

  static TextStyle stampText({required Color color, double fontSize = 11.0, double letterSpacing = 1.4}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        letterSpacing: letterSpacing,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: color,
      );

  static TextStyle plateText({double fontSize = 14.0, Color color = const Color(0xFF0F172A)}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: color,
      );
}
