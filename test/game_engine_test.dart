import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/domain/usecases/market_engine.dart';
import 'package:galeriden/domain/usecases/expertise_engine.dart';
import 'package:galeriden/domain/usecases/repair_engine.dart';
import 'package:galeriden/domain/usecases/auction_engine.dart';
import 'package:galeriden/domain/usecases/negotiation_engine.dart';
import 'package:galeriden/domain/usecases/risk_engine.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/customer_model.dart';
import 'package:galeriden/data/models/branch_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/detailing_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/part_order_model.dart';
import 'package:galeriden/core/constants/first_time_action_keys.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  group('Galeriden Tycoon Engine Tests', () {
    test('Market Engine generates offline listings with realistic Turkish prices', () {
      final listings = MarketEngine.generateRandomListings(count: 5, playerLevel: 1);
      expect(listings.length, greaterThanOrEqualTo(5));
      expect(listings.first.car.brand.isNotEmpty, isTrue);
      expect(listings.first.askingPrice, greaterThanOrEqualTo(35000));
    });

    test('Expertise Engine evaluates vehicle damage correctly', () {
      final listings = MarketEngine.generateRandomListings(count: 1, playerLevel: 1);
      final car = listings.first.car;
      final eval = ExpertiseEngine.evaluateVehicle(car);

      expect(eval.containsKey('overallGrade'), isTrue);
      expect(eval['damagePercentage'], greaterThanOrEqualTo(0));
    });

    test('Repair Engine restores body part to original with Master Tier', () {
      final listings = MarketEngine.generateRandomListings(count: 1, playerLevel: 1);
      final car = listings.first.car;

      // Find a part that is not original, or force one to painted
      final targetPart = car.expertise.bodyParts.keys.firstWhere(
        (k) => car.expertise.bodyParts[k] != PartStatus.original,
        orElse: () => 'Kaput',
      );

      final damagedCar = car.copyWith(
        expertise: ExpertiseReport(
          engineCondition: car.expertise.engineCondition,
          transmissionCondition: car.expertise.transmissionCondition,
          tramerAmount: car.expertise.tramerAmount,
          mileage: car.expertise.mileage,
          isMileageTampered: car.expertise.isMileageTampered,
          bodyParts: {...car.expertise.bodyParts, targetPart: PartStatus.painted},
        ),
      );

      final result = RepairEngine.repairBodyPart(damagedCar, targetPart, RepairTier.master);
      expect(result.isSuccess, isTrue);
      expect(result.updatedCar.expertise.bodyParts[targetPart], equals(PartStatus.original));
    });

    test('Risk Engine evaluates uninspected purchases correctly', () {
      final listings = MarketEngine.generateRandomListings(count: 1, playerLevel: 1);
      final car = listings.first.car;

      // Run 20 evaluations to ensure risk engine produces valid outcomes
      for (int i = 0; i < 20; i++) {
        final outcome = RiskEngine.evaluateUninspectedPurchaseRisk(car);
        expect(outcome.title.isNotEmpty, isTrue);
        expect(outcome.description.isNotEmpty, isTrue);
      }
    });

    test('Repair Engine prevents repairing already original parts and 100% engines', () {
      final listings = MarketEngine.generateRandomListings(count: 1, playerLevel: 1);
      final car = listings.first.car;

      final damagedCar = car.copyWith(
        expertise: ExpertiseReport(
          engineCondition: 80.0,
          transmissionCondition: 80.0,
          tramerAmount: car.expertise.tramerAmount,
          mileage: car.expertise.mileage,
          isMileageTampered: car.expertise.isMileageTampered,
          bodyParts: {...car.expertise.bodyParts, 'Kaput': PartStatus.painted},
        ),
      );

      // 1. Repair part to original first
      final res1 = RepairEngine.repairBodyPart(damagedCar, 'Kaput', RepairTier.master);
      expect(res1.isSuccess, isTrue);

      // 2. Try to repair already original part
      final res2 = RepairEngine.repairBodyPart(res1.updatedCar, 'Kaput', RepairTier.master);
      expect(res2.isSuccess, isFalse);
      expect(res2.costPaid, equals(0.0));

      // 3. Repair engine to 100%
      final engRes1 = RepairEngine.repairEngine(damagedCar, RepairTier.master);
      expect(engRes1.isSuccess, isTrue);

      // 4. Try to repair already 100% engine
      final engRes2 = RepairEngine.repairEngine(engRes1.updatedCar, RepairTier.master);
      expect(engRes2.isSuccess, isFalse);
      expect(engRes2.costPaid, equals(0.0));
    });

    test('NegotiationEngine detects expertise discrepancy correctly', () {
      final listings = MarketEngine.generateRandomListings(count: 1, playerLevel: 1);
      final car = listings.first.car;

      final tamperedCar = car.copyWith(
        declarationType: ListingDeclarationType.tamperedMileageClaim,
        expertise: ExpertiseReport(
          engineCondition: car.expertise.engineCondition,
          transmissionCondition: car.expertise.transmissionCondition,
          tramerAmount: car.expertise.tramerAmount,
          mileage: car.expertise.mileage,
          isMileageTampered: true,
          bodyParts: car.expertise.bodyParts,
        ),
      );

      final disc = NegotiationEngine.detectExpertiseDiscrepancy(tamperedCar);
      expect(disc.hasDiscrepancy, isTrue);
      expect(disc.extraDiscountPercent, equals(0.25));
    });

    test('AuctionEngine generates live auctions with 3 rival bidders', () {
      final auction = AuctionEngine.createLiveAuction(playerLevel: 1);
      expect(auction.car.brand.isNotEmpty, isTrue);
      expect(auction.rivals.length, greaterThanOrEqualTo(3));
      expect(auction.startingPrice, lessThan(auction.estimatedMarketValue));
      expect(auction.secondsRemaining, greaterThanOrEqualTo(20));
    });

    test('AuctionEngine generates randomized intervals and rich officer dialogues', () {
      AuctionEngine.scheduleNextRandomSession(minSeconds: 50, maxSeconds: 120);
      final secondsUntil = AuctionEngine.getSecondsUntilNextAuction();
      expect(secondsUntil, greaterThanOrEqualTo(49));
      expect(secondsUntil, lessThanOrEqualTo(120));

      final dialogue = AuctionEngine.getRandomOfficerDialogue('01:45');
      expect(dialogue.isNotEmpty, isTrue);
      expect(dialogue.contains('01:45'), isTrue);
    });

    test('CustomerModel generates valid buyer archetypes', () {
      final customer = CustomerModel.generateRandomCustomer();
      expect(customer.name.isNotEmpty, isTrue);
      expect(customer.archetypeTitle.isNotEmpty, isTrue);
    });

    test('BranchModel defines 8 tiers of dealership expansion', () {
      final branches = BranchModel.getAllBranches(currentSlotCount: 3, currentLevel: 1);
      expect(branches.length, equals(8));
      expect(branches.first.maxGarageSlots, equals(3));
      expect(branches.last.maxGarageSlots, equals(20));
    });

    test('DetailingOption returns 4 detailing & tuning options', () {
      final options = DetailingOption.getAvailableOptions();
      expect(options.length, equals(4));
      expect(options.any((o) => o.isRisky), isTrue);
    });

    test('NegotiationEngine evaluates player fraud inspection correctly', () {
      final listings = MarketEngine.generateRandomListings(count: 1, playerLevel: 1);
      final car = listings.first.car.copyWith(
        declarationType: ListingDeclarationType.flawlessClaim,
      );

      final customer = CustomerModel.generateRandomCustomer();
      expect(customer.inspectionProbability, greaterThan(0.0));

      final result = NegotiationEngine.evaluatePlayerFraudInspection(car: car, customer: customer);
      expect(result.title.isNotEmpty, isTrue);
      if (result.caughtFraud) {
        expect(result.fineAmount, equals(10000.0));
        expect(result.reputationPenalty, equals(15));
      }
    });

    test('GameNotifier processes bank loan and repayment correctly', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(gameProvider.notifier);
      final initialBalance = container.read(gameProvider).balance;

      final loanSuccess = notifier.takeBankLoan(
        bankName: 'Ziraat Finans',
        amount: 100000.0,
        months: 6,
      );

      expect(loanSuccess, isTrue);
      expect(container.read(gameProvider).balance, equals(initialBalance + 100000.0));
      expect(container.read(gameProvider).activeLoans.length, equals(1));

      final loan = container.read(gameProvider).activeLoans.first;
      final paySuccess = notifier.payLoanInstallment(loan.id);

      expect(paySuccess, isTrue);
      expect(container.read(gameProvider).activeLoans.first.remainingInstallments, equals(5));
    });

    test('DealershipModel initial state grants 75.000 TL and Heritage Car', () {
      final initialDealership = DealershipModel.initial();
      expect(initialDealership.balance, equals(75000.0));
      expect(initialDealership.ownedCars.length, equals(1));
      expect(initialDealership.ownedCars.first.brand, equals('Tofaşk'));
      expect(initialDealership.ownedCars.first.modelName, contains('Murat 124'));
    });

    test('PartOrderModel evaluates delivery progress and remaining time correctly', () {
      final order = PartOrderModel(
        id: 'order_test_1',
        carId: 'car_heritage_dede',
        partName: 'Kaput',
        orderType: OrderType.masterRepair,
        cost: 4500.0,
        orderedAt: DateTime.now().subtract(const Duration(seconds: 10)),
        deliveryDurationSeconds: 60,
      );

      expect(order.isDelivered, isFalse);
      expect(order.remainingSeconds, lessThanOrEqualTo(50));
      expect(order.progressPercentage, greaterThan(0.0));
    });

    test('RepairEngine applies installed part orders correctly', () {
      final car = DealershipModel.initial().ownedCars.first;
      final restoredCar = RepairEngine.applyInstalledPart(car, 'Kaput', OrderType.newOemPart);

      expect(restoredCar.expertise.bodyParts['Kaput'], equals(PartStatus.original));
      expect(restoredCar.expertise.partConditions['Kaput'], equals(100.0));
    });

    test('RepairEngine calculates realistic and varied part repair costs', () {
      final car = DealershipModel.initial().ownedCars.first;
      final engineCost = RepairEngine.calculatePartRepairCost(car, 'Motor & Şanzıman', OrderType.newOemPart);
      final hoodCost = RepairEngine.calculatePartRepairCost(car, 'Kaput', OrderType.newOemPart);
      final doorCost = RepairEngine.calculatePartRepairCost(car, 'Sol Ön Kapı', OrderType.newOemPart);
      final bumperCost = RepairEngine.calculatePartRepairCost(car, 'Ön Tampon', OrderType.newOemPart);

      expect(engineCost, greaterThan(hoodCost));
      expect(hoodCost, greaterThan(doorCost));
      expect(doorCost, greaterThan(bumperCost));

      final quickPatchHood = RepairEngine.calculatePartRepairCost(car, 'Kaput', OrderType.quickPatch);
      final masterRepairHood = RepairEngine.calculatePartRepairCost(car, 'Kaput', OrderType.masterRepair);
      final oemHood = RepairEngine.calculatePartRepairCost(car, 'Kaput', OrderType.newOemPart);

      expect(quickPatchHood, lessThan(masterRepairHood));
      expect(masterRepairHood, lessThan(oemHood));
    });

    test('GameNotifier updates player name, dealership title and logo emblem', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      expect(container.read(gameProvider).playerName, equals('Kaptan'));
      expect(container.read(gameProvider).dealershipName, equals('Miras Oto Galeri'));
      expect(container.read(gameProvider).logoEmblemId, equals('crown'));

      notifier.updateDealershipIdentity(
        playerName: 'Mehmet Usta',
        dealershipName: 'Aslanlar Motors',
        logoEmblemId: 'shield',
      );

      expect(container.read(gameProvider).playerName, equals('Mehmet Usta'));
      expect(container.read(gameProvider).dealershipName, equals('Aslanlar Motors'));
      expect(container.read(gameProvider).logoEmblemId, equals('shield'));
    });

    test('Bank deposit, withdrawal, and interest accumulation operate properly', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        completedFirstTimeActions: {FirstTimeActionKeys.firstBankDeposit},
      );

      final initialBalance = container.read(gameProvider).balance;
      expect(container.read(gameProvider).bankDepositBalance, equals(0.0));

      // 1. Deposit 20,000 to bank
      final depositSuccess = notifier.depositToBank(20000.0);
      expect(depositSuccess, isTrue);
      expect(container.read(gameProvider).balance, equals(initialBalance - 20000.0));
      expect(container.read(gameProvider).bankDepositBalance, equals(20000.0));

      // 2. Advance game day and check interest
      notifier.advanceGameDay();
      expect(container.read(gameProvider).bankDepositBalance, greaterThan(20000.0));

      // 3. Withdraw 10,000 from bank
      final bankBalanceBeforeWithdraw = container.read(gameProvider).bankDepositBalance;
      final walletBeforeWithdraw = container.read(gameProvider).balance;
      final withdrawSuccess = notifier.withdrawFromBank(10000.0);
      expect(withdrawSuccess, isTrue);
      expect(container.read(gameProvider).bankDepositBalance, equals(bankBalanceBeforeWithdraw - 10000.0));
      expect(container.read(gameProvider).balance, equals(walletBeforeWithdraw + 10000.0));
    });

    test('Staff Academy course purchase persists in state', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      expect(container.read(gameProvider).purchasedAcademyCourses, isEmpty);

      final initialBalance = container.read(gameProvider).balance;
      final courseCost = 12000.0;
      final courseId = 'course_sales_master';

      final success = notifier.purchaseAcademyCourse(courseId, courseCost);
      expect(success, isTrue);
      expect(container.read(gameProvider).balance, equals(initialBalance - courseCost));
      expect(container.read(gameProvider).purchasedAcademyCourses, contains(courseId));

      // Duplicate purchase should fail
      final duplicateSuccess = notifier.purchaseAcademyCourse(courseId, courseCost);
      expect(duplicateSuccess, isFalse);
    });

    test('Stock Market applies 0.2% commission on buy and sell operations', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      final initialBalance = container.read(gameProvider).balance;
      final stock = container.read(gameProvider).marketStocks.first;
      final sharesToBuy = 10;
      final rawCost = stock.currentPrice * sharesToBuy;
      final expectedCommission = rawCost * 0.002;
      final totalExpectedCost = rawCost + expectedCommission;

      final buySuccess = notifier.buyStock(stock.symbol, sharesToBuy);
      expect(buySuccess, isTrue);
      expect(container.read(gameProvider).balance, closeTo(initialBalance - totalExpectedCost, 0.01));
      
      final owned = container.read(gameProvider).ownedStocks.firstWhere((s) => s.symbol == stock.symbol);
      expect(owned.quantity, equals(sharesToBuy));

      final balanceBeforeSell = container.read(gameProvider).balance;
      final rawRevenue = stock.currentPrice * sharesToBuy;
      final sellCommission = rawRevenue * 0.002;
      final netExpectedRevenue = rawRevenue - sellCommission;

      final sellSuccess = notifier.sellStock(stock.symbol, sharesToBuy);
      expect(sellSuccess, isTrue);
      expect(container.read(gameProvider).balance, closeTo(balanceBeforeSell + netExpectedRevenue, 0.01));
      expect(container.read(gameProvider).ownedStocks.any((s) => s.symbol == stock.symbol), isFalse);
    });

    test('Instant part delivery completes pending order immediately', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      final car = container.read(gameProvider).ownedCars.first;
      final orderSuccess = notifier.orderPart(
        carId: car.id,
        partName: 'Kaput',
        cost: 1500.0,
        deliveryDurationSeconds: 60,
        orderType: OrderType.newOemPart,
      );
      expect(orderSuccess, isTrue);
      expect(container.read(gameProvider).pendingOrders.length, equals(1));

      final orderId = container.read(gameProvider).pendingOrders.first.id;
      notifier.instantDeliverPartOrder(orderId);

      final updatedOrder = container.read(gameProvider).pendingOrders.first;
      expect(updatedOrder.isDelivered, isTrue);
      expect(updatedOrder.remainingSeconds, equals(0));
    });

    test('RepairEngine differentiates painted vs OEM original part status', () {
      final car = DealershipModel.initial().ownedCars.first;
      final masterRepairedCar = RepairEngine.applyInstalledPart(car, 'Kaput', OrderType.masterRepair);
      expect(masterRepairedCar.expertise.bodyParts['Kaput'], equals(PartStatus.painted));
      expect(masterRepairedCar.expertise.partConditions['Kaput'], equals(95.0));

      final oemCar = RepairEngine.applyInstalledPart(car, 'Kaput', OrderType.newOemPart);
      expect(oemCar.expertise.bodyParts['Kaput'], equals(PartStatus.original));
      expect(oemCar.expertise.partConditions['Kaput'], equals(100.0));
    });

    test('NegotiationEngine evaluates flawless declaration accurately without false fraud penalty', () {
      final pristineCar = CarModel(
        id: 'test_pristine',
        brand: 'BMW',
        modelName: '320i',
        modelYear: 2022,
        bodyType: 'sedan',
        colorHex: '#000000',
        baseMarketValue: 500000,
        currentPurchasePrice: 550000,
        expertise: ExpertiseReport(
          engineCondition: 100,
          transmissionCondition: 100,
          tramerAmount: 0,
          mileage: 15000,
          isMileageTampered: false,
          bodyParts: {
            'Kaput': PartStatus.original,
            'Tavan': PartStatus.original,
            'Bagaj': PartStatus.original,
          },
        ),
        declarationType: ListingDeclarationType.flawlessClaim,
      );

      final customer = CustomerModel(
        id: 'cust_1',
        name: 'Ahmet',
        archetype: CustomerArchetype.skepticalOfficial,
        archetypeTitle: 'Şüpheci Memur',
        avatarType: 'man_1',
        personalityDescription: 'Titiz',
        preferredDialogueTrait: 'formal',
      );

      final pristineResult = NegotiationEngine.evaluatePlayerFraudInspection(
        car: pristineCar,
        customer: customer,
      );
      expect(pristineResult.caughtFraud, isFalse);
      expect(pristineResult.fineAmount, equals(0.0));

      final damagedCar = pristineCar.copyWith(
        id: 'test_damaged',
        expertise: ExpertiseReport(
          engineCondition: 100,
          transmissionCondition: 100,
          tramerAmount: 5000,
          mileage: 15000,
          isMileageTampered: false,
          bodyParts: {
            'Kaput': PartStatus.painted,
            'Tavan': PartStatus.original,
            'Bagaj': PartStatus.original,
          },
        ),
        declarationType: ListingDeclarationType.flawlessClaim,
      );

      final damagedResult = NegotiationEngine.evaluatePlayerFraudInspection(
        car: damagedCar,
        customer: customer,
      );
      expect(damagedResult.caughtFraud, isTrue);
      expect(damagedResult.fineAmount, equals(10000.0));

      final honestDamagedCar = damagedCar.copyWith(
        declarationType: ListingDeclarationType.honest,
      );
      final honestResult = NegotiationEngine.evaluatePlayerFraudInspection(
        car: honestDamagedCar,
        customer: customer,
      );
      expect(honestResult.caughtFraud, isFalse);
      expect(honestResult.fineAmount, equals(0.0));
    });
  });
}
