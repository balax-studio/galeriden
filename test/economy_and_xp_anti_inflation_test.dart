import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/player_skills.dart';
import 'package:galeriden/data/models/stock_model.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/domain/usecases/stock_market_engine.dart';
import 'package:galeriden/domain/usecases/offline_progression.dart';
import 'package:galeriden/domain/usecases/loan_settlement_engine.dart';
import 'package:galeriden/core/services/ad_reward_calculator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Economy & XP Anti-Inflation Hardening Tests', () {
    test('PlayerSkills XP curve prevents instant early level skips', () {
      expect(PlayerSkills.requiredXpForLevel(1), equals(1500));
      expect(PlayerSkills.requiredXpForLevel(2), equals(3750));
      expect(PlayerSkills.requiredXpForLevel(3), equals(7500));
      expect(PlayerSkills.requiredXpForLevel(4), equals(14000));
      expect(PlayerSkills.requiredXpForLevel(5), equals(24000));

      final skills = PlayerSkills(xp: 1200);
      expect(skills.currentLevel, equals(1));

      final skillsLvl2 = PlayerSkills(xp: 1600);
      expect(skillsLvl2.currentLevel, equals(2));
    });

    test('CarModel valuation clamps restored barn find to max 1.6x base market value', () {
      final baseCar = CarModel(
        id: 'test_barn_car',
        brand: 'Mercedes',
        modelName: '300 SL Gullwing',
        modelYear: 1957,
        bodyType: 'Klasik',
        colorHex: '0xFFFFFFFF',
        baseMarketValue: 1000000.0,
        currentPurchasePrice: 200000.0,
        isBarnFind: true,
        isBarnFindRestored: true,
        isBarnFindOriginalParts: true,
        expertise: ExpertiseReport(
          engineCondition: 100.0,
          transmissionCondition: 100.0,
          tramerAmount: 0,
          mileage: 50000,
          isMileageTampered: false,
          bodyParts: {
            'Kaput': PartStatus.original,
            'Tavan': PartStatus.original,
            'Sol Kapı': PartStatus.original,
            'Sağ Kapı': PartStatus.original,
            'Bagaj': PartStatus.original,
          },
          partConditions: {
            'Kaput': 100.0,
            'Tavan': 100.0,
            'Sol Kapı': 100.0,
            'Sağ Kapı': 100.0,
            'Bagaj': 100.0,
          },
        ),
      );

      final realVal = baseCar.estimatedRealValue;
      expect(realVal, lessThanOrEqualTo(1000000.0 * 1.6));
    });

    test('StockMarketEngine IPO settlement includes dynamic risk variance', () {
      const ipo = IpoOfferModel(
        id: 'ipo_test_1',
        companyName: 'Akıncı Batarya',
        symbol: 'AKBAT',
        lotPrice: 100.0,
        totalLotsAvailable: 10000,
        daysUntilListing: 1,
        listingMultiplier: 1.45,
        description: 'Batarya Teknolojileri',
      );

      const request = PlayerIpoRequestModel(
        ipoId: 'ipo_test_1',
        requestedLots: 100,
        totalSpent: 10000.0,
      );

      final result = StockMarketEngine.processIpoSettlement(
        nextDay: 2,
        balance: 50000.0,
        ipos: [ipo],
        requests: [request],
        events: [],
      );

      // IPO listed
      expect(result.$1.first.isListed, isTrue);
      // Payout received
      expect(result.$3, greaterThan(50000.0));
      expect(result.$4.isNotEmpty, isTrue);
    });

    test('OfflineProgressionEngine caps simulated days to max 7 days', () {
      final dealership = DealershipModel.initial().copyWith(
        lastActiveTime: DateTime.now().subtract(const Duration(hours: 48)), // 2 days = 2880 mins
      );

      final outcome = OfflineProgression.processOfflineTime(
        dealership,
        currentTime: DateTime.now(),
      );

      expect(outcome['daysElapsed'], lessThanOrEqualTo(7));
      expect(outcome['daysElapsed'], greaterThanOrEqualTo(1));
    });

    test('LoanSettlementEngine calculates progressive daily corporate and wealth tax', () {
      // Level 1 low balance
      final lowTax = LoanSettlementEngine.calculateDailyTax(1, totalLiquidWealth: 50000.0);
      expect(lowTax, equals(250.0));

      // Level 7 high balance
      final highWealthTax = LoanSettlementEngine.calculateDailyTax(7, totalLiquidWealth: 10500000.0);
      // Base tax (Level 7) = 2000.0 + (10.000.000 * 0.001 = 10.000.0) = 12000.0
      expect(highWealthTax, equals(12000.0));
    });

    test('AdRewardCalculator tier-gates maximum jackpot based on player level', () {
      final lowLvlReward = AdRewardCalculator.calculateDynamicReward(
        playerLevel: 1,
        totalGarageValue: 100000.0,
      );
      expect(lowLvlReward.moneyAmount, lessThanOrEqualTo(100000.0));

      final midLvlReward = AdRewardCalculator.calculateDynamicReward(
        playerLevel: 5,
        totalGarageValue: 500000.0,
      );
      expect(midLvlReward.moneyAmount, lessThanOrEqualTo(250000.0));
    });

    test('DealershipProvider anti-exploit daily gates work as intended', () {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final notifier = container.read(gameProvider.notifier);
      final initialDay = container.read(gameProvider).currentDay;

      // 1. Morning Siftah once per day
      final siftah1 = notifier.performMorningSiftah();
      expect(siftah1, isTrue);
      expect(container.read(gameProvider).lastSiftahDay, equals(initialDay));

      final siftah2 = notifier.performMorningSiftah();
      expect(siftah2, isFalse);

      // 2. Scrapyard search max 3 times per day with increasing costs
      expect(container.read(gameProvider).remainingScrapSearchesToday, equals(3));
      expect(container.read(gameProvider).nextScrapSearchCost, equals(500));

      final search1 = notifier.searchScrapForTreasures();
      expect(search1, isNotNull);
      expect(container.read(gameProvider).remainingScrapSearchesToday, equals(2));
      expect(container.read(gameProvider).nextScrapSearchCost, equals(2500));

      final search2 = notifier.searchScrapForTreasures();
      expect(search2, isNotNull);
      expect(container.read(gameProvider).remainingScrapSearchesToday, equals(1));
      expect(container.read(gameProvider).nextScrapSearchCost, equals(7500));

      final search3 = notifier.searchScrapForTreasures();
      expect(search3, isNotNull);
      expect(container.read(gameProvider).remainingScrapSearchesToday, equals(0));

      final search4 = notifier.searchScrapForTreasures();
      expect(search4, isNull);

      // 3. Office ad grant once per day
      final grant1 = notifier.claimOfficeAdGrant(25000.0);
      expect(grant1, equals(25000.0));

      final grant2 = notifier.claimOfficeAdGrant(25000.0);
      expect(grant2, equals(0.0));
    });
  });
}
