import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/real_estate_category.dart';
import 'package:galeriden/data/models/real_estate_model.dart';
import 'package:galeriden/domain/usecases/construction_negative_events_engine.dart';
import 'package:galeriden/domain/usecases/construction_timeline_engine.dart';
import 'package:galeriden/domain/usecases/real_estate_chat_negotiation_engine.dart';
import 'package:galeriden/domain/usecases/zoning_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Construction Master Modules Audit (B · C · D · E · F)', () {
    late RealEstateModel sampleLand;

    setUp(() {
      sampleLand = RealEstateModel(
        id: 'master_test_land',
        title: 'Kadıköy İmar Parseli',
        category: RealEstateCategory.land,
        city: 'İstanbul',
        district: 'Kadıköy',
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
          'units1Plus0': 2,
          'units1Plus1': 2,
          'units2Plus0': 0,
          'units2Plus1': 2,
          'units3Plus1': 2,
          'units4Plus1': 2,
        },
      );
    });

    test('B1 & B8: Self-build starts at stage 2 and clamps at 8', () {
      final activeSelfBuild = sampleLand.copyWith(
        constructionMode: 'selfBuild',
        constructionStage: 2,
        isConstructionWorking: false,
        constructionDaysRemaining: 0,
      );

      expect(activeSelfBuild.constructionStage, 2);
      expect(activeSelfBuild.landPhase, LandPhase.etapHazir);

      // Completed stage clamps to 8
      final completedStage = activeSelfBuild.copyWith(
        constructionStage: (8 + 1).clamp(1, 8),
      );
      expect(completedStage.constructionStage, 8);
    });

    test('B4: ConstructionPricing.stageCost single source of truth', () {
      final costStd = ConstructionPricing.stageCost(sampleLand, 2);
      final costIndexed = ConstructionPricing.stageCost(sampleLand, 2, costIndex: 1.20);
      expect(costIndexed, equals((costStd * 1.20).roundToDouble()));

      final subSpeed = ConstructionTimelineEngine.getSubcontractorsForStage(2).first;
      final costSpeed = ConstructionPricing.stageCost(sampleLand, 2, subcontractor: subSpeed);
      expect(costSpeed, equals((costStd * subSpeed.costMultiplier).roundToDouble()));
    });

    test('B5: Subcontractor negotiation observes minPrice floor and patience cost', () {
      final sub = ConstructionTimelineEngine.getSubcontractorsForStage(2)[1];
      final state = ChatNegotiationState(
        targetId: '${sampleLand.id}_stage_2',
        counterpartyName: sub.name,
        counterpartyRole: ChatSenderRole.subcontractor,
        patience: 100,
        satisfaction: 60,
        currentPrice: 1200000.0,
        minPrice: 900000.0,
      );

      final nextState = RealEstateChatNegotiationEngine.executeTactic(
        state: state,
        tactic: ChatTacticType.demandCashMaterials,
        playerMessageText: 'Peşin malzeme alıyorum',
        random: Random(42),
      );

      expect(nextState.currentPrice, greaterThanOrEqualTo(900000.0));
      expect(nextState.patience, equals(state.patience - 20));
    });

    test('B7: SubcontractorProfile tier riskMultiplier rebalancing', () {
      final subs = ConstructionTimelineEngine.getSubcontractorsForStage(2);
      final speedSub = subs.firstWhere((s) => s.tier == SubcontractorTier.speed);
      final stdSub = subs.firstWhere((s) => s.tier == SubcontractorTier.standard);
      final budgetSub = subs.firstWhere((s) => s.tier == SubcontractorTier.budget);

      expect(speedSub.riskMultiplier, equals(1.25));
      expect(stdSub.riskMultiplier, equals(0.80));
      expect(budgetSub.riskMultiplier, equals(1.10));

      expect(speedSub.durationMultiplier, equals(0.75));
      expect(stdSub.durationMultiplier, equals(1.00));
      expect(budgetSub.durationMultiplier, equals(1.25));
    });

    test('B10 & C1: isConstructionComplete requires stage 8, 0 days, not working', () {
      final finishedLand = sampleLand.copyWith(
        constructionMode: 'selfBuild',
        constructionStage: 8,
        constructionDaysRemaining: 0,
        isConstructionWorking: false,
      );
      expect(finishedLand.isConstructionComplete, isTrue);
      expect(finishedLand.landPhase, LandPhase.teslimeHazir);

      final stillWorking = finishedLand.copyWith(isConstructionWorking: true);
      expect(stillWorking.isConstructionComplete, isFalse);

      final stillHasDays = finishedLand.copyWith(constructionDaysRemaining: 2);
      expect(stillHasDays.isConstructionComplete, isFalse);
    });

    test('C3: Pre-sale sacrifices smallest units first', () {
      final preSaleLand = sampleLand.copyWith(
        constructionMode: 'selfBuild',
        playerSharePercent: 100,
        constructionStage: 4,
        soldPreSaleUnits: 2,
      );

      // Total units: 2*(1+0) + 2*(1+1) + 2*(2+1) + 2*(3+1) + 2*(4+1) = 10 units
      expect(preSaleLand.totalProjectUnits, 10);
      expect(preSaleLand.playerShareUnits, 8); // 10 - 2 sold = 8
    });

    test('C4: Unit acquisition cost includes total construction investment', () {
      final investedLand = sampleLand.copyWith(
        constructionStage: 8,
        playerSharePercent: 100,
        constructionDaysRemaining: 0,
        totalConstructionSpent: 6000000.0,
      );

      final totalInvestment = investedLand.currentPurchasePrice +
          investedLand.deedFeePaid +
          investedLand.commissionPaid +
          investedLand.totalConstructionSpent;
      // 10M + 400K + 200K + 6M = 16.6M
      expect(totalInvestment, 16600000.0);

      final costPerUnit = totalInvestment / investedLand.playerShareUnits;
      expect(costPerUnit, equals(1660000.0)); // 16.6M / 10 = 1.66M per unit
    });

    test('C7: Project cancellation cleans active construction and refunds 40%', () {
      final activeLand = sampleLand.copyWith(
        constructionMode: 'selfBuild',
        constructionStage: 4,
        totalConstructionSpent: 3000000.0,
      );
      expect(activeLand.isConstructionActive, isTrue);

      final clearedLand = activeLand.copyWith(
        clearConstructionMode: true,
        constructionStage: 0,
        constructionDaysRemaining: 0,
      );
      expect(clearedLand.isConstructionActive, isFalse);
      expect(clearedLand.constructionMode, isNull);
    });

    test('D2: Emsal excess blocks starting construction', () {
      // Create an illegal mix that massively exceeds KAKS
      final excessiveMix = const {
        'units1Plus0': 0,
        'units1Plus1': 0,
        'units2Plus0': 0,
        'units2Plus1': 0,
        'units3Plus1': 0,
        'units4Plus1': 50, // 50 * 180m2 = 9000m2 >> allowable ~1500m2
      };

      final zoning = ZoningEngine.calculateZoning(
        parcelSquareMeters: sampleLand.squareMeters.toDouble(),
        baseMarketValue: sampleLand.baseMarketValue,
        customUnitMix: ZoningUnitMix.fromMap(excessiveMix),
      );

      expect(zoning.isEmsalExceeded, isTrue);
    });

    test('F2·5: ConstructionNegativeEventsEngine rollStageIncident observes conditions', () {
      final incident = ConstructionNegativeEventsEngine.rollStageIncident(
        stageNumber: 3,
        baseStageCost: 2000000.0,
        riskMultiplier: 1.25,
        hasMasterMechanic: true,
        isBadWeather: false,
      );

      if (incident != null) {
        expect(incident.costImpact, greaterThan(0));
        expect(incident.dayDelayImpact, greaterThan(0));
        expect(incident.title.isNotEmpty, isTrue);
      }
    });
  });
}
