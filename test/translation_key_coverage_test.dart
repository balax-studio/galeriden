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

    File('missing_keys_report.txt').writeAsStringSync(summary.toString());

    expect(
      missingKeysByLang.values.every((set) => set.isEmpty),
      isTrue,
      reason: 'Found missing translation keys:\n$summary',
    );
  });
}
