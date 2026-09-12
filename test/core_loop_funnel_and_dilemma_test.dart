import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/player_skills.dart';
import 'package:galeriden/domain/usecases/contextual_dilemma_pool.dart';
import 'package:galeriden/domain/usecases/dramatic_card_engine.dart';

void main() {
  group('Core Loop Funnel & Dynamic Dilemmas Tests', () {
    test('PlayerSkills: Level 1 target XP is calibrated to 250 XP', () {
      expect(PlayerSkills.requiredXpForLevel(1), equals(250));
      expect(PlayerSkills.requiredXpForLevel(2), equals(750));
      expect(PlayerSkills.requiredXpForLevel(3), equals(1800));
      expect(PlayerSkills.requiredXpForLevel(4), equals(4500));
    });

    test('ContextualDilemmaPool: Returns rookie dealer card for Level 1 day 1 player', () {
      final game = DealershipModel.initial().copyWith(
        level: 1,
        currentDay: 1,
        balance: 100000.0,
      );

      final card = ContextualDilemmaPool.selectContextualCard(game);
      expect(card, isNotNull);
      expect(
        ContextualDilemmaPool.rookieCards.any((c) => c.id == card.id),
        isTrue,
        reason: 'Rookie player should receive cards from the rookie pool',
      );
    });

    test('ContextualDilemmaPool: Returns cash crisis card when balance is negative', () {
      final game = DealershipModel.initial().copyWith(
        level: 2,
        currentDay: 8,
        balance: -15000.0,
      );

      final card = ContextualDilemmaPool.selectContextualCard(game);
      expect(card, isNotNull);
      expect(
        ContextualDilemmaPool.cashCrisisCards.any((c) => c.id == card.id),
        isTrue,
        reason: 'Negative balance should trigger cash crisis dilemma card',
      );
    });

    test('ContextualDilemmaPool: Returns idle inventory card when player has unlisted cars', () {
      final car = CarModel(
        id: 'idle_car_1',
        brand: 'Renault',
        modelName: 'Clio',
        modelYear: 2016,
        bodyType: 'Hatchback',
        colorHex: '0xFFFFFFFF',
        baseMarketValue: 180000.0,
        currentPurchasePrice: 160000.0,
        expertise: ExpertiseReport(
          engineCondition: 85.0,
          transmissionCondition: 90.0,
          tramerAmount: 0,
          mileage: 65000,
          isMileageTampered: false,
          bodyParts: const {},
        ),
      );

      final game = DealershipModel.initial().copyWith(
        level: 3,
        currentDay: 6, // multiple of 3
        balance: 250000.0,
        ownedCars: [car],
      );

      final card = ContextualDilemmaPool.selectContextualCard(game);
      expect(card, isNotNull);
      expect(
        ContextualDilemmaPool.idleInventoryCards.any((c) => c.id == card.id),
        isTrue,
        reason: 'Stale idle car should trigger unlisted inventory dilemma card',
      );
    });

    test('DramaticCardEngine: Uses ContextualDilemmaPool dynamically instead of static 365 calendar', () {
      final game = DealershipModel.initial().copyWith(
        level: 1,
        currentDay: 15,
        balance: 80000.0,
      );

      final card = DramaticCardEngine.generateDailyDilemma(15, game);
      expect(card, isNotNull);
      // All cards in pools have valid choices and non-empty dialogue
      expect(card.choices.isNotEmpty, isTrue);
      expect(card.dialogue.isNotEmpty, isTrue);
    });
  });
}
