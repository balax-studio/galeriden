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
  });
}
