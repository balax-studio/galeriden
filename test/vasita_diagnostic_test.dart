import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/localization/translations/tr_translations.dart';
import 'package:galeriden/core/localization/translations/en_translations.dart';
import 'package:galeriden/core/localization/translations/de_translations.dart';
import 'package:galeriden/core/localization/translations/es_translations.dart';
import 'package:galeriden/core/localization/translations/pt_translations.dart';
import 'package:galeriden/core/localization/translations/ru_translations.dart';
import 'package:galeriden/core/localization/translations/ar_translations.dart';

void main() {
  group('Diagnostic Scan Localization & Invariants', () {
    final diagnosticKeys = [
      'diag_dialog_title',
      'diag_dialog_subtitle',
      'diag_progress_text',
      'diag_status_queued',
      'diag_status_scanning',
      'diag_status_done',
      'diag_complete_badge',
      'diag_view_report_btn',
      'diag_arch_perf',
      'diag_arch_suv',
      'diag_arch_comm',
      'diag_arch_classic',
      'diag_arch_standard',
      'diag_perf_s1_t',
      'diag_perf_s1_d',
      'diag_perf_s2_t',
      'diag_perf_s2_d',
      'diag_perf_s3_t',
      'diag_perf_s3_d',
      'diag_perf_s4_t',
      'diag_perf_s4_d',
      'diag_suv_s1_t',
      'diag_suv_s1_d',
      'diag_suv_s2_t',
      'diag_suv_s2_d',
      'diag_suv_s3_t',
      'diag_suv_s3_d',
      'diag_suv_s4_t',
      'diag_suv_s4_d',
      'diag_comm_s1_t',
      'diag_comm_s1_d',
      'diag_comm_s2_t',
      'diag_comm_s2_d',
      'diag_comm_s3_t',
      'diag_comm_s3_d',
      'diag_comm_s4_t',
      'diag_comm_s4_d',
      'diag_classic_s1_t',
      'diag_classic_s1_d',
      'diag_classic_s2_t',
      'diag_classic_s2_d',
      'diag_classic_s3_t',
      'diag_classic_s3_d',
      'diag_classic_s4_t',
      'diag_classic_s4_d',
      'diag_std_s1_t',
      'diag_std_s1_d',
      'diag_std_s2_t',
      'diag_std_s2_d',
      'diag_std_s3_t',
      'diag_std_s3_d',
      'diag_std_s4_t',
      'diag_std_s4_d',
    ];

    final translationsMap = {
      'tr': trTranslations,
      'en': enTranslations,
      'de': deTranslations,
      'es': esTranslations,
      'pt': ptTranslations,
      'ru': ruTranslations,
      'ar': arTranslations,
    };

    test('All 53 diagnostic keys exist in all 7 languages without empty strings', () {
      for (final entry in translationsMap.entries) {
        final lang = entry.key;
        final map = entry.value;

        for (final key in diagnosticKeys) {
          expect(map.containsKey(key), isTrue,
              reason: 'Language $lang missing diagnostic key $key');
          expect(map[key]?.trim().isNotEmpty, isTrue,
              reason: 'Language $lang has empty string for $key');
        }
      }
    });

    test('Zero parentheses invariant is strictly respected across all 7 languages', () {
      for (final entry in translationsMap.entries) {
        final lang = entry.key;
        final map = entry.value;

        for (final key in diagnosticKeys) {
          final val = map[key] ?? '';
          expect(val.contains('('), isFalse,
              reason: 'Language $lang has "(" in $key: $val');
          expect(val.contains(')'), isFalse,
              reason: 'Language $lang has ")" in $key: $val');
        }
      }
    });

    test('Zero unicode emojis invariant is strictly respected across all 7 languages', () {
      final emojiRegex = RegExp(r'[\u{1F300}-\u{1F9FF}]|[\u{2600}-\u{26FF}]', unicode: true);
      for (final entry in translationsMap.entries) {
        final lang = entry.key;
        final map = entry.value;

        for (final key in diagnosticKeys) {
          final val = map[key] ?? '';
          expect(emojiRegex.hasMatch(val), isFalse,
              reason: 'Language $lang has emoji in $key: $val');
        }
      }
    });
  });
}
