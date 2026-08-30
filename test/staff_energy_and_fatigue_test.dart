import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/data/models/staff_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Staff Energy, Stamina & Leave Mechanism Suite', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
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

    test('1. StaffModel initializes with 100 energy, not on leave, and JSON roundtrip preserves energy state', () {
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

    test('2. Working staff loses energy on daily turnover, while resting staff on leave recovers +50 energy and returns after leave', () {
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

      // Send mechanic on 1-day leave
      final leaveSuccess = container.read(gameProvider.notifier).sendStaffOnLeave(mechanic.id, 1);
      expect(leaveSuccess, isTrue);

      final onLeaveStaff = container.read(gameProvider).hiredStaff.firstWhere((s) => s.id == mechanic.id);
      expect(onLeaveStaff.isOnLeave, isTrue);
      expect(onLeaveStaff.leaveDaysRemaining, equals(1));
      expect(onLeaveStaff.isAvailableForWork, isFalse);

      // Advance game day
      container.read(gameProvider.notifier).advanceGameDay();

      final staffAfterDay = container.read(gameProvider).hiredStaff;
      final updatedMechanic = staffAfterDay.firstWhere((s) => s.id == mechanic.id);
      final updatedWasher = staffAfterDay.firstWhere((s) => s.id == washer.id);

      // Resting mechanic gained +50 energy (40 + 50 = 90) and finished 1-day leave
      expect(updatedMechanic.energy, equals(90));
      expect(updatedMechanic.isOnLeave, isFalse);
      expect(updatedMechanic.leaveDaysRemaining, equals(0));
      expect(updatedMechanic.isAvailableForWork, isTrue);

      // Working washer consumed energy (40 - 12 = 28)
      expect(updatedWasher.energy, equals(28));
      expect(updatedWasher.isAvailableForWork, isTrue);
    });

    test('3. Treats (Tea, Meal, Bonus) restore both morale and energy', () {
      final salesman = StaffModel(
        id: 'staff_sale',
        name: 'Selin Satış',
        role: StaffRole.salesman,
        hiredAt: DateTime(2026, 1, 1),
        morale: 50,
        energy: 50,
      );

      container.read(gameProvider.notifier).hireStaff(salesman);

      // Treat Tea (₺500, +15 Morale, +15 Energy)
      final teaOk = container.read(gameProvider.notifier).treatStaffTea(salesman.id);
      expect(teaOk, isTrue);

      var staff = container.read(gameProvider).hiredStaff.firstWhere((s) => s.id == salesman.id);
      expect(staff.morale, equals(65));
      expect(staff.energy, equals(65));

      // Treat Meal (₺1.500, +35 Morale, +30 Energy)
      final mealOk = container.read(gameProvider.notifier).treatStaffMeal(salesman.id);
      expect(mealOk, isTrue);

      staff = container.read(gameProvider).hiredStaff.firstWhere((s) => s.id == salesman.id);
      expect(staff.morale, equals(100));
      expect(staff.energy, equals(95));
    });

    test('4. Exhausted staff with energy <= 10 is marked unavailable for work and has lower speed multiplier', () {
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

    test('5. Recalling staff early from leave brings them back to work immediately', () {
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
}
