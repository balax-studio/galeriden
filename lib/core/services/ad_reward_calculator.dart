import 'dart:math';

enum AdRewardTier {
  standard,
  doubleLuck,
  legendaryJackpot,
}

class AdRewardOutcome {
  final double moneyAmount;
  final AdRewardTier tier;
  final double multiplier;
  final String badgeText;
  final String title;
  final String message;
  final String? bonusItemDescription;

  const AdRewardOutcome({
    required this.moneyAmount,
    required this.tier,
    required this.multiplier,
    required this.badgeText,
    required this.title,
    required this.message,
    this.bonusItemDescription,
  });
}

/// Dynamic reward calculator that scales payouts with player progress and rolls
/// dopamine-stimulating variable ratio jackpot outcomes (80% Standard, 17% Double, 3% Legendary).
///
/// Ensures late-game tycoons (e.g. 66M+ TL) receive motivating million-scale payouts
/// while early-game newcomers receive helpful, progression-safe capital.
class AdRewardCalculator {
  AdRewardCalculator._();

  static AdRewardOutcome calculateDynamicReward({
    required int playerLevel,
    required double totalGarageValue,
    double? playerBalance,
    double? targetCarPrice,
    int dayStreak = 1,
    Random? random,
  }) {
    final rng = random ?? Random();

    // 1. Total economic wealth evaluation (liquid balance + fleet value)
    final effectiveBalance = max(0.0, playerBalance ?? 0.0);
    final effectiveGarage = max(0.0, totalGarageValue);
    final totalWealth = effectiveBalance + effectiveGarage;

    // 2. Base scaling based on player level
    final double baseLevelAmount = 5000.0 + (playerLevel * 1500.0);

    // 3. Economy-safe dynamic wealth percentage scaling:
    // Strictly calibrated so an ad NEVER ruins the economy or progression.
    // - Low wealth (<= 500k TL): 1.5% (gives up to 7.5k TL)
    // - Mid wealth (<= 5M TL): 1.0% (for 3M TL -> gives 30k TL base; with level ~40-45k TL total)
    // - Upper-mid wealth (<= 25M TL): 0.5% (for 10M -> 50k TL, for 25M -> 125k TL)
    // - Tycoon wealth (> 25M TL): 0.25% (for 50M -> 125k TL)
    double wealthRatioAmount = 0.0;
    if (totalWealth > 0) {
      final double wealthRate;
      if (totalWealth <= 500000.0) {
        wealthRate = 0.015;
      } else if (totalWealth <= 5000000.0) {
        wealthRate = 0.010;
      } else if (totalWealth <= 25000000.0) {
        wealthRate = 0.005;
      } else {
        wealthRate = 0.0025;
      }
      wealthRatioAmount = totalWealth * wealthRate;
    }

    double baseAmount = baseLevelAmount + wealthRatioAmount;

    if (targetCarPrice != null && targetCarPrice > 0) {
      baseAmount = max(baseAmount, min(40000.0, targetCarPrice * 0.02));
    }

    // Dynamic level & wealth gated clamps protecting tycoon economy
    // Strict upper bounds ensure an ad NEVER ruins the joy of flipping cars or earning wealth.
    // A player with 3M wealth will receive ~40.000 - 50.000 TL standard, max ~120.000 TL on jackpot.
    // Even an endgame multibillionaire will never receive millions from an ad (max cap 350.000 TL).
    final double maxBaseCap;
    final double maxJackpotCap;
    if (playerLevel <= 3) {
      maxBaseCap = min(25000.0, max(10000.0, totalWealth * 0.03));
      maxJackpotCap = min(50000.0, maxBaseCap * 2.0);
    } else if (playerLevel <= 6) {
      maxBaseCap = min(55000.0, max(20000.0, totalWealth * 0.018));
      maxJackpotCap = min(140000.0, maxBaseCap * 2.5);
    } else {
      maxBaseCap = min(120000.0, max(30000.0, totalWealth * 0.008));
      maxJackpotCap = min(350000.0, maxBaseCap * 2.5);
    }

    baseAmount = baseAmount.clamp(5000.0, maxBaseCap);

    // Round nicely to clean game numbers
    baseAmount = _roundToCleanNumber(baseAmount);

    // 4. Roll variable ratio outcome
    final roll = rng.nextInt(100) + 1; // 1 to 100

    if (roll >= 98) {
      // 3% Legendary Jackpot
      final total = _roundToCleanNumber((baseAmount * 2.5).clamp(0.0, maxJackpotCap));
      return AdRewardOutcome(
        moneyAmount: total,
        tier: AdRewardTier.legendaryJackpot,
        multiplier: 2.5,
        badgeText: 'EFSANEVİ BÜYÜK İKRAMİYE • 2.5X',
        title: 'SANAYİ EFSANESİ BÜYÜK İKRAMİYE KAZANDIN',
        message: 'Tüm sanayi esnafı senin için toplandı! Şampiyon galericilere özel dev nakit desteği kasana aktarıldı.',
        bonusItemDescription: 'Sanayi Ustalarından Altın Mühürlü Onur Plaketi',
      );
    } else if (roll >= 81) {
      // 17% Double Luck
      final total = _roundToCleanNumber((baseAmount * 1.8).clamp(0.0, maxJackpotCap));
      return AdRewardOutcome(
        moneyAmount: total,
        tier: AdRewardTier.doubleLuck,
        multiplier: 1.8,
        badgeText: 'ÇİFTE KAZANÇ • 1.8X',
        title: 'ŞANSLI GÜNÜNDESİN • ÇİFTE KAZANÇ',
        message: 'Esnaf dayanışması bu kez bereketle katlandı! Destek hesabına yansıtıldı.',
      );
    } else {
      // 80% Standard Reward
      return AdRewardOutcome(
        moneyAmount: baseAmount,
        tier: AdRewardTier.standard,
        multiplier: 1.0,
        badgeText: 'ESNAF DESTEĞİ • 1X',
        title: 'STANDART ESNAF DESTEĞİ TANIMLANDI',
        message: 'Galericiler birliği destek fonundan hesabına nakit akışı sağlandı.',
      );
    }
  }

