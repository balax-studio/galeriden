import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/domain/usecases/season_engine.dart';

void main() {
  group('Weekly Season & Podium Engine Tests', () {
    test('SeasonEngine calculates valid ISO week ID', () {
      final testDate = DateTime.utc(2026, 9, 10);
      final seasonId = SeasonEngine.getSeasonId(testDate);
      expect(seasonId, greaterThan(202600));
      expect(seasonId, lessThan(202700));

      final start = SeasonEngine.getSeasonStartAt(testDate);
      final end = SeasonEngine.getSeasonEndAt(testDate);
      expect(start.weekday, DateTime.monday);
      expect(end.isAfter(start), isTrue);
    });

    test('SeasonEngine generates correct perks for all podium ranks', () {
      final rank1Perks = SeasonEngine.generatePodiumPerks(rank: 1, seasonId: 202636);
      expect(rank1Perks.rank, 1);
      expect(rank1Perks.notaryDiscountRate, 0.50);
      expect(rank1Perks.hasCustomsAuctionPass, isTrue);
      expect(rank1Perks.hasGulfBuyerNetwork, isTrue);
      expect(rank1Perks.customPlateTitle, '34 KRAL 01');
      expect(rank1Perks.isActive, isTrue);

      final rank2Perks = SeasonEngine.generatePodiumPerks(rank: 2, seasonId: 202636);
      expect(rank2Perks.rank, 2);
      expect(rank2Perks.notaryDiscountRate, 0.30);
      expect(rank2Perks.hasFleetLiquidationProtocol, isTrue);
      expect(rank2Perks.hasInspectionTransparency, isTrue);
      expect(rank2Perks.customPlateTitle, '06 USTA 02');

      final rank3Perks = SeasonEngine.generatePodiumPerks(rank: 3, seasonId: 202636);
      expect(rank3Perks.rank, 3);
      expect(rank3Perks.notaryDiscountRate, 0.15);
      expect(rank3Perks.hasMasterMechanicVoucher, isTrue);
      expect(rank3Perks.hasShowcaseBoost, isTrue);
      expect(rank3Perks.customPlateTitle, '35 ESNAF 03');

      final runnerPerks = SeasonEngine.generatePodiumPerks(rank: 5, seasonId: 202636);
      expect(runnerPerks.rank, 5);
      expect(runnerPerks.freeNoterVouchers, 2);
    });

    test('SeasonEngine creates permanent trophy for top 3 ranks', () {
      final goldTrophy = SeasonEngine.createPodiumTrophy(rank: 1, seasonId: 202636);
      expect(goldTrophy, isNotNull);
      expect(goldTrophy!.rank, 1);
      expect(goldTrophy.id, 'trophy_202636_rank1');

      final silverTrophy = SeasonEngine.createPodiumTrophy(rank: 2, seasonId: 202636);
      expect(silverTrophy, isNotNull);
      expect(silverTrophy!.rank, 2);

      final bronzeTrophy = SeasonEngine.createPodiumTrophy(rank: 3, seasonId: 202636);
      expect(bronzeTrophy, isNotNull);
      expect(bronzeTrophy!.rank, 3);

      final runnerTrophy = SeasonEngine.createPodiumTrophy(rank: 4, seasonId: 202636);
      expect(runnerTrophy, isNull);
    });

    test('DealershipModel serializes and deserializes weekly season data seamlessly', () {
      final initial = DealershipModel.initial();
      expect(initial.currentSeasonId, 0);
      expect(initial.weeklyTurnoverScore, 0.0);
      expect(initial.earnedTrophies, isEmpty);

      final perks = SeasonEngine.generatePodiumPerks(rank: 1, seasonId: 202636);
      final trophy = SeasonEngine.createPodiumTrophy(rank: 1, seasonId: 202636)!;

      final updated = initial.copyWith(
        currentSeasonId: 202636,
        weeklyTurnoverScore: 450000.0,
        weeklyCarsSold: 5,
        hasUnclaimedSeasonRewards: true,
        lastClaimedSeasonRank: 1,
        activePodiumPerks: perks,
        earnedTrophies: [trophy],
      );

      final json = updated.toJson();
      final restored = DealershipModel.fromJson(json);

      expect(restored.currentSeasonId, 202636);
      expect(restored.weeklyTurnoverScore, 450000.0);
      expect(restored.weeklyCarsSold, 5);
      expect(restored.hasUnclaimedSeasonRewards, isTrue);
      expect(restored.lastClaimedSeasonRank, 1);
      expect(restored.activePodiumPerks, isNotNull);
      expect(restored.activePodiumPerks!.rank, 1);
      expect(restored.activePodiumPerks!.customPlateTitle, '34 KRAL 01');
      expect(restored.earnedTrophies.length, 1);
      expect(restored.earnedTrophies.first.id, 'trophy_202636_rank1');
    });

    test('Season settlement rollover behavior', () {
      final dealership = DealershipModel.initial().copyWith(
        currentSeasonId: 202635,
      );

      final now = DateTime.utc(2026, 9, 10); // Week 37 (202637)
      expect(SeasonEngine.shouldSettleSeason(dealership, now), isTrue);

      final uninitialized = DealershipModel.initial();
      expect(SeasonEngine.needsSeasonInit(uninitialized), isTrue);
      expect(SeasonEngine.shouldSettleSeason(uninitialized, now), isFalse);
    });

    test('ActivePodiumPerks isActive returns false when expired', () {
      final now = DateTime.now();
      final activePerks = SeasonEngine.generatePodiumPerks(rank: 1, seasonId: 202636);
      expect(activePerks.isActive, isTrue);

      final expiredPerks = activePerks.copyWith(
        expiresAt: now.subtract(const Duration(hours: 1)),
      );
      expect(expiredPerks.isActive, isFalse);
    });

    test('Podium perks configuration integrity for each tier', () {
      final tier1 = SeasonEngine.generatePodiumPerks(rank: 1, seasonId: 202636);
      expect(tier1.hasCustomsAuctionPass, isTrue);
      expect(tier1.hasGulfBuyerNetwork, isTrue);
      expect(tier1.notaryDiscountRate, 0.50);

      final tier2 = SeasonEngine.generatePodiumPerks(rank: 2, seasonId: 202636);
      expect(tier2.hasFleetLiquidationProtocol, isTrue);
      expect(tier2.hasInspectionTransparency, isTrue);
      expect(tier2.notaryDiscountRate, 0.30);

      final tier3 = SeasonEngine.generatePodiumPerks(rank: 3, seasonId: 202636);
      expect(tier3.hasMasterMechanicVoucher, isTrue);
      expect(tier3.hasShowcaseBoost, isTrue);
      expect(tier3.notaryDiscountRate, 0.15);

      final runner = SeasonEngine.generatePodiumPerks(rank: 8, seasonId: 202636);
      expect(runner.freeNoterVouchers, 2);
    });
  });
}
