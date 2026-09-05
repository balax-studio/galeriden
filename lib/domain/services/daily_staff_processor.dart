import 'dart:math';
import '../../data/models/car_model.dart';
import '../../data/models/dealership_model.dart';
import '../../data/models/game_event_model.dart';
import '../../data/models/staff_model.dart';

/// Pure domain processor for daily staff operations: training progression,
/// leave management, daily fatigue, salaries, resignations, and staff automation.
class DailyStaffProcessor {
  const DailyStaffProcessor._();

  static (double newBalance, List<StaffModel> updatedStaff, List<GameEventModel> updatedEvents) processSalaries({
    required double balance,
    required List<StaffModel> staff,
    required List<GameEventModel> events,
    required SpecializationPath specializationPath,
  }) {
    if (staff.isEmpty) return (balance, staff, events);

    // 1. Process staff training progression & graduations
    List<StaffModel> updatedStaff = [];
    for (final s in staff) {
      if (s.isUnderTraining) {
        final remaining = s.trainingDaysRemaining - 1;
        if (remaining <= 0) {
          final courseId = s.currentTrainingCourseId;
          final course = courseId != null
              ? StaffRoleSpecializations.allCourses.firstWhere(
                  (c) => c.id == courseId,
                  orElse: () => StaffRoleSpecializations.allCourses.first,
                )
              : null;
          final updatedCourses = courseId != null &&
                  !s.completedCourseIds.contains(courseId)
              ? [...s.completedCourseIds, courseId]
              : s.completedCourseIds;
          StaffPerk? assignedPerk = s.perk;
          if (assignedPerk == null) {
            switch (s.role) {
              case StaffRole.washer:
                assignedPerk = StaffPerk.meticulous;
                break;
              case StaffRole.apprentice:
                assignedPerk = StaffPerk.hardWorker;
                break;
              case StaffRole.salesman:
                assignedPerk = StaffPerk.silverTongue;
                break;
              case StaffRole.masterMechanic:
              case StaffRole.appraiser:
                assignedPerk = StaffPerk.meticulous;
                break;
              case StaffRole.marketer:
                assignedPerk = StaffPerk.silverTongue;
                break;
              case StaffRole.legalAdvisor:
                assignedPerk = StaffPerk.thrifty;
                break;
            }
          }
          final newMorale = min(100, s.morale + 25);
          final newMastery = min(5, s.masteryLevel + 1);
          updatedStaff.add(s.copyWith(
            completedCourseIds: updatedCourses,
            morale: newMorale,
            masteryLevel: newMastery,
            perk: assignedPerk,
            specialization: course?.title ?? s.specialization,
            isUnderTraining: false,
            trainingDaysRemaining: 0,
            totalTrainingDays: 0,
            currentTrainingCourseId: null,
          ));
          events.insert(
            0,
            GameEventModel(
              id: 'staff_grad_${DateTime.now().millisecondsSinceEpoch}_${s.id}',
              title: 'USTALIK MEZUNİYETİ!',
              description:
                  '${s.name}, ${course?.title ?? "kurs"} eğitimini üstün başarıyla tamamladı ve diplomasını alarak görevine döndü!',
              type: GameEventType.goodEvent,
              amount: 0.0,
              date: DateTime.now(),
            ),
          );
        } else {
          final newEnergy = max(0, s.energy - 10);
          updatedStaff.add(s.copyWith(
            trainingDaysRemaining: remaining,
            energy: newEnergy,
          ));
        }
      } else if (s.isOnLeave) {
        final remainingLeave = s.leaveDaysRemaining - 1;
        final recoveredEnergy = min(100, s.energy + 50);
        final refreshedMorale = min(100, s.morale + 5);
        if (remainingLeave <= 0) {
          updatedStaff.add(s.copyWith(
            isOnLeave: false,
            leaveDaysRemaining: 0,
            energy: recoveredEnergy,
            morale: refreshedMorale,
          ));
          events.insert(
            0,
            GameEventModel(
              id: 'staff_leave_end_${DateTime.now().millisecondsSinceEpoch}_${s.id}',
              title: 'PERSONEL İZİNDEN DÖNDÜ!',
              description:
                  '${s.name} dinlenme iznini tamamladı, enerjisini toplayarak - %$recoveredEnergy Enerji ile - göreve geri döndü!',
              type: GameEventType.goodEvent,
              amount: 0.0,
              date: DateTime.now(),
            ),
          );
        } else {
          updatedStaff.add(s.copyWith(
            leaveDaysRemaining: remainingLeave,
            energy: recoveredEnergy,
            morale: refreshedMorale,
          ));
        }
      } else {
        // Working staff daily fatigue
        final decay = s.perk == StaffPerk.hardWorker ? 8 : 12;
        final newEnergy = max(0, s.energy - decay);
        updatedStaff.add(s.copyWith(energy: newEnergy));
      }
    }

    // 2. Process daily salaries and morale
    double totalSalaries = updatedStaff.fold(0.0, (sum, st) => sum + st.dailySalary);
    if (specializationPath == SpecializationPath.boss) {
      totalSalaries *= 0.80;
    }

    if (balance >= totalSalaries) {
      final finalStaff = updatedStaff
          .map((s) => s.copyWith(morale: min(100, s.morale + 1)))
          .toList();
      return (balance - totalSalaries, finalStaff, events);
    } else {
      final remainingStaff = <StaffModel>[];
      final resignedStaff = <StaffModel>[];

      for (final s in updatedStaff) {
        final newMorale = s.morale - 35;
        if (newMorale <= 10) {
          resignedStaff.add(s);
        } else {
          remainingStaff.add(s.copyWith(morale: newMorale));
        }
      }

      if (resignedStaff.isNotEmpty) {
        final names =
            resignedStaff.map((s) => '${s.name} • ${s.role.name}').join(', ');
        events.insert(
            0,
            GameEventModel(
              id: 'staff_resignation_${DateTime.now().millisecondsSinceEpoch}',
              title: 'PERSONEL İSTİFASI!',
              description:
                  'Maaş ödemeleri yapılamadığı için $names morali tükenerek galerinizi terk etti ve istifa etti!',
              type: GameEventType.expense,
              amount: 0.0,
              date: DateTime.now(),
            ));
      } else {
        events.insert(
            0,
            GameEventModel(
              id: 'salary_unpaid_${DateTime.now().millisecondsSinceEpoch}',
              title: 'MAAŞLAR ÖDENEMEDİ!',
              description:
                  'Kasada yeterli nakit olmadığı için personellerin günlük maaşı ödenemedi. Personel morali ağır darbe aldı • -35 Moral!',
              type: GameEventType.expense,
              amount: 0.0,
              date: DateTime.now(),
            ));
      }

      return (balance, remainingStaff, events);
    }
  }

