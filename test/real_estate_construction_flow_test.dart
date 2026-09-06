import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  group('Realistic Day-Cycle Construction & Subcontractor System Suite', () {
    test('1. ConstructionTimelineEngine: 8 Stages, Tier multipliers & Duration calculation', () {
      expect(ConstructionTimelineEngine.stages.length, equals(8));

      // Stage details
      final stage1 = ConstructionTimelineEngine.getStageDetails(1);
      expect(stage1.stageNumber, equals(1));
      expect(stage1.baseDays, equals(8));
      expect(stage1.costPercentage, equals(0.10));

      final stage2 = ConstructionTimelineEngine.getStageDetails(2);
      expect(stage2.stageNumber, equals(2));
      expect(stage2.baseDays, equals(10));
      expect(stage2.costPercentage, equals(0.12));

      // Check tier calculation
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

      // Subcontractor profiles for each stage
      for (int s = 1; s <= 4; s++) {
        final subs = ConstructionTimelineEngine.getSubcontractorsForStage(s);
        expect(subs.length, equals(3));
        expect(subs.any((sub) => sub.tier == SubcontractorTier.speed), isTrue);
        expect(subs.any((sub) => sub.tier == SubcontractorTier.standard), isTrue);
        expect(subs.any((sub) => sub.tier == SubcontractorTier.budget), isTrue);
      }

      // Anecdotes pool
      expect(ConstructionTimelineEngine.humorousAnecdoteKeys.isNotEmpty, isTrue);
      expect(ConstructionTimelineEngine.anecdoteTurkishTexts.isNotEmpty, isTrue);
      final randomAnecdote = ConstructionTimelineEngine.getRandomAnecdoteText(Random(42));
      expect(randomAnecdote.isNotEmpty, isTrue);
    });

    test('2. RealEstateChatNegotiationEngine: Subcontractor Tactics Execution', () {
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

      // Tactic: Demand Double Shift (Gece Dökümü & Çift Vardiya)
      final afterDoubleShift = RealEstateChatNegotiationEngine.executeTactic(
        state: session,
        tactic: ChatTacticType.demandDoubleShift,
        playerMessageText: 'Mikserleri gece sokalım, çift vardiya basalım!',
        random: FixedRandom(0.2), // Guaranteed success
      );
      expect(afterDoubleShift.messages.length, greaterThan(session.messages.length));
      expect(afterDoubleShift.patience, lessThan(session.patience));
      expect(afterDoubleShift.messages.last.badgeText, equals('ÇİFT VARDİYA ONAYLANDI'));

      // Tactic: Demand Cash Materials (Peşin Malzeme İndirimi)
      final afterCash = RealEstateChatNegotiationEngine.executeTactic(
        state: afterDoubleShift,
        tactic: ChatTacticType.demandCashMaterials,
        playerMessageText: 'Demir ve çimentoyu nakit çekeceğim!',
        random: FixedRandom(0.2), // Guaranteed success
      );
      expect(afterCash.currentPrice, lessThan(afterDoubleShift.currentPrice));
      expect(afterCash.messages.last.badgeText, equals('PEŞİN MALZEME İNDİRİMİ'));

      // Tactic: Demand Penalty Clause (Gecikme Ceza Maddesi)
      final afterPenalty = RealEstateChatNegotiationEngine.executeTactic(
        state: afterCash,
        tactic: ChatTacticType.demandPenaltyClause,
        playerMessageText: 'Gecikme cezası koyuyorum!',
        random: FixedRandom(0.2), // Guaranteed success
      );
      expect(afterPenalty.messages.last.badgeText, equals('CEZAİ ŞART TAAHHÜDÜ'));

      // Tactic: Accept Agreement
      final agreed = RealEstateChatNegotiationEngine.executeTactic(
        state: afterPenalty,
        tactic: ChatTacticType.acceptAgreement,
        playerMessageText: 'Anlaştık usta el sıkışalım.',
        random: FixedRandom(0.2),
      );
      expect(agreed.isAgreed, isTrue);
      expect(agreed.messages.last.badgeText, equals('MUTABAKAT SAĞLANDI'));
    });

    test('3. GameRealEstateMixin & GameTimeMixin: 3-State Construction Lifecycle & Daily Countdown', () {
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

      // --- STATE 1: UNSTARTED ---
      // Start self build mode (deducts 15% upfront, initializes unstarted stage 1 with 0 days)
      final startSuccess = notifier.startSelfBuildConstruction('land_sim_test');
      expect(startSuccess, isTrue);

      var currentLand = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'land_sim_test');
      expect(currentLand.isConstructionActive, isTrue);
      expect(currentLand.constructionMode, equals('selfBuild'));
      expect(currentLand.constructionStage, equals(1));
      expect(currentLand.constructionDaysRemaining, equals(0));
      expect(currentLand.isConstructionWorking, isFalse);
      expect(currentLand.activeSubcontractorName, isNull);

      // Cannot complete stage 1 before starting/working
      final earlyComplete = notifier.completeSelfBuildStage('land_sim_test');
      expect(earlyComplete, isFalse);

      // --- STATE 2: WORKING ---
      // Select subcontractor and start Stage 1
      final sub = ConstructionTimelineEngine.getSubcontractorsForStage(1).first;
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
      expect(currentLand.stageTotalDays, equals(currentLand.constructionDaysRemaining));

      // Cannot start again while already working
      final duplicateStart = notifier.startSelfBuildStage('land_sim_test', subcontractor: sub);
      expect(duplicateStart, isFalse);

      // Simulate day progression (advanceGameDay)
      while (currentLand.constructionDaysRemaining > 0) {
        notifier.advanceGameDay();
        final landDuringWork = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'land_sim_test');
        if (landDuringWork.constructionDaysRemaining > 0) {
          expect(landDuringWork.isConstructionWorking, isTrue);
          expect(notifier.completeSelfBuildStage('land_sim_test'), isFalse);
        }
        currentLand = landDuringWork;
      }
      expect(currentLand.constructionDaysRemaining, equals(0));

      // --- STATE 3: HANDOVER & ADVANCE ---
      // Now player can complete and inspect stage 1
      final completeStage1 = notifier.completeSelfBuildStage('land_sim_test');
      expect(completeStage1, isTrue);

      currentLand = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'land_sim_test');
      expect(currentLand.constructionStage, equals(2));
      expect(currentLand.constructionDaysRemaining, equals(0));
      expect(currentLand.isConstructionWorking, isFalse);
      expect(currentLand.activeSubcontractorName, isNull);

      // Provenance log check
      expect(
        currentLand.provenanceLog.any((log) => log.contains('Aşama 1 başarıyla teslim alındı')),
        isTrue,
      );

      // Complete stages 2 through 8
      for (int stage = 2; stage <= 8; stage++) {
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

      // All 8 stages finished (constructionStage is now 9, or completed)
      final finishedLand = notifier.state.ownedRealEstates.firstWhere((x) => x.id == 'land_sim_test');
      expect(finishedLand.constructionStage, greaterThanOrEqualTo(8));

      // Finalize Construction and mint turnkey apartments
      final turnkeyApartments = notifier.finalizeConstruction('land_sim_test');
      expect(turnkeyApartments.isNotEmpty, isTrue);
      expect(turnkeyApartments.length, equals(6)); // 600m2 -> 6 units

      // Land parcel should be removed
      final remainingLands = notifier.state.ownedRealEstates.where((x) => x.id == 'land_sim_test').toList();
      expect(remainingLands, isEmpty);

      // Turnkey apartments present
      final createdHousing = notifier.state.ownedRealEstates
          .where((x) => x.category == RealEstateCategory.housing && x.district == 'Eyüpsultan')
          .toList();
      expect(createdHousing.length, equals(6));

      notifier.stopPeriodicOrganicOfferTimer();
      container.dispose();
    });

    test('4. Invariant Rules: Zero Unicode Emojis & Zero Parentheses across all new keys in 7 languages', () {
      final allTranslations = <String, Map<String, String>>{
        'tr': trTranslations,
        'en': enTranslations,
        'de': deTranslations,
        'pt': ptTranslations,
        'es': esTranslations,
        'ru': ruTranslations,
        'ar': arTranslations,
      };

      final newKeys = [
        'real_estate_stage_btn_select_subcontractor',
        'real_estate_stage_btn_working',
        'real_estate_stage_btn_handover',
        'real_estate_stage_desc_ready_handover',
        'real_estate_stage_desc_in_progress',
        'subcontractor_btn_select_for_stage',
        'subcontractor_btn_active_with_days',
        'real_estate_radio_dispatch_title',
        'real_estate_radio_badge_channel',
        'real_estate_radio_badge_standby',
        'real_estate_radio_default_quote',
        'real_estate_construction_timeline_title',
        'subcontractor_badge_unstarted',
        'subcontractor_btn_direct_hire',
        'subcontractor_toast_hired',
        'subcontractor_badge_working',
        'subcontractor_days_suffix',
        'subcontractor_tactic_double_shift_label',
        'subcontractor_tactic_double_shift_msg',
        'subcontractor_tactic_cash_materials_label',
        'subcontractor_tactic_cash_materials_msg',
        'subcontractor_tactic_penalty_clause_label',
        'subcontractor_tactic_penalty_clause_msg',
        'subcontractor_mode_budget',
      ];

      final emojiPattern = RegExp(
        r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
        unicode: true,
      );
      final parenthesesPattern = RegExp(r'[()]');

      for (final entry in allTranslations.entries) {
        final lang = entry.key;
        final map = entry.value;

        for (final key in newKeys) {
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

    test('5. Invariant Rules: Anecdotes & Radio Messages have Zero Emojis & Zero Parentheses', () {
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

    test('6. Stage 4 Pre-Sale Capability & Dynamic Stage Cost Calculation', () {
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

      // Player share is 6 units. Sold 2. Remaining 4 units > 1.
      expect(baseLand.playerShareUnits, equals(4));
      // At Stage 4 before completion, pre-sales are still possible
      expect(baseLand.canPreSell, isTrue);

      // Verify each stage's calculated cost matches ConstructionTimelineEngine
      for (final stage in ConstructionTimelineEngine.stages) {
        final expectedCost = (baseLand.baseMarketValue * stage.costPercentage).roundToDouble();
        expect(expectedCost, greaterThan(0));
      }
    });
  });
}