  /// Calculates dynamic municipal & KOSGEB expansion grant for branch screen
  static double calculateBranchGrant({
    required int playerLevel,
    required double playerBalance,
    double totalGarageValue = 0.0,
    int branchTier = 1,
  }) {
    final base = calculateDynamicReward(
      playerLevel: playerLevel,
      totalGarageValue: totalGarageValue,
      playerBalance: playerBalance,
    ).moneyAmount;
    final tierMultiplier = 1.0 + (branchTier * 0.10);
    return _roundToCleanNumber(min(180000.0, max(25000.0, base * 1.15 * tierMultiplier)));
  }

  /// Calculates dynamic VIP corporate fleet contract grant for rent-a-car screen
  static double calculateVipFleetGrant({
    required int playerLevel,
    required double playerBalance,
    double totalGarageValue = 0.0,
    int fleetCount = 0,
  }) {
    final base = calculateDynamicReward(
      playerLevel: playerLevel,
      totalGarageValue: totalGarageValue,
      playerBalance: playerBalance,
    ).moneyAmount;
    final fleetBonus = 1.0 + (fleetCount * 0.03);
    return _roundToCleanNumber(min(160000.0, max(20000.0, base * 1.10 * fleetBonus)));
  }

  /// Calculates dynamic stock insider market report cash grant for stock market screen
  static double calculateStockInsiderGrant({
    required int playerLevel,
    required double playerBalance,
    double totalGarageValue = 0.0,
  }) {
    final base = calculateDynamicReward(
      playerLevel: playerLevel,
      totalGarageValue: totalGarageValue,
      playerBalance: playerBalance,
    ).moneyAmount;
    return _roundToCleanNumber(min(140000.0, max(15000.0, base * 0.90)));
  }

  /// Calculates dynamic emergency cash grant for lifeline dialogs
  static double calculateEmergencyGrant({
    required int playerLevel,
    required double playerBalance,
    double totalGarageValue = 0.0,
    double? recentLoss,
  }) {
    final base = calculateDynamicReward(
      playerLevel: playerLevel,
      totalGarageValue: totalGarageValue,
      playerBalance: playerBalance,
    ).moneyAmount;
    if (recentLoss != null && recentLoss > base) {
      return _roundToCleanNumber(min(220000.0, max(base, recentLoss * 0.50)));
    }
    return _roundToCleanNumber(min(140000.0, max(20000.0, base)));
  }

  /// Rounds reward to clean presentable game figures (e.g. 25.000, 1.850.000)
  static double _roundToCleanNumber(double val) {
    if (val >= 1000000.0) {
      return (val / 50000.0).round() * 50000.0;
    } else if (val >= 100000.0) {
      return (val / 5000.0).round() * 5000.0;
    } else if (val >= 10000.0) {
      return (val / 1000.0).round() * 1000.0;
    } else {
      return (val / 500.0).round() * 500.0;
    }
  }
}
