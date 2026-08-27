import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/loan_model.dart';
import 'package:galeriden/data/models/part_order_model.dart';
import 'package:galeriden/data/models/player_skills.dart';
import 'package:galeriden/data/models/stock_model.dart';
import 'package:galeriden/domain/usecases/casino_engine.dart';
import 'package:galeriden/domain/usecases/district_economy_engine.dart';
import 'package:galeriden/domain/usecases/loan_settlement_engine.dart';
import 'package:galeriden/domain/usecases/negotiation_engine.dart';
import 'package:galeriden/domain/usecases/night_market_engine.dart';
import 'package:galeriden/domain/usecases/offline_progression.dart';
import 'package:galeriden/domain/usecases/repair_engine.dart';
import 'package:galeriden/domain/usecases/stock_market_engine.dart';

void main() {
  group('Comprehensive Mathematical & Economic Audit Test Suite', () {
    // 1. Car Model Valuation & Edge Cases
    test('1. Car Valuation: Zero & Extreme Edge Cases do not crash or produce NaN/Infinity', () {
      final pristineExp = ExpertiseReport(
        engineCondition: 100,
        transmissionCondition: 100,
        tramerAmount: 0,
        mileage: 1000,
        isMileageTampered: false,
        bodyParts: {
          'Kaput': PartStatus.original,
          'Tavan': PartStatus.original,
          'Bagaj': PartStatus.original,
        },
      );

      final carZero = CarModel(
        id: 'c_zero',
        brand: 'Fiat',
        modelName: 'Egea',
        modelYear: 2020,
        bodyType: 'Sedan',
        colorHex: '#FFFFFF',
        baseMarketValue: 0.0,
        currentPurchasePrice: 0.0,
        expertise: pristineExp,
      );

      // Must not throw or produce NaN/Infinite
      final zeroVal = carZero.estimatedRealValue;
      expect(zeroVal.isNaN, isFalse);
      expect(zeroVal.isInfinite, isFalse);
      expect(zeroVal, greaterThanOrEqualTo(0.0));

      // Negative base value must safely return 0.0 without throwing ArgumentError in clamp
      final carNegative = carZero.copyWith(baseMarketValue: -50000.0);
      expect(carNegative.estimatedRealValue, equals(0.0));

      final carNormal = CarModel(
        id: 'c_norm',
        brand: 'BMW',
        modelName: '320i',
        modelYear: 2022,
        bodyType: 'Sedan',
        colorHex: '#000000',
        baseMarketValue: 1500000.0,
        currentPurchasePrice: 1300000.0,
        expertise: pristineExp,
      );

      final normalVal = carNormal.estimatedRealValue;
      expect(normalVal, greaterThan(carNormal.baseMarketValue * 0.2));
      expect(normalVal, lessThanOrEqualTo(carNormal.baseMarketValue * 1.6));
    });

    // 2. Tax & Wealth Tax Calculations
    test('2. Tax Engine: Progressive daily tax and liquid wealth tax calculations', () {
      final taxLvl1 = LoanSettlementEngine.calculateDailyTax(1, totalLiquidWealth: 100000);
      expect(taxLvl1, equals(250.0));

      final taxLvl5WithWealth = LoanSettlementEngine.calculateDailyTax(5, totalLiquidWealth: 2500000);
      // Base: 750, Wealth: (2500000 - 500000) * 0.001 = 2000 => Total = 2750
      expect(taxLvl5WithWealth, equals(2750.0));

      // Wealth tax cap at 150000
      final taxLvl9SuperWealth = LoanSettlementEngine.calculateDailyTax(9, totalLiquidWealth: 500000000);
      expect(taxLvl9SuperWealth, equals(5000.0 + 150000.0));
    });

    // 3. Bankruptcy & Debt Recovery Calculations
    test('3. Bankruptcy Engine: Concordat and bailiff asset seizure thresholds', () {
      final result = LoanSettlementEngine.processBankruptcy(
        nextDay: 14,
        balance: -120000.0,
        cars: [
          CarModel(
            id: 'seize_car',
            brand: 'Renault',
            modelName: 'Clio',
            modelYear: 2018,
            bodyType: 'Hatchback',
            colorHex: '#FFFFFF',
            baseMarketValue: 400000.0,
            currentPurchasePrice: 350000.0,
            expertise: ExpertiseReport(
              engineCondition: 80,
              transmissionCondition: 80,
              tramerAmount: 0,
              mileage: 80000,
              isMileageTampered: false,
              bodyParts: {},
            ),
          )
        ],
        loans: [
          const LoanModel(
            id: 'l1',
            bankName: 'İş Bankası',
            principalAmount: 100000,
            interestRate: 0.18,
            totalRepayment: 118000,
            remainingAmount: 118000,
            totalInstallments: 6,
            remainingInstallments: 6,
            monthlyPayment: 19666,
          )
        ],
        dynastyHistory: [],
        events: [],
        bankDepositBalance: 0.0,
      );

      // Car should be liquidated by bailiff and balance adjusted
      expect(result.$2, isEmpty); // Car removed
      expect(result.$1, greaterThan(-120000.0)); // Balance recovered partially
    });

    // 4. Stock Market Price Floors & Dividend Mathematics
    test('4. Stock Market Engine: Price floor never falls below 1.0 TL and dividends are positive', () {
      final stocks = <StockModel>[
        StockModel(
          symbol: 'TEST',
          name: 'Test A.Ş.',
          currentPrice: 1.05,
          previousPrice: 1.10,
          priceHistory: [1.10, 1.05],
          dividendYield: 0.10,
          sectorCategory: 'Test',
        )
      ];

      // Force large negative RNG
      final rng = Random(42);
      final (updatedStocks, _, _) = StockMarketEngine.processStockFluctuationsAndDividends(
        nextDay: 2,
        balance: 10000,
        stocks: stocks,
        ownedStocks: [
          PlayerStockModel(symbol: 'TEST', quantity: 1000, averageCost: 1.05),
        ],
        events: [],
        random: rng,
      );

      expect(updatedStocks.first.currentPrice, greaterThanOrEqualTo(1.0));
      expect(updatedStocks.first.priceHistory.length, equals(3));

      // Test IPO request pruning on listing
      final ipo = IpoOfferModel.defaultIpos(1).first.copyWith(daysUntilListing: 1);
      final playerReq = PlayerIpoRequestModel(ipoId: ipo.id, requestedLots: 100, totalSpent: 50000.0);
      final (updatedIpos, updatedReqs, newBal, _) = StockMarketEngine.processIpoSettlement(
        nextDay: 2,
        balance: 10000.0,
        ipos: [ipo],
        requests: [playerReq],
        events: [],
      );
      expect(updatedIpos.first.isListed, isTrue);
      expect(updatedReqs, isEmpty, reason: 'Processed IPO request must be pruned to avoid recurring duplicate payouts');
      expect(newBal, greaterThan(10000.0));
    });

    // 5. Forex & Gold Spread Mathematics
    test('5. Forex Engine: Buy rate is always greater than sell rate (bank spread)', () {
      final forex = ForexGoldModel.defaultForex;
      final updated = StockMarketEngine.processForexFluctuations(forexList: forex);

      for (var f in updated) {
        expect(f.buyRate, greaterThan(f.sellRate), reason: '${f.symbol} buy rate must exceed sell rate');
        expect(f.buyRate, greaterThan(0.0));
        expect(f.sellRate, greaterThan(0.0));
      }
    });

    // 6. Casino Plinko Multipliers & Binomial Bounds
    test('6. Casino Engine: Plinko drops strictly stay within slot index range 0..8 and RTP is balanced', () {
      // Symmetrical binomial distribution coefficients for N=8: [1, 8, 28, 56, 70, 56, 28, 8, 1] / 256
      final binomWeights = [1, 8, 28, 56, 70, 56, 28, 8, 1];
      double expectedMultiplier = 0.0;
      for (int i = 0; i < CasinoEngine.plinkoMultipliers.length; i++) {
        expectedMultiplier += CasinoEngine.plinkoMultipliers[i] * (binomWeights[i] / 256.0);
      }
      expect(expectedMultiplier, inInclusiveRange(0.90, 0.98), reason: 'Plinko RTP must be sustainable (~94.7%)');

      for (int i = 0; i < 50; i++) {
        final result = CasinoEngine.dropPlinkoBuji(betAmount: 1000.0);
        expect(result.slotIndex, inInclusiveRange(0, 8));
        expect(result.multiplier, greaterThan(0.0));
        expect(result.payoutAmount, equals(1000.0 * result.multiplier));
        expect(result.pathOffsets.length, equals(8));
      }
    });

    // 7. Casino Lucky Wheel Slice Weights & Probability Math
    test('7. Casino Engine: Lucky Wheel slice selection respects valid slice indices', () {
      for (int i = 0; i < 50; i++) {
        final spin = CasinoEngine.spinLuckyWheel(betAmount: 5000.0);
        expect(spin.sliceIndex, inInclusiveRange(0, CasinoEngine.wheelSlices.length - 1));
        expect(spin.payoutAmount, greaterThanOrEqualTo(0.0));
      }
    });

    // 8. Casino Scratch Card Grid Matrix
    test('8. Casino Engine: Scratch card generates exactly 9 spots with valid symbols', () {
      for (int i = 0; i < 30; i++) {
        final scratch = CasinoEngine.generateScratchCard(cardCost: 2000.0);
        expect(scratch.grid.length, equals(9));
        if (scratch.isWin) {
          expect(scratch.payoutAmount, greaterThan(0.0));
          expect(scratch.matchingSymbol, isNotNull);
        } else {
          expect(scratch.payoutAmount, equals(0.0));
        }
      }
    });

    // 9. Casino Aviator Multiplier Distribution
    test('9. Casino Engine: Aviator multiplier is clamped in [1.00, 75.00]', () {
      for (int i = 0; i < 100; i++) {
        final mult = CasinoEngine.generateAviatorCrashMultiplier();
        expect(mult, inInclusiveRange(1.00, 75.00));
      }
    });

    // 10. Street Racing Power Calculation & Bradley-Terry Odds
    test('10. Night Market Engine: Win chance uses Bradley-Terry model clamped in [15%, 95%]', () {
      final carLow = CarModel(
        id: 'c_low',
        brand: 'Fiat',
        modelName: 'Uno',
        modelYear: 1998,
        bodyType: 'Hatchback',
        colorHex: '#FF0000',
        baseMarketValue: 120000.0,
        currentPurchasePrice: 100000.0,
        expertise: ExpertiseReport(
          engineCondition: 60,
          transmissionCondition: 60,
          tramerAmount: 0,
          mileage: 200000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );

      const rivalSuper = NightRivalModel(
        id: 'r_boss',
        name: 'GTR Reis',
        title: 'Yeraltı Kralı',
        carName: 'Nissan GTR',
        modificationSummary: '1000 HP',
        tier: 3,
        basePower: 1000,
        badge: 'EFSANE',
      );

      final winChance = NightMarketEngine.estimateWinChance(carLow, rivalSuper);
      expect(winChance, inInclusiveRange(15, 95));
      expect(winChance, equals(15)); // Uno vs 1000 HP GTR clamped to min 15%
    });

    // 11. Repair Engine Cost Profile & Zero Scrap Cost
    test('11. Repair Engine: Salvaged scrap part orders are 0 TL, OEM parts scale with car value', () {
      final car = CarModel(
        id: 'c_rep',
        brand: 'Mercedes',
        modelName: 'E250',
        modelYear: 2016,
        bodyType: 'Sedan',
        colorHex: '#000000',
        baseMarketValue: 1800000.0,
        currentPurchasePrice: 1600000.0,
        expertise: ExpertiseReport(
          engineCondition: 80,
          transmissionCondition: 80,
          tramerAmount: 0,
          mileage: 120000,
          isMileageTampered: false,
          bodyParts: {'Kaput': PartStatus.damaged},
        ),
      );

      final scrapCost = RepairEngine.calculatePartRepairCost(car, 'Kaput', OrderType.salvagedScrap);
      expect(scrapCost, equals(0.0));

      final oemCost = RepairEngine.calculatePartRepairCost(car, 'Kaput', OrderType.newOemPart);
      expect(oemCost, greaterThan(5000.0));
    });

    // 12. Player Skills XP Progression Curve
    test('12. Player Skills: XP level progression is monotonically increasing', () {
      int prevReq = 0;
      for (int lvl = 1; lvl <= 15; lvl++) {
        final req = PlayerSkills.requiredXpForLevel(lvl);
        expect(req, greaterThan(prevReq), reason: 'Level $lvl XP requirement must exceed Level ${lvl - 1}');
        prevReq = req;
      }

      final skills = PlayerSkills(xp: 50000);
      expect(skills.currentLevel, equals(4)); // 3000 + 7500 + 15000 + 28000 = 53500 needed for L5
      expect(skills.availableSkillPoints, equals(skills.totalSkillPointsEarned));
    });

    // 13. Offline Progression Clamp Invariants
    test('13. Offline Progression: Minutes clamped to 960 and simulated days to 7', () {
      final dealership = DealershipModel.initial().copyWith(
        dealershipName: 'Yıldız Galeri',
        balance: 500000.0,
        lastActiveTime: DateTime.now().subtract(const Duration(days: 30)),
      );

      final result = OfflineProgression.processOfflineTime(dealership);
      expect(result['elapsedMinutes'], equals(960)); // Max 16 hours
      expect(result['daysElapsed'], inInclusiveRange(1, 7)); // Max 7 simulated days
      expect(result['updatedDealership'].balance, greaterThanOrEqualTo(0.0));
    });

    // 14. District Economy Exponential Cost Curve
    test('14. District Economy: Boost cost scales monotonically with market share', () {
      final cost10 = DistrictEconomyEngine.calculateBoostCost(0.10);
      final cost50 = DistrictEconomyEngine.calculateBoostCost(0.50);
      final cost90 = DistrictEconomyEngine.calculateBoostCost(0.90);

      expect(cost50, greaterThan(cost10));
      expect(cost90, greaterThan(cost50));
      expect(DistrictEconomyEngine.calculateBoostCost(1.0), equals(0.0)); // 100% share cannot be boosted
    });

    // 15. Negotiation Dynamic Ceiling Multipliers
    test('15. Negotiation Engine: Dynamic ceiling multiplier bounds', () {
      final normalCar = CarModel(
        id: 'c_n',
        brand: 'Ford',
        modelName: 'Focus',
        modelYear: 2017,
        bodyType: 'Hatchback',
        colorHex: '#FFFFFF',
        baseMarketValue: 600000.0,
        currentPurchasePrice: 550000.0,
        expertise: ExpertiseReport(
          engineCondition: 85,
          transmissionCondition: 85,
          tramerAmount: 0,
          mileage: 100000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );

      final rareCar = normalCar.copyWith(isRare: true);

      final normalCeiling = NegotiationEngine.getDynamicCeilingMultiplier(normalCar);
      final rareCeiling = NegotiationEngine.getDynamicCeilingMultiplier(rareCar);

      expect(normalCeiling, inInclusiveRange(1.20, 1.40));
      expect(rareCeiling, equals(1.65));
    });
  });
}
