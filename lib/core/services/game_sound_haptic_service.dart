import 'package:flutter/services.dart';

/// Centralized Haptic & Sound Effects Manager for Galeriden Tycoon (§4.1)
class GameSoundHapticService {
  GameSoundHapticService._();

  static bool isSoundEnabled = true;
  static bool isHapticEnabled = true;

  /// 1. Subtle click for button & navigation interactions
  static Future<void> playClick() async {
    if (isSoundEnabled) {
      try {
        await SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
    if (isHapticEnabled) {
      try {
        await HapticFeedback.selectionClick();
      } catch (_) {}
    }
  }

  /// 2. Cash transaction & sales revenue feedback
  static Future<void> playCashSuccess() async {
    if (isSoundEnabled) {
      try {
        await SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
    if (isHapticEnabled) {
      try {
        await HapticFeedback.mediumImpact();
      } catch (_) {}
    }
  }

  /// 3. Notary Signature & Official Sale Contract Completion
  static Future<void> playNotaryStamp() async {
    if (isSoundEnabled) {
      try {
        await SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
    if (isHapticEnabled) {
      try {
        await HapticFeedback.heavyImpact();
      } catch (_) {}
    }
  }

  /// 4. Engine start / rev sound trigger
  static Future<void> playEngineRev() async {
    if (isHapticEnabled) {
      try {
        await HapticFeedback.mediumImpact();
      } catch (_) {}
    }
  }

  /// 5. Car Keys Handover / Delivery
  static Future<void> playKeyJingle() async {
    if (isHapticEnabled) {
      try {
        await HapticFeedback.lightImpact();
      } catch (_) {}
    }
  }

  /// 6. Esnaf Tea Spoon Stirring in Negotiation
  static Future<void> playTeaStir() async {
    if (isHapticEnabled) {
      try {
        await HapticFeedback.selectionClick();
      } catch (_) {}
    }
  }

  /// 7. Warning / Fraud / Police Raid Alert
  static Future<void> playWarningVibration() async {
    if (isHapticEnabled) {
      try {
        await HapticFeedback.vibrate();
      } catch (_) {}
    }
  }

  /// 8. Auction Gavel / Hammer Drop
  static Future<void> playAuctionHammer() async {
    if (isSoundEnabled) {
      try {
        await SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
    if (isHapticEnabled) {
      try {
        await HapticFeedback.heavyImpact();
      } catch (_) {}
    }
  }

  /// 9. Level Up / Milestone Double Tap Haptic
  static Future<void> playLevelUp() async {
    if (isHapticEnabled) {
      try {
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.mediumImpact();
      } catch (_) {}
    }
  }

  /// 10. Car Wash Foam & Rinse
  static Future<void> playCarWash() async {
    if (isHapticEnabled) {
      try {
        await HapticFeedback.lightImpact();
      } catch (_) {}
    }
  }

  /// 11. Police / Bailiff Seizure Intervention
  static Future<void> playPoliceRaid() async {
    if (isHapticEnabled) {
      try {
        await HapticFeedback.vibrate();
        await Future.delayed(const Duration(milliseconds: 150));
        await HapticFeedback.vibrate();
      } catch (_) {}
    }
  }

  /// 12. Barn Find 5-Stage Restoration Progress Ratchet
  static Future<void> playRestorationProgress() async {
    if (isHapticEnabled) {
      try {
        await HapticFeedback.mediumImpact();
      } catch (_) {}
    }
  }

  /// 13. Heavy Industrial Rocker Switch / Toggle Snapping
  static Future<void> playSwitchToggle([bool state = true]) async {
    if (isSoundEnabled) {
      try {
        await SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
    if (isHapticEnabled) {
      try {
        if (state) {
          await HapticFeedback.mediumImpact();
        } else {
          await HapticFeedback.lightImpact();
        }
      } catch (_) {}
    }
  }

  /// 14. Mechanical Rolling Counter & Odometer Gear Tick
  static Future<void> playCounterTick() async {
    if (isHapticEnabled) {
      try {
        await HapticFeedback.selectionClick();
      } catch (_) {}
    }
  }

  /// 15. Heavy Rubber Stamp / Official Notary & Expertise Seal Slam
  static Future<void> playStampSlam() async {
    if (isSoundEnabled) {
      try {
        await SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
    if (isHapticEnabled) {
      try {
        await HapticFeedback.heavyImpact();
      } catch (_) {}
    }
  }

  /// Legacy aliases
  static Future<void> playTapImpact() async {
    if (isHapticEnabled) {
      try {
        await HapticFeedback.selectionClick();
      } catch (_) {}
    }
  }

  static Future<void> playNotarySignature() => playNotaryStamp();
  static Future<void> playAuctionBid() => playAuctionHammer();
}
