import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/constants/game_constants.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/domain/usecases/market_engine.dart';

void main() {
  group('Market Budget Car & Brand Sanitization Tests', () {
    test('1. MarketEngine guarantees at least 1 affordable car within low player budget', () {
      const lowBalance = 50000.0;
      final listings = MarketEngine.generateRandomListings(
        count: 8,
        playerLevel: 1,
        playerBalance: lowBalance,
      );

      expect(listings, isNotEmpty);
      final affordableCount = listings.where((l) => l.askingPrice <= lowBalance).length;
      expect(affordableCount, greaterThanOrEqualTo(1),
          reason: 'Market must always provide at least 1 affordable car to prevent early-game soft-lock');

      final cheapest = listings.reduce((a, b) => a.askingPrice < b.askingPrice ? a : b);
      expect(cheapest.askingPrice, lessThanOrEqualTo(lowBalance));
      expect(cheapest.askingPrice, greaterThanOrEqualTo(35000.0));
    });

    test('2. CarBrandData models do NOT contain brand name prefix', () {
      for (final brand in GameConstants.carBrands) {
        final brandLower = brand.name.toLowerCase();
        for (final model in brand.models) {
          expect(
            model.toLowerCase().startsWith('$brandLower '),
            isFalse,
            reason: 'Brand "${brand.name}" should not be prefixed in model name "$model"',
          );
        }
      }
    });

    test('3. CarModel.sanitizeModelName strips repeated brand name prefix from legacy and new cars', () {
      final legacyCar = CarModel(
        id: 'car_legacy_1',
        brand: 'Merso',
        modelName: 'Merso G-63 Tuğla V8',
        modelYear: 2021,
        bodyType: 'SUV',
        colorHex: '#000000',
        baseMarketValue: 1200000.0,
        currentPurchasePrice: 1100000.0,
        expertise: ExpertiseReport(
          engineCondition: 90.0,
          transmissionCondition: 90.0,
          tramerAmount: 0,
          mileage: 30000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );

      expect(legacyCar.modelName, 'G-63 Tuğla V8');
      expect(legacyCar.carTitle, 'Merso G-63 Tuğla V8');
      expect(legacyCar.carModelName, 'Merso G-63 Tuğla V8');

      final cleanCar = CarModel(
        id: 'car_clean_1',
        brand: 'Toyo',
        modelName: 'Korola 1.8 Hibrit Eko',
        modelYear: 2022,
        bodyType: 'Sedan',
        colorHex: '#FFFFFF',
        baseMarketValue: 750000.0,
        currentPurchasePrice: 700000.0,
        expertise: ExpertiseReport(
          engineCondition: 95.0,
          transmissionCondition: 95.0,
          tramerAmount: 0,
          mileage: 20000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );

      expect(cleanCar.modelName, 'Korola 1.8 Hibrit Eko');
      expect(cleanCar.carTitle, 'Toyo Korola 1.8 Hibrit Eko');
    });

    test('4. As player safe balance grows, low-priced cars are suppressed and high-tier cars dominate', () {
      const highBalance = 10000000.0; // ₺10M Tycoon cash
      final listings = MarketEngine.generateRandomListings(
        count: 50,
        playerLevel: 5,
        playerBalance: highBalance,
      );

      expect(listings.length, 50);

      // Low priced vehicles under ₺150.000 should be exceptionally rare (< 8% max, usually 0-2 out of 50)
      final lowTierCount = listings.where((l) => l.askingPrice < 150000.0 && !l.car.isRare && !l.car.isBarnFind).length;
      expect(lowTierCount, lessThanOrEqualTo(4),
          reason: 'At ₺10M wealth, non-collectible low-tier clunkers (< ₺150k) should be suppressed');

      // High-tier vehicles (>= ₺500.000) should dominate
      final highTierCount = listings.where((l) => l.askingPrice >= 500000.0).length;
      expect(highTierCount, greaterThanOrEqualTo(30),
          reason: 'At ₺10M wealth, majority of market should offer high-value trade opportunities');

      // Average price should be substantially high
      final averagePrice = listings.map((l) => l.askingPrice).reduce((a, b) => a + b) / listings.length;
      expect(averagePrice, greaterThan(1200000.0));
    });

    test('5. Prestige classics like Supra and S2000 have proper enthusiast base values', () {
      final supraListings = MarketEngine.generateRandomListings(
        count: 100,
        playerLevel: 4,
        playerBalance: 5000000.0,
      );

      final supras = supraListings.where((l) => l.car.modelName.contains('Supra')).toList();
      for (final s in supras) {
        // Supra should never be a ₺45.000 clunker
        expect(s.car.baseMarketValue, greaterThanOrEqualTo(2000000.0));
        expect(s.askingPrice, greaterThanOrEqualTo(1000000.0));
      }
    });
  });
}
