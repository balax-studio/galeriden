import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/branch_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/domain/usecases/cashflow_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('8-Tier Authentic Dealership & Plaza Expansion Tests', () {
    test('BranchModel.getAllBranches returns exactly 8 tiers with calibrated progression', () {
      final branches = BranchModel.getAllBranches();
      expect(branches.length, equals(8));

      // Check IDs
      for (int i = 1; i <= 8; i++) {
        expect(branches[i - 1].id, equals('branch_$i'));
        expect(branches[i - 1].targetLevel, equals(i));
      }

      // Check slot progression
      expect(branches[0].maxGarageSlots, equals(3));
      expect(branches[1].maxGarageSlots, equals(4));
      expect(branches[2].maxGarageSlots, equals(6));
      expect(branches[3].maxGarageSlots, equals(8));
      expect(branches[4].maxGarageSlots, equals(10));
      expect(branches[5].maxGarageSlots, equals(13));
      expect(branches[6].maxGarageSlots, equals(16));
      expect(branches[7].maxGarageSlots, equals(20));

      // Check authentic non-locational names
      expect(branches[0].name, contains('Ayakçı'));
      expect(branches[1].name, contains('Mahalle'));
      expect(branches[2].name, contains('Sanayi'));
      expect(branches[3].name, contains('Butik'));
      expect(branches[4].name, contains('Oto Center'));
      expect(branches[5].name, contains('Premium'));
      expect(branches[6].name, contains('Koleksiyoner'));
      expect(branches[7].name, contains('Holding'));

      // Ensure no specific geographic district names in titles
      final forbiddenLocations = ['ikitelli', 'maslak', 'levent', 'boğaz', 'etiler', 'kadıköy', 'bodrum'];
      for (final b in branches) {
        for (final loc in forbiddenLocations) {
          expect(b.name.toLowerCase().contains(loc), isFalse, reason: '${b.name} contains forbidden location $loc');
        }
      }
    });

    test('Dual-gate branch upgrade fails if level is insufficient', () {
      final notifier = GameNotifier();
      notifier.addCheatFunds(50000000.0); // Plenty of money, but level is 1
      expect(notifier.state.level, equals(1));

      final branches = BranchModel.getAllBranches(
        currentSlotCount: notifier.state.maxGarageSlots,
        currentLevel: notifier.state.level,
      );

      final branch2 = branches[1]; // Requires level 2
      final success = notifier.upgradeBranch(branch2);
      expect(success, isFalse);
    });

    test('Dual-gate branch upgrade fails if balance is insufficient', () {
      final notifier = GameNotifier();
      // Level is set to 2, but balance is 0
      notifier.state = notifier.state.copyWith(level: 2, balance: 0.0);

      final branches = BranchModel.getAllBranches(
        currentSlotCount: notifier.state.maxGarageSlots,
        currentLevel: notifier.state.level,
      );

      final branch2 = branches[1]; // Requires 100,000 TL
      final success = notifier.upgradeBranch(branch2);
      expect(success, isFalse);
    });

    test('Sequential upgrade through all 8 tiers unlocks slots, property tiers and services', () {
      final notifier = GameNotifier();
      notifier.addCheatFunds(100000000.0);

      for (int targetTier = 2; targetTier <= 8; targetTier++) {
        // Elevate level to meet requirement
        notifier.state = notifier.state.copyWith(level: targetTier);

        final branches = BranchModel.getAllBranches(
          currentSlotCount: notifier.state.maxGarageSlots,
          currentLevel: notifier.state.level,
          unlockedBuildings: notifier.state.unlockedBuildings,
        );
        final branch = branches[targetTier - 1];

        final success = notifier.upgradeBranch(branch);
        expect(success, isTrue, reason: 'Failed to upgrade to branch tier $targetTier');
        expect(notifier.state.maxGarageSlots, equals(branch.maxGarageSlots));
        expect(notifier.state.unlockedBuildings.contains('property_tier_$targetTier'), isTrue);
      }

      // Check that critical routes are unlocked in state
      expect(notifier.state.unlockedBuildings.contains('/workshop'), isTrue);
      expect(notifier.state.unlockedBuildings.contains('/tuning-studio'), isTrue);
      expect(notifier.state.unlockedBuildings.contains('/auction'), isTrue);
      expect(notifier.state.unlockedBuildings.contains('/stock-market'), isTrue);
      expect(notifier.state.unlockedBuildings.contains('/rent-a-car'), isTrue);
      expect(notifier.state.unlockedBuildings.contains('/scrapyard'), isTrue);
      expect(notifier.state.unlockedBuildings.contains('/side-businesses'), isTrue);
    });

    test('CashflowEngine calculates property daily burn according to highest tier 1..8', () {
      final notifier = GameNotifier();

      // Tier 1 default burn
      final cf1 = CashflowEngine.calculate(notifier.state);
      expect(cf1.totalDailyExpense, greaterThanOrEqualTo(300.0));

      // Tier 8 burn
      final tier8Buildings = Set<String>.from(notifier.state.unlockedBuildings)..add('property_tier_8');
      final stateTier8 = notifier.state.copyWith(unlockedBuildings: tier8Buildings);
      final cf8 = CashflowEngine.calculate(stateTier8);
      expect(cf8.totalDailyExpense, greaterThanOrEqualTo(75000.0));
    });

    test('DealershipModel maps routes and branch names across 8 tiers', () {
      expect(DealershipModel.getRequiredLevel('/marketplace'), equals(1));
      expect(DealershipModel.getRequiredLevel('/car-wash'), equals(2));
      expect(DealershipModel.getRequiredLevel('/workshop'), equals(3));
      expect(DealershipModel.getRequiredLevel('/tuning-studio'), equals(4));
      expect(DealershipModel.getRequiredLevel('/auction'), equals(5));
      expect(DealershipModel.getRequiredLevel('/stock-market'), equals(6));
      expect(DealershipModel.getRequiredLevel('/rent-a-car'), equals(7));
      expect(DealershipModel.getRequiredLevel('/scrapyard'), equals(8));

      // Check required branch names are non-empty and descriptive
      final bName3 = DealershipModel.getRequiredBranchName('/workshop');
      expect(bName3, contains('Sanayi'));
      final bName8 = DealershipModel.getRequiredBranchName('/scrapyard');
      expect(bName8, contains('Holding'));
    });
  });
}
