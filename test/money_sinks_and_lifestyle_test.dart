import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/data/models/branch_model.dart';
import 'package:galeriden/data/models/lifestyle_item_model.dart';
import 'package:galeriden/data/models/pr_campaign_model.dart';
import 'package:galeriden/domain/usecases/auction_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Money Sinks & Lifestyle Engine Tests', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Branch Deed purchase zeroes daily rent and expands bank credit limit', () {
      final notifier = container.read(gameProvider.notifier);
      notifier.addMoney(20000000.0); // 20M TL

      final branchesBefore = BranchModel.getAllBranches(
        ownedDeeds: container.read(gameProvider).ownedBranchDeeds,
      );
      final branch3 = branchesBefore.firstWhere((b) => b.id == 'branch_3');
      expect(branch3.isDeedOwned, isFalse);
      expect(branch3.dailyBurnRate, equals(1800.0));

      final initialCreditLimit = container.read(gameProvider).bankCreditLimit;

      // Buy Deed
      final success = notifier.buyBranchDeed(branch3);
      expect(success, isTrue);

      final stateAfter = container.read(gameProvider);
      expect(stateAfter.ownedBranchDeeds.contains('branch_3'), isTrue);
      expect(stateAfter.bankCreditLimit, equals(initialCreditLimit + (branch3.deedCost * 0.35)));

      final branchesAfter = BranchModel.getAllBranches(
        ownedDeeds: stateAfter.ownedBranchDeeds,
      );
      final branch3After = branchesAfter.firstWhere((b) => b.id == 'branch_3');
      expect(branch3After.isDeedOwned, isTrue);
      expect(branch3After.dailyBurnRate, equals(0.0)); // Rent is now zero!
    });

    test('Media PR Agency campaign starts and applies dynamic boosts', () {
      final notifier = container.read(gameProvider.notifier);
      notifier.addMoney(5000000.0);

      final campaign = PrCampaignModel.campaigns.firstWhere((c) => c.id == 'pr_youtube_influencer');
      final initialReputation = container.read(gameProvider).reputationScore;

      final success = notifier.startPrCampaign(campaign);
      expect(success, isTrue);

      final state = container.read(gameProvider);
      expect(state.activePrCampaign, isNotNull);
      expect(state.activePrCampaign!.campaignId, equals('pr_youtube_influencer'));
      expect(state.activePrCampaign!.isActive(state.currentDay), isTrue);
      expect(state.activePrCampaign!.customerFlowMultiplier, equals(2.0));
      expect(state.activePrCampaign!.offerPriceBoost, equals(0.10));
      expect(state.activePrCampaign!.remainingDays(state.currentDay), equals(3));
      expect(state.reputationScore, equals(initialReputation + campaign.reputationReward));
    });

    test('Lifestyle Wardrobe items purchase, equipping, and passive bonus aggregation with diminishing returns', () {
      final notifier = container.read(gameProvider.notifier);
      notifier.addMoney(10000000.0);

      final royalSuit = LifestyleItemModel.allItems.firstWhere((i) => i.id == 'suit_royal_smoking');
      final diamondWatch = LifestyleItemModel.allItems.firstWhere((i) => i.id == 'acc_diamond_tourbillon');

      // Buy both categories
      expect(notifier.buyLifestyleItem(royalSuit), isTrue);
      expect(notifier.buyLifestyleItem(diamondWatch), isTrue);

      final state = container.read(gameProvider);
      expect(state.ownedLifestyleItems.contains(royalSuit.id), isTrue);
      expect(state.ownedLifestyleItems.contains(diamondWatch.id), isTrue);

      expect(state.equippedSuitId, equals(royalSuit.id));
      expect(state.equippedAccessoryId, equals(diamondWatch.id));

      // Check cumulative bonuses with diminishing returns
      // Raw: 0.08 + 0.06 = 0.14 -> Diminishing: 0.14 / (1 + 0.14 * 1.5) = ~0.1157 (Capped under 0.12)
      expect(state.lifestyleNegotiationBonus, closeTo(0.1157, 0.005));
      expect(state.lifestyleNegotiationBonus, lessThanOrEqualTo(0.12));

      // Royal suit (0.15) + Diamond watch (0.20) = 0.35
      expect(state.lifestyleRichCustomerBonus, closeTo(0.35, 0.001));

      // Diamond watch (0.08) = 0.08
      expect(state.lifestyleInterestDiscount, closeTo(0.08, 0.001));
    });

    test('VIP Auction generates high-end rare supercars and elite rivals', () {
      final vipAuction = AuctionEngine.createVipAuction(playerLevel: 8);

      expect(vipAuction.car, isNotNull);
      expect(vipAuction.car.isRare, isTrue);
      expect(vipAuction.car.baseMarketValue, greaterThanOrEqualTo(5000000.0));
      expect(vipAuction.startingPrice, greaterThanOrEqualTo(2500000.0));
      expect(vipAuction.rivals.length, equals(3));
      expect(vipAuction.customsNote.trunkLoot.value, equals(250000.0));
    });
  });
}
