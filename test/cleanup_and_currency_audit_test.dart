import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/utils/currency_formatter.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/core/localization/translations/tr_translations.dart';
import 'package:galeriden/core/localization/translations/en_translations.dart';
import 'package:galeriden/core/localization/translations/de_translations.dart';
import 'package:galeriden/core/localization/translations/es_translations.dart';
import 'package:galeriden/core/localization/translations/pt_translations.dart';
import 'package:galeriden/core/localization/translations/ru_translations.dart';
import 'package:galeriden/core/localization/translations/ar_translations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Task 7: Cleanup and Currency Audit Tests (C6 & C7)', () {
    test('C6: getRequiredBranchTier and getRequiredBranchName decoupled from level', () {
      // Test routes across tiers
      expect(DealershipModel.getRequiredBranchTier('/car-wash'), equals(2));
      expect(DealershipModel.getRequiredBranchTier('/workshop'), equals(3));
      expect(DealershipModel.getRequiredBranchTier('/emlak'), equals(4));
      expect(DealershipModel.getRequiredBranchTier('/finance'), equals(5));
      expect(DealershipModel.getRequiredBranchTier('/bank-investments'), equals(6));
      expect(DealershipModel.getRequiredBranchTier('/rent-a-car'), equals(7));
      expect(DealershipModel.getRequiredBranchTier('/side-businesses'), equals(8));

      // Test required branch name formatting
      final branchName = DealershipModel.getRequiredBranchName('/car-wash', null, 'tr');
      expect(branchName.contains('Mahalle Tipi Açık Oto Galeri'), isTrue);
      expect(branchName.contains('Seviye 2'), isTrue);

      final branch8Name = DealershipModel.getRequiredBranchName('/side-businesses', null, 'tr');
      expect(branch8Name.contains('Mega Otomotiv Holding Plazası'), isTrue);
      expect(branch8Name.contains('Seviye 8'), isTrue);
    });

    test('C7: 7-language translation keys for currency abbreviations exist and match invariants', () {
      final allTranslations = [
        ('tr', trTranslations),
        ('en', enTranslations),
        ('de', deTranslations),
        ('es', esTranslations),
        ('pt', ptTranslations),
        ('ru', ruTranslations),
        ('ar', arTranslations),
      ];

      for (final (lang, map) in allTranslations) {
        expect(map.containsKey('fmt_thousand'), isTrue, reason: 'Missing fmt_thousand in $lang');
        expect(map.containsKey('fmt_million'), isTrue, reason: 'Missing fmt_million in $lang');
        expect(map.containsKey('fmt_billion'), isTrue, reason: 'Missing fmt_billion in $lang');

        // Verify zero parentheses and zero emojis invariant
        for (final key in ['fmt_thousand', 'fmt_million', 'fmt_billion']) {
          final val = map[key]!;
          expect(val.contains('('), isFalse, reason: '$key in $lang contains (');
          expect(val.contains(')'), isFalse, reason: '$key in $lang contains )');
        }
      }
    });

    test('C7: CurrencyFormatter.format applies locale-based separation', () {
      final trFormatted = CurrencyFormatter.format(1500000, 'tr');
      expect(trFormatted.contains('1.500.000'), isTrue);

      final enFormatted = CurrencyFormatter.format(1500000, 'en');
      expect(enFormatted.contains('1,500,000'), isTrue);
    });

    test('C7: CurrencyFormatter.formatShort handles negative, billions, and localized suffixes', () {
      // Negative amounts
      expect(CurrencyFormatter.formatShort(-5000, 'en'), equals('-₺5K'));
      expect(CurrencyFormatter.formatShort(-5000, 'tr'), equals('-₺5B'));

      // Millions
      expect(CurrencyFormatter.formatShort(1500000, 'en'), equals('₺1.5M'));
      expect(CurrencyFormatter.formatShort(2000000, 'en'), equals('₺2M'));

      // Billions
      expect(CurrencyFormatter.formatShort(1500000000, 'en'), equals('₺1.5B'));
      expect(CurrencyFormatter.formatShort(1500000000, 'tr'), equals('₺1.5Mrd'));
      expect(CurrencyFormatter.formatShort(1500000000, 'de'), equals('₺1.5Mrd'));

      // Negative Billions
      expect(CurrencyFormatter.formatShort(-2500000000, 'en'), equals('-₺2.5B'));
    });
  });
}
