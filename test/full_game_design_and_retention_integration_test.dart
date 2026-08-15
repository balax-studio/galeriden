import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/staff_model.dart';
import 'package:galeriden/domain/usecases/psychology_engine.dart';
import 'package:galeriden/domain/usecases/weekly_event_engine.dart';
import 'package:galeriden/domain/usecases/rival_leaderboard_engine.dart';
import 'package:galeriden/domain/usecases/collection_album_engine.dart';

void main() {
  group('Full Game Design & Retention Psychology Implementation Tests', () {
    test('Initial dealership has clean salesHistory without mock transactions', () {
      final initialGame = DealershipModel.initial();
      expect(initialGame.salesHistory, isEmpty);
      expect(initialGame.carsSold, 0);
    });

    test('WeeklyEventEngine returns correct Day 1 to Day 7 events with multiplier logic', () {
      final mondayEvent = WeeklyEventEngine.getEventForDay(1);
      expect(mondayEvent.dayOfWeek, 1);
      expect(mondayEvent.discountMultiplier, lessThan(1.0));

      final wednesdayEvent = WeeklyEventEngine.getEventForDay(3);
      expect(wednesdayEvent.dayOfWeek, 3);
      expect(wednesdayEvent.discountMultiplier, lessThan(1.0));

      final weekendEvent = WeeklyEventEngine.getEventForDay(6);
      expect(weekendEvent.dayOfWeek, 6);
      expect(weekendEvent.visitorSpeedMultiplier, greaterThan(1.0));
    });

    test('PsychologyEngine generates rich open loops summary for dashboard and exit hook', () {
      final summary = PsychologyEngine.getOpenLoopsSummary(
        pendingOrdersCount: 2,
        showroomListedCarsCount: 3,
        currentStreak: 4,
      );

      expect(summary.containsKey('items'), isTrue);
      expect(summary['items'], isA<List<String>>());
      expect(summary['tomorrowStreak'], 5);
    });

    test('CollectionAlbumEngine computes 30-car album statistics correctly', () {
      final album = CollectionAlbumEngine.calculateAlbumProgress(
        discoveredCarIds: ['sedan_1', 'suv_1', 'hatchback_1'],
      );

      expect(album.totalCatalogCarsCount, 30);
      expect(album.discoveredCount, 3);
      expect(album.completionPercentage, closeTo(0.1, 0.01));
      expect(CollectionAlbumEngine.getMilestoneReward(3), 15000);
    });

    test('RivalLeaderboardEngine integrates player smoothly among regional competitors', () {
      final playerDealership = DealershipModel.initial().copyWith(
        dealershipName: 'Balax Galeri',
        totalProfit: 500000.0,
        reputationScore: 85,
        carsSold: 12,
      );

      final leaderboard = RivalLeaderboardEngine.getLeaderboard(
        playerDealership: playerDealership,
        currentDay: 5,
      );

      expect(leaderboard.length, 6);
      expect(leaderboard.any((e) => e.isPlayer), isTrue);
      final playerEntry = leaderboard.firstWhere((e) => e.isPlayer);
      expect(playerEntry.name, 'Balax Galeri');
      expect(playerEntry.rank, inInclusiveRange(1, 6));
    });

    test('Emergency bailout formula correctly sums balance, bank deposit, and vehicle asset value', () {
      final car = CarModel(
        id: 'car_test_1',
        brand: 'Renault',
        modelName: 'Clio',
        modelYear: 2020,
        bodyType: 'Hatchback',
        colorHex: '#FFFFFF',
        baseMarketValue: 250000,
        currentPurchasePrice: 200000,
        expertise: ExpertiseReport(
          engineCondition: 90,
          transmissionCondition: 90,
          mileage: 40000,
          tramerAmount: 0,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );

      final state = DealershipModel.initial().copyWith(
        balance: 5000,
        bankDepositBalance: 10000,
        ownedCars: [car],
      );

      // Total wealth = 5000 + 10000 + 232500 = 247500 >= 30000 -> Bailout not needed
      final totalWealth = state.balance +
          state.bankDepositBalance +
          state.ownedCars.fold<double>(0.0, (s, c) => s + c.estimatedRealValue);

      expect(totalWealth, greaterThan(200000));
      expect(totalWealth < 30000, isFalse);
    });

    test('StaffRole salary extension values match realistic overhead standards', () {
      expect(StaffRole.washer.dailySalary, 1200);
      expect(StaffRole.apprentice.dailySalary, 1800);
      expect(StaffRole.salesman.dailySalary, 2500);
      expect(StaffRole.masterMechanic.dailySalary, 3500);
    });
  });
}
