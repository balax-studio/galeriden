import 'dart:math';
import '../../data/models/car_model.dart';
import '../../data/models/expertise_model.dart';
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

class ExpertiseDiscrepancyInfo {
  final bool hasDiscrepancy;
  final String title;
  final String description;
  final double extraDiscountPercent;

  ExpertiseDiscrepancyInfo({
    required this.hasDiscrepancy,
    required this.title,
    required this.description,
    required this.extraDiscountPercent,
  });
}

class NegotiationEngine {
  static final Random _random = Random();

  /// Detects discrepancy between seller claim and full expertise report
  static ExpertiseDiscrepancyInfo detectExpertiseDiscrepancy(CarModel car) {
    final exp = car.expertise;

    if (exp.isMileageTampered) {
      return ExpertiseDiscrepancyInfo(
        hasDiscrepancy: true,
        title: 'SAHTE SAYAÇ / KM DÜŞÜRÜLMÜŞ',
        description: 'Ekspertiz beyin taramasında aracın kilometresinin düşürüldüğü kanıtlandı! (-%25 Ekstra İndirim Kozu)',
        extraDiscountPercent: 0.25,
      );
    }

    final changedOrDamaged = exp.bodyParts.entries.where(
      (e) => e.value == PartStatus.changed || e.value == PartStatus.damaged,
    ).toList();

    if (changedOrDamaged.isNotEmpty) {
      final partName = changedOrDamaged.first.key;
      return ExpertiseDiscrepancyInfo(
        hasDiscrepancy: true,
        title: 'GİZLİ DEĞİŞEN / HASARLI PARÇA',
        description: 'İlanda söylenmeyen $partName parçasında ağır hasar/değişen tespit edildi! (-%18 Ekstra İndirim Kozu)',
        extraDiscountPercent: 0.18,
      );
    }

    if (exp.tramerAmount > 45000) {
      return ExpertiseDiscrepancyInfo(
        hasDiscrepancy: true,
        title: 'GİZLENMİŞ TRAMER KAYDI',
        description: 'Ekspertiz raporunda ₺${exp.tramerAmount} yüksek tramer kaydı çıktı! (-%15 Ekstra İndirim Kozu)',
        extraDiscountPercent: 0.15,
      );
    }

    return ExpertiseDiscrepancyInfo(
      hasDiscrepancy: false,
      title: 'Çelişki Yok',
      description: 'Ekspertiz raporu ile satıcı beyanı birebir örtüşüyor.',
      extraDiscountPercent: 0.0,
    );
  }

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

  static const List<String> lowballMessages = [
    'Usta öldürmüş gibi olmasın ama nakit bu kadar çalışır, işine gelirse noter hazır.',
    'Aracın piyasası ölü usta, bu fiyata veren çıkarsa şükret derim.',
    'Selamın aleykum, aracın masrafı çok duruyor. Hurda niyetine bu fiyata kapatırım.',
    'Kardeşim acil nakit lazımsa hemen geleyim, üstüne bir kuruş çıkamam.',
  ];

  /// Generates a realistic buyer offer (including 25% chance of lowball "ölücü" offers)
  static OfferModel generateBuyerOffer(CarModel car, double listingPrice) {
    final realVal = car.estimatedRealValue;
    final isLowball = _random.nextDouble() < 0.25;

    double baseOffer;
    String message;

    if (isLowball) {
      // Ölücü Teklif (%50 - %72 piyasa değeri)
      baseOffer = (realVal * (0.50 + (_random.nextDouble() * 0.22))).roundToDouble();
      message = lowballMessages[_random.nextInt(lowballMessages.length)];
    } else {
      // Normal Teklif (%88 - %108 piyasa değeri)
      baseOffer = (realVal * (0.88 + (_random.nextDouble() * 0.20))).roundToDouble();
      if (baseOffer > listingPrice * 1.05) {
        baseOffer = listingPrice * 0.98;
      }
      message = buyerMessages[_random.nextInt(buyerMessages.length)];
    }

    final buyerName = buyerNames[_random.nextInt(buyerNames.length)];

    return OfferModel(
      id: 'offer_${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(999)}',
      carId: car.id,
      buyerName: isLowball ? 'Ölücü $buyerName' : buyerName,
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
