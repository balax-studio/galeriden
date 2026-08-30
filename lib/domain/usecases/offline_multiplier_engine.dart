import 'dart:math' as math;

/// Dynamic Multiplier Engine for Offline Earnings Rewarded Ads
class OfflineMultiplierEngine {
  OfflineMultiplierEngine._();

  /// Multiplier weights:
  /// - 1.5x: 40%
  /// - 2.0x: 35%
  /// - 2.5x: 15%
  /// - 3.0x: 10%
  static const List<(double multiplier, int weight)> multiplierTiers = [
    (1.5, 40),
    (2.0, 35),
    (2.5, 15),
    (3.0, 10),
  ];

  /// Total sum of tier weights (100)
  static int get totalWeight =>
      multiplierTiers.fold(0, (sum, item) => sum + item.$2);

  /// Selects a weighted random multiplier (1.5x, 2.0x, 2.5x, 3.0x)
  static double getRandomMultiplier({math.Random? rng}) {
    final random = rng ?? math.Random();
    int roll = random.nextInt(totalWeight);

    for (final tier in multiplierTiers) {
      if (roll < tier.$2) {
        return tier.$1;
      }
      roll -= tier.$2;
    }

    return 2.0; // Safe default
  }

  /// Calculates the extra bonus amount to be added when watching the rewarded ad
  /// (since 1x base income is already credited during offline simulation loading)
  static double calculateBonusAmount(double earnedIncome, double multiplier) {
    if (earnedIncome <= 0 || multiplier <= 1.0) return 0.0;
    return earnedIncome * (multiplier - 1.0);
  }

  /// Calculates the total multiplied income (earnedIncome * multiplier)
  static double calculateTotalAmount(double earnedIncome, double multiplier) {
    if (earnedIncome <= 0) return 0.0;
    return earnedIncome * multiplier;
  }

  /// Formats multiplier cleanly without unnecessary trailing zeros (e.g. "1.5x", "2x", "2.5x", "3x")
  static String formatMultiplier(double multiplier) {
    if (multiplier % 1 == 0) {
      return '${multiplier.toInt()}x';
    }
    return '${multiplier.toStringAsFixed(1)}x';
  }
}
