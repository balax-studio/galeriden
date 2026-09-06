import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/part_order_model.dart';
import 'package:galeriden/data/models/vehicle_category.dart';
import 'package:galeriden/domain/usecases/repair_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Vehicle-Aware Spare Parts Ordering & Anti-Spam Validation Tests', () {
    late ProviderContainer container;
    late CarModel pristineCar;
    late CarModel damagedCar;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();

      pristineCar = CarModel(
        id: 'car_pristine_golf',
        brand: 'Volk',
        modelName: 'Golf GTI Klasiği',
        modelYear: 2018,
        bodyType: 'Hatchback',
        colorHex: '0xFFFFFFFF',
        baseMarketValue: 120000,
        currentPurchasePrice: 120000,
        vehicleCategory: VehicleCategory.car,
        expertise: ExpertiseReport(
          engineCondition: 100.0,
          transmissionCondition: 100.0,
          tramerAmount: 0,
          mileage: 35000,
          isMileageTampered: false,
          bodyParts: {
            'Kaput': PartStatus.original,
            'Tavan': PartStatus.original,
            'Ön Tampon': PartStatus.original,
            'Sol Ön Kapı': PartStatus.original,
            'Sağ Ön Kapı': PartStatus.original,
            'Bagaj': PartStatus.original,
          },
        ),
      );

      damagedCar = CarModel(
        id: 'car_damaged_egea',
        brand: 'Fiyasko',
        modelName: 'Egea Easy',
        modelYear: 2020,
        bodyType: 'Sedan',
        colorHex: '0xFF333333',
        baseMarketValue: 60000,
        currentPurchasePrice: 50000,
        vehicleCategory: VehicleCategory.car,
        expertise: ExpertiseReport(
          engineCondition: 82.0, // Needs engine repair
          transmissionCondition: 98.0,
          tramerAmount: 18000,
          mileage: 140000,
          isMileageTampered: false,
          bodyParts: {
            'Kaput': PartStatus.damaged,
            'Ön Tampon': PartStatus.changed,
            'Sol Ön Çamurluk': PartStatus.painted,
            'Tavan': PartStatus.original,
          },
          partConditions: {
            'Kaput': 20.0,
            'Ön Tampon': 50.0,
            'Sol Ön Çamurluk': 75.0,
            'Tavan': 100.0,
          },
        ),
      );

      container.read(gameProvider.notifier).state =
          container.read(gameProvider).copyWith(
                balance: 100000.0,
                ownedCars: [pristineCar, damagedCar],
                pendingOrders: [],
              );
    });

    tearDown(() {
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      container.dispose();
    });

    test('1. Pristine vehicle has zero needed parts and cannot order any parts', () {
      final needed = RepairEngine.getNeededPartsForCar(pristineCar);
      expect(needed, isEmpty);

      // Attempting to order a part for a flawless car must be rejected
      final orderResult = container.read(gameProvider.notifier).orderPart(
            carId: pristineCar.id,
            partName: 'Ön Kaput',
            orderType: OrderType.newOemPart,
            cost: 8000.0,
            deliveryDurationSeconds: 60,
          );

      expect(orderResult, isFalse);
      expect(container.read(gameProvider).pendingOrders, isEmpty);
      expect(container.read(gameProvider).balance, equals(100000.0));
    });

    test('2. Damaged vehicle accurately lists only defective parts and allows ordering them', () {
      final needed = RepairEngine.getNeededPartsForCar(damagedCar);
      expect(needed, contains('Kaput'));
      expect(needed, contains('Ön Tampon'));
      expect(needed, contains('Sol Ön Çamurluk'));
      expect(needed, contains('Motor Bloğu & Piston')); // Engine is 82% (< 95%)
      expect(needed, isNot(contains('Tavan'))); // Tavan is original
      expect(needed, isNot(contains('Şanzıman & Debriyaj'))); // Transmission is 98% (>= 95%)

      // Ordering an unneeded part (Tavan) fails
      final tavanResult = container.read(gameProvider.notifier).orderPart(
            carId: damagedCar.id,
            partName: 'Tavan',
            orderType: OrderType.newOemPart,
            cost: 5000.0,
            deliveryDurationSeconds: 60,
          );
      expect(tavanResult, isFalse);

      // Ordering a needed part (Kaput) succeeds
      final kaputResult = container.read(gameProvider.notifier).orderPart(
            carId: damagedCar.id,
            partName: 'Ön Kaput',
            orderType: OrderType.newOemPart,
            cost: 6000.0,
            deliveryDurationSeconds: 60,
          );
      expect(kaputResult, isTrue);
      expect(container.read(gameProvider).pendingOrders.length, equals(1));
      expect(container.read(gameProvider).balance, equals(94000.0));

      // Attempting to order the same part again while in transit is blocked
      final duplicateResult = container.read(gameProvider.notifier).orderPart(
            carId: damagedCar.id,
            partName: 'Kaput',
            orderType: OrderType.newOemPart,
            cost: 6000.0,
            deliveryDurationSeconds: 60,
          );
      expect(duplicateResult, isFalse);
      expect(container.read(gameProvider).pendingOrders.length, equals(1));
    });

    test('3. Part condition descriptions strictly contain zero parentheses and zero emojis', () {
      final descKaput = RepairEngine.getPartConditionDescription(damagedCar, 'Kaput');
      final descMotor = RepairEngine.getPartConditionDescription(damagedCar, 'Motor Bloğu & Piston');
      final descTampon = RepairEngine.getPartConditionDescription(damagedCar, 'Ön Tampon');

      expect(descKaput.contains('(') || descKaput.contains(')'), isFalse);
      expect(descMotor.contains('(') || descMotor.contains(')'), isFalse);
      expect(descTampon.contains('(') || descTampon.contains(')'), isFalse);

      final emojiRegex = RegExp(
          r'[\u{1F300}-\u{1F5FF}\u{1F600}-\u{1F64F}\u{1F680}-\u{1F6FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
          unicode: true);
      expect(emojiRegex.hasMatch(descKaput), isFalse);
      expect(emojiRegex.hasMatch(descMotor), isFalse);
      expect(emojiRegex.hasMatch(descTampon), isFalse);
    });
  });
}
