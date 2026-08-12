import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsState {
  final ThemeMode themeMode;
  final String languageCode; // 'tr' or 'en'
  final bool isAudioEnabled;

  SettingsState({
    required this.themeMode,
    required this.languageCode,
    required this.isAudioEnabled,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? languageCode,
    bool? isAudioEnabled,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      isAudioEnabled: isAudioEnabled ?? this.isAudioEnabled,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier()
      : super(SettingsState(
          themeMode: ThemeMode.dark,
          languageCode: 'tr',
          isAudioEnabled: true,
        )) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('is_dark_mode') ?? true;
    final lang = prefs.getString('language_code') ?? 'tr';
    final audio = prefs.getBool('audio_enabled') ?? true;

    state = SettingsState(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      languageCode: lang,
      isAudioEnabled: audio,
    );
  }

  Future<void> toggleThemeMode() async {
    final newMode = state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = state.copyWith(themeMode: newMode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', newMode == ThemeMode.dark);
  }

  Future<void> setLanguage(String code) async {
    state = state.copyWith(languageCode: code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', code);
  }

  Future<void> toggleAudio() async {
    final newAudio = !state.isAudioEnabled;
    state = state.copyWith(isAudioEnabled: newAudio);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('audio_enabled', newAudio);
  }
}
