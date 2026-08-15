import 'dart:math';
import '../../data/models/car_model.dart';
import '../../data/models/dealership_model.dart';
import '../../data/models/dramatic_card_model.dart';
import '../../data/models/expertise_model.dart';

class DramaticResolutionResult {
  final DramaticCardModel card;
  final DramaticChoiceModel choice;
  final DramaticOutcomeModel outcome;
  final DealershipModel updatedState;

  const DramaticResolutionResult({
    required this.card,
    required this.choice,
    required this.outcome,
    required this.updatedState,
  });
}

class DramaticCardEngine {
  /// Selects the next appropriate dramatic dilemma card based on player state and cycle history
  static DramaticCardModel? selectNextCard(DealershipModel state, {Random? randomInstance}) {
    final rng = randomInstance ?? Random();
    final allCards = DramaticCardModel.defaultCards;

    // 1. Filter cards by context and gating requirements
    final eligibleCards = allCards.where((card) {
      if (card.minPlayerLevel > state.level) return false;
      if (card.requiresCarInGarage && state.ownedCars.isEmpty) return false;
      if (card.requiresHeirloomCar &&
          !state.ownedCars.any((c) =>
              c.brand.toLowerCase().contains('tofaş') ||
              c.modelName.toLowerCase().contains('murat 124') ||
              c.modelName.toLowerCase().contains('124'))) {
        return false;
      }
      return true;
    }).toList();

    if (eligibleCards.isEmpty) return allCards.first;

    // 2. Filter out already seen cards in the current cycle
    var availableCards = eligibleCards.where((c) => !state.seenDramaticCardIds.contains(c.id)).toList();

    // If all eligible cards have been seen in this cycle, start fresh cycle
    if (availableCards.isEmpty) {
      availableCards = List.from(eligibleCards);
    }

    // 3. Weighted Random Selection (Low/Medium cards appear more often than Extreme/Catastrophic ones)
    final List<DramaticCardModel> weightedPool = [];
    for (final card in availableCards) {
      int weight = 3;
      switch (card.severity) {
        case DramaticSeverity.low:
          weight = 4;
          break;
        case DramaticSeverity.medium:
          weight = 3;
          break;
        case DramaticSeverity.high:
          weight = 2;
          break;
        case DramaticSeverity.extreme:
          weight = 1;
          break;
      }
      for (int i = 0; i < weight; i++) {
        weightedPool.add(card);
      }
    }

    if (weightedPool.isEmpty) return availableCards.first;
    return weightedPool[rng.nextInt(weightedPool.length)];
  }

  /// Resolves the player's choice on a dramatic card, determining probabilistic outcomes and applying mutations
  static DramaticResolutionResult resolveChoice(
    DealershipModel state,
    DramaticCardModel card,
    DramaticChoiceModel choice, {
    double? fixedRoll,
    Random? randomInstance,
  }) {
    final rng = randomInstance ?? Random();
    final roll = fixedRoll ?? rng.nextDouble();

    // 1. Determine matching outcome from probability ranges
    DramaticOutcomeModel selectedOutcome = choice.outcomes.first;
    double cumulativeProbability = 0.0;
    for (final outcome in choice.outcomes) {
      cumulativeProbability += outcome.probability;
      if (roll <= cumulativeProbability || outcome == choice.outcomes.last) {
        selectedOutcome = outcome;
        break;
      }
    }

    // 2. Mutate Dealership State
    double newBalance = state.balance - choice.upfrontCost + selectedOutcome.moneyDelta;
    if (newBalance < 0) newBalance = 0;

    int newReputation = (state.reputation + selectedOutcome.reputationDelta).clamp(0, 100);
    int newXP = state.experience + selectedOutcome.xpReward;

    List<CarModel> updatedCars = List.from(state.ownedCars);

    // Handle vehicle loss / damage
    if (selectedOutcome.loseTargetCar && updatedCars.isNotEmpty) {
      // Lose the most valuable car
      updatedCars.sort((a, b) => b.estimatedRealValue.compareTo(a.estimatedRealValue));
      updatedCars.removeAt(0);
    } else if (selectedOutcome.recoverCarValueMultiplier != null && updatedCars.isNotEmpty) {
      updatedCars.sort((a, b) => b.estimatedRealValue.compareTo(a.estimatedRealValue));
      final car = updatedCars.first;
      updatedCars[0] = car.copyWith(
        baseMarketValue: car.baseMarketValue * selectedOutcome.recoverCarValueMultiplier!,
      );
    }

    // Handle spawn bargain car
    if (selectedOutcome.spawnBargainCar && updatedCars.length < state.maxGarageSlots) {
      final bargainCar = CarModel(
        id: 'bargain_${DateTime.now().millisecondsSinceEpoch}',
        brand: 'Volk',
        modelName: 'Golf GTI Klasiği',
        modelYear: 2018,
        bodyType: 'Hatchback',
        colorHex: 'D90429',
        currentPurchasePrice: 60000.0,
        baseMarketValue: 120000.0,
        expertise: ExpertiseReport(
          engineCondition: 92.0,
          transmissionCondition: 90.0,
          tramerAmount: 2500,
          mileage: 65000,
          isMileageTampered: false,
          bodyParts: const {},
        ),
      );
      updatedCars.add(bargainCar);
    }

    // Update seen card IDs
    final updatedSeenIds = List<String>.from(state.seenDramaticCardIds);
    if (!updatedSeenIds.contains(card.id)) {
      updatedSeenIds.add(card.id);
    }

    final updatedState = state.copyWith(
      balance: newBalance,
      reputationScore: newReputation,
      skills: state.skills.copyWith(xp: newXP),
      ownedCars: updatedCars,
      seenDramaticCardIds: updatedSeenIds,
      clearPendingDramaticCard: true,
    );

    return DramaticResolutionResult(
      card: card,
      choice: choice,
      outcome: selectedOutcome,
      updatedState: updatedState,
    );
  }
}
