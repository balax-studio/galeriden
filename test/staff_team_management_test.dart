import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/staff_model.dart';
import 'package:galeriden/core/services/game_sound_haptic_service.dart';
import 'package:galeriden/domain/usecases/loan_settlement_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Staff & Team Management System Test Suite', () {
    test('1. StaffRole enum contains all 7 specialized roles with metadata', () {
      expect(StaffRole.values.length, equals(7));
      expect(StaffRole.values.contains(StaffRole.appraiser), isTrue);
      expect(StaffRole.values.contains(StaffRole.marketer), isTrue);
      expect(StaffRole.values.contains(StaffRole.legalAdvisor), isTrue);

      expect(StaffRole.appraiser.title, contains('Ekspertiz'));
      expect(StaffRole.marketer.title, contains('Pazarlamacı'));
      expect(StaffRole.legalAdvisor.title, contains('Hukuk'));
    });

    test('2. Staff perks and career stats initialize and compute properly', () {
      final staff = StaffModel(
        id: 'st_1',
        name: 'Usta Vedat',
        role: StaffRole.masterMechanic,
        hiredAt: DateTime.now(),
        morale: 80,
        perk: StaffPerk.hardWorker,
        tasksCompleted: 15,
        profitContributed: 85000.0,
      );

      expect(staff.morale, equals(80));
      expect(staff.perk, equals(StaffPerk.hardWorker));
      expect(staff.perk!.title, contains('Çalışkan'));
      expect(staff.profitContributed, equals(85000.0));
      expect(staff.tasksCompleted, equals(15));
    });

    test('3. Treating staff with tea/meal boosts morale and deducts money', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      final staff = StaffModel(
        id: 'st_sales',
        name: 'Kemal Bey',
        role: StaffRole.salesman,
        hiredAt: DateTime.now(),
        morale: 50,
      );

      notifier.state = notifier.state.copyWith(
        balance: 10000.0,
        hiredStaff: [staff],
      );

      // Treat tea (₺500, +15 Morale)
      final teaSuccess = notifier.treatStaffTea('st_sales');
      expect(teaSuccess, isTrue);
      expect(notifier.state.balance, equals(9500.0));
      expect(notifier.state.hiredStaff.first.morale, equals(65));

      // Treat meal (₺1500, +35 Morale)
      final mealSuccess = notifier.treatStaffMeal('st_sales');
      expect(mealSuccess, isTrue);
      expect(notifier.state.balance, equals(8000.0));
      expect(notifier.state.hiredStaff.first.morale, equals(100)); // Capped at 100

      // When morale is 100%, subsequent treat and bonus actions are rejected and balance is preserved
      final fullTeaSuccess = notifier.treatStaffTea('st_sales');
      expect(fullTeaSuccess, isFalse);
      final fullMealSuccess = notifier.treatStaffMeal('st_sales');
      expect(fullMealSuccess, isFalse);
      final fullBonusSuccess = notifier.giveStaffBonus('st_sales', 2000.0);
      expect(fullBonusSuccess, isFalse);
      expect(notifier.state.balance, equals(8000.0));
      expect(notifier.state.hiredStaff.first.morale, equals(100));
    });

    test('4. Team synergies calculate accurately when required roles are present', () {
      final staffList = [
        StaffModel(
          id: 'st_1',
          name: 'Ahmet',
          role: StaffRole.salesman,
          hiredAt: DateTime.now(),
        ),
        StaffModel(
          id: 'st_2',
          name: 'Zeynep',
          role: StaffRole.marketer,
          hiredAt: DateTime.now(),
        ),
        StaffModel(
          id: 'st_3',
          name: 'Hasan Usta',
          role: StaffRole.masterMechanic,
          hiredAt: DateTime.now(),
        ),
        StaffModel(
          id: 'st_4',
          name: 'Ali Çırak',
          role: StaffRole.apprentice,
          hiredAt: DateTime.now(),
        ),
      ];

      final synergies = TeamSynergyEngine.calculateSynergies(staffList);
      expect(synergies.length, greaterThanOrEqualTo(3));

      expect(synergies.any((s) => s.id == 'synergy_sales_force'), isTrue); // Salesman + Marketer
      expect(synergies.any((s) => s.id == 'synergy_full_workshop'), isTrue); // Mechanic + Apprentice
      expect(synergies.any((s) => s.id == 'synergy_corporate_culture'), isTrue); // 4+ staff
    });

    test('5. Giving bonus increases loyalty, morale and grants dealer XP', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      final staff = StaffModel(
        id: 'st_exp',
        name: 'Murat Eksper',
        role: StaffRole.appraiser,
        hiredAt: DateTime.now(),
        morale: 40,
      );

      notifier.state = notifier.state.copyWith(
        balance: 20000.0,
        hiredStaff: [staff],
      );

      final bonusSuccess = notifier.giveStaffBonus('st_exp', 3000.0);
      expect(bonusSuccess, isTrue);
      expect(notifier.state.balance, equals(17000.0));
      expect(notifier.state.hiredStaff.first.morale, equals(90));
      expect(notifier.state.skills.xp, greaterThan(0));
    });
  });

  group('Staff Automation & Daily Simulation Tests', () {
    late GameNotifier gameNotifier;
    late CarModel dirtyCar;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      gameNotifier = GameNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      dirtyCar = CarModel(
        id: 'test_dirty_car_1',
        brand: 'Merso',
        modelName: 'C200',
        modelYear: 2020,
        bodyType: 'Sedan',
        colorHex: '000000',
        baseMarketValue: 1200000,
        currentPurchasePrice: 1000000,
        customListingPrice: 1250000,
        isWashed: false,
        isPolished: false,
        isDetailedCleaned: false,
        expertise: ExpertiseReport(
          engineCondition: 60.0,
          transmissionCondition: 55.0,
          tramerAmount: 0,
          mileage: 50000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );

      final washer = StaffModel(
        id: 'staff_washer_1',
        name: 'Ali Usta',
        role: StaffRole.washer,
        hiredAt: DateTime(2026, 1, 1),
      );

      final mechanic = StaffModel(
        id: 'staff_mechanic_1',
        name: 'Hasan Usta',
        role: StaffRole.masterMechanic,
        hiredAt: DateTime(2026, 1, 1),
      );

      final salesman = StaffModel(
        id: 'staff_sales_1',
        name: 'Kemal Danışman',
        role: StaffRole.salesman,
        hiredAt: DateTime(2026, 1, 1),
      );

      gameNotifier.completeTutorial();
      gameNotifier.state = gameNotifier.state.copyWith(
        balance: 500000.0,
        ownedCars: [dirtyCar],
        hiredStaff: [washer, mechanic, salesman],
      );
    });

    tearDown(() {
      gameNotifier.dispose();
    });

    test('advanceGameDay automatically washes dirty cars if Washer staff is present', () {
      expect(gameNotifier.state.ownedCars.first.isWashed, isFalse);
      expect(gameNotifier.state.ownedCars.first.isPolished, isFalse);

      gameNotifier.advanceGameDay();

      final updatedCar = gameNotifier.state.ownedCars.first;
      expect(updatedCar.isWashed, isTrue);
      expect(updatedCar.isPolished, isTrue);
      expect(updatedCar.isDetailedCleaned, isTrue);
    });

    test('advanceGameDay automatically repairs low engine/transmission condition if Mechanic is present', () {
      expect(gameNotifier.state.ownedCars.first.expertise.engineCondition, equals(60.0));
      expect(gameNotifier.state.ownedCars.first.expertise.transmissionCondition, equals(55.0));

      gameNotifier.advanceGameDay();

      final updatedCar = gameNotifier.state.ownedCars.first;
      expect(updatedCar.expertise.engineCondition, equals(80.0));
      expect(updatedCar.expertise.transmissionCondition, equals(75.0));
    });

    test('advanceGameDay deducts daily staff salaries and property overhead accurately', () {
      final startingBalance = gameNotifier.state.balance;
      final totalDailySalary = gameNotifier.state.hiredStaff.fold(0.0, (sum, s) => sum + s.role.dailySalary);
      final dailyTax = LoanSettlementEngine.calculateDailyTax(
        gameNotifier.state.level,
        totalLiquidWealth: gameNotifier.state.balance + gameNotifier.state.bankDepositBalance,
      );

      gameNotifier.advanceGameDay();

      expect(gameNotifier.state.balance, equals(startingBalance - 300.0 - totalDailySalary - dailyTax));
      expect(gameNotifier.state.currentDay, equals(2));
    });
  });

  group('Staff Energy, Stamina & Leave Mechanism Suite', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      container.read(gameProvider.notifier).state = container.read(gameProvider).copyWith(
        unlockedBuildings: {
          '/car-wash',
          '/workshop',
          '/expertise',
          '/showroom',
          '/photography-studio',
          '/bank',
        },
        balance: 100000.0,
      );
    });

    tearDown(() {
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      container.dispose();
    });

    test('StaffModel initializes with 100 energy, not on leave, and JSON roundtrip preserves energy state', () {
      final staff = StaffModel(
        id: 'staff_1',
        name: 'Ahmet Usta',
        role: StaffRole.masterMechanic,
        hiredAt: DateTime(2026, 1, 1),
      );

      expect(staff.energy, equals(100));
      expect(staff.isOnLeave, isFalse);
      expect(staff.leaveDaysRemaining, equals(0));
      expect(staff.isExhausted, isFalse);
      expect(staff.isAvailableForWork, isTrue);

      final json = staff.toJson();
      expect(json['energy'], equals(100));
      expect(json['isOnLeave'], isFalse);
      expect(json['leaveDaysRemaining'], equals(0));

      final restored = StaffModel.fromJson(json);
      expect(restored.energy, equals(100));
      expect(restored.isOnLeave, isFalse);
      expect(restored.leaveDaysRemaining, equals(0));
    });

    test('Working staff loses energy on daily turnover, while resting staff on leave recovers +50 energy and returns after leave', () {
      final mechanic = StaffModel(
        id: 'staff_mech',
        name: 'Haydar Usta',
        role: StaffRole.masterMechanic,
        hiredAt: DateTime(2026, 1, 1),
        energy: 40,
      );

      final washer = StaffModel(
        id: 'staff_wash',
        name: 'Kemal Yıkamacı',
        role: StaffRole.washer,
        hiredAt: DateTime(2026, 1, 1),
        energy: 40,
      );

      container.read(gameProvider.notifier).hireStaff(mechanic);
      container.read(gameProvider.notifier).hireStaff(washer);

      final leaveSuccess = container.read(gameProvider.notifier).sendStaffOnLeave(mechanic.id, 1);
      expect(leaveSuccess, isTrue);

      final onLeaveStaff = container.read(gameProvider).hiredStaff.firstWhere((s) => s.id == mechanic.id);
      expect(onLeaveStaff.isOnLeave, isTrue);
      expect(onLeaveStaff.leaveDaysRemaining, equals(1));
      expect(onLeaveStaff.isAvailableForWork, isFalse);

      container.read(gameProvider.notifier).advanceGameDay();

      final staffAfterDay = container.read(gameProvider).hiredStaff;
      final updatedMechanic = staffAfterDay.firstWhere((s) => s.id == mechanic.id);
      final updatedWasher = staffAfterDay.firstWhere((s) => s.id == washer.id);

      expect(updatedMechanic.energy, equals(90));
      expect(updatedMechanic.isOnLeave, isFalse);
      expect(updatedMechanic.leaveDaysRemaining, equals(0));
      expect(updatedMechanic.isAvailableForWork, isTrue);

      expect(updatedWasher.energy, equals(28));
      expect(updatedWasher.isAvailableForWork, isTrue);
    });

    test('Treats (Tea, Meal, Bonus) restore both morale and energy', () {
      final salesman = StaffModel(
        id: 'staff_sale',
        name: 'Selin Satış',
        role: StaffRole.salesman,
        hiredAt: DateTime(2026, 1, 1),
        morale: 50,
        energy: 50,
      );

      container.read(gameProvider.notifier).hireStaff(salesman);

      final teaOk = container.read(gameProvider.notifier).treatStaffTea(salesman.id);
      expect(teaOk, isTrue);

      var staff = container.read(gameProvider).hiredStaff.firstWhere((s) => s.id == salesman.id);
      expect(staff.morale, equals(65));
      expect(staff.energy, equals(65));

      final mealOk = container.read(gameProvider.notifier).treatStaffMeal(salesman.id);
      expect(mealOk, isTrue);

      staff = container.read(gameProvider).hiredStaff.firstWhere((s) => s.id == salesman.id);
      expect(staff.morale, equals(100));
      expect(staff.energy, equals(95));
    });

    test('Exhausted staff with energy <= 10 is marked unavailable for work and has lower speed multiplier', () {
      final tiredStaff = StaffModel(
        id: 'staff_tired',
        name: 'Yorgun Çırak',
        role: StaffRole.apprentice,
        hiredAt: DateTime(2026, 1, 1),
        energy: 10,
      );

      expect(tiredStaff.isExhausted, isTrue);
      expect(tiredStaff.isAvailableForWork, isFalse);
      expect(tiredStaff.speedMultiplier, lessThan(1.0));
    });

    test('Recalling staff early from leave brings them back to work immediately', () {
      final staff = StaffModel(
        id: 'staff_rec',
        name: 'Eksper Faruk',
        role: StaffRole.appraiser,
        hiredAt: DateTime(2026, 1, 1),
        energy: 50,
      );

      container.read(gameProvider.notifier).hireStaff(staff);
      container.read(gameProvider.notifier).sendStaffOnLeave(staff.id, 2);

      var current = container.read(gameProvider).hiredStaff.firstWhere((s) => s.id == staff.id);
      expect(current.isOnLeave, isTrue);

      final recallOk = container.read(gameProvider.notifier).recallStaffFromLeave(staff.id);
      expect(recallOk, isTrue);

      current = container.read(gameProvider).hiredStaff.firstWhere((s) => s.id == staff.id);
      expect(current.isOnLeave, isFalse);
      expect(current.leaveDaysRemaining, equals(0));
      expect(current.isAvailableForWork, isTrue);
    });
  });

  group('Staff Academy & Multi-Day Apprenticeship Tests', () {
    test('Courses have valid durations between 1 and 3 game days', () {
      for (final role in StaffRole.values) {
        final courses = StaffRoleSpecializations.coursesForRole(role);
        expect(courses.isNotEmpty, true);
        for (final course in courses) {
          expect(course.durationDays >= 1 && course.durationDays <= 3, true);
        }
      }
    });

    test('Enrolling staff starts multi-day training timer and gates availability', () {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final notifier = container.read(gameProvider.notifier);

      final apprenticeStaff = StaffModel(
        id: 'staff_appr_1',
        name: 'Mustafa Çırak',
        role: StaffRole.apprentice,
        hiredAt: DateTime.now(),
      );

      notifier.state = notifier.state.copyWith(
        balance: 500000.0,
        unlockedBuildings: {'/workshop'},
        hiredStaff: [apprenticeStaff],
      );

      expect(apprenticeStaff.isUnderTraining, false);
      expect(apprenticeStaff.isAvailableForWork, true);

      final courses = StaffRoleSpecializations.coursesForRole(StaffRole.apprentice);
      final course = courses.first;

      final success = notifier.trainStaffMember(apprenticeStaff.id, course);
      expect(success, true);

      final staffInTraining = container.read(gameProvider).hiredStaff.firstWhere(
            (s) => s.id == apprenticeStaff.id,
          );

      expect(staffInTraining.isUnderTraining, true);
      expect(staffInTraining.trainingDaysRemaining, course.durationDays);
      expect(staffInTraining.totalTrainingDays, course.durationDays);
      expect(staffInTraining.currentTrainingCourseId, course.id);
      expect(staffInTraining.isAvailableForWork, false);
      expect(staffInTraining.trainingProgress, 0.0);
    });

    test('Advancing game day decrements training days and graduates upon completion', () {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final notifier = container.read(gameProvider.notifier);

      final washerStaff = StaffModel(
        id: 'staff_wash_1',
        name: 'Kemal Usta',
        role: StaffRole.washer,
        hiredAt: DateTime.now(),
      );

      notifier.state = notifier.state.copyWith(
        balance: 500000.0,
        unlockedBuildings: {'/car-wash'},
        hiredStaff: [washerStaff],
      );

      final courses = StaffRoleSpecializations.coursesForRole(StaffRole.washer);
      final course = courses.first;

      notifier.trainStaffMember(washerStaff.id, course);

      final duration = course.durationDays;

      for (int i = 0; i < duration; i++) {
        final staffBeforeDay = container.read(gameProvider).hiredStaff.firstWhere(
              (s) => s.id == washerStaff.id,
            );

        if (i < duration - 1) {
          expect(staffBeforeDay.isUnderTraining, true);
          expect(staffBeforeDay.isAvailableForWork, false);
        }

        notifier.advanceGameDay();
      }

      final graduatedStaff = container.read(gameProvider).hiredStaff.firstWhere(
            (s) => s.id == washerStaff.id,
          );

      expect(graduatedStaff.isUnderTraining, false);
      expect(graduatedStaff.isAvailableForWork, true);
      expect(graduatedStaff.completedCourseIds.contains(course.id), true);
      expect(graduatedStaff.perk, isNotNull);
      expect(graduatedStaff.masteryLevel >= 1, true);
    });

    test('rushStaffTraining immediately graduates staff using rewarded video reward', () {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final notifier = container.read(gameProvider.notifier);

      final salesStaff = StaffModel(
        id: 'staff_sales_1',
        name: 'Hakan Bey',
        role: StaffRole.salesman,
        hiredAt: DateTime.now(),
      );

      notifier.state = notifier.state.copyWith(
        balance: 500000.0,
        unlockedBuildings: {'/showroom'},
        hiredStaff: [salesStaff],
      );

      final courses = StaffRoleSpecializations.coursesForRole(StaffRole.salesman);
      final course = courses.last;

      notifier.trainStaffMember(salesStaff.id, course);

      var staff = container.read(gameProvider).hiredStaff.firstWhere(
            (s) => s.id == salesStaff.id,
          );
      expect(staff.isUnderTraining, true);
      expect(staff.trainingDaysRemaining, course.durationDays);

      final rushed = notifier.rushStaffTraining(salesStaff.id);
      expect(rushed, true);

      staff = container.read(gameProvider).hiredStaff.firstWhere(
            (s) => s.id == salesStaff.id,
          );

      expect(staff.isUnderTraining, false);
      expect(staff.isAvailableForWork, true);
      expect(staff.completedCourseIds.contains(course.id), true);
      expect(staff.perk, isNotNull);
      expect(staff.trainingDaysRemaining, 0);
    });
  });

  group('Tactile Audio & Haptic Methods Safety Tests', () {
    test('GameSoundHapticService tactile methods execute without unhandled exceptions', () {
      expect(() => GameSoundHapticService.playSwitchToggle(true), returnsNormally);
      expect(() => GameSoundHapticService.playSwitchToggle(false), returnsNormally);
      expect(() => GameSoundHapticService.playCounterTick(), returnsNormally);
      expect(() => GameSoundHapticService.playStampSlam(), returnsNormally);
    });
  });
}
