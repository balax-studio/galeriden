import '../../../core/constants/first_time_action_keys.dart';
import '../../../data/models/mission_model.dart';
import '../../../data/models/staff_model.dart';
import 'game_base_notifier.dart';

mixin GameStaffMixin on GameBaseNotifier {
  /// Hire a staff member
  bool hireStaff(StaffModel staff) {
    if (!state.isFeatureUnlocked(staff.role.requiredFeatureRoute)) {
      return false;
    }
    if (state.hiredStaff.any((s) => s.role == staff.role)) {
      return false; // Max 1 per role
    }
    state = state.copyWith(hiredStaff: [...state.hiredStaff, staff]);
    addXP(25);
    checkAndAwardFirstTimeAction(FirstTimeActionKeys.firstStaffHire);
    updateMissionProgress(MissionType.hireStaff, 1);
    saveState();
    return true;
  }

  /// Fire a staff member
  void fireStaff(String staffId) {
    state = state.copyWith(
      hiredStaff: state.hiredStaff.where((s) => s.id != staffId).toList(),
    );
    saveState();
  }

  /// Treat a staff member to tea & coffee (₺500, +15 Morale, +15 Energy)
  bool treatStaffTea(String staffId) {
    const cost = 500.0;
    if (state.balance < cost) return false;

    final index = state.hiredStaff.indexWhere((s) => s.id == staffId);
    if (index == -1) return false;

    final staff = state.hiredStaff[index];
    if (staff.morale >= 100 && staff.energy >= 100) return false;
    final newMorale = (staff.morale + 15).clamp(0, 100);
    final newEnergy = (staff.energy + 15).clamp(0, 100);

    List<StaffModel> updated = List<StaffModel>.from(state.hiredStaff);
    updated[index] = staff.copyWith(morale: newMorale, energy: newEnergy);

    state = state.copyWith(
      balance: state.balance - cost,
      hiredStaff: updated,
    );
    addXP(5);
    saveState();
    return true;
  }

  /// Treat a staff member to a rich meal & kebab (₺1.500, +35 Morale, +30 Energy)
  bool treatStaffMeal(String staffId) {
    const cost = 1500.0;
    if (state.balance < cost) return false;

    final index = state.hiredStaff.indexWhere((s) => s.id == staffId);
    if (index == -1) return false;

    final staff = state.hiredStaff[index];
    if (staff.morale >= 100 && staff.energy >= 100) return false;
    final newMorale = (staff.morale + 35).clamp(0, 100);
    final newEnergy = (staff.energy + 30).clamp(0, 100);

    List<StaffModel> updated = List<StaffModel>.from(state.hiredStaff);
    updated[index] = staff.copyWith(morale: newMorale, energy: newEnergy);

    state = state.copyWith(
      balance: state.balance - cost,
      hiredStaff: updated,
    );
    addXP(15);
    saveState();
    return true;
  }

  /// Give performance bonus / festival payout to staff (+50 Morale, +40 Energy, grants dealer XP)
  bool giveStaffBonus(String staffId, double amount) {
    if (amount <= 0 || state.balance < amount) return false;

    final index = state.hiredStaff.indexWhere((s) => s.id == staffId);
    if (index == -1) return false;

    final staff = state.hiredStaff[index];
    if (staff.morale >= 100 && staff.energy >= 100) return false;
    final newMorale = (staff.morale + 50).clamp(0, 100);
    final newEnergy = (staff.energy + 40).clamp(0, 100);

    List<StaffModel> updated = List<StaffModel>.from(state.hiredStaff);
    updated[index] = staff.copyWith(
      morale: newMorale,
      energy: newEnergy,
      salaryMultiplier: staff.salaryMultiplier * 1.05,
    );

    state = state.copyWith(
      balance: state.balance - amount,
      hiredStaff: updated,
    );
    addXP(30);
    saveState();
    return true;
  }

  /// Send a staff member on a paid resting leave (recovers +50 Energy per day)
  bool sendStaffOnLeave(String staffId, int days) {
    if (days <= 0) return false;

    final index = state.hiredStaff.indexWhere((s) => s.id == staffId);
    if (index == -1) return false;

    final staff = state.hiredStaff[index];
    if (staff.isOnLeave || staff.isUnderTraining) return false;

    List<StaffModel> updated = List<StaffModel>.from(state.hiredStaff);
    updated[index] = staff.copyWith(
      isOnLeave: true,
      leaveDaysRemaining: days,
    );

    state = state.copyWith(hiredStaff: updated);
    addXP(15);
    saveState();
    return true;
  }

  /// Recall staff member early from leave
  bool recallStaffFromLeave(String staffId) {
    final index = state.hiredStaff.indexWhere((s) => s.id == staffId);
    if (index == -1) return false;

    final staff = state.hiredStaff[index];
    if (!staff.isOnLeave) return false;

    List<StaffModel> updated = List<StaffModel>.from(state.hiredStaff);
    updated[index] = staff.copyWith(
      isOnLeave: false,
      leaveDaysRemaining: 0,
    );

    state = state.copyWith(hiredStaff: updated);
    saveState();
    return true;
  }

  /// Drain staff energy when completing intensive workshop or dealership tasks
  bool drainStaffEnergy(String staffId, int amount) {
    if (amount <= 0) return false;

    final index = state.hiredStaff.indexWhere((s) => s.id == staffId);
    if (index == -1) return false;

    final staff = state.hiredStaff[index];
    final newEnergy = (staff.energy - amount).clamp(0, 100);

    List<StaffModel> updated = List<StaffModel>.from(state.hiredStaff);
    updated[index] = staff.copyWith(energy: newEnergy);

    state = state.copyWith(hiredStaff: updated);
    saveState();
    return true;
  }

  /// Purchase an academy certificate course for all staff
  bool purchaseAcademyCourse(String courseId, double cost) {
    if (state.purchasedAcademyCourses.contains(courseId)) return false;
    if (state.balance < cost) return false;

    state = state.copyWith(
      balance: state.balance - cost,
      purchasedAcademyCourses: [...state.purchasedAcademyCourses, courseId],
    );
    addXP(50);
    saveState();
    return true;
  }

  /// Enroll a specific staff member into a role-specialized training course (1-3 days)
  bool trainStaffMember(String staffId, StaffTrainingCourse course) {
    if (state.balance < course.cost) return false;

    final index = state.hiredStaff.indexWhere((s) => s.id == staffId);
    if (index == -1) return false;

    final staff = state.hiredStaff[index];
    if (staff.completedCourseIds.contains(course.id)) return false;
    if (staff.isUnderTraining) return false;

    final updatedStaff = staff.copyWith(
      isUnderTraining: true,
      trainingDaysRemaining: course.durationDays,
      totalTrainingDays: course.durationDays,
      currentTrainingCourseId: course.id,
    );

    List<StaffModel> updatedList = List<StaffModel>.from(state.hiredStaff);
    updatedList[index] = updatedStaff;

    state = state.copyWith(
      balance: state.balance - course.cost,
      hiredStaff: updatedList,
    );

    addXP(20);
    saveState();
    return true;
  }

  /// Instantly rush and complete staff training with Rewarded Video Ad
  bool rushStaffTraining(String staffId) {
    final index = state.hiredStaff.indexWhere((s) => s.id == staffId);
    if (index == -1) return false;

    final staff = state.hiredStaff[index];
    if (!staff.isUnderTraining || staff.currentTrainingCourseId == null) {
      return false;
    }

    final courseId = staff.currentTrainingCourseId!;
    final course = StaffRoleSpecializations.allCourses.firstWhere(
      (c) => c.id == courseId,
      orElse: () => StaffRoleSpecializations.allCourses.first,
    );

    final updatedCourses = staff.completedCourseIds.contains(courseId)
        ? staff.completedCourseIds
        : [...staff.completedCourseIds, courseId];
    final newMorale = (staff.morale + 25).clamp(0, 100);
    final newMasteryLevel = (staff.masteryLevel + 1).clamp(1, 5);
    StaffPerk? assignedPerk = staff.perk;
    if (assignedPerk == null) {
      switch (staff.role) {
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

    final updatedStaff = staff.copyWith(
      completedCourseIds: updatedCourses,
      morale: newMorale,
      masteryLevel: newMasteryLevel,
      perk: assignedPerk,
      specialization: course.title,
      isUnderTraining: false,
      trainingDaysRemaining: 0,
      totalTrainingDays: 0,
      currentTrainingCourseId: null,
    );

    List<StaffModel> updatedList = List<StaffModel>.from(state.hiredStaff);
    updatedList[index] = updatedStaff;

    final updatedAcademyPurchases =
        state.purchasedAcademyCourses.contains(courseId)
            ? state.purchasedAcademyCourses
            : [...state.purchasedAcademyCourses, courseId];

    state = state.copyWith(
      hiredStaff: updatedList,
      purchasedAcademyCourses: updatedAcademyPurchases,
    );

    addXP(50);
    saveState();
    return true;
  }
}
