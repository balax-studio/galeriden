import 'package:flutter/material.dart';

/// 2026 "Quiet Luxury" Color Palette for Galeriden
class AppColors {
  AppColors._();

  // Background Colors (Obsidian Midnight & Cream Paper)
  static const Color backgroundDark = Color(0xFF07080B);
  static const Color backgroundLight = Color(0xFFF7F5F0);

  // Surface & Card Colors (Double-Bezel Hardware Architecture)
  static const Color surfaceDark = Color(0xFF12151C);
  static const Color surfaceShellDark = Color(0xFF1A1E29);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceBorderDark = Color(0xFF262C3D);
  static const Color surfaceBorderLight = Color(0xFFE2DDD5);

  // Ultra-Premium Automotive Luxury Accents (Champagne Gold & Platinum)
  static const Color primaryAmber = Color(0xFFE5C158); // Champagne Imperial Gold
  static const Color primaryAmberLight = Color(0xFFF3D684);
  static const Color secondarySage = Color(0xFF38BDF8); // Platinum Ice Slate
  static const Color secondarySageLight = Color(0xFF7DD3FC);

  // Status & Feedback Colors
  static const Color successGreen = Color(0xFF10B981); // Rich Emerald Cash
  static const Color warningOrange = Color(0xFFF59E0B); // Amber Warning
  static const Color errorRed = Color(0xFFF43F5E);     // Crimson Risk
  static const Color infoBlue = Color(0xFF64748B);     // Muted Slate

  // Text Colors (Warm Ivory & Warm Grey)
  static const Color textPrimaryDark = Color(0xFFF8F6F0);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);

  // Body Part Condition Colors (Expertise Inspection Map)
  static const Color partOriginal = Color(0xFF10B981); // Green
  static const Color partPainted = Color(0xFFF59E0B);  // Orange
  static const Color partChanged = Color(0xFFF43F5E);  // Red
  static const Color partDamaged = Color(0xFFA855F7);  // Purple

  // Arcade Tycoon Vibrant Tokens
  // ponytail: reserved for achievement VFX & particle animations (level up, rare achievement unlock, money confetti)
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color arcadeGold = Color(0xFFFFD700);
  static const Color electricPurple = Color(0xFFB026FF);
  static const Color laserGreen = Color(0xFF00FF66);
  static const Color isometricGridDark = Color(0xFF171B26);
  static const Color isometricGridLight = Color(0xFFE6ECEF);

  // Beneloil Style Game UI Tokens
  static const Color beneloilRed = Color(0xFFDC2626);
  static const Color beneloilPillBg = Color(0xFFFFFFFF);
  static const Color beneloilGrassGreen = Color(0xFF8BBF52);
  static const Color beneloilAsphaltRoad = Color(0xFF4A4E58);

  // Neo-Brutalism & Monolithic Block Tokens
  static const Color brutalYellow = Color(0xFFFFDE59);
  static const Color brutalCyan = Color(0xFF00F0FF);
  static const Color brutalPink = Color(0xFFFF54B0);
  static const Color brutalOrange = Color(0xFFFF7A00);
  static const Color brutalGreen = Color(0xFF00E575);
  static const Color brutalRed = Color(0xFFEF4444);
  static const Color brutalPurple = Color(0xFFA855F7);
  static const Color brutalBlue = Color(0xFF3B82F6);
  static const Color brutalDarkBg = Color(0xFF0C0E14);
  static const Color brutalDarkSurface = Color(0xFF141721);
  static const Color brutalDarkBorder = Color(0xFF2A3142);
  static const Color brutalLightBg = Color(0xFFF4F4F0);
  static const Color brutalLightSurface = Color(0xFFFFFFFF);
  static const Color brutalLightBorder = Color(0xFF0F172A);
  static const Color brutalShadowDark = Color(0xFF000000);
  static const Color brutalShadowLight = Color(0xFF0F172A);

  // Absurd Cyber Neo-Brutal Tokens ("Toksik Asit & Siber Galeri")
  static const Color toxicLime = Color(0xFFCCFF00);       // Ultra-vibrant Acid Lime
  static const Color hotMagenta = Color(0xFFFF007F);      // Hyper Neon Fuchsia
  static const Color cyberNightBg = Color(0xFF09060F);    // Obsidian Cyber Void
  static const Color cyberSurface = Color(0xFF140D24);    // Deep Acid Indigo
  static const Color cyberSurfaceBorder = Color(0xFFCCFF00); // Acid Stroke
  static const Color cyberLilac = Color(0xFFD8B4FE);      // Secondary Text Lilac
  static const Color neonMint = Color(0xFF00FF9D);        // Terminal Mint
}

/// 8-Point Neo-Brutalist Layout Grid & Spacing Standard
class AppSpacing {
  AppSpacing._();

  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;
}
