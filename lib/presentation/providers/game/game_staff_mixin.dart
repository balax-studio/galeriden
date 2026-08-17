import '../../../data/models/staff_model.dart';
import 'game_base_notifier.dart';

mixin GameStaffMixin on GameBaseNotifier {
  /// Hire a staff member
  bool hireStaff(StaffModel staff) {
    if (state.hiredStaff.any((s) => s.role == staff.role)) return false; // Max 1 per role
    state = state.copyWith(hiredStaff: [...state.hiredStaff, staff]);
    addXP(25);
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
}
