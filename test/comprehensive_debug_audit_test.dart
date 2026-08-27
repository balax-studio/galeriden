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
  group('Comprehensive Systematic Debug & Quality Audit', () {
    final allTranslations = <String, Map<String, String>>{
      'tr': trTranslations,
      'en': enTranslations,
      'de': deTranslations,
      'pt': ptTranslations,
      'es': esTranslations,
      'ru': ruTranslations,
      'ar': arTranslations,
    };

    test('1. Localization Parity: All 7 languages must have exact key alignment', () {
      final baseKeys = enTranslations.keys.toSet();
      final mismatches = <String, Map<String, List<String>>>{};

      for (final entry in allTranslations.entries) {
        final lang = entry.key;
        final keys = entry.value.keys.toSet();

        final missingInLang = baseKeys.difference(keys);
        final extraInLang = keys.difference(baseKeys);

        if (missingInLang.isNotEmpty || extraInLang.isNotEmpty) {
          mismatches[lang] = {
            if (missingInLang.isNotEmpty) 'missing': missingInLang.toList(),
            if (extraInLang.isNotEmpty) 'extra': extraInLang.toList(),
          };
        }
      }

      expect(mismatches, isEmpty, reason: 'Key parity mismatches found: $mismatches');
    });

    test('2. Invariant Rule 1: Zero Unicode Emojis in lib/ source and translations', () {
      final emojiRegex = RegExp(
        r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F600}-\u{1F64F}\u{1F680}-\u{1F6FF}\u{1FA70}-\u{1FAFF}]',
        unicode: true,
      );

      final violations = <String, List<String>>{};

      for (final entry in allTranslations.entries) {
        final lang = entry.key;
        for (final item in entry.value.entries) {
          if (emojiRegex.hasMatch(item.value)) {
            violations.putIfAbsent('translation_$lang', () => []).add('${item.key}: "${item.value}"');
          }
        }
      }

      final libDir = Directory('lib');
      for (final file in libDir.listSync(recursive: true).whereType<File>()) {
        if (file.path.endsWith('.dart')) {
          final content = file.readAsStringSync();
          if (emojiRegex.hasMatch(content)) {
            final lines = content.split('\n');
            for (var i = 0; i < lines.length; i++) {
              if (emojiRegex.hasMatch(lines[i])) {
                violations.putIfAbsent(file.path, () => []).add('Line ${i + 1}: ${lines[i].trim()}');
              }
            }
          }
        }
      }

      expect(violations, isEmpty, reason: 'Unicode emojis found in code/translations: $violations');
    });

    test('3. Invariant Rule 2: Zero Parentheses in UI translation strings', () {
      final violations = <String, List<String>>{};

      for (final entry in allTranslations.entries) {
        final lang = entry.key;
        for (final item in entry.value.entries) {
          if (item.value.contains('(') || item.value.contains(')')) {
            violations.putIfAbsent(lang, () => []).add('${item.key} => "${item.value}"');
          }
        }
      }

      expect(violations, isEmpty, reason: 'Parentheses found in translation strings: $violations');
    });

    test('4. Invariant Rule 7: Game save/load serialization uses compute isolate', () {
      final gameCoreProviderFile = File('lib/presentation/providers/game/game_core_provider.dart');
      expect(gameCoreProviderFile.existsSync(), isTrue);

      final content = gameCoreProviderFile.readAsStringSync();
      expect(content.contains('compute('), isTrue, reason: 'GameState serialization must use compute() isolate');
      expect(content.contains('kIsWeb'), isTrue, reason: 'Must have safe web fallback for compute() isolate');
    });

    test('5. Check for dangerous Division by Zero patterns in game engines', () {
      final enginesDir = Directory('lib/domain/usecases');
      expect(enginesDir.existsSync(), isTrue);

      final suspiciousPatterns = <String>[];

      for (final file in enginesDir.listSync(recursive: true).whereType<File>()) {
        if (file.path.endsWith('.dart')) {
          final lines = file.readAsStringSync().split('\n');
          for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim();
            if (line.contains('//')) {
              line = line.substring(0, line.indexOf('//')).trim();
            }
            if (line.contains('/ 0') || line.contains('/0') || line.contains('~/ 0') || line.contains('~/0')) {
              suspiciousPatterns.add('${file.path}:${i + 1} -> $line');
            }
          }
        }
      }

      expect(suspiciousPatterns, isEmpty, reason: 'Explicit division by zero found: $suspiciousPatterns');
    });
  });
}
