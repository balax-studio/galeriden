import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/domain/usecases/collection_album_engine.dart';
import 'package:galeriden/domain/usecases/negotiation_engine.dart';
import 'package:galeriden/domain/usecases/rival_leaderboard_engine.dart';
import 'package:galeriden/domain/usecases/weekly_event_engine.dart';

void main() {
  group('Kademe 3: Prestige, Collection Album, Rival Leaderboard & Dynamic Calendar', () {
    late DealershipModel baseDealership;
    late CarModel sampleCar;

    setUp(() {
      baseDealership = DealershipModel.initial();
      sampleCar = CarModel(
        id: 'car_k3_1',
        brand: 'Merso',
        modelName: 'C200d AMG',
        modelYear: 2021,
        bodyType: 'Sedan',
        colorHex: '0xFFFFFFFF',
        baseMarketValue: 1200000.0,
        currentPurchasePrice: 1000000.0,
        customListingPrice: 1250000.0,
        expertise: ExpertiseReport(
          engineCondition: 100,
          transmissionCondition: 100,
          tramerAmount: 0,
          mileage: 40000,
          isMileageTampered: false,
          bodyParts: const {},
        ),
      );
    });

    test('CollectionAlbumEngine records discovered cars and computes milestone rewards', () {
      final discoveredIds = <String>{'merso_c200d', 'bemeve_320i', 'tofas_sahin'};
      final progress = CollectionAlbumEngine.calculateAlbumProgress(
        discoveredCarIds: discoveredIds.toList(),
        totalCatalogCarsCount: 30,
      );

      expect(progress.discoveredCount, equals(3));
      expect(progress.completionPercentage, closeTo(0.10, 0.01));
      
      final reward = CollectionAlbumEngine.getMilestoneReward(progress.discoveredCount);
      expect(reward, isNotNull);
    });

    test('RivalLeaderboardEngine ranks player against regional NPC dealerships', () {
      final playerDealership = baseDealership.copyWith(
        dealershipName: 'Apex Galeri',
        carsSold: 25,
        totalProfit: 2500000.0,
        reputationScore: 140,
      );

      final leaderboard = RivalLeaderboardEngine.getLeaderboard(
        playerDealership: playerDealership,
        currentDay: 15,
      );

      expect(leaderboard.length, equals(6)); // Player + 5 NPC rivals
      expect(leaderboard.any((entry) => entry.isPlayer), isTrue);
      
      // Sorted descending by total score / turnover
      for (int i = 0; i < leaderboard.length - 1; i++) {
        expect(leaderboard[i].turnoverScore, greaterThanOrEqualTo(leaderboard[i + 1].turnoverScore));
      }
    });

    test('WeeklyEventEngine returns active dynamic event for in-game day', () {
      final mondayEvent = WeeklyEventEngine.getEventForDay(1); // Monday
      final fridayEvent = WeeklyEventEngine.getEventForDay(5); // Friday
      final sundayEvent = WeeklyEventEngine.getEventForDay(7); // Sunday

      expect(mondayEvent.id, equals('credit_ease_monday'));
      expect(fridayEvent.id, equals('friday_super_market'));
      expect(sundayEvent.id, equals('collector_sunday_auction'));
      expect(fridayEvent.visitorSpeedMultiplier, greaterThan(1.0));
    });

    test('Loyal Customer CRM gives bonus offers from known past buyers', () {
      final loyalBuyer = 'Mehmet Kaya';
      final offer = NegotiationEngine.generateLoyalCustomerOffer(
        car: sampleCar,
        customerName: loyalBuyer,
      );

      expect(offer.buyerName, equals(loyalBuyer));
      expect(offer.offeredAmount, greaterThanOrEqualTo(sampleCar.estimatedRealValue * 0.95));
      expect(offer.buyerMessage, contains('Tekrar'));
    });

    test('Prestige reset resets transient assets while boosting prestige multiplier and keeping album', () {
      final richDealership = baseDealership.copyWith(
        balance: 15000000.0,
        level: 8,
        ownedCars: [sampleCar],
        discoveredCarModelIds: ['merso_c200d', 'tofas_sahin'],
        prestigeLevel: 0,
        prestigeMultiplier: 1.0,
      );

      final prestiged = richDealership.performPrestigeReset();

      expect(prestiged.prestigeLevel, equals(1));
      expect(prestiged.prestigeMultiplier, closeTo(1.15, 0.01));
      expect(prestiged.balance, equals(150000.0));
      expect(prestiged.ownedCars, isEmpty);
      expect(prestiged.discoveredCarModelIds, contains('merso_c200d'));
      expect(prestiged.discoveredCarModelIds, contains('tofas_sahin'));
    });
  });
}
