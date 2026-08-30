import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/core/services/game_sound_haptic_service.dart';
import 'package:galeriden/data/models/staff_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
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

      // Trigger rewarded ad speedup
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
