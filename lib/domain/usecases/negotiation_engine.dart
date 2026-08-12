import 'dart:math';
import '../../data/models/car_model.dart';
import '../../data/models/offer_model.dart';

class NegotiationOutcome {
  final OfferModel updatedOffer;
  final String responseMessage;
  final bool isAccepted;
  final bool isWalkaway;

  NegotiationOutcome({
    required this.updatedOffer,
    required this.responseMessage,
    required this.isAccepted,
    required this.isWalkaway,
  });
}

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
    'Hasan R.',
    'Kemal T.',
  ];

  /// Generates a realistic buyer offer for a car listed in Showroom
  static OfferModel generateBuyerOffer(CarModel car, double listingPrice) {
    final realVal = car.estimatedRealValue;
    double baseOffer = (realVal * (0.90 + (_random.nextDouble() * 0.20))).roundToDouble();

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

  /// Process counter-offer from player to buyer
  static NegotiationOutcome evaluateCounterOffer({
    required OfferModel currentOffer,
    required double playerTargetPrice,
    required CarModel car,
    required int negotiationSkillLevel,
  }) {
    final double previousOffer = currentOffer.offeredAmount;
    final double carRealValue = car.estimatedRealValue;

    // Skill boost: +3% acceptance probability per skill level
    double skillBonus = (negotiationSkillLevel - 1) * 0.03;

    // Difference ratio between player target and buyer's previous offer
    double diffRatio = (playerTargetPrice - previousOffer) / previousOffer;

    // Probability calculations
    if (playerTargetPrice <= previousOffer) {
      // Player asked for lower/same amount -> Immediate Accept!
      return NegotiationOutcome(
        updatedOffer: currentOffer.copyWith(
          offeredAmount: playerTargetPrice,
          status: OfferStatus.accepted,
        ),
        responseMessage: 'Harika! Bu teklifi memnuniyetle kabul ediyorum. Noterde buluşalım.',
        isAccepted: true,
        isWalkaway: false,
      );
    }

    if (diffRatio <= 0.08 + skillBonus) {
      // Very reasonable counter offer -> 85% chance accept
      if (_random.nextDouble() < 0.85 + skillBonus) {
        return NegotiationOutcome(
          updatedOffer: currentOffer.copyWith(
            offeredAmount: playerTargetPrice,
            status: OfferStatus.accepted,
          ),
          responseMessage: 'Anlaştık usta! ₺${playerTargetPrice.round()} benim için uygundur.',
          isAccepted: true,
          isWalkaway: false,
        );
      }
    }

    // Check walkaway threshold (asking way above real value or huge counter)
    if (diffRatio > 0.25 || playerTargetPrice > carRealValue * 1.35) {
      if (_random.nextDouble() > (0.15 + skillBonus)) {
        return NegotiationOutcome(
          updatedOffer: currentOffer.copyWith(status: OfferStatus.rejected),
          responseMessage: 'Yok usta bu fiyat beni çok aşar, ben başka ilanlara bakayım. Kolay gelsin.',
          isAccepted: false,
          isWalkaway: true,
        );
      }
    }

    // Buyer makes a middle counter-offer
    double buyerNewOffer = (previousOffer + (playerTargetPrice - previousOffer) * (0.45 + _random.nextDouble() * 0.20 + skillBonus)).roundToDouble();
    int newCount = currentOffer.counterCount + 1;

    if (newCount >= currentOffer.maxCounters) {
      // Max counters reached -> Buyer gives final offer
      return NegotiationOutcome(
        updatedOffer: currentOffer.copyWith(
          offeredAmount: buyerNewOffer,
          counterCount: newCount,
          status: OfferStatus.countered,
        ),
        responseMessage: 'Usta son sözüm ₺${buyerNewOffer.round()}. Üstüne çıkamam, kabul ediyorsan hayırlı olsun.',
        isAccepted: false,
        isWalkaway: false,
      );
    }

    return NegotiationOutcome(
      updatedOffer: currentOffer.copyWith(
        offeredAmount: buyerNewOffer,
        counterCount: newCount,
        status: OfferStatus.countered,
      ),
      responseMessage: '₺${playerTargetPrice.round()} biraz yüksek ama bütçemi zorlayıp ₺${buyerNewOffer.round()} verebilirim.',
      isAccepted: false,
      isWalkaway: false,
    );
  }
}
