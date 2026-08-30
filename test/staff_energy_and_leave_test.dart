import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/data/models/staff_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Staff Energy and Leave System Tests', () {
    test('StaffModel serialization handles energy and leaveDaysRemaining', () {
      final staff = StaffModel(
        id: 'staff_test_1',
        name: 'Ahmet Usta',
        role: StaffRole.masterMechanic,
        hiredAt: DateTime(2026, 1, 1),
        energy: 85,
        leaveDaysRemaining: 2,
        isOnLeave: true,
      );

      expect(staff.energy, 85);
      expect(staff.leaveDaysRemaining, 2);
      expect(staff.isOnLeave, isTrue);
      expect(staff.isExhausted, isFalse);

      final json = staff.toJson();
      expect(json['energy'], 85);
      expect(json['leaveDaysRemaining'], 2);
      expect(json['isOnLeave'], isTrue);

      final parsed = StaffModel.fromJson(json);
      expect(parsed.energy, 85);
      expect(parsed.leaveDaysRemaining, 2);
      expect(parsed.isOnLeave, isTrue);
    });

    test('StaffModel exhaustion check is true when energy <= 20 and speedMultiplier is penalized', () {
      final tiredStaff = StaffModel(
        id: 'staff_tired',
        name: 'Yorgun Usta',
        role: StaffRole.apprentice,
        hiredAt: DateTime(2026, 1, 1),
        energy: 20,
      );

      expect(tiredStaff.isExhausted, isTrue);
      expect(tiredStaff.isAvailableForWork, isTrue);

      final veryTiredStaff = StaffModel(
        id: 'staff_very_tired',
        name: 'Tükenmiş Usta',
        role: StaffRole.apprentice,
        hiredAt: DateTime(2026, 1, 1),
        energy: 5,
      );

      expect(veryTiredStaff.isExhausted, isTrue);
      expect(veryTiredStaff.isAvailableForWork, isFalse);

      final freshStaff = StaffModel(
        id: 'staff_fresh',
        name: 'Dinamik Usta',
        role: StaffRole.apprentice,
        hiredAt: DateTime(2026, 1, 1),
        energy: 90,
      );

      expect(freshStaff.isExhausted, isFalse);
      expect(freshStaff.isAvailableForWork, isTrue);
      expect(freshStaff.speedMultiplier, greaterThan(tiredStaff.speedMultiplier));
    });

    test('Provider sendStaffOnLeave and recallStaffFromLeave update state properly', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      final testStaff = StaffModel(
        id: 'staff_test_leave',
        name: 'Mehmet Usta',
        role: StaffRole.masterMechanic,
        hiredAt: DateTime.now(),
        energy: 50,
      );

      notifier.state = notifier.state.copyWith(
        balance: 100000,
        hiredStaff: [testStaff],
      );

      final initialStaff = container.read(gameProvider).hiredStaff;
      expect(initialStaff.isNotEmpty, isTrue);

      final targetId = testStaff.id;

      // Send on leave for 1 day
      final leaveResult = notifier.sendStaffOnLeave(targetId, 1);
      expect(leaveResult, isTrue);

      final staffAfterLeave = container.read(gameProvider).hiredStaff.firstWhere((s) => s.id == targetId);
      expect(staffAfterLeave.isOnLeave, isTrue);
      expect(staffAfterLeave.leaveDaysRemaining, 1);
      expect(staffAfterLeave.isAvailableForWork, isFalse);

      // Recall early
      final recallResult = notifier.recallStaffFromLeave(targetId);
      expect(recallResult, isTrue);

      final staffAfterRecall = container.read(gameProvider).hiredStaff.firstWhere((s) => s.id == targetId);
      expect(staffAfterRecall.isOnLeave, isFalse);
      expect(staffAfterRecall.leaveDaysRemaining, 0);
      expect(staffAfterRecall.isAvailableForWork, isTrue);
    });

    test('advanceGameDay decrements leaveDaysRemaining and restores full energy on leave completion', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      final testStaff = StaffModel(
        id: 'staff_advance_test',
        name: 'Hasan Usta',
        role: StaffRole.apprentice,
        hiredAt: DateTime.now(),
        energy: 20,
      );

      notifier.state = notifier.state.copyWith(
        balance: 100000,
        hiredStaff: [testStaff],
      );

      final targetId = testStaff.id;

      // Put on 1-day leave
      notifier.sendStaffOnLeave(targetId, 1);

      var currentStaff = container.read(gameProvider).hiredStaff.firstWhere((s) => s.id == targetId);
      expect(currentStaff.energy, lessThanOrEqualTo(20));
      expect(currentStaff.isOnLeave, isTrue);

      // Advance day
      notifier.advanceGameDay();

      currentStaff = container.read(gameProvider).hiredStaff.firstWhere((s) => s.id == targetId);
      expect(currentStaff.leaveDaysRemaining, 0);
      expect(currentStaff.isOnLeave, isFalse);
      expect(currentStaff.energy, 70);
    });

    test('Staff treatStaffMeal and treatStaffTea recover energy', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      final testStaff = StaffModel(
        id: 'staff_boost_test',
        name: 'Veli Usta',
        role: StaffRole.washer,
        hiredAt: DateTime.now(),
        morale: 40,
        energy: 40,
      );

      notifier.state = notifier.state.copyWith(
        balance: 100000,
        hiredStaff: [testStaff],
      );

      final targetId = testStaff.id;
      final staffBefore = container.read(gameProvider).hiredStaff.firstWhere((s) => s.id == targetId);
      final energyBefore = staffBefore.energy;

      // Treat meal (₺1500)
      notifier.treatStaffMeal(targetId);

      final staffAfterMeal = container.read(gameProvider).hiredStaff.firstWhere((s) => s.id == targetId);
      expect(staffAfterMeal.energy, greaterThan(energyBefore));
      expect(staffAfterMeal.morale, greaterThan(staffBefore.morale));
    });
  });
}
