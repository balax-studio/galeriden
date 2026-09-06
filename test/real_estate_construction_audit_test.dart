import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/real_estate_category.dart';
import 'package:galeriden/data/models/real_estate_model.dart';
import 'package:galeriden/domain/usecases/construction_timeline_engine.dart';
import 'package:galeriden/domain/usecases/real_estate_chat_negotiation_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Construction & Kat Karşılığı Audit Constitution Tests', () {
    late RealEstateModel sampleLand;

    setUp(() {
      sampleLand = RealEstateModel(
        id: 'test_land_1',
        title: 'Ataşehir Arsa Parseli',
        category: RealEstateCategory.land,
        city: 'İstanbul',
        district: 'Ataşehir',
        squareMeters: 1000,
        roomCount: 'Arsa',
        buildingAge: 0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 10000000.0,
        currentPurchasePrice: 10000000.0,
        deedFeePaid: 400000.0,
        commissionPaid: 200000.0,
        customUnitMix: const {
          'units1Plus0': 0,
          'units1Plus1': 4,
          'units2Plus0': 0,
          'units2Plus1': 4,
          'units3Plus1': 2,
          'units4Plus1': 0,
        },
      );
    });

    test('A1: Player share percentage calculation and unit allocation', () {
      // 10 units total
      expect(sampleLand.totalProjectUnits, 10);

      // Player negotiates 55% share
      final land55 = sampleLand.copyWith(playerSharePercent: 55);
      expect(land55.playerShareUnits, 5); // 10 * 55 / 100 = 5

      // Player negotiates 33% share
      final land33 = sampleLand.copyWith(playerSharePercent: 33);
      expect(land33.playerShareUnits, 3); // 10 * 33 / 100 = 3

      // Backward compatibility getter
      expect(land55.contractorSharePercent, 45);
      expect(land33.contractorSharePercent, 67);
    });

    test('A5: Negotiation engine acceptAgreement requires satisfaction >= 40', () {
      final stateLowSatisfaction = RealEstateChatNegotiationEngine.createContractorSession(
        landId: 'land_test',
        totalUnits: 10,
        baseMarketValue: 5000000.0,
      ).copyWith(satisfaction: 20);

      final stateRejected = RealEstateChatNegotiationEngine.executeTactic(
        state: stateLowSatisfaction,
        tactic: ChatTacticType.acceptAgreement,
        playerMessageText: 'Anlaştık',
        random: Random(42),
      );
      expect(stateRejected.isAgreed, isFalse);

      final stateHighSatisfaction = stateLowSatisfaction.copyWith(satisfaction: 60);
      final stateAgreed = RealEstateChatNegotiationEngine.executeTactic(
        state: stateHighSatisfaction,
        tactic: ChatTacticType.acceptAgreement,
        playerMessageText: 'Anlaştık',
        random: Random(42),
      );
      expect(stateAgreed.isAgreed, isTrue);
    });

    test('A5: demandCashDiscount is distinct from acceptAgreement and observes minPrice', () {
      final initialPrice = 1000000.0;
      final minPrice = 800000.0;
      final state = RealEstateChatNegotiationEngine.createContractorSession(
        landId: 'land_test',
        totalUnits: 10,
        baseMarketValue: initialPrice,
      ).copyWith(
        currentPrice: initialPrice,
        minPrice: minPrice,
      );

      final nextState = RealEstateChatNegotiationEngine.executeTactic(
        state: state,
        tactic: ChatTacticType.demandCashDiscount,
        playerMessageText: 'Peşin indirim istiyorum',
        random: Random(42),
      );

      // Should NOT automatically agree
      expect(nextState.isAgreed, isFalse);
      expect(nextState.currentPrice, greaterThanOrEqualTo(minPrice));
    });

    test('A6: Diminishing returns on askJokeOrChat', () {
      var state = RealEstateChatNegotiationEngine.createContractorSession(
        landId: 'land_test',
        totalUnits: 10,
        baseMarketValue: 5000000.0,
      ).copyWith(patience: 50, maxPatience: 100);

      // 1st joke
      state = RealEstateChatNegotiationEngine.executeTactic(
        state: state,
        tactic: ChatTacticType.askJokeOrChat,
        playerMessageText: 'Bir fıkra anlatayım',
        random: Random(42),
      );
      expect(state.jokeUseCount, 1);
      expect(state.patience, greaterThan(50));

      // 2nd joke
      state = RealEstateChatNegotiationEngine.executeTactic(
        state: state,
        tactic: ChatTacticType.askJokeOrChat,
        playerMessageText: 'Bir tane daha',
        random: Random(42),
      );
      expect(state.jokeUseCount, 2);

      // 3rd joke
      state = RealEstateChatNegotiationEngine.executeTactic(
        state: state,
        tactic: ChatTacticType.askJokeOrChat,
        playerMessageText: 'Son bir şaka',
        random: Random(42),
      );
      expect(state.jokeUseCount, 3);

      // 4th joke: should penalize patience
      final patienceBefore = state.patience;
      state = RealEstateChatNegotiationEngine.executeTactic(
        state: state,
        tactic: ChatTacticType.askJokeOrChat,
        playerMessageText: 'Bir espri daha',
        random: Random(42),
      );
      expect(state.jokeUseCount, 4);
      expect(state.patience, lessThan(patienceBefore));
    });

    test('B1 & B4: Stage cost calculation and self build initialization', () {
      final stage2Cost = ConstructionPricing.stageCost(sampleLand, 2);
      final stageDetails = ConstructionTimelineEngine.getStageDetails(2);
      expect(stage2Cost, (sampleLand.baseMarketValue * stageDetails.costPercentage).roundToDouble());

      // Duration calculation with durationMultiplier
      final daysStandard = ConstructionTimelineEngine.calculateStageDays(
        stageNumber: 2,
        parcelSquareMeters: 1000,
        tier: SubcontractorTier.standard,
      );
      final daysSpeed = ConstructionTimelineEngine.calculateStageDays(
        stageNumber: 2,
        parcelSquareMeters: 1000,
        durationMultiplier: 0.75,
      );
      expect(daysSpeed, lessThanOrEqualTo(daysStandard));
    });

    test('B10 & E0: LandPhase state machine transitions', () {
      // Unstarted without custom mix: imar
      final landNoMix = sampleLand.copyWith(clearCustomUnitMix: true);
      expect(landNoMix.landPhase, LandPhase.imar);

      // Unstarted with custom mix: modSecimi
      expect(sampleLand.landPhase, LandPhase.modSecimi);

      // Contractor active: muteahhitBekleme
      final landContractor = sampleLand.copyWith(
        constructionMode: 'contractor',
        constructionStage: 2,
        constructionDaysRemaining: 15,
      );
      expect(landContractor.landPhase, LandPhase.muteahhitBekleme);

      // Self build ready for subcontractor: etapHazir
      final landSelfBuildReady = sampleLand.copyWith(
        constructionMode: 'selfBuild',
        constructionStage: 2,
        isConstructionWorking: false,
        constructionDaysRemaining: 0,
      );
      expect(landSelfBuildReady.landPhase, LandPhase.etapHazir);

      // Self build working: etapCalisiyor
      final landSelfBuildWorking = sampleLand.copyWith(
        constructionMode: 'selfBuild',
        constructionStage: 2,
        isConstructionWorking: true,
        constructionDaysRemaining: 8,
      );
      expect(landSelfBuildWorking.landPhase, LandPhase.etapCalisiyor);

      // Completed construction: teslimeHazir
      final landComplete = sampleLand.copyWith(
        constructionMode: 'selfBuild',
        constructionStage: 8,
        isConstructionWorking: false,
        constructionDaysRemaining: 0,
      );
      expect(landComplete.isConstructionComplete, isTrue);
      expect(landComplete.landPhase, LandPhase.teslimeHazir);
    });

    test('C4: Unit acquisition cost includes land purchase, fees, and construction expenses', () {
      final landWithSpent = sampleLand.copyWith(
        constructionStage: 8,
        constructionDaysRemaining: 0,
        totalConstructionSpent: 5000000.0,
      );

      final totalInvested = landWithSpent.currentPurchasePrice +
          landWithSpent.deedFeePaid +
          landWithSpent.commissionPaid +
          landWithSpent.totalConstructionSpent;
      final unitsToCreate = landWithSpent.playerShareUnits;
      final costPerUnit = (totalInvested / unitsToCreate).roundToDouble();

      // Invested: 10M + 400k + 200k + 5M = 15.6M / 5 units = 3.12M per unit
      expect(costPerUnit, 3120000.0);
    });

    test('C7: copyWith clearConstructionMode clears active construction', () {
      final activeLand = sampleLand.copyWith(
        constructionMode: 'contractor',
        constructionStage: 4,
      );
      expect(activeLand.isConstructionActive, isTrue);

      final clearedLand = activeLand.copyWith(
        clearConstructionMode: true,
        constructionStage: 0,
        constructionDaysRemaining: 0,
      );
      expect(clearedLand.constructionMode, isNull);
      expect(clearedLand.isConstructionActive, isFalse);
    });
  });
}
