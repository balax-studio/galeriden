import 'package:flutter_test/flutter_test.dart';
import 'helpers/invariant_test_helpers.dart';
import 'package:galeriden/data/models/construction_stages_model.dart';
import 'package:galeriden/data/models/real_estate_category.dart';
import 'package:galeriden/data/models/real_estate_model.dart';
import 'package:galeriden/domain/usecases/construction_negative_events_engine.dart';
import 'package:galeriden/domain/usecases/construction_timeline_engine.dart';
import 'package:galeriden/domain/usecases/zoning_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Dynamic KAKS & Zoning Construction Lifecycle Suite', () {
    test('1. Turkish Zoning Law KAKS & TAKS Math & 15% Core Deduction', () {
      const parcelM2 = 1000.0;
      const baseValue = 10000000.0;

      final profile = ZoningEngine.calculateZoning(
        parcelSquareMeters: parcelM2,
        baseMarketValue: baseValue,
      );

      // TAKS: 0.30 -> footprint = 300 m2
      expect(profile.footprintArea, equals(300.0));
      // KAKS: 1.80 -> gross construction area = 1800 m2
      expect(profile.totalConstructionArea, equals(1800.0));
      // Net residential area: 1800 * 0.85 = 1530 m2 (15% core/shafts deduction)
      expect(profile.netResidentialArea, equals(1530.0));
      expect(profile.maxFloors, equals(5));

      // Utilization with default optimized mix
      expect(profile.consumedEmsalArea, greaterThan(0));
      expect(profile.consumedEmsalArea, lessThanOrEqualTo(profile.netResidentialArea));
      expect(profile.isEmsalExceeded, isFalse);
      expect(profile.emsalUtilizationRatio, inInclusiveRange(0.0, 1.0));
    });

    test('2. 6 Unit Typologies & ZoningUnitMix Serialization and Optimization', () {
      // Check constants for all 6 typologies
      expect(ZoningUnitMix.grossArea1Plus0, equals(45.0));
      expect(ZoningUnitMix.netArea1Plus0, equals(38.0));
      expect(ZoningUnitMix.grossArea1Plus1, equals(65.0));
      expect(ZoningUnitMix.netArea1Plus1, equals(55.0));
      expect(ZoningUnitMix.grossArea2Plus0, equals(80.0));
      expect(ZoningUnitMix.netArea2Plus0, equals(68.0));
      expect(ZoningUnitMix.grossArea2Plus1, equals(105.0));
      expect(ZoningUnitMix.netArea2Plus1, equals(88.0));
      expect(ZoningUnitMix.grossArea3Plus1, equals(135.0));
      expect(ZoningUnitMix.netArea3Plus1, equals(115.0));
      expect(ZoningUnitMix.grossArea4Plus1, equals(175.0));
      expect(ZoningUnitMix.netArea4Plus1, equals(150.0));

      const customMix = ZoningUnitMix(
        units1Plus0: 2,
        units1Plus1: 4,
        units2Plus0: 3,
        units2Plus1: 5,
        units3Plus1: 2,
        units4Plus1: 1,
      );

      expect(customMix.totalUnits, equals(17));
      final expectedGross = (2 * 45) + (4 * 65) + (3 * 80) + (5 * 105) + (2 * 135) + (1 * 175);
      expect(customMix.totalGrossArea, equals(expectedGross.toDouble()));

      // Serialization round-trip
      final map = customMix.toMap();
      final restored = ZoningUnitMix.fromMap(map);
      expect(restored.units1Plus0, equals(2));
      expect(restored.units1Plus1, equals(4));
      expect(restored.units2Plus0, equals(3));
      expect(restored.units2Plus1, equals(5));
      expect(restored.units3Plus1, equals(2));
      expect(restored.units4Plus1, equals(1));
      expect(restored.totalUnits, equals(17));

      // Optimizer test with a typical 1000m2 net building area
      final optimized = ZoningEngine.optimizeUnitMix(1000.0);
      expect(optimized.totalUnits, greaterThan(0));
      expect(optimized.totalGrossArea, lessThanOrEqualTo(1000.0));
      expect(optimized.totalGrossArea, greaterThan(800.0));
    });

    test('3. ConstructionTimelineEngine 8 Stages & Municipal Checklist Progression', () {
      final stages = ConstructionTimelineEngine.stages;
      expect(stages.length, equals(8));

      for (int i = 0; i < 8; i++) {
        expect(stages[i].stageNumber, equals(i + 1));
        expect(stages[i].costPercentage, greaterThan(0.0));
        expect(stages[i].baseDays, greaterThan(0));
      }

      final totalPercentage = stages.fold<double>(0.0, (sum, s) => sum + s.costPercentage);
      expect(totalPercentage, closeTo(1.0, 0.001));

      // Municipal Documents: Stage 1 (In Review for requiredStage 1)
      final stage1Docs = ConstructionTimelineEngine.getMunicipalDocuments(1);
      expect(stage1Docs.length, equals(8));
      final inReviewAtStage1 = stage1Docs.where((d) => d.status == MunicipalDocStatus.inReview).toList();
      expect(inReviewAtStage1.length, equals(4));

      // Municipal Documents: Stage 2 (Stage 1 docs now approved)
      final stage2Docs = ConstructionTimelineEngine.getMunicipalDocuments(2);
      final approvedAtStage2 = stage2Docs.where((d) => d.status == MunicipalDocStatus.approved).toList();
      expect(approvedAtStage2.length, equals(4));

      // Municipal Documents: Stage 8 (Finished)
      final finishedDocs = ConstructionTimelineEngine.getMunicipalDocuments(8, isFinished: true);
      final allApproved = finishedDocs.every((d) => d.status == MunicipalDocStatus.approved);
      expect(allApproved, isTrue);
    });

    test('4. Turnkey Finalization generates authentic apartments matching custom unit mix', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      const configuredMix = ZoningUnitMix(
        units1Plus0: 1,
        units1Plus1: 2,
        units2Plus0: 1,
        units2Plus1: 2,
        units3Plus1: 1,
        units4Plus1: 1,
      );

      final land = RealEstateModel(
        id: 'land_typology_mint_test',
        title: 'Kadıköy Kentsel Dönüşüm Parseli',
        category: RealEstateCategory.land,
        city: 'İstanbul',
        district: 'Kadıköy',
        squareMeters: 800,
        roomCount: '-',
        buildingAge: 0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 8000000,
        currentPurchasePrice: 8000000,
      );

      notifier.state = notifier.state.copyWith(
        ownedRealEstates: [land],
        balance: 10000000,
        maxRealEstateSlots: 10,
      );

      final startSuccess = notifier.startSelfBuildConstruction(
        'land_typology_mint_test',
        customUnitMix: configuredMix,
      );
      expect(startSuccess, isTrue);

      var activeLand = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'land_typology_mint_test');
      expect(activeLand.customUnitMix, isNotNull);
      expect(activeLand.totalProjectUnits, equals(8));

      notifier.state = notifier.state.copyWith(
        ownedRealEstates: [
          activeLand.copyWith(
            constructionStage: 8,
            constructionDaysRemaining: 0,
          ),
        ],
      );

      final mintedUnits = notifier.finalizeConstruction('land_typology_mint_test');
      expect(mintedUnits.length, equals(8));

      expect(mintedUnits.where((u) => u.roomCount == '1+0').length, equals(1));
      expect(mintedUnits.where((u) => u.roomCount == '1+1').length, equals(2));
      expect(mintedUnits.where((u) => u.roomCount == '2+0').length, equals(1));
      expect(mintedUnits.where((u) => u.roomCount == '2+1').length, equals(2));
      expect(mintedUnits.where((u) => u.roomCount == '3+1').length, equals(1));
      expect(mintedUnits.where((u) => u.roomCount == '4+1').length, equals(1));

      final unit1Plus0 = mintedUnits.firstWhere((u) => u.roomCount == '1+0');
      expect(unit1Plus0.squareMeters, equals(45));

      final unit4Plus1 = mintedUnits.firstWhere((u) => u.roomCount == '4+1');
      expect(unit4Plus1.squareMeters, equals(175));

      notifier.stopPeriodicOrganicOfferTimer();
      container.dispose();
    });

    test('5. Standard contractors list has 3 distinct tiers with realistic ranges', () {
      final contractors = ZoningEngine.standardContractors;
      expect(contractors.length, equals(3));
      for (final c in contractors) {
        expect(c.minShare, greaterThanOrEqualTo(40));
        expect(c.maxShare, lessThanOrEqualTo(65));
        expect(c.rating, inInclusiveRange(3.0, 5.0));
      }
    });

    test('6. ConstructionStagesCatalog & Subcontractor tiers', () {
      final stages = ConstructionStagesCatalog.stages;
      expect(stages.length, equals(9));

      for (int i = 0; i < 9; i++) {
        expect(stages[i].stageNumber, equals(i + 1));
        expect(stages[i].title.isNotEmpty, isTrue);
        expect(stages[i].baseCostRatio, greaterThan(0));
      }

      final stage5 = ConstructionStagesCatalog.getStage(5);
      expect(stage5.id, equals('cati_izolasyon'));

      final tiers = ConstructionStagesCatalog.subcontractorTiers;
      expect(tiers.length, equals(3));
      expect(tiers.map((t) => t.id).toList(), containsAll(['ekonomik', 'usta', 'elit']));
    });

    test('7. ConstructionNegativeEventsEngine incident roll mechanics and text invariant checks', () {
      final noIncident = ConstructionNegativeEventsEngine.rollStageIncident(
        stageNumber: 1,
        baseStageCost: 100000.0,
        riskMultiplier: 0.0,
      );
      expect(noIncident, isNull);

      for (int i = 0; i < 50; i++) {
        final incident = ConstructionNegativeEventsEngine.rollStageIncident(
          stageNumber: 2,
          baseStageCost: 100000.0,
          riskMultiplier: 10.0,
        );
        if (incident != null) {
          expect(incident.title.contains('('), isFalse, reason: 'Title must not contain parentheses');
          expect(incident.title.contains(')'), isFalse, reason: 'Title must not contain parentheses');
          expect(incident.costImpact, greaterThan(0));
        }
      }
    });

    test('8. Invariant Rules: Zero Unicode Emojis & Zero Parentheses across all 7 languages for zoning & precon keys', () {
      final newZoningKeys = [
        'real_estate_construction_tab_stages',
        'real_estate_construction_tab_kaks',
        'real_estate_construction_tab_municipal',
        'real_estate_construction_tab_presale',
        'real_estate_kaks_tab_title',
        'real_estate_kaks_capacity_header',
        'real_estate_kaks_allowable_label',
        'real_estate_kaks_consumed_label',
        'real_estate_kaks_remaining_label',
        'real_estate_kaks_usage_rate',
        'real_estate_kaks_warning_exceeded',
        'real_estate_kaks_optimal_badge',
        'real_estate_kaks_btn_auto_optimize',
        'real_estate_kaks_btn_confirm_mix',
        'real_estate_kaks_confirmed_toast',
        'real_estate_kaks_reset_btn',
        'real_estate_typology_1plus0_title',
        'real_estate_typology_1plus0_desc',
        'real_estate_typology_1plus1_title',
        'real_estate_typology_1plus1_desc',
        'real_estate_typology_2plus0_title',
        'real_estate_typology_2plus0_desc',
        'real_estate_typology_2plus1_title',
        'real_estate_typology_2plus1_desc',
        'real_estate_typology_3plus1_title',
        'real_estate_typology_3plus1_desc',
        'real_estate_typology_4plus1_title',
        'real_estate_typology_4plus1_desc',
        'construction_stage_permits_title',
        'construction_stage_permits_desc',
        'construction_stage_landscape_infra_title',
        'construction_stage_landscape_infra_desc',
        'municipal_dossier_header',
        'municipal_dossier_guide',
        'municipal_status_approved',
        'municipal_status_in_review',
        'municipal_status_pending_fee',
        'municipal_status_locked',
        'municipal_fee_label',
        'municipal_doc_zoning_title',
        'municipal_doc_zoning_desc',
        'municipal_doc_geotech_title',
        'municipal_doc_geotech_desc',
        'municipal_doc_blueprint_title',
        'municipal_doc_blueprint_desc',
        'municipal_doc_permit_title',
        'municipal_doc_permit_desc',
        'municipal_doc_inspection_title',
        'municipal_doc_inspection_desc',
        'municipal_doc_fire_title',
        'municipal_doc_fire_desc',
        'municipal_doc_sgk_title',
        'municipal_doc_sgk_desc',
        'municipal_doc_iskan_title',
        'municipal_doc_iskan_desc',
        'real_estate_precon_plan_title',
        'real_estate_precon_plan_working_desc',
        'real_estate_precon_plan_idle_desc',
        'real_estate_precon_plan_btn_working',
        'real_estate_self_build_plan_btn',
        'real_estate_self_build_plan_started_toast',
        'real_estate_precon_permit_title',
        'real_estate_precon_permit_working_desc',
        'real_estate_precon_permit_idle_desc',
        'real_estate_precon_permit_btn_working',
        'real_estate_precon_permit_btn',
        'real_estate_precon_permit_submitted_toast',
      ];

      expectInvariantKeys(newZoningKeys);
    });

    const basePreconLand = RealEstateModel(
      id: 'precon_land_test',
      title: 'Göktürk Proje Parseli',
      category: RealEstateCategory.land,
      city: 'İstanbul',
      district: 'Eyüpsultan',
      squareMeters: 500,
      roomCount: 'İmarlı Arsa',
      buildingAge: 0,
      deedType: DeedType.ownershipDeed,
      sellerType: RealEstateSellerType.individual,
      baseMarketValue: 10000000.0,
      currentPurchasePrice: 10000000.0,
    );

    test('9. RealEstateModel pre-construction fields and serialization', () {
      expect(basePreconLand.isArchitecturalApproved, isFalse);
      expect(basePreconLand.hasBuildingPermit, isFalse);
      expect(basePreconLand.preConstructionStep, isNull);

      final updated = basePreconLand.copyWith(
        isArchitecturalApproved: true,
        hasBuildingPermit: true,
        preConstructionStep: 'permitApproved',
      );

      expect(updated.isArchitecturalApproved, isTrue);
      expect(updated.hasBuildingPermit, isTrue);
      expect(updated.preConstructionStep, equals('permitApproved'));

      final json = updated.toJson();
      expect(json['isArchitecturalApproved'], isTrue);
      expect(json['hasBuildingPermit'], isTrue);
      expect(json['preConstructionStep'], equals('permitApproved'));

      final restored = RealEstateModel.fromJson(json);
      expect(restored.isArchitecturalApproved, isTrue);
      expect(restored.hasBuildingPermit, isTrue);
      expect(restored.preConstructionStep, equals('permitApproved'));
    });

    test('10. Dynamic fee calculations for architectural plan & municipal permit', () {
      final basePlanCost = ConstructionPricing.architecturalPlanCost(
        basePreconLand,
        costIndex: 1.0,
        hasArchitectStaff: false,
      );
      expect(basePlanCost, equals(400000.0));

      final discountedPlanCost = ConstructionPricing.architecturalPlanCost(
        basePreconLand,
        costIndex: 1.0,
        hasArchitectStaff: true,
      );
      expect(discountedPlanCost, equals(280000.0));

      final basePermitCost = ConstructionPricing.municipalPermitCost(
        basePreconLand,
        costIndex: 1.0,
        hasLegalAdvisor: false,
      );
      expect(basePermitCost, equals(600000.0));

      final discountedPermitCost = ConstructionPricing.municipalPermitCost(
        basePreconLand,
        costIndex: 1.0,
        hasLegalAdvisor: true,
      );
      expect(discountedPermitCost, equals(420000.0));
    });

    test('11. Full 2-Step Pre-Construction Lifecycle in Game Provider', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      notifier.state = notifier.state.copyWith(
        ownedRealEstates: [basePreconLand],
        balance: 20000000.0,
        constructionCostIndex: 1.0,
      );

      // STEP 1: Architectural Plan
      final balanceBeforePlan = notifier.state.balance;
      final planSuccess = notifier.startSelfBuildArchitecturalPlan(basePreconLand.id);
      expect(planSuccess, isTrue);

      var land = notifier.state.ownedRealEstates.firstWhere((r) => r.id == basePreconLand.id);
      expect(land.constructionMode, equals('selfBuild'));
      expect(land.constructionStage, equals(1));
      expect(land.constructionDaysRemaining, equals(1));
      expect(land.stageTotalDays, equals(1));
      expect(land.isConstructionWorking, isTrue);
      expect(land.isArchitecturalApproved, isFalse);
      expect(land.hasBuildingPermit, isFalse);
      expect(land.preConstructionStep, equals('drafting'));
      expect(notifier.state.balance, equals(balanceBeforePlan - 400000.0));

      final earlyPermit = notifier.submitSelfBuildMunicipalPermit(basePreconLand.id);
      expect(earlyPermit, isFalse);

      final sub = ConstructionTimelineEngine.getSubcontractorsForStage(2).first;
      final earlySubcontractor = notifier.startSelfBuildStage(basePreconLand.id, subcontractor: sub);
      expect(earlySubcontractor, isFalse);

      notifier.advanceGameDay();

      land = notifier.state.ownedRealEstates.firstWhere((r) => r.id == basePreconLand.id);
      expect(land.constructionStage, equals(1));
      expect(land.constructionDaysRemaining, equals(0));
      expect(land.isConstructionWorking, isFalse);
      expect(land.isArchitecturalApproved, isTrue);
      expect(land.hasBuildingPermit, isFalse);
      expect(land.preConstructionStep, equals('draftingCompleted'));

      // STEP 2: Municipal Permit Submission
      final balanceBeforePermit = notifier.state.balance;
      final expectedPermitCost = ConstructionPricing.municipalPermitCost(
        land,
        costIndex: notifier.state.constructionCostIndex,
      );
      final permitSuccess = notifier.submitSelfBuildMunicipalPermit(basePreconLand.id);
      expect(permitSuccess, isTrue);

      land = notifier.state.ownedRealEstates.firstWhere((r) => r.id == basePreconLand.id);
      expect(land.constructionDaysRemaining, equals(1));
      expect(land.isConstructionWorking, isTrue);
      expect(land.preConstructionStep, equals('municipalReview'));
      expect(notifier.state.balance, equals(balanceBeforePermit - expectedPermitCost));

      notifier.advanceGameDay();

      land = notifier.state.ownedRealEstates.firstWhere((r) => r.id == basePreconLand.id);
      expect(land.hasBuildingPermit, isTrue);
      expect(land.constructionStage, equals(2));
      expect(land.constructionDaysRemaining, equals(0));
      expect(land.isConstructionWorking, isFalse);
      expect(land.preConstructionStep, equals('permitApproved'));

      // STAGE 2: Subcontractor Hiring
      final subStageSuccess = notifier.startSelfBuildStage(
        basePreconLand.id,
        subcontractor: sub,
        triggerIncidents: false,
      );
      expect(subStageSuccess, isTrue);

      land = notifier.state.ownedRealEstates.firstWhere((r) => r.id == basePreconLand.id);
      expect(land.isConstructionWorking, isTrue);
      expect(land.activeSubcontractorName, equals(sub.name));

      notifier.stopPeriodicOrganicOfferTimer();
      container.dispose();
    });
  });
}
