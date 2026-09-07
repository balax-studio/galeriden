import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/constants/first_time_action_keys.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/car_wash_job_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/staff_model.dart';
import 'package:galeriden/data/models/workshop_job_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Car Wash, Detailing Packages & Workshop Micro RPG Suite', () {
    late ProviderContainer container;
    late CarModel testCar;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();

      testCar = CarModel(
        id: 'car_wash_test_1',
        brand: 'Renault',
        modelName: 'Megane',
        modelYear: 2020,
        bodyType: 'Sedan',
        colorHex: '#FFFFFF',
        baseMarketValue: 400000.0,
        currentPurchasePrice: 350000.0,
        expertise: ExpertiseReport(
          mileage: 120000,
          isMileageTampered: false,
          engineCondition: 85.0,
          transmissionCondition: 85.0,
          tramerAmount: 0,
          bodyParts: {
            'Kaput': PartStatus.original,
            'Tavan': PartStatus.original,
          },
          partConditions: {
            'Kaput': 100.0,
            'Tavan': 100.0,
          },
        ),
        isWashed: false,
        isPolished: false,
        isDetailedCleaned: false,
        appliedDetailingOptionIds: [],
      );

      container.read(gameProvider.notifier).state = container.read(gameProvider).copyWith(
        balance: 100000,
        ownedCars: [testCar],
        hiredStaff: [
          StaffModel(
            id: 'staff_mechanic_1',
            name: 'Hasan Usta',
            role: StaffRole.masterMechanic,
            morale: 60,
            hiredAt: DateTime.now(),
          ),
        ],
      );
    });

    tearDown(() {
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      container.dispose();
    });

    test('1. Applying Package 1 (Köpüklü Yıkama) sets isWashed but does NOT mark Package 2 (Interior)', () {
      final notifier = container.read(gameProvider.notifier);

      final washSuccess = notifier.performWashService(
        testCar.id,
        cost: 350.0,
        valueBoostPercent: 0.01,
        setWashed: true,
        setInterior: false,
        setPolished: false,
        setDetailed: false,
      );

      expect(washSuccess, isTrue);
      final updatedCar = notifier.state.ownedCars.first;

      expect(updatedCar.isWashed, isTrue);
      expect(updatedCar.isInteriorCleaned, isFalse);
      expect(updatedCar.isPolished, isFalse);
      expect(updatedCar.isDetailedCleaned, isFalse);
    });

    test('2. Package 2 (Detaylı İç-Dış Temizlik) can be applied after Package 1 independently and rejects duplicates', () {
      final notifier = container.read(gameProvider.notifier);

      notifier.performWashService(
        testCar.id,
        cost: 350.0,
        valueBoostPercent: 0.01,
        setWashed: true,
      );

      expect(notifier.state.ownedCars.first.isWashed, isTrue);
      expect(notifier.state.ownedCars.first.isInteriorCleaned, isFalse);

      final interiorSuccess = notifier.performWashService(
        testCar.id,
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

      final duplicateInterior = notifier.performWashService(
        testCar.id,
        cost: 1200.0,
        valueBoostPercent: 0.03,
        setInterior: true,
      );
      expect(duplicateInterior, isFalse);
    });

    test('3. Customer wash jobs generate randomized requests with payouts and XP', () {
      final jobs = CustomerWashJob.generateRandomJobs(count: 4);

      expect(jobs.length, equals(4));
      for (final job in jobs) {
        expect(job.customerName, isNotEmpty);
        expect(job.vehicleName, isNotEmpty);
        expect(job.paymentReward, greaterThan(0));
        expect(job.masteryXp, greaterThan(0));
      }
    });

    test('4. Completing a customer wash job adds money to balance and awards XP', () {
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        completedFirstTimeActions: {FirstTimeActionKeys.firstCarWash},
        hiredStaff: [
          ...container.read(gameProvider).hiredStaff,
          StaffModel(
            id: 'staff_washer_4',
            name: 'Cemil Usta',
            role: StaffRole.washer,
            morale: 80,
            hiredAt: DateTime.now(),
          ),
        ],
      );
      final initialBalance = container.read(gameProvider).balance;
      final initialXp = container.read(gameProvider).skills.xp;

      final job = CustomerWashJob(
        id: 'wash_test_1',
        customerName: 'Taksici Salih',
        vehicleName: 'Fiat Egea',
        customerStory: 'Vardiya değişimi var yeğenim.',
        washType: WashJobType.foamWash,
        paymentReward: 750.0,
        masteryXp: 25,
      );

      final success = container.read(gameProvider.notifier).completeCustomerWashJob(job);

      expect(success, isTrue);
      expect(container.read(gameProvider).balance, equals(initialBalance + job.paymentReward));
      expect(container.read(gameProvider).skills.xp, equals(initialXp + job.masteryXp));
    });

    test('5. Applying a scented aroma tags the car and adds detailing option', () {
      final initialBalance = container.read(gameProvider).balance;
      final scent = CarScent.availableScents.first;

      final success = container.read(gameProvider.notifier).applyCarScent(testCar.id, scent);

      expect(success, isTrue);
      expect(container.read(gameProvider).balance, equals(initialBalance - scent.cost));
      final updatedCar = container.read(gameProvider).ownedCars.firstWhere((c) => c.id == testCar.id);
      expect(updatedCar.hasScent, isTrue);
      expect(updatedCar.appliedScentId, equals(scent.id));
    });

    test('6. Headlight restoration and wheel iron decon increase car value and tag detailing', () {
      final initialBalance = container.read(gameProvider).balance;

      final successHeadlight = container.read(gameProvider.notifier).restoreHeadlights(testCar.id);
      final successIron = container.read(gameProvider.notifier).cleanWheelIronDecon(testCar.id);

      expect(successHeadlight, isTrue);
      expect(successIron, isTrue);
      expect(container.read(gameProvider).balance, equals(initialBalance - 1300));

      final updatedCar = container.read(gameProvider).ownedCars.firstWhere((c) => c.id == testCar.id);
      expect(updatedCar.hasRestoredHeadlights, isTrue);
      expect(updatedCar.hasIronDecon, isTrue);
    });

    test('7. PDR dent repair and 2-Year TÜVTÜRK certification tag car correctly', () {
      final initialBalance = container.read(gameProvider).balance;

      final successPdr = container.read(gameProvider.notifier).performPdrDentRepair(testCar.id);
      final successTuvturk = container.read(gameProvider.notifier).certifyTuvturkInspection(testCar.id);

      expect(successPdr, isTrue);
      expect(successTuvturk, isTrue);
      expect(container.read(gameProvider).balance, equals(initialBalance - 4700));

      final updatedCar = container.read(gameProvider).ownedCars.firstWhere((c) => c.id == testCar.id);
      expect(updatedCar.hasPdrRepaired, isTrue);
      expect(updatedCar.hasTuvturkCertified, isTrue);
    });

    test('8. Treating workshop staff with sanayi tostu boosts morale', () {
      final initialBalance = container.read(gameProvider).balance;
      final initialMorale = container.read(gameProvider).hiredStaff.first.morale;

      final success = container.read(gameProvider.notifier).treatWorkshopStaffSnack();

      expect(success, isTrue);
      expect(container.read(gameProvider).balance, equals(initialBalance - 250));
      expect(container.read(gameProvider).hiredStaff.first.morale, equals(initialMorale + 20));
    });

    test('9. Workshop master repair consumes daily quota, blocks when exhausted, resets on day advance', () {
      final notifier = container.read(gameProvider.notifier);
      final initialQuota = container.read(gameProvider).remainingWorkshopRepairsToday;
      expect(initialQuota, greaterThan(0));

      final repairJob = CustomerRepairJob(
        id: 'repair_job_quota_1',
        customerName: 'Ahmet Bey',
        carModelName: 'Fiat Egea',
        customerStory: 'Debriyaj kaciriyor',
        jobType: RepairJobType.transmission,
        partsCost: 500.0,
        laborReward: 1500.0,
        masteryXpReward: 50,
        correctDiagnosisKey: 'clutch',
      );

      // Perform repairs until quota is exhausted
      notifier.state = notifier.state.copyWith(
        lastWorkshopRepairDay: notifier.state.currentDay,
        dailyWorkshopRepairsCount: container.read(gameProvider).maxDailyWorkshopRepairs - 1,
      );
      expect(container.read(gameProvider).remainingWorkshopRepairsToday, equals(1));

      // 1 repair remaining - should succeed
      final success1 = notifier.completeCustomerRepairJob(repairJob);
      expect(success1, isTrue);
      expect(container.read(gameProvider).remainingWorkshopRepairsToday, equals(0));

      // 0 repairs remaining - should fail
      final success2 = notifier.completeCustomerRepairJob(repairJob);
      expect(success2, isFalse);

      // Advance day resets daily quota
      notifier.advanceGameDay();
      expect(container.read(gameProvider).remainingWorkshopRepairsToday, equals(container.read(gameProvider).maxDailyWorkshopRepairs));
      expect(container.read(gameProvider).dailyWorkshopRepairsCount, equals(0));
    });

    test('10. Car wash specialist consumes daily quota, blocks when exhausted, resets on day advance', () {
      final notifier = container.read(gameProvider.notifier);
      
      // Add washer to staff
      notifier.state = notifier.state.copyWith(
        hiredStaff: [
          ...container.read(gameProvider).hiredStaff,
          StaffModel(
            id: 'staff_washer_1',
            name: 'Cemil Usta',
            role: StaffRole.washer,
            morale: 80,
            hiredAt: DateTime.now(),
          ),
        ],
      );

      expect(container.read(gameProvider).remainingCarWashesToday, greaterThan(0));

      final washJob = CustomerWashJob(
        id: 'wash_job_quota_1',
        customerName: 'Mehmet Bey',
        vehicleName: 'Toyota Corolla',
        customerStory: 'Toz toprak icinde kaldi',
        washType: WashJobType.foamWash,
        paymentReward: 500.0,
        masteryXp: 20,
      );

      // Exhaust all but 1
      notifier.state = notifier.state.copyWith(
        lastCarWashDay: notifier.state.currentDay,
        dailyCarWashCount: container.read(gameProvider).maxDailyCarWashes - 1,
      );
      expect(container.read(gameProvider).remainingCarWashesToday, equals(1));

      // 1 wash remaining - succeeds
      final success1 = notifier.completeCustomerWashJob(washJob);
      expect(success1, isTrue);
      expect(container.read(gameProvider).remainingCarWashesToday, equals(0));

      // 0 wash remaining - fails
      final success2 = notifier.completeCustomerWashJob(washJob);
      expect(success2, isFalse);

      // Advance day resets wash quota
      notifier.advanceGameDay();
      expect(container.read(gameProvider).remainingCarWashesToday, equals(container.read(gameProvider).maxDailyCarWashes));
      expect(container.read(gameProvider).dailyCarWashCount, equals(0));
    });

    test('11. Sponsor quota replenishment restores action quotas without waiting for day change', () {
      final notifier = container.read(gameProvider.notifier);

      // Add required staff
      notifier.state = notifier.state.copyWith(
        hiredStaff: [
          StaffModel(
            id: 'staff_master_1',
            name: 'Ali Usta',
            role: StaffRole.masterMechanic,
            morale: 90,
            hiredAt: DateTime.now(),
          ),
          StaffModel(
            id: 'staff_washer_1',
            name: 'Cemil Usta',
            role: StaffRole.washer,
            morale: 80,
            hiredAt: DateTime.now(),
          ),
        ],
        lastWorkshopRepairDay: notifier.state.currentDay,
        dailyWorkshopRepairsCount: 5,
        lastCarWashDay: notifier.state.currentDay,
        dailyCarWashCount: 5,
      );

      expect(container.read(gameProvider).remainingWorkshopRepairsToday, equals(0));
      expect(container.read(gameProvider).remainingCarWashesToday, equals(0));

      // Replenish workshop quota with sponsor support (+2)
      notifier.replenishWorkshopQuota(2);
      expect(container.read(gameProvider).remainingWorkshopRepairsToday, equals(2));

      // Replenish car wash quota with sponsor support (+3)
      notifier.replenishCarWashQuota(3);
      expect(container.read(gameProvider).remainingCarWashesToday, equals(3));
    });
  });
}
