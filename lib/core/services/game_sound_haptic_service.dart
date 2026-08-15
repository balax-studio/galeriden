import 'package:flutter/services.dart';

/// Centralized Haptic & Sound Effects Manager for Galerisinden Tycoon
class GameSoundHapticService {
  GameSoundHapticService._();

  /// Play subtle tactile tap on global screen touch
  static Future<void> playTapImpact() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Play light click haptic for buttons & tabs
  static Future<void> playClick() async {
    try {
      await SystemSound.play(SystemSoundType.click);
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /// Play cash register / money transaction haptic & feedback
  static Future<void> playCashSuccess() async {
    try {
      await SystemSound.play(SystemSoundType.click);
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Play notary signature completion haptic
  static Future<void> playNotarySignature() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  /// Play alert / fraud caught warning vibration
  static Future<void> playWarningVibration() async {
    try {
      await HapticFeedback.vibrate();
    } catch (_) {}
  }

  /// Play auction hammer bid haptic
  static Future<void> playAuctionBid() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }
}
