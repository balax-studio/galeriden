import 'package:intl/intl.dart';
import '../localization/app_localizations.dart';

/// Single source of truth for formatting currency across all 7 supported languages (C7)
/// Supports locale-based NumberFormat, clean negative values, and billions tier.
class CurrencyFormatter {
  CurrencyFormatter._();

  static String currentLanguageCode = 'tr';

  static final Map<String, NumberFormat> _cachedFormatters = {};

  static NumberFormat _getFormatter(String langCode) {
    return _cachedFormatters.putIfAbsent(langCode, () {
      final locale = _getLocale(langCode);
      return NumberFormat.currency(
        locale: locale,
        symbol: '₺',
        decimalDigits: 0,
      );
    });
  }

  static String _getLocale(String langCode) {
    switch (langCode.toLowerCase()) {
      case 'en':
        return 'en_US';
      case 'de':
        return 'de_DE';
      case 'pt':
        return 'pt_BR';
      case 'es':
        return 'es_ES';
      case 'ru':
        return 'ru_RU';
      case 'ar':
        return 'ar_SA';
      case 'tr':
      default:
        return 'tr_TR';
    }
  }

  /// Formats an amount with localized grouping separators and currency symbol.
  /// Example: 1500000 -> ₺1.500.000 (tr), ₺1,500,000 (en)
  static String format(num amount, [String? langCode]) {
    final code = langCode ?? currentLanguageCode;
    return _getFormatter(code).format(amount);
  }

  /// Formats an amount compactly with thousand (K/B), million (M), or billion (B/Mrd) suffixes.
  /// Correctly handles negative amounts, zero decimals when whole, and localized suffixes.
  /// Example: -5000 -> -₺5B (tr), -₺5K (en), 1500000000 -> ₺1.5Mrd (tr), ₺1.5B (en)
  static String formatShort(num amount, [String? langCode]) {
    final isNegative = amount < 0;
    final abs = amount.abs().toDouble();
    final sign = isNegative ? '-' : '';
    final code = langCode ?? currentLanguageCode;

    final keys = AppLocalizations.getAllKeysFor(code);
    final kThousand = keys['fmt_thousand'] ?? 'K';
    final kMillion = keys['fmt_million'] ?? 'M';
    final kBillion = keys['fmt_billion'] ?? 'B';

    if (abs >= 1000000000) {
      final val = (abs / 1000000000).toStringAsFixed(1);
      final trimmed = val.endsWith('.0') ? val.substring(0, val.length - 2) : val;
      return '$sign₺$trimmed$kBillion';
    } else if (abs >= 1000000) {
      final val = (abs / 1000000).toStringAsFixed(1);
      final trimmed = val.endsWith('.0') ? val.substring(0, val.length - 2) : val;
      return '$sign₺$trimmed$kMillion';
    } else if (abs >= 1000) {
      final val = (abs / 1000).toStringAsFixed(0);
      return '$sign₺$val$kThousand';
    }
    return '$sign₺${abs.toInt()}';
  }
}
