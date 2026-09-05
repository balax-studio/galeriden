import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/localization/translations/ar_translations.dart';
import 'package:galeriden/core/localization/translations/de_translations.dart';
import 'package:galeriden/core/localization/translations/en_translations.dart';
import 'package:galeriden/core/localization/translations/es_translations.dart';
import 'package:galeriden/core/localization/translations/pt_translations.dart';
import 'package:galeriden/core/localization/translations/ru_translations.dart';
import 'package:galeriden/core/localization/translations/tr_translations.dart';
import 'package:galeriden/data/models/real_estate_category.dart';
import 'package:galeriden/data/models/real_estate_model.dart';
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

  group('Dynamic KAKS & 8-Stage Municipal Lifecycle Test Suite', () {
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
      // Total gross area check
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
      expect(optimized.totalGrossArea, greaterThan(800.0)); // Highly efficient fill
    });

    test('3. ConstructionTimelineEngine 8 Stages & Municipal Checklist Progression', () {
      final stages = ConstructionTimelineEngine.stages;
      expect(stages.length, equals(8));

      // Verify strict sequential numbering 1 to 8
      for (int i = 0; i < 8; i++) {
        expect(stages[i].stageNumber, equals(i + 1));
        expect(stages[i].costPercentage, greaterThan(0.0));
        expect(stages[i].baseDays, greaterThan(0));
      }

      // Total cost percentage across all 8 stages should sum to 1.0 (100%)
      final totalPercentage = stages.fold<double>(0.0, (sum, s) => sum + s.costPercentage);
      expect(totalPercentage, closeTo(1.0, 0.001));

      // Municipal Documents: Stage 1 (In Review for requiredStage 1)
      final stage1Docs = ConstructionTimelineEngine.getMunicipalDocuments(1);
      expect(stage1Docs.length, equals(8));
      final inReviewAtStage1 = stage1Docs.where((d) => d.status == MunicipalDocStatus.inReview).toList();
      expect(inReviewAtStage1.length, equals(4)); // 4 documents required for stage 1 are currently inReview

      // Municipal Documents: Stage 2 (Stage 1 docs now approved)
      final stage2Docs = ConstructionTimelineEngine.getMunicipalDocuments(2);
      final approvedAtStage2 = stage2Docs.where((d) => d.status == MunicipalDocStatus.approved).toList();
      expect(approvedAtStage2.length, equals(4)); // Stage 1 docs approved

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
      );

      // Start Self Build with custom unit mix
      final startSuccess = notifier.startSelfBuildConstruction(
        'land_typology_mint_test',
        customUnitMix: configuredMix,
      );
      expect(startSuccess, isTrue);

      var activeLand = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'land_typology_mint_test');
      expect(activeLand.customUnitMix, isNotNull);
      expect(activeLand.totalProjectUnits, equals(8));

      // Fast-forward to Stage 8 finished
      notifier.state = notifier.state.copyWith(
        ownedRealEstates: [
          activeLand.copyWith(
            constructionStage: 8,
            constructionDaysRemaining: 0,
          ),
        ],
      );

      // Finalize construction
      final mintedUnits = notifier.finalizeConstruction('land_typology_mint_test');
      expect(mintedUnits.length, equals(8));

      // Check distribution of created apartments
      expect(mintedUnits.where((u) => u.roomCount == '1+0').length, equals(1));
      expect(mintedUnits.where((u) => u.roomCount == '1+1').length, equals(2));
      expect(mintedUnits.where((u) => u.roomCount == '2+0').length, equals(1));
      expect(mintedUnits.where((u) => u.roomCount == '2+1').length, equals(2));
      expect(mintedUnits.where((u) => u.roomCount == '3+1').length, equals(1));
      expect(mintedUnits.where((u) => u.roomCount == '4+1').length, equals(1));

      // Verify gross square meters on minted apartments
      final unit1Plus0 = mintedUnits.firstWhere((u) => u.roomCount == '1+0');
      expect(unit1Plus0.squareMeters, equals(45));

      final unit4Plus1 = mintedUnits.firstWhere((u) => u.roomCount == '4+1');
      expect(unit4Plus1.squareMeters, equals(175));

      container.dispose();
    });

    test('5. Invariant Rules: Zero Unicode Emojis & Zero Parentheses across all 7 languages', () {
      final allLanguages = <String, Map<String, String>>{
        'tr': trTranslations,
        'en': enTranslations,
        'de': deTranslations,
        'pt': ptTranslations,
        'es': esTranslations,
        'ru': ruTranslations,
        'ar': arTranslations,
      };

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
      ];

      final emojiRegex = RegExp(
        r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F600}-\u{1F64F}\u{1F680}-\u{1F6FF}]',
        unicode: true,
      );

      for (final langEntry in allLanguages.entries) {
        final lang = langEntry.key;
        final map = langEntry.value;

        for (final key in newZoningKeys) {
          expect(map.containsKey(key), isTrue,
              reason: 'Key $key must exist in language $lang');

          final value = map[key]!;

          // Rule 1: Zero Unicode Emojis
          expect(
            emojiRegex.hasMatch(value),
            isFalse,
            reason: 'Value for $key in $lang must not contain Unicode emojis: $value',
          );

          // Rule 2: Zero Parentheses
          expect(
            value.contains('(') || value.contains(')'),
            isFalse,
            reason: 'Value for $key in $lang must not contain parentheses: $value',
          );
        }
      }
    });
  });
}
