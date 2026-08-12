import 'dart:math';
import '../../data/models/car_model.dart';
import '../../data/models/offer_model.dart';

class NegotiationEngine {
  static final Random _random = Random();

  static const List<String> buyerMessages = [
    'Usta araç fotoğraflarda güzel duruyor, fiyatta bir şeyler yaparsan hemen geleyim.',
    'Selamın aleykum, pazarlık payı var mıdır? Nakit alıcıyım.',
    'Aracınız tam aradığım kriterlerde. Ekspertize sokup anlaşalım.',
    'Usta son ne olur? Bütçem kısıtlı ama ciddi alıcıyım.',
    'Aracı canlı görmek isterim, teklifimi kabul ederseniz bugün noter yaparız.',
  ];

  static const List<String> buyerNames = [
    'Volkan Y.',
    'Serkan B.',
    'Oğuzhan D.',
    'Tolga K.',
    'Batuhan T.',
    'Murat E.',
  ];

  /// Generates a realistic buyer offer for a car listed in Showroom
  static OfferModel generateBuyerOffer(CarModel car, double listingPrice) {
    final realVal = car.estimatedRealValue;
    double baseOffer = (realVal * (0.90 + (_random.nextDouble() * 0.20))).roundToDouble();

    // Cap offer relative to listing price
    if (baseOffer > listingPrice * 1.1) {
      baseOffer = listingPrice * 0.98;
    }

    final buyerName = buyerNames[_random.nextInt(buyerNames.length)];
    final message = buyerMessages[_random.nextInt(buyerMessages.length)];

    return OfferModel(
      id: 'offer_${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(999)}',
      carId: car.id,
      buyerName: buyerName,
      offeredAmount: baseOffer,
      buyerMessage: message,
      status: OfferStatus.pending,
      createdAt: DateTime.now(),
    );
  }
}
