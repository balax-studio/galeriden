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
class AdRewardCalculator {
  AdRewardCalculator._();

  static AdRewardOutcome calculateDynamicReward({
    required int playerLevel,
    required double totalGarageValue,
    double? targetCarPrice,
    int dayStreak = 1,
  }) {
    final random = Random();

    // 1. Dynamic base scaling based on player level and garage net worth
    double baseAmount = 15000.0 + (playerLevel * 5000.0) + (totalGarageValue * 0.025);

    if (targetCarPrice != null && targetCarPrice > 0) {
      // If tied to a specific car context (e.g. black market / negotiation), factor 5% of car value
      baseAmount = max(baseAmount, targetCarPrice * 0.05);
    }

    // Hard clamps: minimum 15.000 TL, maximum 500.000 TL to protect game economy balance
    baseAmount = baseAmount.clamp(15000.0, 500000.0);

    // 2. Roll variable ratio outcome
    final roll = random.nextInt(100) + 1; // 1 to 100

    if (roll >= 98) {
      // 3% Legendary Jackpot
      final total = baseAmount * 4.0;
      return AdRewardOutcome(
        moneyAmount: total,
        tier: AdRewardTier.legendaryJackpot,
        multiplier: 4.0,
        badgeText: 'EFSANEVİ BÜYÜK İKRAMİYE • 4X',
        title: 'SANAYİ EFSANESİ BÜYÜK İKRAMİYE KAZANDIN',
        message: 'Tüm sanayi esnafı senin için toplandı! Şampiyon galericilere özel 4 katı dev nakit desteği kasana aktarıldı.',
        bonusItemDescription: 'Sanayi Ustalarından Altın Mühürlü Onur Plaketi',
      );
    } else if (roll >= 81) {
      // 17% Double Luck
      final total = baseAmount * 2.0;
      return AdRewardOutcome(
        moneyAmount: total,
        tier: AdRewardTier.doubleLuck,
        multiplier: 2.0,
        badgeText: 'ÇİFTE KAZANÇ • 2X',
        title: 'ŞANSLI GÜNÜNDESİN • ÇİFTE KAZANÇ',
        message: 'Esnaf dayanışması bu kez ikiye katlandı! Bereketli kazanç hesabına yansıtıldı.',
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
}
