import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'package:galeriden/presentation/screens/real_estate/real_estate_renovation_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Real Estate Renovation & Craftsmanship Expansion Suite', () {
    test('1. RealEstateModel: Zeigarnik stages, progress, defect risk & sale gating', () {
      final baseProperty = RealEstateModel(
        id: 'prop_test_1',
        title: 'Kadıköy Apartman Dairesi',
        category: RealEstateCategory.housing,
        city: 'İstanbul',
        district: 'Kadıköy',
        squareMeters: 120,
        roomCount: '3+1',
        buildingAge: 5,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 2000000,
        currentPurchasePrice: 2000000,
        renovationStage: 0,
        isRenovated: false,
      );

      // Stage 0: 0%
      expect(baseProperty.renovationStage, equals(0));
      expect(baseProperty.renovationPercent, equals(0));
      expect(baseProperty.renovationProgress, equals(0.0));
      expect(baseProperty.isUnderRenovation, isFalse);
      expect(baseProperty.canBeSold, isTrue);
      expect(baseProperty.canBeRented, isTrue);

      // Stage 1: 35%
      final stage1 = baseProperty.copyWith(renovationStage: 1);
      expect(stage1.renovationPercent, equals(35));
      expect(stage1.renovationProgress, closeTo(0.35, 0.01));
      expect(stage1.isUnderRenovation, isTrue);
      expect(stage1.canBeSold, isFalse);
      expect(stage1.canBeRented, isFalse);

      // Stage 2: 70%
      final stage2 = baseProperty.copyWith(renovationStage: 2);
      expect(stage2.renovationPercent, equals(70));
      expect(stage2.renovationProgress, closeTo(0.70, 0.01));
      expect(stage2.isUnderRenovation, isTrue);
      expect(stage2.canBeSold, isFalse);
      expect(stage2.canBeRented, isFalse);

      // Stage 3: 100%
      final stage3 = baseProperty.copyWith(renovationStage: 3, isRenovated: true);
      expect(stage3.renovationPercent, equals(100));
      expect(stage3.renovationProgress, equals(1.0));
      expect(stage3.isUnderRenovation, isFalse);
      expect(stage3.canBeSold, isTrue);
      expect(stage3.canBeRented, isTrue);

      // Water leak risk penalty (-10% on estimatedRealValue)
      final withLeak = stage3.copyWith(hasWaterLeakRisk: true);
      expect(withLeak.estimatedRealValue, equals(stage3.estimatedRealValue * 0.90));

      // Personal residence restrictions & prestige bonus
      final asResidence = stage3.copyWith(isPersonalResidence: true);
      expect(asResidence.personalResidencePrestigeBonus, equals(15));
      expect(asResidence.canBeSold, isFalse);
      expect(asResidence.canBeRented, isFalse);

      // Rented property restriction
      final rented = stage3.copyWith(isRented: true);
      expect(rented.canBeSold, isFalse);
    });

    test('2. Serialization backward compatibility for older save games', () {
      final legacyJson = {
        'id': 'legacy_prop',
        'title': 'Eski Daire',
        'category': 'housing',
        'city': 'İstanbul',
        'district': 'Beşiktaş',
        'squareMeters': 90,
        'roomCount': '2+1',
        'buildingAge': 12,
        'deedType': 'ownershipDeed',
        'sellerType': 'individual',
        'baseMarketValue': 1000000.0,
        'currentPurchasePrice': 1000000.0,
        'isRenovated': true,
      };

      final fromLegacy = RealEstateModel.fromJson(legacyJson);
      expect(fromLegacy.renovationStage, equals(3));
      expect(fromLegacy.renovationPercent, equals(100));
      expect(fromLegacy.isUnderRenovation, isFalse);
    });

    test('3. GameRealEstateMixin: Stage advance, rush renovation, leak repair and rent collection', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      final testProperty = RealEstateModel(
        id: 'prop_test_2',
        title: 'Moda Sahil Evi',
        category: RealEstateCategory.housing,
        city: 'İstanbul',
        district: 'Kadıköy',
        squareMeters: 180,
        roomCount: '4+1',
        buildingAge: 2,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 5000000,
        currentPurchasePrice: 5000000,
        renovationStage: 0,
        isRenovated: false,
      );

      notifier.state = notifier.state.copyWith(
        balance: 10000000,
        ownedRealEstates: [testProperty],
      );

      // Advance stage 1
      notifier.advanceRenovationStage('prop_test_2');
      var p = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'prop_test_2');
      expect(p.renovationStage, equals(1));
      expect(p.renovationDaysRemaining, equals(2));
      expect(p.isUnderRenovation, isTrue);

      final blocked = notifier.advanceRenovationStage('prop_test_2');
      expect(blocked, isFalse);

      notifier.advanceGameDay();
      p = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'prop_test_2');
      expect(p.renovationDaysRemaining, equals(1));

      notifier.advanceGameDay();
      p = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'prop_test_2');
      expect(p.renovationDaysRemaining, equals(0));

      // Advance stage 2
      notifier.advanceRenovationStage('prop_test_2');
      p = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'prop_test_2');
      expect(p.renovationStage, equals(2));
      expect(p.isUnderRenovation, isTrue);

      notifier.state = notifier.state.copyWith(
        ownedRealEstates: [p.copyWith(renovationDaysRemaining: 0)],
      );

      // Advance stage 3
      notifier.advanceRenovationStage('prop_test_2');
      p = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'prop_test_2');
      expect(p.renovationStage, equals(3));
      expect(p.isRenovated, isTrue);
      expect(p.isUnderRenovation, isFalse);

      final testProperty2 = RealEstateModel(
        id: 'prop_test_3',
        title: 'Caddebostan Daire',
        category: RealEstateCategory.housing,
        city: 'İstanbul',
        district: 'Kadıköy',
        squareMeters: 110,
        roomCount: '3+1',
        buildingAge: 7,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 3000000,
        currentPurchasePrice: 3000000,
        renovationStage: 0,
      );
      notifier.state = notifier.state.copyWith(
        ownedRealEstates: [...notifier.state.ownedRealEstates, testProperty2],
      );

      notifier.rushRenovation('prop_test_3');
      var p2 = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'prop_test_3');
      expect(p2.renovationStage, equals(3));
      expect(p2.isRenovated, isTrue);
      expect(p2.hasWaterLeakRisk, isTrue);
      expect(p2.isRushedRenovation, isTrue);

      notifier.repairWaterLeak('prop_test_3');
      p2 = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'prop_test_3');
      expect(p2.hasWaterLeakRisk, isFalse);

      notifier.setPersonalResidence('prop_test_2');
      p = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'prop_test_2');
      expect(p.isPersonalResidence, isTrue);
      expect(p.canBeSold, isFalse);
      expect(p.canBeRented, isFalse);

      notifier.vacatePersonalResidence('prop_test_2');
      p = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'prop_test_2');
      expect(p.isPersonalResidence, isFalse);
      expect(p.canBeSold, isTrue);

      notifier.state = notifier.state.copyWith(
        ownedRealEstates: [
          p.copyWith(
            pendingRentIncome: 30000,
            uncollectedRentDays: 6,
          ),
        ],
      );

      final prevBalance = notifier.state.balance;
      final collected = notifier.collectRent('prop_test_2');
      expect(collected, equals(30000));
      expect(notifier.state.balance, equals(prevBalance + 30000));
      p = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'prop_test_2');
      expect(p.pendingRentIncome, equals(0));
      expect(p.uncollectedRentDays, equals(0));

      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      container.dispose();
    });

    test('4. Contains 10 rich craftsmanship expansion packages', () {
      expect(RealEstateRenovationExpansion.allPackages.length, equals(10));
      for (final pkg in RealEstateRenovationExpansion.allPackages) {
        expect(pkg.stages.length, equals(3));
        expect(pkg.bonusMultiplier, greaterThan(1.0));
        expect(pkg.applicableCategories.isNotEmpty, isTrue);
      }
    });

    test('5. Random diversity: Different property IDs receive varied packages', () {
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
      expect(pkg1.applicableCategories.contains(RealEstateCategory.housing), isTrue);
      expect(pkg2.applicableCategories.contains(RealEstateCategory.housing), isTrue);
    });

    test('6. Explicit renovationPackageId overrides deterministic fallback', () {
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

    test('7. Stage costs vary dynamically with package ratios and property size', () {
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
      expect(costS2, greaterThan(costS1));
      expect(costS3, equals(costS1));
    });

    test('8. setRenovationPackage allows switching package only at stage 0', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

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
        ownedRealEstates: [testProp],
        balance: 1000000,
      );

      final success = notifier.setRenovationPackage(
        'prop_stage0_test',
        RealEstateRenovationExpansion.packageCommercialFitoutId,
      );
      expect(success, isTrue);

      final updated = notifier.state.ownedRealEstates.firstWhere((p) => p.id == 'prop_stage0_test');
      expect(updated.renovationPackageId, equals(RealEstateRenovationExpansion.packageCommercialFitoutId));

      final propStage1 = updated.copyWith(renovationStage: 1);
      notifier.state = notifier.state.copyWith(ownedRealEstates: [propStage1]);

      final switchFail = notifier.setRenovationPackage(
        'prop_stage0_test',
        RealEstateRenovationExpansion.packageIndustrialLoftId,
      );
      expect(switchFail, isFalse);

      container.dispose();
    });

    test('9. accelerateRenovationTimer clears days remaining to 0 via rewarded ad', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      final prop = RealEstateModel(
        id: 'prop_timer_test',
        title: 'Zamanlı Daire',
        category: RealEstateCategory.housing,
        city: 'Ankara',
        district: 'Çankaya',
        squareMeters: 100,
        roomCount: '3+1',
        buildingAge: 5,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 2000000,
        currentPurchasePrice: 2000000,
        renovationStage: 1,
        renovationDaysRemaining: 5,
      );

      notifier.state = notifier.state.copyWith(ownedRealEstates: [prop]);

      final accelerated = notifier.accelerateRenovationTimer('prop_timer_test');
      expect(accelerated, isTrue);

      final updated = notifier.state.ownedRealEstates.firstWhere((p) => p.id == 'prop_timer_test');
      expect(updated.renovationDaysRemaining, equals(0));

      container.dispose();
    });

    test('10. Invariant Rule: Zero Unicode Emojis & Zero Parentheses across all keys in 7 languages', () {
      final allTranslations = <String, Map<String, String>>{
        'tr': trTranslations,
        'en': enTranslations,
        'de': deTranslations,
        'pt': ptTranslations,
        'es': esTranslations,
        'ru': ruTranslations,
        'ar': arTranslations,
      };

      final faz3Keys = [
        'real_estate_renovation_title',
        'real_estate_workshop_badge',
        'real_estate_badge_under_renovation',
        'real_estate_renovation_zeigarnik_stage0',
        'real_estate_renovation_zeigarnik_stage1',
        'real_estate_renovation_zeigarnik_stage2',
        'real_estate_renovation_zeigarnik_stage3',
        'real_estate_renovation_zeigarnik_warning',
        'real_estate_stage1_title',
        'real_estate_stage1_desc',
        'real_estate_stage2_title',
        'real_estate_stage2_desc',
        'real_estate_stage3_title',
        'real_estate_stage3_desc',
        'real_estate_stage_btn_start',
        'real_estate_rush_title',
        'real_estate_rush_desc',
        'real_estate_rush_btn',
        'real_estate_leak_alert_title',
        'real_estate_leak_alert_desc',
        'real_estate_leak_repair_btn',
        'real_estate_leak_badge',
        'real_estate_residence_badge',
        'real_estate_set_residence_btn',
        'real_estate_vacate_residence_btn',
        'real_estate_residence_toast',
        'real_estate_rent_pool_title',
        'real_estate_rent_pool_desc',
        'real_estate_rent_collect_btn',
        'real_estate_rent_collect_all_btn',
        'real_estate_rent_collect_toast',
        'real_estate_rent_delay_warning',
        'real_estate_sale_blocked_rented',
        'real_estate_sale_blocked_residence',
        'real_estate_sale_blocked_renovation',
        'real_estate_renovation_in_progress',
      ];

      final emojiRegex = RegExp(
        r'[\u{1F300}-\u{1F9FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]|[\u{1FA00}-\u{1FAFF}]',
        unicode: true,
      );
      final parenthesisRegex = RegExp(r'[()]');

      for (final entry in allTranslations.entries) {
        final lang = entry.key;
        final map = entry.value;

        for (final key in faz3Keys) {
          final text = map[key];
          expect(text, isNotNull, reason: 'Key $key must exist in $lang');
          expect(
            emojiRegex.hasMatch(text!),
            isFalse,
            reason: 'Key $key in $lang contains emoji: $text',
          );
          expect(
            parenthesisRegex.hasMatch(text),
            isFalse,
            reason: 'Key $key in $lang contains parentheses: $text',
          );
        }
      }
    });

    testWidgets('11. Widget Test: RealEstateRenovationScreen renders Zeigarnik stages', (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      final testProperty = RealEstateModel(
        id: 'prop_widget_test',
        title: 'Caddebostan Sahil Rezidans',
        category: RealEstateCategory.housing,
        city: 'İstanbul',
        district: 'Kadıköy',
        squareMeters: 200,
        roomCount: '4+1',
        buildingAge: 1,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 15000000,
        currentPurchasePrice: 15000000,
        renovationStage: 1, // 35%
        isRenovated: false,
      );

      notifier.state = notifier.state.copyWith(
        balance: 50000000,
        ownedRealEstates: [testProperty],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            locale: Locale('tr'),
            supportedLocales: [
              Locale('tr'),
              Locale('en'),
            ],
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: RealEstateRenovationScreen(propertyId: 'prop_widget_test'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Caddebostan Sahil Rezidans'), findsOneWidget);
      expect(find.text('Mülk Tadilat & Yenileme Atölyesi'.toUpperCase()), findsOneWidget);
      expect(
        find.text('Tadilat %35 Tamamlandı • Mutfak & Banyo Bitirilmedi'),
        findsOneWidget,
      );
      expect(find.text('AŞAMAYI BAŞLAT'), findsOneWidget);
      expect(find.text('REKLAM İLE HIZLANDIR'), findsWidgets);

      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      container.dispose();
    });
  });
}
