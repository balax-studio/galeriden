import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/game_event_model.dart';
import 'package:galeriden/data/models/scrapyard_model.dart';
import 'package:galeriden/domain/usecases/contextual_emergency_ad_engine.dart';

void main() {
  group('ContextualEmergencyAdEngine Unit Tests', () {
    late DealershipModel baseModel;

    setUp(() {
      baseModel = DealershipModel.initial().copyWith(
        balance: 200000.0,
        maxGarageSlots: 5,
        ownedCars: [],
        salvagedParts: [],
        reputationScore: 50,
        dailyWorkshopRepairsCount: 0,
        dailyCarWashCount: 0,
        recentEvents: [],
      );
    });

    test('1. Direct purchase shortfall has top priority over general cash crisis', () {
      final model = baseModel.copyWith(balance: 10000.0);
      final encounter = ContextualEmergencyAdEngine.evaluateNeed(
        game: model,
        purchaseShortfall: 24500.0,
      );

      expect(encounter, isNotNull);
      expect(encounter!.needType, equals(EmergencyNeedType.purchaseShortfall));
      expect(encounter.grantAmount, equals(24500.0));
      expect(encounter.avatarKey, equals('suit'));
      expect(encounter.translationArgs['shortfall'], equals('24500'));
    });

    test('2. Cash crisis triggers when balance is under 20,000 TL', () {
      final model = baseModel.copyWith(balance: 12000.0, level: 1);
      final encounter = ContextualEmergencyAdEngine.evaluateNeed(
        game: model,
      );

      expect(encounter, isNotNull);
      expect(encounter!.needType, equals(EmergencyNeedType.cashCrisis));
      expect(encounter.grantAmount, greaterThanOrEqualTo(25000.0));
      expect(encounter.avatarKey, equals('mustache'));
    });

    test('3. Garage full triggers when owned cars equals or exceeds maxGarageSlots', () {
      final testCar = CarModel(
        id: 'test_car_1',
        brand: 'Renault',
        modelName: 'Clio',
        modelYear: 2020,
        bodyType: 'Hatchback',
        colorHex: '0xFFFFFFFF',
        colorDisplayName: 'Beyaz',
        colorRarity: 'common',
        plateNumber: '34 TEST 01',
        plateRarity: 'common',
        baseMarketValue: 300000.0,
        currentPurchasePrice: 250000.0,
        expertise: ExpertiseReport(
          engineCondition: 100.0,
          transmissionCondition: 100.0,
          tramerAmount: 0,
          mileage: 45000,
          isMileageTampered: false,
          bodyParts: const {},
        ),
      );

      final model = baseModel.copyWith(
        balance: 300000.0,
        maxGarageSlots: 2,
        ownedCars: [testCar, testCar],
      );

      final encounter = ContextualEmergencyAdEngine.evaluateNeed(game: model);

      expect(encounter, isNotNull);
      expect(encounter!.needType, equals(EmergencyNeedType.garageFull));
      expect(encounter.garageSlotBonus, equals(1));
      expect(encounter.avatarKey, equals('hat'));
    });

    test('4. Action quota exhausted triggers when workshop or car wash limit is reached', () {
      final model = baseModel.copyWith(
        balance: 300000.0,
        dailyWorkshopRepairsCount: 4,
      );

      final encounter = ContextualEmergencyAdEngine.evaluateNeed(game: model);

      expect(encounter, isNotNull);
      expect(encounter!.needType, equals(EmergencyNeedType.actionQuotaExhausted));
      expect(encounter.resetDailyActions, isTrue);
      expect(encounter.avatarKey, equals('mechanic'));
    });

    test('5. Parts shortage triggers when damaged car exists and inventory is empty', () {
      final damagedCar = CarModel(
        id: 'damaged_car_1',
        brand: 'Fiat',
        modelName: 'Egea',
        modelYear: 2019,
        bodyType: 'Sedan',
        colorHex: '0xFF000000',
        colorDisplayName: 'Siyah',
        colorRarity: 'common',
        plateNumber: '34 DMG 01',
        plateRarity: 'common',
        baseMarketValue: 200000.0,
        currentPurchasePrice: 150000.0,
        expertise: ExpertiseReport(
          engineCondition: 70.0,
          transmissionCondition: 80.0,
          tramerAmount: 5000,
          mileage: 95000,
          isMileageTampered: false,
          bodyParts: const {'Kaput': PartStatus.changed},
        ),
      );

      final model = baseModel.copyWith(
        balance: 300000.0,
        ownedCars: [damagedCar],
        salvagedParts: [],
      );

      final encounter = ContextualEmergencyAdEngine.evaluateNeed(game: model);

      expect(encounter, isNotNull);
      expect(encounter!.needType, equals(EmergencyNeedType.partsShortage));
      expect(encounter.grantPartsCrate, isTrue);
    });

    test('6. Level-up stagnation triggers when reputation is between 75 and 99', () {
      final model = baseModel.copyWith(
        balance: 300000.0,
        reputationScore: 85,
      );

      final encounter = ContextualEmergencyAdEngine.evaluateNeed(game: model);

      expect(encounter, isNotNull);
      expect(encounter!.needType, equals(EmergencyNeedType.levelUpStagnation));
      expect(encounter.reputationBonus, equals(15));
      expect(encounter.avatarKey, equals('glasses'));
    });

    test('7. Post disaster shock triggers when a recent negative game event exists', () {
      final negativeEvent = GameEventModel(
        id: 'storm_event_1',
        title: 'Dolu Fırtınası',
        description: 'Şiddetli dolu araçlara zarar verdi.',
        amount: 25000.0,
        type: GameEventType.badEvent,
        date: DateTime.now(),
      );

      final model = baseModel.copyWith(
        balance: 300000.0,
        recentEvents: [negativeEvent],
      );

      final encounter = ContextualEmergencyAdEngine.evaluateNeed(game: model);

      expect(encounter, isNotNull);
      expect(encounter!.needType, equals(EmergencyNeedType.postDisasterShock));
      expect(encounter.grantAmount, greaterThanOrEqualTo(20000.0));
      expect(encounter.avatarKey, equals('heritage'));
    });

    test('8. Returns null when player has healthy state and no bottlenecks', () {
      final model = baseModel.copyWith(
        balance: 500000.0,
        maxGarageSlots: 10,
        ownedCars: [],
        salvagedParts: [
          const SalvagedPart(
            id: 'p1',
            name: 'Fren Balatası',
            carModelName: 'Renault Clio',
            category: 'brakes',
            conditionPercent: 100,
            estimatedValue: 2000.0,
          )
        ],
        reputationScore: 50,
        dailyWorkshopRepairsCount: 0,
        dailyCarWashCount: 0,
        recentEvents: [],
      );

      final encounter = ContextualEmergencyAdEngine.evaluateNeed(game: model);
      expect(encounter, isNull);
    });

    test('9. Cooldown pacing respects day gate and real-world debounce seconds', () {
      final now = DateTime(2026, 9, 8, 12, 0, 0);

      // Same day -> should return false
      expect(
        ContextualEmergencyAdEngine.canTriggerUnprompted(
          currentDay: 5,
          lastTriggerDay: 5,
          lastTriggerRealTime: now.subtract(const Duration(minutes: 10)),
          now: now,
        ),
        isFalse,
      );

      // New day, but fired 1 minute ago -> should return false due to debounce
      expect(
        ContextualEmergencyAdEngine.canTriggerUnprompted(
          currentDay: 6,
          lastTriggerDay: 5,
          lastTriggerRealTime: now.subtract(const Duration(seconds: 60)),
          now: now,
        ),
        isFalse,
      );

      // New day, fired 5 minutes ago -> should return true
      expect(
        ContextualEmergencyAdEngine.canTriggerUnprompted(
          currentDay: 6,
          lastTriggerDay: 5,
          lastTriggerRealTime: now.subtract(const Duration(minutes: 5)),
          now: now,
        ),
        isTrue,
      );
    });
  });
}