  static List<CarModel> processStaffAutomation({
    required List<StaffModel> staff,
    required List<CarModel> cars,
    required bool hasCarWashBusiness,
  }) {
    final hasWasher =
        staff.any((s) => s.isAvailableForWork && s.role == StaffRole.washer) || hasCarWashBusiness;
    final hasMechanic = staff.any((s) => s.isAvailableForWork && s.role == StaffRole.masterMechanic);

    if (hasWasher && cars.isNotEmpty) {
      int washedCount = 0;
      final maxCleanPerDay = hasCarWashBusiness ? 5 : 2;
      for (int i = 0; i < cars.length; i++) {
        final car = cars[i];
        if (!car.isWashed || !car.isPolished || !car.isDetailedCleaned) {
          cars[i] = car.copyWith(
              isWashed: true, isPolished: true, isDetailedCleaned: true);
          washedCount++;
          if (washedCount >= maxCleanPerDay) break;
        }
      }
    }

    if (hasMechanic && cars.isNotEmpty) {
      for (int i = 0; i < cars.length; i++) {
        final car = cars[i];
        if (car.expertise.engineCondition < 100 ||
            car.expertise.transmissionCondition < 100) {
          final newEngine = min(100.0, car.expertise.engineCondition + 20.0);
          final newTrans =
              min(100.0, car.expertise.transmissionCondition + 20.0);
          cars[i] = car.copyWith(
              expertise: car.expertise.copyWith(
                  engineCondition: newEngine, transmissionCondition: newTrans));
          break;
        }
      }
    }
    return cars;
  }
}
