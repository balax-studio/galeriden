import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/loan_model.dart';
import 'package:galeriden/data/models/rental_agreement_model.dart';
import 'package:galeriden/data/models/scrapyard_model.dart';
import 'package:galeriden/data/models/staff_model.dart';
import 'package:galeriden/data/models/offer_model.dart';
import 'package:galeriden/data/models/casino_game_model.dart';
import 'package:galeriden/domain/usecases/loan_settlement_engine.dart';
import 'package:galeriden/domain/usecases/rental_progression_engine.dart';
import 'package:galeriden/domain/usecases/consignment_engine.dart';
import 'package:galeriden/domain/usecases/cashflow_engine.dart';
import 'package:galeriden/domain/usecases/review_engine.dart';
import 'package:galeriden/domain/usecases/district_economy_engine.dart';
import 'package:galeriden/domain/usecases/black_market_engine.dart';
import 'package:galeriden/domain/usecases/gossip_engine.dart';
import 'package:galeriden/data/models/stock_model.dart';
import 'package:galeriden/data/models/cheque_model.dart';
import 'package:galeriden/data/models/branch_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Ecosystem 5-Phase Deep Audit & Cohesion Tests', () {
    // -------------------------------------------------------------------------
    // PHASE 1: Finance & Investment Subsystems
    // -------------------------------------------------------------------------
    test('Phase 1: Loan Settlement Engine processes weekly loans correctly', () {
      const loan = LoanModel(
        id: 'test_loan_1',
        bankName: 'VakıfBank',
        principalAmount: 140000.0,
        interestRate: 0.15,
        totalRepayment: 140000.0,
        remainingAmount: 140000.0,
        totalInstallments: 7,
        remainingInstallments: 7,
        monthlyPayment: 20000.0,
      );

      // On day 6 (not multiple of 7), no deduction happens
      final (balNonPayDay, loansNonPayDay) = LoanSettlementEngine.processWeeklyLoans(
        nextDay: 6,
        balance: 500000.0,
        loans: [loan],
      );
      expect(balNonPayDay, equals(500000.0));
      expect(loansNonPayDay.length, equals(1));
      expect(loansNonPayDay.first.remainingInstallments, equals(7));

      // On day 7 (multiple of 7), installment is deducted
      final (balPayDay, loansPayDay) = LoanSettlementEngine.processWeeklyLoans(
        nextDay: 7,
        balance: 500000.0,
        loans: [loan],
      );
      expect(balPayDay, equals(480000.0));
      expect(loansPayDay.length, equals(1));
      expect(loansPayDay.first.remainingInstallments, equals(6));
      expect(loansPayDay.first.remainingAmount, equals(120000.0));
    });

    test('Phase 1: Daily Tax calculation clamps properly and scales with wealth', () {
      final lowWealthTax = LoanSettlementEngine.calculateDailyTax(
        1,
        totalLiquidWealth: 50000.0,
      );
      expect(lowWealthTax, greaterThanOrEqualTo(0.0));

      final highWealthTax = LoanSettlementEngine.calculateDailyTax(
        8,
        totalLiquidWealth: 50000000.0,
      );
      expect(highWealthTax, greaterThan(lowWealthTax));
    });

    // -------------------------------------------------------------------------
    // PHASE 2: Showroom & Sales / Consignment Subsystems
    // -------------------------------------------------------------------------
    test('Phase 2: Showcase Lock & Hero Showcase toggle without side-effects', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      final testCar = CarModel(
        id: 'test_showcase_car_1',
        brand: 'Porsche',
        modelName: '911 Carrera',
        modelYear: 2022,
        bodyType: 'Coupe',
        colorHex: '#FF0000',
        baseMarketValue: 8000000.0,
        currentPurchasePrice: 7500000.0,
        customListingPrice: 8500000.0,
        expertise: ExpertiseReport(
          engineCondition: 100,
          transmissionCondition: 100,
          isMileageTampered: false,
          bodyParts: {},
          tramerAmount: 0,
          mileage: 15000,
        ),
      );

      notifier.state = notifier.state.copyWith(
        ownedCars: [testCar],
        balance: 1000000.0,
      );

      // Toggle showcase lock
      final lockSuccess = notifier.toggleShowcaseLock(testCar.id);
      expect(lockSuccess, isTrue);
      expect(notifier.state.ownedCars.first.isLockedInShowcase, isTrue);
      expect(notifier.state.ownedCars.first.customListingPrice, isNull);

      // Toggle hero showcase
      final heroSuccess = notifier.toggleHeroShowcase(testCar.id);
      expect(heroSuccess, isTrue);
      expect(notifier.state.ownedCars.first.isHeroShowcase, isTrue);

      container.dispose();
    });

    test('Phase 2: Consignment car sales award pure commission and create sale record', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      final consignmentCar = CarModel(
        id: 'consignment_car_1',
        brand: 'Mercedes-Benz',
        modelName: 'E200',
        modelYear: 2020,
        bodyType: 'Sedan',
        colorHex: '#000000',
        baseMarketValue: 3000000.0,
        currentPurchasePrice: 0.0,
        customListingPrice: 3000000.0,
        isConsignment: true,
        consignmentOwnerName: 'Doktor Cihan Bey',
        consignmentCommissionRate: 0.15,
        consignmentDaysRemaining: 7,
        expertise: ExpertiseReport(
          engineCondition: 95,
          transmissionCondition: 95,
          isMileageTampered: false,
          bodyParts: {},
          tramerAmount: 0,
          mileage: 40000,
        ),
      );

      notifier.state = notifier.state.copyWith(
        ownedCars: [consignmentCar],
        balance: 100000.0,
        tutorialCompleted: true,
        completedFirstTimeActions: {'first_car_sell'},
      );

      final offer = OfferModel(
        id: 'offer_consignment_1',
        carId: consignmentCar.id,
        buyerName: 'Selim Bey',
        buyerMessage: 'Aracı çok beğendim hemen almak istiyorum.',
        offeredAmount: 3000000.0,
        createdAt: DateTime.now(),
      );

      notifier.acceptOffer(offer);

      // Expected commission: 3,000,000 * 0.15 = 450,000 TL
      expect(notifier.state.balance, equals(550000.0));
      expect(notifier.state.ownedCars.any((c) => c.id == consignmentCar.id), isFalse);
      expect(notifier.state.salesHistory.isNotEmpty, isTrue);
      expect(notifier.state.salesHistory.first.isConsignment, isTrue);
      expect(notifier.state.salesHistory.first.netProfit, equals(450000.0));

      container.dispose();
    });

    // -------------------------------------------------------------------------
    // PHASE 3: Operations & Fleet Subsystems (Rentals, Scrapyard, District Decay)
    // -------------------------------------------------------------------------
    test('Phase 3: Rental Progression Engine applies daily rental income & incident deductible', () {
      final testCar = CarModel(
        id: 'rental_car_1',
        brand: 'Renault',
        modelName: 'Megane',
        modelYear: 2021,
        bodyType: 'Sedan',
        colorHex: '#C0C0C0',
        baseMarketValue: 900000.0,
        currentPurchasePrice: 850000.0,
        isRented: true,
        expertise: ExpertiseReport(
          engineCondition: 90,
          transmissionCondition: 90,
          isMileageTampered: false,
          bodyParts: {},
          tramerAmount: 0,
          mileage: 60000,
        ),
      );

      final agreement = RentalAgreement(
        id: 'rental_agr_1',
        carId: testCar.id,
        renterName: 'Ahmet Kaya',
        renterType: 'individual',
        dailyRate: 2000.0,
        rentedDays: 2,
        hasInsurance: true,
        insuranceDailyFee: 300.0,
      );

      final (newBal, carsAfterRental, updatedAgreements, events, offers) =
          RentalProgressionEngine.processDailyRentals(
        balance: 50000.0,
        cars: [testCar],
        rentals: [agreement],
        events: [],
        incomingOffers: [],
        random: Random(42),
      );

      // Net daily: 2000 - 300 = 1700 TL income added
      expect(newBal, greaterThanOrEqualTo(51700.0 - 5000.0));
      expect(updatedAgreements.first.rentedDays, equals(3));
    });

    test('Phase 3: Scrapyard buy & dismantle recovers parts and grants XP', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      final scrapCar = ScrapyardCar(
        id: 'scrap_car_audit_1',
        brand: 'Fiat',
        modelName: 'Egea',
        modelYear: 2018,
        scrapPrice: 50000.0,
        estimatedPartTotalValue: 80000.0,
        damageNote: 'Önden kazalı hurda',
        parts: ScrapyardCar.generateRandomParts('Fiat Egea', 80000.0),
      );

      notifier.state = notifier.state.copyWith(
        scrapyardCars: [scrapCar],
        balance: 200000.0,
      );

      final result = notifier.buyAndDismantleScrapCar(scrapCar.id, random: Random(100));
      expect(result.success, isTrue);
      expect(notifier.state.balance, equals(150000.0));
      expect(notifier.state.salvagedParts.length, equals(result.salvagedParts.length));

      container.dispose();
    });

    // -------------------------------------------------------------------------
    // PHASE 4: Underground & Special Systems (Black Market, Gossip, Casino)
    // -------------------------------------------------------------------------
    test('Phase 4: Gossip hotline generates daily news intelligence', () {
      final gossipsDay1 = GossipEngine.generateDailyGossips(1);
      expect(gossipsDay1.isNotEmpty, isTrue);
      expect(gossipsDay1.first.title.isNotEmpty, isTrue);
      expect(gossipsDay1.first.cost, greaterThan(0));

      final gossipsDay10 = GossipEngine.generateDailyGossips(10);
      expect(gossipsDay10.isNotEmpty, isTrue);
    });

    test('Phase 4: Casino Valet Baccarat resolves game logic fairly and records stats', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      notifier.state = notifier.state.copyWith(
        balance: 100000.0,
        casinoStats: const CasinoStatsModel(),
      );

      final result = notifier.playCasinoBaccarat(
        betAmount: 10000.0,
        choice: BaccaratBetChoice.player,
      );

      expect(result, isNotNull);
      expect(notifier.state.casinoStats.totalGamesPlayed, equals(1));
      if (result!.isWin) {
        expect(notifier.state.balance, greaterThanOrEqualTo(100000.0));
      } else {
        expect(notifier.state.balance, equals(90000.0));
      }

      container.dispose();
    });

    // -------------------------------------------------------------------------
    // PHASE 5: Office, Staff & Cashflow History Subsystems
    // -------------------------------------------------------------------------
    test('Phase 5: Staff treats restore morale and energy with proper cost bounds', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      final staff = StaffModel(
        id: 'staff_audit_1',
        name: 'Usta Mehmet',
        role: StaffRole.masterMechanic,
        hiredAt: DateTime.now(),
        morale: 40,
        energy: 50,
      );

      notifier.state = notifier.state.copyWith(
        hiredStaff: [staff],
        balance: 50000.0,
      );

      // Treat tea (₺500, +15 Morale, +15 Energy)
      final teaResult = notifier.treatStaffTea(staff.id);
      expect(teaResult, isTrue);
      expect(notifier.state.balance, equals(49500.0));
      expect(notifier.state.hiredStaff.first.morale, equals(55));
      expect(notifier.state.hiredStaff.first.energy, equals(65));

      // Treat meal (₺1,500, +35 Morale, +30 Energy)
      final mealResult = notifier.treatStaffMeal(staff.id);
      expect(mealResult, isTrue);
      expect(notifier.state.balance, equals(48000.0));
      expect(notifier.state.hiredStaff.first.morale, equals(90));
      expect(notifier.state.hiredStaff.first.energy, equals(95));

      container.dispose();
    });

    test('Phase 1 & 5: CashflowEngine daily interest parity with GameTimeMixin', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      notifier.state = notifier.state.copyWith(
        balance: 1000000.0,
        bankDepositBalance: 500000.0,
      );

      // Deposit interest formula is 0.12% daily
      // In GameTimeMixin: (game.bankDepositBalance * 0.0012).roundToDouble() = 600.0
      // In CashflowEngine.calculate: breakdown.depositDailyInterest should match 600.0
      final breakdown = CashflowEngine.calculate(notifier.state);
      expect(breakdown.depositDailyInterest, equals(600.0));

      container.dispose();
    });

    test('Phase 2: Consignment daily parking fees scale strictly with branch tier', () {
      // ConsignmentEngine.calculateDailyParkingFee(tier)
      expect(ConsignmentEngine.calculateDailyParkingFee(1), equals(300.0));
      expect(ConsignmentEngine.calculateDailyParkingFee(2), equals(600.0));
      expect(ConsignmentEngine.calculateDailyParkingFee(3), equals(1200.0));
      expect(ConsignmentEngine.calculateDailyParkingFee(4), equals(2500.0));
      expect(ConsignmentEngine.calculateDailyParkingFee(5), equals(5000.0));
      expect(ConsignmentEngine.calculateDailyParkingFee(6), equals(10000.0));
      expect(ConsignmentEngine.calculateDailyParkingFee(7), equals(22000.0));
      expect(ConsignmentEngine.calculateDailyParkingFee(8), equals(45000.0));
    });

    // -------------------------------------------------------------------------
    // ADDITIONAL PHASE 1-5 DEEP SPEC TESTS
    // -------------------------------------------------------------------------
    test('Phase 1: Bank loan enforces maximum 3 active loans limit', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      final dummyLoans = [
        const LoanModel(
          id: 'l1', bankName: 'Ziraat', principalAmount: 50000, interestRate: 0.1,
          totalRepayment: 55000, remainingAmount: 55000, totalInstallments: 5,
          remainingInstallments: 5, monthlyPayment: 11000,
        ),
        const LoanModel(
          id: 'l2', bankName: 'İş Bankası', principalAmount: 50000, interestRate: 0.1,
          totalRepayment: 55000, remainingAmount: 55000, totalInstallments: 5,
          remainingInstallments: 5, monthlyPayment: 11000,
        ),
        const LoanModel(
          id: 'l3', bankName: 'Garanti', principalAmount: 50000, interestRate: 0.1,
          totalRepayment: 55000, remainingAmount: 55000, totalInstallments: 5,
          remainingInstallments: 5, monthlyPayment: 11000,
        ),
      ];

      notifier.state = notifier.state.copyWith(
        activeLoans: dummyLoans,
        balance: 100000.0,
      );

      // Attempting 4th loan must fail
      final result = notifier.takeBankLoan(
        bankName: 'Yapı Kredi',
        amount: 50000.0,
        months: 6,
      );
      expect(result, isFalse);
      expect(notifier.state.activeLoans.length, equals(3));

      container.dispose();
    });

    test('Phase 1: Bank deposit enforces balance constraints and positive amount', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      notifier.state = notifier.state.copyWith(
        balance: 5000.0,
        bankDepositBalance: 1000.0,
        completedFirstTimeActions: {'first_bank_deposit'},
      );

      // Zero or negative deposit must fail
      expect(notifier.depositToBank(0.0), isFalse);
      expect(notifier.depositToBank(-50.0), isFalse);
      // More than current balance must fail
      expect(notifier.depositToBank(6000.0), isFalse);
      // Valid deposit
      expect(notifier.depositToBank(2000.0), isTrue);
      expect(notifier.state.balance, equals(3000.0));
      expect(notifier.state.bankDepositBalance, equals(3000.0));

      // Withdraw zero or negative must fail
      expect(notifier.withdrawFromBank(0.0), isFalse);
      expect(notifier.withdrawFromBank(-100.0), isFalse);
      // Withdraw more than deposited must fail
      expect(notifier.withdrawFromBank(4000.0), isFalse);
      // Valid withdraw
      expect(notifier.withdrawFromBank(1000.0), isTrue);
      expect(notifier.state.balance, equals(4000.0));
      expect(notifier.state.bankDepositBalance, equals(2000.0));

      container.dispose();
    });

    test('Phase 1: Stock trading validates WAC cost, %0.2 commission and negative lot bounds', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      final stock = StockModel(
        symbol: 'OTO',
        name: 'Otomotiv A.Ş.',
        currentPrice: 100.0,
        previousPrice: 95.0,
      );

      notifier.state = notifier.state.copyWith(
        balance: 100000.0,
        marketStocks: [stock],
        ownedStocks: [],
      );

      // Negative or zero lot buy must fail
      expect(notifier.buyStock('OTO', 0), isFalse);
      expect(notifier.buyStock('OTO', -5), isFalse);

      // Buy 100 shares at ₺100 (₺10,000 + %0.2 commission = ₺10,020)
      expect(notifier.buyStock('OTO', 100), isTrue);
      expect(notifier.state.balance, equals(100000.0 - 10020.0));
      expect(notifier.state.ownedStocks.first.quantity, equals(100));
      expect(notifier.state.ownedStocks.first.averageCost, equals(100.0));

      // Sell negative or more than owned must fail
      expect(notifier.sellStock('OTO', 0), isFalse);
      expect(notifier.sellStock('OTO', 150), isFalse);

      // Sell 50 shares at ₺100 (₺5,000 - %0.2 commission = ₺4,990)
      expect(notifier.sellStock('OTO', 50), isTrue);
      expect(notifier.state.ownedStocks.first.quantity, equals(50));
      expect(notifier.state.balance, equals(89980.0 + 4990.0));

      container.dispose();
    });

    test('Phase 1: Factoring early cashout applies factoring discount fee', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      final testCheque = Cheque(
        id: 'cheque_test_1',
        customerName: 'Alıcı İnşaat Ltd.',
        amount: 100000.0,
        daysUntilDue: 15,
      );

      notifier.state = notifier.state.copyWith(
        activeCheques: [testCheque],
        balance: 50000.0,
      );

      // Factoring discount 8%: ₺100,000 * 0.92 = ₺92,000 added
      final success = notifier.cashOutChequeEarly(testCheque.id);
      expect(success, isTrue);
      expect(notifier.state.balance, equals(50000.0 + 92000.0));
      expect(notifier.state.activeCheques.isEmpty, isTrue);

      container.dispose();
    });

    test('Phase 2: ReviewEngine generates context-aware ratings and handles dishonest declarations', () {
      final car = CarModel(
        id: 'review_car_1',
        brand: 'BMW',
        modelName: '320i',
        modelYear: 2021,
        bodyType: 'Sedan',
        colorHex: '#000000',
        baseMarketValue: 2000000.0,
        currentPurchasePrice: 1800000.0,
        isWashed: true,
        declarationType: ListingDeclarationType.honest,
        expertise: ExpertiseReport(
          engineCondition: 100,
          transmissionCondition: 100,
          isMileageTampered: false,
          bodyParts: {},
          tramerAmount: 0,
          mileage: 20000,
        ),
      );

      // Honest flawless declaration
      final honestResult = ReviewEngine.generateSaleReview(
        car: car,
        buyerName: 'Ahmet Bey',
        hasVipConcierge: false,
        hasVipLounge: false,
        hasTrophy: false,
        random: Random(42),
      );
      expect(honestResult.review.rating, equals(5.0));
      expect(honestResult.reputationChange, equals(5));
      expect(honestResult.review.comment.isNotEmpty, isTrue);

      // Dishonest / hidden flaw declaration penalties
      final dishonestCar = car.copyWith(declarationType: ListingDeclarationType.minorFlawHidden);
      final dishonestResult = ReviewEngine.generateSaleReview(
        car: dishonestCar,
        buyerName: 'Mehmet Bey',
        hasVipConcierge: false,
        hasVipLounge: false,
        hasTrophy: false,
        random: Random(42),
      );
      expect(dishonestResult.review.rating, lessThanOrEqualTo(2.5));
      expect(dishonestResult.reputationChange, equals(-4));
    });

    test('Phase 3: DistrictEconomyEngine scales market boost costs exponentially', () {
      final cost0 = DistrictEconomyEngine.calculateBoostCost(0.0);
      final cost50 = DistrictEconomyEngine.calculateBoostCost(0.50);
      final cost90 = DistrictEconomyEngine.calculateBoostCost(0.90);

      expect(cost0, equals(15000.0));
      expect(cost50, greaterThan(cost0));
      expect(cost90, greaterThan(cost50));
      expect(DistrictEconomyEngine.calculateBoostCost(1.0), equals(0.0));
    });

    test('Phase 4: BlackMarketEngine legal advisor mitigates raid fine and prevents seizure', () {
      final contrabandCar = CarModel(
        id: 'bm_contraband_1',
        brand: 'Mercedes-Benz',
        modelName: 'G63',
        modelYear: 2022,
        bodyType: 'SUV',
        colorHex: '#000000',
        baseMarketValue: 15000000.0,
        currentPurchasePrice: 8000000.0,
        blackMarketRiskType: 'change_vin',
        expertise: ExpertiseReport(
          engineCondition: 100,
          transmissionCondition: 100,
          isMileageTampered: false,
          bodyParts: {},
          tramerAmount: 0,
          mileage: 10000,
        ),
      );

      // Without lawyer: full fine ₺35,000, 20 rep loss, car seized
      final noLawyerResult = BlackMarketEngine.processRaid(
        car: contrabandCar,
        hasLegalAdvisor: false,
        random: Random(1),
      );
      expect(noLawyerResult.fine, equals(35000.0));
      expect(noLawyerResult.reputationLoss, equals(20));
      expect(noLawyerResult.shouldSeizeCar, isTrue);

      // With lawyer: 75% discounted fine ₺8,750, 5 rep loss, car NOT seized
      final lawyerResult = BlackMarketEngine.processRaid(
        car: contrabandCar,
        hasLegalAdvisor: true,
        random: Random(1),
      );
      expect(lawyerResult.fine, equals(8750.0));
      expect(lawyerResult.reputationLoss, equals(5));
      expect(lawyerResult.shouldSeizeCar, isFalse);
    });

    test('Phase 5: Branch upgrade validates level and capital requirements', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      final allBranches = BranchModel.getAllBranches();
      final branchTier2 = allBranches[1]; // Target level 2, requires capital

      notifier.state = notifier.state.copyWith(
        balance: 10000.0,
        level: 1,
        unlockedBuildings: {},
      );

      // Insufficient balance & level for branch upgrade
      expect(notifier.upgradeBranch(branchTier2), isFalse);
      expect(notifier.state.currentBranchTier, equals(1));

      // With sufficient level and balance
      notifier.state = notifier.state.copyWith(
        balance: branchTier2.requiredBalance + 50000.0,
        level: branchTier2.targetLevel,
      );
      expect(notifier.upgradeBranch(branchTier2), isTrue);
      expect(notifier.state.currentBranchTier, equals(2));

      container.dispose();
    });
  });
}

