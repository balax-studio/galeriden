import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/localization/translations/tr_translations.dart';
import 'package:galeriden/core/localization/translations/en_translations.dart';
import 'package:galeriden/core/localization/translations/de_translations.dart';
import 'package:galeriden/core/localization/translations/pt_translations.dart';
import 'package:galeriden/core/localization/translations/es_translations.dart';
import 'package:galeriden/core/localization/translations/ru_translations.dart';
import 'package:galeriden/core/localization/translations/ar_translations.dart';
import 'package:galeriden/domain/usecases/market_engine.dart';
import 'package:galeriden/data/models/marketplace_extensions_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final supportedLanguages = ['tr', 'en', 'de', 'pt', 'es', 'ru', 'ar'];

  group('7-Language Marketplace Localization & Cultural Keys Test Suite', () {
    test('All 7 translation maps contain required cultural keys with non-empty values', () {
      final translationMaps = {
        'tr': trTranslations,
        'en': enTranslations,
        'de': deTranslations,
        'pt': ptTranslations,
        'es': esTranslations,
        'ru': ruTranslations,
        'ar': arTranslations,
      };

      final requiredKeys = [
        'city_istanbul',
        'city_ankara',
        'city_izmir',
        'city_bursa',
        'city_antalya',
        'city_adana',
        'city_konya',
        'city_gaziantep',
        'city_trabzon',
        'seller_name_1',
        'seller_name_2',
        'seller_name_3',
        'seller_name_4',
        'seller_name_5',
        'seller_name_6',
        'seller_profile_doctor',
        'seller_profile_urgent_cash',
        'seller_profile_trade_in',
        'seller_profile_debt',
        'seller_profile_collector',
        'seller_profile_officer',
        'seller_profile_abroad',
        'seller_profile_whim',
        'seller_profile_teacher',
        'seller_profile_military',
        'seller_profile_contractor',
        'seller_profile_house_downpayment',
        'seller_profile_pristine',
        'seller_profile_barn_find',
        'seller_profile_rare',
        'seller_profile_flash_deal',
        'title_prefix_barn',
        'title_prefix_pristine',
        'title_prefix_rare',
        'title_prefix_normal_1',
        'title_prefix_normal_2',
        'title_prefix_normal_3',
        'title_prefix_normal_4',
        'title_prefix_normal_5',
        'desc_barn_find_1',
        'desc_pristine_1',
        'desc_flash_urgent_1',
        'desc_flash_house_1',
        'desc_rare_collector_1',
        'desc_honest_clean_no_tramer',
        'desc_honest_with_tramer',
        'desc_flawless_claim_1',
      ];

      for (final lang in supportedLanguages) {
        final map = translationMaps[lang]!;
        for (final key in requiredKeys) {
          expect(
            map.containsKey(key),
            isTrue,
            reason: 'Language "$lang" must contain key "$key"',
          );
          expect(
            map[key]!.trim().isNotEmpty,
            isTrue,
            reason: 'Key "$key" in "$lang" must not be empty',
          );
        }
      }
    });

    testWidgets('MarketEngine generated listings dynamically translate across all 7 locales', (tester) async {
      final trend = MarketEngine.generateMarketTrend();
      final pool = MarketEngine.generateRandomListings(playerLevel: 3, trend: trend, count: 15);

      expect(pool.isNotEmpty, isTrue);

      for (final lang in supportedLanguages) {
        await tester.pumpWidget(
          MaterialApp(
            locale: Locale(lang),
            home: Builder(
              builder: (context) {
                for (final listing in pool) {
                  final cityName = listing.getLocalizedSellerCity(context);
                  final sellerName = listing.getLocalizedSellerName(context);
                  final sellerTrait = listing.getLocalizedSellerTrait(context);
                  final title = listing.getLocalizedTitle(context);
                  final description = listing.getLocalizedDescription(context);
                  final persona = SellerPersona.fromListing(listing);

                  expect(cityName.isNotEmpty, isTrue);
                  expect(sellerName.isNotEmpty, isTrue);
                  expect(sellerTrait.isNotEmpty, isTrue);
                  expect(title.isNotEmpty, isTrue);
                  expect(description.isNotEmpty, isTrue);
                  expect(persona, isNotNull);
                }
                return const Scaffold(body: Text('Marketplace Test Ready'));
              },
            ),
          ),
        );
        await tester.pumpAndSettle();
      }
    });
  });
}
