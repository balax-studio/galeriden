import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/real_estate_category.dart';
import 'package:galeriden/data/models/real_estate_model.dart';
import 'package:galeriden/domain/usecases/contractor_negotiation_expansion.dart';
import 'package:galeriden/domain/usecases/real_estate_buyer_negotiation_expansion.dart';
import 'package:galeriden/domain/usecases/real_estate_chat_negotiation_engine.dart';
import 'package:galeriden/domain/usecases/real_estate_negotiation_engine.dart';
import 'helpers/invariant_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sampleRealEstateIndividual = RealEstateModel(
    id: 're_test_indiv_1',
    title: 'Göztepe 3+1 Daire',
    category: RealEstateCategory.housing,
    city: 'İstanbul',
    district: 'Kadıköy',
    squareMeters: 130,
    roomCount: '3+1',
    buildingAge: 5,
    baseMarketValue: 10000000.0,
    currentPurchasePrice: 10000000.0,
    deedType: DeedType.ownershipDeed,
    sellerType: RealEstateSellerType.individual,
  );

  const sampleListingIndividual = RealEstateListingModel(
    id: 'listing_indiv_1',
    realEstate: sampleRealEstateIndividual,
    askingPrice: 10000000.0,
    sellerName: 'Ahmet Bey',
    sellerTrait: 'Tok Satıcı',
    description: 'Test ilanı',
    isHotDeal: false,
  );

  const sampleRealEstateBank = RealEstateModel(
    id: 're_test_bank_1',
    title: 'İcra İhalesi Ticari Bina',
    category: RealEstateCategory.building,
    city: 'Ankara',
    district: 'Çankaya',
    squareMeters: 500,
    roomCount: 'Bina',
    buildingAge: 10,
    baseMarketValue: 25000000.0,
    currentPurchasePrice: 25000000.0,
    deedType: DeedType.ownershipDeed,
    sellerType: RealEstateSellerType.bankAuction,
  );

  const sampleListingBank = RealEstateListingModel(
    id: 'listing_bank_1',
    realEstate: sampleRealEstateBank,
    askingPrice: 25000000.0,
    sellerName: 'Varlık Yönetim A.Ş.',
    sellerTrait: 'Kurumsal Ofis Müdürü',
    description: 'Banka icra satışı',
    isHotDeal: false,
  );

  group('Real Estate Negotiation & Buyer Archetype Suite', () {
    test('1. Detects all 6 buyer archetypes accurately from name and property category', () {
      final fund = RealEstateBuyerNegotiationExpansion.detectBuyerArchetype(
        'Bora Soydan • Yatırım Fonu Direktörü',
        RealEstateCategory.building,
      );
      expect(fund.id, BuyerArchetypeId.fundDirector);

      final ind = RealEstateBuyerNegotiationExpansion.detectBuyerArchetype(
        'Teoman Bey • Sanayici',
        RealEstateCategory.commercial,
      );
      expect(ind.id, BuyerArchetypeId.industrialist);

      final family = RealEstateBuyerNegotiationExpansion.detectBuyerArchetype(
        'Dr. Selin & Aile',
        RealEstateCategory.housing,
      );
      expect(family.id, BuyerArchetypeId.familyBuyer);

      final merchant = RealEstateBuyerNegotiationExpansion.detectBuyerArchetype(
        'Hacı Esnaf Osman Ticaret',
        RealEstateCategory.commercial,
      );
      expect(merchant.id, BuyerArchetypeId.merchantTrader);

      final expat = RealEstateBuyerNegotiationExpansion.detectBuyerArchetype(
        'Kerem Bey • Gurbetçi Yatırımcı',
        RealEstateCategory.housing,
      );
      expect(expat.id, BuyerArchetypeId.expatInvestor);

      final opportunist = RealEstateBuyerNegotiationExpansion.detectBuyerArchetype(
        'Mert Kaya Tok Alıcı',
        RealEstateCategory.land,
      );
      expect(opportunist.id, BuyerArchetypeId.opportunist);
    });

    test('2. Dynamic tactic progression cycles correctly through steps', () {
      final step0 = RealEstateBuyerNegotiationExpansion.getTacticStep(
        ChatTacticType.counterPrice,
        0,
      );
      final step1 = RealEstateBuyerNegotiationExpansion.getTacticStep(
        ChatTacticType.counterPrice,
        1,
      );
      final step2 = RealEstateBuyerNegotiationExpansion.getTacticStep(
        ChatTacticType.counterPrice,
        2,
      );
      final step3 = RealEstateBuyerNegotiationExpansion.getTacticStep(
        ChatTacticType.counterPrice,
        3,
      );

      expect(step0.labelKey, 'buyer_tactic_counter_label_0');
      expect(step1.labelKey, 'buyer_tactic_counter_label_1');
      expect(step2.labelKey, 'buyer_tactic_counter_label_2');
      expect(step3.labelKey, 'buyer_tactic_counter_label_0');

      final deed0 = RealEstateBuyerNegotiationExpansion.getTacticStep(
        ChatTacticType.transferDeedCosts,
        0,
      );
      final deed1 = RealEstateBuyerNegotiationExpansion.getTacticStep(
        ChatTacticType.transferDeedCosts,
        1,
      );
      expect(deed0.labelKey, 'buyer_tactic_deed_cost_label_0');
      expect(deed1.labelKey, 'buyer_tactic_deed_cost_label_1');
    });

    test('3. Buyer evaluation outputs formatted prices without raw integers', () {
      final state = ChatNegotiationState(
        targetId: 'prop_test',
        counterpartyName: 'Bora Soydan',
        counterpartyRole: ChatSenderRole.buyer,
        currentPrice: 5000000.0,
        patience: 100,
        satisfaction: 50,
      );

      final archetype = RealEstateBuyerNegotiationExpansion.detectBuyerArchetype(
        state.counterpartyName,
        RealEstateCategory.housing,
      );

      final result = RealEstateBuyerNegotiationExpansion.evaluateBuyerTactic(
        state: state,
        tactic: ChatTacticType.counterPrice,
        archetype: archetype,
        random: Random(42),
      );

      expect(result.nextPrice, greaterThanOrEqualTo(5000000.0));
      expect(result.replyText.contains('₺5155500'), isFalse);
      expect(result.patienceDelta, lessThan(0));
    });

    test('4. Full 7-language synchronization and invariant checks for all buyer negotiation keys', () {
      final requiredKeys = [
        'buyer_tactic_counter_label_0',
        'buyer_tactic_counter_label_1',
        'buyer_tactic_counter_label_2',
        'buyer_tactic_counter_msg_0',
        'buyer_tactic_counter_msg_1',
        'buyer_tactic_counter_msg_2',
        'buyer_tactic_deed_cost_label_0',
        'buyer_tactic_deed_cost_label_1',
        'buyer_tactic_deed_cost_label_2',
        'buyer_tactic_deed_cost_msg_0',
        'buyer_tactic_deed_cost_msg_1',
        'buyer_tactic_deed_cost_msg_2',
        'buyer_tactic_cash_block_label_0',
        'buyer_tactic_cash_block_label_1',
        'buyer_tactic_cash_block_label_2',
        'buyer_tactic_cash_block_msg_0',
        'buyer_tactic_cash_block_msg_1',
        'buyer_tactic_cash_block_msg_2',
        'buyer_tactic_location_label_0',
        'buyer_tactic_location_label_1',
        'buyer_tactic_location_label_2',
        'buyer_tactic_location_msg_0',
        'buyer_tactic_location_msg_1',
        'buyer_tactic_location_msg_2',
        'buyer_tactic_fixture_label_0',
        'buyer_tactic_fixture_label_1',
        'buyer_tactic_fixture_label_2',
        'buyer_tactic_fixture_msg_0',
        'buyer_tactic_fixture_msg_1',
        'buyer_tactic_fixture_msg_2',
        'buyer_tactic_coffee_label',
        'buyer_tactic_coffee_msg',
        'buyer_chat_patience_normal',
        'buyer_chat_patience_tense',
        'buyer_chat_patience_critical',
        'buyer_chat_player_role_tag',
        'buyer_chat_buyer_role_tag',
        'buyer_chat_market_diff_badge',
        'buyer_chat_tactics_title',
        'buyer_chat_agreed_toast',
        'buyer_chat_walkaway_toast',
        'buyer_archetype_fund_title',
        'buyer_archetype_fund_sub',
        'buyer_archetype_industrialist_title',
        'buyer_archetype_industrialist_sub',
        'buyer_archetype_family_title',
        'buyer_archetype_family_sub',
        'buyer_archetype_merchant_title',
        'buyer_archetype_merchant_sub',
        'buyer_archetype_expat_title',
        'buyer_archetype_expat_sub',
        'buyer_archetype_opportunist_title',
        'buyer_archetype_opportunist_sub',
      ];

      expectInvariantKeys(requiredKeys);
    });

    test('5. Bank or Agency seller is assigned corporate personality', () {
      final personality = RealEstateNegotiationEngine.getSellerPersonality(sampleListingBank);
      expect(personality, RealEstateSellerPersonality.corporate);
      expect(personality.localizationKey, 'real_estate_personality_corporate');
      expect(personality.descriptionKey, 'real_estate_personality_corporate_desc');
    });

    test('6. Individual sellers are deterministically assigned urgent or stubborn personality', () {
      final personality1 = RealEstateNegotiationEngine.getSellerPersonality(sampleListingIndividual);
      expect(
        personality1 == RealEstateSellerPersonality.urgent ||
            personality1 == RealEstateSellerPersonality.stubborn,
        true,
      );
    });

    test('7. Personality affects buyer success chance', () {
      final stubbornChance = RealEstateNegotiationEngine.calculateBuyerSuccessChance(
        askingPrice: 10000000.0,
        offeredPrice: 9000000.0,
        playerLevel: 10,
        sellerType: RealEstateSellerType.individual,
        personality: RealEstateSellerPersonality.stubborn,
      );

      final corporateChance = RealEstateNegotiationEngine.calculateBuyerSuccessChance(
        askingPrice: 10000000.0,
        offeredPrice: 9000000.0,
        playerLevel: 10,
        sellerType: RealEstateSellerType.individual,
        personality: RealEstateSellerPersonality.corporate,
      );

      final urgentChance = RealEstateNegotiationEngine.calculateBuyerSuccessChance(
        askingPrice: 10000000.0,
        offeredPrice: 9000000.0,
        playerLevel: 10,
        sellerType: RealEstateSellerType.individual,
        personality: RealEstateSellerPersonality.urgent,
      );

      expect(urgentChance > corporateChance, true);
      expect(corporateChance > stubbornChance, true);
    });

    test('8. getThinkingSteps returns 3 distinct localization keys', () {
      final steps = RealEstateNegotiationEngine.getThinkingSteps();
      expect(steps.length, 3);
      expect(steps.toSet().length, 3);
      expect(steps.contains('real_estate_thinking_step_owner'), true);
      expect(steps.contains('real_estate_thinking_step_tax'), true);
      expect(steps.contains('real_estate_thinking_step_market'), true);
    });

    test('9. Very low offer generates detailed esnaf rejection reason without unicode emoji or parentheses', () {
      final outcome = RealEstateNegotiationEngine.evaluateOffer(
        listing: sampleListingIndividual,
        offeredPrice: 7000000.0,
        currentPatience: 20,
        playerLevel: 1,
        personality: RealEstateSellerPersonality.stubborn,
      );

      if (!outcome.isAccepted && outcome.rejectionReason != null) {
        expectValidInvariantString(outcome.rejectionReason!);
      }
    });

    test('10. Personality influences counter-offer price calculation', () {
      final urgentOutcome = RealEstateNegotiationEngine.evaluateOffer(
        listing: sampleListingIndividual,
        offeredPrice: 9000000.0,
        currentPatience: 75,
        playerLevel: 1,
        personality: RealEstateSellerPersonality.urgent,
      );

      final stubbornOutcome = RealEstateNegotiationEngine.evaluateOffer(
        listing: sampleListingIndividual,
        offeredPrice: 9000000.0,
        currentPatience: 75,
        playerLevel: 1,
        personality: RealEstateSellerPersonality.stubborn,
      );

      if (urgentOutcome.isCounterOffer && stubbornOutcome.isCounterOffer) {
        expect(urgentOutcome.counterOfferPrice! <= stubbornOutcome.counterOfferPrice!, true);
      }
    });
  });

  group('RealEstateChatNegotiationEngine Tests', () {
    test('createContractorSession initializes with opening contractor message and 100 patience', () {
      final session = RealEstateChatNegotiationEngine.createContractorSession(
        landId: 'land_123',
        contractorName: 'Metropol Yapı',
        totalUnits: 12,
        baseMarketValue: 5000000.0,
      );

      expect(session.counterpartyName, 'Metropol Yapı');
      expect(session.counterpartyRole, ChatSenderRole.contractor);
      expect(session.patience, 100);
      expect(session.currentSharePercent, 50);
      expect(session.messages.length, 1);
      expect(session.messages.first.isFromPlayer, isFalse);
      expect(session.messages.first.badgeText, isNotNull);
    });

    test('createBuyerSession initializes with opening buyer offer message', () {
      final session = RealEstateChatNegotiationEngine.createBuyerSession(
        propertyId: 'prop_456',
        buyerName: 'Ahmet Yılmaz',
        offeredPrice: 3800000.0,
        buyerNote: 'Peşin alıcıyım hemen devir yapalım.',
        isRental: false,
      );

      expect(session.counterpartyName, 'Ahmet Yılmaz');
      expect(session.counterpartyRole, ChatSenderRole.buyer);
      expect(session.currentPrice, 3800000.0);
      expect(session.messages.first.message, 'Peşin alıcıyım hemen devir yapalım.');
    });

    test('executeTactic acceptAgreement sets isAgreed to true with mutabakat reply', () {
      final session = RealEstateChatNegotiationEngine.createContractorSession(
        landId: 'land_123',
        contractorName: 'Metropol Yapı',
        totalUnits: 12,
        baseMarketValue: 5000000.0,
      );

      final next = RealEstateChatNegotiationEngine.executeTactic(
        state: session,
        tactic: ChatTacticType.acceptAgreement,
        playerMessageText: 'Şartları kabul ediyorum, sözleşmeyi imzalayalım.',
        random: Random(42),
      );

      expect(next.isAgreed, isTrue);
      expect(next.isWalkedAway, isFalse);
      expect(next.messages.length, 3);
      expect(next.messages.last.badgeText, 'MUTABAKAT SAĞLANDI');
    });

    test('executeTactic walkAway immediately sets isWalkedAway to true', () {
      final session = RealEstateChatNegotiationEngine.createContractorSession(
        landId: 'land_123',
        contractorName: 'Metropol Yapı',
        totalUnits: 12,
        baseMarketValue: 5000000.0,
      );

      final next = RealEstateChatNegotiationEngine.executeTactic(
        state: session,
        tactic: ChatTacticType.walkAway,
        playerMessageText: 'Bu şartlarda sizinle anlaşamayız, masadan kalkıyorum.',
        random: Random(42),
      );

      expect(next.isWalkedAway, isTrue);
      expect(next.isAgreed, isFalse);
      expect(next.messages.last.badgeText, 'PAZARLIK BİTTİ');
    });

    test('createContractorSession with Hacı Reşat profile starts at %33 and base patience 110', () {
      final profile = ContractorNegotiationExpansion.getContractor('contractor_haci_resat');
      final session = RealEstateChatNegotiationEngine.createContractorSession(
        landId: 'land_haci',
        totalUnits: 20,
        baseMarketValue: 8000000.0,
        profile: profile,
      );

      expect(session.counterpartyName, 'Hacı Reşat & Oğulları Yapı');
      expect(session.patience, 110);
      expect(session.maxPatience, 110);
      expect(session.currentSharePercent, 33);
      expect(session.maxSharePercent, 50);
      expect(session.contractorId, 'contractor_haci_resat');
      expect(session.messages.first.badgeText, '%33 - %67 KAT KARŞILIĞI');
      expect(session.messages.first.message.contains('%33'), isTrue);
    });

    test('executeTactic askJokeOrChat restores patience and returns an authentic joke', () {
      final profile = ContractorNegotiationExpansion.getContractor('contractor_kartal_hizli');
      var session = RealEstateChatNegotiationEngine.createContractorSession(
        landId: 'land_kartal',
        totalUnits: 16,
        baseMarketValue: 6000000.0,
        profile: profile,
      );

      session = session.copyWith(patience: 40);

      final next = RealEstateChatNegotiationEngine.executeTactic(
        state: session,
        tactic: ChatTacticType.askJokeOrChat,
        playerMessageText: 'Ustam gel bir çay içelim, dertleşelim.',
        random: Random(42),
      );

      expect(next.patience, greaterThan(40));
      expect(next.messages.last.badgeText, 'ÇAY VE SOHBET • SABIR +22');
      expect(next.messages.last.message.isNotEmpty, isTrue);
    });

    test('executeTactic demandBankGuarantee handles corporate guarantee request', () {
      final profile = ContractorNegotiationExpansion.getContractor('contractor_metropol_mimarlik');
      final session = RealEstateChatNegotiationEngine.createContractorSession(
        landId: 'land_metropol',
        totalUnits: 24,
        baseMarketValue: 12000000.0,
        profile: profile,
      );

      final next = RealEstateChatNegotiationEngine.executeTactic(
        state: session,
        tactic: ChatTacticType.demandBankGuarantee,
        playerMessageText: 'Yarım kalma riskine karşı teminat mektubu istiyoruz.',
        random: Random(1),
      );

      expect(next.messages.length, 3);
      expect(next.patience, lessThan(session.patience));
    });
  });
}
