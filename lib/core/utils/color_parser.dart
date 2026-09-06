import 'package:flutter/material.dart';

/// Single source of truth for parsing vehicle color hex strings robustly (B5)
/// Handles '#RRGGBB', '0xFFRRGGBB', bare 'RRGGBB', 'RRGGBBAA', with safe fallbacks.
class ColorParser {
  ColorParser._();

  static const Color defaultCarFallbackColor = Color(0xFF64748B);

  /// Safely parses a hex color string into a Flutter [Color].
  /// Never throws [FormatException]; falls back to [fallback] on invalid inputs.
  static Color parseCarColor(String? hex, [Color fallback = defaultCarFallbackColor]) {
    if (hex == null) return fallback;
    final cleaned = hex.trim().replaceFirst('#', '').replaceFirst(RegExp(r'^0[xX]'), '');
    if (cleaned.isEmpty) return fallback;

    try {
      if (cleaned.length == 6) {
        return Color(int.parse('FF$cleaned', radix: 16));
      } else if (cleaned.length == 8) {
        return Color(int.parse(cleaned, radix: 16));
      }
    } catch (_) {
      return fallback;
    }
    return fallback;
  }

  /// Normalizes any color hex string into '#RRGGBB' format.
  static String normalizeCarHex(String? hex, [String fallback = '#64748B']) {
    if (hex == null) return fallback;
    final cleaned = hex.trim().replaceFirst('#', '').replaceFirst(RegExp(r'^0[xX]'), '');
    if (cleaned.length == 6) {
      return '#${cleaned.toUpperCase()}';
    } else if (cleaned.length == 8) {
      // If 8 chars, assume AARRGGBB, extract RRGGBB
      return '#${cleaned.substring(2).toUpperCase()}';
    }
    return fallback;
  }
}
