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
import 'package:galeriden/domain/usecases/gossip_engine.dart';
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
  });
}
