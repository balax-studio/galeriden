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

  /// Generates a realistic buyer offer (strictly capped at seller's custom listing price)
  static OfferModel generateBuyerOffer(CarModel car, double listingPrice) {
    final realVal = car.estimatedRealValue;
    final askingPrice = car.listingPrice;
    final isLowball = _random.nextDouble() < 0.25;

    double baseOffer;
    String message;

    if (isLowball) {
      // Ölücü Teklif (%50 - %72 piyasa değeri, kesinlikle isteğin üstüne çıkamaz)
      baseOffer = (min(realVal, askingPrice) * (0.50 + (_random.nextDouble() * 0.22))).roundToDouble();
      if (baseOffer >= askingPrice) {
        baseOffer = (askingPrice * 0.70).roundToDouble();
      }
      message = lowballMessages[_random.nextInt(lowballMessages.length)];
    } else {
      // Normal Teklif (%88 - %99 isteğin üstüne çıkamaz)
      final maxAllowed = min(realVal * 1.05, askingPrice);
      final minAllowed = min(realVal * 0.85, askingPrice * 0.82);
      baseOffer = (minAllowed + (_random.nextDouble() * (maxAllowed - minAllowed))).roundToDouble();
      if (baseOffer > askingPrice) {
        baseOffer = askingPrice;
      }
      message = buyerMessages[_random.nextInt(buyerMessages.length)];
    }

    final buyerName = buyerNames[_random.nextInt(buyerNames.length)];

    // Randomize Offer Type: 60% Cash, 25% Installment, 15% Cheque
    OfferType chosenOfferType = OfferType.cash;
    final typeRoll = _random.nextDouble();
    if (typeRoll < 0.25) {
      chosenOfferType = OfferType.installment;
      baseOffer = (baseOffer * 1.12).roundToDouble(); // %12 vadeli prim
      message = 'Usta peşinat verip kalanını 5 taksitle ödemek istiyorum. Toplam ₺${baseOffer.round()} veririm.';
    } else if (typeRoll < 0.40) {
      chosenOfferType = OfferType.cheque;
      baseOffer = (baseOffer * 1.15).roundToDouble(); // %15 senet prim
      message = '30 gün vadeli resmi şirket senetim var. Kabul edersen ₺${baseOffer.round()} senet veririm.';
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
}
