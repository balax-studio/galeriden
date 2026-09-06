import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/branch_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('A5, B1, B2: Branch Upgrade, Deed Immunity & Profit Multipliers Audit', () {
    test('A5: Sequential upgrade requirement prevents jumping tiers', () {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final branches = BranchModel.getAllBranches();
      final branchTier3 = branches.firstWhere((b) => b.targetLevel == 3);
      final branchTier2 = branches.firstWhere((b) => b.targetLevel == 2);

      // Starting dealership is tier 1 with high balance & level
      final notifier = container.read(gameProvider.notifier);
      notifier.state = DealershipModel.initial().copyWith(
        balance: 10000000.0,
        level: 10,
      );

      // Attempting to upgrade to Tier 3 directly from Tier 1 must fail
      final jumped = notifier.upgradeBranch(branchTier3);
      expect(jumped, isFalse, reason: 'Cannot jump from Tier 1 to Tier 3');
      expect(container.read(gameProvider).currentBranchTier, equals(1));

      // Upgrading sequentially to Tier 2 succeeds
      final upgradedTier2 = notifier.upgradeBranch(branchTier2);
      expect(upgradedTier2, isTrue, reason: 'Upgrading from Tier 1 to Tier 2 is sequential and valid');
      expect(container.read(gameProvider).currentBranchTier, equals(2));
    });

    test('A5: Garage slots are not downgraded if previously expanded', () {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final notifier = container.read(gameProvider.notifier);
      // Artificially simulate 10 garage slots via perks/prestige
      notifier.state = DealershipModel.initial().copyWith(
        balance: 10000000.0,
        level: 10,
        maxGarageSlots: 10,
      );
      expect(container.read(gameProvider).maxGarageSlots, equals(10));

      final branchTier2 = BranchModel.getAllBranches().firstWhere((b) => b.targetLevel == 2);
      // branchTier2 has maxGarageSlots: 4
      final upgraded = notifier.upgradeBranch(branchTier2);
      expect(upgraded, isTrue);
      // maxGarageSlots must remain 10, not downgraded to 4
      expect(container.read(gameProvider).maxGarageSlots, equals(10));
    });

    test('B1: Deed ownership grants base rent immunity for owned branch tier', () {
      // Tier 1 dealership without deed: base rent 300 TL, 0 dues -> 300 TL burn
      final rentedDealership = DealershipModel.initial();
      expect(rentedDealership.dailyPropertyRentBurn, equals(300.0));

      // Tier 1 dealership with deed: base rent 0 TL, 1 deed dues 1250 TL -> 1250 TL burn
      final deedDealership = rentedDealership.copyWith(
        ownedBranchDeeds: {'branch_1'},
      );
      expect(deedDealership.dailyPropertyRentBurn, equals(1250.0));

      // Tier 2 dealership without deed_2: base rent 750 TL + 1250 TL (for branch_1 deed) = 2000 TL
      final tier2WithDeed1 = rentedDealership.copyWith(
        unlockedBuildings: {'property_tier_2'},
        ownedBranchDeeds: {'branch_1'},
      );
      expect(tier2WithDeed1.dailyPropertyRentBurn, equals(750.0 + 1250.0));

      // Tier 2 dealership with both deeds: base rent 0 TL + 2 * 1250 TL = 2500 TL
      final tier2WithBothDeeds = rentedDealership.copyWith(
        unlockedBuildings: {'property_tier_2'},
        ownedBranchDeeds: {'branch_1', 'branch_2'},
      );
      expect(tier2WithBothDeeds.dailyPropertyRentBurn, equals(2500.0));
    });

    test('B2: Branch profit multiplier scales with branch tier', () {
      final initial = DealershipModel.initial();
      expect(initial.branchProfitMultiplier, equals(1.00));

      final tier2 = initial.copyWith(unlockedBuildings: {'property_tier_2'});
      expect(tier2.branchProfitMultiplier, equals(1.10));

      final tier4 = initial.copyWith(unlockedBuildings: {'property_tier_2', 'property_tier_3', 'property_tier_4'});
      expect(tier4.branchProfitMultiplier, equals(1.40));

      final tier8 = initial.copyWith(unlockedBuildings: {'property_tier_8'});
      expect(tier8.branchProfitMultiplier, equals(2.50));
    });
  });
}
