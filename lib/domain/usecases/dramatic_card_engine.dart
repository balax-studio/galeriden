import 'dart:math';
import '../../data/models/car_model.dart';
import '../../data/models/dealership_model.dart';
import '../../data/models/dramatic_card_model.dart';
import '../../data/models/expertise_model.dart';
import '../../data/models/staff_model.dart';
import 'contextual_dilemma_pool.dart';
import 'daily_life_cards_data.dart';

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
  /// Generates the daily dilemma card for the specified calendar day • Day 1 to 365+
  static DramaticCardModel generateDailyDilemma(int day, DealershipModel state, {Random? randomInstance}) {
    final dayIndex = ((day - 1) % 365) + 1;
    final cardDef = DailyLifeCardsData.getCardForDay(dayIndex);
    return cardDef.toCard(day);
  }

  /// Selects the next appropriate dramatic dilemma card based on player state and cycle history
  static DramaticCardModel? selectNextCard(DealershipModel state, {Random? randomInstance}) {
    return generateDailyDilemma(state.currentDay, state, randomInstance: randomInstance);
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
    // Strict upfront cost deduction - prevent ₺0 balance exploit where expensive choices are taken for free
    final double upfrontCost = choice.upfrontCost;
    double newBalance = state.balance - upfrontCost + selectedOutcome.moneyDelta;
    if (selectedOutcome.isDynamicGrant) {
      newBalance += ContextualDilemmaPool.calculateDynamicGrant(state);
    }

    int newReputation = (state.reputation + selectedOutcome.reputationDelta).clamp(0, 1000);
    int newXP = state.experience + selectedOutcome.xpReward;

    List<CarModel> updatedCars = List.from(state.ownedCars);

    // Handle vehicle loss / damage (heirloom / locked cars are protected from theft)
    if (selectedOutcome.loseTargetCar && updatedCars.isNotEmpty) {
      final candidateCars = updatedCars.where((c) => !c.isLockedInShowcase).toList();
      if (candidateCars.isNotEmpty) {
        candidateCars.sort((a, b) => b.estimatedRealValue.compareTo(a.estimatedRealValue));
        final carToLose = candidateCars.first;
        updatedCars.removeWhere((c) => c.id == carToLose.id);
      }
    } else if (selectedOutcome.recoverCarValueMultiplier != null && updatedCars.isNotEmpty) {
      final candidateCars = updatedCars.where((c) => !c.isLockedInShowcase).toList();
      final targetList = candidateCars.isNotEmpty ? candidateCars : updatedCars;
      targetList.sort((a, b) => b.estimatedRealValue.compareTo(a.estimatedRealValue));
      final car = targetList.first;
      final idx = updatedCars.indexWhere((c) => c.id == car.id);
      if (idx != -1) {
        updatedCars[idx] = car.copyWith(
          baseMarketValue: car.baseMarketValue * selectedOutcome.recoverCarValueMultiplier!,
        );
      }
    }

    // Handle family heirloom status locking
    if (selectedOutcome.makeFamilyHeirloom && updatedCars.isNotEmpty) {
      final heirloomIndex = updatedCars.indexWhere((c) =>
          c.brand.toLowerCase().contains('tofaş') ||
          c.modelName.toLowerCase().contains('murat 124') ||
          c.modelName.toLowerCase().contains('124') ||
          c.isRare);
      final targetIndex = heirloomIndex != -1 ? heirloomIndex : 0;
      final targetCar = updatedCars[targetIndex];
      updatedCars[targetIndex] = targetCar.copyWith(
        isLockedInShowcase: true,
        clearListingPrice: true,
      );
    }

    // Handle staff salary multiplier
    List<StaffModel> updatedStaff = List.from(state.hiredStaff);
    if (selectedOutcome.staffSalaryMultiplier != null && updatedStaff.isNotEmpty) {
      updatedStaff = updatedStaff.map((s) {
        if (s.role == StaffRole.masterMechanic || s.role == StaffRole.apprentice) {
          return s.copyWith(salaryMultiplier: s.salaryMultiplier * selectedOutcome.staffSalaryMultiplier!);
        }
        return s;
      }).toList();
    }

    // Handle spawn bargain car
    if (selectedOutcome.spawnBargainCar && updatedCars.length < state.maxGarageSlots) {
      final bargainCar = CarModel(
        id: 'bargain_${DateTime.now().millisecondsSinceEpoch}',
        brand: 'Vosgen',
        modelName: 'Golf GTI Klasiği',
        modelYear: 2018,
        bodyType: 'Hatchback',
        colorHex: '#D90429',
        colorDisplayName: 'Lansman Kırmızısı',
        colorRarity: 'rare',
        plateNumber: '06 GTI 18',
        plateRarity: 'legendary',
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

    // Handle grant heirloom vehicle
    if (selectedOutcome.grantHeirloomVehicle) {
      final heirloomCar = CarModel(
        id: 'heirloom_classic_${DateTime.now().millisecondsSinceEpoch}',
        brand: 'Mercedes-Benz',
        modelName: '200D W123',
        modelYear: 1982,
        bodyType: 'Sedan',
        colorHex: '#2E4053',
        colorDisplayName: 'Dede Yadigârı Gece Mavisi',
        colorRarity: 'rare',
        plateNumber: '06 DEDE 82',
        plateRarity: 'legendary',
        currentPurchasePrice: 0.0,
        baseMarketValue: 240000.0,
        isHeroShowcase: true,
        expertise: ExpertiseReport(
          engineCondition: 68.0,
          transmissionCondition: 72.0,
          tramerAmount: 0,
          mileage: 285000,
          isMileageTampered: false,
          bodyParts: const {},
        ),
      );
      updatedCars.add(heirloomCar);
    }

    // Update seen card IDs
    final updatedSeenIds = List<String>.from(state.seenDramaticCardIds);
    if (!updatedSeenIds.contains(card.id)) {
      updatedSeenIds.add(card.id);
    }

    // Mutate NPC relationships dynamically based on choices (§2.4)
    final updatedNpc = Map<String, int>.from(state.npcRelationships);
    final charLower = card.characterName.toLowerCase();
    if (charLower.contains('necati')) {
      if (choice.id.contains('give') || choice.id.contains('accept')) {
        updatedNpc['necati'] = selectedOutcome.isSuccess
            ? ((updatedNpc['necati'] ?? 50) + 35).clamp(0, 100)
            : 0;
      } else {
        updatedNpc['necati'] = ((updatedNpc['necati'] ?? 50) - 30).clamp(0, 100);
      }
    } else if (charLower.contains('berk') || charLower.contains('vlogger')) {
      if (choice.id.contains('sponsor') || choice.id.contains('accept') || choice.id.contains('give')) {
        updatedNpc['vlogger_berk'] = ((updatedNpc['vlogger_berk'] ?? 50) + 25).clamp(0, 100);
      } else {
        updatedNpc['vlogger_berk'] = ((updatedNpc['vlogger_berk'] ?? 50) - 15).clamp(0, 100);
      }
    } else if (charLower.contains('gölge') || charLower.contains('ibrahim')) {
      if (selectedOutcome.isSuccess) {
        updatedNpc['golge_ibrahim'] = ((updatedNpc['golge_ibrahim'] ?? 50) + 20).clamp(0, 100);
      }
    } else if (charLower.contains('haydar')) {
      updatedNpc['haydar_usta'] = ((updatedNpc['haydar_usta'] ?? 50) + (selectedOutcome.isSuccess ? 15 : -10)).clamp(0, 100);
    }

    final updatedState = state.copyWith(
      balance: newBalance,
      reputationScore: newReputation,
      skills: state.skills.copyWith(xp: newXP),
      ownedCars: updatedCars,
      hiredStaff: updatedStaff,
      npcRelationships: updatedNpc,
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
