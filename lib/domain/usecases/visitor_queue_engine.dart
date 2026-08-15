import '../../data/models/car_model.dart';

class VisitorQueueEngine {
  /// Base arrival time in seconds (e.g. 180s = 3 minutes)
  static const double baseSeconds = 180.0;

  /// Calculates the deterministic or dynamic seconds until the next customer arrives to inspect the vehicle
  static int calculateNextVisitorSeconds({
    required CarModel car,
    required int reputation,
    required bool hasSalesman,
    double marketSenseBonus = 0.0,
  }) {
    double factor = 1.0;

    // 1. Price vs Real Value ratio penalty or bonus
    final askingPrice = car.listingPrice;
    final realValue = car.estimatedRealValue;
    if (realValue > 0) {
      final priceRatio = askingPrice / realValue;
      if (priceRatio > 1.25) {
        factor *= (1.0 + (priceRatio - 1.25) * 1.5); // Slower if overpriced
      } else if (priceRatio < 0.90) {
        factor *= (0.70 + (priceRatio * 0.30)); // Faster if bargain
      }
    }

    // 2. Dealership Reputation factor (reputation 100 is baseline, 200 is 50% faster)
    final repFactor = (1.0 - ((reputation.clamp(50, 200) - 100) / 200.0)).clamp(0.50, 1.30);
    factor *= repFactor;

    // 3. Marketing / Doping bonus (3x speed up)
    if (car.isDoped) {
      factor *= 0.35;
    }

    // 4. Salesman / Staff presence bonus
    if (hasSalesman) {
      factor *= 0.70;
    }

    // 5. Market Sense Skill bonus
    if (marketSenseBonus > 0) {
      factor *= (1.0 - marketSenseBonus.clamp(0.0, 0.40));
    }

    final totalSeconds = (baseSeconds * factor).round().clamp(20, 600);
    return totalSeconds;
  }
}
