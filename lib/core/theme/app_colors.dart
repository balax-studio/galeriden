import 'package:flutter/material.dart';

/// 2026 "Quiet Luxury" Color Palette for Galerisinden
class AppColors {
  AppColors._();

  // Background Colors (Deep Charcoal & Soft Paper)
  static const Color backgroundDark = Color(0xFF0F1114);
  static const Color backgroundLight = Color(0xFFF5F3EF);

  // Surface & Card Colors
  static const Color surfaceDark = Color(0xFF1B1D22);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceBorderDark = Color(0xFF2A2D35);
  static const Color surfaceBorderLight = Color(0xFFE2DDD5);

  // Accent Colors (Quiet Luxury Imperial Gold & Emerald Teal)
  static const Color primaryAmber = Color(0xFFE8B94A); // Imperial Gold (More vibrant for Tycoon UX)
  static const Color primaryAmberLight = Color(0xFFF5CD68);
  static const Color secondarySage = Color(0xFF2EC4B6); // Active Emerald Teal
  static const Color secondarySageLight = Color(0xFF5CD5C9);

  // Status & Feedback Colors
  static const Color successGreen = Color(0xFF34D399); // Kâr & Başarılı Satış
  static const Color warningOrange = Color(0xFFF59E0B); // Bakım & Dikkat
  static const Color errorRed = Color(0xFFEF4444);     // Hasar & Zarar
  static const Color infoBlue = Color(0xFF64748B);     // Nötr Bilgi

  // Text Colors
  static const Color textPrimaryDark = Color(0xFFF1F0EB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color textMutedDark = Color(0xFF6B7280);

  static const Color textPrimaryLight = Color(0xFF1A1A1E);
  static const Color textSecondaryLight = Color(0xFF6B6760);
  static const Color textMutedLight = Color(0xFFA09B93);

  // Body Part Condition Colors (Expertise Inspection Map)
  static const Color partOriginal = Color(0xFF34D399); // Green
  static const Color partPainted = Color(0xFFF59E0B);  // Orange
  static const Color partChanged = Color(0xFFEF4444);  // Red
  static const Color partDamaged = Color(0xFFA855F7);  // Purple

  // Arcade Tycoon Vibrant Tokens
  // ponytail: reserved for achievement VFX & particle animations (level up, rare achievement unlock, money confetti)
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color arcadeGold = Color(0xFFFFD700);
  static const Color electricPurple = Color(0xFFB026FF);
  static const Color laserGreen = Color(0xFF00FF66);
  static const Color isometricGridDark = Color(0xFF1E222D);
  static const Color isometricGridLight = Color(0xFFE6ECEF);
}
