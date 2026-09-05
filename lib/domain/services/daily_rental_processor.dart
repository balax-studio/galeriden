import 'dart:math';
import '../../data/models/car_model.dart';
import '../../data/models/game_event_model.dart';
import '../../data/models/offer_model.dart';
import '../../data/models/rental_agreement_model.dart';
import '../usecases/rental_progression_engine.dart';

/// Pure domain processor for daily fleet rental progressions, returns, and damages.
class DailyRentalProcessor {
  const DailyRentalProcessor._();

  static (
    double newBalance,
    List<CarModel> updatedCars,
    List<RentalAgreement> updatedRentals,
    List<GameEventModel> updatedEvents,
    List<OfferModel> updatedOffers
  ) processRentals({
    required double balance,
    required List<CarModel> cars,
    required List<RentalAgreement> rentals,
    required List<GameEventModel> events,
    required List<OfferModel> incomingOffers,
    required Random random,
  }) {
    return RentalProgressionEngine.processDailyRentals(
      balance: balance,
      cars: cars,
      rentals: rentals,
      events: events,
      incomingOffers: incomingOffers,
      random: random,
    );
  }
}
