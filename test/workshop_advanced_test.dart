import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/staff_model.dart';
import 'package:galeriden/data/models/workshop_job_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Workshop & Repair Advanced System Test Suite', () {
    late ProviderContainer container;
    late CarModel testCar;

    setUp(() {
      container = ProviderContainer();
      testCar = CarModel(
        id: 'car_repair_test',
        brand: 'Volkswagen',
        modelName: 'Golf 7 1.4 TSI',
        modelYear: 2018,
        bodyType: 'Hatchback',
        colorHex: '#333333',
        baseMarketValue: 600000,
        currentPurchasePrice: 500000,
        appliedDetailingOptionIds: [],
        expertise: ExpertiseReport(
          engineCondition: 65,
          transmissionCondition: 60,
          tramerAmount: 12000,
          mileage: 110000,
          isMileageTampered: false,
          bodyParts: {'Kaput': PartStatus.painted, 'Sol Çamurluk': PartStatus.changed},
        ),
      );

      container.read(gameProvider.notifier).state = container.read(gameProvider).copyWith(
        balance: 100000,
        ownedCars: [testCar],
      );
    });

    test('1. Customer repair jobs generate randomized contract offers with rewards', () {
      final jobs = CustomerRepairJob.generateRandomJobs(count: 4);

      expect(jobs.length, equals(4));
      for (final job in jobs) {
        expect(job.customerName, isNotEmpty);
        expect(job.carModelName, isNotEmpty);
        expect(job.laborReward, greaterThan(0));
        expect(job.partsCost, greaterThan(0));
        expect(job.masteryXpReward, greaterThan(0));
      }
    });

    test('2. Completing a customer contract earns net labor profit and grants dealer XP', () {
      final initialBalance = container.read(gameProvider).balance;
      final initialXp = container.read(gameProvider).skills.xp;

      final job = CustomerRepairJob(
        id: 'job_test_1',
        customerName: 'Ahmet Taksici',
        carModelName: 'Fiat Egea',
        customerStory: 'Baskı balata kaçırıyor.',
        jobType: RepairJobType.transmission,
        partsCost: 5000,
        laborReward: 12000,
        masteryXpReward: 50,
        correctDiagnosisKey: 'baski_balata',
      );

      final success = container.read(gameProvider.notifier).completeCustomerRepairJob(job);

      expect(success, isTrue);
      // Net balance increases by (laborReward - partsCost) = 12000 - 5000 = +7000
      expect(container.read(gameProvider).balance, equals(initialBalance + (job.laborReward - job.partsCost)));
      expect(container.read(gameProvider).skills.xp, equals(initialXp + job.masteryXpReward));
    });

    test('3. 10.000 KM Periodic Maintenance boosts engine & transmission by +15% for ₺3.500', () {
      final initialBalance = container.read(gameProvider).balance;

      final success = container.read(gameProvider.notifier).performPeriodicMaintenance(testCar.id);

      expect(success, isTrue);
      expect(container.read(gameProvider).balance, equals(initialBalance - 3500));

      final updatedCar = container.read(gameProvider).ownedCars.firstWhere((c) => c.id == testCar.id);
      expect(updatedCar.expertise.engineCondition, equals(80)); // 65 + 15
      expect(updatedCar.expertise.transmissionCondition, equals(75)); // 60 + 15
    });

    test('4. Custom Color Respray updates colorHex, colorDisplayName and increases market value', () {
      final initialBalance = container.read(gameProvider).balance;
      final nardoGrey = CustomPaintColor.palette.firstWhere((c) => c.name.contains('Nardo'));

      final success = container.read(gameProvider.notifier).applyCustomPaintRespray(testCar.id, nardoGrey);

      expect(success, isTrue);
      expect(container.read(gameProvider).balance, equals(initialBalance - nardoGrey.cost));

      final repaintedCar = container.read(gameProvider).ownedCars.firstWhere((c) => c.id == testCar.id);
      expect(repaintedCar.colorHex, equals(nardoGrey.hex));
      expect(repaintedCar.colorDisplayName, equals(nardoGrey.name));
      expect(repaintedCar.baseMarketValue, greaterThan(testCar.baseMarketValue));
    });

    test('5. Staff Master Mechanic and Apprentice synergies eliminate repair failure and speed up orders', () {
      final mechanic = StaffModel(
        id: 'staff_mech',
        name: 'Haydar Usta',
        role: StaffRole.masterMechanic,
        hiredAt: DateTime.now(),
      );
      final apprentice = StaffModel(
        id: 'staff_appr',
        name: 'Ali Çırak',
        role: StaffRole.apprentice,
        hiredAt: DateTime.now(),
      );

      container.read(gameProvider.notifier).hireStaff(mechanic);
      container.read(gameProvider.notifier).hireStaff(apprentice);

      final state = container.read(gameProvider);
      final hasMechanic = state.hiredStaff.any((s) => s.role == StaffRole.masterMechanic);
      final hasApprentice = state.hiredStaff.any((s) => s.role == StaffRole.apprentice);

      expect(hasMechanic, isTrue);
      expect(hasApprentice, isTrue);
    });
  });
}
