import 'package:flutter/widgets.dart';

import 'translations/ar_translations.dart';
import 'translations/de_translations.dart';
import 'translations/en_translations.dart';
import 'translations/es_translations.dart';
import 'translations/pt_translations.dart';
import 'translations/ru_translations.dart';
import 'translations/tr_translations.dart';

class AppLocalizations {
  final String languageCode;

  const AppLocalizations(this.languageCode);

  static const Map<String, Map<String, String>> _localizedValues = {
    'tr': trTranslations,
    'en': enTranslations,
    'de': deTranslations,
    'pt': ptTranslations,
    'es': esTranslations,
    'ru': ruTranslations,
    'ar': arTranslations,
  };

  String get(String key, [Map<String, dynamic>? params]) {
    String? translation = _localizedValues[languageCode]?[key];
    if (translation == null || translation.isEmpty) {
      // Fallback to English, then Turkish
      translation = _localizedValues['en']?[key] ?? _localizedValues['tr']?[key] ?? key;
    }

    if (params != null && params.isNotEmpty) {
      params.forEach((paramKey, value) {
        translation = translation!.replaceAll('{$paramKey}', value.toString());
      });
    }

    return translation!;
  }

  static AppLocalizations of(BuildContext context) {
    final locale = Localizations.maybeLocaleOf(context);
    final code = locale?.languageCode ?? 'tr';
    return AppLocalizations(code);
  }

  static String tr(BuildContext context, String key, [Map<String, dynamic>? params]) {
    return of(context).get(key, params);
  }

  static Map<String, String> getAllKeysFor(String code) {
    return _localizedValues[code] ?? _localizedValues['tr']!;
  }

  static List<String> get supportedLanguageCodes => _localizedValues.keys.toList();
}

extension AppLocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String tr(String key, [Map<String, dynamic>? params]) => AppLocalizations.tr(this, key, params);
}
