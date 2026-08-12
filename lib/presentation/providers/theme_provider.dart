import 'dart:convert';
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
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: activePalette.primaryColor,
        onPrimary: activePalette.backgroundColor,
        secondary: activePalette.secondaryColor,
        onSecondary: Colors.white,
        error: activePalette.errorColor,
        onError: Colors.white,
        surface: activePalette.surfaceColor,
        onSurface: activePalette.textPrimaryColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: activePalette.surfaceColor,
        foregroundColor: activePalette.textPrimaryColor,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: activePalette.surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: activePalette.surfaceBorderColor, width: 1),
        ),
      ),
      extensions: [
        AppThemeExtension(palette: activePalette),
      ],
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

  static const String _storageKey = 'theme_palettes_v1';
  static const String _activeIdKey = 'active_palette_id_v1';

  Future<void> _loadThemeState() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    final activeId = prefs.getString(_activeIdKey) ?? 'quiet_luxury_dark';

    List<ThemePaletteModel> loadedList = ThemePaletteModel.defaultPalettes;

    if (jsonString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        loadedList = decoded.map((item) => ThemePaletteModel.fromJson(item as Map<String, dynamic>)).toList();
      } catch (e) {
        // Fallback
      }
    }

    final active = loadedList.firstWhere(
      (p) => p.id == activeId,
      orElse: () => loadedList.first,
    );

    state = ThemeState(
      activePalette: active,
      availablePalettes: loadedList,
    );
  }

  Future<void> _saveThemeState() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(state.availablePalettes.map((p) => p.toJson()).toList());
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
}
