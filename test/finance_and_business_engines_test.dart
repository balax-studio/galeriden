import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/loan_model.dart';
import 'package:galeriden/data/models/installment_contract_model.dart';
import 'package:galeriden/data/models/cheque_model.dart';
import 'package:galeriden/data/models/stock_model.dart';
import 'package:galeriden/data/models/rental_agreement_model.dart';
import 'package:galeriden/data/models/side_business_model.dart';
import 'package:galeriden/domain/usecases/loan_settlement_engine.dart';
import 'package:galeriden/domain/usecases/stock_market_engine.dart';
import 'package:galeriden/domain/usecases/rental_progression_engine.dart';
import 'package:galeriden/domain/usecases/side_business_engine.dart';
import 'package:galeriden/domain/usecases/negotiation_engine.dart';
import 'package:galeriden/data/models/real_estate_model.dart';
import 'package:galeriden/data/models/tenant_model.dart';
import 'package:galeriden/data/models/real_estate_category.dart';
import 'package:galeriden/domain/usecases/cashflow_engine.dart';
import 'package:galeriden/domain/usecases/consignment_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/offer_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/providers/game/game_finance_mixin.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
  group('LoanSettlementEngine Tests', () {
    test('processWeeklyLoans deducts payments only on 7th day and removes completed loans', () {
      const loan = LoanModel(
        id: 'loan_1',
        bankName: 'Esnaf Bankası',
        principalAmount: 70000.0,
        interestRate: 0.10,
        totalRepayment: 70000.0,
        remainingAmount: 10000.0,
        totalInstallments: 7,
        remainingInstallments: 1,
        monthlyPayment: 10000.0,
      );

      // Day 6 (no payment)
      final (balDay6, loansDay6) = LoanSettlementEngine.processWeeklyLoans(
        nextDay: 6,
        balance: 50000.0,
        loans: [loan],
      );
      expect(balDay6, equals(50000.0));
      expect(loansDay6.length, equals(1));

      // Day 7 (payment deducted and loan completes)
      final (balDay7, loansDay7) = LoanSettlementEngine.processWeeklyLoans(
        nextDay: 7,
        balance: 50000.0,
        loans: [loan],
      );
      expect(balDay7, equals(40000.0));
      expect(loansDay7, isEmpty);
    });

    test('processInstallments deducts regular payment and updates remaining count', () {
      final contract = InstallmentContract(
        id: 'inst_1',
        customerName: 'Ahmet Bey',
        totalAmount: 120000.0,
        paidAmount: 20000.0,
        installmentAmount: 20000.0,
        totalInstallments: 6,
        paidInstallments: 1,
        daysUntilNextPayment: 1,
      );

      final (newBal, updatedList) = LoanSettlementEngine.processInstallments(
        balance: 10000.0,
        installments: [contract],
        random: Random(42),
      );

      expect(newBal, equals(30000.0));
      expect(updatedList.first.paidInstallments, equals(2));
      expect(updatedList.first.daysUntilNextPayment, equals(30));
    });

    test('processCheques clears due cheques and processes legal recovery', () {
      final matureCheque = Cheque(
        id: 'chq_1',
        customerName: 'Güven Oto',
        amount: 50000.0,
        daysUntilDue: 1,
      );

      final legalCheque = Cheque(
        id: 'chq_2',
        customerName: 'Batık Ltd',
        amount: 100000.0,
        daysUntilDue: 0,
        inLegalCollection: true,
        legalCollectionDaysRemaining: 1,
      );

      final (bal, remaining) = LoanSettlementEngine.processCheques(
        balance: 0.0,
        cheques: [matureCheque, legalCheque],
        chequeRiskReduction: 0.05,
        random: Random(99),
      );

      // matureCheque paid 50000 + legalCheque recovered 75% (75000) = 125000
      expect(bal, equals(125000.0));
      expect(remaining, isEmpty);
    });

    test('calculateDailyTax scales properly by level', () {
      expect(LoanSettlementEngine.calculateDailyTax(1), equals(250.0));
      expect(LoanSettlementEngine.calculateDailyTax(4), equals(750.0));
      expect(LoanSettlementEngine.calculateDailyTax(7), equals(2000.0));
      expect(LoanSettlementEngine.calculateDailyTax(10), equals(5000.0));
    });
  });

  group('StockMarketEngine Tests', () {
    test('processStockFluctuationsAndDividends updates prices and adds dividend earnings', () {
      final stock = StockModel(
        symbol: 'FROTO',
        name: 'Ford Otosan',
        currentPrice: 1000.0,
        previousPrice: 1000.0,
        priceHistory: [1000.0],
        dividendYield: 0.10,
        sectorCategory: 'Otomotiv & Sanayi',
      );

      final owned = PlayerStockModel(
        symbol: 'FROTO',
        quantity: 365,
        averageCost: 1000.0,
      );

      final (stocks, newBal, events) = StockMarketEngine.processStockFluctuationsAndDividends(
        nextDay: 5,
        balance: 10000.0,
        stocks: [stock],
        ownedStocks: [owned],
        events: [],
        random: Random(42),
      );

      expect(stocks.first.priceHistory.length, equals(2));
      expect(newBal, greaterThan(10000.0));
      expect(events.any((e) => e.id.contains('dividend')), isTrue);
    });

    test('processForexFluctuations tracks buy and sell rates', () {
      const forex = ForexGoldModel(
        symbol: 'USD',
        name: 'Amerikan Doları',
        buyRate: 36.0,
        sellRate: 35.6,
        previousRate: 36.0,
        rateHistory: [36.0],
      );

      final updated = StockMarketEngine.processForexFluctuations(
        forexList: [forex],
        random: Random(42),
      );

      expect(updated.first.rateHistory.length, equals(2));
      expect(updated.first.buyRate, greaterThan(0.0));
      expect(updated.first.sellRate, lessThan(updated.first.buyRate));
    });

    test('processIpoSettlement triggers payout on listing day', () {
      const ipo = IpoOfferModel(
        id: 'ipo_test',
        symbol: 'TEST',
        companyName: 'Test Holding',
        lotPrice: 100.0,
        totalLotsAvailable: 1000,
        daysUntilListing: 1,
        listingMultiplier: 1.50,
        description: 'Test Halka Arz',
      );

      const playerReq = PlayerIpoRequestModel(
        ipoId: 'ipo_test',
        requestedLots: 10,
        totalSpent: 1000.0,
      );

      final (ipos, reqs, newBal, events) = StockMarketEngine.processIpoSettlement(
        nextDay: 10,
        balance: 5000.0,
        ipos: [ipo],
        requests: [playerReq],
        events: [],
      );

      expect(ipos.first.isListed, isTrue);
      expect(newBal, greaterThanOrEqualTo(5850.0)); // 5000 + 1000 * outcome multiplier
      expect(events.first.id, contains('ipo_listed_ipo_test_10'));
    });
  });

  group('RentalProgressionEngine Tests', () {
    test('processDailyRentals collects net daily earnings', () {
      final car = CarModel(
        id: 'car_rent_1',
        brand: 'Renault',
        modelName: 'Clio',
        modelYear: 2022,
        bodyType: 'Hatchback',
        colorHex: '0xFFFFFFFF',
        currentPurchasePrice: 600000.0,
        baseMarketValue: 600000.0,
        expertise: ExpertiseReport(
          engineCondition: 100,
          transmissionCondition: 100,
          tramerAmount: 0,
          mileage: 45000,
          isMileageTampered: false,
          bodyParts: {},
        ),
        isRented: true,
      );

      final rental = RentalAgreement(
        id: 'rent_1',
        carId: 'car_rent_1',
        renterName: 'Mehmet Yılmaz',
        renterType: 'corporate',
        dailyRate: 2000.0,
        hasInsurance: true,
        insuranceDailyFee: 300.0,
      );

      final (bal, cars, rentals, events, offers) = RentalProgressionEngine.processDailyRentals(
        balance: 10000.0,
        cars: [car],
        rentals: [rental],
        events: [],
        incomingOffers: [],
        random: Random(10),
      );

      expect(bal, greaterThanOrEqualTo(10000.0 + 1700.0));
      expect(rentals.first.totalEarned, equals(1700.0));
      expect(rentals.first.rentedDays, equals(1));
    });
  });

  group('SideBusinessEngine Tests', () {
    test('processDailyEarnings calculates passive revenue with specialization bonus and billboard synergy', () {
      final rentalBiz = SideBusinessModel(
        id: 'carRental',
        type: SideBusinessType.carRental,
        name: 'Filo Kiralama',
        level: 1,
        isOwned: true,
        dailyIncome: 1000.0,
        cost: 50000.0,
        totalEarned: 0.0,
      );

      final billboardBiz = SideBusinessModel(
        id: 'billboard',
        type: SideBusinessType.billboard,
        name: 'Totem Tabela',
        level: 1,
        isOwned: true,
        dailyIncome: 500.0,
        cost: 25000.0,
        totalEarned: 0.0,
      );

      // With boss specialization (1.3x) & billboard synergy (+15% on rental fleet)
      final (bal, updatedBusinesses) = SideBusinessEngine.processDailyEarnings(
        balance: 0.0,
        cars: [],
        businesses: [rentalBiz, billboardBiz],
        specializationPath: SpecializationPath.boss,
        carsWashedLast7Days: 0,
        expertisesPerformedLast7Days: 0,
        partsRepairedLast7Days: 0,
        towedCarsLast7Days: 0,
        activeRentalsCount: 2,
      );

      expect(bal, greaterThan(0.0));
      expect(updatedBusinesses.first.totalEarned, greaterThan(0.0));
      expect(updatedBusinesses[1].totalEarned, greaterThan(0.0));
    });
  });

  group('NegotiationEngine Esnaf Tactics Tests', () {
    test('executeEsnafAction with ortak_arayayim gives bonus acceptance chance without increasing player offer', () {
      final res = NegotiationEngine.executeEsnafAction(
        actionType: 'ortak_arayayim',
        currentOffer: 400000.0,
        askingPrice: 500000.0,
        negotiationSkillLevel: 3,
      );

      expect(res.containsKey('success'), isTrue);
      expect(res.containsKey('bonusChance'), isTrue);
      expect(res['priceShift'], isNull); // Ensures player offer is not shifted up
      if (res['success'] == true) {
        expect(res['bonusChance'], equals(22)); // 16 + (3 * 2) = 22
      }
    });
  });

  group('Finance Gating & Installment Lock Suite', () {
    final testCar = CarModel(
      id: 'car_install_test',
      brand: 'Bemeve',
      modelName: 'Üç Yirmi Dizel',
      modelYear: 2021,
      bodyType: 'Sedan',
      colorHex: '#FFFFFF',
      baseMarketValue: 1200000,
      currentPurchasePrice: 1100000,
      allowsInstallments: true,
      expertise: ExpertiseReport(
        engineCondition: 100.0,
        transmissionCondition: 100.0,
        tramerAmount: 0,
        mileage: 45000,
        isMileageTampered: false,
        bodyParts: {},
      ),
    );

    test('DealershipModel required level for /finance is 5; unlockedBuildings controls feature access', () {
      expect(DealershipModel.getRequiredLevel('/finance'), equals(5));

      final earlyGame = DealershipModel.initial();
      expect(earlyGame.isFeatureUnlocked('/finance'), isFalse);

      final financeGame = DealershipModel.initial().copyWith(unlockedBuildings: {'/finance'});
      expect(financeGame.isFeatureUnlocked('/finance'), isTrue);
    });

    test('When finance is locked (isFinanceUnlocked: false), offers are 100% CASH only', () {
      for (int i = 0; i < 50; i++) {
        final offer = NegotiationEngine.generateBuyerOffer(
          testCar,
          testCar.listingPrice,
          isFinanceUnlocked: false,
        );

        expect(offer.offerType, equals(OfferType.cash));
        expect(offer.installmentMonths, equals(0));
        expect(offer.buyerMessage.contains('senetle'), isFalse);
        expect(offer.buyerMessage.contains('çekle'), isFalse);
      }
    });

    test('When finance is unlocked (isFinanceUnlocked: true), installment and cheque offers generate', () {
      int installmentOrChequeCount = 0;
      for (int i = 0; i < 50; i++) {
        final offer = NegotiationEngine.generateBuyerOffer(
          testCar,
          testCar.listingPrice,
          isFinanceUnlocked: true,
        );

        if (offer.offerType == OfferType.installment || offer.offerType == OfferType.cheque) {
          installmentOrChequeCount++;
        }
      }

      expect(installmentOrChequeCount, greaterThan(15));
    });

    test('Invariant checks: zero parentheses and zero emojis in generated messages', () {
      for (int i = 0; i < 20; i++) {
        final offer = NegotiationEngine.generateBuyerOffer(
          testCar,
          testCar.listingPrice,
          isFinanceUnlocked: true,
        );

        expect(offer.buyerMessage.contains('('), isFalse);
        expect(offer.buyerMessage.contains(')'), isFalse);

        final emojiRegex = RegExp(r'[\u{1F300}-\u{1F9FF}]|[\u{2600}-\u{26FF}]', unicode: true);
        expect(emojiRegex.hasMatch(offer.buyerMessage), isFalse);
      }
    });
  });

  group('Finance Collection & Liquidity Micro Suite', () {
    test('Cheque factoring / early discount calculation & cash-out works', () {
      final cheque = Cheque(
        id: 'chq_1',
        customerName: 'Ahmet Bey',
        amount: 100000.0,
        daysUntilDue: 15,
      );

      expect(cheque.calculateFactoringCash(discountRate: 0.08), equals(92000.0));
      expect(cheque.calculateFactoringDiscount(discountRate: 0.08), equals(8000.0));

      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        balance: 10000.0,
        activeCheques: [cheque],
      );

      final success = notifier.cashOutChequeEarly('chq_1', discountRate: 0.08);
      expect(success, isTrue);
      expect(notifier.state.balance, equals(102000.0));
      expect(notifier.state.activeCheques.isEmpty, isTrue);
    });

    test('Defaulted cheque can be sent to legal collection and recovers funds over time', () {
      final defaultedCheque = Cheque(
        id: 'chq_bad',
        customerName: 'Dolandırıcı Niyazi',
        amount: 80000.0,
        daysUntilDue: 0,
        isDefaulted: true,
      );

      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        balance: 50000.0,
        activeCheques: [defaultedCheque],
      );

      final sentToLegal = notifier.sendChequeToLegalCollection('chq_bad');
      expect(sentToLegal, isTrue);
      expect(notifier.state.balance, equals(48500.0));
      expect(notifier.state.activeCheques.first.inLegalCollection, isTrue);
      expect(notifier.state.activeCheques.first.legalCollectionDaysRemaining, equals(5));

      for (int i = 0; i < 5; i++) {
        notifier.advanceGameDay();
      }

      expect(notifier.state.activeCheques.any((c) => c.id == 'chq_bad'), isFalse);
      expect(notifier.state.balance, greaterThan(100000.0));
    });

    test('Installment early settlement discount gives cash upfront & closes contract', () {
      final contract = InstallmentContract(
        id: 'inst_1',
        customerName: 'Mehmet Usta',
        totalAmount: 120000.0,
        paidAmount: 40000.0,
        installmentAmount: 10000.0,
        totalInstallments: 12,
        paidInstallments: 4,
        daysUntilNextPayment: 10,
      );

      expect(contract.remainingAmount, equals(80000.0));
      expect(contract.calculateEarlySettlementCash(discountRate: 0.05), equals(76000.0));
      expect(contract.calculateEarlySettlementDiscount(discountRate: 0.05), equals(4000.0));

      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        balance: 20000.0,
        activeInstallments: [contract],
      );

      final settled = notifier.settleInstallmentEarly('inst_1', discountRate: 0.05);
      expect(settled, isTrue);
      expect(notifier.state.balance, equals(96000.0));
      expect(notifier.state.activeInstallments.isEmpty, isTrue);
    });

    test('Liquidity & Financial Safety ratio categorizes dealer solvency accurately', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        balance: 500000.0,
        activeLoans: const [],
        dailyTaxRate: 150.0,
      );

      final status1 = notifier.calculateLiquidityStatus();
      expect(status1.level, equals(LiquidityLevel.strong));
      expect(status1.badgeLabel, contains('Sağlam'));

      notifier.state = notifier.state.copyWith(
        balance: 10000.0,
        activeLoans: [
          LoanModel(
            id: 'loan_big',
            bankName: 'Devlet Bankası',
            principalAmount: 1000000.0,
            remainingAmount: 900000.0,
            monthlyPayment: 75000.0,
            totalInstallments: 12,
            remainingInstallments: 12,
            interestRate: 0.04,
            totalRepayment: 1040000.0,
          ),
        ],
      );

      final status2 = notifier.calculateLiquidityStatus();
      expect(status2.level, equals(LiquidityLevel.tight));
      expect(status2.badgeLabel, contains('Nakit'));
    });
  });

  group('CashflowEngine & Effective Daily Tax Tests', () {
    test('effectiveDailyTax calculates dynamic progressive tax from LoanSettlementEngine', () {
      final baseDealer = DealershipModel.initial();
      expect(baseDealer.level, 1);
      // Level 1 base tax is 250.0 (wealth tax = 0 since balance <= 500k)
      expect(baseDealer.effectiveDailyTax, 250.0);
      expect(baseDealer.dailyTaxRate, 250.0);

      // Level 8 top tier corporate tax (5000.0) + wealth tax on 1.5M liquid assets (1.5M - 500k = 1M * 0.001 = 1000.0)
      final wealthyPlaza = baseDealer.copyWith(
        level: 8,
        balance: 1000000.0,
        bankDepositBalance: 500000.0,
      );
      expect(wealthyPlaza.effectiveDailyTax, 5000.0 + 1000.0);
      expect(wealthyPlaza.dailyTaxRate, wealthyPlaza.effectiveDailyTax);
    });

    test('CashflowEngine computes weekly loan proration, real estate rent, consignment parking, and deeds', () {
      final baseDealer = DealershipModel.initial();

      final activeLoan = LoanModel(
        id: 'loan_1',
        bankName: 'Girişimci Bankası',
        principalAmount: 70000.0,
        remainingAmount: 70000.0,
        totalRepayment: 70000.0,
        totalInstallments: 10,
        monthlyPayment: 7000.0,
        remainingInstallments: 10,
        interestRate: 0.1,
      );

      final rentedProperty = RealEstateModel(
        id: 'prop_apt_1',
        title: 'Lüks Rezidans Dairesi',
        category: RealEstateCategory.housing,
        city: 'İstanbul',
        district: 'Merkez',
        squareMeters: 120,
        roomCount: '3+1',
        buildingAge: 5,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        currentPurchasePrice: 2500000.0,
        baseMarketValue: 2500000.0,
        currentTenant: const TenantModel(
          id: 'tenant_1',
          name: 'Ahmet Bey',
          profession: 'Mühendis',
          monthlyRent: 30000.0,
          reliabilityScore: 90,
          evictionRiskScore: 10,
          depositAmount: 60000.0,
        ),
        isRented: true,
      );

      final consignmentCar = CarModel(
        id: 'car_consignment_1',
        brand: 'Mercedo',
        modelName: 'C200',
        modelYear: 2021,
        bodyType: 'Sedan',
        currentPurchasePrice: 0.0,
        baseMarketValue: 1500000.0,
        colorHex: '#FFFFFF',
        isConsignment: true,
        consignmentCommissionRate: 0.08,
        expertise: ExpertiseReport(
          engineCondition: 90.0,
          transmissionCondition: 90.0,
          tramerAmount: 0,
          mileage: 50000,
          isMileageTampered: false,
          bodyParts: const {},
        ),
      );

      final rentalAgreement = RentalAgreement(
        id: 'rental_1',
        carId: 'car_rent_1',
        renterName: 'Kiralık Müşteri',
        dailyRate: 1500.0,
      );

      final testDealer = baseDealer.copyWith(
        activeLoans: [activeLoan],
        ownedRealEstates: [rentedProperty],
        ownedCars: [consignmentCar],
        activeRentals: [rentalAgreement],
        ownedBranchDeeds: {'branch_1'},
      );

      final summary = CashflowEngine.calculate(testDealer);

      // Loan daily payment must be 7000 / 7 = 1000.0
      expect(summary.loanDailyPayment, 1000.0);

      // Real estate rent income must be 1000.0
      expect(summary.realEstateRentIncome, 1000.0);

      // Vehicle rental is 1500.0, combined rental is 2500.0
      expect(summary.rentalDailyIncome, 2500.0);

      // Consignment parking fee for Tier 1 branch is 300.0
      expect(summary.consignmentParkingIncome, ConsignmentEngine.calculateDailyParkingFee(1));
      expect(summary.consignmentParkingIncome, 300.0);

      // Deed dues must be 1 * 1250.0 = 1250.0
      expect(summary.deedDues, 1250.0);

      // Daily tax estimate must match effectiveDailyTax
      expect(summary.dailyTaxEstimate, testDealer.effectiveDailyTax);
    });
  });
}
