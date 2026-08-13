import '../../../data/models/staff_model.dart';
import 'game_base_notifier.dart';

mixin GameStaffMixin on GameBaseNotifier {
  /// Hire a staff member
  bool hireStaff(StaffModel staff) {
    if (state.hiredStaff.any((s) => s.role == staff.role)) return false; // Max 1 per role
    state = state.copyWith(hiredStaff: [...state.hiredStaff, staff]);
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
}
