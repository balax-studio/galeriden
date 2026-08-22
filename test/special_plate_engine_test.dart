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

    test('Custom Plate Evaluation: Legendary Keyword triggers legendary rarity and +35% boost', () {
      final evaluated = SpecialPlateEngine.evaluateCustomPlate(
        cityCode: '34',
        letters: 'ATA',
        digits: '1923',
      );

      expect(evaluated.plateNumber, equals('34 ATA 1923'));
      expect(evaluated.rarity, equals('legendary'));
      expect(evaluated.valueBonusPercent, equals(35));
      expect(evaluated.price, greaterThanOrEqualTo(80000.0));
    });

    test('Custom Plate Evaluation: Symmetrical pattern triggers symmetric rarity and +12% boost', () {
      final evaluated = SpecialPlateEngine.evaluateCustomPlate(
        cityCode: '06',
        letters: 'AB',
        digits: '606',
      );

      expect(evaluated.plateNumber, equals('06 AB 606'));
      expect(evaluated.rarity, equals('symmetric'));
      expect(evaluated.valueBonusPercent, equals(12));
      expect(evaluated.price, equals(42000.0));
    });

    test('Custom Plate Evaluation: Repeating numbers trigger repeated rarity and +8% boost', () {
      final evaluated = SpecialPlateEngine.evaluateCustomPlate(
        cityCode: '35',
        letters: 'XY',
        digits: '777',
      );

      expect(evaluated.plateNumber, equals('35 XY 777'));
      expect(evaluated.rarity, equals('repeated'));
      expect(evaluated.valueBonusPercent, equals(8));
      expect(evaluated.price, equals(30000.0));
    });

    test('State Integration: buyAndAssignPlate updates car plate and increases estimatedRealValue', () async {
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
      expect(newRealValue / initialRealValue, closeTo(1.35, 0.05)); // ~35% boost
    });
  });
}
