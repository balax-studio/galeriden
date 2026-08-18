import 'dart:math';
import '../../data/models/game_event_model.dart';

/// Pure domain usecase for district market share economy, exponential advertising scaling and competitor decay.
class DistrictEconomyEngine {
  /// Calculates dynamic exponential cost for acquiring +5% market share in a district
  static double calculateBoostCost(double currentShare) {
    if (currentShare >= 1.0) return 0.0;
    final step = (currentShare * 20).round().clamp(0, 19);
    final rawCost = 15000.0 * pow(1.20, step);
    if (rawCost >= 100000) {
      return (rawCost / 5000).round() * 5000.0;
    } else if (rawCost >= 20000) {
      return (rawCost / 1000).round() * 1000.0;
    } else {
      return (rawCost / 500).round() * 500.0;
    }
  }

  /// Evaluates daily competitor campaigns and market circulation decay
  static (Map<String, double>, List<GameEventModel>) processDecay(
    Map<String, double> currentShares,
    List<GameEventModel> events, {
    Random? random,
  }) {
    final rng = random ?? Random();
    final updatedShares = Map<String, double>.from(currentShares);
    final updatedEvents = List<GameEventModel>.from(events);

    for (final entry in currentShares.entries) {
      final districtKey = entry.key;
      final currentShare = entry.value;

      // Only decay if share is above 10%
      if (currentShare > 0.10) {
        // 20% chance per day of competitor campaign / circulation loss
        if (rng.nextDouble() < 0.20) {
          // Decay between 2% and 5%
          final lossRate = 0.02 + (rng.nextDouble() * 0.03);
          final newShare = (currentShare - lossRate).clamp(0.05, 1.0);
          final actualLoss = currentShare - newShare;
          if (actualLoss > 0.001) {
            updatedShares[districtKey] = double.parse(newShare.toStringAsFixed(3));
            final lossPercent = (actualLoss * 100).round();
            updatedEvents.insert(
              0,
              GameEventModel(
                id: 'district_decay_${districtKey}_${DateTime.now().millisecondsSinceEpoch}',
                title: '$districtKey • Rakip Esnaf Hamlesi!',
                description: '$districtKey bölgesinde rakip oto galeriler büyük kampanya başlattı! Pazar payın %$lossPercent azaldı.',
                type: GameEventType.badEvent,
                amount: 0.0,
                date: DateTime.now(),
              ),
            );
          }
        }
      }
    }

    return (updatedShares, updatedEvents);
  }
}
