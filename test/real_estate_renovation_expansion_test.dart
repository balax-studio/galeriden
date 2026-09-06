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
import 'package:galeriden/domain/usecases/real_estate_renovation_expansion.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RealEstateRenovationExpansion Domain Tests', () {
    test('Contains 10 rich craftsmanship expansion packages', () {
      expect(RealEstateRenovationExpansion.allPackages.length, equals(10));
      for (final pkg in RealEstateRenovationExpansion.allPackages) {
        expect(pkg.stages.length, equals(3));
        expect(pkg.bonusMultiplier, greaterThan(1.0));
        expect(pkg.applicableCategories.isNotEmpty, isTrue);
      }
    });

    test('Random diversity: Different property IDs receive varied packages', () {
      const p1 = RealEstateModel(
        id: 'prop_alpha_101',
        title: 'Daire A',
        category: RealEstateCategory.housing,
        city: 'İstanbul',
        district: 'Kadıköy',
        squareMeters: 100,
        roomCount: '2+1',
        buildingAge: 5,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 2000000,
        currentPurchasePrice: 2000000,
      );

      const p2 = RealEstateModel(
        id: 'prop_beta_202',
        title: 'Daire B',
        category: RealEstateCategory.housing,
        city: 'İstanbul',
        district: 'Beşiktaş',
        squareMeters: 100,
        roomCount: '3+1',
        buildingAge: 10,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 3500000,
        currentPurchasePrice: 3500000,
      );

      final pkg1 = RealEstateRenovationExpansion.getPackageForProperty(p1);
      final pkg2 = RealEstateRenovationExpansion.getPackageForProperty(p2);

      expect(pkg1, isNotNull);
      expect(pkg2, isNotNull);
      // Both belong to housing-compatible packages
      expect(pkg1.applicableCategories.contains(RealEstateCategory.housing), isTrue);
      expect(pkg2.applicableCategories.contains(RealEstateCategory.housing), isTrue);
    });

    test('Explicit renovationPackageId overrides deterministic fallback', () {
      const property = RealEstateModel(
        id: 'prop_fixed_id',
        title: 'Smart Daire',
        category: RealEstateCategory.housing,
        city: 'Ankara',
        district: 'Çankaya',
        squareMeters: 120,
        roomCount: '3+1',
        buildingAge: 2,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 4000000,
        currentPurchasePrice: 4000000,
        renovationPackageId: RealEstateRenovationExpansion.packageSmartLuxuryId,
      );

      final pkg = RealEstateRenovationExpansion.getPackageForProperty(property);
      expect(pkg.id, equals(RealEstateRenovationExpansion.packageSmartLuxuryId));
      expect(pkg.stages.length, equals(3));
    });

    test('Stage costs vary dynamically with package ratios and property size', () {
      const smallProp = RealEstateModel(
        id: 'prop_small',
        title: 'Stüdyo',
        category: RealEstateCategory.housing,
        city: 'İzmir',
        district: 'Karşıyaka',
        squareMeters: 80,
        roomCount: '1+1',
        buildingAge: 3,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 1500000,
        currentPurchasePrice: 1500000,
        renovationPackageId: RealEstateRenovationExpansion.packageModernLivingId,
      );

      final costS1 = RealEstateRenovationExpansion.getStageCost(smallProp, 1);
      final costS2 = RealEstateRenovationExpansion.getStageCost(smallProp, 2);
      final costS3 = RealEstateRenovationExpansion.getStageCost(smallProp, 3);

      expect(costS1, greaterThan(0));
      expect(costS2, greaterThan(costS1)); // S2 is 0.40, S1 is 0.30
      expect(costS3, equals(costS1)); // S3 is 0.30
    });
  });

  group('GameNotifier Renovation Expansion & Timer Methods', () {
    late GameNotifier notifier;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      notifier = GameNotifier();
      notifier.stopPeriodicOrganicOfferTimer();
    });

    tearDown(() {
      notifier.stopPeriodicOrganicOfferTimer();
    });

    test('setRenovationPackage allows switching package only at stage 0', () {
      const testProp = RealEstateModel(
        id: 'prop_stage0_test',
        title: 'Mülk 0',
        category: RealEstateCategory.commercial,
        city: 'İstanbul',
        district: 'Şişli',
        squareMeters: 150,
        roomCount: 'Açık Alan',
        buildingAge: 4,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 5000000,
        currentPurchasePrice: 5000000,
        renovationStage: 0,
      );

      notifier.state = notifier.state.copyWith(
        ownedRealEstates: [...notifier.state.ownedRealEstates, testProp],
      );

      // Set package before starting stage 1
      final success = notifier.setRenovationPackage(
        'prop_stage0_test',
        RealEstateRenovationExpansion.packageCommercialFitoutId,
      );
      expect(success, isTrue);

      final updated = notifier.state.ownedRealEstates.firstWhere((p) => p.id == 'prop_stage0_test');
      expect(updated.renovationPackageId, equals(RealEstateRenovationExpansion.packageCommercialFitoutId));

      // After stage advances, package switching must be locked
      final propStage1 = updated.copyWith(renovationStage: 1);
      final list = List<RealEstateModel>.from(notifier.state.ownedRealEstates);
      list[list.indexWhere((p) => p.id == 'prop_stage0_test')] = propStage1;
      notifier.state = notifier.state.copyWith(ownedRealEstates: list);

      final switchFail = notifier.setRenovationPackage(
        'prop_stage0_test',
        RealEstateRenovationExpansion.packageIndustrialLoftId,
      );
      expect(switchFail, isFalse);
    });

    test('accelerateRenovationTimer clears days remaining to 0 via rewarded ad', () {
      const testProp = RealEstateModel(
        id: 'prop_timer_test',
        title: 'Mülk Timer',
        category: RealEstateCategory.housing,
        city: 'Bursa',
        district: 'Nilüfer',
        squareMeters: 130,
        roomCount: '3+1',
        buildingAge: 1,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 3000000,
        currentPurchasePrice: 3000000,
        renovationStage: 1,
        renovationDaysRemaining: 2,
      );

      notifier.state = notifier.state.copyWith(
        ownedRealEstates: [...notifier.state.ownedRealEstates, testProp],
      );

      final ok = notifier.accelerateRenovationTimer('prop_timer_test');
      expect(ok, isTrue);

      final accelerated = notifier.state.ownedRealEstates.firstWhere((p) => p.id == 'prop_timer_test');
      expect(accelerated.renovationDaysRemaining, equals(0));
      expect(accelerated.hasWaterLeakRisk, isFalse); // No leak penalty for timer acceleration
    });

    test('rushRenovation instantly completes all stages with water leak risk', () {
      const testProp = RealEstateModel(
        id: 'prop_rush_all_test',
        title: 'Mülk Acele',
        category: RealEstateCategory.housing,
        city: 'Antalya',
        district: 'Muratpaşa',
        squareMeters: 110,
        roomCount: '2+1',
        buildingAge: 6,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 2800000,
        currentPurchasePrice: 2800000,
        renovationStage: 0,
      );

      notifier.state = notifier.state.copyWith(
        ownedRealEstates: [...notifier.state.ownedRealEstates, testProp],
      );

      final ok = notifier.rushRenovation('prop_rush_all_test');
      expect(ok, isTrue);

      final finished = notifier.state.ownedRealEstates.firstWhere((p) => p.id == 'prop_rush_all_test');
      expect(finished.renovationStage, equals(3));
      expect(finished.isRenovated, isTrue);
      expect(finished.renovationDaysRemaining, equals(0));
      expect(finished.hasWaterLeakRisk, isTrue);
      expect(finished.isRushedRenovation, isTrue);
    });
  });

  group('Renovation Expansion 7-Language Localization & Invariant Compliance', () {
    final expansionKeys = [
      'real_estate_renovation_bonus_tag',
      'real_estate_change_package_btn',
      'real_estate_select_package_title',
      'real_estate_select_package_desc',
      'real_estate_package_applied_toast',
      'real_estate_rush_timer_btn',
      'real_estate_rush_timer_title',
      'real_estate_rush_timer_toast',
      'real_estate_days_suffix',
      // Modern Living
      'renov_pkg_modern_badge',
      'renov_pkg_modern_name',
      'renov_pkg_modern_desc',
      'renov_pkg_modern_s1_t',
      'renov_pkg_modern_s1_d',
      'renov_pkg_modern_s2_t',
      'renov_pkg_modern_s2_d',
      'renov_pkg_modern_s3_t',
      'renov_pkg_modern_s3_d',
      // Smart Luxury
      'renov_pkg_smart_badge',
      'renov_pkg_smart_name',
      'renov_pkg_smart_desc',
      'renov_pkg_smart_s1_t',
      'renov_pkg_smart_s1_d',
      'renov_pkg_smart_s2_t',
      'renov_pkg_smart_s2_d',
      'renov_pkg_smart_s3_t',
      'renov_pkg_smart_s3_d',
      // Eco Green
      'renov_pkg_eco_badge',
      'renov_pkg_eco_name',
      'renov_pkg_eco_desc',
      'renov_pkg_eco_s1_t',
      'renov_pkg_eco_s1_d',
      'renov_pkg_eco_s2_t',
      'renov_pkg_eco_s2_d',
      'renov_pkg_eco_s3_t',
      'renov_pkg_eco_s3_d',
      // Historic Wood
      'renov_pkg_historic_badge',
      'renov_pkg_historic_name',
      'renov_pkg_historic_desc',
      'renov_pkg_historic_s1_t',
      'renov_pkg_historic_s1_d',
      'renov_pkg_historic_s2_t',
      'renov_pkg_historic_s2_d',
      'renov_pkg_historic_s3_t',
      'renov_pkg_historic_s3_d',
      // Commercial Fitout
      'renov_pkg_comm_badge',
      'renov_pkg_comm_name',
      'renov_pkg_comm_desc',
      'renov_pkg_comm_s1_t',
      'renov_pkg_comm_s1_d',
      'renov_pkg_comm_s2_t',
      'renov_pkg_comm_s2_d',
      'renov_pkg_comm_s3_t',
      'renov_pkg_comm_s3_d',
      // Industrial Loft
      'renov_pkg_loft_badge',
      'renov_pkg_loft_name',
      'renov_pkg_loft_desc',
      'renov_pkg_loft_s1_t',
      'renov_pkg_loft_s1_d',
      'renov_pkg_loft_s2_t',
      'renov_pkg_loft_s2_d',
      'renov_pkg_loft_s3_t',
      'renov_pkg_loft_s3_d',
      // Garden Oasis
      'renov_pkg_garden_badge',
      'renov_pkg_garden_name',
      'renov_pkg_garden_desc',
      'renov_pkg_garden_s1_t',
      'renov_pkg_garden_s1_d',
      'renov_pkg_garden_s2_t',
      'renov_pkg_garden_s2_d',
      'renov_pkg_garden_s3_t',
      'renov_pkg_garden_s3_d',
      // Quick Flip
      'renov_pkg_flip_badge',
      'renov_pkg_flip_name',
      'renov_pkg_flip_desc',
      'renov_pkg_flip_s1_t',
      'renov_pkg_flip_s1_d',
      'renov_pkg_flip_s2_t',
      'renov_pkg_flip_s2_d',
      'renov_pkg_flip_s3_t',
      'renov_pkg_flip_s3_d',
      // Land Development
      'renov_pkg_land_badge',
      'renov_pkg_land_name',
      'renov_pkg_land_desc',
      'renov_pkg_land_s1_t',
      'renov_pkg_land_s1_d',
      'renov_pkg_land_s2_t',
      'renov_pkg_land_s2_d',
      'renov_pkg_land_s3_t',
      'renov_pkg_land_s3_d',
      // Building Facelift
      'renov_pkg_bldg_badge',
      'renov_pkg_bldg_name',
      'renov_pkg_bldg_desc',
      'renov_pkg_bldg_s1_t',
      'renov_pkg_bldg_s1_d',
      'renov_pkg_bldg_s2_t',
      'renov_pkg_bldg_s2_d',
      'renov_pkg_bldg_s3_t',
      'renov_pkg_bldg_s3_d',
    ];

    final translationMaps = {
      'tr': trTranslations,
      'en': enTranslations,
      'de': deTranslations,
      'es': esTranslations,
      'pt': ptTranslations,
      'ru': ruTranslations,
      'ar': arTranslations,
    };

    test('All expansion keys exist simultaneously in all 7 languages', () {
      for (final entry in translationMaps.entries) {
        final lang = entry.key;
        final map = entry.value;

        for (final key in expansionKeys) {
          expect(
            map.containsKey(key),
            isTrue,
            reason: 'Missing key "$key" in language "$lang"',
          );
          expect(
            map[key]!.trim().isNotEmpty,
            isTrue,
            reason: 'Empty translation for "$key" in language "$lang"',
          );
        }
      }
    });

    test('Invariant check: Zero unicode emojis in all translation strings', () {
      final emojiRegex = RegExp(
        r'[\u{1F300}-\u{1F9FF}|\u{2600}-\u{26FF}|\u{2700}-\u{27BF}|\u{1F600}-\u{1F64F}|\u{1F680}-\u{1F6FF}]',
        unicode: true,
      );

      for (final entry in translationMaps.entries) {
        final lang = entry.key;
        final map = entry.value;

        for (final key in expansionKeys) {
          final text = map[key]!;
          expect(
            emojiRegex.hasMatch(text),
            isFalse,
            reason: 'Emoji detected in key "$key" for language "$lang": "$text"',
          );
        }
      }
    });

    test('Invariant check: Zero parentheses in all translation strings', () {
      for (final entry in translationMaps.entries) {
        final lang = entry.key;
        final map = entry.value;

        for (final key in expansionKeys) {
          final text = map[key]!;
          expect(
            text.contains('(') || text.contains(')'),
            isFalse,
            reason: 'Parenthesis detected in key "$key" for language "$lang": "$text"',
          );
        }
      }
    });
  });
}
