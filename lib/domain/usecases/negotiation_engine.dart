import 'dart:math';
import '../../core/utils/currency_formatter.dart';
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

  /// Calculates success probability based on asking price, offered price, and player negotiation skill level
  static int calculateMarketplaceBuyerSuccessChance({
    required double askingPrice,
    required double offeredPrice,
    required int negotiationSkillLevel,
  }) {
    if (askingPrice <= 0 || offeredPrice >= askingPrice) return 100;
    final discountPercent = ((askingPrice - offeredPrice) / askingPrice) * 100;
    final double baseChance = 100.0 - (discountPercent * 5.2);
    final double skillBonus = negotiationSkillLevel * 4.0;
    return (baseChance + skillBonus).clamp(5.0, 98.0).round();
  }

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
    // 1. If seller declared honestly or car is completely pristine, zero discrepancy
    if (car.declarationType == ListingDeclarationType.honest || car.isPristineOriginal) {
      return ExpertiseDiscrepancyInfo(
        hasDiscrepancy: false,
        title: 'DÜRÜST SATICI: Söylenenin Dışında Kusur Çıkmadı',
        description: 'Ekspertiz raporu ile satıcı beyanı birebir örtüşüyor. Güvenilir esnaf / dürüst araç sahibi.',
        extraDiscountPercent: 0.0,
      );
    }

    final exp = car.expertise;

    // 2. Tampered Mileage (Major fraud)
    if (exp.isMileageTampered || car.declarationType == ListingDeclarationType.tamperedMileageClaim) {
      return ExpertiseDiscrepancyInfo(
        hasDiscrepancy: true,
        title: 'SAHTE SAYAÇ / KM DÜŞÜRÜLMÜŞ',
        description: 'Ekspertiz beyin taramasında aracın kilometresinin düşürüldüğü kanıtlandı! • -%25 Ekstra İndirim Kozu',
        extraDiscountPercent: 0.25,
      );
    }

    // 3. Minor flaw hidden (Paint or minor cosmetic part undisclosed)
    if (car.declarationType == ListingDeclarationType.minorFlawHidden) {
      final paintedOrDamaged = exp.bodyParts.entries.where(
        (e) => e.value == PartStatus.painted || e.value == PartStatus.changed || e.value == PartStatus.damaged,
      ).toList();
      final partName = paintedOrDamaged.isNotEmpty ? paintedOrDamaged.first.key : 'Gövde';
      return ExpertiseDiscrepancyInfo(
        hasDiscrepancy: true,
        title: 'GİZLİ BOYA / ÇIKINTI PARÇA',
        description: 'İlanda söylenmeyen $partName parçasında boya/işlem tespit edildi! • -%10 Ekstra İndirim Kozu',
        extraDiscountPercent: 0.10,
      );
    }

    // 4. Major flawless claim contradiction (Heavy damage, replaced part, or heavy tramer)
    final changedOrDamaged = exp.bodyParts.entries.where(
      (e) => e.value == PartStatus.changed || e.value == PartStatus.damaged,
    ).toList();

    if (changedOrDamaged.isNotEmpty) {
      final partName = changedOrDamaged.first.key;
      return ExpertiseDiscrepancyInfo(
        hasDiscrepancy: true,
        title: 'KOZ FIRSATI: GİZLİ DEĞİŞEN / HASARLI PARÇA',
        description: 'İlanda söylenmeyen $partName parçasında ağır hasar/değişen tespit edildi! • -%18 Ekstra İndirim Kozu',
        extraDiscountPercent: 0.18,
      );
    }

    if (exp.tramerAmount > 25000) {
      return ExpertiseDiscrepancyInfo(
        hasDiscrepancy: true,
        title: 'GİZLENMİŞ TRAMER KAYDI',
        description: 'Ekspertiz raporunda ₺${exp.tramerAmount} yüksek tramer kaydı çıktı! • -%15 Ekstra İndirim Kozu',
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

  /// Generates a realistic buyer offer with customer archetype and test drive request
  static OfferModel generateBuyerOffer(
    CarModel car,
    double listingPrice, {
    double seasonMultiplier = 1.0,
  }) {
    final realVal = car.estimatedRealValue * seasonMultiplier;
    final askingPrice = car.isListed ? car.listingPrice : (listingPrice > 0 ? listingPrice : realVal);
    final distRoll = _random.nextDouble();

    // Listing Quality Factor
    double listingQualityBonus = 1.0;
    if (car.listingPhotoLocation == 'studio') {
      listingQualityBonus += 0.05;
    } else if (car.listingPhotoLocation == 'scenic') {
      listingQualityBonus += 0.03;
    }
    if (car.listingPhotoCount >= 8) {
      listingQualityBonus += 0.04;
    } else if (car.listingPhotoCount >= 4) {
      listingQualityBonus += 0.02;
    }
    if (car.listingTone == 'vip') {
      listingQualityBonus += 0.03;
    }

    double baseOffer;
    String message;
    String buyerName = buyerNames[_random.nextInt(buyerNames.length)];
    bool isLowball = false;

    // Archetype assignment
    final archetypes = CustomerArchetype.values;
    final assignedArchetype = archetypes[_random.nextInt(archetypes.length)];
    final customer = CustomerModel.generate(assignedArchetype);
    buyerName = customer.name;

    if (distRoll < 0.05) {
      // 1) Collector / Serious Buyer match (%5 chance): Exactly 100% asking price
      baseOffer = askingPrice;
      buyerName = 'Koleksiyoner $buyerName';
      message = 'Tam aradığım temizlikte özel bir araç! İlandaki ${CurrencyFormatter.formatShort(baseOffer)} fiyatınızı kabul ediyorum, hemen notere geçelim.';
    } else if (distRoll < 0.15) {
      // 2) Asking Price Match (%10 chance): Exactly 100% of asking price
      baseOffer = askingPrice;
      message = 'Fiyat gayet makul. İlandaki ${CurrencyFormatter.formatShort(baseOffer)} fiyattan pazarlıksız alıyorum.';
    } else if (distRoll < 0.35) {
      // 3) Lowball / Ölücü (%20 chance): %60 - %78 of asking price
      isLowball = true;
      baseOffer = (askingPrice * (0.60 + (_random.nextDouble() * 0.18))).roundToDouble();
      if (baseOffer >= askingPrice) {
        baseOffer = (askingPrice * 0.75).roundToDouble();
      }
      message = lowballMessages[_random.nextInt(lowballMessages.length)];
    } else {
      // 4) Standard Normal Offer (%65 chance): %85 - %97 of asking price
      final discountPercent = 0.03 + (_random.nextDouble() * 0.12);
      baseOffer = (askingPrice * (1.0 - discountPercent) * listingQualityBonus).roundToDouble();
      if (baseOffer > askingPrice) {
        baseOffer = askingPrice;
      }
      message = buyerMessages[_random.nextInt(buyerMessages.length)];
    }

    // Strict ceiling clamp for cash baseline
    if (baseOffer > askingPrice) {
      baseOffer = askingPrice;
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

    // Offer Type Distribution:
    // If car does NOT allow installments: 100% CASH ONLY (Never installment or cheque)
    // If car allows installments: 50% Installment (Senetli), 25% Cheque (Çekli), 25% Cash
    OfferType chosenOfferType = OfferType.cash;
    int installments = 0;

    if (car.allowsInstallments) {
      final typeRoll = _random.nextDouble();
      if (typeRoll < 0.50) {
        chosenOfferType = OfferType.installment;
        installments = _random.nextBool() ? 6 : 12;
        final premium = 1.15 + (_random.nextDouble() * 0.15); // +15% to +30% financing interest
        baseOffer = (askingPrice * premium).roundToDouble();
        message = 'Usta nakitim kısıtlı ama aylık gelirim düzenli. İlan fiyatınız yerine $installments ay vadeli senetle vade farkıyla toplam ${CurrencyFormatter.formatShort(baseOffer)} teklif ediyorum.';
      } else if (typeRoll < 0.75) {
        chosenOfferType = OfferType.cheque;
        installments = 1;
        final premium = 1.10 + (_random.nextDouble() * 0.10); // +10% to +20% cheque premium
        baseOffer = (askingPrice * premium).roundToDouble();
        message = 'Ticari 45 gün vadeli banka onaylı çekim var. İlan fiyatınız yerine çekle ${CurrencyFormatter.formatShort(baseOffer)} teklif ediyorum.';
      } else {
        chosenOfferType = OfferType.cash;
      }
    } else {
      chosenOfferType = OfferType.cash;
      installments = 0;
    }

    // Test Drive Request (%35 chance for serious buyers)
    bool wantsTestDrive = !isLowball && _random.nextDouble() < 0.35;
    String? testResult;
    if (wantsTestDrive) {
      final engineCond = (car.expertise.engineCondition + car.expertise.transmissionCondition) / 200.0;
      if (engineCond >= 0.85) {
        testResult = 'Test sürüşü kusursuz geçti! Motorun ve yürüyen aksamın sesine hayran kaldı • +%5 Memnuniyet.';
      } else if (engineCond < 0.60) {
        testResult = 'Test sürüşünde motordan gelen tıkırtıyı duydu ve tedirgin oldu!';
      } else {
        testResult = 'Test sürüşünü başarıyla tamamladı, genel sürüşü beğendi.';
      }
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
      buyerCustomer: customer,
      requestedTestDrive: wantsTestDrive,
      testDriveResult: testResult,
    );
  }

  /// Calculates dynamic negotiation price ceiling multiplier based on vehicle & buyer profile (§1.1)
  static double getDynamicCeilingMultiplier(CarModel car, {OfferModel? offer}) {
    if (car.isRare || car.isBarnFind) return 1.65;
    if (offer?.buyerCustomer?.archetype == CustomerArchetype.impatientYouth) return 1.45;
    if (car.plateRarity == 'legendary' || car.colorRarity == 'legendary') return 1.45;
    if (offer?.buyerName.contains('Sözleşme') == true || offer?.buyerName.contains('İhale') == true) return 1.40;
    if (car.isPolished && car.isWashed) return 1.30;
    return 1.25;
  }

  /// Executes interactive esnaf tactics (§2.4 / Q14)
  static Map<String, dynamic> executeEsnafAction({
    required String actionType,
    required double currentOffer,
    required double askingPrice,
    required int negotiationSkillLevel,
  }) {
    switch (actionType) {
      case 'cay_soyle':
        return {
          'success': true,
          'bonusChance': 10 + (negotiationSkillLevel * 2),
          'message': 'Sıcak tavşankanı çay ikram edildi! Satıcının yumuşamasıyla ikna şansı +%${10 + (negotiationSkillLevel * 2)} arttı.',
        };
      case 'sigara_yak':
        return {
          'success': true,
          'bonusChance': 12 + negotiationSkillLevel,
          'message': 'Ağır esnaf tavrıyla sigara yakıldı. Tok duruşun sayesinde satıcının direnci kırıldı! • +%${12 + negotiationSkillLevel}',
        };
      case 'ortak_arayayim':
        final shiftAmount = (askingPrice - currentOffer) * 0.40;
        final newShiftedPrice = (currentOffer + shiftAmount).roundToDouble();
        return {
          'success': true,
          'bonusChance': 15,
          'priceShift': newShiftedPrice,
          'message': 'Ortağa danışıldı ve "Tamamdır usta, ortak onay verdi" denildi. Teklif yukarı çekildi!',
        };
      default:
        return {
          'success': false,
          'bonusChance': 0,
          'message': 'Bilinmeyen esnaf taktiği.',
        };
    }
  }

  /// Process counter-offer from player to buyer with strategic esnaf approaches (§1.1 & §2.4)
  static NegotiationOutcome evaluateCounterOffer({
    required OfferModel currentOffer,
    required double playerTargetPrice,
    required CarModel car,
    required int negotiationSkillLevel,
    String? strategy, // 'ikna_et', 'duyguya_oyna', 'sert_dur', 'hizli_kapat', 'cay_soyle', 'sigara_yak', 'ortak_arayayim'
    List<String> purchasedAcademyCourses = const [],
    bool isTraderSpecialization = false,
  }) {
    final double previousOffer = currentOffer.offeredAmount;
    final double carRealValue = car.estimatedRealValue;
    final customer = currentOffer.buyerCustomer;
    final double maxCeiling = getDynamicCeilingMultiplier(car, offer: currentOffer);

    // Strategy Bonus Modifier
    double strategyBonus = 0.0;
    double walkawayModifier = 0.0;

    // Staff Academy & Specialization Trader Perks
    if (purchasedAcademyCourses.contains('course_sales_master')) {
      strategyBonus += 0.10; // Personel Akademisi Satış Ustası Bonusu
    }
    if (isTraderSpecialization) {
      strategyBonus += 0.15; // Tüccar Uzmanlık Bonusu
    }

    if (strategy == 'ikna_et') {
      // Transparency & Expertise focus
      if (car.declarationType == ListingDeclarationType.honest) {
        strategyBonus += 0.20;
      } else {
        strategyBonus -= 0.10;
        walkawayModifier += 0.15;
      }
    } else if (strategy == 'duyguya_oyna') {
      // Warm Esnaf Tea & Empathy
      if (customer?.archetype == CustomerArchetype.familyMan || customer?.archetype == CustomerArchetype.skepticalOfficial) {
        strategyBonus += 0.18;
      } else if (customer?.archetype == CustomerArchetype.impatientYouth) {
        strategyBonus += 0.05;
      }
    } else if (strategy == 'sert_dur') {
      // Confident Tok Satıcı
      if (customer?.archetype == CustomerArchetype.impatientYouth) {
        strategyBonus += 0.15;
      } else {
        walkawayModifier += 0.20;
      }
    } else if (strategy == 'hizli_kapat') {
      // Fast closure discount
      strategyBonus += 0.22;
    } else if (strategy == 'cay_soyle') {
      // Esnaf Çayı: +10% alıcı toleransı, masadan kalkma riskini düşürür (§2.4)
      strategyBonus += 0.14;
      walkawayModifier -= 0.15;
    } else if (strategy == 'sigara_yak') {
      // Ağırdan Al & Sigara Yak: Tok satıcı duruşu
      strategyBonus += 0.16;
      walkawayModifier += 0.05;
    } else if (strategy == 'ortak_arayayim') {
      // Ortağa Danışma: Fiyatı yukarı çeker
      strategyBonus += 0.18;
    }

    // Skill boost: +3% acceptance probability per skill level
    double skillBonus = ((negotiationSkillLevel - 1) * 0.03) + strategyBonus;

    // Difference ratio between player target and buyer's previous offer
    double diffRatio = (playerTargetPrice - previousOffer) / previousOffer;

    // Probability calculations
    if (playerTargetPrice <= previousOffer) {
      // Player asked for lower/same amount -> Immediate Accept!
      final msg = _getAcceptedMessage(customer?.archetype, playerTargetPrice);
      return NegotiationOutcome(
        updatedOffer: currentOffer.copyWith(
          offeredAmount: playerTargetPrice,
          status: OfferStatus.accepted,
          counterStrategy: strategy,
        ),
        responseMessage: msg,
        isAccepted: true,
        isWalkaway: false,
      );
    }

    if (diffRatio <= 0.08 + skillBonus) {
      // Very reasonable counter offer -> 85% chance accept
      if (_random.nextDouble() < 0.85 + skillBonus) {
        final msg = _getAcceptedMessage(customer?.archetype, playerTargetPrice);
        return NegotiationOutcome(
          updatedOffer: currentOffer.copyWith(
            offeredAmount: playerTargetPrice,
            status: OfferStatus.accepted,
            counterStrategy: strategy,
          ),
          responseMessage: msg,
          isAccepted: true,
          isWalkaway: false,
        );
      }
    }

    final nearMissDiff = (playerTargetPrice - previousOffer).abs().toInt();
    final diffFormatted = '₺${nearMissDiff.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

    // Check walkaway threshold adjusted by dynamic ceiling
    if (diffRatio > 0.50 || playerTargetPrice > carRealValue * (maxCeiling + 0.10)) {
      final msg = _getWalkawayMessage(customer?.archetype, diffFormatted, isExtreme: true);
      return NegotiationOutcome(
        updatedOffer: currentOffer.copyWith(status: OfferStatus.rejected, counterStrategy: strategy),
        responseMessage: msg,
        isAccepted: false,
        isWalkaway: true,
      );
    }

    if (diffRatio > (0.30 - walkawayModifier) || playerTargetPrice > carRealValue * maxCeiling) {
      if (_random.nextDouble() > (0.15 + skillBonus)) {
        final msg = _getWalkawayMessage(customer?.archetype, diffFormatted, isExtreme: false);
        return NegotiationOutcome(
          updatedOffer: currentOffer.copyWith(status: OfferStatus.rejected, counterStrategy: strategy),
          responseMessage: msg,
          isAccepted: false,
          isWalkaway: true,
        );
      }
    }

    // Buyer makes a middle counter-offer
    double buyerNewOffer = (previousOffer + (playerTargetPrice - previousOffer) * (0.45 + _random.nextDouble() * 0.20 + skillBonus)).roundToDouble();
    
    // Dynamic Ceiling constraint (§1.1)
    if (buyerNewOffer > carRealValue * maxCeiling) {
      buyerNewOffer = (carRealValue * maxCeiling).roundToDouble();
    }
    int newCount = currentOffer.counterCount + 1;

    if (newCount >= currentOffer.maxCounters) {
      // Max counters reached -> Buyer gives final offer
      final msg = _getFinalOfferMessage(customer?.archetype, buyerNewOffer);
      return NegotiationOutcome(
        updatedOffer: currentOffer.copyWith(
          offeredAmount: buyerNewOffer,
          counterCount: newCount,
          status: OfferStatus.countered,
          counterStrategy: strategy,
        ),
        responseMessage: msg,
        isAccepted: false,
        isWalkaway: false,
      );
    }

    final msg = _getMiddleCounterMessage(customer?.archetype, buyerNewOffer, playerTargetPrice);
    return NegotiationOutcome(
      updatedOffer: currentOffer.copyWith(
        offeredAmount: buyerNewOffer,
        counterCount: newCount,
        status: OfferStatus.countered,
        counterStrategy: strategy,
      ),
      responseMessage: msg,
      isAccepted: false,
      isWalkaway: false,
    );
  }

  static String _getAcceptedMessage(CustomerArchetype? archetype, double price) {
    final priceStr = '₺${price.round()}';
    final options = switch (archetype) {
      CustomerArchetype.skepticalOfficial => [
        'Anlaştık, $priceStr benim için makul. Noter evraklarını hazırlayalım.',
        'Hayırlı olsun. Ekspertiz raporundaki şeffaflık için teşekkür ederim, $priceStr kabulümdür.',
        'Fiyatta anlaştık. Devir işlemlerini hemen başlatalım.',
      ],
      CustomerArchetype.impatientYouth => [
        'Tamamdır usta! $priceStr fiyata araba benimdir, anahtarı ver gazlayalım!',
        'Süper oldu! Yarın ilk iş egzoz ve jant bakacağım, $priceStr kabul!',
        'Harika rakam, el sıkıştık say!',
      ],
      CustomerArchetype.greedyFlipper => [
        'Kurtardı esnafım. $priceStr nakit hesaba geçiyorum, satışı ver.',
        'Tamam, kırmadın bizi. $priceStr peşin sayıyorum, hayrını gör.',
        'Peki usta, aramızda kalsın bu rakam. Notere geçelim.',
      ],
      _ => [
        'Anlaştık usta! $priceStr aile bütçemize uydu, hayırlı olsun.',
        'Güzel ticaret oldu. $priceStr nakit devir için notere geçebiliriz.',
        'İkna oldum, esnaflığın için sağ ol. $priceStr fiyata anlaştık.',
      ],
    };
    return options[_random.nextInt(options.length)];
  }

  static String _getWalkawayMessage(CustomerArchetype? archetype, String diff, {required bool isExtreme}) {
    if (isExtreme) {
      final options = switch (archetype) {
        CustomerArchetype.skepticalOfficial => [
          'Alıcı $diff fark yüzünden masadan kalktı! — "Bu paraya bayiden sıfır kilometre araç alırım"',
          'Alıcı $diff aşırı farkı görünce evrakları çantasına koyup çıktı. — "Piyasa rayicinin çok üstünde"',
        ],
        CustomerArchetype.impatientYouth => [
          'Genç alıcı $diff fark yüzünden vazgeçti! — "O paraya üst kasa turbo alırım"',
          'Alıcı $diff farkı duyunca kapıyı çarpıp çıktı!',
        ],
        CustomerArchetype.greedyFlipper => [
          'Al-satçı $diff farkı görünce güldü: — "Bize ekmek bırakmadın usta, kolay gelsin"',
          'Esnaf $diff fark yüzünden masadan kalktı. — "Bu fiyata kimseye satamazsın"',
        ],
        _ => [
          'Alıcı $diff fark yüzünden masadan kalktı! — "Bütçemi fazlasıyla aşıyor, başka arabalara bakacağım"',
          'Müşteri $diff fiyat farkını görünce teşekkür edip ayrıldı.',
        ],
      };
      return options[_random.nextInt(options.length)];
    }

    final options = switch (archetype) {
      CustomerArchetype.skepticalOfficial => [
        'Alıcı $diff farkla masadan kalktı! — "Hesaplarıma uymadı, hayırlı işler"',
        'Alıcı $diff fark yüzünden tereddüt etti ve vazgeçti.',
      ],
      CustomerArchetype.impatientYouth => [
        'Alıcı $diff fark yüzünden başka ilana yöneldi.',
        'Genç alıcı $diff farkı karşılayamadığı için ayrıldı.',
      ],
      _ => [
        'Alıcı $diff farkla masadan kalktı! — "Bütçemi aştı, başka ilanlara bakacağım"',
        'Müşteri $diff fark yüzünden anlaşamadı ve ayrıldı.',
      ],
    };
    return options[_random.nextInt(options.length)];
  }

  static String _getMiddleCounterMessage(CustomerArchetype? archetype, double buyerOffer, double targetPrice) {
    final buyerStr = '₺${buyerOffer.round()}';
    final targetStr = '₺${targetPrice.round()}';
    final options = switch (archetype) {
      CustomerArchetype.skepticalOfficial => [
        '$targetStr biraz bütçemi aşıyor. Raporu inceledim, en fazla $buyerStr verebilirim.',
        'Maaş hesabımı dengelemem lazım. $buyerStr nakit ödeyebilirim, ne dersin?',
      ],
      CustomerArchetype.impatientYouth => [
        'Usta $targetStr çok zorlar. Kredi kartı limitimi de ekleyip $buyerStr yapayım, bitirelim!',
        'Arabayı çok beğendim ama param $buyerStr kadar çıkıyor. Orta yolu bulalım.',
      ],
      CustomerArchetype.greedyFlipper => [
        'Esnafım $targetStr kurtarmaz. Ben de ekmek yiyeceğim, $buyerStr peşin çalışır.',
        'Bana $buyerStr bırakırsan yarım saate noterde devri alırız.',
      ],
      _ => [
        '$targetStr biraz yüksek geldi ama bütçemi zorlayıp $buyerStr verebilirim.',
        'Ailemiz için bu araç uygun ama limitimiz $buyerStr. Uyarsa el sıkışalım.',
      ],
    };
    return options[_random.nextInt(options.length)];
  }

  static String _getFinalOfferMessage(CustomerArchetype? archetype, double buyerOffer) {
    final buyerStr = '₺${buyerOffer.round()}';
    final options = [
      'Usta son sözüm $buyerStr. Üstüne bir kuruş çıkamam, kabul ediyorsan hayırlı olsun.',
      'Bütçemin son damlası $buyerStr. Vermezsen başka araca bakacağım.',
      'Son teklifim $buyerStr nakit. Karar senin.',
    ];
    return options[_random.nextInt(options.length)];
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
      buyerCustomer: CustomerModel(
        id: 'loyal_${customerName.hashCode}',
        name: customerName,
        archetype: CustomerArchetype.familyMan,
        archetypeTitle: 'Sadık Müşteri',
        avatarType: 'star',
        personalityDescription: 'Daha önce alışveriş yapmış ve memnun kalmış daimi müşteri.',
        preferredDialogueTrait: 'Vefa & Samimiyet',
      ),
    );
  }
}
