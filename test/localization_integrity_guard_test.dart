import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('C5: Localization Integrity Guard Test', () {
    test('Ensures no NEW hardcoded Turkish strings in presentation/screens', () {
      final screensDir = Directory('lib/presentation/screens');
      expect(screensDir.existsSync(), isTrue);

      final turkishCharPattern = RegExp(r'[çÇğĞıİöÖşŞüÜ]');
      final stringLiteralPattern = RegExp(r'''(['"])(.*?)\1''');

      final allowlistFile = File('test/resources/presentation_unlocalized_allowlist.txt');
      final Set<String> allowlist = allowlistFile.existsSync()
          ? allowlistFile.readAsLinesSync().map((l) => l.trim()).where((l) => l.isNotEmpty).toSet()
          : <String>{};

      final List<String> currentUnlocalized = [];

      for (final file in screensDir.listSync(recursive: true).whereType<File>()) {
        if (!file.path.endsWith('.dart')) continue;

        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i].trim();
          // Skip comments, imports, exports, and already localized lines
          if (line.startsWith('//') || line.startsWith('*') || line.startsWith('/*')) continue;
          if (line.startsWith('import ') || line.startsWith('export ')) continue;
          if (line.contains('.tr(') || line.contains('context.tr(') || line.contains('AppLocalizations')) continue;

          for (final match in stringLiteralPattern.allMatches(line)) {
            final content = match.group(2) ?? '';
            if (content.contains(turkishCharPattern)) {
              // Normalize relative file path for consistency across OS
              final relPath = file.path.replaceAll('\\', '/').replaceFirst('lib/presentation/screens/', '');
              final entry = '$relPath: "${content.trim()}"';
              currentUnlocalized.add(entry);
            }
          }
        }
      }

      // If allowlist file does not exist, initialize it with current baseline
      if (!allowlistFile.existsSync()) {
        allowlistFile.parent.createSync(recursive: true);
        final sortedEntries = currentUnlocalized.toSet().toList()..sort();
        allowlistFile.writeAsStringSync(sortedEntries.join('\n'));
        return;
      }

      // Detect any new unlocalized string not present in the allowlist
      final newViolations = currentUnlocalized
          .where((entry) => !allowlist.contains(entry))
          .toSet()
          .toList();

      expect(
        newViolations.isEmpty,
        isTrue,
        reason: 'NEW unlocalized Turkish strings detected in lib/presentation/screens! '
            'All newly introduced strings must use context.tr(...) and 7-language synchronization:\n'
            '${newViolations.join("\n")}',
      );
    });
  });
}
