import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/side_business_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

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
      expect(business.purchasedUpgradeCount, 1); // Only up_2 is counted as operational

      // Progress 1 day
      final progressed = business.copyWith(
        levelUpgradeDaysRemaining: 1,
      );
      expect(progressed.levelUpgradeProgress, 0.5);

      // JSON round trip
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

      // First own and complete construction
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
      expect(upgradedWash.levelUpgradeDaysRemaining, 1); // Level 1 -> 2 takes 1 day
      expect(upgradedWash.pendingTargetLevel, 2);
      expect(upgradedWash.level, 1); // Not upgraded yet
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

      // Start level upgrade (Level 1 -> 2: 1 day)
      notifier.upgradeSideBusiness(carWash.id);

      // Start sub-upgrade (1 day)
      final firstUpgrade = carWash.upgrades.first;
      notifier.buySideBusinessUpgrade(carWash.id, firstUpgrade.id);

      // Advance 1 day
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
