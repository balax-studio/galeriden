import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme_extension.dart';
import '../../data/models/theme_palette_model.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

class ThemeState {
  final ThemePaletteModel activePalette;
  final List<ThemePaletteModel> availablePalettes;

  ThemeState({
    required this.activePalette,
    required this.availablePalettes,
  });

  ThemeData buildThemeData() {
    final isDark = activePalette.isDark;
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: activePalette.backgroundColor,
      colorScheme: _buildColorScheme(isDark),
      appBarTheme: _buildAppBarTheme(),
      tabBarTheme: _buildTabBarTheme(isDark),
      cardTheme: _buildCardTheme(),
      elevatedButtonTheme: _buildElevatedButtonTheme(isDark),
      outlinedButtonTheme: _buildOutlinedButtonTheme(),
      inputDecorationTheme: _buildInputDecorationTheme(),
      chipTheme: _buildChipTheme(),
      dialogTheme: _buildDialogTheme(),
      bottomSheetTheme: _buildBottomSheetTheme(),
      pageTransitionsTheme: _buildPageTransitionsTheme(),
      extensions: [
        AppThemeExtension(palette: activePalette),
      ],
    );
  }

  ColorScheme _buildColorScheme(bool isDark) {
    return ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: activePalette.primaryColor,
      onPrimary: activePalette.backgroundColor,
      secondary: activePalette.secondaryColor,
      onSecondary: Colors.white,
      error: activePalette.errorColor,
      onError: Colors.white,
      surface: activePalette.surfaceColor,
      onSurface: activePalette.textPrimaryColor,
    );
  }

  AppBarTheme _buildAppBarTheme() {
    return AppBarTheme(
      backgroundColor: activePalette.surfaceColor,
      foregroundColor: activePalette.textPrimaryColor,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.8,
        color: activePalette.textPrimaryColor,
      ),
      shape: Border(
        bottom: BorderSide(
          color: activePalette.surfaceBorderColor,
          width: 2.0,
        ),
      ),
    );
  }

  TabBarThemeData _buildTabBarTheme(bool isDark) {
    return TabBarThemeData(
      dividerColor: Colors.transparent,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: BoxDecoration(
        color: activePalette.primaryColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: activePalette.surfaceBorderColor,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: activePalette.surfaceBorderColor,
            offset: const Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      labelColor: const Color(0xFF0F172A),
      unselectedLabelColor:
          isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 13,
        letterSpacing: 0.3,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 13,
        letterSpacing: 0.3,
      ),
    );
  }

  CardThemeData _buildCardTheme() {
    return CardThemeData(
      color: activePalette.surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: activePalette.surfaceBorderColor, width: 1),
      ),
    );
  }

  ElevatedButtonThemeData _buildElevatedButtonTheme(bool isDark) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: activePalette.primaryColor,
        foregroundColor: isDark ? const Color(0xFF0D0D0F) : Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
              color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
              width: 2.0),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
          fontSize: 14,
        ),
      ),
    );
  }

  OutlinedButtonThemeData _buildOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: activePalette.textPrimaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        side: BorderSide(color: activePalette.surfaceBorderColor, width: 2.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
          fontSize: 13,
        ),
      ),
    );
  }

  InputDecorationTheme _buildInputDecorationTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: activePalette.surfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            BorderSide(color: activePalette.surfaceBorderColor, width: 2.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            BorderSide(color: activePalette.surfaceBorderColor, width: 2.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: activePalette.primaryColor, width: 2.0),
      ),
      hintStyle:
          TextStyle(color: activePalette.textSecondaryColor, fontSize: 13),
    );
  }

  ChipThemeData _buildChipTheme() {
    return ChipThemeData(
      backgroundColor: activePalette.surfaceColor,
      selectedColor: activePalette.primaryColor.withValues(alpha: 0.2),
      secondarySelectedColor: activePalette.primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: activePalette.surfaceBorderColor, width: 1.5),
      ),
      labelStyle: TextStyle(
          color: activePalette.textPrimaryColor,
          fontSize: 12,
          fontWeight: FontWeight.w700),
    );
  }

  DialogThemeData _buildDialogTheme() {
    return DialogThemeData(
      backgroundColor: activePalette.surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: activePalette.surfaceBorderColor, width: 2.5),
      ),
    );
  }

  BottomSheetThemeData _buildBottomSheetTheme() {
    return BottomSheetThemeData(
      backgroundColor: activePalette.surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: activePalette.surfaceBorderColor, width: 2.5),
      ),
    );
  }

  PageTransitionsTheme _buildPageTransitionsTheme() {
    return const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        TargetPlatform.fuchsia: CupertinoPageTransitionsBuilder(),
      },
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier()
      : super(ThemeState(
          activePalette: ThemePaletteModel.defaultPalettes.first,
          availablePalettes: ThemePaletteModel.defaultPalettes,
        )) {
    _loadThemeState();
  }

  static const String _storageKey = 'theme_palettes_v3';
  static const String _activeIdKey = 'active_palette_id_v3';

  Future<void> _loadThemeState() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    final activeId = prefs.getString(_activeIdKey) ?? 'sanayi_ciragi_light';

    List<ThemePaletteModel> basePalettes =
        List<ThemePaletteModel>.from(ThemePaletteModel.defaultPalettes);

    if (jsonString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        final storedList = decoded
            .map((item) =>
                ThemePaletteModel.fromJson(item as Map<String, dynamic>))
            .toList();
        final unlockedIds =
            storedList.where((p) => p.isUnlocked).map((p) => p.id).toSet();

        basePalettes = basePalettes.map((p) {
          if (unlockedIds.contains(p.id)) {
            return p.copyWith(isUnlocked: true);
          }
          return p;
        }).toList();
      } catch (e) {
        debugPrint('Theme load error: $e');
        // Fallback to defaults
      }
    }

    final active = basePalettes.firstWhere(
      (p) => p.id == activeId,
      orElse: () => basePalettes.first,
    );

    state = ThemeState(
      activePalette: active,
      availablePalettes: basePalettes,
    );
  }

  Future<void> _saveThemeState() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString =
        jsonEncode(state.availablePalettes.map((p) => p.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
    await prefs.setString(_activeIdKey, state.activePalette.id);
  }

  /// Select active theme
  void selectPalette(String paletteId) {
    final target = state.availablePalettes.firstWhere((p) => p.id == paletteId);
    if (!target.isUnlocked) return;

    state = ThemeState(
      activePalette: target,
      availablePalettes: state.availablePalettes,
    );
    _saveThemeState();
  }

  /// Unlock/Purchase theme using in-game currency
  bool unlockPalette(String paletteId, double currentBalance) {
    final index = state.availablePalettes.indexWhere((p) => p.id == paletteId);
    if (index == -1) return false;

    final target = state.availablePalettes[index];
    if (target.isUnlocked) return true;
    if (currentBalance < target.price) return false;

    final updated = target.copyWith(isUnlocked: true);
    final newList = List<ThemePaletteModel>.from(state.availablePalettes);
    newList[index] = updated;

    state = ThemeState(
      activePalette: updated, // Automatically activate upon purchase
      availablePalettes: newList,
    );

    _saveThemeState();
    return true;
  }

  /// Unlock theme instantly by watching a rewarded ad
  bool unlockPaletteViaAd(String paletteId) {
    final index = state.availablePalettes.indexWhere((p) => p.id == paletteId);
    if (index == -1) return false;

    final target = state.availablePalettes[index];
    final updated = target.copyWith(isUnlocked: true);
    final newList = List<ThemePaletteModel>.from(state.availablePalettes);
    newList[index] = updated;

    state = ThemeState(
      activePalette: updated, // Automatically activate upon ad reward
      availablePalettes: newList,
    );

    _saveThemeState();
    return true;
  }
}
