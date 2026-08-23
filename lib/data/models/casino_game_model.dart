import 'package:flutter/foundation.dart';
import 'car_model.dart';

/// Supported Casino & Underworld Club Mini-Games
enum CasinoGameType {
  baccarat,
  streetCraps,
  hiLo,
  plinko,
  wheelRoulette,
  scratchCard,
  doubleOrNothing,
  aviator,
  sanayiBarbutu,
}

/// Wager method: Standard cash or Pink Slip (Araba Bahsi / Ruhsat)
enum CasinoWagerType {
  cash,
  pinkSlip,
}

/// Valet Baccarat Bet Choices
enum BaccaratBetChoice {
  player, // 2.0x payout (1:1)
  banker, // 1.95x payout (0.95:1)
  tie, // 8.0x payout (8:1)
}

/// Playing Card representation for Baccarat & Hi-Lo
@immutable
class CasinoCard {
  final String suit; // 'spades', 'hearts', 'diamonds', 'clubs'
  final int rank; // 1 (A) to 13 (K)
  final String label; // 'A', '2'-'10', 'J', 'Q', 'K'
  final int baccaratValue; // A=1, 2-9=face value, 10/J/Q/K=0

  const CasinoCard({
    required this.suit,
    required this.rank,
    required this.label,
    required this.baccaratValue,
  });

  factory CasinoCard.fromRankAndSuit(int rank, String suit) {
    String lbl;
    int bVal;
    switch (rank) {
      case 1:
        lbl = 'A';
        bVal = 1;
        break;
      case 11:
        lbl = 'J';
        bVal = 0;
        break;
      case 12:
        lbl = 'Q';
        bVal = 0;
        break;
      case 13:
        lbl = 'K';
        bVal = 0;
        break;
      default:
        lbl = '$rank';
        bVal = rank >= 10 ? 0 : rank;
    }
    return CasinoCard(
      suit: suit,
      rank: rank,
      label: lbl,
      baccaratValue: bVal,
    );
  }

  Map<String, dynamic> toJson() => {
        'suit': suit,
        'rank': rank,
        'label': label,
        'baccaratValue': baccaratValue,
      };

  factory CasinoCard.fromJson(Map<String, dynamic> json) => CasinoCard(
        suit: json['suit'] as String? ?? 'spades',
        rank: json['rank'] as int? ?? 1,
        label: json['label'] as String? ?? 'A',
        baccaratValue: json['baccaratValue'] as int? ?? 1,
      );
}

/// Result of a Valet Baccarat Round
class BaccaratResult {
  final List<CasinoCard> playerCards;
  final List<CasinoCard> bankerCards;
  final int playerTotal;
  final int bankerTotal;
  final BaccaratBetChoice winningChoice;
  final bool isWin;
  final double payoutAmount;
  final CarModel? wonCar; // Optional high-tier car if pink slip won

  const BaccaratResult({
    required this.playerCards,
    required this.bankerCards,
    required this.playerTotal,
    required this.bankerTotal,
    required this.winningChoice,
    required this.isWin,
    required this.payoutAmount,
    this.wonCar,
  });
}

/// Street Craps Phase & State
enum CrapsPhase {
  comeOut,
  pointPhase,
}

class StreetCrapsRollResult {
  final int die1;
  final int die2;
  final int sum;
  final CrapsPhase nextPhase;
  final int? point;
  final bool isWin;
  final bool isLoss;
  final double payoutMultiplier; // 2.0x for standard win
  final String statusSummaryKey;

  const StreetCrapsRollResult({
    required this.die1,
    required this.die2,
    required this.sum,
    required this.nextPhase,
    this.point,
    required this.isWin,
    required this.isLoss,
    required this.payoutMultiplier,
    required this.statusSummaryKey,
  });
}

/// Hi-Lo Step Guess Result
class HiLoStepResult {
  final CasinoCard currentCard;
  final CasinoCard nextCard;
  final bool isCorrect;
  final int currentStreak;
  final double currentMultiplier; // 1.5x, 2.25x, 3.5x, 5.5x, 9x, 15x, 30x...
  final bool isBust;

  const HiLoStepResult({
    required this.currentCard,
    required this.nextCard,
    required this.isCorrect,
    required this.currentStreak,
    required this.currentMultiplier,
    required this.isBust,
  });
}

/// Plinko Slot Result
class PlinkoDropResult {
  final List<int> pathOffsets; // -1 for left, +1 for right on each peg row
  final int slotIndex;
  final double multiplier; // e.g. 0.2x, 0.5x, 1.5x, 5x, 50x, 1000x
  final double payoutAmount;

  const PlinkoDropResult({
    required this.pathOffsets,
    required this.slotIndex,
    required this.multiplier,
    required this.payoutAmount,
  });
}

/// Lucky Wheel Slice
enum WheelSliceType {
  cashMultiplier,
  mysteryParts,
  legendaryCarKey,
  bankrupt,
}

class LuckyWheelSlice {
  final String id;
  final WheelSliceType type;
  final double multiplier;
  final String labelKey;
  final int colorHex;

  const LuckyWheelSlice({
    required this.id,
    required this.type,
    required this.multiplier,
    required this.labelKey,
    required this.colorHex,
  });
}

class LuckyWheelSpinResult {
  final int sliceIndex;
  final LuckyWheelSlice slice;
  final double payoutAmount;
  final CarModel? awardedCar;
  final bool isBankrupt;

