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

        // Find the balanced closing ')' for this function call
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

          // Check if a map literal `{ ... }` was passed as arguments
          final mapStart = fullCallArgs.indexOf('{');
          final mapEnd = fullCallArgs.lastIndexOf('}');
          if (mapStart != -1 && mapEnd > mapStart) {
            final mapBody = fullCallArgs.substring(mapStart + 1, mapEnd);
            final paramKeyRegex = RegExp(r"[']([a-zA-Z0-9_]+)[']\s*:");
            for (final pMatch in paramKeyRegex.allMatches(mapBody)) {
              providedKeys.add(pMatch.group(1)!);
            }
          }

          // Check across all languages
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

    final summary = StringBuffer();
    for (final entry in fileMap.entries) {
      summary.writeln('\n--- File: ${entry.key} (${entry.value.length} issues) ---');
      for (final issue in entry.value) {
        summary.writeln('  * $issue');
      }
    }

    File('placeholder_audit_report.txt').writeAsStringSync(summary.toString());

    expect(fileMap, isEmpty, reason: 'Found issues in ${fileMap.length} files!');
  });
}
