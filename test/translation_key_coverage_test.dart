import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/localization/language_model.dart';
import 'package:galeriden/core/localization/translations/ar_translations.dart';
import 'package:galeriden/core/localization/translations/de_translations.dart';
import 'package:galeriden/core/localization/translations/en_translations.dart';
import 'package:galeriden/core/localization/translations/es_translations.dart';
import 'package:galeriden/core/localization/translations/pt_translations.dart';
import 'package:galeriden/core/localization/translations/ru_translations.dart';
import 'package:galeriden/core/localization/translations/tr_translations.dart';
import 'package:galeriden/presentation/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/invariant_test_helpers.dart';

void main() {
  test('Check that all context.tr keys in code exist across all 7 translation files', () {
    final allTranslations = <String, Map<String, String>>{
      'tr': trTranslations,
      'en': enTranslations,
      'de': deTranslations,
      'pt': ptTranslations,
      'es': esTranslations,
      'ru': ruTranslations,
      'ar': arTranslations,
    };

    final trKeyRegex = RegExp(r'''\btr\(\s*['"]([a-zA-Z0-9_\-]+)['"]''');
    final declaredKeyRegex = RegExp(r'''['"]([a-z][a-z0-9_]+(?:_[a-z0-9_]+)+)['"]''');
    final libDir = Directory('lib');

    final missingKeysByLang = <String, Set<String>>{
      for (final lang in allTranslations.keys) lang: {},
    };

    final fileUsageMap = <String, List<String>>{};

    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart') && !entity.path.contains('localization/translations')) {
        final content = entity.readAsStringSync();
        final matches = trKeyRegex.allMatches(content);
        for (final m in matches) {
          final key = m.group(1)!;
          fileUsageMap.putIfAbsent(key, () => []).add(entity.path);

          for (final entry in allTranslations.entries) {
            final lang = entry.key;
            final map = entry.value;
            if (!map.containsKey(key)) {
              missingKeysByLang[lang]!.add(key);
            }
          }
        }

        // Also check declared keys ending in 'Key' or defined in models/enums if used with translation
        if (entity.path.contains('model') || entity.path.contains('widget') || entity.path.contains('screen') || entity.path.contains('dialog')) {
          final declaredMatches = declaredKeyRegex.allMatches(content);
          for (final dm in declaredMatches) {
            final possibleKey = dm.group(1)!;
            // If it exists in trTranslations (meaning it's definitely a translation key), verify all 6 other languages also have it!
            if (trTranslations.containsKey(possibleKey)) {
              fileUsageMap.putIfAbsent(possibleKey, () => []).add(entity.path);
              for (final entry in allTranslations.entries) {
                if (!entry.value.containsKey(possibleKey)) {
                  missingKeysByLang[entry.key]!.add(possibleKey);
                }
              }
            }
          }
        }
      }
    }

    final summary = StringBuffer();
    for (final entry in missingKeysByLang.entries) {
      if (entry.value.isNotEmpty) {
        summary.writeln('\n=== Missing in ${entry.key.toUpperCase()} (${entry.value.length} keys) ===');
        for (final k in entry.value) {
          summary.writeln('  - $k (used in: ${fileUsageMap[k]?.join(', ')})');
        }
      }
    }

    expect(
      missingKeysByLang.values.every((set) => set.isEmpty),
      isTrue,
      reason: 'Found missing translation keys:\n$summary',
    );
  });

  test('Check that all 7 translation files have identical key sets (complete symmetry)', () {
    final allTranslations = <String, Map<String, String>>{
      'tr': trTranslations,
      'en': enTranslations,
      'de': deTranslations,
      'pt': ptTranslations,
      'es': esTranslations,
      'ru': ruTranslations,
      'ar': arTranslations,
    };

    final allUniqueKeys = <String>{};
    for (final map in allTranslations.values) {
      allUniqueKeys.addAll(map.keys);
    }

    final missingParity = <String, List<String>>{};
    for (final entry in allTranslations.entries) {
      final lang = entry.key;
      final map = entry.value;
      final missing = allUniqueKeys.difference(map.keys.toSet()).toList();
      if (missing.isNotEmpty) {
        missingParity[lang] = missing;
      }
    }

    final paritySummary = StringBuffer();
    for (final entry in missingParity.entries) {
      paritySummary.writeln('\n=== ${entry.key.toUpperCase()} is missing ${entry.value.length} keys ===');
      for (final k in entry.value.take(20)) {
        paritySummary.writeln('  - $k');
      }
      if (entry.value.length > 20) {
        paritySummary.writeln('  ... and ${entry.value.length - 20} more');
      }
    }

    expect(
      missingParity.isEmpty,
      isTrue,
      reason: 'Translation key asymmetry detected across languages:\n$paritySummary',
    );
  });

  test('AppLanguage enum contains all 7 target languages with metadata', () {
    expect(AppLanguage.values.length, 7);

    final codes = AppLanguage.values.map((e) => e.code).toSet();
    expect(codes, containsAll(['tr', 'en', 'de', 'pt', 'es', 'ru', 'ar']));

    // Arabic RTL check
    final arabic = AppLanguage.fromCode('ar');
    expect(arabic.isRtl, isTrue);
    expect(arabic.countryBadge, 'AR');
    expect(arabic.nativeName, 'العربية');

    // German & Portuguese checks
    final german = AppLanguage.fromCode('de');
    expect(german.isRtl, isFalse);
    expect(german.nativeName, 'Deutsch');

    final portuguese = AppLanguage.fromCode('pt');
    expect(portuguese.isRtl, isFalse);
    expect(portuguese.nativeName, 'Português');

    // Fallback check
    expect(AppLanguage.fromCode('unknown_xyz'), AppLanguage.turkish);
  });

  test('SettingsNotifier updates language and isRtl reactivity correctly', () async {
    SharedPreferences.setMockInitialValues({});
    final notifier = SettingsNotifier();

    expect(notifier.state.languageCode, isNotEmpty);

    await notifier.setLanguage('ar');
    expect(notifier.state.languageCode, 'ar');
    expect(notifier.state.isRtl, isTrue);
    expect(notifier.state.currentLanguage, AppLanguage.arabic);

    await notifier.setLanguage('de');
    expect(notifier.state.languageCode, 'de');
    expect(notifier.state.isRtl, isFalse);
    expect(notifier.state.currentLanguage, AppLanguage.german);

    await notifier.setLanguage('pt');
    expect(notifier.state.languageCode, 'pt');
    expect(notifier.state.isRtl, isFalse);
    expect(notifier.state.currentLanguage, AppLanguage.portuguese);

    await notifier.setLanguage('ru');
    expect(notifier.state.languageCode, 'ru');
    expect(notifier.state.currentLanguage, AppLanguage.russian);

    await notifier.setLanguage('es');
    expect(notifier.state.languageCode, 'es');
    expect(notifier.state.currentLanguage, AppLanguage.spanish);

    await notifier.setLanguage('tr');
    expect(notifier.state.languageCode, 'tr');
    expect(notifier.state.currentLanguage, AppLanguage.turkish);
  });

  test('All 7 translation files obey invariant rules: zero emojis, zero parentheses, non-empty', () {
    final allTranslations = <String, Map<String, String>>{
      'tr': trTranslations,
      'en': enTranslations,
      'de': deTranslations,
      'pt': ptTranslations,
      'es': esTranslations,
      'ru': ruTranslations,
      'ar': arTranslations,
    };

    for (final entry in allTranslations.entries) {
      final lang = entry.key;
      for (final kv in entry.value.entries) {
        expectValidInvariantString(
          kv.value,
          reason: 'Key "${kv.key}" in language "$lang" violated invariants: "${kv.value}"',
        );
      }
    }
  });

  test('Audit all translation placeholder mismatches accurately', () {
    final allTranslations = <String, Map<String, String>>{
      'tr': trTranslations,
      'en': enTranslations,
      'de': deTranslations,
      'pt': ptTranslations,
      'es': esTranslations,
      'ru': ruTranslations,
      'ar': arTranslations,
    };

    final libDir = Directory('lib');
    final dartFiles = libDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart') && !f.path.contains('translations/'));

    final startPattern = RegExp(r"(?:context\.tr|\.get|\bl10n\.get)\s*\(\s*[']");
    final placeholderRegex = RegExp(r'\{([a-zA-Z0-9_]+)\}');
    final fileMap = <String, List<String>>{};

    for (final file in dartFiles) {
      final content = file.readAsStringSync();
      final matches = startPattern.allMatches(content);

      for (final match in matches) {
        final keyStart = match.end;
        final keyEnd = content.indexOf("'", keyStart);
        if (keyEnd == -1) continue;

        final key = content.substring(keyStart, keyEnd);

        int parenDepth = 1;
        int cur = keyEnd + 1;
        int callEnd = -1;
        while (cur < content.length && parenDepth > 0) {
          final ch = content[cur];
          if (ch == '(') parenDepth++;
          if (ch == ')') parenDepth--;
          if (parenDepth == 0) {
            callEnd = cur;
            break;
          }
          cur++;
        }

        if (callEnd != -1) {
          final fullCallArgs = content.substring(keyEnd + 1, callEnd);
          final providedKeys = <String>{};

          final mapStart = fullCallArgs.indexOf('{');
          final mapEnd = fullCallArgs.lastIndexOf('}');
          if (mapStart != -1 && mapEnd > mapStart) {
            final mapBody = fullCallArgs.substring(mapStart + 1, mapEnd);
            final paramKeyRegex = RegExp(r"[']([a-zA-Z0-9_]+)[']\s*:");
            for (final pMatch in paramKeyRegex.allMatches(mapBody)) {
              providedKeys.add(pMatch.group(1)!);
            }
          }

          for (final lang in allTranslations.keys) {
            final val = allTranslations[lang]?[key];
            if (val == null) continue;

            final expectedPlaceholders = placeholderRegex.allMatches(val).map((m) => m.group(1)!).toSet();
            final missing = expectedPlaceholders.difference(providedKeys);
            if (missing.isNotEmpty) {
              final issueStr = 'Key: "$key" ($lang) | Expected: $expectedPlaceholders | Provided: $providedKeys | Template: "$val"';
              final list = fileMap.putIfAbsent(file.path, () => []);
              if (!list.contains(issueStr)) {
                list.add(issueStr);
              }
            }
          }
        }
      }
    }

    expect(fileMap, isEmpty, reason: 'Found issues in ${fileMap.length} files: $fileMap');
  });
}
