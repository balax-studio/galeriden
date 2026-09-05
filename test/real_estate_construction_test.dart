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
import 'package:galeriden/presentation/screens/real_estate/real_estate_construction_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('FAZ 4: Real Estate Construction & Contractor Revenue Share Suite', () {
    test('1. RealEstateModel: Construction state, computed properties & sale gating', () {
      final baseLand = RealEstateModel(
        id: 'land_test_1',
        title: 'Çekmeköy İmarlı Arsa',
        category: RealEstateCategory.land,
        city: 'İstanbul',
        district: 'Çekmeköy',
        squareMeters: 600,
        roomCount: '-',
        buildingAge: 0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 5000000,
        currentPurchasePrice: 5000000,
      );

      // Stage 0: Inactive
      expect(baseLand.isConstructionActive, isFalse);
      expect(baseLand.constructionStage, equals(0));
      expect(baseLand.constructionProgress, equals(0.0));
      expect(baseLand.constructionPercent, equals(0));
      expect(baseLand.totalProjectUnits, equals(6)); // 600m2 -> 6 units
      expect(baseLand.canBeSold, isTrue);
      expect(baseLand.canBeRented, isFalse);

      // Stage 1 with contractor mode
      final contractorLand = baseLand.copyWith(
        constructionStage: 1,
        constructionMode: 'contractor',
        contractorSharePercent: 50,
        constructionDaysRemaining: 5,
      );
      expect(contractorLand.isConstructionActive, isTrue);
      expect(contractorLand.constructionProgress, equals(0.125));
      expect(contractorLand.constructionPercent, equals(13));
      expect(contractorLand.playerShareUnits, equals(3)); // 6 * 50% = 3
      expect(contractorLand.canPreSell, isFalse); // Contractor mode cannot pre-sell
      expect(contractorLand.canBeSold, isFalse); // Construction blocks selling
      expect(contractorLand.canBeRented, isFalse); // Construction blocks renting

      // Self-build mode with pre-sales
      final selfBuildLand = baseLand.copyWith(
        constructionStage: 2,
        constructionMode: 'selfBuild',
        contractorSharePercent: 0,
        constructionDaysRemaining: 4,
        soldPreSaleUnits: 1,
      );
      expect(selfBuildLand.isConstructionActive, isTrue);
      expect(selfBuildLand.constructionProgress, equals(0.25));
      expect(selfBuildLand.constructionPercent, equals(25));
      expect(selfBuildLand.playerShareUnits, equals(5)); // 6 units total - 1 presold = 5
      expect(selfBuildLand.canPreSell, isTrue); // sold 1 < 5 max allowed
      expect(selfBuildLand.preSaleUnitPrice, equals(1375000)); // (5.0M * 2.2 / 6) * 0.75
      expect(selfBuildLand.turnkeyUnitPrice, equals(2083333)); // 5.0M * 2.5 / 6

      // Serialization round-trip
      final json = selfBuildLand.toJson();
      final restored = RealEstateModel.fromJson(json);
      expect(restored.constructionStage, equals(2));
      expect(restored.constructionMode, equals('selfBuild'));
      expect(restored.soldPreSaleUnits, equals(1));
      expect(restored.contractorSharePercent, equals(0));
    });

    test('2. GameRealEstateMixin: Contractor Mode Start & Turnkey Finalization', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      final land = RealEstateModel(
        id: 'land_contractor_test',
        title: 'Beykoz İmar Parseli',
        category: RealEstateCategory.land,
        city: 'İstanbul',
        district: 'Beykoz',
        squareMeters: 600,
        roomCount: '-',
        buildingAge: 0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 6000000,
        currentPurchasePrice: 6000000,
      );

      notifier.state = notifier.state.copyWith(
        ownedRealEstates: [land],
        balance: 1000000,
      );

      // Start Contractor Construction (0 cost, 50% share)
      final startSuccess = notifier.startContractorConstruction('land_contractor_test');
      expect(startSuccess, isTrue);

      var currentLand = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'land_contractor_test');
      expect(currentLand.isConstructionActive, isTrue);
      expect(currentLand.constructionMode, equals('contractor'));
      expect(currentLand.constructionStage, equals(1));
      expect(currentLand.contractorSharePercent, equals(50));
      expect(currentLand.playerShareUnits, equals(3));
      expect(notifier.state.balance, equals(1000000)); // Zero cost

      // Advance to stage 8 (completed)
      notifier.state = notifier.state.copyWith(
        ownedRealEstates: [
          currentLand.copyWith(
            constructionStage: 8,
            constructionDaysRemaining: 0,
          ),
        ],
      );

      // Finalize Construction
      final createdUnits = notifier.finalizeConstruction('land_contractor_test');
      expect(createdUnits.length, equals(3));

      // Land parcel should be removed
      final remainingLands = notifier.state.ownedRealEstates.where((x) => x.id == 'land_contractor_test').toList();
      expect(remainingLands, isEmpty);

      // 3 Turnkey Housing Apartments should be added
      final newApartments = notifier.state.ownedRealEstates
          .where((x) => x.category == RealEstateCategory.housing && x.title.contains('Beykoz'))
          .toList();
      expect(newApartments.length, equals(3));
      for (final apt in newApartments) {
        expect(apt.deedType, equals(DeedType.ownershipDeed));
        expect(apt.isRenovated, isTrue);
        expect(apt.renovationStage, equals(3));
        expect(apt.estimatedRealValue, greaterThan(0));
      }

      container.dispose();
    });

    test('3. GameRealEstateMixin: Self-Build Mode, Off-Plan Pre-Sales & Stage Advancement', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      final land = RealEstateModel(
        id: 'land_selfbuild_test',
        title: 'Sarıyer Yatırımlık Arsa',
        category: RealEstateCategory.land,
        city: 'İstanbul',
        district: 'Sarıyer',
        squareMeters: 400,
        roomCount: '-',
        buildingAge: 0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 4000000,
        currentPurchasePrice: 4000000,
      );

      final initialBalance = 2000000.0;
      notifier.state = notifier.state.copyWith(
        ownedRealEstates: [land],
        balance: initialBalance,
      );

      // 1. Start Self-Build (deducts 10% upfront = 400,000 for Stage 1 Ruhsat & Proje)
      final startSuccess = notifier.startSelfBuildConstruction('land_selfbuild_test');
      expect(startSuccess, isTrue);
      expect(notifier.state.balance, equals(initialBalance - 400000));

      var currentLand = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'land_selfbuild_test');
      expect(currentLand.constructionMode, equals('selfBuild'));
      expect(currentLand.constructionStage, equals(1));
      expect(currentLand.playerShareUnits, equals(4)); // 400m2 -> 4 units, all for player

      // 2. Advance Stage to Stage 2 with capital funding (Stage 1 -> 2: 10% = 400,000)
      final balanceBeforeAdvance = notifier.state.balance;
      final advanceCost = (currentLand.baseMarketValue * 0.10).roundToDouble();
      final advanceSuccess = notifier.advanceSelfBuildStage('land_selfbuild_test', triggerIncidents: false);
      expect(advanceSuccess, isTrue);
      expect(notifier.state.balance, equals(balanceBeforeAdvance - advanceCost));

      currentLand = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'land_selfbuild_test');
      expect(currentLand.constructionStage, equals(2));
      expect(currentLand.constructionDaysRemaining, equals(4));

      // 3. Off-Plan Pre-Sale (Topraktan Satış) - enabled at stage 2+
      final balanceBeforePreSale = notifier.state.balance;
      final preSaleRevenue = notifier.preSellUnit('land_selfbuild_test');
      expect(preSaleRevenue, greaterThan(0));
      expect(notifier.state.balance, equals(balanceBeforePreSale + preSaleRevenue));

      currentLand = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'land_selfbuild_test');
      expect(currentLand.soldPreSaleUnits, equals(1));

      // 4. Advance to completion & Finalize
      notifier.state = notifier.state.copyWith(
        ownedRealEstates: [
          currentLand.copyWith(
            constructionStage: 8,
            constructionDaysRemaining: 0,
          ),
        ],
      );

      final deliveredUnits = notifier.finalizeConstruction('land_selfbuild_test');
      expect(deliveredUnits.length, equals(3));

      // Player had 4 units total and sold 1 unit off-plan -> 3 turnkey units received
      final portfolioUnits = notifier.state.ownedRealEstates
          .where((x) => x.category == RealEstateCategory.housing && x.title.contains('Sarıyer'))
          .toList();
      expect(portfolioUnits.length, equals(3));

      container.dispose();
    });

    test('4. Invariant Rules: Zero Unicode Emojis & Zero Parentheses across all FAZ 4 keys in 7 languages', () {
      final allTranslations = <String, Map<String, String>>{
        'tr': trTranslations,
        'en': enTranslations,
        'de': deTranslations,
        'pt': ptTranslations,
        'es': esTranslations,
        'ru': ruTranslations,
        'ar': arTranslations,
      };

      final faz4Keys = [
        'real_estate_sale_blocked_construction',
        'real_estate_construction_title',
        'real_estate_construction_badge_ready',
        'real_estate_construction_badge_active',
        'real_estate_construction_badge_idle',
        'real_estate_label_market_value',
        'real_estate_construction_potential_desc',
        'real_estate_contractor_title',
        'real_estate_contractor_desc',
        'real_estate_contractor_share',
        'real_estate_contractor_units',
        'real_estate_contractor_guarantee',
        'real_estate_contractor_btn',
        'real_estate_contractor_success_toast',
        'real_estate_self_build_title',
        'real_estate_self_build_desc',
        'real_estate_self_build_all_units',
        'real_estate_self_build_presale_right',
        'real_estate_self_build_max_profit',
        'real_estate_self_build_btn',
        'real_estate_self_build_success_toast',
        'real_estate_construction_stage0_status',
        'real_estate_construction_stage1_status',
        'real_estate_construction_stage2_status',
        'real_estate_construction_stage3_status',
        'real_estate_construction_stage4_status',
        'real_estate_construction_progress_header',
        'real_estate_construction_zeigarnik_lore',
        'real_estate_stage_m1_title',
        'real_estate_stage_m2_title',
        'real_estate_stage_m3_title',
        'real_estate_stage_m4_title',
        'real_estate_construction_mode_contractor',
        'real_estate_construction_mode_self_build',
        'real_estate_stat_mode',
        'real_estate_stat_player_units',
        'real_estate_stat_units_suffix',
        'real_estate_stat_days_remaining',
        'real_estate_stat_stage_ready',
        'real_estate_presale_title',
        'real_estate_presale_desc',
        'real_estate_presale_btn',
        'real_estate_presale_toast',
        'real_estate_advance_title',
        'real_estate_advance_desc',
        'real_estate_advance_stage_btn',
        'real_estate_advance_success_toast',
        'real_estate_contractor_working_title',
        'real_estate_contractor_working_desc',
        'real_estate_completion_title',
        'real_estate_completion_desc',
        'real_estate_finalize_btn',
        'real_estate_finalize_success_toast',
        'real_estate_btn_manage_construction',
        'real_estate_btn_start_construction',
        'real_estate_presale_last_unit_blocked',
      ];

      final emojiPattern = RegExp(
        r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
        unicode: true,
      );
      final parenthesesPattern = RegExp(r'[()]');

      for (final entry in allTranslations.entries) {
        final lang = entry.key;
        final map = entry.value;

        for (final key in faz4Keys) {
          expect(map.containsKey(key), isTrue,
              reason: 'Missing key "$key" in language "$lang"');

          final text = map[key]!;
          expect(emojiPattern.hasMatch(text), isFalse,
              reason: 'Invariant Violation: Found Unicode Emoji in "$key" ($lang): "$text"');
          expect(parenthesesPattern.hasMatch(text), isFalse,
              reason: 'Invariant Violation: Found Parentheses in "$key" ($lang): "$text"');
        }
      }
    });

    testWidgets('5. Widget Test: RealEstateConstructionScreen renders contractor & self-build workstation', (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      final land = RealEstateModel(
        id: 'land_widget_test',
        title: 'Silivri Sahil İmar Parseli',
        category: RealEstateCategory.land,
        city: 'İstanbul',
        district: 'Silivri',
        squareMeters: 600,
        roomCount: '-',
        buildingAge: 0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 3000000,
        currentPurchasePrice: 3000000,
      );

      notifier.state = notifier.state.copyWith(
        ownedRealEstates: [land],
        balance: 5000000,
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
            home: RealEstateConstructionScreen(landId: 'land_widget_test'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Screen Header and Land Details
      expect(find.text('Silivri Sahil İmar Parseli'), findsOneWidget);
      expect(find.byType(RealEstateConstructionScreen), findsOneWidget);

      // Verify both contract cards are displayed at Stage 0
      expect(find.text('KAT KARŞILIĞI MÜTEAHHİT ANLAŞMASI'), findsOneWidget);
      expect(find.text('ÖZ SERMAYE İLE KENDİN İNŞA ET'), findsOneWidget);
      expect(find.text('MÜTEAHHİTLE ANLAŞ'), findsOneWidget);
      expect(find.textContaining('ŞANTİYEYİ KENDİN BAŞLAT'), findsOneWidget);

      // Tap Contractor Agreement button
      await tester.tap(find.text('MÜTEAHHİTLE ANLAŞ'));
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // Verify active construction workstation UI rendered
      expect(find.text('ŞANTİYE VE İNŞAAT İLERLEMESİ'), findsOneWidget);
      expect(find.textContaining('Belediye Ruhsatı'), findsOneWidget);
      expect(find.textContaining('Hafriyat, Zemin Etüdü'), findsOneWidget);
      expect(find.textContaining('Temel, Perde'), findsOneWidget);
      expect(find.textContaining('Duvar Örme, Çatı'), findsOneWidget);

      // Clean up timer and container
      notifier.stopPeriodicOrganicOfferTimer();
      container.dispose();
    });
  });
}
