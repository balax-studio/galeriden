import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/customer_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/listing_model.dart';
import 'package:galeriden/domain/usecases/negotiation_engine.dart';
import 'package:galeriden/domain/usecases/real_estate_tenant_negotiation_expansion.dart';
import 'package:galeriden/domain/usecases/real_estate_buyer_negotiation_expansion.dart';
import 'package:galeriden/domain/usecases/real_estate_chat_negotiation_engine.dart';
import 'package:galeriden/domain/usecases/vasita_negotiation_engine.dart';

void main() {
  final defaultExpertise = ExpertiseReport(
    engineCondition: 85,
    transmissionCondition: 90,
    tramerAmount: 5000,
    mileage: 120000,
    isMileageTampered: false,
    bodyParts: {
      'kaput': PartStatus.original,
      'tavan': PartStatus.original,
      'sol_on_camurluk': PartStatus.painted,
    },
  );

  final sampleCar = CarModel(
    id: 'car_test_1',
    brand: 'BMW',
    modelName: '320i',
    modelYear: 2018,
    bodyType: 'Sedan',
    colorHex: '#000000',
    baseMarketValue: 650000,
    currentPurchasePrice: 600000,
    expertise: defaultExpertise,
  );

  group('Dynamic Esnaf Tactics & Dice Roll System Tests', () {

    test('generateTactics produces exactly 3 contextual tactics for buying and selling', () {
      final buyingTactics = NegotiationEngine.generateTactics(
        isBuying: true,
        car: sampleCar,
        customer: CustomerModel(
          id: 'c1',
          name: 'Ahmet Bey',
          archetype: CustomerArchetype.skepticalOfficial,
          archetypeTitle: 'Şüpheci Memur',
          avatarType: 'official',
          personalityDescription: 'Her detayı inceler',
          preferredDialogueTrait: 'Resmi',
        ),
        price: 600000,
      );

      expect(buyingTactics.length, 3);
      for (final t in buyingTactics) {
        expect(t.context == TacticContext.buying || t.context == TacticContext.both, isTrue);
      }

      final sellingTactics = NegotiationEngine.generateTactics(
        isBuying: false,
        car: sampleCar,
        customer: CustomerModel(
          id: 'c2',
          name: 'Emre',
          archetype: CustomerArchetype.impatientYouth,
          archetypeTitle: 'Sabırsız Genç',
          avatarType: 'youth',
          personalityDescription: 'Aceleci',
          preferredDialogueTrait: 'Samimi',
        ),
        price: 650000,
      );

      expect(sellingTactics.length, 3);
      for (final t in sellingTactics) {
        expect(t.context == TacticContext.selling || t.context == TacticContext.both, isTrue);
      }
    });

    test('generateTactics produces distinct categories and varies across different offer IDs', () {
      final customer = CustomerModel(
        id: 'c2',
        name: 'Emre',
        archetype: CustomerArchetype.impatientYouth,
        archetypeTitle: 'Sabırsız Genç',
        avatarType: 'youth',
        personalityDescription: 'Aceleci',
        preferredDialogueTrait: 'Samimi',
      );

      final tacticsOffer1 = NegotiationEngine.generateTactics(
        isBuying: false,
        car: sampleCar,
        customer: customer,
        price: 650000,
        offerId: 'offer_1001_aaa',
      );

      final tacticsOffer2 = NegotiationEngine.generateTactics(
        isBuying: false,
        car: sampleCar,
        customer: customer,
        price: 650000,
        offerId: 'offer_1002_bbb',
      );

      expect(tacticsOffer1.length, 3);
      expect(tacticsOffer2.length, 3);

      // Verify distinct categories within the 3 tactics (distinct colors)
      final categories1 = tacticsOffer1.map((t) => t.category).toSet();
      expect(categories1.length, 3);

      final categories2 = tacticsOffer2.map((t) => t.category).toSet();
      expect(categories2.length, 3);

      // Verify each tactic has an accentColor
      for (final t in [...tacticsOffer1, ...tacticsOffer2]) {
        expect(t.accentColor, isNotNull);
      }
    });

    test('generateTactics produces distinct categories and varies across different listing IDs for buying', () {
      final customer = CustomerModel(
        id: 'seller_1',
        name: 'Ahmet Y.',
        archetype: CustomerArchetype.skepticalOfficial,
        archetypeTitle: 'Şüpheci Memur',
        avatarType: 'official',
        personalityDescription: 'Piyasa değerini bilir',
        preferredDialogueTrait: 'Resmi',
      );

      final tacticsListing1 = NegotiationEngine.generateTactics(
        isBuying: true,
        car: sampleCar,
        customer: customer,
        price: 689000,
        offerId: 'listing_101_crv',
      );

      final tacticsListing2 = NegotiationEngine.generateTactics(
        isBuying: true,
        car: sampleCar,
        customer: customer,
        price: 689000,
        offerId: 'listing_202_sedan',
      );

      expect(tacticsListing1.length, 3);
      expect(tacticsListing2.length, 3);

      final categories1 = tacticsListing1.map((t) => t.category).toSet();
      expect(categories1.length, 3);

      final categories2 = tacticsListing2.map((t) => t.category).toSet();
      expect(categories2.length, 3);
    });

    test('generateTactics prioritizes damaged parts/high mileage tactics for buyers', () {
      final damagedCar = sampleCar.copyWith(
        expertise: sampleCar.expertise.copyWith(
          mileage: 220000,
          bodyParts: {
            'kaput': PartStatus.damaged,
            'tavan': PartStatus.painted,
          },
        ),
      );

      final tactics = NegotiationEngine.generateTactics(
        isBuying: true,
        car: damagedCar,
        customer: CustomerModel(
          id: 'c1',
          name: 'Memur Bey',
          archetype: CustomerArchetype.skepticalOfficial,
          archetypeTitle: 'Şüpheci Memur',
          avatarType: 'official',
          personalityDescription: 'Her detayı inceler',
          preferredDialogueTrait: 'Resmi',
        ),
        price: 450000,
      );

      expect(tactics.any((t) => t.id == 'ekspertiz_kusuru'), isTrue);
    });

    test('rollTactic calculates diminishing returns across consecutive attempts', () {
      final tactic = NegotiationEngine.allTactics.firstWhere((t) => t.id == 'ekspertiz_kusuru');

      // Attempt 1: 75% base success
      final outcome1 = NegotiationEngine.rollTactic(
        tactic: tactic,
        tacticUsageIndex: 0,
        negotiationSkillLevel: 5,
        car: sampleCar,
        isBuying: true,
      );
      expect(outcome1.threshold, greaterThanOrEqualTo(75));

      // Attempt 2: 50% base success
      final outcome2 = NegotiationEngine.rollTactic(
        tactic: tactic,
        tacticUsageIndex: 1,
        negotiationSkillLevel: 5,
        car: sampleCar,
        isBuying: true,
      );
      expect(outcome2.threshold, lessThan(outcome1.threshold));

      // Attempt 3: 30% base success
      final outcome3 = NegotiationEngine.rollTactic(
        tactic: tactic,
        tacticUsageIndex: 2,
        negotiationSkillLevel: 5,
        car: sampleCar,
        isBuying: true,
      );
      expect(outcome3.threshold, lessThan(outcome2.threshold));
    });

    test('all tactic dialogues and outcomes adhere strictly to zero unicode emoji and zero parenthesis invariant rules', () {
      final emojiPattern = RegExp(r'[\u{1F300}-\u{1F9FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]', unicode: true);

      for (final tactic in NegotiationEngine.allTactics) {
        // Zero Parentheses Check
        expect(tactic.title.contains('(') || tactic.title.contains(')'), isFalse, reason: 'Parenthesis in title: ${tactic.title}');
        expect(tactic.badgeText.contains('(') || tactic.badgeText.contains(')'), isFalse, reason: 'Parenthesis in badge: ${tactic.badgeText}');
        expect(tactic.description.contains('(') || tactic.description.contains(')'), isFalse, reason: 'Parenthesis in description: ${tactic.description}');
        expect(tactic.successDialogue.contains('(') || tactic.successDialogue.contains(')'), isFalse, reason: 'Parenthesis in success: ${tactic.successDialogue}');
        expect(tactic.failureDialogue.contains('(') || tactic.failureDialogue.contains(')'), isFalse, reason: 'Parenthesis in failure: ${tactic.failureDialogue}');
        expect(tactic.walkawayDialogue.contains('(') || tactic.walkawayDialogue.contains(')'), isFalse, reason: 'Parenthesis in walkaway: ${tactic.walkawayDialogue}');

        // Zero Unicode Emoji Check
        expect(emojiPattern.hasMatch(tactic.title), isFalse, reason: 'Emoji in title: ${tactic.title}');
        expect(emojiPattern.hasMatch(tactic.badgeText), isFalse, reason: 'Emoji in badge: ${tactic.badgeText}');
        expect(emojiPattern.hasMatch(tactic.description), isFalse, reason: 'Emoji in description: ${tactic.description}');
        expect(emojiPattern.hasMatch(tactic.successDialogue), isFalse, reason: 'Emoji in success: ${tactic.successDialogue}');
        expect(emojiPattern.hasMatch(tactic.failureDialogue), isFalse, reason: 'Emoji in failure: ${tactic.failureDialogue}');
        expect(emojiPattern.hasMatch(tactic.walkawayDialogue), isFalse, reason: 'Emoji in walkaway: ${tactic.walkawayDialogue}');
      }
    });
  });

  group('Expanded Multi-Screen Negotiation & Chatbot Dynamics Tests', () {
    final emojiPattern = RegExp(
        r'[\u{1F300}-\u{1F9FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]|[\u{1F600}-\u{1F64F}]',
        unicode: true);

    test('Tenant deck contains 14 distinct tactics and replenishes hand dynamically until exhaustion', () {
      final allTactics = RealEstateTenantNegotiationExpansion.getAllTactics();
      expect(allTactics.length, 14);

      final usedCounts = <TenantTacticType, int>{};
      var hand = RealEstateTenantNegotiationExpansion.getAvailableDeck(usedCounts).take(4).toList();
      expect(hand.length, 4);

      // Consume the first card in hand
      final firstCard = hand.first;
      usedCounts[firstCard.type] = (usedCounts[firstCard.type] ?? 0) + 1;

      // New hand must not contain the consumed card, and must draw the 5th card from deck
      var nextHand = RealEstateTenantNegotiationExpansion.getAvailableDeck(usedCounts).take(4).toList();
      expect(nextHand.length, 4);
      expect(nextHand.any((c) => c.type == firstCard.type), isFalse);

      // Exhaust all 14 cards
      for (final card in allTactics) {
        usedCounts[card.type] = card.maxUses;
      }
      final exhaustedDeck = RealEstateTenantNegotiationExpansion.getAvailableDeck(usedCounts);
      expect(exhaustedDeck.isEmpty, isTrue);
    });

    test('Tenant tactic evaluations produce varied dynamic responses across invocations without emojis or parentheses', () {
      final archetype = RealEstateTenantNegotiationExpansion.archetypes.values.first;
      final responses = <String>{};

      for (var i = 0; i < 20; i++) {
        final outcome = RealEstateTenantNegotiationExpansion.evaluateTactic(
          tactic: TenantTacticType.offerRentDiscount,
          currentRent: 25000,
          currentDeposit: 50000,
          patience: 80,
          satisfaction: 50,
          archetype: archetype,
          useCount: 1,
          random: Random(i * 37 + 11),
        );
        expect(outcome.replyText.contains('(') || outcome.replyText.contains(')'), isFalse);
        expect(emojiPattern.hasMatch(outcome.replyText), isFalse);
        responses.add(outcome.replyText);
      }

      // Must produce more than 1 distinct response (anti-repetition chatbot dynamic)
      expect(responses.length, greaterThan(1));
    });

    test('Buyer tactic evaluations produce varied dynamic responses and track exhaustion', () {
      // Exhaustion check
      expect(RealEstateBuyerNegotiationExpansion.isTacticExhausted(ChatTacticType.counterPrice, 0), isFalse);
      expect(RealEstateBuyerNegotiationExpansion.isTacticExhausted(ChatTacticType.counterPrice, 3), isTrue);

      const state = ChatNegotiationState(
        targetId: 'target_1',
        counterpartyName: 'Kerem Bey',
        counterpartyRole: ChatSenderRole.buyer,
        currentPrice: 1000000,
        patience: 80,
        satisfaction: 50,
      );
      final archetype = RealEstateBuyerNegotiationExpansion.archetypes[BuyerArchetypeId.familyBuyer]!;

      final responses = <String>{};
      for (var i = 0; i < 20; i++) {
        final outcome = RealEstateBuyerNegotiationExpansion.evaluateBuyerTactic(
          state: state,
          tactic: ChatTacticType.counterPrice,
          archetype: archetype,
          random: Random(i * 43 + 7),
        );
        expect(outcome.replyText.contains('(') || outcome.replyText.contains(')'), isFalse);
        expect(emojiPattern.hasMatch(outcome.replyText), isFalse);
        responses.add(outcome.replyText);
      }
      expect(responses.length, greaterThan(1));
    });

    test('Vasita negotiation evaluations produce varied responses without emojis or parentheses', () {
      final listing = ListingModel(
        id: 'test-listing-1',
        car: sampleCar,
        sellerName: 'Kemal Bey',
        sellerCity: 'Ankara',
        sellerTrait: 'Memur',
        title: 'Satılık BMW',
        description: 'Temiz araç',
        askingPrice: 700000,
        isExpertiseCompleted: true,
        createdAt: DateTime.now(),
      );

      final responses = <String>{};
      for (var i = 0; i < 20; i++) {
        final result = VasitaNegotiationEngine.evaluateOffer(
          listing: listing,
          offeredPrice: 500000,
          currentPatience: 50,
          playerLevel: 3,
        );
        expect(result.responseMessage.contains('(') || result.responseMessage.contains(')'), isFalse);
        expect(emojiPattern.hasMatch(result.responseMessage), isFalse);
        responses.add(result.responseMessage);
      }
      expect(responses.length, greaterThan(1));
    });
  });
}

