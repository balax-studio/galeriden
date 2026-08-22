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

void main() {
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
      expect(LoanSettlementEngine.calculateDailyTax(1), equals(150.0));
      expect(LoanSettlementEngine.calculateDailyTax(4), equals(450.0));
      expect(LoanSettlementEngine.calculateDailyTax(7), equals(1200.0));
      expect(LoanSettlementEngine.calculateDailyTax(10), equals(3500.0));
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
      expect(newBal, equals(6500.0)); // 5000 + 1000 * 1.5 = 6500
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
}
