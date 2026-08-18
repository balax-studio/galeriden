import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/side_business_model.dart';

void main() {
  group('SideBusinessModel Maintenance Expense & Passive Income Balancing Tests', () {
    test('1. Maintenance expense scales with gross income and level', () {
      final businessLvl1 = SideBusinessModel(
        id: 'sb_test',
        name: 'Oto Yıkama',
        type: SideBusinessType.carWash,
        dailyIncome: 10000.0,
        cost: 50000.0,
        isOwned: true,
        level: 1,
      );

      final businessLvl3 = businessLvl1.copyWith(level: 3);
      final businessLvl5 = businessLvl1.copyWith(level: 5);

      // Level 1: 15% maintenance rate -> gross = 10.000 -> expense = 1.500 -> net = 8.500
      expect(businessLvl1.grossDailyIncome, equals(10000.0));
      expect(businessLvl1.dailyMaintenanceExpense, equals(1500.0));
      expect(businessLvl1.effectiveDailyIncome, equals(8500.0));

      // Level 3: base = 10.000 * (1 + 2*0.35) = 17.000 -> expense = 2.550 -> net = 14.450
      expect(businessLvl3.grossDailyIncome, equals(17000.0));
      expect(businessLvl3.dailyMaintenanceExpense, equals(2550.0));
      expect(businessLvl3.effectiveDailyIncome, equals(14450.0));

      // Level 5: base = 10.000 * (1 + 4*0.35) = 24.000 -> expense = 3.600 -> net = 20.400
      expect(businessLvl5.grossDailyIncome, equals(24000.0));
      expect(businessLvl5.dailyMaintenanceExpense, equals(3600.0));
      expect(businessLvl5.effectiveDailyIncome, equals(20400.0));
    });

    test('2. Having a manager adds manager salary to maintenance expense', () {
      final businessWithManager = SideBusinessModel(
        id: 'sb_mgr',
        name: 'Otomat İstasyonu',
        type: SideBusinessType.vendingMachine,
        dailyIncome: 1000.0,
        cost: 25000.0,
        isOwned: true,
        level: 1,
        hasManager: true,
        managerSalary: 150.0,
        managerBonusPercent: 0.20,
      );

      // Gross = 1000 * 1.20 = 1200
      // Maintenance = (1200 * 0.15) + 150 = 180 + 150 = 330
      // Effective net = 1200 - 330 = 870
      expect(businessWithManager.grossDailyIncome, equals(1200.0));
      expect(businessWithManager.dailyMaintenanceExpense, equals(330.0));
      expect(businessWithManager.effectiveDailyIncome, equals(870.0));
    });
  });
}
