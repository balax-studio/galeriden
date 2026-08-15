import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/domain/usecases/rival_leaderboard_engine.dart';

void main() {
  group('Dynamic RivalLeaderboardEngine Tests', () {
    test('Player does NOT start at fixed rank #6 on Day 1 with fresh dealership', () {
      final initialDealership = DealershipModel.initial().copyWith(
        dealershipName: 'Benim Galerim',
        balance: 100000.0,
        carsSold: 0,
        totalProfit: 0.0,
        reputationScore: 50,
      );

      final leaderboard = RivalLeaderboardEngine.getLeaderboard(
        playerDealership: initialDealership,
        currentDay: 1,
      );

      expect(leaderboard.length, equals(6));
      final playerEntry = leaderboard.firstWhere((e) => e.isPlayer);
      
      // Player should start dynamically around rank 4 or 5, not stuck at 6
      expect(playerEntry.rank, isIn([3, 4, 5]));
    });

    test('Rival scores scale organically as player earns money and sells vehicles (Rubber-banding)', () {
      final starterGame = DealershipModel.initial().copyWith(
        balance: 150000.0,
        carsSold: 2,
        totalProfit: 50000.0,
        reputationScore: 60,
      );

      final starterLeaderboard = RivalLeaderboardEngine.getLeaderboard(
        playerDealership: starterGame,
        currentDay: 3,
      );

      final bogaziciStarter = starterLeaderboard.firstWhere((e) => e.name == 'Boğaziçi Otomotiv');

      // Pro Dealership with 5M+ net worth
      final richCar = CarModel(
        id: 'car_rich_1',
        brand: 'Porsche',
        modelName: '911 Carrera',
        modelYear: 2023,
        bodyType: 'Coupe',
        colorHex: '#000000',
        baseMarketValue: 4500000.0,
        currentPurchasePrice: 4000000.0,
        expertise: ExpertiseReport(
          engineCondition: 98,
          transmissionCondition: 98,
          tramerAmount: 0,
          mileage: 12000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );

      final proGame = starterGame.copyWith(
        balance: 2000000.0,
        carsSold: 28,
        totalProfit: 3500000.0,
        reputationScore: 180,
        ownedCars: [richCar],
      );

      final proLeaderboard = RivalLeaderboardEngine.getLeaderboard(
        playerDealership: proGame,
        currentDay: 15,
      );

      final bogaziciPro = proLeaderboard.firstWhere((e) => e.name == 'Boğaziçi Otomotiv');

      // Rivals should scale their performance up as player grows ("biz kazandıkça onlar da kazansın")
      expect(bogaziciPro.turnoverScore, greaterThan(bogaziciStarter.turnoverScore));
      expect(bogaziciPro.carsSold, greaterThan(bogaziciStarter.carsSold));
    });

    test('Near-Miss Info provides clear motivational distance to rival directly ahead', () {
      final playerDealership = DealershipModel.initial().copyWith(
        dealershipName: 'Zafer Plaza',
        balance: 300000.0,
        carsSold: 5,
        totalProfit: 180000.0,
        reputationScore: 75,
      );

      final leaderboard = RivalLeaderboardEngine.getLeaderboard(
        playerDealership: playerDealership,
        currentDay: 5,
      );

      final nearMiss = RivalLeaderboardEngine.getNearMissInfo(leaderboard);

      expect(nearMiss.playerRank, inInclusiveRange(1, 6));
      expect(nearMiss.motivationMessage.isNotEmpty, isTrue);

      if (nearMiss.playerRank > 1) {
        expect(nearMiss.targetRivalName, isNotNull);
        expect(nearMiss.scoreDifference, greaterThan(0.0));
      } else {
        expect(nearMiss.isLeader, isTrue);
      }
    });

    test('Day-based market fluctuations produce dynamic rank change indications', () {
      final game = DealershipModel.initial().copyWith(
        balance: 250000.0,
        carsSold: 4,
        totalProfit: 120000.0,
        reputationScore: 70,
      );

      final day5Leaderboard = RivalLeaderboardEngine.getLeaderboard(
        playerDealership: game,
        currentDay: 5,
      );

      // Verify entries have rankChange and valid taglines
      for (final entry in day5Leaderboard) {
        expect(entry.tagline.isNotEmpty, isTrue);
        expect(entry.rankChange, isIn([-5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5]));
      }
    });
  });
}
