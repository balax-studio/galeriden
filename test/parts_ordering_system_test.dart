import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/mission_model.dart';
import 'package:galeriden/data/models/part_order_model.dart';
import 'package:galeriden/data/models/scrapyard_model.dart';
import 'package:galeriden/domain/usecases/repair_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Spare Parts Ordering & Inventory Management Test Suite', () {
    late ProviderContainer container;
    late CarModel testCar;
    late SalvagedPart testSalvagePart;

    setUp(() {
      container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();

      testCar = CarModel(
        id: 'car_part_test_1',
        brand: 'BMW',
        modelName: '320i M Sport',
        modelYear: 2020,
        bodyType: 'Sedan',
        colorHex: '#003366',
        baseMarketValue: 1200000,
        currentPurchasePrice: 950000,
        expertise: ExpertiseReport(
          engineCondition: 60,
          transmissionCondition: 50,
          tramerAmount: 15000,
          mileage: 85000,
          isMileageTampered: false,
          bodyParts: {
            'Kaput': PartStatus.damaged,
            'Bagaj': PartStatus.changed,
            'Sol Ön Çamurluk': PartStatus.painted,
            'Tavan': PartStatus.original,
          },
        ),
      );

      testSalvagePart = SalvagedPart(
        id: 'salvage_kaput_1',
        name: 'Kaput',
        category: 'body',
        conditionPercent: 88,
        estimatedValue: 8000,
        carModelName: 'BMW 320i',
        tier: PartQualityTier.good,
      );

      container.read(gameProvider.notifier).state =
          container.read(gameProvider).copyWith(
                balance: 200000,
                ownedCars: [testCar],
                salvagedParts: [testSalvagePart],
                pendingOrders: [],
                activeMissions: [
                  MissionModel(
                    id: 'mission_repair_parts_daily',
                    title: 'Yedek Parça Ustası',
                    description: '3 parça tamir et',
                    rewardMoney: 15000,
                    rewardXP: 100,
                    type: MissionType.repairParts,
                    targetGoal: 3,
                    currentProgress: 0,
                  ),
                ],
              );
    });

    tearDown(() {
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      container.dispose();
    });

    test('1. Part name fuzzy resolution matches Ön Kaput to Kaput and Bagaj Kapağı to Bagaj', () {
      // Test direct repair applying Ön Kaput
      final updatedCar1 = RepairEngine.applyInstalledPart(
          testCar, 'Ön Kaput', OrderType.newOemPart);
      expect(updatedCar1.expertise.bodyParts['Kaput'], equals(PartStatus.original));
      expect(updatedCar1.expertise.partConditions['Kaput'], equals(100.0));

      // Test direct repair applying Bagaj Kapağı with Master Repair
      final updatedCar2 = RepairEngine.applyInstalledPart(
          testCar, 'Bagaj Kapağı', OrderType.masterRepair);
      expect(updatedCar2.expertise.bodyParts['Bagaj'], equals(PartStatus.painted));
      expect(updatedCar2.expertise.partConditions['Bagaj'], equals(95.0));

      // Test direct repair applying Sol Çamurluk
      final updatedCar3 = RepairEngine.applyInstalledPart(
          testCar, 'Sol Çamurluk', OrderType.newOemPart);
      expect(updatedCar3.expertise.bodyParts['Sol Ön Çamurluk'], equals(PartStatus.original));
    });

    test('2. Engine repair does NOT affect transmission, and transmission repair does NOT affect engine', () {
      final initialEngine = testCar.expertise.engineCondition;
      final initialTrans = testCar.expertise.transmissionCondition;

      // Repair Engine only
      final carEngineRepaired = RepairEngine.applyInstalledPart(
          testCar, 'Motor Bloğu & Piston', OrderType.newOemPart);
      expect(carEngineRepaired.expertise.engineCondition, equals(100.0));
      expect(carEngineRepaired.expertise.transmissionCondition, equals(initialTrans));

      // Repair Transmission only
      final carTransRepaired = RepairEngine.applyInstalledPart(
          testCar, 'Şanzıman & Debriyaj', OrderType.newOemPart);
      expect(carTransRepaired.expertise.transmissionCondition, equals(100.0));
      expect(carTransRepaired.expertise.engineCondition, equals(initialEngine));
    });

    test('3. Ordering a part deducts balance and adds a pending order to state', () {
      final initialBalance = container.read(gameProvider).balance;

      final success = container.read(gameProvider.notifier).orderPart(
            carId: testCar.id,
            partName: 'Ön Kaput',
            orderType: OrderType.newOemPart,
            cost: 12000,
            deliveryDurationSeconds: 120,
          );

      expect(success, isTrue);
      final state = container.read(gameProvider);
      expect(state.balance, equals(initialBalance - 12000));
      expect(state.pendingOrders.length, equals(1));
      expect(state.pendingOrders.first.partName, equals('Ön Kaput'));
      expect(state.pendingOrders.first.carId, equals(testCar.id));
      expect(state.pendingOrders.first.isDelivered, isFalse);
    });

    test('4. Ordering with Salvaged Scrap consumes matching scrap part and costs 0 cash', () {
      final initialBalance = container.read(gameProvider).balance;
      expect(container.read(gameProvider).salvagedParts.length, equals(1));

      final success = container.read(gameProvider.notifier).orderPart(
            carId: testCar.id,
            partName: 'Kaput',
            orderType: OrderType.salvagedScrap,
            cost: 10000, // Should be free for scrap
            deliveryDurationSeconds: 20,
          );

      expect(success, isTrue);
      final state = container.read(gameProvider);
      expect(state.balance, equals(initialBalance)); // 0 cost
      expect(state.salvagedParts.isEmpty, isTrue); // Consumed from inventory
      expect(state.pendingOrders.length, equals(1));
      expect(state.pendingOrders.first.orderType, equals(OrderType.salvagedScrap));
    });

    test('5. Duplicate pending order for the same car and part is prevented', () {
      container.read(gameProvider.notifier).orderPart(
            carId: testCar.id,
            partName: 'Ön Kaput',
            orderType: OrderType.newOemPart,
            cost: 12000,
            deliveryDurationSeconds: 120,
          );

      // Attempting to place a second identical order for the same car & part
      final secondOrderSuccess = container.read(gameProvider.notifier).orderPart(
            carId: testCar.id,
            partName: 'Ön Kaput',
            orderType: OrderType.newOemPart,
            cost: 12000,
            deliveryDurationSeconds: 120,
          );

      expect(secondOrderSuccess, isFalse);
      expect(container.read(gameProvider).pendingOrders.length, equals(1));
    });

    test('6. Canceling a part order refunds cash or restores salvaged part to inventory', () {
      final initialBalance = container.read(gameProvider).balance;

      container.read(gameProvider.notifier).orderPart(
            carId: testCar.id,
            partName: 'Ön Kaput',
            orderType: OrderType.newOemPart,
            cost: 15000,
            deliveryDurationSeconds: 120,
          );

      expect(container.read(gameProvider).balance, equals(initialBalance - 15000));
      final orderId = container.read(gameProvider).pendingOrders.first.id;

      final cancelSuccess =
          container.read(gameProvider.notifier).cancelPartOrder(orderId);

      expect(cancelSuccess, isTrue);
      expect(container.read(gameProvider).pendingOrders.isEmpty, isTrue);
      expect(container.read(gameProvider).balance, equals(initialBalance));
    });

    test('7. Canceling a salvaged scrap order returns the scrap part to inventory', () {
      container.read(gameProvider.notifier).orderPart(
            carId: testCar.id,
            partName: 'Kaput',
            orderType: OrderType.salvagedScrap,
            cost: 8000,
            deliveryDurationSeconds: 20,
          );

      expect(container.read(gameProvider).salvagedParts.isEmpty, isTrue);
      final orderId = container.read(gameProvider).pendingOrders.first.id;

      final cancelSuccess =
          container.read(gameProvider.notifier).cancelPartOrder(orderId);

      expect(cancelSuccess, isTrue);
      expect(container.read(gameProvider).pendingOrders.isEmpty, isTrue);
      expect(container.read(gameProvider).salvagedParts.length, equals(1));
      expect(container.read(gameProvider).salvagedParts.first.name, equals('Kaput'));
    });

    test('8. advanceGameDay accelerates and auto-delivers all pending orders', () {
      container.read(gameProvider.notifier).orderPart(
            carId: testCar.id,
            partName: 'Ön Kaput',
            orderType: OrderType.newOemPart,
            cost: 12000,
            deliveryDurationSeconds: 180,
          );

      expect(container.read(gameProvider).pendingOrders.first.isDelivered, isFalse);

      // Advance game day
      container.read(gameProvider.notifier).advanceGameDay();

      final updatedOrders = container.read(gameProvider).pendingOrders;
      expect(updatedOrders.length, equals(1));
      expect(updatedOrders.first.isDelivered, isTrue);
    });

    test('9. Installing delivered part awards XP, updates repair mission, increments stats and repairs vehicle', () {
      final initialXp = container.read(gameProvider).skills.xp;

      container.read(gameProvider.notifier).orderPart(
            carId: testCar.id,
            partName: 'Ön Kaput',
            orderType: OrderType.newOemPart,
            cost: 12000,
            deliveryDurationSeconds: 10,
          );

      final orderId = container.read(gameProvider).pendingOrders.first.id;
      // Fast forward delivery
      container.read(gameProvider.notifier).instantDeliverPartOrder(orderId);

      final installSuccess =
          container.read(gameProvider.notifier).installDeliveredPart(orderId);

      expect(installSuccess, isTrue);
      final state = container.read(gameProvider);
      expect(state.pendingOrders.isEmpty, isTrue);

      // Verify car was repaired
      final car = state.ownedCars.firstWhere((c) => c.id == testCar.id);
      expect(car.expertise.bodyParts['Kaput'], equals(PartStatus.original));

      // Verify XP awarded
      expect(state.skills.xp, equals(initialXp + 35));

      // Verify repair mission progress incremented
      final mission = state.activeMissions.firstWhere((m) => m.id == 'mission_repair_parts_daily');
      expect(mission.currentProgress, equals(1));
      expect(state.partsRepairedLast7Days, equals(1));
    });

    test('10. If car is sold/missing when installing, stranded order is cleaned up safely without crash', () {
      final initialBalance = container.read(gameProvider).balance;

      container.read(gameProvider.notifier).orderPart(
            carId: testCar.id,
            partName: 'Ön Kaput',
            orderType: OrderType.newOemPart,
            cost: 12000,
            deliveryDurationSeconds: 10,
          );

      final orderId = container.read(gameProvider).pendingOrders.first.id;
      container.read(gameProvider.notifier).instantDeliverPartOrder(orderId);

      // Simulate selling or removing the car
      container.read(gameProvider.notifier).state =
          container.read(gameProvider).copyWith(ownedCars: []);

      // Attempt to install for non-existent car
      final installResult =
          container.read(gameProvider.notifier).installDeliveredPart(orderId);

      expect(installResult, isFalse);
      // Stranded order must be cleanly removed and refunded
      expect(container.read(gameProvider).pendingOrders.isEmpty, isTrue);
      expect(container.read(gameProvider).balance, equals(initialBalance));
    });
  });
}
