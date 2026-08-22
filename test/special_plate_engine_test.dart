import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/domain/usecases/special_plate_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Special License Plate Engine & Valuation Tests', () {
    test('Curated Catalogue is populated and correctly categorized', () {
      final plates = SpecialPlateEngine.curatedPlates;
      expect(plates.isNotEmpty, isTrue);

      final legendaryPlates = plates.where((p) => p.category == PlateCategory.legendary).toList();
      final teamPlates = plates.where((p) => p.category == PlateCategory.team).toList();
      final namePlates = plates.where((p) => p.category == PlateCategory.names).toList();
      final symmetricPlates = plates.where((p) => p.category == PlateCategory.symmetric).toList();

      expect(legendaryPlates.isNotEmpty, isTrue);
      expect(teamPlates.isNotEmpty, isTrue);
      expect(namePlates.isNotEmpty, isTrue);
      expect(symmetricPlates.isNotEmpty, isTrue);

      for (final plate in plates) {
        expect(plate.plateNumber.isNotEmpty, isTrue);
        expect(plate.price, greaterThan(0));
        expect(plate.valueBonusPercent, greaterThan(0));
        // Invariant check: No parentheses
        expect(plate.title.contains('('), isFalse, reason: 'Parenthesis found in title: ${plate.title}');
        expect(plate.title.contains(')'), isFalse, reason: 'Parenthesis found in title: ${plate.title}');
        expect(plate.description.contains('('), isFalse, reason: 'Parenthesis found in description: ${plate.description}');
        expect(plate.description.contains(')'), isFalse, reason: 'Parenthesis found in description: ${plate.description}');
        // Invariant check: No unicode emojis
        expect(RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true).hasMatch(plate.title), isFalse);
        expect(RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true).hasMatch(plate.description), isFalse);
      }
    });

    test('Custom Plate Evaluation: Legendary Keyword triggers legendary rarity and +10% boost', () {
      final evaluated = SpecialPlateEngine.evaluateCustomPlate(
        cityCode: '34',
        letters: 'ATA',
        digits: '1923',
      );

      expect(evaluated.plateNumber, equals('34 ATA 1923'));
      expect(evaluated.rarity, equals('legendary'));
      expect(evaluated.valueBonusPercent, equals(10));
      expect(evaluated.price, greaterThanOrEqualTo(80000.0));
    });

    test('Custom Plate Evaluation: Symmetrical pattern triggers symmetric rarity and +5% boost', () {
      final evaluated = SpecialPlateEngine.evaluateCustomPlate(
        cityCode: '06',
        letters: 'AB',
        digits: '606',
      );

      expect(evaluated.plateNumber, equals('06 AB 606'));
      expect(evaluated.rarity, equals('symmetric'));
      expect(evaluated.valueBonusPercent, equals(5));
      expect(evaluated.price, equals(42000.0));
    });

    test('Custom Plate Evaluation: Repeating numbers trigger repeated rarity and +3% boost', () {
      final evaluated = SpecialPlateEngine.evaluateCustomPlate(
        cityCode: '35',
        letters: 'XY',
        digits: '777',
      );

      expect(evaluated.plateNumber, equals('35 XY 777'));
      expect(evaluated.rarity, equals('repeated'));
      expect(evaluated.valueBonusPercent, equals(3));
      expect(evaluated.price, equals(30000.0));
    });

    test('State Integration: buyAndAssignPlate updates car plate and increases estimatedRealValue with capped boost', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final testCar = CarModel(
        id: 'car_plate_test_1',
        brand: 'BMW',
        modelName: '320i',
        modelYear: 2020,
        bodyType: 'Sedan',
        colorHex: '#000000',
        baseMarketValue: 1000000.0,
        currentPurchasePrice: 900000.0,
        plateNumber: '34 XYZ 123',
        plateRarity: 'standard',
        expertise: ExpertiseReport(
          engineCondition: 100.0,
          transmissionCondition: 100.0,
          tramerAmount: 0,
          mileage: 50000,
          isMileageTampered: false,
          bodyParts: const {},
        ),
      );

      // Add car to garage and give player balance
      notifier.state = notifier.state.copyWith(
        balance: 500000.0,
        ownedCars: [testCar],
      );

      final double initialRealValue = testCar.estimatedRealValue;

      // Assign legendary plate
      final success = notifier.buyAndAssignPlate(
        carId: testCar.id,
        plateNumber: '34 ATA 1881',
        plateRarity: 'legendary',
        cost: 150000.0,
        reputationBonus: 20,
      );

      expect(success, isTrue);
      expect(notifier.state.balance, equals(350000.0)); // 500k - 150k
      expect(notifier.state.ownedCars.first.plateNumber, equals('34 ATA 1881'));
      expect(notifier.state.ownedCars.first.plateRarity, equals('legendary'));

      final double newRealValue = notifier.state.ownedCars.first.estimatedRealValue;
      expect(newRealValue, greaterThan(initialRealValue));
      expect(newRealValue / initialRealValue, closeTo(1.10, 0.02)); // +10% boost for 1M car
    });

    test('Luxury Car Exploit Prevention: 10M car plate boost is strictly capped at max ₺250.000', () {
      final luxuryCar = CarModel(
        id: 'car_luxury_1',
        brand: 'Porsche',
        modelName: '911 GT3',
        modelYear: 2023,
        bodyType: 'Coupe',
        colorHex: '#FFFFFF',
        baseMarketValue: 10000000.0,
        currentPurchasePrice: 9500000.0,
        plateNumber: '34 XYZ 999',
        plateRarity: 'standard',
        expertise: ExpertiseReport(
          engineCondition: 100.0,
          transmissionCondition: 100.0,
          tramerAmount: 0,
          mileage: 5000,
          isMileageTampered: false,
          bodyParts: const {},
        ),
      );

      final carWithLegendaryPlate = luxuryCar.copyWith(
        plateRarity: 'legendary',
        plateNumber: '34 VIP 001',
      );

      final double gain = carWithLegendaryPlate.estimatedRealValue - luxuryCar.estimatedRealValue;
      expect(gain, closeTo(250000.0, 1.0)); // Exactly capped at +₺250.000 instead of unbounded +3.5M
    });

    test('Duplicate License Plate Prevention: Cannot assign duplicate plate or re-assign current plate', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      final car1 = CarModel(
        id: 'car_plate_dup_1',
        brand: 'BMW',
        modelName: '320i',
        modelYear: 2020,
        bodyType: 'Sedan',
        colorHex: '#000000',
        baseMarketValue: 1000000.0,
        currentPurchasePrice: 900000.0,
        plateNumber: '34 ATA 1881',
        plateRarity: 'legendary',
        expertise: ExpertiseReport(
          engineCondition: 100.0,
          transmissionCondition: 100.0,
          tramerAmount: 0,
          mileage: 50000,
          isMileageTampered: false,
          bodyParts: const {},
        ),
      );

      final car2 = CarModel(
        id: 'car_plate_dup_2',
        brand: 'Mercedes',
        modelName: 'C200',
        modelYear: 2021,
        bodyType: 'Sedan',
        colorHex: '#FFFFFF',
        baseMarketValue: 1200000.0,
        currentPurchasePrice: 1100000.0,
        plateNumber: '06 ABC 123',
        plateRarity: 'standard',
        expertise: ExpertiseReport(
          engineCondition: 100.0,
          transmissionCondition: 100.0,
          tramerAmount: 0,
          mileage: 30000,
          isMileageTampered: false,
          bodyParts: const {},
        ),
      );

      notifier.state = notifier.state.copyWith(
        balance: 500000.0,
        ownedCars: [car1, car2],
      );

      // Attempt 1: car2 tries to take car1's plate '34 ATA 1881' -> should FAIL
      final failAttempt1 = notifier.buyAndAssignPlate(
        carId: car2.id,
        plateNumber: '34 ATA 1881',
        plateRarity: 'legendary',
        cost: 150000.0,
        reputationBonus: 20,
      );
      expect(failAttempt1, isFalse);
      expect(notifier.state.balance, equals(500000.0)); // Balance unchanged
      expect(notifier.state.ownedCars[1].plateNumber, equals('06 ABC 123'));

      // Attempt 2: car1 tries to buy its own plate '34 ATA 1881' again -> should FAIL
      final failAttempt2 = notifier.buyAndAssignPlate(
        carId: car1.id,
        plateNumber: '34 ATA 1881',
        plateRarity: 'legendary',
        cost: 150000.0,
        reputationBonus: 20,
      );
      expect(failAttempt2, isFalse);
      expect(notifier.state.balance, equals(500000.0));

      // Attempt 3: car2 buys a new unique plate '06 BOSS 01' -> should SUCCEED
      final successAttempt = notifier.buyAndAssignPlate(
        carId: car2.id,
        plateNumber: '06 BOSS 01',
        plateRarity: 'legendary',
        cost: 110000.0,
        reputationBonus: 16,
      );
      expect(successAttempt, isTrue);
      expect(notifier.state.balance, equals(390000.0));
      expect(notifier.state.ownedCars[1].plateNumber, equals('06 BOSS 01'));
      expect(notifier.state.ownedCars[1].plateRarity, equals('legendary'));

      notifier.stopPeriodicOrganicOfferTimer();
    });
  });
}
