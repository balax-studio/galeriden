import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/core/localization/app_localizations.dart';
import 'package:galeriden/data/models/real_estate_category.dart';
import 'package:galeriden/data/models/real_estate_model.dart';
import 'package:galeriden/domain/usecases/construction_timeline_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Self-Build Pre-Construction Suite', () {
    const baseLand = RealEstateModel(
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

    test('1. RealEstateModel pre-construction fields and serialization', () {
      expect(baseLand.isArchitecturalApproved, isFalse);
      expect(baseLand.hasBuildingPermit, isFalse);
      expect(baseLand.preConstructionStep, isNull);

      final updated = baseLand.copyWith(
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

    test('2. Dynamic fee calculations for architectural plan & municipal permit', () {
      // Step 1: Architectural plan is 4% of baseMarketValue * costIndex
      final basePlanCost = ConstructionPricing.architecturalPlanCost(
        baseLand,
        costIndex: 1.0,
        hasArchitectStaff: false,
      );
      expect(basePlanCost, equals(400000.0)); // 4% of 10M

      // With staff discount (30% discount -> 0.70)
      final discountedPlanCost = ConstructionPricing.architecturalPlanCost(
        baseLand,
        costIndex: 1.0,
        hasArchitectStaff: true,
      );
      expect(discountedPlanCost, equals(280000.0)); // 400000 * 0.70

      // Step 2: Municipal permit is 6% of baseMarketValue * costIndex
      final basePermitCost = ConstructionPricing.municipalPermitCost(
        baseLand,
        costIndex: 1.0,
        hasLegalAdvisor: false,
      );
      expect(basePermitCost, equals(600000.0)); // 6% of 10M

      // With legal advisor discount (30% discount -> 0.70)
      final discountedPermitCost = ConstructionPricing.municipalPermitCost(
        baseLand,
        costIndex: 1.0,
        hasLegalAdvisor: true,
      );
      expect(discountedPermitCost, equals(420000.0)); // 600000 * 0.70
    });

    test('3. Full 2-Step Pre-Construction Lifecycle in Game Provider', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      notifier.state = notifier.state.copyWith(
        ownedRealEstates: [baseLand],
        balance: 20000000.0,
        constructionCostIndex: 1.0,
      );

      // --- STEP 1: Architectural Plan ---
      final balanceBeforePlan = notifier.state.balance;
      final planSuccess = notifier.startSelfBuildArchitecturalPlan(baseLand.id);
      expect(planSuccess, isTrue);

      var land = notifier.state.ownedRealEstates.firstWhere((r) => r.id == baseLand.id);
      expect(land.constructionMode, equals('selfBuild'));
      expect(land.constructionStage, equals(1));
      expect(land.constructionDaysRemaining, equals(1));
      expect(land.stageTotalDays, equals(1));
      expect(land.isConstructionWorking, isTrue);
      expect(land.isArchitecturalApproved, isFalse);
      expect(land.hasBuildingPermit, isFalse);
      expect(land.preConstructionStep, equals('drafting'));
      expect(notifier.state.balance, equals(balanceBeforePlan - 400000.0));

      // Cannot submit municipal permit while architectural plan is still in progress
      final earlyPermit = notifier.submitSelfBuildMunicipalPermit(baseLand.id);
      expect(earlyPermit, isFalse);

      // Cannot hire subcontractor at stage 1
      final sub = ConstructionTimelineEngine.getSubcontractorsForStage(2).first;
      final earlySubcontractor = notifier.startSelfBuildStage(baseLand.id, subcontractor: sub);
      expect(earlySubcontractor, isFalse);

      // Advance 1 in-game day
      notifier.advanceGameDay();

      land = notifier.state.ownedRealEstates.firstWhere((r) => r.id == baseLand.id);
      expect(land.constructionStage, equals(1));
      expect(land.constructionDaysRemaining, equals(0));
      expect(land.isConstructionWorking, isFalse);
      expect(land.isArchitecturalApproved, isTrue);
      expect(land.hasBuildingPermit, isFalse);
      expect(land.preConstructionStep, equals('draftingCompleted'));

      // --- STEP 2: Municipal Permit Submission ---
      final balanceBeforePermit = notifier.state.balance;
      final expectedPermitCost = ConstructionPricing.municipalPermitCost(
        land,
        costIndex: notifier.state.constructionCostIndex,
      );
      final permitSuccess = notifier.submitSelfBuildMunicipalPermit(baseLand.id);
      expect(permitSuccess, isTrue);

      land = notifier.state.ownedRealEstates.firstWhere((r) => r.id == baseLand.id);
      expect(land.constructionDaysRemaining, equals(1));
      expect(land.isConstructionWorking, isTrue);
      expect(land.preConstructionStep, equals('municipalReview'));
      expect(notifier.state.balance, equals(balanceBeforePermit - expectedPermitCost));

      // Advance 1 in-game day for municipal review
      notifier.advanceGameDay();

      land = notifier.state.ownedRealEstates.firstWhere((r) => r.id == baseLand.id);
      expect(land.hasBuildingPermit, isTrue);
      expect(land.constructionStage, equals(2)); // Unlocks Stage 2
      expect(land.constructionDaysRemaining, equals(0));
      expect(land.isConstructionWorking, isFalse);
      expect(land.preConstructionStep, equals('permitApproved'));

      // --- STAGE 2 UNLOCKED: Subcontractor Hiring ---
      final subStageSuccess = notifier.startSelfBuildStage(
        baseLand.id,
        subcontractor: sub,
        triggerIncidents: false,
      );
      expect(subStageSuccess, isTrue);

      land = notifier.state.ownedRealEstates.firstWhere((r) => r.id == baseLand.id);
      expect(land.isConstructionWorking, isTrue);
      expect(land.activeSubcontractorName, equals(sub.name));

      notifier.stopPeriodicOrganicOfferTimer();
      container.dispose();
    });

    test('4. All 7 languages localize all 12 pre-construction keys without parentheses or emojis', () {
      final supportedCodes = AppLocalizations.supportedLanguageCodes;
      expect(supportedCodes, containsAll(['tr', 'en', 'de', 'pt', 'es', 'ru', 'ar']));

      final preconKeys = [
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

      final emojiRegex = RegExp(
        r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F1E6}-\u{1F1FF}]',
        unicode: true,
      );

      for (final code in supportedCodes) {
        final translations = AppLocalizations.getAllKeysFor(code);
        for (final key in preconKeys) {
          final value = translations[key];
          expect(value, isNotNull, reason: 'Missing precon key $key in language $code');
          expect(value!.isNotEmpty, isTrue, reason: 'Empty value for key $key in language $code');

          // Zero parentheses invariant
          expect(value.contains('('), isFalse,
              reason: 'Key $key in $code must not contain open parenthesis: $value');
          expect(value.contains(')'), isFalse,
              reason: 'Key $key in $code must not contain close parenthesis: $value');

          // Zero emoji invariant
          expect(emojiRegex.hasMatch(value), isFalse,
              reason: 'Key $key in $code must not contain unicode emojis: $value');
        }
      }
    });
  });
}
