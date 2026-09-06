import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/constants/first_time_action_keys.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/car_wash_job_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/staff_model.dart';
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
  });
}
