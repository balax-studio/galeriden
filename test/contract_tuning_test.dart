import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/outsourced_tuning_model.dart';
import 'package:galeriden/domain/usecases/outsourced_tuning_engine.dart';

void main() {
  group('OutsourcedTuningEngine Studio Registry', () {
    test('all 5 parody studios are correctly configured', () {
      final studios = OutsourcedTuningEngine.allStudios;
      expect(studios.length, 5);

      final yasar = studios.firstWhere((s) => s.id == 'sanayi_yasar');
      expect(yasar.minLevel, 2);
      expect(yasar.durationMinutes, 15);
      expect(yasar.durationSeconds, 900);

      final jdm = studios.firstWhere((s) => s.id == 'tokyo_jdm');
      expect(jdm.minLevel, 4);
      expect(jdm.durationMinutes, 30);
      expect(jdm.acceptedBrands.contains('Tota'), true);

      final klaus = studios.firstWhere((s) => s.id == 'bavaria_klaus');
      expect(klaus.minLevel, 6);
      expect(klaus.durationMinutes, 60);
      expect(klaus.acceptedBrands.contains('Bavyera'), true);

      final hilmi = studios.firstWhere((s) => s.id == 'nostalji_hilmi');
      expect(hilmi.minLevel, 7);
      expect(hilmi.durationMinutes, 90);
      expect(hilmi.isClassicOnly, true);

      final monaco = studios.firstWhere((s) => s.id == 'monaco_hypercraft');
      expect(monaco.minLevel, 9);
      expect(monaco.durationMinutes, 120);
      expect(monaco.isExoticHyperOnly, true);
    });
  });

  group('OutsourcedTuningEngine Car Eligibility Rules', () {
    final baseCar = CarModel(
      id: 'car_1',
      brand: 'Bavyera',
      modelName: 'M3 Competition',
      modelYear: 2022,
      bodyType: 'Sedan',
      colorHex: '#000000',
      baseMarketValue: 1500000,
      currentPurchasePrice: 1400000,
      expertise: ExpertiseReport(
        mileage: 20000,
        isMileageTampered: false,
        engineCondition: 95.0,
        transmissionCondition: 90.0,
        tramerAmount: 0,
        bodyParts: const {},
      ),
    );

    test('Herr Klaus accepts German brands, rejects Japanese brands', () {
      final klaus = OutsourcedTuningEngine.getStudioById('bavaria_klaus')!;
      expect(OutsourcedTuningEngine.isCarAccepted(klaus, baseCar, 6), true);

      final hondaCar = baseCar.copyWith(brand: 'Hondi', modelName: 'Civic');
      expect(OutsourcedTuningEngine.isCarAccepted(klaus, hondaCar, 6), false);
    });

    test('Tokyo JDM accepts Japanese brands, rejects German brands', () {
      final jdm = OutsourcedTuningEngine.getStudioById('tokyo_jdm')!;
      final jdmCar = baseCar.copyWith(brand: 'Nisso', modelName: 'Skyline');
      expect(OutsourcedTuningEngine.isCarAccepted(jdm, jdmCar, 4), true);
      expect(OutsourcedTuningEngine.isCarAccepted(jdm, baseCar, 4), false);
    });

    test('Usta Hilmi accepts cars older than 2003 or classic segment', () {
      final hilmi = OutsourcedTuningEngine.getStudioById('nostalji_hilmi')!;
      final classicCar = baseCar.copyWith(modelYear: 1988);
      expect(OutsourcedTuningEngine.isCarAccepted(hilmi, classicCar, 7), true);

      final modernCar = baseCar.copyWith(modelYear: 2020);
      expect(OutsourcedTuningEngine.isCarAccepted(hilmi, modernCar, 7), false);
    });

    test('Monaco Hypercraft accepts only exotic/hyper cars', () {
      final monaco = OutsourcedTuningEngine.getStudioById('monaco_hypercraft')!;
      final hyperCar = baseCar.copyWith(
        brand: 'Bugac',
        modelName: 'Chiro Hyper Sport',
        baseMarketValue: 15000000,
      );
      expect(OutsourcedTuningEngine.isCarAccepted(monaco, hyperCar, 9), true);
      expect(OutsourcedTuningEngine.isCarAccepted(monaco, baseCar, 9), false);
    });

    test('Rejects cars that are listed, rented, or already in tuning studio', () {
      final yasar = OutsourcedTuningEngine.getStudioById('sanayi_yasar')!;
      
      final listedCar = baseCar.copyWith(customListingPrice: 1550000);
      expect(OutsourcedTuningEngine.isCarAccepted(yasar, listedCar, 2), false);

      final rentedCar = baseCar.copyWith(isRented: true);
      expect(OutsourcedTuningEngine.isCarAccepted(yasar, rentedCar, 2), false);

      final inStudioCar = baseCar.copyWith(isOutsourcedTuning: true);
      expect(OutsourcedTuningEngine.isCarAccepted(yasar, inStudioCar, 2), false);
    });
  });

  group('Economic Formulas & Order Lifecycle', () {
    final testCar = CarModel(
      id: 'car_eco_1',
      brand: 'Bavyera',
      modelName: '320i',
      modelYear: 2021,
      bodyType: 'Sedan',
      colorHex: '#0000FF',
      baseMarketValue: 800000,
      currentPurchasePrice: 750000,
      expertise: ExpertiseReport(
        mileage: 40000,
        isMileageTampered: false,
        engineCondition: 90.0,
        transmissionCondition: 90.0,
        tramerAmount: 0,
        bodyParts: const {},
      ),
    );

    test('calculateCost adheres to studio base cost scaling', () {
      final yasar = OutsourcedTuningEngine.getStudioById('sanayi_yasar')!;
      final cost = OutsourcedTuningEngine.calculateCost(yasar, testCar);
      expect(cost >= 25000.0, true);
    });

    test('createOrder locks car and establishes expected value gain', () {
      final klaus = OutsourcedTuningEngine.getStudioById('bavaria_klaus')!;
      final order = OutsourcedTuningEngine.createOrder(
        studio: klaus,
        car: testCar,
        currentDay: 10,
      );

      expect(order.carId, testCar.id);
      expect(order.studioId, klaus.id);
      expect(order.status, TuningOrderStatus.inProgress);
      expect(order.durationSeconds, klaus.durationSeconds);
      expect(order.remainingSeconds, klaus.durationSeconds);
      expect(order.expectedValueGain > 0, true);
      expect(order.speedupCount, 0);
    });

    test('speedup cuts remaining time in half and increments speedupCount', () {
      final klaus = OutsourcedTuningEngine.getStudioById('bavaria_klaus')!;
      final order = OutsourcedTuningEngine.createOrder(
        studio: klaus,
        car: testCar,
        currentDay: 10,
      );
      expect(order.remainingSeconds, 3600);

      final speedup1 = OutsourcedTuningEngine.applySpeedup(order);
      expect(speedup1.speedupCount, 1);
      expect(speedup1.remainingSeconds < order.remainingSeconds, true);
    });

    test('applyCompletedTuning boosts stats, adds badge and unlocks car', () {
      final klaus = OutsourcedTuningEngine.getStudioById('bavaria_klaus')!;
      final order = OutsourcedTuningEngine.createOrder(
        studio: klaus,
        car: testCar,
        currentDay: 10,
      );
      final lockedCar = testCar.copyWith(
        isOutsourcedTuning: true,
        activeTuningOrderId: order.orderId,
      );

      final upgradedCar = OutsourcedTuningEngine.applyCompletedTuning(
        car: lockedCar,
        studio: klaus,
        order: order,
      );

      expect(upgradedCar.isOutsourcedTuning, false);
      expect(upgradedCar.activeTuningOrderId, isNull);
      expect(upgradedCar.baseMarketValue > testCar.baseMarketValue, true);
      expect(upgradedCar.appliedDetailingOptionIds.contains(klaus.badgeKey), true);
    });
  });
}
