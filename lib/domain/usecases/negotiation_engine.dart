import 'dart:math';
import '../../data/models/car_model.dart';
import '../../data/models/customer_model.dart';
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

class FraudInspectionResult {
  final bool didInspect;
  final bool caughtFraud;
  final String title;
  final String description;
  final double fineAmount;
  final int reputationPenalty;

  FraudInspectionResult({
    required this.didInspect,
    required this.caughtFraud,
    required this.title,
    required this.description,
    required this.fineAmount,
    required this.reputationPenalty,
  });
}

class NegotiationEngine {
  static final Random _random = Random();

  /// Evaluates whether a customer inspects player's listing and catches fraud/misleading claims
  static FraudInspectionResult evaluatePlayerFraudInspection({
    required CarModel car,
    required CustomerModel customer,
  }) {
    if (car.declarationType == ListingDeclarationType.honest) {
      return FraudInspectionResult(
        didInspect: false,
        caughtFraud: false,
        title: 'Dürüst İlan',
        description: 'İlanda beyan edilen bilgiler ekspertiz ile %100 uyuşuyor.',
        fineAmount: 0.0,
        reputationPenalty: 0,
      );
    }

    final bool didInspect = _random.nextDouble() < customer.inspectionProbability;

    if (!didInspect) {
      return FraudInspectionResult(
        didInspect: false,
        caughtFraud: false,
        title: 'Ekspertiz Yapılmadı',
        description: 'Müşteri ilana güvendi ve aracı kontrolden geçirmeden kabul etti!',
        fineAmount: 0.0,
        reputationPenalty: 0,
      );
    }

    String title = 'YAKALANDINIZ!';
    String description = car.declarationType == ListingDeclarationType.flawlessClaim
        ? '${customer.name} aracı ekspertize soktu! İlanda "Hatasız" yazılan araçta ağır kusur tespit edildi!'
        : '${customer.name} beyin taraması yaptırdı! Kilometrenin düşürüldüğü tespit edildi!';

    return FraudInspectionResult(
      didInspect: true,
      caughtFraud: true,
      title: title,
      description: description,
      fineAmount: 10000.0,
      reputationPenalty: 15,
    );
  }

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

