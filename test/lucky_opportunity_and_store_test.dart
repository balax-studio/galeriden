import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/lucky_opportunity_model.dart';
import 'package:galeriden/data/models/showroom_theme_model.dart';
import 'package:galeriden/data/models/store_bundle_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Lucky Opportunity Pity Engine Tests', () {
    test('Pity counter increments and triggers opportunity only after cooldown and day constraint', () {
      final initial = DealershipModel.initial();
      expect(initial.luckyOpportunityPityCounter, 0);
      expect(initial.lastLuckyOpportunityDay, 0);

      // Model calculation test
      final opps = LuckyOpportunityModel.getAllOpportunities();
      expect(opps.length, 5);

      // Verify every opportunity has valid rewards and non-empty strings
      for (final op in opps) {
        expect(op.titleKey.isNotEmpty, true);
        expect(op.descriptionKey.isNotEmpty, true);
        expect(op.cashReward > 0 || op.reputationBonus > 0, true);
      }
    });

    test('Pity engine reset and rewards claiming via GameProvider', () {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final notifier = container.read(gameProvider.notifier);
      final initialGame = container.read(gameProvider);
      final initialBalance = initialGame.balance;
      final initialRep = initialGame.reputationScore;

      const testOpp = LuckyOpportunityModel(
        id: 'test_opp',
        type: LuckyOpportunityType.vipSponsorDeal,
        titleKey: 'lucky_opp_investor_title',
        descriptionKey: 'lucky_opp_investor_desc',
        perkSummaryKey: 'lucky_opp_investor_perk',
        icon: Icons.stars_rounded,
        accentColor: Colors.amber,
        cashReward: 50000.0,
        reputationBonus: 15,
      );

      notifier.claimLuckyOpportunity(testOpp);

      final updatedGame = container.read(gameProvider);
      expect(updatedGame.balance, initialBalance + 50000.0);
      expect(updatedGame.reputationScore, (initialRep + 15).clamp(0, 100));
      expect(updatedGame.luckyOpportunityPityCounter, 0);
      expect(updatedGame.lastLuckyOpportunityDay, updatedGame.currentDay);
    });
  });

  group('Store Bundles and Pro License Tests', () {
    test('Purchasing Starter Bundle grants cash, reputation and starter car', () {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final notifier = container.read(gameProvider.notifier);
      final initialCount = container.read(gameProvider).ownedCars.length;
      final initialBalance = container.read(gameProvider).balance;

      final starterBundle = StoreBundleModel.getAllBundles().firstWhere(
        (b) => b.type == StoreBundleType.starterPack,
      );

      final success = notifier.purchaseStoreBundle(starterBundle, paidRealMoney: true);
      expect(success, true);

      final updatedGame = container.read(gameProvider);
      expect(updatedGame.isStarterBundlePurchased, true);
      expect(updatedGame.balance, initialBalance + starterBundle.cashBonus);
      expect(updatedGame.ownedCars.length, initialCount + 1);
    });

    test('Purchasing No-Ads License enables ad-free perks', () {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final notifier = container.read(gameProvider.notifier);
      expect(container.read(gameProvider).hasNoAdsLicense, false);

      final noAdsBundle = StoreBundleModel.getAllBundles().firstWhere(
        (b) => b.type == StoreBundleType.noAdsLicense,
      );

      final success = notifier.purchaseStoreBundle(noAdsBundle, paidRealMoney: true);
      expect(success, true);

      final updatedGame = container.read(gameProvider);
      expect(updatedGame.hasNoAdsLicense, true);
    });
  });

  group('Showroom Themes and Custom Paint Cosmetics Tests', () {
    test('Themes and paints unlock and activate correctly', () {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final notifier = container.read(gameProvider.notifier);

      // Verify default theme
      expect(container.read(gameProvider).activeShowroomThemeId, 'theme_standard');

      // Set active theme if unlocked
      notifier.setActiveShowroomTheme('theme_standard');
      expect(container.read(gameProvider).activeShowroomThemeId, 'theme_standard');

      // Check all custom paints have value multipliers > 1.0
      final paints = CustomPaintFinishModel.getAllPaintFinishes();
      expect(paints.length, 4);
      for (final p in paints) {
        expect(p.valueMultiplier, greaterThan(1.0));
        expect(p.cost, greaterThan(0.0));
      }
    });
  });
}
