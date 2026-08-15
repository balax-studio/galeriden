import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Button Spam & Chaos Prevention Tests', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('performWorkshopStationRepair prevents redundant repairs on already-perfect parts', () {
      final notifier = container.read(gameProvider.notifier);

      final car = CarModel(
        id: 'test_car_1',
        brand: 'Toyo',
        modelName: 'Yarışçı',
        modelYear: 2022,
        bodyType: 'Sedan',
        colorHex: 'FFFFFF',
        currentPurchasePrice: 100000.0,
        baseMarketValue: 120000.0,
        expertise: ExpertiseReport(
          engineCondition: 100.0,
          transmissionCondition: 100.0,
          tramerAmount: 0,
          mileage: 25000,
          isMileageTampered: false,
          bodyParts: {
            'frontBumper': PartStatus.original,
            'hood': PartStatus.original,
            'roof': PartStatus.original,
          },
        ),
      );

      notifier.state = notifier.state.copyWith(
        balance: 500000.0,
        ownedCars: [car],
        characterOrigin: CharacterOrigin.sehirliYatirimci,
      );

      // Attempt to repair engine when already 100%
      final engineRepairResult = notifier.performWorkshopStationRepair(
        car.id,
        repairType: 'engine',
        cost: 18500.0,
      );
      expect(engineRepairResult, isFalse, reason: 'Engine is already 100%, repair should be rejected');

      // Attempt to repair transmission when already 100%
      final transRepairResult = notifier.performWorkshopStationRepair(
        car.id,
        repairType: 'transmission',
        cost: 12000.0,
      );
      expect(transRepairResult, isFalse, reason: 'Transmission is already 100%, repair should be rejected');

      // Attempt bodywork when all parts are original
      final bodyRepairResult = notifier.performWorkshopStationRepair(
        car.id,
        repairType: 'bodywork',
        cost: 22000.0,
      );
      expect(bodyRepairResult, isFalse, reason: 'Body parts are original, repair should be rejected');

      // Now set engine condition to 70% and test repair success
      final damagedCar = car.copyWith(
        expertise: car.expertise.copyWith(engineCondition: 70.0),
      );
      notifier.state = notifier.state.copyWith(ownedCars: [damagedCar]);

      final initialBalance = notifier.state.balance;
      final validRepairResult = notifier.performWorkshopStationRepair(
        car.id,
        repairType: 'engine',
        cost: 18500.0,
      );
      expect(validRepairResult, isTrue);
      expect(notifier.state.ownedCars.first.expertise.engineCondition, 100.0);
      expect(notifier.state.balance, initialBalance - 18500.0);

      // Immediate second repair must now fail
      final secondRepairResult = notifier.performWorkshopStationRepair(
        car.id,
        repairType: 'engine',
        cost: 18500.0,
      );
      expect(secondRepairResult, isFalse, reason: 'Second immediate repair must be rejected without charging money');
      expect(notifier.state.balance, initialBalance - 18500.0);
    });

    test('performWashService prevents duplicate wash charges when already applied', () {
      final notifier = container.read(gameProvider.notifier);

      final car = CarModel(
        id: 'wash_car_1',
        brand: 'Ford',
        modelName: 'Focus',
        modelYear: 2020,
        bodyType: 'Hatchback',
        colorHex: '0000FF',
        currentPurchasePrice: 80000.0,
        baseMarketValue: 90000.0,
        expertise: ExpertiseReport(
          engineCondition: 100.0,
          transmissionCondition: 100.0,
          tramerAmount: 0,
          mileage: 40000,
          isMileageTampered: false,
          bodyParts: {},
        ),
        isWashed: false,
        isPolished: false,
        isDetailedCleaned: false,
      );

      notifier.state = notifier.state.copyWith(
        balance: 100000.0,
        ownedCars: [car],
      );

      // First wash succeeds
      final wash1 = notifier.performWashService(
        car.id,
        cost: 350.0,
        valueBoostPercent: 0.01,
        setPolished: false,
        setDetailed: false,
      );
      expect(wash1, isTrue);
      expect(notifier.state.ownedCars.first.isWashed, isTrue);
      expect(notifier.state.balance, 100000.0 - 350.0);

      // Second identical wash fails to prevent spamming
      final wash2 = notifier.performWashService(
        car.id,
        cost: 350.0,
        valueBoostPercent: 0.01,
        setPolished: false,
        setDetailed: false,
      );
      expect(wash2, isFalse);
      expect(notifier.state.balance, 100000.0 - 350.0);
    });

    test('washAllCars returns false if all cars are already cleaned', () {
      final notifier = container.read(gameProvider.notifier);

      final cleanCar = CarModel(
        id: 'clean_car_1',
        brand: 'BMW',
        modelName: '320i',
        modelYear: 2021,
        bodyType: 'Sedan',
        colorHex: '111111',
        currentPurchasePrice: 150000.0,
        baseMarketValue: 170000.0,
        expertise: ExpertiseReport(
          engineCondition: 100.0,
          transmissionCondition: 100.0,
          tramerAmount: 0,
          mileage: 15000,
          isMileageTampered: false,
          bodyParts: {},
        ),
        isWashed: true,
        isPolished: true,
        isDetailedCleaned: true,
      );

      notifier.state = notifier.state.copyWith(
        balance: 100000.0,
        ownedCars: [cleanCar],
      );

      final result = notifier.washAllCars();
      expect(result, isFalse, reason: 'All cars already clean, no charge made');
      expect(notifier.state.balance, 100000.0);
    });

    test('purchaseShowroomDecor prevents duplicate building & button spamming', () {
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        balance: 100000.0,
        reputationScore: 100,
        unlockedDecorIds: [],
      );

      // First purchase succeeds
      final build1 = notifier.purchaseShowroomDecor(
        decorId: 'decor_led_grid',
        cost: 25000.0,
        reputationBonus: 5.0,
      );

      expect(build1, isTrue);
      expect(notifier.state.balance, 75000.0);
      expect(notifier.state.reputationScore, 105);
      expect(notifier.state.unlockedDecorIds.contains('decor_led_grid'), isTrue);

      // Second immediate click (spamming "İNŞA ET") must be rejected without deducting money
      final build2 = notifier.purchaseShowroomDecor(
        decorId: 'decor_led_grid',
        cost: 25000.0,
        reputationBonus: 5.0,
      );

      expect(build2, isFalse, reason: 'Duplicate build must be rejected');
      expect(notifier.state.balance, 75000.0, reason: 'Balance must not change on spam clicks');
      expect(notifier.state.reputationScore, 105);
      expect(notifier.state.unlockedDecorIds.length, 1);

      // Insufficient balance rejection
      notifier.state = notifier.state.copyWith(balance: 10000.0);
      final build3 = notifier.purchaseShowroomDecor(
        decorId: 'decor_granite_floor',
        cost: 45000.0,
        reputationBonus: 8.0,
      );
      expect(build3, isFalse, reason: 'Cannot purchase decor when funds are insufficient');
      expect(notifier.state.balance, 10000.0);
    });
  });
}
