import '../../data/models/dealership_model.dart';
import '../../data/models/offer_model.dart';
import 'negotiation_engine.dart';

class OfflineProgression {
  /// Calculates offline time and generates simulated buyer activity
  static Map<String, dynamic> processOfflineTime(DealershipModel dealership) {
    final now = DateTime.now();
    final elapsedMinutes = now.difference(dealership.lastActiveTime).inMinutes;

    if (elapsedMinutes < 2 || dealership.ownedCars.isEmpty) {
      return {
        'elapsedMinutes': elapsedMinutes,
        'newOffersCount': 0,
        'simulatedEarnings': 0.0,
        'updatedDealership': dealership.copyWith(lastActiveTime: now),
      };
    }

    // Reputation level increases offer rate and limit
    int repLevel = dealership.skills.reputation;
    int maxOffersLimit = 8 + repLevel;
    int minutesPerOffer = (15 - (repLevel * 0.8).round()).clamp(5, 15);

    int potentialOffers = (elapsedMinutes / minutesPerOffer).floor().clamp(1, 5);
    var updatedOffers = List<OfferModel>.from(dealership.incomingOffers);
    int newOffersGenerated = 0;

    for (int i = 0; i < potentialOffers; i++) {
      if (dealership.ownedCars.isNotEmpty && updatedOffers.length < maxOffersLimit) {
        final car = dealership.ownedCars[i % dealership.ownedCars.length];
        double repOfferBonus = 1.0 + (repLevel * 0.02);
        final offer = NegotiationEngine.generateBuyerOffer(car, car.estimatedRealValue * 1.15 * repOfferBonus);
        updatedOffers.add(offer);
        newOffersGenerated++;
      }
    }

    final updatedDealership = dealership.copyWith(
      incomingOffers: updatedOffers,
      lastActiveTime: now,
    );

    return {
      'elapsedMinutes': elapsedMinutes,
      'newOffersCount': newOffersGenerated,
      'simulatedEarnings': 0.0,
      'updatedDealership': updatedDealership,
    };
  }
}
