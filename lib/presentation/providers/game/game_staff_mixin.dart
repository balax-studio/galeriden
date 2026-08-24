import '../../../core/constants/first_time_action_keys.dart';
import '../../../data/models/mission_model.dart';
import '../../../data/models/staff_model.dart';
import 'game_base_notifier.dart';

mixin GameStaffMixin on GameBaseNotifier {
  /// Hire a staff member
  bool hireStaff(StaffModel staff) {
    if (!state.isFeatureUnlocked(staff.role.requiredFeatureRoute)) return false;
    if (state.hiredStaff.any((s) => s.role == staff.role))
      return false; // Max 1 per role
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

  /// Treat a staff member to tea & coffee (₺500, +15 Morale)
  bool treatStaffTea(String staffId) {
    const cost = 500.0;
    if (state.balance < cost) return false;

    final index = state.hiredStaff.indexWhere((s) => s.id == staffId);
    if (index == -1) return false;

    final staff = state.hiredStaff[index];
    if (staff.morale >= 100) return false;
    final newMorale = (staff.morale + 15).clamp(0, 100);

    List<StaffModel> updated = List<StaffModel>.from(state.hiredStaff);
    updated[index] = staff.copyWith(morale: newMorale);

    state = state.copyWith(
      balance: state.balance - cost,
      hiredStaff: updated,
    );
    addXP(5);
    saveState();
    return true;
  }

  /// Treat a staff member to a rich meal & kebab (₺1.500, +35 Morale)
  bool treatStaffMeal(String staffId) {
    const cost = 1500.0;
    if (state.balance < cost) return false;

    final index = state.hiredStaff.indexWhere((s) => s.id == staffId);
    if (index == -1) return false;

    final staff = state.hiredStaff[index];
    if (staff.morale >= 100) return false;
    final newMorale = (staff.morale + 35).clamp(0, 100);

    List<StaffModel> updated = List<StaffModel>.from(state.hiredStaff);
    updated[index] = staff.copyWith(morale: newMorale);

    state = state.copyWith(
      balance: state.balance - cost,
      hiredStaff: updated,
    );
    addXP(15);
    saveState();
    return true;
  }

  /// Give performance bonus / festival payout to staff (+50 Morale, grants dealer XP)
  bool giveStaffBonus(String staffId, double amount) {
    if (amount <= 0 || state.balance < amount) return false;

    final index = state.hiredStaff.indexWhere((s) => s.id == staffId);
    if (index == -1) return false;

    final staff = state.hiredStaff[index];
    if (staff.morale >= 100) return false;
    final newMorale = (staff.morale + 50).clamp(0, 100);

    List<StaffModel> updated = List<StaffModel>.from(state.hiredStaff);
    updated[index] = staff.copyWith(
      morale: newMorale,
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

  /// Train a specific staff member with a role-specialized course
  bool trainStaffMember(String staffId, StaffTrainingCourse course) {
    if (state.balance < course.cost) return false;

    final index = state.hiredStaff.indexWhere((s) => s.id == staffId);
    if (index == -1) return false;

    final staff = state.hiredStaff[index];
    if (staff.completedCourseIds.contains(course.id)) return false;

    final updatedCourses = [...staff.completedCourseIds, course.id];
    final newMorale = (staff.morale + 20).clamp(0, 100);
    final newMasteryLevel = (staff.masteryLevel + 1).clamp(1, 5);

    final updatedStaff = staff.copyWith(
      completedCourseIds: updatedCourses,
      morale: newMorale,
      masteryLevel: newMasteryLevel,
      specialization: course.title,
    );

    List<StaffModel> updatedList = List<StaffModel>.from(state.hiredStaff);
    updatedList[index] = updatedStaff;

    final updatedAcademyPurchases =
        state.purchasedAcademyCourses.contains(course.id)
            ? state.purchasedAcademyCourses
            : [...state.purchasedAcademyCourses, course.id];

    state = state.copyWith(
      balance: state.balance - course.cost,
      hiredStaff: updatedList,
      purchasedAcademyCourses: updatedAcademyPurchases,
    );

    addXP(40);
    saveState();
    return true;
  }
}
