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
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/screens/real_estate/real_estate_renovation_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('FAZ 3: Real Estate Renovation & Loss-Aversion Suite', () {
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
      // Older saves marked as isRenovated: true should automatically resolve to stage 3
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

      // Seed state with balance and owned real estate
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

      // Cannot advance while renovation days remaining > 0
      final blocked = notifier.advanceRenovationStage('prop_test_2');
      expect(blocked, isFalse);

      // Day passage reduces renovationDaysRemaining
      notifier.advanceGameDay();
      p = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'prop_test_2');
      expect(p.renovationDaysRemaining, equals(1));

      notifier.advanceGameDay();
      p = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'prop_test_2');
      expect(p.renovationDaysRemaining, equals(0));
      expect(notifier.state.recentEvents.any((e) => e.id.startsWith('renovation_ready_')), isTrue);

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

      // Test rush renovation on another property
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

      // Repair water leak
      notifier.repairWaterLeak('prop_test_3');
      p2 = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'prop_test_3');
      expect(p2.hasWaterLeakRisk, isFalse);

      // Test personal residence
      notifier.setPersonalResidence('prop_test_2');
      p = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'prop_test_2');
      expect(p.isPersonalResidence, isTrue);
      expect(p.canBeSold, isFalse);
      expect(p.canBeRented, isFalse);

      notifier.vacatePersonalResidence('prop_test_2');
      p = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'prop_test_2');
      expect(p.isPersonalResidence, isFalse);
      expect(p.canBeSold, isTrue);

      // Test rent accumulation & collection
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

      container.dispose();
    });

    test('4. Invariant Rule: Zero Unicode Emojis & Zero Parentheses in all FAZ 3 keys across 7 languages', () {
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

    testWidgets('5. Widget Test: RealEstateRenovationScreen renders Zeigarnik stages', (tester) async {
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

      // Check title and property name are rendered
      expect(find.text('Caddebostan Sahil Rezidans'), findsOneWidget);
      expect(find.text('Mülk Tadilat & Yenileme Atölyesi'.toUpperCase()), findsOneWidget);

      // Check Zeigarnik stage text (%35)
      expect(
        find.text('Tadilat %35 Tamamlandı • Mutfak & Banyo Bitirilmedi'),
        findsOneWidget,
      );

      // Check action button
      expect(find.text('AŞAMAYI BAŞLAT'), findsOneWidget);

      // Check rush with ad card
      expect(find.text('REKLAM İLE HIZLANDIR'), findsWidgets);

      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      container.dispose();
    });
  });
}
