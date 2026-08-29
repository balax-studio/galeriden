import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/localization/translations/ar_translations.dart';
import 'package:galeriden/core/localization/translations/de_translations.dart';
import 'package:galeriden/core/localization/translations/en_translations.dart';
import 'package:galeriden/core/localization/translations/es_translations.dart';
import 'package:galeriden/core/localization/translations/pt_translations.dart';
import 'package:galeriden/core/localization/translations/ru_translations.dart';
import 'package:galeriden/core/localization/translations/tr_translations.dart';

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
}
