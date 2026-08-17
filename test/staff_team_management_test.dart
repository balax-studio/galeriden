import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/staff_model.dart';
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
}
