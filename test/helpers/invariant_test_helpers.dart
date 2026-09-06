import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/localization/translations/ar_translations.dart';
import 'package:galeriden/core/localization/translations/de_translations.dart';
import 'package:galeriden/core/localization/translations/en_translations.dart';
import 'package:galeriden/core/localization/translations/es_translations.dart';
import 'package:galeriden/core/localization/translations/pt_translations.dart';
import 'package:galeriden/core/localization/translations/ru_translations.dart';
import 'package:galeriden/core/localization/translations/tr_translations.dart';

final RegExp kEmojiRegex = RegExp(
  r'[\u{1F300}-\u{1F9FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]|[\u{1F1E6}-\u{1F1FF}]|[\u{1F600}-\u{1F64F}]|[\u{1F680}-\u{1F6FF}]',
  unicode: true,
);

const Map<String, Map<String, String>> kAllTranslations = {
  'tr': trTranslations,
  'en': enTranslations,
  'de': deTranslations,
  'pt': ptTranslations,
  'es': esTranslations,
  'ru': ruTranslations,
  'ar': arTranslations,
};

void expectZeroEmojis(String text, {String? reason}) {
  expect(
    kEmojiRegex.hasMatch(text),
    isFalse,
    reason: reason ?? 'Found forbidden Unicode emoji in: "$text"',
  );
}

void expectZeroParentheses(String text, {String? reason}) {
  expect(
    text.contains('(') || text.contains(')'),
    isFalse,
    reason: reason ?? 'Found forbidden parentheses in: "$text"',
  );
}

void expectValidInvariantString(String text, {String? reason}) {
  expect(text.isNotEmpty, isTrue, reason: reason ?? 'String must not be empty');
  expectZeroEmojis(text, reason: reason);
  expectZeroParentheses(text, reason: reason);
}

void expectInvariantKeys(Iterable<String> keys, {Iterable<String>? languageCodes}) {
  final targetLangs = languageCodes ?? kAllTranslations.keys;

  for (final lang in targetLangs) {
    final map = kAllTranslations[lang];
    expect(map, isNotNull, reason: 'Unknown language code: $lang');

    for (final key in keys) {
      expect(map!.containsKey(key), isTrue,
          reason: 'Missing translation key: "$key" in language "$lang"');
      final val = map[key]!;
      expectValidInvariantString(
        val,
        reason: 'Key "$key" in language "$lang" violated invariants: "$val"',
      );
    }
  }
}
