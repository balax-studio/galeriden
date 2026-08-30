import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/active_service_job_model.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:galeriden/data/models/expertise_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ActiveServiceJobModel and Daily Progression Engine Tests', () {
    test('1. Model serialization and deserialization retains all fields', () {
      final job = ActiveServiceJobModel(
        id: 'job_overhaul_1',
        type: ServiceJobType.workshopEngineOverhaul,
        targetEntityId: 'car_passat_1',
        targetTitle: 'VW Passat 2.0 TDI • Motor Revizyonu',
        startDay: 5,
        totalDurationDays: 3,
        remainingDays: 3,
        rushCashCost: 5000.0,
        rushReputationCost: 5,
        rushLoreTitleKey: 'rush_lore_night_shift_title',
        rushLoreDescKey: 'rush_lore_night_shift_desc',
        rushButtonActionKey: 'rush_lore_night_shift_btn',
        metadata: {'cylinders': 4},
      );

      final jsonMap = job.toJson();
      final decodedJob = ActiveServiceJobModel.fromJson(jsonMap);

      expect(decodedJob.id, equals('job_overhaul_1'));
      expect(decodedJob.type, equals(ServiceJobType.workshopEngineOverhaul));
      expect(decodedJob.targetTitle, equals('VW Passat 2.0 TDI • Motor Revizyonu'));
      expect(decodedJob.totalDurationDays, equals(3));
      expect(decodedJob.remainingDays, equals(3));
      expect(decodedJob.rushCashCost, equals(5000.0));
      expect(decodedJob.progressPercentage, equals(0.0));
      expect(decodedJob.isCompleted, isFalse);
    });

    test('2. DealershipModel serialization includes activeServiceJobs', () {
      final job = ActiveServiceJobModel(
        id: 'job_ceramic_1',
        type: ServiceJobType.carWashCeramicCure,
        targetEntityId: 'car_bmw_1',
        targetTitle: 'BMW M4 • Seramik Nano Kaplama',
        startDay: 10,
        totalDurationDays: 2,
        remainingDays: 2,
        rushLoreTitleKey: 'rush_lore_ceramic_cure_title',
        rushLoreDescKey: 'rush_lore_ceramic_cure_desc',
        rushButtonActionKey: 'rush_lore_ceramic_cure_btn',
      );

      final dealership = DealershipModel.initial().copyWith(
        activeServiceJobs: [job],
      );

      final jsonStr = jsonEncode(dealership.toJson());
      final decodedMap = jsonDecode(jsonStr) as Map<String, dynamic>;
      final restored = DealershipModel.fromJson(decodedMap);

      expect(restored.activeServiceJobs.length, equals(1));
      expect(restored.activeServiceJobs.first.id, equals('job_ceramic_1'));
      expect(restored.activeServiceJobs.first.type, equals(ServiceJobType.carWashCeramicCure));
    });

    test('3. advanceGameDay decrements remaining days and delivers completed job to car', () {
      final car = CarModel(
        id: 'car_test_1',
        brand: 'Volkswagen',
        modelName: 'Passat 2.0 TDI',
        modelYear: 2018,
        bodyType: 'Sedan',
        colorHex: '#111827',
        baseMarketValue: 950000.0,
        currentPurchasePrice: 900000.0,
        expertise: ExpertiseReport(
          engineCondition: 45.0, // Damaged engine
          transmissionCondition: 80.0,
          tramerAmount: 5000,
          mileage: 85000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );

      final job = ActiveServiceJobModel(
        id: 'job_overhaul_1',
        type: ServiceJobType.workshopEngineOverhaul,
        targetEntityId: 'car_test_1',
        targetTitle: 'Passat Motor Revizyonu',
        startDay: 1,
        totalDurationDays: 2,
        remainingDays: 1, // 1 day remaining, will finish on next day!
        rushLoreTitleKey: 'rush_lore_night_shift_title',
        rushLoreDescKey: 'rush_lore_night_shift_desc',
        rushButtonActionKey: 'rush_lore_night_shift_btn',
      );

      final initialDealership = DealershipModel.initial().copyWith(
        ownedCars: [car],
        activeServiceJobs: [job],
        currentDay: 1,
      );

      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();
      notifier.state = initialDealership;

      // Advance 1 day
      notifier.advanceGameDay();

      final updatedState = notifier.state;
      expect(updatedState.currentDay, equals(2));
      // Job should be completed and removed from active jobs list
      expect(updatedState.activeServiceJobs.isEmpty, isTrue);
      // Car engine condition should be restored to 100
      final updatedCar = updatedState.ownedCars.firstWhere((c) => c.id == 'car_test_1');
      expect(updatedCar.expertise.engineCondition, equals(100.0));
      // Event should be generated
      expect(updatedState.recentEvents.any((e) => e.title.contains('Tamamlandı')), isTrue);
    });
  });
}

