import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/player_skills.dart';
import 'package:galeriden/domain/usecases/repair_engine.dart';

void main() {
  group('Workshop Gating, Valuation, Reviews & XP Curve Test Suite', () {
    test('1. Engine & Transmission >= 95% condition cannot be overhauled unnecessarily', () {
      final healthyCar = CarModel(
        id: 'car_healthy',
        brand: 'Bemeve',
        modelName: 'Üç Yirmi Dizel',
        modelYear: 2021,
        bodyType: 'Sedan',
        colorHex: '#FFFFFF',
        baseMarketValue: 1200000,
        currentPurchasePrice: 1100000,
        expertise: ExpertiseReport(
          engineCondition: 96.0,
          transmissionCondition: 98.0,
          tramerAmount: 0,
          mileage: 45000,
          isMileageTampered: false,
          bodyParts: {
            'Ön Kaput': PartStatus.original,
            'Tavan': PartStatus.original,
          },
        ),
      );

      final engineResult = RepairEngine.repairEngine(healthyCar, RepairTier.master);
      final transResult = RepairEngine.repairTransmission(healthyCar, RepairTier.master);

      expect(engineResult.isSuccess, isFalse);
      expect(engineResult.message.contains('kusursuz') || engineResult.message.contains('gerekmiyor'), isTrue);
      expect(transResult.isSuccess, isFalse);
      expect(transResult.message.contains('kusursuz') || transResult.message.contains('gerekmiyor'), isTrue);

      final wornCar = CarModel(
        id: 'car_worn',
        brand: 'Bemeve',
        modelName: 'Üç Yirmi Dizel',
        modelYear: 2021,
        bodyType: 'Sedan',
        colorHex: '#FFFFFF',
        baseMarketValue: 1200000,
        currentPurchasePrice: 1100000,
        expertise: ExpertiseReport(
          engineCondition: 70.0,
          transmissionCondition: 65.0,
          tramerAmount: 0,
          mileage: 180000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );

      final wornEngineResult = RepairEngine.repairEngine(wornCar, RepairTier.master);
      final wornTransResult = RepairEngine.repairTransmission(wornCar, RepairTier.master);

      expect(wornEngineResult.isSuccess, isTrue);
      expect(wornEngineResult.updatedCar.expertise.engineCondition, equals(100.0));
      expect(wornTransResult.isSuccess, isTrue);
      expect(wornTransResult.updatedCar.expertise.transmissionCondition, equals(100.0));
    });

    test('2. Dynamic vehicle valuation scales proportionally with base market value', () {
      final budgetCar = CarModel(
        id: 'car_budget',
        brand: 'Fiyat',
        modelName: 'Ege Sedan',
        modelYear: 2020,
        bodyType: 'Sedan',
        colorHex: '#FFFFFF',
        baseMarketValue: 400000,
        currentPurchasePrice: 380000,
        expertise: ExpertiseReport(
          engineCondition: 90.0,
          transmissionCondition: 90.0,
          tramerAmount: 0,
          mileage: 80000,
          isMileageTampered: false,
          bodyParts: {},
        ),
        appliedDetailingOptionIds: ['ceramic_coating', 'interior_detailing'],
      );

      final luxuryCar = CarModel(
        id: 'car_luxury',
        brand: 'Merso',
        modelName: 'Es Beş Yüz Long',
        modelYear: 2022,
        bodyType: 'Sedan',
        colorHex: '#000000',
        baseMarketValue: 4000000,
        currentPurchasePrice: 3800000,
        expertise: ExpertiseReport(
          engineCondition: 90.0,
          transmissionCondition: 90.0,
          tramerAmount: 0,
          mileage: 20000,
          isMileageTampered: false,
          bodyParts: {},
        ),
        appliedDetailingOptionIds: ['ceramic_coating', 'interior_detailing'],
      );

      expect(luxuryCar.estimatedRealValue, greaterThan(3500000));
      expect(budgetCar.estimatedRealValue, greaterThan(350000));
    });

    test('3. Level 5+ XP curve requirement expands distance between levels', () {
      expect(PlayerSkills.requiredXpForLevel(1), equals(1500));
      expect(PlayerSkills.requiredXpForLevel(2), equals(3750));
      expect(PlayerSkills.requiredXpForLevel(3), equals(7500));
      expect(PlayerSkills.requiredXpForLevel(4), equals(14000));
      expect(PlayerSkills.requiredXpForLevel(5), equals(24000));

      final xpLevel5 = PlayerSkills.requiredXpForLevel(5);
      final xpLevel6 = PlayerSkills.requiredXpForLevel(6);
      final xpLevel7 = PlayerSkills.requiredXpForLevel(7);

      expect(xpLevel6 - xpLevel5, greaterThan(10000));
      expect(xpLevel7 - xpLevel6, greaterThan(15000));
    });

    test('4. Invariant checks: zero emojis and zero parentheses in messages', () {
      final car = CarModel(
        id: 'c1',
        brand: 'Fiyat',
        modelName: 'Ege',
        modelYear: 2020,
        bodyType: 'Sedan',
        colorHex: '#FFFFFF',
        baseMarketValue: 500000,
        currentPurchasePrice: 450000,
        expertise: ExpertiseReport(
          engineCondition: 99.0,
          transmissionCondition: 99.0,
          tramerAmount: 0,
          mileage: 10000,
          isMileageTampered: false,
          bodyParts: {'Ön Kaput': PartStatus.original},
        ),
      );

      final resEngine = RepairEngine.repairEngine(car, RepairTier.master);
      final resTrans = RepairEngine.repairTransmission(car, RepairTier.master);

      expect(resEngine.message.contains('('), isFalse);
      expect(resEngine.message.contains(')'), isFalse);
      expect(resTrans.message.contains('('), isFalse);
      expect(resTrans.message.contains(')'), isFalse);

      final emojiRegex = RegExp(r'[\u{1F300}-\u{1F9FF}]|[\u{2600}-\u{26FF}]', unicode: true);
      expect(emojiRegex.hasMatch(resEngine.message), isFalse);
      expect(emojiRegex.hasMatch(resTrans.message), isFalse);
    });
  });
}
