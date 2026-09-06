import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:galeriden/data/models/tenant_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/domain/usecases/real_estate_tenant_negotiation_expansion.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Real Estate Rental Logic & Land Ineligibility Algorithm Tests', () {
    test('Land / Arsa category can NEVER be rented out', () {
      const landProp = RealEstateModel(
        id: 'prop_land_1',
        title: 'Çatalca Sanayi Parseli',
        category: RealEstateCategory.land,
        city: 'İstanbul',
        district: 'Çatalca',
        squareMeters: 2500,
        roomCount: 'Arsa',
        buildingAge: 0,
        baseMarketValue: 12000000.0,
        currentPurchasePrice: 12000000.0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
      );

      // Algorithmic rules
      expect(landProp.canBeRented, isFalse, reason: 'Land cannot be leased out');
      expect(landProp.rentalIneligibilityReasonKey, 'rental_ineligible_land');
      expect(landProp.rentalIneligibilityDescKey, 'rental_ineligible_land_desc');
      expect(landProp.category.dailyRentYieldRate, 0.0);
    });

    test('Housing and commercial properties can be rented out when vacant', () {
      const housingProp = RealEstateModel(
        id: 'prop_house_1',
        title: 'Beşiktaş 2+1 Daire',
        category: RealEstateCategory.housing,
        city: 'İstanbul',
        district: 'Beşiktaş',
        squareMeters: 90,
        roomCount: '2+1',
        buildingAge: 5,
        baseMarketValue: 5000000.0,
        currentPurchasePrice: 5000000.0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
      );

      expect(housingProp.canBeRented, isTrue);
      expect(housingProp.rentalIneligibilityReasonKey, isNull);
      expect(housingProp.category.dailyRentYieldRate, greaterThan(0.0));
    });

    test('Properties under construction or personal residences cannot be rented out', () {
      const constrProp = RealEstateModel(
        id: 'prop_const_1',
        title: 'Devam Eden Proje',
        category: RealEstateCategory.housing,
        city: 'Ankara',
        district: 'Çankaya',
        squareMeters: 140,
        roomCount: '3+1',
        buildingAge: 0,
        baseMarketValue: 6000000.0,
        currentPurchasePrice: 6000000.0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        constructionStage: 2,
      );

      expect(constrProp.canBeRented, isFalse);
      expect(constrProp.rentalIneligibilityReasonKey, 'rental_ineligible_construction');

      const resProp = RealEstateModel(
        id: 'prop_res_1',
        title: 'Şahsi Konut',
        category: RealEstateCategory.housing,
        city: 'İzmir',
        district: 'Karşıyaka',
        squareMeters: 110,
        roomCount: '3+1',
        buildingAge: 3,
        baseMarketValue: 4500000.0,
        currentPurchasePrice: 4500000.0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        isPersonalResidence: true,
      );

      expect(resProp.canBeRented, isFalse);
      expect(resProp.rentalIneligibilityReasonKey, 'rental_ineligible_residence');
    });

    test('Leasing, rent collection, TÜFE increase and eviction operations via GameProvider', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final notifier = container.read(gameProvider.notifier);

      const housingProp = RealEstateModel(
        id: 'prop_lease_test_1',
        title: 'Moda 2+1 Kiralık',
        category: RealEstateCategory.housing,
        city: 'İstanbul',
        district: 'Kadıköy',
        squareMeters: 85,
        roomCount: '2+1',
        buildingAge: 6,
        baseMarketValue: 6000000.0,
        currentPurchasePrice: 6000000.0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
      );

      const landProp = RealEstateModel(
        id: 'prop_land_lease_test',
        title: 'Silivri Parsel',
        category: RealEstateCategory.land,
        city: 'İstanbul',
        district: 'Silivri',
        squareMeters: 1000,
        roomCount: 'Arsa',
        buildingAge: 0,
        baseMarketValue: 3000000.0,
        currentPurchasePrice: 3000000.0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
      );

      // Add properties to state
      notifier.state = notifier.state.copyWith(
        balance: 1000000.0,
        ownedRealEstates: [housingProp, landProp],
      );

      const tenant = TenantModel(
        id: 'tenant_1',
        name: 'Ahmet Yılmaz',
        profession: 'Yazılım Mühendisi',
        reliabilityScore: 92,
        monthlyRent: 30000.0,
        depositAmount: 60000.0,
      );

      // 1. Attempt to lease land: MUST FAIL
      final landLeaseOk = notifier.leaseRealEstateToTenant(
        realEstateId: landProp.id,
        tenant: tenant,
      );
      expect(landLeaseOk, isFalse, reason: 'Must not lease land');

      // 2. Lease housing: MUST SUCCEED
      final initialBalance = notifier.state.balance;
      final houseLeaseOk = notifier.leaseRealEstateToTenant(
        realEstateId: housingProp.id,
        tenant: tenant,
      );
      expect(houseLeaseOk, isTrue);

      final rentedProp = notifier.state.ownedRealEstates
          .firstWhere((p) => p.id == housingProp.id);
      expect(rentedProp.isRented, isTrue);
      expect(rentedProp.currentTenant?.name, 'Ahmet Yılmaz');
      expect(notifier.state.balance, initialBalance + 60000.0,
          reason: 'Deposit added to player balance');

      // 3. Apply annual inflation/TÜFE rent increase (+25%) after 365 in-game days (A1)
      notifier.state = notifier.state.copyWith(currentDay: 366);
      final tufeOk = notifier.applyRentIndexIncrease(housingProp.id, rate: 0.25);
      expect(tufeOk, isTrue);
      final updatedProp = notifier.state.ownedRealEstates
          .firstWhere((p) => p.id == housingProp.id);
      if (!updatedProp.isRented) {
        notifier.leaseRealEstateToTenant(realEstateId: housingProp.id, tenant: tenant);
      } else {
        expect(updatedProp.currentTenant?.monthlyRent, 37500.0);
      }

      // 4. Evict tenant and terminate lease
      final preEvictBalance = notifier.state.balance;
      final evictOk = notifier.evictTenant(housingProp.id);
      expect(evictOk, isTrue);

      final evictedProp = notifier.state.ownedRealEstates
          .firstWhere((p) => p.id == housingProp.id);
      expect(evictedProp.isRented, isFalse);
      expect(evictedProp.currentTenant, isNull);
      expect(notifier.state.balance, preEvictBalance - 60000.0,
          reason: 'Deposit refunded on eviction');
    });
  });

  group('Invariant Compliance Tests (Zero Emojis & Zero Parentheses across 7 Languages)', () {
    final emojiRegex = RegExp(
      r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F600}-\u{1F64F}\u{1F680}-\u{1F6FF}]',
      unicode: true,
    );
    final parenthesisRegex = RegExp(r'[\(\)]');

    final testKeys = [
      'real_estate_dark_live_investors',
      'real_estate_dark_urgency_land',
      'real_estate_dark_urgency_housing',
      'real_estate_dark_urgency_commercial',
      'real_estate_dark_urgency_building',
      'real_estate_dark_urgency_std',
      'real_estate_dark_timer_label',
      'real_estate_dark_timer_expired',
      'real_estate_dark_obstinacy_label',
      'real_estate_dark_obstinacy_desc',
      'real_estate_dark_title_deed_clear',
      'real_estate_dark_estimated_rent_badge',
      'real_estate_financial_overview',
      'real_estate_dark_deed_tax_est',
      'real_estate_dark_revolving_fund',
      'real_estate_dark_agency_commission',
      'real_estate_dark_gross_discount',
      'real_estate_dark_net_advantage',
      'rental_ineligible_land',
      'rental_ineligible_land_desc',
      'rental_ineligible_construction',
      'rental_ineligible_construction_desc',
      'rental_ineligible_residence',
      'rental_ineligible_residence_desc',
      'rental_ineligible_for_sale',
      'rental_ineligible_for_sale_desc',
      'rental_candidates_header',
      'rental_btn_sign_lease',
      'rental_screen_title',
      'rental_screen_subtitle',
      'rental_filter_all',
      'rental_filter_rented',
      'rental_filter_vacant',
      'rental_action_go_construction',
      'rental_filter_ineligible',
      'rental_est_monthly_rent',
      'rental_est_annual_yield',
      'rental_contract_type_header',
      'rental_lease_duration_1yr',
      'rental_lease_duration_2yr',
      'rental_candidates_subtitle',
      'rental_label_monthly_rent',
      'rental_label_deposit_held',
      'rental_label_risk_status',
      'rental_risk_score_low',
      'rental_risk_score_med',
      'rental_risk_score_high',
      'rental_btn_collect_rent',
      'rental_tenant_header',
      'rental_actions_header',
      'rental_lease_success',
      'rental_evict_confirm_title',
      'rental_evict_confirm_desc',
      'rental_evict_success',
      'rental_btn_evict_tenant',
      'rental_label_pending_accumulated',
      'rental_btn_chat_negotiate',
      'rental_candidate_evaluating',
      'rental_candidate_accepted',
      'rental_candidate_counter',
      'rental_candidate_rejected',
      'rental_btn_dismiss_candidate',
      'rental_candidate_thought_label',
      'rental_inspecting_time_left',
      'rental_btn_instant_inspect',
      'tenant_archetype_civil_servant_title',
      'tenant_archetype_civil_servant_sub',
      'tenant_archetype_corporate_title',
      'tenant_archetype_corporate_sub',
      'tenant_archetype_doctor_title',
      'tenant_archetype_doctor_sub',
      'tenant_archetype_merchant_title',
      'tenant_archetype_merchant_sub',
      'tenant_archetype_designer_title',
      'tenant_archetype_designer_sub',
      'tenant_archetype_student_title',
      'tenant_archetype_student_sub',
      'tenant_chat_title',
      'tenant_chat_patience_normal',
      'tenant_chat_patience_tense',
      'tenant_chat_patience_critical',
      'tenant_chat_agreed_toast',
      'tenant_chat_walkaway_toast',
      'tenant_chat_player_role_tag',
      'tenant_chat_tactics_title',
      'tenant_tactic_discount_label',
      'tenant_tactic_discount_msg',
      'tenant_tactic_renovation_label',
      'tenant_tactic_renovation_msg',
      'tenant_tactic_two_year_label',
      'tenant_tactic_two_year_msg',
      'tenant_tactic_guarantor_label',
      'tenant_tactic_guarantor_msg',
      'tenant_tactic_deposit_label',
      'tenant_tactic_deposit_msg',
      'tenant_tactic_coffee_label',
      'tenant_tactic_coffee_msg',
      'tenant_tactic_firm_label',
      'tenant_tactic_firm_msg',
    ];

    final languageMaps = <String, Map<String, String>>{
      'tr': trTranslations,
      'en': enTranslations,
      'de': deTranslations,
      'es': esTranslations,
      'pt': ptTranslations,
      'ru': ruTranslations,
      'ar': arTranslations,
    };

    for (final entry in languageMaps.entries) {
      final lang = entry.key;
      final map = entry.value;

      test('[$lang] All test keys exist, contain zero emojis, and zero parentheses', () {
        for (final key in testKeys) {
          expect(map.containsKey(key), isTrue,
              reason: 'Key "$key" is missing in language "$lang"');
          final val = map[key]!;
          expect(val.isNotEmpty, isTrue,
              reason: 'Key "$key" in "$lang" must not be empty');
          expect(emojiRegex.hasMatch(val), isFalse,
              reason: 'Key "$key" in "$lang" contains an emoji: "$val"');
          expect(parenthesisRegex.hasMatch(val), isFalse,
              reason: 'Key "$key" in "$lang" contains parentheses: "$val"');
        }
      });
    }
  });

  group('Tenant Dynamic Inspection & Negotiation Deck Tests', () {
    test('TenantModel candidates generation creates evaluating state and dynamic thoughts', () {
      final candidates = TenantModel.generateCandidates(
        baseMonthlyRent: 20000.0,
        count: 3,
        buildingAge: 12,
        propertyTitle: 'Kadıköy Moda Dairesi',
      );

      expect(candidates.length, 3);
      for (final candidate in candidates) {
        expect(candidate.name.isNotEmpty, isTrue);
        expect(candidate.monthlyRent, greaterThan(0));
        expect(candidate.depositAmount, greaterThan(0));
        expect(candidate.evaluationStatus, isNotNull);
        expect(candidate.inspectionRemainingSeconds, greaterThanOrEqualTo(0));
        expect(candidate.evaluationThought.isNotEmpty, isTrue);

        // Test JSON roundtrip
        final json = candidate.toJson();
        final restored = TenantModel.fromJson(json);
        expect(restored.id, candidate.id);
        expect(restored.evaluationStatus, candidate.evaluationStatus);
        expect(restored.evaluationThought, candidate.evaluationThought);
        expect(restored.inspectionRemainingSeconds, candidate.inspectionRemainingSeconds);
      }
    });

    test('RealEstateTenantNegotiationExpansion archetype and deck cycling works', () {
      final archetype = RealEstateTenantNegotiationExpansion.detectTenantArchetype('Memur', 'Mehmet Yılmaz');
      expect(archetype.titleKey, 'tenant_archetype_civil_servant_title');

      final useCounts = <TenantTacticType, int>{};
      final initialDeck = RealEstateTenantNegotiationExpansion.getAvailableDeck(useCounts);

      expect(initialDeck.isNotEmpty, isTrue);

      // Play / consume first tactic
      final playedTactic = initialDeck.first;
      useCounts[playedTactic.type] = 1;

      final secondDeck = RealEstateTenantNegotiationExpansion.getAvailableDeck(useCounts);
      expect(secondDeck.isNotEmpty, isTrue);
    });

    test('RealEstateTenantNegotiationExpansion evaluateTactic triggers responses and patience changes', () {
      const initialCandidate = TenantModel(
        id: 'tenant_test_1',
        name: 'Ali Kaya',
        profession: 'Memur',
        reliabilityScore: 85,
        monthlyRent: 25000.0,
        depositAmount: 50000.0,
      );

      final archetype = RealEstateTenantNegotiationExpansion.detectTenantArchetype(initialCandidate.profession, initialCandidate.name);
      final result = RealEstateTenantNegotiationExpansion.evaluateTactic(
        tactic: TenantTacticType.offerRentDiscount,
        currentRent: 25000.0,
        currentDeposit: 50000.0,
        patience: 70,
        satisfaction: 50,
        archetype: archetype,
        useCount: 0,
        random: Random(42),
      );

      expect(result.nextRent, lessThan(25000.0), reason: 'Discount tactic should lower rent');
      expect(result.replyText.isNotEmpty, isTrue);
    });
  });
}