  const LuckyWheelSpinResult({
    required this.sliceIndex,
    required this.slice,
    required this.payoutAmount,
    this.awardedCar,
    required this.isBankrupt,
  });
}

/// Scratch Card Spot
class ScratchSpot {
  final String symbol; // 'turbo', 'engine', 'piston', 'key', 'nos', 'crown'
  final double prizeValue;
  final bool isRevealed;

  const ScratchSpot({
    required this.symbol,
    required this.prizeValue,
    this.isRevealed = false,
  });

  ScratchSpot copyWith({bool? isRevealed}) => ScratchSpot(
        symbol: symbol,
        prizeValue: prizeValue,
        isRevealed: isRevealed ?? this.isRevealed,
      );
}

class ScratchCardResult {
  final List<ScratchSpot> grid; // 9 spots (3x3)
  final String? matchingSymbol;
  final bool isWin;
  final double payoutAmount;

  const ScratchCardResult({
    required this.grid,
    this.matchingSymbol,
    required this.isWin,
    required this.payoutAmount,
  });
}

/// Aviator Crash Round Result
class AviatorFlightResult {
  final double crashMultiplier;
  final double cashedOutMultiplier;
  final bool isCashedOut;
  final double payoutAmount;

  const AviatorFlightResult({
    required this.crashMultiplier,
    required this.cashedOutMultiplier,
    required this.isCashedOut,
    required this.payoutAmount,
  });

  bool get isWin => isCashedOut && payoutAmount > 0;
}

/// Sanayi Barbutu Bet Modes
enum BarbutBetChoice {
  duses, // 6-6 (5.0x)
  ciftler, // Any double: 1-1, 2-2, 3-3, 4-4, 5-5, 6-6 (2.5x)
  barbut, // Classic 3-3, 5-5, 6-6 win vs 1-1, 2-2, 4-4 loss (2.0x)
  highRoll, // Dice sum 8-12 (2.0x)
}

/// Sanayi Barbutu Dice Result
class BarbutResult {
  final int die1;
  final int die2;
  final int sum;
  final bool isDuses; // 6-6
  final bool isDubes; // 5-5
  final bool isDortCihar; // 4-4
  final bool isDuse; // 3-3
  final bool isDubara; // 2-2
  final bool isHepyek; // 1-1
  final bool isWin;
  final double multiplier;
  final double payoutAmount;
  final String comboName;

  const BarbutResult({
    required this.die1,
    required this.die2,
    required this.sum,
    required this.isDuses,
    required this.isDubes,
    required this.isDortCihar,
    required this.isDuse,
    required this.isDubara,
    required this.isHepyek,
    required this.isWin,
    required this.multiplier,
    required this.payoutAmount,
    required this.comboName,
  });
}

/// Overall Statistics for Player's Underworld Activity
class CasinoStatsModel {
  final int totalGamesPlayed;
  final double totalWonAmount;
  final double totalLostAmount;
  final double biggestMultiplierRecord;
  final int vehiclesWageredCount;
  final int vehiclesLostCount;
  final int vehiclesWonCount;

  const CasinoStatsModel({
    this.totalGamesPlayed = 0,
    this.totalWonAmount = 0.0,
    this.totalLostAmount = 0.0,
    this.biggestMultiplierRecord = 1.0,
    this.vehiclesWageredCount = 0,
    this.vehiclesLostCount = 0,
    this.vehiclesWonCount = 0,
  });

  CasinoStatsModel copyWith({
    int? totalGamesPlayed,
    double? totalWonAmount,
    double? totalLostAmount,
    double? biggestMultiplierRecord,
    int? vehiclesWageredCount,
    int? vehiclesLostCount,
    int? vehiclesWonCount,
  }) {
    return CasinoStatsModel(
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalWonAmount: totalWonAmount ?? this.totalWonAmount,
      totalLostAmount: totalLostAmount ?? this.totalLostAmount,
      biggestMultiplierRecord: biggestMultiplierRecord ?? this.biggestMultiplierRecord,
      vehiclesWageredCount: vehiclesWageredCount ?? this.vehiclesWageredCount,
      vehiclesLostCount: vehiclesLostCount ?? this.vehiclesLostCount,
      vehiclesWonCount: vehiclesWonCount ?? this.vehiclesWonCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalGamesPlayed': totalGamesPlayed,
        'totalWonAmount': totalWonAmount,
        'totalLostAmount': totalLostAmount,
        'biggestMultiplierRecord': biggestMultiplierRecord,
        'vehiclesWageredCount': vehiclesWageredCount,
        'vehiclesLostCount': vehiclesLostCount,
        'vehiclesWonCount': vehiclesWonCount,
      };

  factory CasinoStatsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CasinoStatsModel();
    return CasinoStatsModel(
      totalGamesPlayed: json['totalGamesPlayed'] as int? ?? 0,
      totalWonAmount: (json['totalWonAmount'] as num?)?.toDouble() ?? 0.0,
      totalLostAmount: (json['totalLostAmount'] as num?)?.toDouble() ?? 0.0,
      biggestMultiplierRecord: (json['biggestMultiplierRecord'] as num?)?.toDouble() ?? 1.0,
      vehiclesWageredCount: json['vehiclesWageredCount'] as int? ?? 0,
      vehiclesLostCount: json['vehiclesLostCount'] as int? ?? 0,
      vehiclesWonCount: json['vehiclesWonCount'] as int? ?? 0,
    );
  }
}
