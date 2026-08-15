import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/dramatic_card_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/domain/usecases/dramatic_card_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Dramatik Karar Kartları (Dramatic Decision Cards) Engine Tests', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('All 15 dramatic cards are defined across the 5 core categories', () {
      final cards = DramaticCardModel.defaultCards;
      expect(cards.length, greaterThanOrEqualTo(15));

      final categories = cards.map((c) => c.category).toSet();
      expect(categories.contains(DramaticCategory.loss), isTrue, reason: 'Category A: Kayıp Kartları');
      expect(categories.contains(DramaticCategory.betrayal), isTrue, reason: 'Category B: İhanet/Çalınma');
      expect(categories.contains(DramaticCategory.conscience), isTrue, reason: 'Category C: Vicdan Kartları');
      expect(categories.contains(DramaticCategory.legacy), isTrue, reason: 'Category D: Miras Kartları');
      expect(categories.contains(DramaticCategory.gamble), isTrue, reason: 'Category E: Kumar Kartları');
    });

    test('selectNextDramaticCard enforces level gating and asset requirements', () {
      // Level 1 player with no cars in garage
      final beginnerState = DealershipModel.initial().copyWith(
        dealershipName: 'Acemi Galeri',
        level: 1,
        balance: 50000.0,
        ownedCars: [],
      );

      final card = DramaticCardEngine.selectNextCard(beginnerState);
      expect(card, isNotNull);
      // Beginner should not get high-severity car theft (B1) or extreme gamble (E2)
      expect(card!.id != 'B1' && card.id != 'E2', isTrue);
      expect(card.minPlayerLevel <= 1, isTrue);
    });

    test('Cycle protection prevents repeating seen dramatic cards until all available are seen', () {
      final cards = DramaticCardModel.defaultCards;
      final seenIds = cards.take(5).map((c) => c.id).toList();

      final state = DealershipModel.initial().copyWith(
        dealershipName: 'Usta Galeri',
        level: 5,
        balance: 1000000.0,
        ownedCars: [
          CarModel(
            id: 'car_1',
            brand: 'Mercedes',
            modelName: 'C200',
            modelYear: 2021,
            bodyType: 'Sedan',
            colorHex: '000000',
            currentPurchasePrice: 200000.0,
            baseMarketValue: 250000.0,
            expertise: ExpertiseReport(
              engineCondition: 100.0,
              transmissionCondition: 100.0,
              tramerAmount: 0,
              mileage: 30000,
              isMileageTampered: false,
              bodyParts: {},
            ),
          )
        ],
        seenDramaticCardIds: seenIds,
      );

      final nextCard = DramaticCardEngine.selectNextCard(state);
      expect(nextCard, isNotNull);
      expect(seenIds.contains(nextCard!.id), isFalse, reason: 'Selected card must not be in seen list');
    });

    test('resolveDramaticChoice executes financial and reputation effects accurately', () {
      final cardA1 = DramaticCardModel.defaultCards.firstWhere((c) => c.id == 'A1'); // Necati Acil Nakit
      final choice1 = cardA1.choices.first; // ₺40.000 Borç Ver

      final state = DealershipModel.initial().copyWith(
        dealershipName: 'Güleryüz Oto',
        balance: 100000.0,
        reputationScore: 50,
      );

      final result = DramaticCardEngine.resolveChoice(state, cardA1, choice1, fixedRoll: 0.20); // Win roll (< 0.55)
      expect(result.outcome.isSuccess, isTrue);
      expect(result.updatedState.balance, 100000.0 - 40000.0 + 80000.0); // Net +40k
      expect(result.updatedState.reputation, 55); // +5 reputation
    });

    test('resolveDramaticChoice handles loss outcome on failure roll', () {
      final cardA1 = DramaticCardModel.defaultCards.firstWhere((c) => c.id == 'A1');
      final choice1 = cardA1.choices.first; // ₺40.000 Borç Ver

      final state = DealershipModel.initial().copyWith(
        dealershipName: 'Güleryüz Oto',
        balance: 100000.0,
        reputationScore: 50,
      );

      final result = DramaticCardEngine.resolveChoice(state, cardA1, choice1, fixedRoll: 0.80); // Loss roll (> 0.55)
      expect(result.outcome.isSuccess, isFalse);
      expect(result.updatedState.balance, 100000.0 - 40000.0); // 40k lost
    });

    test('Vehicle theft resolution (B1) removes the most valuable car on total loss outcome', () {
      final cardB1 = DramaticCardModel.defaultCards.firstWhere((c) => c.id == 'B1');
      final choiceInvestigate = cardB1.choices.first; // Special detective

      final cheapCar = CarModel(
        id: 'cheap_car',
        brand: 'Renault',
        modelName: 'Clio',
        modelYear: 2012,
        bodyType: 'Hatchback',
        colorHex: 'FFFFFF',
        currentPurchasePrice: 50000.0,
        baseMarketValue: 60000.0,
        expertise: ExpertiseReport(
          engineCondition: 80.0,
          transmissionCondition: 80.0,
          tramerAmount: 0,
          mileage: 120000,
          isMileageTampered: false,
          bodyParts: const {},
        ),
      );

      final expensiveCar = CarModel(
        id: 'expensive_car',
        brand: 'Porsche',
        modelName: 'Taycan',
        modelYear: 2023,
        bodyType: 'Sedan',
        colorHex: '000000',
        currentPurchasePrice: 800000.0,
        baseMarketValue: 1200000.0,
        expertise: ExpertiseReport(
          engineCondition: 100.0,
          transmissionCondition: 100.0,
          tramerAmount: 0,
          mileage: 10000,
          isMileageTampered: false,
          bodyParts: const {},
        ),
      );

      final state = DealershipModel.initial().copyWith(
        ownedCars: [cheapCar, expensiveCar],
        balance: 100000.0,
      );

      // Roll 0.80 -> failure (> 0.45), car lost permanently
      final result = DramaticCardEngine.resolveChoice(state, cardB1, choiceInvestigate, fixedRoll: 0.80);
      expect(result.outcome.loseTargetCar, isTrue);
      expect(result.updatedState.ownedCars.length, 1);
      expect(result.updatedState.ownedCars.first.id, 'cheap_car', reason: 'Most valuable car must be removed');
    });

    test('Narrative card D2 grants +100 XP with a single continue choice', () {
      final cardD2 = DramaticCardModel.defaultCards.firstWhere((c) => c.id == 'D2');
      expect(cardD2.isNarrativeOnly, isTrue);
      expect(cardD2.choices.length, 1);

      final state = DealershipModel.initial();
      final initialXP = state.skills.xp;

      final result = DramaticCardEngine.resolveChoice(state, cardD2, cardD2.choices.first);
      expect(result.updatedState.skills.xp, initialXP + 100);
      expect(result.outcome.isSuccess, isTrue);
    });

    test('DealershipModel JSON serialization preserves dramatic card fields', () {
      final cardE1 = DramaticCardModel.defaultCards.firstWhere((c) => c.id == 'E1');
      final state = DealershipModel.initial().copyWith(
        seenDramaticCardIds: ['A1', 'A2', 'C1'],
        daysSinceLastDramaticCard: 8,
        nextDramaticCardTargetDays: 24,
        pendingDramaticCard: cardE1,
      );

      final json = state.toJson();
      final reconstructed = DealershipModel.fromJson(json);

      expect(reconstructed.seenDramaticCardIds, ['A1', 'A2', 'C1']);
      expect(reconstructed.daysSinceLastDramaticCard, 8);
      expect(reconstructed.nextDramaticCardTargetDays, 24);
      expect(reconstructed.pendingDramaticCard, isNotNull);
      expect(reconstructed.pendingDramaticCard!.id, 'E1');
    });

    test('advanceGameDay increments dramatic card days and schedules next card between 15 and 30 days', () {
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        daysSinceLastDramaticCard: 14,
        nextDramaticCardTargetDays: 15,
        pendingDramaticCard: null,
      );

      notifier.advanceGameDay();

      expect(notifier.state.pendingDramaticCard, isNotNull);
      expect(notifier.state.daysSinceLastDramaticCard, 0);
      expect(notifier.state.nextDramaticCardTargetDays, inInclusiveRange(15, 30));
    });
  });
}