  /// Generates a realistic buyer offer with 4-tier long-tail distribution (VR2)
  static OfferModel generateBuyerOffer(CarModel car, double listingPrice) {
    final realVal = car.estimatedRealValue;
    final askingPrice = car.listingPrice > 0 ? car.listingPrice : realVal;
    final distRoll = _random.nextDouble();

    double baseOffer;
    String message;
    String buyerName = buyerNames[_random.nextInt(buyerNames.length)];
    bool isLowball = false;

    if (distRoll < 0.02) {
      // 1) Collector Jackpot (%2 chance): +20% to +40% over asking/real price
      baseOffer = (max(realVal, askingPrice) * (1.20 + (_random.nextDouble() * 0.20))).roundToDouble();
      buyerName = 'Koleksiyoner $buyerName';
      message = 'Tam aradığım temizlikte özel bir araç! Kaçırmamak için liste fiyatının da üzerinde ₺${baseOffer.round()} nakit teklif ediyorum!';
    } else if (distRoll < 0.10) {
      // 2) Asking Price Match (%8 chance): Exactly 100% of asking price
      baseOffer = askingPrice;
      message = 'Fiyat çok makul, pazarlıksız ilandaki ₺${askingPrice.round()} fiyata hemen notere geçelim.';
    } else if (distRoll < 0.30) {
      // 3) Lowball / Ölücü (%20 chance): %55 - %75 of asking/real price
      isLowball = true;
      baseOffer = (min(realVal, askingPrice) * (0.55 + (_random.nextDouble() * 0.20))).roundToDouble();
      if (baseOffer >= askingPrice) {
        baseOffer = (askingPrice * 0.70).roundToDouble();
      }
      message = lowballMessages[_random.nextInt(lowballMessages.length)];
    } else {
      // 4) Standard Normal Offer (%70 chance): %88 - %98 of asking price
      final maxAllowed = min(realVal * 1.02, askingPrice * 0.98);
      final minAllowed = min(realVal * 0.88, askingPrice * 0.88);
      baseOffer = (minAllowed + (_random.nextDouble() * max(1000.0, maxAllowed - minAllowed))).roundToDouble();
      if (baseOffer > askingPrice) {
        baseOffer = askingPrice;
      }
      message = buyerMessages[_random.nextInt(buyerMessages.length)];
    }

    // Credit score generation
    int creditScore;
    final scoreRoll = _random.nextDouble();
    if (scoreRoll < 0.40) {
      creditScore = 80 + _random.nextInt(19); // 80 - 98 (Safe)
    } else if (scoreRoll < 0.75) {
      creditScore = 50 + _random.nextInt(29); // 50 - 78 (Moderate)
    } else if (scoreRoll < 0.90) {
      creditScore = 30 + _random.nextInt(19); // 30 - 48 (Risky)
    } else {
      creditScore = 12 + _random.nextInt(17); // 12 - 28 (Severe default risk)
    }

    // Offer Type Distribution: 50% Cash, 30% Installment (Senetli/Taksitli), 20% Cheque (Çekli)
    OfferType chosenOfferType = OfferType.cash;
    int installments = 0;
    final typeRoll = _random.nextDouble();

    if (typeRoll < 0.30) {
      chosenOfferType = OfferType.installment;
      installments = _random.nextBool() ? 6 : 12;
      final premium = 1.15 + (_random.nextDouble() * 0.15); // +15% to +30% price premium
      baseOffer = (baseOffer * premium).roundToDouble();
      message = 'Usta nakitim kısıtlı ama aylık gelirim iyi. Aracı $installments ay vadeli senetle ₺${baseOffer.round()} fiyata alayım.';
    } else if (typeRoll < 0.50) {
      chosenOfferType = OfferType.cheque;
      installments = 1;
      final premium = 1.12 + (_random.nextDouble() * 0.10); // +12% to +22% cheque premium
      baseOffer = (baseOffer * premium).roundToDouble();
      message = 'Ticari 45 gün vadeli banka onaylı çekim var. Kabul edersen ₺${baseOffer.round()} fiyata anlaşalım.';
    }

    return OfferModel(
      id: 'offer_${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(999)}',
      carId: car.id,
      buyerName: isLowball ? 'Ölücü $buyerName' : buyerName,
      offeredAmount: baseOffer,
      buyerMessage: message,
      status: OfferStatus.pending,
      createdAt: DateTime.now(),
      offerType: chosenOfferType,
      customerCreditScore: creditScore,
      installmentMonths: installments,
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
    // 1) Hard Walkaway for ridiculous offers (No skill can save this)
    if (diffRatio > 0.40 || playerTargetPrice > carRealValue * 1.30) {
      return NegotiationOutcome(
        updatedOffer: currentOffer.copyWith(status: OfferStatus.rejected),
        responseMessage: 'Dalga mı geçiyorsun usta? Bu paraya bayiden sıfırını alırım! Hadi eyvallah.',
        isAccepted: false,
        isWalkaway: true,
      );
    }

    // 2) Soft Walkaway for high offers (Can be saved by skill)
    if (diffRatio > 0.25 || playerTargetPrice > carRealValue * 1.15) {
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
    
    // HARD CAP: Buyer will NEVER offer more than 115% of the car's real value
    if (buyerNewOffer > carRealValue * 1.15) {
      buyerNewOffer = (carRealValue * 1.15).roundToDouble();
    }
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

  /// Generates a bonus offer from a loyal returning customer (CRM feature)
  static OfferModel generateLoyalCustomerOffer({
    required CarModel car,
    required String customerName,
  }) {
    final realVal = car.estimatedRealValue;
    final askingPrice = car.listingPrice > 0 ? car.listingPrice : realVal;
    // Loyal customers offer between 98% and 106% of asking/real value
    final offerAmount = (max(realVal, askingPrice) * (0.98 + (_random.nextDouble() * 0.08))).roundToDouble();

    return OfferModel(
      id: 'loyal_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1000)}',
      carId: car.id,
      buyerName: customerName,
      offeredAmount: offerAmount,
      buyerMessage: 'Tekrar merhaba! Senden daha önce aldığım araçtan çok memnun kaldım. Bu aracı da ₺${offerAmount.round()} nakit fiyata almak isterim.',
      createdAt: DateTime.now(),
      customerCreditScore: 95,
      offerType: OfferType.cash,
    );
  }
}
