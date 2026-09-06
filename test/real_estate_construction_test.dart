import 'dart:math';
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
import 'package:galeriden/domain/usecases/construction_timeline_engine.dart';
import 'package:galeriden/domain/usecases/real_estate_chat_negotiation_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/screens/real_estate/real_estate_construction_screen.dart';

class FixedRandom implements Random {
  final double val;
  FixedRandom(this.val);
  @override
  double nextDouble() => val;
  @override
  int nextInt(int max) => 0;
  @override
  bool nextBool() => true;
}

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
      expect(selfBuildLand.preSaleUnitPrice, equals(1191667)); // (5.0M * 2.2 / 6) * 0.65 (stage 2)
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

      // 1. Start Self-Build Pre-Construction (Step 1: Architectural Plan, Step 2: Municipal Permit)
      final balanceBefore = notifier.state.balance;
      final startSuccess = notifier.startSelfBuildConstruction('land_selfbuild_test');
      expect(startSuccess, isTrue);
      final cost1 = balanceBefore - notifier.state.balance;

      notifier.advanceGameDay();
      notifier.state = notifier.state.copyWith(constructionCostIndex: 1.0);

      final balanceBeforePermit = notifier.state.balance;
      final permitSuccess = notifier.submitSelfBuildMunicipalPermit('land_selfbuild_test');
      expect(permitSuccess, isTrue);
      final cost2 = balanceBeforePermit - notifier.state.balance;

      notifier.advanceGameDay();
      notifier.state = notifier.state.copyWith(constructionCostIndex: 1.0);

      expect(cost1 + cost2, equals(400000));

      var currentLand = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'land_selfbuild_test');
      expect(currentLand.constructionMode, equals('selfBuild'));
      expect(currentLand.constructionStage, equals(2)); // B1: Ruhsat tamamlandı, 2. etaptan başlar
      expect(currentLand.playerShareUnits, equals(4)); // 400m2 -> 4 units, all for player

      // 2. Start Stage 2 with subcontractor (B1 & B9: startSelfBuildStage replaces legacy advance)
      final balanceBeforeStage2 = notifier.state.balance;
      final stage2Cost = ConstructionPricing.stageCost(currentLand, 2, costIndex: notifier.state.constructionCostIndex);
      final stage2Success = notifier.startSelfBuildStage('land_selfbuild_test', triggerIncidents: false);
      expect(stage2Success, isTrue);
      expect(notifier.state.balance, equals(balanceBeforeStage2 - stage2Cost));

      currentLand = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'land_selfbuild_test');
      expect(currentLand.constructionStage, equals(2));
      expect(currentLand.isConstructionWorking, isTrue);

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
      expect(find.textContaining('Mimari Planı Başlat'), findsOneWidget);

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

    test('6. ConstructionTimelineEngine: 8 Stages, Tier multipliers & Duration calculation', () {
      expect(ConstructionTimelineEngine.stages.length, equals(8));

      final stage1 = ConstructionTimelineEngine.getStageDetails(1);
      expect(stage1.stageNumber, equals(1));
      expect(stage1.baseDays, equals(8));
      expect(stage1.costPercentage, equals(0.10));

      final stage2 = ConstructionTimelineEngine.getStageDetails(2);
      expect(stage2.stageNumber, equals(2));
      expect(stage2.baseDays, equals(10));
      expect(stage2.costPercentage, equals(0.12));

      final standardDays = ConstructionTimelineEngine.calculateStageDays(
        stageNumber: 1,
        parcelSquareMeters: 500,
        tier: SubcontractorTier.standard,
      );
      final speedDays = ConstructionTimelineEngine.calculateStageDays(
        stageNumber: 1,
        parcelSquareMeters: 500,
        tier: SubcontractorTier.speed,
      );
      final budgetDays = ConstructionTimelineEngine.calculateStageDays(
        stageNumber: 1,
        parcelSquareMeters: 500,
        tier: SubcontractorTier.budget,
      );

      expect(speedDays, lessThanOrEqualTo(standardDays));
      expect(budgetDays, greaterThanOrEqualTo(standardDays));

      for (int s = 1; s <= 4; s++) {
        final subs = ConstructionTimelineEngine.getSubcontractorsForStage(s);
        expect(subs.length, equals(3));
        expect(subs.any((sub) => sub.tier == SubcontractorTier.speed), isTrue);
        expect(subs.any((sub) => sub.tier == SubcontractorTier.standard), isTrue);
        expect(subs.any((sub) => sub.tier == SubcontractorTier.budget), isTrue);
      }

      expect(ConstructionTimelineEngine.humorousAnecdoteKeys.isNotEmpty, isTrue);
      expect(ConstructionTimelineEngine.anecdoteTurkishTexts.isNotEmpty, isTrue);
      final randomAnecdote = ConstructionTimelineEngine.getRandomAnecdoteText(Random(42));
      expect(randomAnecdote.isNotEmpty, isTrue);
    });

    test('7. RealEstateChatNegotiationEngine: Subcontractor Tactics Execution', () {
      final session = ChatNegotiationState(
        targetId: 'land_sub_test',
        counterpartyName: 'Dozerci Bekir',
        counterpartyRole: ChatSenderRole.subcontractor,
        currentPrice: 500000.0,
        patience: 100,
        satisfaction: 60,
        messages: [
          ChatMessageModel(
            id: 'msg_0',
            senderName: 'Dozerci Bekir',
            role: ChatSenderRole.subcontractor,
            message: 'Hafriyat işini alırız patron.',
            timestamp: DateTime.now(),
            isFromPlayer: false,
          ),
        ],
      );

      expect(session.counterpartyRole, equals(ChatSenderRole.subcontractor));
      expect(session.currentPrice, equals(500000.0));
      expect(session.patience, equals(100));

      final afterDoubleShift = RealEstateChatNegotiationEngine.executeTactic(
        state: session,
        tactic: ChatTacticType.demandDoubleShift,
        playerMessageText: 'Mikserleri gece sokalım, çift vardiya basalım!',
        random: FixedRandom(0.2),
      );
      expect(afterDoubleShift.messages.length, greaterThan(session.messages.length));
      expect(afterDoubleShift.patience, lessThan(session.patience));
      expect(afterDoubleShift.messages.last.badgeText, equals('ÇİFT VARDİYA ONAYLANDI'));

      final afterCash = RealEstateChatNegotiationEngine.executeTactic(
        state: afterDoubleShift,
        tactic: ChatTacticType.demandCashMaterials,
        playerMessageText: 'Demir ve çimentoyu nakit çekeceğim!',
        random: FixedRandom(0.2),
      );
      expect(afterCash.currentPrice, lessThan(afterDoubleShift.currentPrice));
      expect(afterCash.messages.last.badgeText, equals('PEŞİN MALZEME İNDİRİMİ'));

      final afterPenalty = RealEstateChatNegotiationEngine.executeTactic(
        state: afterCash,
        tactic: ChatTacticType.demandPenaltyClause,
        playerMessageText: 'Gecikme cezası koyuyorum!',
        random: FixedRandom(0.2),
      );
      expect(afterPenalty.messages.last.badgeText, equals('CEZAİ ŞART TAAHHÜDÜ'));

      final agreed = RealEstateChatNegotiationEngine.executeTactic(
        state: afterPenalty,
        tactic: ChatTacticType.acceptAgreement,
        playerMessageText: 'Anlaştık usta el sıkışalım.',
        random: FixedRandom(0.2),
      );
      expect(agreed.isAgreed, isTrue);
      expect(agreed.messages.last.badgeText, equals('MUTABAKAT SAĞLANDI'));
    });

    test('8. GameRealEstateMixin & GameTimeMixin: 3-State Construction Lifecycle & Daily Countdown', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      final land = RealEstateModel(
        id: 'land_sim_test',
        title: 'Kemerburgaz Proje Arsası',
        category: RealEstateCategory.land,
        city: 'İstanbul',
        district: 'Eyüpsultan',
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
        balance: 10000000,
        maxRealEstateSlots: 10,
      );

      final startSuccess = notifier.startSelfBuildConstruction('land_sim_test');
      expect(startSuccess, isTrue);

      var currentLand = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'land_sim_test');
      expect(currentLand.isConstructionActive, isTrue);
      expect(currentLand.constructionMode, equals('selfBuild'));
      expect(currentLand.constructionStage, equals(1));
      expect(currentLand.constructionDaysRemaining, equals(1));
      expect(currentLand.isConstructionWorking, isTrue);
      expect(currentLand.isArchitecturalApproved, isFalse);

      notifier.advanceGameDay();
      currentLand = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'land_sim_test');
      expect(currentLand.isArchitecturalApproved, isTrue);
      expect(currentLand.hasBuildingPermit, isFalse);
      expect(currentLand.isConstructionWorking, isFalse);

      final permitSuccess = notifier.submitSelfBuildMunicipalPermit('land_sim_test');
      expect(permitSuccess, isTrue);
      currentLand = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'land_sim_test');
      expect(currentLand.isConstructionWorking, isTrue);
      expect(currentLand.constructionDaysRemaining, equals(1));

      notifier.advanceGameDay();
      currentLand = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'land_sim_test');
      expect(currentLand.hasBuildingPermit, isTrue);
      expect(currentLand.constructionStage, equals(2));
      expect(currentLand.constructionDaysRemaining, equals(0));
      expect(currentLand.isConstructionWorking, isFalse);

      final sub = ConstructionTimelineEngine.getSubcontractorsForStage(2).first;
      final balanceBeforeStage = notifier.state.balance;
      final stageStartSuccess = notifier.startSelfBuildStage(
        'land_sim_test',
        subcontractor: sub,
        triggerIncidents: false,
      );
      expect(stageStartSuccess, isTrue);
      expect(notifier.state.balance, lessThan(balanceBeforeStage));

      currentLand = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'land_sim_test');
      expect(currentLand.isConstructionWorking, isTrue);
      expect(currentLand.activeSubcontractorName, equals(sub.name));
      expect(currentLand.constructionDaysRemaining, greaterThan(0));

      while (currentLand.constructionDaysRemaining > 0) {
        notifier.advanceGameDay();
        currentLand = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'land_sim_test');
      }
      expect(currentLand.constructionDaysRemaining, equals(0));

      final completeStage2 = notifier.completeSelfBuildStage('land_sim_test');
      expect(completeStage2, isTrue);

      currentLand = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'land_sim_test');
      expect(currentLand.constructionStage, equals(3));
      expect(currentLand.isConstructionWorking, isFalse);

      for (int stage = 3; stage <= 8; stage++) {
        final stageSub = ConstructionTimelineEngine.getSubcontractorsForStage(stage)[1];
        notifier.startSelfBuildStage(
          'land_sim_test',
          subcontractor: stageSub,
          triggerIncidents: false,
        );

        var workingLand = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'land_sim_test');
        while (workingLand.constructionDaysRemaining > 0) {
          notifier.advanceGameDay();
          workingLand = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'land_sim_test');
        }

        final completeSuccess = notifier.completeSelfBuildStage('land_sim_test');
        expect(completeSuccess, isTrue);
      }

      final turnkeyApartments = notifier.finalizeConstruction('land_sim_test');
      expect(turnkeyApartments.isNotEmpty, isTrue);
      expect(turnkeyApartments.length, equals(6));

      notifier.stopPeriodicOrganicOfferTimer();
      container.dispose();
    });

    test('9. Invariant Rules: Anecdotes & Radio Messages have Zero Emojis & Zero Parentheses', () {
      final emojiPattern = RegExp(
        r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
        unicode: true,
      );
      final parenthesesPattern = RegExp(r'[()]');

      for (final text in ConstructionTimelineEngine.anecdoteTurkishTexts.values) {
        expect(emojiPattern.hasMatch(text), isFalse,
            reason: 'Invariant Violation: Emoji found in anecdote: "$text"');
        expect(parenthesesPattern.hasMatch(text), isFalse,
            reason: 'Invariant Violation: Parentheses found in anecdote: "$text"');
      }
    });

    test('10. Stage 4 Pre-Sale Capability & Dynamic Stage Cost Calculation', () {
      const baseLand = RealEstateModel(
        id: 'stage4_test_land',
        title: 'Beykoz Proje Sahası',
        category: RealEstateCategory.land,
        city: 'İstanbul',
        district: 'Beykoz',
        squareMeters: 600,
        roomCount: 'İmarlı Arsa',
        buildingAge: 0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 10000000.0,
        currentPurchasePrice: 10000000.0,
        constructionMode: 'selfBuild',
        contractorSharePercent: 0,
        constructionStage: 4,
        isConstructionWorking: true,
        constructionDaysRemaining: 10,
        soldPreSaleUnits: 2,
      );

      expect(baseLand.playerShareUnits, equals(4));
      expect(baseLand.canPreSell, isTrue);

      for (final stage in ConstructionTimelineEngine.stages) {
        final expectedCost = (baseLand.baseMarketValue * stage.costPercentage).roundToDouble();
        expect(expectedCost, greaterThan(0));
      }
    });
  });

  group('Construction & Kat Karşılığı Audit Constitution Tests', () {
    late RealEstateModel sampleLand;

    setUp(() {
      sampleLand = const RealEstateModel(
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
        customUnitMix: {
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
      expect(sampleLand.totalProjectUnits, 10);

      final land55 = sampleLand.copyWith(playerSharePercent: 55);
      expect(land55.playerShareUnits, 5);

      final land33 = sampleLand.copyWith(playerSharePercent: 33);
      expect(land33.playerShareUnits, 3);

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

      expect(nextState.isAgreed, isFalse);
      expect(nextState.currentPrice, greaterThanOrEqualTo(minPrice));
    });

    test('A6: Diminishing returns on askJokeOrChat', () {
      var state = RealEstateChatNegotiationEngine.createContractorSession(
        landId: 'land_test',
        totalUnits: 10,
        baseMarketValue: 5000000.0,
      ).copyWith(patience: 50, maxPatience: 100);

      state = RealEstateChatNegotiationEngine.executeTactic(
        state: state,
        tactic: ChatTacticType.askJokeOrChat,
        playerMessageText: 'Bir fıkra anlatayım',
        random: Random(42),
      );
      expect(state.jokeUseCount, 1);
      expect(state.patience, greaterThan(50));

      state = RealEstateChatNegotiationEngine.executeTactic(
        state: state,
        tactic: ChatTacticType.askJokeOrChat,
        playerMessageText: 'Bir tane daha',
        random: Random(42),
      );
      expect(state.jokeUseCount, 2);

      state = RealEstateChatNegotiationEngine.executeTactic(
        state: state,
        tactic: ChatTacticType.askJokeOrChat,
        playerMessageText: 'Son bir şaka',
        random: Random(42),
      );
      expect(state.jokeUseCount, 3);

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
      final landNoMix = sampleLand.copyWith(clearCustomUnitMix: true);
      expect(landNoMix.landPhase, LandPhase.imar);

      expect(sampleLand.landPhase, LandPhase.modSecimi);

      final landContractor = sampleLand.copyWith(
        constructionMode: 'contractor',
        constructionStage: 2,
        constructionDaysRemaining: 15,
      );
      expect(landContractor.landPhase, LandPhase.muteahhitBekleme);

      final landSelfBuildReady = sampleLand.copyWith(
        constructionMode: 'selfBuild',
        constructionStage: 2,
        isConstructionWorking: false,
        constructionDaysRemaining: 0,
      );
      expect(landSelfBuildReady.landPhase, LandPhase.etapHazir);

      final landSelfBuildWorking = sampleLand.copyWith(
        constructionMode: 'selfBuild',
        constructionStage: 2,
        isConstructionWorking: true,
        constructionDaysRemaining: 8,
      );
      expect(landSelfBuildWorking.landPhase, LandPhase.etapCalisiyor);

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
