import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/localization/app_localizations.dart';
import 'package:galeriden/data/models/real_estate_category.dart';
import 'package:galeriden/domain/usecases/market_engine.dart';
import 'package:galeriden/domain/usecases/real_estate_market_engine.dart';
import 'package:galeriden/domain/usecases/vasita_market_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Real Estate Market Calibration Tests', () {
    test('Templates contain calibrated realistic Turkish metro benchmark values', () {
      final templates = RealEstateMarketEngine.templates;

      final kuponDaire = templates.firstWhere(
        (t) => t.category == RealEstateCategory.housing && t.roomCount == '3+1',
      );
      expect(kuponDaire.minBaseValue, greaterThanOrEqualTo(6800000.0));
      expect(kuponDaire.maxBaseValue, greaterThanOrEqualTo(19500000.0));

      final studio = templates.firstWhere(
        (t) => t.category == RealEstateCategory.housing && t.roomCount == '1+1',
      );
      expect(studio.minBaseValue, greaterThanOrEqualTo(3500000.0));

      final shop = templates.firstWhere(
        (t) => t.category == RealEstateCategory.commercial && t.roomCount == 'Dükkan',
      );
      expect(shop.minBaseValue, greaterThanOrEqualTo(14000000.0));
      expect(shop.maxBaseValue, greaterThanOrEqualTo(45000000.0));

      final office = templates.firstWhere(
        (t) => t.category == RealEstateCategory.commercial && t.roomCount == 'Ofis Katı',
      );
      expect(office.minBaseValue, greaterThanOrEqualTo(16000000.0));

      final villaLand = templates.firstWhere(
        (t) => t.category == RealEstateCategory.land && t.roomCount == 'İmarlı Arsa',
      );
      expect(villaLand.minBaseValue, greaterThanOrEqualTo(14500000.0));
      expect(villaLand.maxBaseValue, greaterThanOrEqualTo(58000000.0));

      final building = templates.firstWhere(
        (t) => t.category == RealEstateCategory.building,
      );
      expect(building.minBaseValue, greaterThanOrEqualTo(48000000.0));
      expect(building.maxBaseValue, greaterThanOrEqualTo(140000000.0));
    });

    test('generateListings generates valid listings with calibrated price scales', () {
      final listings = RealEstateMarketEngine.generateListings(count: 20);
      expect(listings.length, 20);

      for (final l in listings) {
        expect(l.askingPrice, greaterThan(0));
        expect(l.realEstate.squareMeters, greaterThan(0));
        expect(l.estimatedDeedFee, greaterThan(0));
      }

      final buildingListings = listings.where(
        (l) => l.realEstate.category == RealEstateCategory.building,
      );
      for (final b in buildingListings) {
        expect(b.askingPrice, greaterThanOrEqualTo(30000000.0));
      }
    });
  });

  group('Wealth-Scaled Vehicle Generation Tests', () {
    test('MarketEngine suppresses low budget cars and boosts luxury for wealthy player', () {
      // Generate 50 listings for a low-balance player
      final lowBalanceListings = MarketEngine.generateRandomListings(
        count: 50,
        playerLevel: 1,
        playerBalance: 75000.0,
      );

      // Generate 50 listings for a tycoon player (₺25M+)
      final highBalanceListings = MarketEngine.generateRandomListings(
        count: 50,
        playerLevel: 10,
        playerBalance: 25000000.0,
      );

      final lowBalanceAvgPrice = lowBalanceListings.fold<double>(
            0.0,
            (sum, l) => sum + l.askingPrice,
          ) /
          lowBalanceListings.length;

      final highBalanceAvgPrice = highBalanceListings.fold<double>(
            0.0,
            (sum, l) => sum + l.askingPrice,
          ) /
          highBalanceListings.length;

      expect(highBalanceAvgPrice, greaterThan(lowBalanceAvgPrice));
    });

    test('VasitaMarketEngine weights aircraft and marine higher when player has high cash', () {
      final wealthyListings = VasitaMarketEngine.generateListings(
        count: 40,
        playerLevel: 10,
        playerBalance: 30000000.0,
      );

      final hasHighTierVehicles = wealthyListings.any(
        (l) =>
            l.car.bodyType == 'Hafif Jet' ||
            l.car.bodyType == 'Turboprop Uçak' ||
            l.car.bodyType == 'Motoryat' ||
            l.car.bodyType == 'Yelkenli' ||
            l.car.bodyType == 'Entegre Karavan' ||
            l.car.bodyType == 'Superbike' ||
            l.car.baseMarketValue >= 2000000.0,
      );

      expect(hasHighTierVehicles, isTrue);
    });
  });

  group('Simultaneous 7-Language Localization Integrity Tests', () {
    const requiredKeys = [
      'leaderboard_offline_badge',
      'real_estate_empty_listings_desc',
      'real_estate_empty_listings_cta',
      'real_estate_empty_portfolio_cta',
      'real_estate_construction_empty_title',
      'real_estate_construction_empty_desc',
      'real_estate_construction_empty_cta',
      'real_estate_renovation_empty_title',
      'real_estate_renovation_empty_desc',
      'real_estate_renovation_empty_cta',
    ];

    const supportedLanguages = ['tr', 'en', 'de', 'pt', 'es', 'ru', 'ar'];

    test('All required keys exist in all 7 languages without empty strings', () {
      for (final lang in supportedLanguages) {
        final keysMap = AppLocalizations.getAllKeysFor(lang);
        for (final key in requiredKeys) {
          expect(
            keysMap.containsKey(key),
            isTrue,
            reason: 'Missing key "$key" in language "$lang"',
          );
          final value = keysMap[key]!;
          expect(
            value.trim().isNotEmpty,
            isTrue,
            reason: 'Empty translation for "$key" in language "$lang"',
          );
          // Invariant Rule 1: Zero Unicode Emojis
          final emojiRegex = RegExp(
            r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
            unicode: true,
          );
          expect(
            emojiRegex.hasMatch(value),
            isFalse,
            reason: 'Rule 1 violation: Emoji found in "$key" ($lang): $value',
          );
          // Invariant Rule 2: Zero Parentheses
          expect(
            value.contains('(') || value.contains(')'),
            isFalse,
            reason: 'Rule 2 violation: Parenthesis found in "$key" ($lang): $value',
          );
        }
      }
    });
  });
}
