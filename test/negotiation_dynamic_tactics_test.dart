import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/customer_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/domain/usecases/negotiation_engine.dart';

void main() {
  group('Dynamic Esnaf Tactics & Dice Roll System Tests', () {
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
}
