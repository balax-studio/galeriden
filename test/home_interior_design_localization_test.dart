import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/localization/app_localizations.dart';
import 'package:galeriden/core/localization/language_model.dart';
import 'package:galeriden/data/models/home_interior_design_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final interiorKeys = [
    // Office & Navigation
    'home_interior_office_title',
    'home_interior_office_desc_unlocked',
    'home_interior_office_desc_locked',
    'real_estate_btn_interior_design',
    'real_estate_market_refreshed',
    'vasita_market_refreshed',

    // Main Interior Screen
    'home_interior_title',
    'home_interior_subtitle',
    'home_interior_total_investment',
    'home_interior_appraised_bonus',
    'home_interior_prestige_bonus',
    'home_interior_sections_title',
    'home_interior_no_items_yet',

    // Category Detail Screen
    'home_interior_item_installed',
    'home_interior_item_stats',
    'home_interior_purchase_success',
    'home_interior_btn_buy_install',

    // Categories
    'interior_cat_carpet',
    'interior_cat_appliances',
    'interior_cat_tv',
    'interior_cat_curtains',
    'interior_cat_furniture',
    'interior_cat_lighting',
  ];

  // Also collect all 48 item keys from catalog
  for (final item in HomeInteriorDesignCatalog.allItems) {
    interiorKeys.add(item.nameKey);
    interiorKeys.add(item.descriptionKey);
  }

  group('Home Interior Design 7-Language Localization & Invariant Guard', () {
    test('All 71 interior design keys exist simultaneously in all 7 languages', () {
      expect(interiorKeys.length, 71);

      for (final lang in AppLanguage.values) {
        final loc = AppLocalizations(lang.code);
        for (final key in interiorKeys) {
          final val = loc.get(key);
          expect(val, isNotEmpty, reason: 'Language ${lang.code} is missing key: $key');
          expect(val, isNot(equals(key)), reason: 'Language ${lang.code} untranslated key: $key');
        }
      }
    });

    test('Invariant check: Zero unicode emojis in all translation strings', () {
      final emojiRegex = RegExp(r'[\u{1F300}-\u{1F9FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]', unicode: true);

      for (final lang in AppLanguage.values) {
        final loc = AppLocalizations(lang.code);
        for (final key in interiorKeys) {
          final val = loc.get(key);
          expect(emojiRegex.hasMatch(val), isFalse,
              reason: 'Invariant violation: Emoji detected in [${lang.code}] $key: "$val"');
        }
      }
    });

    test('Invariant check: Zero parentheses in all translation strings', () {
      for (final lang in AppLanguage.values) {
        final loc = AppLocalizations(lang.code);
        for (final key in interiorKeys) {
          final val = loc.get(key);
          expect(val.contains('(') || val.contains(')'), isFalse,
              reason: 'Invariant violation: Parenthesis detected in [${lang.code}] $key: "$val"');
        }
      }
    });

    test('Placeholder test: home_interior_item_stats correctly substitutes params', () {
      for (final lang in AppLanguage.values) {
        final loc = AppLocalizations(lang.code);
        final rendered = loc.get('home_interior_item_stats', {
          'appraisal': '₺50.000',
          'prestige': '25',
        });
        expect(rendered, contains('₺50.000'));
        expect(rendered, contains('25'));
        expect(rendered, isNot(contains('{appraisal}')));
        expect(rendered, isNot(contains('{prestige}')));
      }
    });
  });
}
