import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:galeriden/core/localization/app_localizations.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/vehicle_category.dart';
import 'package:galeriden/data/models/real_estate_category.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/providers/market_provider.dart';
import 'package:galeriden/presentation/providers/vasita_market_provider.dart';
import 'package:galeriden/presentation/providers/real_estate_market_provider.dart';

void main() {
  group('Infinite Scroll Market Stream Tests', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({
        'dealership_state_v2': jsonEncode(DealershipModel.initial().toJson()),
      });

      container = ProviderContainer(
        overrides: [
          gameProvider.overrideWith((ref) => GameNotifier()),
        ],
      );
    });

    tearDown(() {
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      container.dispose();
    });

    test('MarketNotifier.loadMoreListings dynamically appends unique items to market stream', () {
      final initialListings = container.read(marketProvider);
      final initialCount = initialListings.length;
      expect(initialCount, greaterThan(0));

      container.read(marketProvider.notifier).loadMoreListings(count: 6);

      final updatedListings = container.read(marketProvider);
      expect(updatedListings.length, equals(initialCount + 6));

      // Verify all IDs in updated list are unique
      final ids = updatedListings.map((l) => l.id).toSet();
      expect(ids.length, equals(updatedListings.length));
    });

    test('VasitaMarketNotifier.loadMoreListings dynamically appends unique items to vasita stream', () {
      final initialListings = container.read(vasitaMarketProvider);
      final initialCount = initialListings.length;
      expect(initialCount, equals(24));

      container.read(vasitaMarketProvider.notifier).loadMoreListings(count: 6);

      final updatedListings = container.read(vasitaMarketProvider);
      expect(updatedListings.length, equals(initialCount + 6));

      // Verify category filter propagation during loadMore
      container.read(vasitaMarketProvider.notifier).setCategoryFilter(VehicleCategory.motorcycle);
      final filteredInitialCount = container.read(vasitaMarketProvider).length;

      container.read(vasitaMarketProvider.notifier).loadMoreListings(count: 4);
      final filteredAfterLoad = container.read(vasitaMarketProvider);
      expect(filteredAfterLoad.length, equals(filteredInitialCount + 4));
      for (final item in filteredAfterLoad) {
        expect(item.car.vehicleCategory, equals(VehicleCategory.motorcycle));
      }
    });

    test('RealEstateMarketNotifier.loadMoreListings dynamically appends unique items to real estate stream', () {
      final initialListings = container.read(realEstateMarketProvider);
      final initialCount = initialListings.length;
      expect(initialCount, equals(24));

      container.read(realEstateMarketProvider.notifier).loadMoreListings(count: 6);

      final updatedListings = container.read(realEstateMarketProvider);
      expect(updatedListings.length, equals(initialCount + 6));

      // Verify category filter propagation during loadMore
      container.read(realEstateMarketProvider.notifier).setCategoryFilter(RealEstateCategory.commercial);
      final plazaInitialCount = container.read(realEstateMarketProvider).length;

      container.read(realEstateMarketProvider.notifier).loadMoreListings(count: 4);
      final plazaAfterLoad = container.read(realEstateMarketProvider);
      expect(plazaAfterLoad.length, equals(plazaInitialCount + 4));
      for (final item in plazaAfterLoad) {
        expect(item.realEstate.category, equals(RealEstateCategory.commercial));
      }
    });

    test('Ad insertion cadence at index > 0 and index % 4 == 0 produces rhythm every 4 listings', () {
      bool shouldShowAd(int index) => index > 0 && index % 4 == 0;

      expect(shouldShowAd(0), isFalse);
      expect(shouldShowAd(1), isFalse);
      expect(shouldShowAd(2), isFalse);
      expect(shouldShowAd(3), isFalse);
      expect(shouldShowAd(4), isTrue);
      expect(shouldShowAd(5), isFalse);
      expect(shouldShowAd(8), isTrue);
      expect(shouldShowAd(12), isTrue);
      expect(shouldShowAd(16), isTrue);
      expect(shouldShowAd(20), isTrue);
    });

    test('feed_loading_more is localized across all 7 supported languages without emojis or parentheses', () {
      final languages = ['tr', 'en', 'de', 'pt', 'es', 'ru', 'ar'];
      final emojiRegex = RegExp(r'[\u{1F300}-\u{1F6FF}|[\u{1F900}-\u{1F9FF}]|[\u{2600}-\u{26FF}]', unicode: true);

      for (final lang in languages) {
        final translations = AppLocalizations.getAllKeysFor(lang);
        expect(translations.containsKey('feed_loading_more'), isTrue,
            reason: 'Missing feed_loading_more in $lang');

        final text = translations['feed_loading_more']!;
        expect(text.isNotEmpty, isTrue);
        expect(text.contains('('), isFalse, reason: 'Parentheses found in $lang string: $text');
        expect(text.contains(')'), isFalse, reason: 'Parentheses found in $lang string: $text');
        expect(emojiRegex.hasMatch(text), isFalse, reason: 'Emoji found in $lang string: $text');
      }
    });
  });
}
