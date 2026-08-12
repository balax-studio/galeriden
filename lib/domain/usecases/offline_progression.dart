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

    // Every 15 offline minutes can spawn up to 1 offer if space permits
    int potentialOffers = (elapsedMinutes / 15).floor().clamp(1, 4);
    var updatedOffers = List<OfferModel>.from(dealership.incomingOffers);
    int newOffersGenerated = 0;

    for (int i = 0; i < potentialOffers; i++) {
      if (dealership.ownedCars.isNotEmpty && updatedOffers.length < 8) {
        final car = dealership.ownedCars[i % dealership.ownedCars.length];
        final offer = NegotiationEngine.generateBuyerOffer(car, car.estimatedRealValue * 1.15);
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
