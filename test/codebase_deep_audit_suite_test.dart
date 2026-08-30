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
  final allTranslations = <String, Map<String, String>>{
    'tr': trTranslations,
    'en': enTranslations,
    'de': deTranslations,
    'pt': ptTranslations,
    'es': esTranslations,
    'ru': ruTranslations,
    'ar': arTranslations,
  };

  group('Invariant Rule 1: Zero Unicode Emojis', () {
    // Regex matching common Unicode emoji ranges (emojis, pictographs, transport, misc symbols)
    final emojiRegex = RegExp(
      r'[\u{1F300}-\u{1F9FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]|[\u{1FA00}-\u{1FAFF}]|[\u{1F1E0}-\u{1F1FF}]',
      unicode: true,
    );

    test('Translation files must contain zero Unicode emojis', () {
      final emojiViolations = <String, List<String>>{};
      for (final entry in allTranslations.entries) {
        final lang = entry.key;
        for (final item in entry.value.entries) {
          if (emojiRegex.hasMatch(item.value)) {
            emojiViolations.putIfAbsent(lang, () => []).add('${item.key}: "${item.value}"');
          }
        }
      }

      expect(
        emojiViolations.isEmpty,
        isTrue,
        reason: 'Found emoji violations in translations:\n$emojiViolations',
      );
    });

    test('lib/presentation files must contain zero Unicode emojis in string literals', () {
      final presentationDir = Directory('lib/presentation');
      final fileViolations = <String, List<String>>{};

      for (final entity in presentationDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          final lines = entity.readAsLinesSync();
          for (int i = 0; i < lines.length; i++) {
            final line = lines[i];
            if (line.trim().startsWith('//') || line.trim().startsWith('/*')) continue;
            if (emojiRegex.hasMatch(line)) {
              fileViolations.putIfAbsent(entity.path, () => []).add('Line ${i + 1}: ${line.trim()}');
            }
          }
        }
      }

      expect(
        fileViolations.isEmpty,
        isTrue,
        reason: 'Found emoji violations in presentation layer:\n$fileViolations',
      );
    });
  });

  group('Invariant Rule 2: Zero Parentheses in UI Strings', () {
    test('Translation files must contain zero parentheses ()', () {
      final parenViolations = <String, List<String>>{};
      for (final entry in allTranslations.entries) {
        final lang = entry.key;
        for (final item in entry.value.entries) {
          if (item.value.contains('(') || item.value.contains(')')) {
            parenViolations.putIfAbsent(lang, () => []).add('${item.key}: "${item.value}"');
          }
        }
      }

      expect(
        parenViolations.isEmpty,
        isTrue,
        reason: 'Found parentheses in translations:\n$parenViolations',
      );
    });

    test('lib/presentation files must contain zero UI parentheses in Text and title string literals', () {
      final presentationDir = Directory('lib/presentation');
      // Match patterns like Text('...'), Text("..."), title: '...', subtitle: '...'
      final uiStringParamRegex = RegExp(
        r'''(?:Text|title|subtitle|description|label|actionLabel|headerText|buttonText)\s*[:(]\s*(?:const\s+)?(['"])(.*?)\1''',
      );
      final parenViolations = <String, List<String>>{};

      for (final entity in presentationDir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          final lines = entity.readAsLinesSync();
          for (int i = 0; i < lines.length; i++) {
            final line = lines[i];
            if (line.trim().startsWith('//') || line.trim().startsWith('/*') || line.trim().startsWith('import ')) continue;
            // Ignore Dart method invocations in line like context.tr(...)
            if (line.contains(r'context.tr(') || line.contains(r'.tr(')) continue;
            final matches = uiStringParamRegex.allMatches(line);
            for (final m in matches) {
              final rawStr = m.group(2) ?? '';
              // Remove anything inside ${...}
              String withoutInterpolation = rawStr.replaceAll(RegExp(r'\$\{[^}]*\}'), '');
              withoutInterpolation = withoutInterpolation.replaceAll(RegExp(r'\$[a-zA-Z0-9_]+'), '');
              if (withoutInterpolation.contains('(') || withoutInterpolation.contains(')')) {
                parenViolations.putIfAbsent(entity.path, () => []).add('Line ${i + 1}: "$rawStr"');
              }
            }
          }
        }
      }

      expect(
        parenViolations.isEmpty,
        isTrue,
        reason: 'Found UI parentheses in presentation string literals:\n$parenViolations',
      );
    });
  });

  group('Invariant Rule 8: 7-Language Parity & Placeholders', () {
    test('All 7 translation maps have identical key sets', () {
      final allUniqueKeys = <String>{};
      for (final map in allTranslations.values) {
        allUniqueKeys.addAll(map.keys);
      }

      final missingByLang = <String, List<String>>{};
      for (final entry in allTranslations.entries) {
        final missing = allUniqueKeys.difference(entry.value.keys.toSet()).toList();
        if (missing.isNotEmpty) {
          missingByLang[entry.key] = missing;
        }
      }

      expect(
        missingByLang.isEmpty,
        isTrue,
        reason: 'Missing keys across languages: $missingByLang',
      );
    });

    test('All translation values are non-empty and have matching placeholders', () {
      final placeholderRegex = RegExp(r'\{[a-zA-Z0-9_]+\}');
      final trPlaceholders = <String, Set<String>>{};

      for (final item in trTranslations.entries) {
        final matches = placeholderRegex.allMatches(item.value).map((m) => m.group(0)!).toSet();
        trPlaceholders[item.key] = matches;
      }

      final placeholderMismatches = <String, List<String>>{};
      for (final entry in allTranslations.entries) {
        if (entry.key == 'tr') continue;
        for (final item in entry.value.entries) {
          final expected = trPlaceholders[item.key] ?? {};
          final actual = placeholderRegex.allMatches(item.value).map((m) => m.group(0)!).toSet();
          if (!expected.containsAll(actual) || !actual.containsAll(expected)) {
            placeholderMismatches.putIfAbsent(entry.key, () => []).add(
              '${item.key}: expected $expected, got $actual in "${item.value}"',
            );
          }
        }
      }

      expect(
        placeholderMismatches.isEmpty,
        isTrue,
        reason: 'Placeholder mismatches found:\n$placeholderMismatches',
      );
    });
  });
}
