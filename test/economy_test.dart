import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/constants/first_time_action_keys.dart';
import 'package:galeriden/core/services/ad_reward_calculator.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/offer_model.dart';
import 'package:galeriden/data/models/player_skills.dart';
import 'package:galeriden/data/models/stock_model.dart';
import 'package:galeriden/domain/usecases/loan_settlement_engine.dart';
import 'package:galeriden/domain/usecases/offline_progression.dart';
import 'package:galeriden/domain/usecases/stock_market_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Economy and Passive Income System Tests', () {
    late GameNotifier gameNotifier;
    late CarModel testCar;
    
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      gameNotifier = GameNotifier();
      
      // Wait for async load to finish
      await Future.delayed(const Duration(milliseconds: 100));
      
      testCar = CarModel(
        id: 'test_car_1',
        brand: 'TestBrand',
        modelName: 'TestModel',
        modelYear: 2020,
        bodyType: 'Sedan',
        colorHex: 'FFFFFF',
        baseMarketValue: 100000,
        currentPurchasePrice: 50000,
        expertise: ExpertiseReport(
          engineCondition: 100,
          transmissionCondition: 100,
          tramerAmount: 0,
          mileage: 50000,
          isMileageTampered: false,
          bodyParts: {},
        ),
        customListingPrice: 120000,
      );
      // Give initial state
      gameNotifier.completeTutorial(); // complete tutorial to avoid 50k bonus
      gameNotifier.state = gameNotifier.state.copyWith(
        completedFirstTimeActions: {
          FirstTimeActionKeys.firstCarBuy,
          FirstTimeActionKeys.firstCarSell,
        },
      );
      gameNotifier.buyCarDirectly(testCar, 50000);
    });
    
    tearDown(() {
      gameNotifier.dispose();
    });

    test('accepting an installment offer creates a contract', () {
      final offer = OfferModel(
        id: 'offer_inst',
        carId: testCar.id,
        buyerName: 'Ahmet',
        offeredAmount: 100000,
        buyerMessage: 'Test',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        offerType: OfferType.installment,
      );
      
      final initialBalance = gameNotifier.state.balance;
      
      gameNotifier.acceptOffer(offer);
      
      final state = gameNotifier.state;
      
      expect(state.ownedCars.any((c) => c.id == testCar.id), isFalse);
      expect(state.activeInstallments.length, 1);
      final contract = state.activeInstallments.first;
      expect(contract.totalAmount, 100000);
      expect(contract.installmentAmount, 20000); 
      expect(contract.daysUntilNextPayment, 30);
      expect(state.balance, initialBalance);
    });

    test('accepting a cheque offer creates a cheque', () {
      final offer = OfferModel(
        id: 'offer_cheque',
        carId: testCar.id,
        buyerName: 'Mehmet',
        offeredAmount: 95000,
        buyerMessage: 'Test',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        offerType: OfferType.cheque,
      );
      
      final initialBalance = gameNotifier.state.balance;
      
      gameNotifier.acceptOffer(offer);
      
      final state = gameNotifier.state;
      
      expect(state.ownedCars.any((c) => c.id == testCar.id), isFalse);
      expect(state.activeCheques.length, 1);
      final cheque = state.activeCheques.first;
      expect(cheque.amount, 95000);
      expect(cheque.daysUntilDue, 30);
      expect(state.balance, initialBalance);
    });

    test('renting a car', () {
      final success = gameNotifier.rentCar(testCar.id, 1000.0);
      expect(success, isTrue);
      
      expect(gameNotifier.state.activeRentals.length, 1);
      final rental = gameNotifier.state.activeRentals.first;
      expect(rental.carId, testCar.id);
      expect(rental.dailyRate, 600.0);
      
      final car = gameNotifier.state.ownedCars.firstWhere((c) => c.id == testCar.id);
      expect(car.isRented, isTrue);
    });
    
    test('returning a rented car', () {
      gameNotifier.rentCar(testCar.id, 1000.0);
      final rentalId = gameNotifier.state.activeRentals.first.id;

      final success = gameNotifier.returnRentedCar(rentalId);
      expect(success, isTrue);

      expect(gameNotifier.state.activeRentals.isEmpty, isTrue);

      final car = gameNotifier.state.ownedCars.firstWhere((c) => c.id == testCar.id);
      expect(car.isRented, isFalse);
    });

    test('returning an orphan rented car cleans up agreement', () {
      gameNotifier.rentCar(testCar.id, 1000.0);
      final rentalId = gameNotifier.state.activeRentals.first.id;

      // Remove car from ownedCars to simulate car deletion/sale
      gameNotifier.state = gameNotifier.state.copyWith(
        ownedCars: gameNotifier.state.ownedCars.where((c) => c.id != testCar.id).toList(),
      );

      final success = gameNotifier.returnRentedCar(rentalId);
      expect(success, isTrue);
      expect(gameNotifier.state.activeRentals.isEmpty, isTrue);
    });

    test('syncRentalState auto-heals desynced car flags', () {
      final carId = gameNotifier.state.ownedCars.first.id;
      gameNotifier.rentCar(carId, 1000.0);
      
      // Manually tamper isRented to false
      final car = gameNotifier.state.ownedCars.firstWhere((c) => c.id == carId);
      final tamperedCar = car.copyWith(isRented: false);
      gameNotifier.state = gameNotifier.state.copyWith(ownedCars: [tamperedCar]);

      // Call syncRentalState
      gameNotifier.syncRentalState();

      final healedCar = gameNotifier.state.ownedCars.firstWhere((c) => c.id == carId);
      expect(healedCar.isRented, isTrue);
    });

    test('purchasing and upgrading side business level', () {
      // Find sb_9 (Kurumsal Oto Ekspertiz Bayii)
      final business = gameNotifier.state.sideBusinesses.firstWhere((b) => b.id == 'sb_9');
      expect(business.isOwned, isFalse);
      expect(business.level, 1);

      // Add enough money to buy and upgrade
      gameNotifier.state = gameNotifier.state.copyWith(balance: 3000000.0);

      final buySuccess = gameNotifier.buySideBusiness('sb_9');
      expect(buySuccess, isTrue);

      // Complete construction
      gameNotifier.completeSideBusinessConstruction('sb_9');

      var updated = gameNotifier.state.sideBusinesses.firstWhere((b) => b.id == 'sb_9');
      expect(updated.isOwned, isTrue);
      expect(updated.isUnderConstruction, isFalse);
      expect(updated.level, 1);

      // Verify Net Income (Gross minus 15% maintenance)
      expect(updated.grossDailyIncome, 22500.0);
      expect(updated.dailyMaintenanceExpense, 3375.0);
      expect(updated.effectiveDailyIncome, 19125.0);

      // Upgrade level to 2
      final upgradeSuccess = gameNotifier.upgradeSideBusiness('sb_9');
      expect(upgradeSuccess, isTrue);

      // Complete level upgrade duration
      gameNotifier.completeSideBusinessLevelUpgrade('sb_9');

      updated = gameNotifier.state.sideBusinesses.firstWhere((b) => b.id == 'sb_9');
      expect(updated.level, 2);
      expect(updated.grossDailyIncome, closeTo(30375.0, 0.01)); // 22500 * (1 + 0.35)
      expect(updated.effectiveDailyIncome, closeTo(25818.75, 0.01)); // 30375 * 0.85
    });
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

      expect(result.$1.first.isListed, isTrue);
      expect(result.$3, greaterThan(50000.0));
      expect(result.$4.isNotEmpty, isTrue);
    });

    test('OfflineProgressionEngine caps simulated days to max 3 days', () {
      final dealership = DealershipModel.initial().copyWith(
        lastActiveTime: DateTime.now().subtract(const Duration(hours: 48)),
      );

      final outcome = OfflineProgression.processOfflineTime(
        dealership,
        currentTime: DateTime.now(),
      );

      expect(outcome['daysElapsed'], lessThanOrEqualTo(3));
      expect(outcome['daysElapsed'], greaterThanOrEqualTo(1));
    });

    test('LoanSettlementEngine calculates progressive daily corporate and wealth tax', () {
      final lowTax = LoanSettlementEngine.calculateDailyTax(1, totalLiquidWealth: 50000.0);
      expect(lowTax, equals(250.0));

      final highWealthTax = LoanSettlementEngine.calculateDailyTax(7, totalLiquidWealth: 10500000.0);
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
