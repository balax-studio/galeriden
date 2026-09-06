import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/side_business_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/domain/usecases/side_business_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Side Business Maintenance Expense & Passive Income Balancing Tests', () {
    test('Maintenance expense scales with gross income and level', () {
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

    test('Having a manager adds manager salary to maintenance expense', () {
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

      expect(businessWithManager.grossDailyIncome, equals(1200.0));
      expect(businessWithManager.dailyMaintenanceExpense, equals(330.0));
      expect(businessWithManager.effectiveDailyIncome, equals(870.0));
    });
  });

  group('Side Business Construction Duration & Engine Gating Tests', () {
    test('Verifies base construction duration matrix across all business types', () {
      expect(SideBusinessType.vendingMachine.baseConstructionDays, 0);
      expect(SideBusinessType.billboard.baseConstructionDays, 1);
      expect(SideBusinessType.autoShop.baseConstructionDays, 2);
      expect(SideBusinessType.carWash.baseConstructionDays, 2);
      expect(SideBusinessType.towTruck.baseConstructionDays, 3);
      expect(SideBusinessType.sparePartsStore.baseConstructionDays, 3);
      expect(SideBusinessType.wrapStudio.baseConstructionDays, 3);
      expect(SideBusinessType.evCharging.baseConstructionDays, 4);
      expect(SideBusinessType.inspectionStation.baseConstructionDays, 4);
      expect(SideBusinessType.corporateExpertise.baseConstructionDays, 5);
      expect(SideBusinessType.carRental.baseConstructionDays, 5);
    });

    test('SideBusinessModel operational and progress getters work correctly', () {
      final business = SideBusinessModel(
        id: 'wash_1',
        name: 'Oto Yıkama',
        type: SideBusinessType.carWash,
        dailyIncome: 1200.0,
        cost: 150000.0,
        isOwned: true,
        isUnderConstruction: true,
        constructionDaysRemaining: 2,
        totalConstructionDays: 2,
      );

      expect(business.isOperational, false);
      expect(business.grossDailyIncome, 0.0);
      expect(business.effectiveDailyIncome, 0.0);
      expect(business.constructionProgress, 0.0);

      final progressed = business.copyWith(
        constructionDaysRemaining: 1,
      );
      expect(progressed.constructionProgress, 0.5);
      expect(progressed.isOperational, false);

      final finished = business.copyWith(
        isUnderConstruction: false,
        constructionDaysRemaining: 0,
      );
      expect(finished.isOperational, true);
      expect(finished.grossDailyIncome, greaterThan(0.0));
      expect(finished.effectiveDailyIncome, greaterThan(0.0));
      expect(finished.constructionProgress, 1.0);
    });

    test('Serialization correctly preserves construction fields in JSON round-trip', () {
      final model = SideBusinessModel(
        id: 'exp_1',
        name: 'Kurumsal Ekspertiz',
        type: SideBusinessType.corporateExpertise,
        dailyIncome: 4500.0,
        cost: 500000.0,
        isOwned: true,
        isUnderConstruction: true,
        constructionDaysRemaining: 3,
        totalConstructionDays: 5,
      );

      final json = model.toJson();
      expect(json['isUnderConstruction'], true);
      expect(json['constructionDaysRemaining'], 3);
      expect(json['totalConstructionDays'], 5);

      final restored = SideBusinessModel.fromJson(json);
      expect(restored.isUnderConstruction, true);
      expect(restored.constructionDaysRemaining, 3);
      expect(restored.totalConstructionDays, 5);
      expect(restored.isOperational, false);
    });

    test('Engine does not generate revenue for businesses under construction', () {
      final businesses = [
        SideBusinessModel(
          id: 'vending_1',
          name: 'Otomat',
          type: SideBusinessType.vendingMachine,
          dailyIncome: 500.0,
          cost: 20000.0,
          isOwned: true,
          isUnderConstruction: false,
        ),
        SideBusinessModel(
          id: 'wash_1',
          name: 'Oto Yıkama',
          type: SideBusinessType.carWash,
          dailyIncome: 2000.0,
          cost: 200000.0,
          isOwned: true,
          isUnderConstruction: true,
          constructionDaysRemaining: 2,
          totalConstructionDays: 2,
        ),
      ];

      final (newBalance, updated) = SideBusinessEngine.processDailyEarnings(
        balance: 10000.0,
        cars: [],
        businesses: businesses,
        specializationPath: SpecializationPath.none,
        carsWashedLast7Days: 0,
        expertisesPerformedLast7Days: 0,
        partsRepairedLast7Days: 0,
        towedCarsLast7Days: 0,
        activeRentalsCount: 0,
      );

      // Only vending machine earns income
      expect(updated[0].totalEarned, greaterThan(0.0));
      expect(updated[1].totalEarned, 0.0);
      expect(newBalance, greaterThan(10000.0));
    });
  });

  group('GameProvider Purchase and Rush Actions Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Buying side business initializes construction correctly', () {
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(balance: 1000000.0);

      final carWash = notifier.state.sideBusinesses.firstWhere(
        (b) => b.type == SideBusinessType.carWash,
      );

      final buySuccess = notifier.buySideBusiness(carWash.id);
      expect(buySuccess, true);

      final updatedWash = notifier.state.sideBusinesses.firstWhere(
        (b) => b.id == carWash.id,
      );

      expect(updatedWash.isOwned, true);
      expect(updatedWash.isUnderConstruction, true);
      expect(updatedWash.constructionDaysRemaining, 2);
      expect(updatedWash.totalConstructionDays, 2);
      expect(updatedWash.isOperational, false);
    });

    test('Rushing construction instantly completes build and activates business', () {
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(balance: 1000000.0);

      final carWash = notifier.state.sideBusinesses.firstWhere(
        (b) => b.type == SideBusinessType.carWash,
      );

      notifier.buySideBusiness(carWash.id);

      final rushSuccess = notifier.completeSideBusinessConstruction(carWash.id);
      expect(rushSuccess, true);

      final updatedWash = notifier.state.sideBusinesses.firstWhere(
        (b) => b.id == carWash.id,
      );

      expect(updatedWash.isOwned, true);
      expect(updatedWash.isUnderConstruction, false);
      expect(updatedWash.constructionDaysRemaining, 0);
      expect(updatedWash.isOperational, true);
    });

    test('Advancing game days progresses and automatically completes construction', () {
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(balance: 1000000.0);

      final carWash = notifier.state.sideBusinesses.firstWhere(
        (b) => b.type == SideBusinessType.carWash,
      );

      notifier.buySideBusiness(carWash.id);

      // Day 1
      notifier.advanceGameDay();
      var washState = notifier.state.sideBusinesses.firstWhere((b) => b.id == carWash.id);
      expect(washState.isUnderConstruction, true);
      expect(washState.constructionDaysRemaining, 1);

      // Day 2
      notifier.advanceGameDay();
      washState = notifier.state.sideBusinesses.firstWhere((b) => b.id == carWash.id);
      expect(washState.isUnderConstruction, false);
      expect(washState.constructionDaysRemaining, 0);
      expect(washState.isOperational, true);
    });
  });

  group('Side Business Upgrade Model & Serialization Tests', () {
    test('SideBusinessUpgradeModel duration and operational state test', () {
      final upgrade = SideBusinessUpgradeModel(
        id: 'wash_up_1',
        title: 'Köpük Tabancası',
        description: 'Daha hızlı yıkama',
        cost: 5000.0,
        bonusDailyIncome: 400.0,
        isPurchased: true,
        isUpgrading: true,
        upgradeDaysRemaining: 1,
        totalUpgradeDays: 1,
      );

      expect(upgrade.isOperational, false);

      final completed = upgrade.copyWith(
        isUpgrading: false,
        upgradeDaysRemaining: 0,
      );
      expect(completed.isOperational, true);
    });

    test('SideBusinessUpgradeModel JSON serialization round-trip', () {
      final upgrade = SideBusinessUpgradeModel(
        id: 'wash_up_1',
        title: 'Köpük Tabancası',
        description: 'Daha hızlı yıkama',
        cost: 5000.0,
        bonusDailyIncome: 400.0,
        isPurchased: true,
        isUpgrading: true,
        upgradeDaysRemaining: 1,
        totalUpgradeDays: 1,
      );

      final json = upgrade.toJson();
      expect(json['isUpgrading'], true);
      expect(json['upgradeDaysRemaining'], 1);
      expect(json['totalUpgradeDays'], 1);

      final restored = SideBusinessUpgradeModel.fromJson(json);
      expect(restored.isUpgrading, true);
      expect(restored.upgradeDaysRemaining, 1);
      expect(restored.isOperational, false);
    });

    test('SideBusinessModel level upgrade fields and progress calculations', () {
      final business = SideBusinessModel(
        id: 'wash_1',
        name: 'Oto Yıkama',
        type: SideBusinessType.carWash,
        dailyIncome: 1500.0,
        cost: 150000.0,
        isOwned: true,
        level: 2,
        isUpgradingLevel: true,
        levelUpgradeDaysRemaining: 2,
        totalLevelUpgradeDays: 2,
        pendingTargetLevel: 3,
        upgrades: [
          SideBusinessUpgradeModel(
            id: 'up_1',
            title: 'Hızlı Kurutucu',
            description: 'Kurutma süresini kısaltır',
            cost: 10000.0,
            bonusDailyIncome: 500.0,
            isPurchased: true,
            isUpgrading: true,
            upgradeDaysRemaining: 1,
            totalUpgradeDays: 1,
          ),
          SideBusinessUpgradeModel(
            id: 'up_2',
            title: 'Seramik Kaplama',
            description: 'Ekstra parlaklık',
            cost: 15000.0,
            bonusDailyIncome: 800.0,
            isPurchased: true,
            isUpgrading: false,
          ),
        ],
      );

      expect(business.levelUpgradeProgress, 0.0);
      expect(business.purchasedUpgradeCount, 1);

      final progressed = business.copyWith(
        levelUpgradeDaysRemaining: 1,
      );
      expect(progressed.levelUpgradeProgress, 0.5);

      final json = business.toJson();
      expect(json['isUpgradingLevel'], true);
      expect(json['levelUpgradeDaysRemaining'], 2);
      expect(json['pendingTargetLevel'], 3);

      final restored = SideBusinessModel.fromJson(json);
      expect(restored.isUpgradingLevel, true);
      expect(restored.levelUpgradeDaysRemaining, 2);
      expect(restored.pendingTargetLevel, 3);
    });
  });

  group('GameProvider Side Business Upgrade Actions & Rush Flow Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
    });

    tearDown(() {
      container.dispose();
    });

    test('upgradeSideBusiness starts level upgrade and deducts cost', () {
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(balance: 500000.0);

      final carWash = notifier.state.sideBusinesses.firstWhere(
        (b) => b.type == SideBusinessType.carWash,
      );

      notifier.buySideBusiness(carWash.id);
      notifier.completeSideBusinessConstruction(carWash.id);

      final initialCost = notifier.state.sideBusinesses
          .firstWhere((b) => b.id == carWash.id)
          .nextLevelUpgradeCost;
      final initialBalance = notifier.state.balance;

      final upgradeSuccess = notifier.upgradeSideBusiness(carWash.id);
      expect(upgradeSuccess, true);

      final upgradedWash = notifier.state.sideBusinesses
          .firstWhere((b) => b.id == carWash.id);

      expect(upgradedWash.isUpgradingLevel, true);
      expect(upgradedWash.levelUpgradeDaysRemaining, 1);
      expect(upgradedWash.pendingTargetLevel, 2);
      expect(upgradedWash.level, 1);
      expect(notifier.state.balance, initialBalance - initialCost);
    });

    test('completeSideBusinessLevelUpgrade instantly finalizes level promotion', () {
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(balance: 500000.0);

      final carWash = notifier.state.sideBusinesses.firstWhere(
        (b) => b.type == SideBusinessType.carWash,
      );

      notifier.buySideBusiness(carWash.id);
      notifier.completeSideBusinessConstruction(carWash.id);
      notifier.upgradeSideBusiness(carWash.id);

      final rushSuccess =
          notifier.completeSideBusinessLevelUpgrade(carWash.id);
      expect(rushSuccess, true);

      final finalizedWash = notifier.state.sideBusinesses
          .firstWhere((b) => b.id == carWash.id);

      expect(finalizedWash.isUpgradingLevel, false);
      expect(finalizedWash.levelUpgradeDaysRemaining, 0);
      expect(finalizedWash.level, 2);
    });

    test('buySideBusinessUpgrade starts sub-upgrade installation with 1 day duration', () {
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(balance: 500000.0);

      final carWash = notifier.state.sideBusinesses.firstWhere(
        (b) => b.type == SideBusinessType.carWash,
      );

      notifier.buySideBusiness(carWash.id);
      notifier.completeSideBusinessConstruction(carWash.id);

      final firstUpgrade = carWash.upgrades.first;
      final buyUpgradeSuccess =
          notifier.buySideBusinessUpgrade(carWash.id, firstUpgrade.id);
      expect(buyUpgradeSuccess, true);

      final wash = notifier.state.sideBusinesses
          .firstWhere((b) => b.id == carWash.id);
      final upgradedItem =
          wash.upgrades.firstWhere((u) => u.id == firstUpgrade.id);

      expect(upgradedItem.isPurchased, true);
      expect(upgradedItem.isUpgrading, true);
      expect(upgradedItem.upgradeDaysRemaining, 1);
      expect(upgradedItem.isOperational, false);
    });

    test('completeSideBusinessSubUpgrade instantly finishes sub-upgrade installation', () {
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(balance: 500000.0);

      final carWash = notifier.state.sideBusinesses.firstWhere(
        (b) => b.type == SideBusinessType.carWash,
      );

      notifier.buySideBusiness(carWash.id);
      notifier.completeSideBusinessConstruction(carWash.id);

      final firstUpgrade = carWash.upgrades.first;
      notifier.buySideBusinessUpgrade(carWash.id, firstUpgrade.id);

      final rushSuccess = notifier.completeSideBusinessSubUpgrade(
          carWash.id, firstUpgrade.id);
      expect(rushSuccess, true);

      final wash = notifier.state.sideBusinesses
          .firstWhere((b) => b.id == carWash.id);
      final upgradedItem =
          wash.upgrades.firstWhere((u) => u.id == firstUpgrade.id);

      expect(upgradedItem.isPurchased, true);
      expect(upgradedItem.isUpgrading, false);
      expect(upgradedItem.upgradeDaysRemaining, 0);
      expect(upgradedItem.isOperational, true);
    });

    test('Advancing game days automatically completes level and sub-upgrades', () {
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(balance: 1000000.0);

      final carWash = notifier.state.sideBusinesses.firstWhere(
        (b) => b.type == SideBusinessType.carWash,
      );

      notifier.buySideBusiness(carWash.id);
      notifier.completeSideBusinessConstruction(carWash.id);

      notifier.upgradeSideBusiness(carWash.id);

      final firstUpgrade = carWash.upgrades.first;
      notifier.buySideBusinessUpgrade(carWash.id, firstUpgrade.id);

      notifier.advanceGameDay();

      final washState = notifier.state.sideBusinesses
          .firstWhere((b) => b.id == carWash.id);

      expect(washState.isUpgradingLevel, false);
      expect(washState.level, 2);

      final upgradeState =
          washState.upgrades.firstWhere((u) => u.id == firstUpgrade.id);
      expect(upgradeState.isUpgrading, false);
      expect(upgradeState.isOperational, true);
    });
  });
}
