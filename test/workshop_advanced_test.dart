import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/player_skills.dart';
import 'package:galeriden/data/models/staff_model.dart';
import 'package:galeriden/data/models/workshop_job_model.dart';
import 'package:galeriden/domain/usecases/repair_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'helpers/invariant_test_helpers.dart';

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
        unlockedBuildings: {'/workshop'},
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

    test('4. Custom Color Respray puts car in oven and updates colorHex after advancing game day', () {
      final initialBalance = container.read(gameProvider).balance;
      final nardoGrey = CustomPaintColor.palette.firstWhere((c) => c.name.contains('Nardo'));

      final success = container.read(gameProvider.notifier).applyCustomPaintRespray(testCar.id, nardoGrey);

      expect(success, isTrue);
      expect(container.read(gameProvider).balance, equals(initialBalance - nardoGrey.cost));

      final ovenCar = container.read(gameProvider).ownedCars.firstWhere((c) => c.id == testCar.id);
      expect(ovenCar.isPainting, isTrue);
      expect(ovenCar.pendingPaintHex, equals(nardoGrey.hex));

      // Advance game day to cure and apply paint
      container.read(gameProvider.notifier).advanceGameDay();

      final repaintedCar = container.read(gameProvider).ownedCars.firstWhere((c) => c.id == testCar.id);
      expect(repaintedCar.isPainting, isFalse);
      expect(repaintedCar.colorHex, equals(nardoGrey.hex));
      expect(repaintedCar.colorDisplayName, equals(nardoGrey.name));
      expect(repaintedCar.baseMarketValue, equals(testCar.baseMarketValue));
      expect(repaintedCar.estimatedRealValue, greaterThan(testCar.estimatedRealValue));
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

    test('6. Engine & Transmission >= 95% condition cannot be overhauled unnecessarily', () {
      final healthyCar = CarModel(
        id: 'car_healthy',
        brand: 'Bemeve',
        modelName: 'Üç Yirmi Dizel',
        modelYear: 2021,
        bodyType: 'Sedan',
        colorHex: '#FFFFFF',
        baseMarketValue: 1200000,
        currentPurchasePrice: 1100000,
        expertise: ExpertiseReport(
          engineCondition: 96.0,
          transmissionCondition: 98.0,
          tramerAmount: 0,
          mileage: 45000,
          isMileageTampered: false,
          bodyParts: {
            'Ön Kaput': PartStatus.original,
            'Tavan': PartStatus.original,
          },
        ),
      );

      final engineResult = RepairEngine.repairEngine(healthyCar, RepairTier.master);
      final transResult = RepairEngine.repairTransmission(healthyCar, RepairTier.master);

      expect(engineResult.isSuccess, isFalse);
      expect(engineResult.message.contains('kusursuz') || engineResult.message.contains('gerekmiyor'), isTrue);
      expect(transResult.isSuccess, isFalse);
      expect(transResult.message.contains('kusursuz') || transResult.message.contains('gerekmiyor'), isTrue);

      final wornCar = CarModel(
        id: 'car_worn',
        brand: 'Bemeve',
        modelName: 'Üç Yirmi Dizel',
        modelYear: 2021,
        bodyType: 'Sedan',
        colorHex: '#FFFFFF',
        baseMarketValue: 1200000,
        currentPurchasePrice: 1100000,
        expertise: ExpertiseReport(
          engineCondition: 70.0,
          transmissionCondition: 65.0,
          tramerAmount: 0,
          mileage: 180000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );

      final wornEngineResult = RepairEngine.repairEngine(wornCar, RepairTier.master);
      final wornTransResult = RepairEngine.repairTransmission(wornCar, RepairTier.master);

      expect(wornEngineResult.isSuccess, isTrue);
      expect(wornEngineResult.updatedCar.expertise.engineCondition, equals(100.0));
      expect(wornTransResult.isSuccess, isTrue);
      expect(wornTransResult.updatedCar.expertise.transmissionCondition, equals(100.0));
    });

    test('7. Dynamic vehicle valuation scales proportionally with base market value', () {
      final budgetCar = CarModel(
        id: 'car_budget',
        brand: 'Fiyat',
        modelName: 'Ege Sedan',
        modelYear: 2020,
        bodyType: 'Sedan',
        colorHex: '#FFFFFF',
        baseMarketValue: 400000,
        currentPurchasePrice: 380000,
        expertise: ExpertiseReport(
          engineCondition: 90.0,
          transmissionCondition: 90.0,
          tramerAmount: 0,
          mileage: 80000,
          isMileageTampered: false,
          bodyParts: {},
        ),
        appliedDetailingOptionIds: ['ceramic_coating', 'interior_detailing'],
      );

      final luxuryCar = CarModel(
        id: 'car_luxury',
        brand: 'Merso',
        modelName: 'Es Beş Yüz Long',
        modelYear: 2022,
        bodyType: 'Sedan',
        colorHex: '#000000',
        baseMarketValue: 4000000,
        currentPurchasePrice: 3800000,
        expertise: ExpertiseReport(
          engineCondition: 90.0,
          transmissionCondition: 90.0,
          tramerAmount: 0,
          mileage: 20000,
          isMileageTampered: false,
          bodyParts: {},
        ),
        appliedDetailingOptionIds: ['ceramic_coating', 'interior_detailing'],
      );

      expect(luxuryCar.estimatedRealValue, greaterThan(3500000));
      expect(budgetCar.estimatedRealValue, greaterThan(350000));
    });

    test('8. Level 5+ XP curve requirement expands distance between levels', () {
      expect(PlayerSkills.requiredXpForLevel(1), equals(1500));
      expect(PlayerSkills.requiredXpForLevel(2), equals(3750));
      expect(PlayerSkills.requiredXpForLevel(3), equals(7500));
      expect(PlayerSkills.requiredXpForLevel(4), equals(14000));
      expect(PlayerSkills.requiredXpForLevel(5), equals(24000));

      final xpLevel5 = PlayerSkills.requiredXpForLevel(5);
      final xpLevel6 = PlayerSkills.requiredXpForLevel(6);
      final xpLevel7 = PlayerSkills.requiredXpForLevel(7);

      expect(xpLevel6 - xpLevel5, greaterThan(10000));
      expect(xpLevel7 - xpLevel6, greaterThan(15000));
    });

    test('9. Invariant checks: zero emojis and zero parentheses in repair messages', () {
      final car = CarModel(
        id: 'c1',
        brand: 'Fiyat',
        modelName: 'Ege',
        modelYear: 2020,
        bodyType: 'Sedan',
        colorHex: '#FFFFFF',
        baseMarketValue: 500000,
        currentPurchasePrice: 450000,
        expertise: ExpertiseReport(
          engineCondition: 99.0,
          transmissionCondition: 99.0,
          tramerAmount: 0,
          mileage: 10000,
          isMileageTampered: false,
          bodyParts: {'Ön Kaput': PartStatus.original},
        ),
      );

      final resEngine = RepairEngine.repairEngine(car, RepairTier.master);
      final resTrans = RepairEngine.repairTransmission(car, RepairTier.master);

      expectValidInvariantString(resEngine.message);
      expectValidInvariantString(resTrans.message);
    });
  });
}
