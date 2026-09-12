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

    // 2. Dynamic level & wealth percentage scaling:
    // Strictly calibrated so early & mid-game progression remains engaging and safe,
    // while late-game tycoons (> level 20 with 66M+ TL) receive motivating million-scale payouts.
    final double baseLevelAmount;
    final double wealthRate;
    final double maxBaseCap;
    final double maxJackpotCap;

    if (playerLevel <= 3) {
      baseLevelAmount = 5000.0 + (playerLevel * 2000.0);
      wealthRate = 0.015;
      maxBaseCap = min(25000.0, max(10000.0, totalWealth * 0.03));
      maxJackpotCap = min(100000.0, maxBaseCap * 4.0);
    } else if (playerLevel <= 6) {
      baseLevelAmount = 5000.0 + (playerLevel * 2000.0);
      wealthRate = 0.010;
      maxBaseCap = min(35000.0, max(20000.0, totalWealth * 0.012));
      maxJackpotCap = min(140000.0, maxBaseCap * 4.0);
    } else if (playerLevel < 20) {
      // Mid-to-high tier (e.g. Level 15)
      // Guarantees >= 150k TL for level 15 fleets while strictly capping at 350k TL for 100M wealth
      baseLevelAmount = 5000.0 + (playerLevel * 8000.0);
      wealthRate = 0.0075;
      maxBaseCap = min(175000.0, max(150000.0, totalWealth * 0.008));
      maxJackpotCap = min(350000.0, maxBaseCap * 2.0);
    } else {
      // Late-game tycoon tier (Level >= 20 with 66M+ TL balance)
      baseLevelAmount = 5000.0 + (playerLevel * 10000.0);
      wealthRate = 0.0275;
      maxBaseCap = max(1800000.0, totalWealth * 0.05);
      maxJackpotCap = maxBaseCap * 4.0;
    }

    double wealthRatioAmount = totalWealth * wealthRate;
    double baseAmount = baseLevelAmount + wealthRatioAmount;

    if (targetCarPrice != null && targetCarPrice > 0) {
      if (playerLevel < 20) {
        baseAmount = max(baseAmount, min(40000.0, targetCarPrice * 0.02));
      } else {
        baseAmount = max(baseAmount, targetCarPrice * 0.04);
      }
    }

    baseAmount = baseAmount.clamp(5000.0, maxBaseCap);

    // Round nicely to clean game numbers
    baseAmount = _roundToCleanNumber(baseAmount);

    // 4. Roll variable ratio outcome
    final roll = rng.nextInt(100) + 1; // 1 to 100

    if (roll >= 98) {
      // 3% Legendary Jackpot
      final total = _roundToCleanNumber((baseAmount * 4.0).clamp(0.0, maxJackpotCap));
      return AdRewardOutcome(
        moneyAmount: total,
        tier: AdRewardTier.legendaryJackpot,
        multiplier: 4.0,
        badgeText: 'EFSANEVİ BÜYÜK İKRAMİYE • 4X',
        title: 'SANAYİ EFSANESİ BÜYÜK İKRAMİYE KAZANDIN',
        message: 'Tüm sanayi esnafı senin için toplandı! Şampiyon galericilere özel dev nakit desteği kasana aktarıldı.',
        bonusItemDescription: 'Sanayi Ustalarından Altın Mühürlü Onur Plaketi',
      );
    } else if (roll >= 81) {
      // 17% Double Luck
      final total = _roundToCleanNumber((baseAmount * 2.0).clamp(0.0, maxJackpotCap));
      return AdRewardOutcome(
        moneyAmount: total,
        tier: AdRewardTier.doubleLuck,
        multiplier: 2.0,
        badgeText: 'ÇİFTE KAZANÇ • 2X',
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
    if (playerLevel <= 6) {
      return _roundToCleanNumber(min(180000.0, max(25000.0, base * 1.15 * tierMultiplier)));
    } else if (playerLevel < 20) {
      return _roundToCleanNumber(min(350000.0, max(40000.0, base * 1.15 * tierMultiplier)));
    } else {
      return _roundToCleanNumber(max(500000.0, base * 1.20 * tierMultiplier));
    }
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
    if (playerLevel <= 6) {
      return _roundToCleanNumber(min(160000.0, max(20000.0, base * 1.10 * fleetBonus)));
    } else if (playerLevel < 20) {
      return _roundToCleanNumber(min(300000.0, max(35000.0, base * 1.10 * fleetBonus)));
    } else {
      return _roundToCleanNumber(max(400000.0, base * 1.10 * fleetBonus));
    }
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
    if (playerLevel <= 6) {
      return _roundToCleanNumber(min(140000.0, max(15000.0, base * 0.90)));
    } else if (playerLevel < 20) {
      return _roundToCleanNumber(min(250000.0, max(25000.0, base * 0.90)));
    } else {
      return _roundToCleanNumber(max(250000.0, base * 0.90));
    }
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
    if (playerLevel <= 6) {
      final effectiveLossRelief = recentLoss != null ? max(base, recentLoss * 0.80) : base;
      return _roundToCleanNumber(min(220000.0, max(35000.0, effectiveLossRelief)));
    } else if (playerLevel < 20) {
      final effectiveLossRelief = recentLoss != null ? max(base, recentLoss * 0.80) : base;
      return _roundToCleanNumber(min(450000.0, max(40000.0, effectiveLossRelief)));
    } else {
      final effectiveLossRelief = recentLoss != null ? max(base, recentLoss * 0.80) : base;
      return _roundToCleanNumber(max(1000000.0, effectiveLossRelief));
    }
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
