import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Car Wash & Detailing Independent Package Tests', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    CarModel createTestCar() {
      return CarModel(
        id: 'test_car_wash_1',
        brand: 'Merso',
        modelName: 'C-200 Makam AMG',
        modelYear: 2020,
        bodyType: 'Sedan',
        colorHex: '#000000',
        baseMarketValue: 500000.0,
        currentPurchasePrice: 450000.0,
        expertise: ExpertiseReport(
          engineCondition: 80.0,
          transmissionCondition: 85.0,
          tramerAmount: 0,
          mileage: 60000,
          isMileageTampered: false,
          bodyParts: {},
        ),
        isWashed: false,
        isPolished: false,
        isDetailedCleaned: false,
        appliedDetailingOptionIds: [],
      );
    }

    test('1. Applying Package 1 (Köpüklü Yıkama) sets isWashed but does NOT mark Package 2 (Interior)', () {
      final notifier = container.read(gameProvider.notifier);
      final car = createTestCar();

      notifier.state = notifier.state.copyWith(
        balance: 100000.0,
        ownedCars: [car],
      );

      // Apply Package 1
      final washSuccess = notifier.performWashService(
        car.id,
        cost: 350.0,
        valueBoostPercent: 0.01,
        setWashed: true,
        setInterior: false,
        setPolished: false,
        setDetailed: false,
      );

      expect(washSuccess, isTrue);
      final updatedCar = notifier.state.ownedCars.first;

      // Package 1 is completed
      expect(updatedCar.isWashed, isTrue);

      // Package 2, 3, 4 remain unapplied
      expect(updatedCar.isInteriorCleaned, isFalse);
      expect(updatedCar.isPolished, isFalse);
      expect(updatedCar.isDetailedCleaned, isFalse);
    });

    test('2. Package 2 (Detaylı İç-Dış Temizlik) can be applied after Package 1 independently', () {
      final notifier = container.read(gameProvider.notifier);
      final car = createTestCar();

      notifier.state = notifier.state.copyWith(
        balance: 100000.0,
        ownedCars: [car],
      );

      // Step 1: Apply Package 1 (Köpüklü Yıkama)
      notifier.performWashService(
        car.id,
        cost: 350.0,
        valueBoostPercent: 0.01,
        setWashed: true,
      );

      expect(notifier.state.ownedCars.first.isWashed, isTrue);
      expect(notifier.state.ownedCars.first.isInteriorCleaned, isFalse);

      // Step 2: Apply Package 2 (Detaylı İç-Dış Temizlik)
      final interiorSuccess = notifier.performWashService(
        car.id,
        cost: 1200.0,
        valueBoostPercent: 0.03,
        setWashed: true,
        setInterior: true,
      );

      expect(interiorSuccess, isTrue);
      final fullyWashedCar = notifier.state.ownedCars.first;
      expect(fullyWashedCar.isWashed, isTrue);
      expect(fullyWashedCar.isInteriorCleaned, isTrue);
      expect(fullyWashedCar.isPolished, isFalse);
      expect(fullyWashedCar.isDetailedCleaned, isFalse);

      // Step 3: Trying to apply Package 2 again is rejected
      final duplicateInterior = notifier.performWashService(
        car.id,
        cost: 1200.0,
        valueBoostPercent: 0.03,
        setInterior: true,
      );
      expect(duplicateInterior, isFalse);
    });
  });
}
