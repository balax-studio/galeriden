import 'dart:math' as math;
import '../../../data/models/car_model.dart';
import '../../../data/models/casino_game_model.dart';
import '../../../data/models/mission_model.dart';
import '../../../domain/usecases/casino_engine.dart';
import 'game_base_notifier.dart';

mixin GameCasinoMixin on GameBaseNotifier {
  // ==========================================
  // 1. VALET BACCARAT
  // ==========================================
  BaccaratResult? playCasinoBaccarat({
    required double betAmount,
    required BaccaratBetChoice choice,
    CarModel? wageredCar,
  }) {
    if (wageredCar != null) {
      if (!state.ownedCars.any((c) => c.id == wageredCar.id)) return null;
    } else {
      if (state.balance < betAmount || betAmount <= 0) return null;
    }

    // Deduct wager initially
    double currentBalance = state.balance;
    List<CarModel> updatedCars = List.from(state.ownedCars);

    if (wageredCar != null) {
      updatedCars.removeWhere((c) => c.id == wageredCar.id);
    } else {
      currentBalance -= betAmount;
    }

    final result = CasinoEngine.playBaccarat(
      betAmount: betAmount,
      choice: choice,
      wageredCar: wageredCar,
    );

    final effectiveBet = wageredCar != null ? wageredCar.price : betAmount;
    final isWin = result.isWin;
    final payout = result.payoutAmount;

    // Apply winnings
    if (isWin) {
      currentBalance += payout;
      if (wageredCar != null) {
        // Player gets back their wagered car
        updatedCars.add(wageredCar);
      }
      if (result.wonCar != null) {
        // Player wins bonus supercar
        updatedCars.add(result.wonCar!);
      }
    }

    // Update stats
    final oldStats = state.casinoStats;
    final newStats = oldStats.copyWith(
      totalGamesPlayed: oldStats.totalGamesPlayed + 1,
      totalWonAmount: oldStats.totalWonAmount + (isWin ? (payout - effectiveBet) : 0.0),
      totalLostAmount: oldStats.totalLostAmount + (isWin ? 0.0 : effectiveBet),
      biggestMultiplierRecord: math.max(oldStats.biggestMultiplierRecord, isWin ? (payout / effectiveBet) : 1.0),
      vehiclesWageredCount: oldStats.vehiclesWageredCount + (wageredCar != null ? 1 : 0),
      vehiclesLostCount: oldStats.vehiclesLostCount + (wageredCar != null && !isWin ? 1 : 0),
      vehiclesWonCount: oldStats.vehiclesWonCount + (result.wonCar != null ? 1 : 0),
    );

    state = state.copyWith(
      balance: currentBalance,
      ownedCars: updatedCars,
      casinoStats: newStats,
    );

    updateMissionProgress(MissionType.casinoPlay, 1);
    return result;
  }

  // ==========================================
  // 2. STREET CRAPS (SOKAK ZARI)
  // ==========================================
  StreetCrapsRollResult? playCasinoStreetCraps({
    required CrapsPhase currentPhase,
    int? currentPoint,
    required double betAmount,
    CarModel? wageredCar,
  }) {
    if (currentPhase == CrapsPhase.comeOut) {
      if (wageredCar != null) {
        if (!state.ownedCars.any((c) => c.id == wageredCar.id)) return null;
      } else {
        if (state.balance < betAmount || betAmount <= 0) return null;
      }

      // Deduct bet at the start of Come-Out roll
      double currentBalance = state.balance;
      List<CarModel> updatedCars = List.from(state.ownedCars);

      if (wageredCar != null) {
        updatedCars.removeWhere((c) => c.id == wageredCar.id);
      } else {
        currentBalance -= betAmount;
      }

      state = state.copyWith(
        balance: currentBalance,
        ownedCars: updatedCars,
      );
    }

    final effectiveBet = wageredCar != null ? wageredCar.price : betAmount;
    final result = CasinoEngine.rollStreetCraps(
      currentPhase: currentPhase,
      currentPoint: currentPoint,
      betAmount: betAmount,
      wageredCar: wageredCar,
    );

    if (result.isWin || result.isLoss) {
      double currentBalance = state.balance;
      List<CarModel> updatedCars = List.from(state.ownedCars);

      if (result.isWin) {
        currentBalance += (effectiveBet * result.payoutMultiplier);
        if (wageredCar != null) {
          updatedCars.add(wageredCar);
        }
      }

      final oldStats = state.casinoStats;
      final newStats = oldStats.copyWith(
        totalGamesPlayed: oldStats.totalGamesPlayed + 1,
        totalWonAmount: oldStats.totalWonAmount + (result.isWin ? effectiveBet : 0.0),
        totalLostAmount: oldStats.totalLostAmount + (result.isLoss ? effectiveBet : 0.0),
        biggestMultiplierRecord: math.max(oldStats.biggestMultiplierRecord, result.isWin ? 2.0 : 1.0),
        vehiclesWageredCount: oldStats.vehiclesWageredCount + (wageredCar != null ? 1 : 0),
        vehiclesLostCount: oldStats.vehiclesLostCount + (wageredCar != null && result.isLoss ? 1 : 0),
      );

      state = state.copyWith(
        balance: currentBalance,
        ownedCars: updatedCars,
        casinoStats: newStats,
      );
    }

    return result;
  }

  // ==========================================
  // 3. HI-LO VİTES
  // ==========================================
  bool startHiLoGame(double betAmount) {
    if (state.balance < betAmount || betAmount <= 0) return false;
    state = state.copyWith(balance: state.balance - betAmount);
    return true;
  }

  void cashOutHiLo({
    required double initialBet,
    required double payoutAmount,
    required int streak,
  }) {
    final oldStats = state.casinoStats;
    final profit = payoutAmount - initialBet;
    final multiplier = initialBet > 0 ? (payoutAmount / initialBet) : 1.0;

    final newStats = oldStats.copyWith(
      totalGamesPlayed: oldStats.totalGamesPlayed + 1,
      totalWonAmount: oldStats.totalWonAmount + (profit > 0 ? profit : 0.0),
      biggestMultiplierRecord: math.max(oldStats.biggestMultiplierRecord, multiplier),
    );

    state = state.copyWith(
      balance: state.balance + payoutAmount,
      casinoStats: newStats,
    );
    updateMissionProgress(MissionType.casinoPlay, 1);
  }

  void recordHiLoBust(double initialBet) {
    final oldStats = state.casinoStats;
    final newStats = oldStats.copyWith(
      totalGamesPlayed: oldStats.totalGamesPlayed + 1,
      totalLostAmount: oldStats.totalLostAmount + initialBet,
    );

    state = state.copyWith(casinoStats: newStats);
    updateMissionProgress(MissionType.casinoPlay, 1);
  }

  // ==========================================
  // 4. PISTON PLINKO
  // ==========================================
  PlinkoDropResult? playCasinoPlinko({required double betAmount}) {
    if (state.balance < betAmount || betAmount <= 0) return null;

    final result = CasinoEngine.dropPlinkoBuji(betAmount: betAmount);
    final profit = result.payoutAmount - betAmount;

    final oldStats = state.casinoStats;
    final newStats = oldStats.copyWith(
      totalGamesPlayed: oldStats.totalGamesPlayed + 1,
      totalWonAmount: oldStats.totalWonAmount + (profit > 0 ? profit : 0.0),
      totalLostAmount: oldStats.totalLostAmount + (profit < 0 ? (-profit) : 0.0),
      biggestMultiplierRecord: math.max(oldStats.biggestMultiplierRecord, result.multiplier),
    );

    state = state.copyWith(
      balance: state.balance - betAmount + result.payoutAmount,
      casinoStats: newStats,
    );

    updateMissionProgress(MissionType.casinoPlay, 1);
    return result;
  }

  // ==========================================
  // 5. KAYIP BAGAJ RULETİ (LUCKY WHEEL)
  // ==========================================
  LuckyWheelSpinResult? spinCasinoWheel({
    required double betAmount,
    CarModel? wageredCar,
  }) {
    if (wageredCar != null) {
      if (!state.ownedCars.any((c) => c.id == wageredCar.id)) return null;
    } else {
      if (state.balance < betAmount || betAmount <= 0) return null;
    }

    double currentBalance = state.balance;
    List<CarModel> updatedCars = List.from(state.ownedCars);

    if (wageredCar != null) {
      updatedCars.removeWhere((c) => c.id == wageredCar.id);
    } else {
      currentBalance -= betAmount;
    }

    final result = CasinoEngine.spinLuckyWheel(
      betAmount: betAmount,
      wageredCar: wageredCar,
    );

    final effectiveBet = wageredCar != null ? wageredCar.price : betAmount;

    if (!result.isBankrupt && result.slice.multiplier > 0) {
      currentBalance += result.payoutAmount;
      if (wageredCar != null) {
        updatedCars.add(wageredCar);
      }
    }

    if (result.awardedCar != null) {
      updatedCars.add(result.awardedCar!);
    }

    final profit = result.payoutAmount - effectiveBet;

    final oldStats = state.casinoStats;
    final newStats = oldStats.copyWith(
      totalGamesPlayed: oldStats.totalGamesPlayed + 1,
      totalWonAmount: oldStats.totalWonAmount + (profit > 0 ? profit : 0.0),
      totalLostAmount: oldStats.totalLostAmount + (profit < 0 ? (-profit) : 0.0),
      biggestMultiplierRecord: math.max(oldStats.biggestMultiplierRecord, result.slice.multiplier),
      vehiclesWageredCount: oldStats.vehiclesWageredCount + (wageredCar != null ? 1 : 0),
      vehiclesLostCount: oldStats.vehiclesLostCount + (wageredCar != null && result.isBankrupt ? 1 : 0),
      vehiclesWonCount: oldStats.vehiclesWonCount + (result.awardedCar != null ? 1 : 0),
    );

    state = state.copyWith(
      balance: currentBalance,
      ownedCars: updatedCars,
      casinoStats: newStats,
    );

    updateMissionProgress(MissionType.casinoPlay, 1);
    return result;
  }

  // ==========================================
  // 6. ŞASİ KAZI KAZAN (SCRATCH CARD)
  // ==========================================
  ScratchCardResult? buyAndScratchCard({required double cardCost}) {
    if (state.balance < cardCost || cardCost <= 0) return null;

    final result = CasinoEngine.generateScratchCard(cardCost: cardCost);
    final profit = result.payoutAmount - cardCost;

    final oldStats = state.casinoStats;
    final newStats = oldStats.copyWith(
      totalGamesPlayed: oldStats.totalGamesPlayed + 1,
      totalWonAmount: oldStats.totalWonAmount + (profit > 0 ? profit : 0.0),
      totalLostAmount: oldStats.totalLostAmount + (profit < 0 ? (-profit) : 0.0),
      biggestMultiplierRecord: math.max(oldStats.biggestMultiplierRecord, cardCost > 0 ? (result.payoutAmount / cardCost) : 1.0),
    );

    state = state.copyWith(
      balance: state.balance - cardCost + result.payoutAmount,
      casinoStats: newStats,
    );

    updateMissionProgress(MissionType.casinoPlay, 1);
    return result;
  }

  // ==========================================
  // 7. ÇİFTE KATLA (DOUBLE OR NOTHING)
  // ==========================================
  bool playCasinoDoubleOrNothing({
    required double baseProfit,
    required bool guessHeads,
    CarModel? wageredCar,
  }) {
    final isWin = CasinoEngine.flipDoubleOrNothing(guessHeads: guessHeads);
    final effectiveStake = wageredCar != null ? wageredCar.price : baseProfit;

    double currentBalance = state.balance;
    List<CarModel> updatedCars = List.from(state.ownedCars);

    if (wageredCar != null) {
      if (isWin) {
        currentBalance += (wageredCar.price * 2.0);
      } else {
        updatedCars.removeWhere((c) => c.id == wageredCar.id);
      }
    } else {
      if (isWin) {
        currentBalance += baseProfit; // Adds another 1x (total 2x of profit)
      } else {
        currentBalance -= baseProfit; // Loses the profit
      }
    }

    final oldStats = state.casinoStats;
    final newStats = oldStats.copyWith(
      totalGamesPlayed: oldStats.totalGamesPlayed + 1,
      totalWonAmount: oldStats.totalWonAmount + (isWin ? effectiveStake : 0.0),
      totalLostAmount: oldStats.totalLostAmount + (isWin ? 0.0 : effectiveStake),
      biggestMultiplierRecord: math.max(oldStats.biggestMultiplierRecord, isWin ? 2.0 : 1.0),
      vehiclesWageredCount: oldStats.vehiclesWageredCount + (wageredCar != null ? 1 : 0),
      vehiclesLostCount: oldStats.vehiclesLostCount + (wageredCar != null && !isWin ? 1 : 0),
    );

    state = state.copyWith(
      balance: currentBalance,
      ownedCars: updatedCars,
      casinoStats: newStats,
    );

    updateMissionProgress(MissionType.casinoPlay, 1);
    return isWin;
  }

  // ==========================================
  // 8. AVIATOR (TURBO ROKET)
  // ==========================================
  void playCasinoAviatorDeductWager({
    required double betAmount,
    CarModel? wageredCar,
  }) {
    double currentBalance = state.balance;
    List<CarModel> updatedCars = List.from(state.ownedCars);

    if (wageredCar != null) {
      updatedCars.removeWhere((c) => c.id == wageredCar.id);
    } else {
      currentBalance -= betAmount;
    }

    state = state.copyWith(
      balance: currentBalance,
      ownedCars: updatedCars,
    );
  }

  void playCasinoAviatorCashout({
    required double betAmount,
    required double multiplier,
    CarModel? wageredCar,
    required bool isWin,
  }) {
    final effectiveBet = wageredCar != null ? wageredCar.price : betAmount;
    double currentBalance = state.balance;
    List<CarModel> updatedCars = List.from(state.ownedCars);

    final payout = effectiveBet * multiplier;
    if (isWin) {
      currentBalance += payout;
      if (wageredCar != null) {
        updatedCars.add(wageredCar);
      }
    }

    final oldStats = state.casinoStats;
    final newStats = oldStats.copyWith(
      totalGamesPlayed: oldStats.totalGamesPlayed + 1,
      totalWonAmount: oldStats.totalWonAmount + (isWin ? (payout - effectiveBet) : 0.0),
      totalLostAmount: oldStats.totalLostAmount + (isWin ? 0.0 : effectiveBet),
      biggestMultiplierRecord: math.max(oldStats.biggestMultiplierRecord, isWin ? multiplier : 1.0),
      vehiclesWageredCount: oldStats.vehiclesWageredCount + (wageredCar != null ? 1 : 0),
      vehiclesLostCount: oldStats.vehiclesLostCount + (wageredCar != null && !isWin ? 1 : 0),
    );

    state = state.copyWith(
      balance: currentBalance,
      ownedCars: updatedCars,
      casinoStats: newStats,
    );
    updateMissionProgress(MissionType.casinoPlay, 1);
  }

  void playCasinoAviatorCrash({
    required double betAmount,
    CarModel? wageredCar,
  }) {
    final effectiveBet = wageredCar != null ? wageredCar.price : betAmount;
    final oldStats = state.casinoStats;
    final newStats = oldStats.copyWith(
      totalGamesPlayed: oldStats.totalGamesPlayed + 1,
      totalLostAmount: oldStats.totalLostAmount + effectiveBet,
      vehiclesWageredCount: oldStats.vehiclesWageredCount + (wageredCar != null ? 1 : 0),
      vehiclesLostCount: oldStats.vehiclesLostCount + (wageredCar != null ? 1 : 0),
    );

    state = state.copyWith(
      casinoStats: newStats,
    );
    updateMissionProgress(MissionType.casinoPlay, 1);
  }

  // ==========================================
  // 9. SANAYİ BARBUTU (ZAR VE KUPA DÜELLOSU)
  // ==========================================
  BarbutResult? playCasinoSanayiBarbutu({
    required double betAmount,
    required BarbutBetChoice choice,
    CarModel? wageredCar,
  }) {
    if (wageredCar != null) {
      if (!state.ownedCars.any((c) => c.id == wageredCar.id)) return null;
    } else {
      if (state.balance < betAmount || betAmount <= 0) return null;
    }

    double currentBalance = state.balance;
    List<CarModel> updatedCars = List.from(state.ownedCars);

    if (wageredCar != null) {
      updatedCars.removeWhere((c) => c.id == wageredCar.id);
    } else {
      currentBalance -= betAmount;
    }

    final result = CasinoEngine.playSanayiBarbutu(
      betAmount: betAmount,
      choice: choice,
      wageredCar: wageredCar,
    );

    final effectiveBet = wageredCar != null ? wageredCar.price : betAmount;
    final isWin = result.isWin;
    final payout = result.payoutAmount;

    if (isWin) {
      currentBalance += payout;
      if (wageredCar != null) {
        updatedCars.add(wageredCar);
      }
    }

    final oldStats = state.casinoStats;
    final newStats = oldStats.copyWith(
      totalGamesPlayed: oldStats.totalGamesPlayed + 1,
      totalWonAmount: oldStats.totalWonAmount + (isWin ? (payout - effectiveBet) : 0.0),
      totalLostAmount: oldStats.totalLostAmount + (isWin ? 0.0 : effectiveBet),
      biggestMultiplierRecord: math.max(oldStats.biggestMultiplierRecord, isWin ? result.multiplier : 1.0),
      vehiclesWageredCount: oldStats.vehiclesWageredCount + (wageredCar != null ? 1 : 0),
      vehiclesLostCount: oldStats.vehiclesLostCount + (wageredCar != null && !isWin ? 1 : 0),
    );

    state = state.copyWith(
      balance: currentBalance,
      ownedCars: updatedCars,
      casinoStats: newStats,
    );

    updateMissionProgress(MissionType.casinoPlay, 1);
    return result;
  }
}
