import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/utils/anti_repetition_queue.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/slot_text_composer.dart';
import '../../data/models/car_model.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/expertise_model.dart';
import '../../data/models/offer_model.dart';

enum TacticContext {
  buying,
  selling,
  both,
}

class EsnafTactic {
  final String id;
  final String title;
  final String badgeText;
  final String description;
  final String iconKey;
  final TacticContext context;
  final List<CustomerArchetype> preferredArchetypes;
  final int baseBonusPercent;
  final String successDialogue;
  final String failureDialogue;
  final String walkawayDialogue;
  final List<String> successDialogues;
  final List<String> failureDialogues;
  final List<String> walkawayDialogues;
  final Color accentColor;
  final String category;

  const EsnafTactic({
    required this.id,
    required this.title,
    required this.badgeText,
    required this.description,
    required this.iconKey,
    required this.context,
    this.preferredArchetypes = const [],
    required this.baseBonusPercent,
    required this.successDialogue,
    required this.failureDialogue,
    required this.walkawayDialogue,
    this.successDialogues = const [],
    this.failureDialogues = const [],
    this.walkawayDialogues = const [],
    this.accentColor = const Color(0xFFFFB703),
    this.category = 'prestige',
  });

  String getDynamicSuccessDialogue([Random? rng]) {
    final list = successDialogues.isNotEmpty ? successDialogues : [successDialogue];
    return list[(rng ?? Random()).nextInt(list.length)];
  }

  String getDynamicFailureDialogue([Random? rng]) {
    final list = failureDialogues.isNotEmpty ? failureDialogues : [failureDialogue];
    return list[(rng ?? Random()).nextInt(list.length)];
  }

  String getDynamicWalkawayDialogue([Random? rng]) {
    final list = walkawayDialogues.isNotEmpty ? walkawayDialogues : [walkawayDialogue];
    return list[(rng ?? Random()).nextInt(list.length)];
  }
}

class TacticRollOutcome {
  final bool isSuccess;
  final bool isWalkaway;
  final int diceRoll;
  final int threshold;
  final int bonusChance;
  final String message;
  final String tacticTitle;

  const TacticRollOutcome({
    required this.isSuccess,
    required this.isWalkaway,
    required this.diceRoll,
    required this.threshold,
    required this.bonusChance,
    required this.message,
    required this.tacticTitle,
  });
}

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

  /// Calculates success probability based on asking price, offered price, player negotiation skill level and lifestyle bonuses
  static int calculateMarketplaceBuyerSuccessChance({
    required double askingPrice,
    required double offeredPrice,
    required int negotiationSkillLevel,
    double lifestyleBonusPercent = 0.0,
  }) {
    if (askingPrice <= 0 || offeredPrice >= askingPrice) return 100;
    final discountPercent = ((askingPrice - offeredPrice) / askingPrice) * 100;
    final double baseChance = 100.0 - (discountPercent * 5.2);
    final double skillBonus = negotiationSkillLevel * 4.0;
    // Diminishing returns on lifestyle bonus (soft-cap at 8%)
    final double lifestyleGain = (lifestyleBonusPercent * 100.0).clamp(0.0, 8.0);
    return (baseChance + skillBonus + lifestyleGain).clamp(5.0, 95.0).round();
  }

  /// Evaluates whether a customer inspects player's listing and catches fraud/misleading claims
  static FraudInspectionResult evaluatePlayerFraudInspection({
    required CarModel car,
    required CustomerModel customer,
    Random? random,
    bool? forceInspect,
  }) {
    final exp = car.expertise;
    final hasBodyFlaws = exp.bodyParts.values.any((status) =>
        status == PartStatus.painted ||
        status == PartStatus.localPainted ||
        status == PartStatus.changed ||
        status == PartStatus.damaged);
    final hasTramer = exp.tramerAmount > 0;
    final isTampered = exp.isMileageTampered;
    final hasSevereMechanical = exp.engineCondition < 60.0 || exp.transmissionCondition < 60.0;
    final bool isActuallyFlawless =
        (!hasBodyFlaws && !hasTramer && !isTampered && !hasSevereMechanical) ||
        car.isPristineOriginal;

    final rng = random ?? _random;

    if (car.declarationType == ListingDeclarationType.honest ||
        ((car.declarationType == ListingDeclarationType.flawlessClaim ||
                car.declarationType == ListingDeclarationType.minorFlawHidden) &&
            isActuallyFlawless)) {
      final bool customerInspected =
          forceInspect ?? (rng.nextDouble() < customer.inspectionProbability);
      return FraudInspectionResult(
        didInspect: customerInspected,
        caughtFraud: false,
        title: customerInspected ? 'Ekspertiz Kusursuz Çıktı!' : 'Dürüst İlan',
        description: customerInspected
            ? '${customer.name} aracı kurumsal ekspertize soktu. İddia ettiğiniz gibi tek bir hata bile çıkmadı! Müşteri güvenle satın alıyor.'
            : 'İlanda beyan edilen bilgiler ekspertiz ile %100 uyuşuyor.',
        fineAmount: 0.0,
        reputationPenalty: 0,
      );
    }

    final bool didInspect = forceInspect ?? (rng.nextDouble() < customer.inspectionProbability);

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

    // Ekspertizde kusurun gözden kaçma veya alıcının önemsememe ihtimali
    final double detectionRate;
    switch (car.declarationType) {
      case ListingDeclarationType.minorFlawHidden:
        detectionRate = 0.50;
        break;
      case ListingDeclarationType.flawlessClaim:
        detectionRate = 0.65;
        break;
      case ListingDeclarationType.tamperedMileageClaim:
        detectionRate = 0.80;
        break;
      default:
        detectionRate = 0.60;
    }

    final bool caught = forceInspect ?? (rng.nextDouble() < detectionRate);

    if (!caught) {
      return FraudInspectionResult(
        didInspect: true,
        caughtFraud: false,
        title: 'Kusur Gözden Kaçtı!',
        description:
            '${customer.name} ekspertiz yaptırdı ancak usta ilandaki kusurları gözden kaçırdı! Şans eseri yakalanmadın.',
        fineAmount: 0.0,
        reputationPenalty: 0,
      );
    }

    String title = 'YAKALANDINIZ!';
    String description = car.declarationType == ListingDeclarationType.flawlessClaim
        ? '${customer.name} aracı ekspertize soktu! İlanda "Hatasız" yazılan araçta kusur tespit edildi!'
        : (isTampered
            ? '${customer.name} beyin taraması yaptırdı! Kilometrenin düşürüldüğü tespit edildi!'
            : '${customer.name} ekspertiz yaptırdı! İlanda gizlenen kusurlar tespit edildi!');

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

  static final AntiRepetitionQueue<String> _dialogueQueue = AntiRepetitionQueue<String>(capacity: 25);

  /// Generates a dynamic, culturally rich, non-repetitive buyer message using slot composition
  static String generateDynamicBuyerMessage({
    required CustomerArchetype archetype,
    required double offeredPrice,
    required double askingPrice,
    bool isLowball = false,
    bool isOverTuned = false,
    bool isCollector = false,
    Random? rng,
  }) {
    final random = rng ?? _random;
    final formattedPrice = CurrencyFormatter.formatShort(offeredPrice);

    if (isCollector) {
      final collectorPool = [
        'Tam aradığım temizlikte özel bir araç! İlandaki $formattedPrice fiyatınızı kabul ediyorum, hemen notere geçelim.',
        'Koleksiyonumda eksik olan nadir bir parça. Belirttiğiniz $formattedPrice rakamı fazlasıyla hak ediyor, hayırlı olsun.',
        'Kondisyonuna ve orijinal hatlarına hayran kaldım. $formattedPrice üzerinden devir işlemlerini başlatalım.',
        'Özel garajımda saklayacağım nadide bir makine. İlandaki $formattedPrice teklifinizi onaylıyorum.',
      ];
      return _dialogueQueue.selectNext(collectorPool, randomInstance: random);
    }

    if (isOverTuned && archetype == CustomerArchetype.impatientYouth) {
      final slot1 = [
        'Reis makine alev atıyor •',
        'Ustam popcorn yazılımına bittim •',
        'Caddede dikkat çeker bu makine •',
        'Valla garajda gördüm kanım kaynadı •',
        'Sesi caddeleri inletir bunun •',
        'Basıklığı ve duruşu efsane olmuş •',
      ];
      final slot2 = [
        'Bu basıklık ve egzoz sesi tam bizim semte göre.',
        'Arabayı bu akşam alıp caddeye çıkmam lazım.',
        'Jantlar ve bodykit harika duruyor.',
        'Duruşu kordonu mermi gibi maşallah.',
        'Mekanik ciğeri diriyse ufak tefek sürtmelere bakmam.',
        'Tam aradığım hot hatch duruşu.',
      ];
      final slot3 = [
        '$formattedPrice peşin veriyorum, hemen el sıkışalım.',
        '$formattedPrice say hemen IBAN at, noter harcını ben ödeyeyim.',
        '$formattedPrice teklif ediyorum, direkt notere geçelim.',
        '$formattedPrice nakite bu akşam anahtarı teslim alayım.',
      ];
      final composed = SlotTextComposer.compose3(slot1: slot1, slot2: slot2, slot3: slot3, randomInstance: random);
      _dialogueQueue.push(composed);
      return composed;
    }

    if (isLowball) {
      final slot1 = [
        'Usta öldürmüş gibi olmasın ama •',
        'Selamın aleykum usta •',
        'Piyasa şartları malum •',
        'Kardeşim acil nakit lazımsa •',
        'Araç başında konuştuk say •',
        'Ustam hayırlı işler •',
        'Galerici dostum kolay gelsin •',
      ];
      final slot2 = [
        'aracın masrafı çok duruyor, piyasası da durgun.',
        'bu rakamlara müşteri bulamazsın, herkes nakit sıkışıklığında.',
        'kaporta ve yürüyen elden geçmeli, masrafı boyunu aşar.',
        'hurda niyetine bu fiyata kapatırım.',
        'üstüne bir kuruş dahi çıkamam, nakit bu kadar çalışır.',
        'piyasada yaprak kımıldamıyor, bu parayı veren çıkmaz.',
        'ağır hasar riski var, fiyatı bu seviyeye çekmemiz lazım.',
      ];
      final slot3 = [
        '$formattedPrice nakit çalışır, işine gelirse noter hazır.',
        '$formattedPrice veririm, anında hesaba geçerim.',
        '$formattedPrice peşin teklifimdir, düşünürsen ara.',
        '$formattedPrice deste nakit masada, hemen devri alalım.',
        '$formattedPrice son teklifim, başka kapıya bakma.',
      ];
      final composed = SlotTextComposer.compose3(slot1: slot1, slot2: slot2, slot3: slot3, randomInstance: random);
      _dialogueQueue.push(composed);
      return composed;
    }

    switch (archetype) {
      case CustomerArchetype.skepticalOfficial:
        final slot1 = [
          'İyi günler beyefendi •',
          'Hayırlı işler ustam •',
          'İlanınızı memurlar lokalinde gördüm •',
          'Aracın sicil kaydını inceledim •',
          'Selamlar ustam •',
          'Hayırlı ticaretler beyefendi •',
        ];
        final slot2 = [
          'Maaşımız belli, sürpriz masraf kaldıracak durumum yok.',
          'Şasilerde ve podyelerde en ufak oynama varsa noterden dönerim.',
          'Triger seti ve periyodik bakım faturalarını görmek isterim.',
          'Kilometre orijinal mi yoksa beyinle oynandı mı ekspertizde netleşir.',
          'Ailemizle uzun yola çıkacağız, masrafsız binilecek araç arıyorum.',
          'Yetkili servis kayıtları tamsa almayı ciddi düşünüyorum.',
        ];
        final slot3 = [
          'Bütçem ancak $formattedPrice nakite elveriyor, uygunsa ekspertize geçelim.',
          'Ekspertiz masrafını yarı yarıya bölüşürsek $formattedPrice peşin verebilirim.',
          'Son limitim $formattedPrice, kabul ederseniz randevuyu oluşturalım.',
          'Maksimum bütçem $formattedPrice, uygun görürseniz aracı görmek isterim.',
        ];
        final composed = SlotTextComposer.compose3(slot1: slot1, slot2: slot2, slot3: slot3, randomInstance: random);
        _dialogueQueue.push(composed);
        return composed;

      case CustomerArchetype.impatientYouth:
        final slot1 = [
          'Selamın aleykum reis •',
          'Ustam makine çok diri duruyor •',
          'Caddede dikkat çeker bu kasa •',
          'Hayırlı cumalar kral •',
          'İlanda gördüm hemen yazdım •',
          'Reis hayırlı işler •',
        ];
        final slot2 = [
          'Duruşu ve kordonu mermi gibi maşallah.',
          'Bu akşam sahil turuna çıkmam lazım, acil alıp geçeceğim.',
          'Egzoz sesi ve jantlar tam aradığım tarzda.',
          'Mekanik yürüyeni diriyse ufak çiziklerine takılmam.',
          'Kasa diri olsun gerisini sanayide hallederiz.',
          'Motor sesi ciğerli geliyor.',
        ];
        final slot3 = [
          'Cebimde net $formattedPrice hazır, yarım saate noterdeyim.',
          'Reis $formattedPrice say hemen IBAN at, noter harcını ben ödeyeyim.',
          '$formattedPrice nakit veriyorum, direkt ruhsatı üstüme alayım.',
          '$formattedPrice peşin elden veririm, hemen devredelim.',
        ];
        final composed = SlotTextComposer.compose3(slot1: slot1, slot2: slot2, slot3: slot3, randomInstance: random);
        _dialogueQueue.push(composed);
        return composed;

      case CustomerArchetype.greedyFlipper:
        final slot1 = [
          'Hayırlı ticaretler kardeşim •',
          'Usta kolay gelsin, piyasa durgun •',
          'Biz de bu işin içindeyiz •',
          'Hayırlı pazarlar esnaf dostum •',
          'Selamın aleykum hayırlı işler •',
          'Bereketli olsun usta •',
        ];
        final slot2 = [
          'Bu kasanın piyasası ağır gidiyor, hızlı erimiyor.',
          'Boya takıntım yok ama müşteriye satarken fiyat kırmak zorundayım.',
          'Kaportada ufak dalga var, masrafını düşmek durumundayım.',
          'Tramer kaydını ve piyasa durgunluğunu göz önüne alıyorum.',
          'Piyasada yaprak kımıldamıyor, nakit dönen tek adam benim.',
          'İki günde satmam lazım, sermayeyi bağlayamam.',
        ];
        final slot3 = [
          'Bana da üç beş ekmek kalsın, $formattedPrice peşin verip arabayı şimdi kaldırayım.',
          'Gözünü seveyim beni yorma, $formattedPrice nakit deste masada.',
          '$formattedPrice nakit hemen hesaba geçsin, arabayı çekiciye yükleyelim.',
          '$formattedPrice peşine bağlayalım, iki esnaf helalleşelim.',
        ];
        final composed = SlotTextComposer.compose3(slot1: slot1, slot2: slot2, slot3: slot3, randomInstance: random);
        _dialogueQueue.push(composed);
        return composed;

      case CustomerArchetype.familyMan:
        final slot1 = [
          'Selamlar ustam •',
          'Cümleten hayırlı işler •',
          'Çocukları okula bırakıp geldik •',
          'Ailemiz için temiz bir araç arıyoruz •',
          'Hayırlı günler evladım •',
          'Kolay gelsin ustam •',
        ];
        final slot2 = [
          'Bagaj hacmi ve çocuk koltuğu konforu bizim için çok önemli.',
          'Kliması ve kaloriferi sorunsuz üflüyor mu, çoluk çocuk yolda kalmayalım.',
          'İç döşemeleri temiz olsun, sigara kokusu sinmemişse talibiz.',
          'LPG tank tarihi ve muayenesi güncelse sanayiyle uğraşmak istemem.',
          'Eşimle konuştuk, temizliğine güvenirsek almak istiyoruz.',
          'Geniş ferah bir aile arabasına ihtiyacımız var.',
        ];
        final slot3 = [
          'Bütçemiz en fazla $formattedPrice nakite yetiyor, kabul ederseniz duamızı alırsınız.',
          'Kısmetse $formattedPrice teklif ediyorum, hayrını görelim inşallah.',
          '$formattedPrice peşin verebilirim, ailemize uğur getirsin.',
          '$formattedPrice nakit denkleştirdik, helali hoş olsun.',
        ];
        final composed = SlotTextComposer.compose3(slot1: slot1, slot2: slot2, slot3: slot3, randomInstance: random);
        _dialogueQueue.push(composed);
        return composed;
    }
  }

  /// Generates a realistic buyer offer with customer archetype and test drive request
  static OfferModel generateBuyerOffer(
    CarModel car,
    double listingPrice, {
    double seasonMultiplier = 1.0,
    bool isFinanceUnlocked = true,
    double districtMultiplier = 1.0,
    double gossipMultiplier = 1.0,
    double branchMultiplier = 1.0,
    double weatherMultiplier = 1.0,
    int? currentDay,
  }) {
    final totalMultiplier = seasonMultiplier *
        districtMultiplier *
        gossipMultiplier *
        branchMultiplier *
        weatherMultiplier;
    final realVal = car.estimatedRealValue * totalMultiplier;
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
    bool isLowball = false;

    // Archetype assignment: Over-tuned vehicles heavily attract young enthusiasts
    final CustomerArchetype assignedArchetype;
    if (car.isOverTuned && _random.nextDouble() < 0.85) {
      assignedArchetype = CustomerArchetype.impatientYouth;
    } else {
      final archetypes = CustomerArchetype.values;
      assignedArchetype = archetypes[_random.nextInt(archetypes.length)];
    }
    final customer = CustomerModel.generate(assignedArchetype);
    String buyerName = customer.name;

    // Realistic market ceiling: Buyers won't pay unlimited money just because an asking price is inflated
    final bool isOverpriced = askingPrice > (realVal * 1.05);
    final double maxRealisticWillingness = realVal * (1.05 + (listingQualityBonus - 1.0) + (car.isRare ? 0.10 : 0.0));

    if (distRoll < 0.05) {
      // 1) Collector / Serious Buyer match (%5 chance): Accepts asking price only if reasonably priced or rare, otherwise caps at realistic willingness
      baseOffer = isOverpriced && !car.isRare ? min(askingPrice, maxRealisticWillingness) : askingPrice;
      buyerName = 'Koleksiyoner $buyerName';
      message = generateDynamicBuyerMessage(
        archetype: assignedArchetype,
        offeredPrice: baseOffer,
        askingPrice: askingPrice,
        isCollector: true,
      );
    } else if (distRoll < 0.15) {
      // 2) Asking Price Match (%10 chance): Exactly asking price (capped at market willingness if overpriced)
      baseOffer = isOverpriced ? min(askingPrice, maxRealisticWillingness) : askingPrice;
      message = generateDynamicBuyerMessage(
        archetype: assignedArchetype,
        offeredPrice: baseOffer,
        askingPrice: askingPrice,
        isOverTuned: car.isOverTuned,
      );
    } else if (distRoll < 0.35) {
      // 3) Lowball / Ölücü (%20 chance): %60 - %78 of asking price (anchored to min of askingPrice and realVal)
      isLowball = true;
      final anchorPrice = min(askingPrice, realVal * 1.10);
      baseOffer = (anchorPrice * (0.60 + (_random.nextDouble() * 0.18))).roundToDouble();
      if (baseOffer >= askingPrice) {
        baseOffer = (askingPrice * 0.75).roundToDouble();
      }
      message = generateDynamicBuyerMessage(
        archetype: assignedArchetype,
        offeredPrice: baseOffer,
        askingPrice: askingPrice,
        isLowball: true,
        isOverTuned: car.isOverTuned,
      );
    } else {
      // 4) Standard Normal Offer (%65 chance): %85 - %97 of fair anchor price
      final discountPercent = 0.03 + (_random.nextDouble() * 0.12);
      final anchorPrice = isOverpriced ? min(askingPrice, maxRealisticWillingness) : askingPrice;
      baseOffer = (anchorPrice * (1.0 - discountPercent) * listingQualityBonus).roundToDouble();
      if (baseOffer > askingPrice) {
        baseOffer = askingPrice;
      }
      message = generateDynamicBuyerMessage(
        archetype: assignedArchetype,
        offeredPrice: baseOffer,
        askingPrice: askingPrice,
        isOverTuned: car.isOverTuned,
      );
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
    // If car does NOT allow installments OR finance is locked: 100% CASH ONLY (Never installment or cheque)
    // If car allows installments AND finance is unlocked: 50% Installment (Senetli), 25% Cheque (Çekli), 25% Cash
    OfferType chosenOfferType = OfferType.cash;
    int installments = 0;

    if (car.allowsInstallments && isFinanceUnlocked) {
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

    final now = DateTime.now();
    return OfferModel(
      id: 'offer_${now.microsecondsSinceEpoch}_${_random.nextInt(999)}',
      carId: car.id,
      buyerName: isLowball ? 'Ölücü $buyerName' : buyerName,
      offeredAmount: baseOffer,
      buyerMessage: message,
      status: OfferStatus.pending,
      createdAt: now,
      expiresAt: now.add(Duration(minutes: 3 + _random.nextInt(6))),
      expiresOnDay: (currentDay ?? 1) + 2 + _random.nextInt(3),
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

  // --- DYNAMIC ESNAF TACTICS POOL (§2.4 / Q14) ---
  static const List<EsnafTactic> allTactics = [
    // --- ALIM TAKTİKLERİ (BUYING) ---
    EsnafTactic(
      id: 'ekspertiz_kusuru',
      title: 'Ekspertiz Kusuru Öne Sür',
      badgeText: 'Kusur Baskısı',
      description: 'Araçtaki boya, hasar veya yüksek kilometreyi masaya koyup fiyatı kır.',
      iconKey: 'expert',
      context: TacticContext.buying,
      preferredArchetypes: [CustomerArchetype.skepticalOfficial, CustomerArchetype.familyMan],
      baseBonusPercent: 18,
      accentColor: Color(0xFF00E575),
      category: 'defect',
      successDialogue: 'Ekspertiz raporundaki kusurlar tek tek sayıldı • Satıcı terledi ve boyun eğdi!',
      failureDialogue: 'Satıcı • Usta araba sıfır değil, bu yaşta normal • diyerek kusurlara kulak tıkadı.',
      walkawayDialogue: 'Satıcı sinirlendi • Kusur arıyorsan bayiye git sıfır al usta, pazarlık bitti! • Masayı terk etti.',
    ),
    EsnafTactic(
      id: 'nakit_goster',
      title: 'Nakit Para Çıkar',
      badgeText: 'Peşin Gücü',
      description: 'Deste nakdi masaya koyup hemen notere geçme teklifi yap.',
      iconKey: 'cash',
      context: TacticContext.buying,
      preferredArchetypes: [CustomerArchetype.greedyFlipper, CustomerArchetype.impatientYouth],
      baseBonusPercent: 20,
      accentColor: Color(0xFFFFDE59),
      category: 'cash',
      successDialogue: 'Masanın üstündeki nakit desteyi gören satıcının gözleri parladı • Hemen el sıkışmaya hazır!',
      failureDialogue: 'Satıcı • Paranın yüzü sıcak ama bu rakama kurtarmaz usta • diyerek tok durdu.',
      walkawayDialogue: 'Satıcı • Parayla beni ezemezsin usta, araba satılık değil artık! • Masadan kalktı.',
    ),
    EsnafTactic(
      id: 'piyasa_durgunlugu',
      title: 'Piyasa Durgunluğu Blöfü',
      badgeText: 'Piyasa Gerçeği',
      description: 'Piyasada yaprak kımıldamadığını, bu fiyata kimsenin almayacağını söyle.',
      iconKey: 'market',
      context: TacticContext.buying,
      preferredArchetypes: [CustomerArchetype.skepticalOfficial, CustomerArchetype.familyMan],
      baseBonusPercent: 16,
      accentColor: Color(0xFFFF54B0),
      category: 'market',
      successDialogue: 'Piyasa analizlerin satıcıyı ikna etti • "Haklısın usta, uzun süredir soran yoktu" diyerek yumuşadı!',
      failureDialogue: 'Satıcı • Piyasayı bana öğretme usta, dün 3 kişi aradı bu araba için • diyerek rest çekti.',
      walkawayDialogue: 'Satıcı • Madem piyasa ölü, araba garajımda yatar yine de sana vermem! • Masadan ayrıldı.',
    ),
    EsnafTactic(
      id: 'ortak_arayayim',
      title: 'Ortağa Danış',
      badgeText: 'Bütçe Limiti',
      description: 'Ortağını arayıp bütçenin son limitine gelindiği algısı yarat.',
      iconKey: 'partner',
      context: TacticContext.buying,
      preferredArchetypes: [CustomerArchetype.familyMan, CustomerArchetype.skepticalOfficial, CustomerArchetype.greedyFlipper],
      baseBonusPercent: 16,
      accentColor: Color(0xFF38BDF8),
      category: 'budget',
      successDialogue: 'Ortağa danışıldı • "Usta ortak onay vermiyor, bütçemiz ancak bu fiyata yetiyor" denildi. Satıcının direnci kırıldı!',
      failureDialogue: 'Karşı taraf • Ortağın da piyasayı bilmiyor herhalde usta • diyerek taviz vermedi.',
      walkawayDialogue: 'Satıcı • Ortağınla aranda anlaş öyle gel, vaktimi harcama! • Masayı terk etti.',
    ),
    EsnafTactic(
      id: 'cay_soyle',
      title: 'Tavşankanı Çay Ismarla',
      badgeText: 'Ortamı Yumuşat',
      description: 'Sıcak çay ikram edip muhabbetle satıcının savunmasını düşür.',
      iconKey: 'tea',
      context: TacticContext.buying,
      preferredArchetypes: [CustomerArchetype.skepticalOfficial, CustomerArchetype.familyMan, CustomerArchetype.impatientYouth, CustomerArchetype.greedyFlipper],
      baseBonusPercent: 14,
      accentColor: Color(0xFFFFB703),
      category: 'diplomacy',
      successDialogue: 'Tavşankanı sıcak çay yudumlandı • Tatlı muhabbetle masadaki buzlar tamamen eridi!',
      failureDialogue: 'Satıcı • Sağ ol usta çaya vaktim yok, fiyata gelelim • diyerek kestirip attı.',
      walkawayDialogue: 'Satıcı • Çayla kahveyle aklımı çelemezsin, satmıyorum! • Masadan kalktı.',
    ),
    EsnafTactic(
      id: 'sigara_yak',
      title: 'Ağır Esnaf Tavrı',
      badgeText: 'Direnç Kır',
      description: 'Kendinden emin ağır galerici duruşuyla satıcıya baskı kur.',
      iconKey: 'smoke',
      context: TacticContext.buying,
      preferredArchetypes: [CustomerArchetype.impatientYouth, CustomerArchetype.greedyFlipper],
      baseBonusPercent: 15,
      accentColor: Color(0xFF94A3B8),
      category: 'firmness',
      successDialogue: 'Ağır esnaf tavrın ve kendinden emin duruşun karşı tarafın direncini kırdı!',
      failureDialogue: 'Karşı taraf ağır duruşundan etkilenmedi • "Fiyatım net usta" dedi.',
      walkawayDialogue: 'Karşı taraf tavrından rahatsız oldu • "Böyle esnaflık olmaz" diyerek masayı terk etti.',
    ),
    EsnafTactic(
      id: 'usta_cagir',
      title: 'Sanayiden Usta Çağır',
      badgeText: 'Usta Gözü',
      description: 'Sanayiden güvendiğin motor ustasını çağırıp gizli sesleri dinlet.',
      iconKey: 'mechanic',
      context: TacticContext.buying,
      preferredArchetypes: [CustomerArchetype.skepticalOfficial, CustomerArchetype.impatientYouth],
      baseBonusPercent: 19,
      accentColor: Color(0xFFF97316),
      category: 'mechanic',
      successDialogue: 'Usta kaputu açıp iki noktayı gösterdi • Satıcı afalladı ve fiyatta büyük geri adım attı!',
      failureDialogue: 'Satıcı • Kendi ustanı getirmişsin tabii kusur bulur • diyerek itiraz etti.',
      walkawayDialogue: 'Satıcı • Arabamı kurcalatmam kimseye, araba satılık değil! • Masadan ayrıldı.',
    ),
    EsnafTactic(
      id: 'cebindeki_son_nakit',
      title: 'Cebimdeki Son Kuruş',
      badgeText: 'Son Bütçe',
      description: 'Hesaptaki ve cepteki tüm parayı denkleştirdiğini, tek kuruş fazlasının olmadığını söyle.',
      iconKey: 'cash',
      context: TacticContext.buying,
      preferredArchetypes: [CustomerArchetype.familyMan, CustomerArchetype.skepticalOfficial],
      baseBonusPercent: 17,
      accentColor: Color(0xFFFFDE59),
      category: 'cash',
      successDialogue: 'Tüm birikimini dürüstçe masaya koyman satıcıyı etkiledi • "Sana helal olsun" diyerek kabul etti!',
      failureDialogue: 'Satıcı • Herkesin bir bütçesi var usta, benim de masrafım var • diyerek inmedi.',
      walkawayDialogue: 'Satıcı • Cebinde paran yoksa araba bakma usta! • Masadan kalktı.',
    ),
    EsnafTactic(
      id: 'kaporayi_vereyim_hemen',
      title: 'Kapora Masada Resti',
      badgeText: 'Anında Kapora',
      description: 'Cebinden kaporayı çıkarıp masaya vur, bu fiyata el sıkışılırsa ilanı hemen kapattır.',
      iconKey: 'speed',
      context: TacticContext.buying,
      preferredArchetypes: [CustomerArchetype.greedyFlipper, CustomerArchetype.impatientYouth],
      baseBonusPercent: 19,
      accentColor: Color(0xFFA855F7),
      category: 'speed',
      successDialogue: 'Masanın üstündeki kaporayı gören satıcının gözleri parladı • İlanı yayından kaldırdı!',
      failureDialogue: 'Satıcı • Kaporanın cazibesi güzel ama rakam kurtarmaz usta • dedi.',
      walkawayDialogue: 'Satıcı • Parayla beni aceleye getiremezsin! • Masayı terk etti.',
    ),
    EsnafTactic(
      id: 'agir_hasar_riski',
      title: 'Tramer Kaydı Baskısı',
      badgeText: 'Tramer Riski',
      description: 'Araçtaki tramer kayıtlarını masaya koyup ileride satarken değer kaybedeceğini vurgula.',
      iconKey: 'defect',
      context: TacticContext.buying,
      preferredArchetypes: [CustomerArchetype.skepticalOfficial, CustomerArchetype.familyMan],
      baseBonusPercent: 18,
      accentColor: Color(0xFFFF3366),
      category: 'defect',
      successDialogue: 'Tramer kayıtlarını tek tek sayınca satıcı tedirgin oldu • Fiyatı hemen aşağı çekti!',
      failureDialogue: 'Satıcı • Bu yaştaki arabada tramer normal usta • diyerek oralı olmadı.',
      walkawayDialogue: 'Satıcı • Trameri bahane edip malımı öldürme usta! • Masadan ayrıldı.',
    ),
    EsnafTactic(
      id: 'noter_kapanacak_acelesi',
      title: 'Noter Kapanıyor Telaşı',
      badgeText: 'Noter Telaşı',
      description: 'Mesai bitimine az kaldığını, anlaşılırsa hemen notere yetişileceğini söyleyip acele ettir.',
      iconKey: 'urgent',
      context: TacticContext.buying,
      preferredArchetypes: [CustomerArchetype.impatientYouth, CustomerArchetype.greedyFlipper],
      baseBonusPercent: 18,
      accentColor: Color(0xFFA855F7),
      category: 'speed',
      successDialogue: 'Noter kapanmadan devri bitirme telaşı satıcının inadını kırdı • Hemen evrakları topladı!',
      failureDialogue: 'Satıcı • Noter yarın da açık usta, aceleye gelmem • dedi.',
      walkawayDialogue: 'Satıcı • Beni yangından mal kaçırır gibi sıkıştırma! • Masadan kalktı.',
    ),
    EsnafTactic(
      id: 'kronik_ariza_bilgisi',
      title: 'Kronik Sorun Kartı',
      badgeText: 'Kronik Kusur',
      description: 'Bu kasanın şanzıman ve motor kronik arızalarını ezberden sayıp masraf riskini göster.',
      iconKey: 'mechanic',
      context: TacticContext.buying,
      preferredArchetypes: [CustomerArchetype.skepticalOfficial, CustomerArchetype.greedyFlipper],
      baseBonusPercent: 20,
      accentColor: Color(0xFFF97316),
      category: 'mechanic',
      successDialogue: 'Kronik dertleri teknik dille anlatınca satıcı terledi • Fiyatta büyük taviz verdi!',
      failureDialogue: 'Satıcı • İnternet hurafelerini bana anlatma usta, saat gibi çalışıyor • dedi.',
      walkawayDialogue: 'Satıcı • Arabamı kötüleyeceksen git başka yerden al! • Masayı terk etti.',
    ),
    EsnafTactic(
      id: 'hemsehri_muhabbeti',
      title: 'Hemşehri Muhabbeti',
      badgeText: 'Toprak Bağı',
      description: 'Memleket muhabbeti açıp aynı toprağın insanı olduğunuzu hatırlatarak ortamı ısıt.',
      iconKey: 'handshake',
      context: TacticContext.buying,
      preferredArchetypes: [CustomerArchetype.familyMan, CustomerArchetype.skepticalOfficial],
      baseBonusPercent: 15,
      accentColor: Color(0xFF38BDF8),
      category: 'diplomacy',
      successDialogue: 'Memleket bağı satıcının kalbini yumuşattı • "Hemşehriyiz, kırmayalım birbirimizi" dedi!',
      failureDialogue: 'Satıcı • Ticarette hemşehrilik sökmez usta, rakam net • diyerek taviz vermedi.',
      walkawayDialogue: 'Satıcı • Muhabbetle fiyat kırılmaz usta! • Masadan kalktı.',
    ),
    EsnafTactic(
      id: 'diger_ilana_gidiyorum',
      title: 'Rakip Galeri Blöfü',
      badgeText: 'Rakip İlan',
      description: 'Yan caddedeki galeride aynı modelin daha temizi için randevun olduğunu söyleyip blöf yap.',
      iconKey: 'market',
      context: TacticContext.buying,
      preferredArchetypes: [CustomerArchetype.greedyFlipper, CustomerArchetype.impatientYouth],
      baseBonusPercent: 18,
      accentColor: Color(0xFFFF3366),
      category: 'market',
      successDialogue: 'Müşteriyi rakibe kaptırmak istemeyen satıcı hemen yumuşadı • İndirimi kabul etti!',
      failureDialogue: 'Satıcı • Git oradan al o zaman usta, beni bağlamaz • dedi.',
      walkawayDialogue: 'Satıcı • Blöfün sökmez bana, kapı orada usta! • Masadan ayrıldı.',
    ),
    EsnafTactic(
      id: 'masraflari_boluselim',
      title: 'Bakım Masrafı Paylaşımı',
      badgeText: 'Masraf Payı',
      description: 'Gereken lastik ve periyodik bakım masraflarını listeleyip fiyattan yarı yarıya düşmeyi öner.',
      iconKey: 'notary',
      context: TacticContext.buying,
      preferredArchetypes: [CustomerArchetype.familyMan, CustomerArchetype.skepticalOfficial],
      baseBonusPercent: 17,
      accentColor: Color(0xFF00E575),
      category: 'diplomacy',
      successDialogue: 'Masraf paylaşımı satıcıya mantıklı geldi • "Haklısın usta, yarı yarıya kıralım" dedi!',
      failureDialogue: 'Satıcı • Masrafını da düşünerek bu fiyatı yazdım zaten • diyerek geri adım atmadı.',
      walkawayDialogue: 'Satıcı • Sıfır araba almıyorsun usta, masrafını bana yükleme! • Masadan kalktı.',
    ),
    EsnafTactic(
      id: 'galerici_gozuyle_bak',
      title: 'Esnaf Dayanışması',
      badgeText: 'Esnaf Duruşu',
      description: 'Biz de esnafız usta, sen de kazan biz de kazanalım, tezgâh dönsün diyerek esnaf payı iste.',
      iconKey: 'tok_seller',
      context: TacticContext.buying,
      preferredArchetypes: [CustomerArchetype.greedyFlipper, CustomerArchetype.impatientYouth],
      baseBonusPercent: 16,
      accentColor: Color(0xFFFFB703),
      category: 'firmness',
      successDialogue: 'Esnaf lisanından samimi yaklaşımın satıcının hoşuna gitti • Anlaşma sağlandı!',
      failureDialogue: 'Satıcı • Esnafsan sen de hakkını ver usta, bedavaya mal yok • dedi.',
      walkawayDialogue: 'Satıcı • Esnaflığı bana öğretme usta! • Masadan ayrıldı.',
    ),

    // --- SATIM TAKTİKLERİ (SELLING) ---
    // 1. ACİLİYET & BLÖF GRUBU (Vibrant Rose Red - 0xFFFF3366)
    EsnafTactic(
      id: 'baska_alici_var',
      title: 'Başka Alıcı Var Acelesi',
      badgeText: 'Aciliyet Blöfü',
      description: 'Öğleden sonra başka bir müşterinin kapora göndereceğini söyleyip elini çabuk tuttur.',
      iconKey: 'urgent',
      context: TacticContext.selling,
      preferredArchetypes: [CustomerArchetype.impatientYouth, CustomerArchetype.greedyFlipper],
      baseBonusPercent: 19,
      accentColor: Color(0xFFFF3366),
      category: 'bluff',
      successDialogue: 'Alıcı panikledi • "Kapora vermesin usta, ben hemen alıyorum" diyerek teklifini yukarı çekti!',
      failureDialogue: 'Alıcı • Nasipse o alsın usta, ben aceleye gelmem • diyerek blöfü yemedi.',
      walkawayDialogue: 'Alıcı • Madem başka alıcı var ona sat usta, ben çekiliyorum! • Masayı terk etti.',
    ),
    EsnafTactic(
      id: 'pazar_hareketli_blof',
      title: 'Hafta Sonu Pazarı Blöfü',
      badgeText: 'Piyasa Baskısı',
      description: 'Hafta sonu oto pazarına çekildiğinde bu fiyattan çok fazlasına gideceğini fısılda.',
      iconKey: 'market',
      context: TacticContext.selling,
      preferredArchetypes: [CustomerArchetype.greedyFlipper, CustomerArchetype.impatientYouth],
      baseBonusPercent: 18,
      accentColor: Color(0xFFFF3366),
      category: 'bluff',
      successDialogue: 'Piyasa fırsatını kaçırmak istemeyen alıcı acele etti • Teklifi hemen onayladı!',
      failureDialogue: 'Alıcı • Pazarda da bu paralara araba gitmiyor usta • diyerek blöfü boşa çıkardı.',
      walkawayDialogue: 'Alıcı • Götür pazarda sat o zaman usta, benden bu kadar! • Masadan ayrıldı.',
    ),
    EsnafTactic(
      id: 'son_fiyat_resti',
      title: 'Kırmızı Çizgi Resti',
      badgeText: 'Son Rakam',
      description: 'Fiyatın taban olduğunu, bu seviyenin altına tek kuruş inmeyeceğini hissettir.',
      iconKey: 'strike',
      context: TacticContext.selling,
      preferredArchetypes: [CustomerArchetype.impatientYouth, CustomerArchetype.greedyFlipper],
      baseBonusPercent: 20,
      accentColor: Color(0xFFFF3366),
      category: 'bluff',
      successDialogue: 'Net ve tavizsiz duruşun karşısında alıcı fırsatı kaçırmadı • "Tamam anlaştık" dedi!',
      failureDialogue: 'Alıcı • Sen inmezsen ben de çıkmam usta • diyerek direndi.',
      walkawayDialogue: 'Alıcı • Bu fiyatta diretirsen sana iyi satışlar usta! • Masayı terk etti.',
    ),

    // 2. PRESTİJ & TOK DURUŞ GRUBU (VIP Amber Altın - 0xFFFFB703)
    EsnafTactic(
      id: 'fiyat_sabit_tok',
      title: 'Tok Satıcı Duruşu',
      badgeText: 'Tok Duruş',
      description: 'Aracın arkasında durup kalitesine güvendiğini, aşağı inmeyeceğini hissettir.',
      iconKey: 'tok_seller',
      context: TacticContext.selling,
      preferredArchetypes: [CustomerArchetype.impatientYouth, CustomerArchetype.greedyFlipper],
      baseBonusPercent: 17,
      accentColor: Color(0xFFFFB703),
      category: 'prestige',
      successDialogue: 'Tok duruşun müşteriye aracın gerçekten temiz olduğunu hissettirdi • Fiyatı kabul etti!',
      failureDialogue: 'Müşteri • Sen tok satıcıysan ben de aceleci alıcı değilim usta • dedi.',
      walkawayDialogue: 'Müşteri • İnadınla bol kazançlar usta, başka galeriden bakarım! • Masadan ayrıldı.',
    ),
    EsnafTactic(
      id: 'emsalsiz_kondisyon',
      title: 'Emsalsiz Makine Övgüsü',
      badgeText: 'Kondisyon Övgüsü',
      description: 'Aracın motor performansını, duruşunu ve temizliğini öne çıkar.',
      iconKey: 'pristine',
      context: TacticContext.selling,
      preferredArchetypes: [CustomerArchetype.impatientYouth, CustomerArchetype.greedyFlipper],
      baseBonusPercent: 18,
      accentColor: Color(0xFFFFB703),
      category: 'prestige',
      successDialogue: 'Aracın detaylarını dinleyen alıcının gözleri parladı • Fiyat farkını seve seve kabul etti!',
      failureDialogue: 'Alıcı • Herkes kendi malını över usta, piyasa ortada • diyerek fiyatında diretti.',
      walkawayDialogue: 'Alıcı • Altın kaplama değil ya bu araba, abarttın iyice! • Masadan kalktı.',
    ),
    EsnafTactic(
      id: 'garaj_arabasi',
      title: 'Kapalı Garaj Hikayesi',
      badgeText: 'Garaj Aracı',
      description: 'Aracın kapalı garajda muhafaza edildiğini, yağmur kar görmediğini anlat.',
      iconKey: 'garage',
      context: TacticContext.selling,
      preferredArchetypes: [CustomerArchetype.skepticalOfficial, CustomerArchetype.familyMan],
      baseBonusPercent: 19,
      accentColor: Color(0xFFFFB703),
      category: 'prestige',
      successDialogue: 'Garaj hikayesi alıcının aklına yattı • "Böyle bakımlısını bulmak zor" diyerek teklifini yükseltti!',
      failureDialogue: 'Alıcı • Garajda yatan arabanın da contası kurur usta • diyerek oralı olmadı.',
      walkawayDialogue: 'Alıcı • Garaj hikayeleriyle beni kandıramazsın usta! • Masadan ayrıldı.',
    ),
    EsnafTactic(
      id: 'koleksiyonluk_temizlik',
      title: 'Fabrika Kondisyonu',
      badgeText: 'Koleksiyon Değeri',
      description: 'Koltuk döşemelerinin, konsolun ve motor sesinin ilk günkü diriliğini gözler önüne ser.',
      iconKey: 'diamond',
      context: TacticContext.selling,
      preferredArchetypes: [CustomerArchetype.impatientYouth, CustomerArchetype.skepticalOfficial],
      baseBonusPercent: 20,
      accentColor: Color(0xFFFFB703),
      category: 'prestige',
      successDialogue: 'Aracın fabrika temizliği alıcıyı büyüledi • "Böylesi piyasada yok" diyerek kabul etti!',
      failureDialogue: 'Alıcı • Temiz ama nihayetinde kullanılmış araç usta • dedi.',
      walkawayDialogue: 'Alıcı • Sıfır araba muamelesi yapma usta, vazgeçtim! • Masadan kalktı.',
    ),

    // 3. ŞEFFAFLIK & GÜVEN GRUBU (Neon Zümrüt Yeşili - 0xFF00E575)
    EsnafTactic(
      id: 'expertiz_guvencesi',
      title: 'Şeffaf Kurumsal Ekspertiz',
      badgeText: 'Ekspertiz Raporu',
      description: 'Tüm mekanik ve kaporta raporunu açıkça sunup sıfır şüphe bırak.',
      iconKey: 'expert',
      context: TacticContext.selling,
      preferredArchetypes: [CustomerArchetype.skepticalOfficial, CustomerArchetype.familyMan],
      baseBonusPercent: 20,
      accentColor: Color(0xFF00E575),
      category: 'trust',
      successDialogue: 'Şeffaf ekspertiz raporu alıcının tüm korkularını sildi • Hemen el sıkışıldı!',
      failureDialogue: 'Alıcı • Rapor iyi güzel ama bütçem bu kadar usta • diyerek teklifini korudu.',
      walkawayDialogue: 'Alıcı • Raporla göz boyama usta, bu fiyat mantıksız! • Masayı terk etti.',
    ),
    EsnafTactic(
      id: 'ustani_al_gel_resti',
      title: 'Ustanı Al Gel Resti',
      badgeText: 'Hodri Meydan',
      description: 'İstediğin ustaya servise göster, en ufak masrafta bedelini üstlenirim de.',
      iconKey: 'mechanic',
      context: TacticContext.selling,
      preferredArchetypes: [CustomerArchetype.skepticalOfficial, CustomerArchetype.familyMan],
      baseBonusPercent: 21,
      accentColor: Color(0xFF00E575),
      category: 'trust',
      successDialogue: 'Özgüvenli restin alıcının kafasındaki tüm soru işaretlerini sildi • Hemen el sıkıştı!',
      failureDialogue: 'Alıcı • Ustaya götürsek kim bilir neler çıkar usta • diyerek temkinli yaklaştı.',
      walkawayDialogue: 'Alıcı • Rest çekerek araba satamazsın usta! • Masadan kalktı.',
    ),
    EsnafTactic(
      id: 'dosta_gider_kefalet',
      title: 'Dosta Gider Kefaleti',
      badgeText: 'Esnaf Namusu',
      description: 'Kendi bindiğim araç gibi kefilim, en ufak sıkıntıda anahtarı bana getir güvencesi ver.',
      iconKey: 'shield',
      context: TacticContext.selling,
      preferredArchetypes: [CustomerArchetype.familyMan, CustomerArchetype.skepticalOfficial],
      baseBonusPercent: 19,
      accentColor: Color(0xFF00E575),
      category: 'trust',
      successDialogue: 'Esnaf namusuna verilen kefalet alıcının gönlünü fethetti • Fiyatı memnuniyetle onayladı!',
      failureDialogue: 'Alıcı • Söz uçar yazı kalır usta, garanti belgesi vermiyorsun sonuçta • dedi.',
      walkawayDialogue: 'Alıcı • Tanımadığım adamın kefaletine güvenmem! • Masadan ayrıldı.',
    ),
    EsnafTactic(
      id: 'yedek_anahtar_kitapcik',
      title: 'Eksiksiz Çeyiz & Kitapçık',
      badgeText: 'Orijinal Evrak',
      description: 'Yedek anahtarı, servis faturaları ve orijinal kitapçıklarını masaya koy.',
      iconKey: 'key',
      context: TacticContext.selling,
      preferredArchetypes: [CustomerArchetype.skepticalOfficial, CustomerArchetype.familyMan],
      baseBonusPercent: 18,
      accentColor: Color(0xFF00E575),
      category: 'trust',
      successDialogue: 'Kusursuz dosya ve yedek anahtarlar alıcıya güven verdi • Masada anlaşma sağlandı!',
      failureDialogue: 'Alıcı • Kitapçık değil araba alıyoruz usta, fiyatta indirim yap • dedi.',
      walkawayDialogue: 'Alıcı • Masadaki kağıt kürekle göz boyama usta! • Masadan kalktı.',
    ),

    // 4. ESNAF DİPLOMASİSİ & JEST GRUBU (Canlı Gök Mavisi - 0xFF38BDF8)
    EsnafTactic(
      id: 'cay_soyle_satis',
      title: 'Tavşankanı Çay & İkram',
      badgeText: 'Esnaf Sohbeti',
      description: 'Müşteriye sıcacık çay ikram edip galericilik muhabbetiyle güven aşıla.',
      iconKey: 'tea',
      context: TacticContext.selling,
      preferredArchetypes: [CustomerArchetype.skepticalOfficial, CustomerArchetype.familyMan, CustomerArchetype.impatientYouth, CustomerArchetype.greedyFlipper],
      baseBonusPercent: 14,
      accentColor: Color(0xFF38BDF8),
      category: 'diplomacy',
      successDialogue: 'Sıcak çay eşliğinde kurulan esnaf diyaloğu müşterinin güvenini tazeledi!',
      failureDialogue: 'Müşteri • Çay için teşekkürler ama rakam hala yüksek usta • dedi.',
      walkawayDialogue: 'Müşteri • Laf kalabalığına karnım tok, satmıyorsan gidiyorum! • Masadan ayrıldı.',
    ),
    EsnafTactic(
      id: 'dost_isi_ikram',
      title: 'Dost İşi Noter İkramı',
      badgeText: 'Esnaf Jesti',
      description: 'Noter masrafını ve ilk depo yakıtı üstlenerek karşı teklifini tatlandır.',
      iconKey: 'notary',
      context: TacticContext.selling,
      preferredArchetypes: [CustomerArchetype.familyMan, CustomerArchetype.skepticalOfficial],
      baseBonusPercent: 16,
      accentColor: Color(0xFF38BDF8),
      category: 'diplomacy',
      successDialogue: 'Yaptığın samimi jest alıcının gönlünü fethetti • "Helali hoş olsun usta" diyerek anlaştı!',
      failureDialogue: 'Alıcı • Bir depo benzinle göz boyama usta, fiyattan düş • dedi.',
      walkawayDialogue: 'Alıcı • Küçük hesaplarla beni oyalama usta! • Masayı terk etti.',
    ),
    EsnafTactic(
      id: 'maliyetine_birakiyorum',
      title: 'Maliyetine Esnaf Devri',
      badgeText: 'Zararına Satış',
      description: 'Bize de bu fiyata mal olduğunu, kâr gözetmeden tezgâh dönsün diye verdiğini belirt.',
      iconKey: 'handshake',
      context: TacticContext.selling,
      preferredArchetypes: [CustomerArchetype.familyMan, CustomerArchetype.greedyFlipper],
      baseBonusPercent: 17,
      accentColor: Color(0xFF38BDF8),
      category: 'diplomacy',
      successDialogue: 'Esnaf fedakarlığın alıcıyı etkiledi • "Helal olsun usta, tezgâhın dönsün" diyerek kabul etti!',
      failureDialogue: 'Alıcı • Her esnaf aynı şeyi söyler usta, fiyata odaklanalım • dedi.',
      walkawayDialogue: 'Alıcı • Esnaf edebiyatı dinlemeye gelmedim usta! • Masayı terk etti.',
    ),
    EsnafTactic(
      id: 'pesin_noter_harci',
      title: 'Noter Harcı & Çorba İkramı',
      badgeText: 'Tatlı Uzlaşma',
      description: 'Rakamı kırmadan noter masrafını ve esnaf lokantasında öğle yemeğini üstlen.',
      iconKey: 'gift',
      context: TacticContext.selling,
      preferredArchetypes: [CustomerArchetype.familyMan, CustomerArchetype.greedyFlipper],
      baseBonusPercent: 16,
      accentColor: Color(0xFF38BDF8),
      category: 'diplomacy',
      successDialogue: 'Güler yüzlü esnaf ikramı masadaki gerginliği bitirdi • Tatlıya bağlandı!',
      failureDialogue: 'Alıcı • Çorbayla noterle olmuyor usta, fiyattan biraz daha kır • dedi.',
      walkawayDialogue: 'Alıcı • Çorba parasıyla pazarlık mı kapatılır usta! • Masadan ayrıldı.',
    ),

    // 5. HIZ & DEVİR GRUBU (Hızlı Devir Moru - 0xFFA855F7)
    EsnafTactic(
      id: 'hizli_teslimat',
      title: 'Hemen Noter & Teslimat',
      badgeText: 'Hızlı Devir',
      description: 'Ruhsatı ve anahtarları masaya koyup 15 dakikada devir garantisi ver.',
      iconKey: 'urgent',
      context: TacticContext.selling,
      preferredArchetypes: [CustomerArchetype.greedyFlipper, CustomerArchetype.impatientYouth],
      baseBonusPercent: 18,
      accentColor: Color(0xFFA855F7),
      category: 'speed',
      successDialogue: 'Hızlı teslimat teklifin acelesi olan alıcının tam aradığı fırsat oldu!',
      failureDialogue: 'Alıcı • Hız önemli ama para daha önemli usta, indirim yap • dedi.',
      walkawayDialogue: 'Alıcı • Beni aceleye getirip sıkıştırma usta! • Masadan ayrıldı.',
    ),
  ];

  /// Generates 3 contextual esnaf tactics dynamically based on role, car condition, customer archetype, and offer seed
  static List<EsnafTactic> generateTactics({
    required bool isBuying,
    required CarModel car,
    CustomerModel? customer,
    required double price,
    String? offerId,
  }) {
    final targetContext = isBuying ? TacticContext.buying : TacticContext.selling;
    final candidates = allTactics.where((t) => t.context == targetContext || t.context == TacticContext.both).toList();

    // Deterministic seed for variance across different offers on the same vehicle
    final int seed = offerId != null
        ? (offerId.hashCode.abs() + (customer?.name.hashCode.abs() ?? 0) * 31)
        : (car.id.hashCode.abs() + (customer?.name.hashCode.abs() ?? 0) * 31);

    // Score candidates based on customer archetype, car condition, price, and dynamic seed
    final scored = candidates.map((tactic) {
      int score = 15;

      // 1. Archetype Match (+20)
      if (customer != null && tactic.preferredArchetypes.contains(customer.archetype)) {
        score += 20;
      }

      // 2. Car Condition Alignment
      final hasDamagedParts = car.expertise.bodyParts.values.any(
        (st) => st == PartStatus.painted || st == PartStatus.changed || st == PartStatus.damaged,
      );
      if (isBuying) {
        if (tactic.id == 'ekspertiz_kusuru' && (hasDamagedParts || car.expertise.mileage > 150000)) {
          score += 35;
        }
        if (tactic.id == 'agir_hasar_riski' && (car.expertise.tramerAmount > 10000 || hasDamagedParts)) {
          score += 32;
        }
        if (tactic.id == 'kronik_ariza_bilgisi' && (car.expertise.engineCondition < 80 || car.modelYear < 2014)) {
          score += 28;
        }
        if (tactic.id == 'usta_cagir' && (car.expertise.engineCondition < 75 || car.modelYear < 2012)) {
          score += 26;
        }
        if ((tactic.id == 'nakit_goster' || tactic.id == 'cebindeki_son_nakit') && price < 450000) {
          score += 22;
        }
        if ((tactic.id == 'kaporayi_vereyim_hemen' || tactic.id == 'noter_kapanacak_acelesi') &&
            (customer?.archetype == CustomerArchetype.impatientYouth || customer?.archetype == CustomerArchetype.greedyFlipper)) {
          score += 24;
        }
        if ((tactic.id == 'hemsehri_muhabbeti' || tactic.id == 'masraflari_boluselim') &&
            (customer?.archetype == CustomerArchetype.familyMan || customer?.archetype == CustomerArchetype.skepticalOfficial)) {
          score += 22;
        }
        if ((tactic.id == 'diger_ilana_gidiyorum' || tactic.id == 'galerici_gozuyle_bak') &&
            (customer?.archetype == CustomerArchetype.greedyFlipper || customer?.archetype == CustomerArchetype.impatientYouth)) {
          score += 24;
        }
      } else {
        if ((tactic.id == 'emsalsiz_kondisyon' || tactic.id == 'garaj_arabasi' || tactic.id == 'koleksiyonluk_temizlik') &&
            (car.isPristineOriginal || car.isPolished || car.isRare || car.expertise.mileage < 70000)) {
          score += 28;
        }
        if ((tactic.id == 'expertiz_guvencesi' || tactic.id == 'ustani_al_gel_resti' || tactic.id == 'dosta_gider_kefalet') &&
            (car.isPristineOriginal || car.expertise.engineCondition >= 80)) {
          score += 24;
        }
        if ((tactic.id == 'baska_alici_var' || tactic.id == 'pazar_hareketli_blof' || tactic.id == 'son_fiyat_resti') &&
            (car.estimatedRealValue > 400000 || customer?.archetype == CustomerArchetype.impatientYouth)) {
          score += 20;
        }
        if ((tactic.id == 'maliyetine_birakiyorum' || tactic.id == 'dost_isi_ikram' || tactic.id == 'pesin_noter_harci') &&
            (customer?.archetype == CustomerArchetype.familyMan || customer?.archetype == CustomerArchetype.greedyFlipper)) {
          score += 22;
        }
      }

      // 3. Dynamic offer-specific variance to prevent repetitive identical sets across offers
      final dynamicSalt = (seed * 17 + tactic.id.hashCode.abs()) % 23;
      score += dynamicSalt;

      return MapEntry(tactic, score);
    }).toList();

    // Sort all scored candidates by score descending
    scored.sort((a, b) => b.value.compareTo(a.value));

    final selectedTactics = <EsnafTactic>[];
    final selectedCategories = <String>{};

    // 1. Pick top-scoring tactics from distinct categories (ensuring 3 diverse roles and vibrant colors)
    for (final entry in scored) {
      if (selectedTactics.length >= 3) break;
      if (!selectedCategories.contains(entry.key.category)) {
        selectedTactics.add(entry.key);
        selectedCategories.add(entry.key.category);
      }
    }

    // 2. Fallback: fill up to 3 tactics if fewer than 3 categories exist
    if (selectedTactics.length < 3) {
      for (final entry in scored) {
        if (selectedTactics.length >= 3) break;
        if (!selectedTactics.contains(entry.key)) {
          selectedTactics.add(entry.key);
        }
      }
    }

    return selectedTactics.take(3).toList();
  }

  /// Evaluates a dice-rolled tactic attempt with diminishing returns and walkaway risks
  static TacticRollOutcome rollTactic({
    required EsnafTactic tactic,
    required int tacticUsageIndex, // 0 for 1st card, 1 for 2nd card, 2 for 3rd card
    required int negotiationSkillLevel,
    required CarModel car,
    CustomerModel? customer,
    required bool isBuying,
    List<String> purchasedAcademyCourses = const [],
    bool isTraderSpecialization = false,
  }) {
    // 1. Base Success Threshold with Diminishing Returns
    int baseThreshold;
    if (tacticUsageIndex == 0) {
      baseThreshold = 75; // 1st Card: 75% base success
    } else if (tacticUsageIndex == 1) {
      baseThreshold = 50; // 2nd Card: 50% base success
    } else {
      baseThreshold = 30; // 3rd Card: 30% base success
    }

    // 2. Modifiers
    int threshold = baseThreshold + (negotiationSkillLevel * 3);
    if (customer != null && tactic.preferredArchetypes.contains(customer.archetype)) {
      threshold += 10;
    }
    if (purchasedAcademyCourses.contains('course_sales_master')) {
      threshold += 6;
    }
    if (isTraderSpecialization) {
      threshold += 8;
    }
    threshold = threshold.clamp(15, 95);

    // 3. Dice Roll (1 - 100)
    final roll = _random.nextInt(100) + 1;
    final bool isSuccess = roll <= threshold;

    if (isSuccess) {
      double bonusMultiplier = 1.0;
      if (tacticUsageIndex == 1) bonusMultiplier = 0.75;
      if (tacticUsageIndex >= 2) bonusMultiplier = 0.50;

      final int bonus = ((tactic.baseBonusPercent + (negotiationSkillLevel * 2)) * bonusMultiplier).round();
      final msg = tactic.getDynamicSuccessDialogue(_random);
      return TacticRollOutcome(
        isSuccess: true,
        isWalkaway: false,
        diceRoll: roll,
        threshold: threshold,
        bonusChance: bonus,
        message: '$msg • +%$bonus',
        tacticTitle: tactic.title,
      );
    }

    // 4. Failure & Walkaway Risk
    int walkawayRiskPercent = 0;
    if (tacticUsageIndex == 1) walkawayRiskPercent = 12;
    if (tacticUsageIndex >= 2) walkawayRiskPercent = 35;

    final walkawayRoll = _random.nextInt(100) + 1;
    final bool isWalkaway = walkawayRoll <= walkawayRiskPercent;

    if (isWalkaway) {
      return TacticRollOutcome(
        isSuccess: false,
        isWalkaway: true,
        diceRoll: roll,
        threshold: threshold,
        bonusChance: -15,
        message: tactic.getDynamicWalkawayDialogue(_random),
        tacticTitle: tactic.title,
      );
    }

    final int penalty = tacticUsageIndex == 0 ? -3 : (tacticUsageIndex == 1 ? -6 : -10);
    return TacticRollOutcome(
      isSuccess: false,
      isWalkaway: false,
      diceRoll: roll,
      threshold: threshold,
      bonusChance: penalty,
      message: '${tactic.getDynamicFailureDialogue(_random)} • $penalty%',
      tacticTitle: tactic.title,
    );
  }

  /// Legacy helper backwards-compatible wrapper
  static Map<String, dynamic> executeEsnafAction({
    required String actionType,
    required double currentOffer,
    required double askingPrice,
    required int negotiationSkillLevel,
  }) {
    final tactic = allTactics.firstWhere(
      (t) => t.id == actionType,
      orElse: () => allTactics.first,
    );
    final outcome = rollTactic(
      tactic: tactic,
      tacticUsageIndex: 0,
      negotiationSkillLevel: negotiationSkillLevel,
      car: CarModel(
        id: '',
        brand: '',
        modelName: '',
        modelYear: 2020,
        bodyType: '',
        colorHex: '#000000',
        baseMarketValue: askingPrice,
        currentPurchasePrice: askingPrice,
        expertise: ExpertiseReport(
          engineCondition: 100,
          transmissionCondition: 100,
          tramerAmount: 0,
          mileage: 100000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      ),
      isBuying: true,
    );

    return {
      'success': outcome.isSuccess,
      'isWalkaway': outcome.isWalkaway,
      'bonusChance': outcome.bonusChance,
      'priceShift': null,
      'message': outcome.message,
    };
  }

  /// Process counter-offer from player to buyer with strategic esnaf approaches (§1.1 & §2.4)
  static NegotiationOutcome evaluateCounterOffer({
    required OfferModel currentOffer,
    required double playerTargetPrice,
    required CarModel car,
    required int negotiationSkillLevel,
    double? dynamicMaxMultiplier,
    CustomerModel? customer,
    String? strategy, // 'ikna_et', 'duyguya_oyna', 'sert_dur', 'hizli_kapat', 'cay_soyle', 'sigara_yak', 'ortak_arayayim'
    List<String> purchasedAcademyCourses = const [],
    bool isTraderSpecialization = false,
    double lifestylePersuasionBonus = 0.0,
  }) {
    final double previousOffer = currentOffer.offeredAmount;
    final double carRealValue = car.estimatedRealValue;
    final activeCustomer = customer ?? currentOffer.buyerCustomer;
    final double declaredListingPrice = car.listingPrice > 0 ? car.listingPrice : (car.estimatedRealValue * 1.15);
    final double maxCeiling = dynamicMaxMultiplier ?? getDynamicCeilingMultiplier(car, offer: currentOffer);
    double strategyBonus = 0.0;
    // Input validation: Protect against NaN, Infinite, or non-positive values
    if (playerTargetPrice.isNaN ||
        !playerTargetPrice.isFinite ||
        playerTargetPrice <= 0) {
      return NegotiationOutcome(
        updatedOffer: currentOffer.copyWith(
            status: OfferStatus.rejected, counterStrategy: strategy),
        responseMessage:
            'Geçersiz bir teklif girdiniz • Lütfen geçerli bir rakam yazın.',
        isAccepted: false,
        isWalkaway: false,
      );
    }
    double walkawayModifier = 0.0;

    // Strict Rule: If counter offer is above the advertised listing sticker price, customer immediately rejects
    if (car.listingPrice > 0 && playerTargetPrice > car.listingPrice + 500) {
      final listedFormatted = CurrencyFormatter.format(car.listingPrice);
      final targetFormatted = CurrencyFormatter.format(playerTargetPrice);
      final msg = 'Alıcı şaşkınlıkla masadan kalktı! — "Usta camdaki ilana $listedFormatted yazmışsın, pazarlıkta benden $targetFormatted istiyorsun! Böyle ticaret olmaz."';
      return NegotiationOutcome(
        updatedOffer: currentOffer.copyWith(status: OfferStatus.rejected, counterStrategy: strategy),
        responseMessage: msg,
        isAccepted: false,
        isWalkaway: true,
      );
    }

    // Staff Academy & Specialization Trader Perks
    if (purchasedAcademyCourses.contains('course_sales_master')) {
      strategyBonus += 0.08;
    }
    if (isTraderSpecialization) {
      strategyBonus += 0.12;
    }

    final bool isHonestOrTruthful = car.declarationType == ListingDeclarationType.honest ||
        (car.declarationType == ListingDeclarationType.flawlessClaim && car.isPristineOriginal) ||
        (car.declarationType == ListingDeclarationType.minorFlawHidden && car.isPristineOriginal);

    if (strategy == 'ikna_et') {
      if (isHonestOrTruthful) {
        strategyBonus += (activeCustomer?.archetype == CustomerArchetype.familyMan || activeCustomer?.archetype == CustomerArchetype.skepticalOfficial) ? 0.16 : 0.10;
      } else {
        strategyBonus -= 0.12;
        walkawayModifier += 0.18;
      }
    } else if (strategy == 'baska_alici_var') {
      if (activeCustomer?.archetype == CustomerArchetype.impatientYouth || activeCustomer?.archetype == CustomerArchetype.greedyFlipper) {
        strategyBonus += 0.18;
      } else {
        strategyBonus += 0.06;
        walkawayModifier += 0.12;
      }
    } else if (strategy == 'pazar_hareketli_blof') {
      if (activeCustomer?.archetype == CustomerArchetype.greedyFlipper || activeCustomer?.archetype == CustomerArchetype.impatientYouth) {
        strategyBonus += 0.19;
      } else {
        walkawayModifier += 0.12;
      }
    } else if (strategy == 'son_fiyat_resti') {
      if (activeCustomer?.archetype == CustomerArchetype.impatientYouth || activeCustomer?.archetype == CustomerArchetype.greedyFlipper) {
        strategyBonus += 0.20;
      } else {
        walkawayModifier += 0.15;
      }
    } else if (strategy == 'emsalsiz_kondisyon') {
      if (activeCustomer?.archetype == CustomerArchetype.impatientYouth || car.isPristineOriginal) {
        strategyBonus += 0.20;
      } else {
        strategyBonus += 0.10;
      }
    } else if (strategy == 'garaj_arabasi') {
      if (car.expertise.mileage < 80000 || car.isPristineOriginal || car.isRare) {
        strategyBonus += 0.22;
      } else {
        strategyBonus += 0.10;
      }
    } else if (strategy == 'koleksiyonluk_temizlik') {
      if (car.isPristineOriginal || car.isRare || activeCustomer?.archetype == CustomerArchetype.impatientYouth) {
        strategyBonus += 0.22;
      } else {
        strategyBonus += 0.12;
      }
    } else if (strategy == 'dost_isi_ikram') {
      if (activeCustomer?.archetype == CustomerArchetype.familyMan || activeCustomer?.archetype == CustomerArchetype.skepticalOfficial) {
        strategyBonus += 0.16;
        walkawayModifier -= 0.10;
      } else {
        strategyBonus += 0.10;
      }
    } else if (strategy == 'maliyetine_birakiyorum') {
      if (activeCustomer?.archetype == CustomerArchetype.familyMan || activeCustomer?.archetype == CustomerArchetype.greedyFlipper) {
        strategyBonus += 0.18;
        walkawayModifier -= 0.08;
      } else {
        strategyBonus += 0.11;
      }
    } else if (strategy == 'pesin_noter_harci') {
      strategyBonus += 0.16;
      walkawayModifier -= 0.10;
    } else if (strategy == 'cay_soyle_satis' || strategy == 'cay_soyle') {
      strategyBonus += 0.14;
      walkawayModifier -= 0.14;
    } else if (strategy == 'fiyat_sabit_tok' || strategy == 'sert_dur') {
      if (activeCustomer?.archetype == CustomerArchetype.impatientYouth || activeCustomer?.archetype == CustomerArchetype.greedyFlipper) {
        strategyBonus += 0.15;
      } else {
        walkawayModifier += 0.16;
      }
    } else if (strategy == 'expertiz_guvencesi') {
      if (isHonestOrTruthful) {
        strategyBonus += (activeCustomer?.archetype == CustomerArchetype.familyMan || activeCustomer?.archetype == CustomerArchetype.skepticalOfficial) ? 0.20 : 0.12;
      } else {
        strategyBonus -= 0.12;
        walkawayModifier += 0.18;
      }
    } else if (strategy == 'ustani_al_gel_resti') {
      if (isHonestOrTruthful) {
        strategyBonus += (activeCustomer?.archetype == CustomerArchetype.skepticalOfficial) ? 0.24 : 0.17;
        walkawayModifier -= 0.12;
      } else {
        strategyBonus -= 0.15;
        walkawayModifier += 0.20;
      }
    } else if (strategy == 'dosta_gider_kefalet') {
      if (isHonestOrTruthful) {
        strategyBonus += (activeCustomer?.archetype == CustomerArchetype.familyMan || activeCustomer?.archetype == CustomerArchetype.skepticalOfficial) ? 0.21 : 0.14;
        walkawayModifier -= 0.10;
      } else {
        strategyBonus -= 0.10;
        walkawayModifier += 0.16;
      }
    } else if (strategy == 'yedek_anahtar_kitapcik') {
      if (activeCustomer?.archetype == CustomerArchetype.skepticalOfficial || activeCustomer?.archetype == CustomerArchetype.familyMan) {
        strategyBonus += 0.19;
        walkawayModifier -= 0.08;
      } else {
        strategyBonus += 0.12;
      }
    } else if (strategy == 'hizli_teslimat' || strategy == 'hizli_kapat') {
      strategyBonus += 0.16;
    } else if (strategy == 'sigara_yak') {
      strategyBonus += 0.12;
      walkawayModifier += 0.08;
    } else if (strategy == 'ortak_arayayim') {
      strategyBonus += 0.15;
    }

    // Diminishing returns on lifestyle persuasion bonus (soft cap at 6%)
    final double effectiveLifestyleBonus = (lifestylePersuasionBonus / (1.0 + lifestylePersuasionBonus * 2.0)).clamp(0.0, 0.06);
    double skillBonus = ((negotiationSkillLevel - 1) * 0.025) + strategyBonus + effectiveLifestyleBonus;
    double diffRatio = previousOffer > 0 ? (playerTargetPrice - previousOffer) / previousOffer : 0.0;

    // Instant accept if player met or went below customer's offer
    if (playerTargetPrice <= previousOffer) {
      final msg = _getAcceptedMessage(activeCustomer?.archetype, playerTargetPrice);
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

    // Tough archetype modifiers
    double archetypeAcceptModifier = switch (activeCustomer?.archetype) {
      CustomerArchetype.greedyFlipper => -0.28,
      CustomerArchetype.skepticalOfficial => -0.22,
      CustomerArchetype.familyMan => -0.14,
      CustomerArchetype.impatientYouth => 0.06,
      _ => -0.10,
    };

    // 1. Direct Acceptance on Small Step (<3.5% gap)
    if (diffRatio <= 0.035 + (skillBonus * 0.4)) {
      double acceptChance = (0.35 + skillBonus + archetypeAcceptModifier).clamp(0.08, 0.75);
      if (_random.nextDouble() < acceptChance) {
        final msg = _getAcceptedMessage(activeCustomer?.archetype, playerTargetPrice);
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

    // 2. High Outrage Walkaway Threshold (Asking >22% higher or asking above dynamic ceiling)
    final bool isExtremeDiff = diffRatio > 0.35 || playerTargetPrice > carRealValue * (maxCeiling + 0.05);
    if (isExtremeDiff) {
      final msg = _getWalkawayMessage(activeCustomer?.archetype, diffFormatted, isExtreme: true);
      return NegotiationOutcome(
        updatedOffer: currentOffer.copyWith(status: OfferStatus.rejected, counterStrategy: strategy),
        responseMessage: msg,
        isAccepted: false,
        isWalkaway: true,
      );
    }

    // 3. Moderate Resistance Walkaway Check (Asking >16% higher or nearing ceiling)
    final double walkawayThreshold = (0.18 - walkawayModifier).clamp(0.08, 0.35);
    if (diffRatio > walkawayThreshold || playerTargetPrice > carRealValue * maxCeiling) {
      double walkawayChance = (0.38 - (skillBonus * 0.6) + (currentOffer.counterCount * 0.15)).clamp(0.10, 0.80);
      if (_random.nextDouble() < walkawayChance) {
        final msg = _getWalkawayMessage(activeCustomer?.archetype, diffFormatted, isExtreme: false);
        return NegotiationOutcome(
          updatedOffer: currentOffer.copyWith(status: OfferStatus.rejected, counterStrategy: strategy),
          responseMessage: msg,
          isAccepted: false,
          isWalkaway: true,
        );
      }
    }

    // 4. Buyer makes a realistic, tight incremental step (20% - 35% of the requested gap)
    double stepFraction = (0.20 + (_random.nextDouble() * 0.15) + (skillBonus * 0.35)).clamp(0.10, 0.50);
    double buyerNewOffer = (previousOffer + (playerTargetPrice - previousOffer) * stepFraction).roundToDouble();

    // Clamp by declared listing price and vehicle dynamic ceiling
    if (buyerNewOffer > declaredListingPrice) {
      buyerNewOffer = declaredListingPrice;
    }
    if (buyerNewOffer > carRealValue * maxCeiling) {
      buyerNewOffer = (carRealValue * maxCeiling).roundToDouble();
    }

    // Ensure step moves forward at least ₺1.000 if gap allows
    if (buyerNewOffer <= previousOffer && playerTargetPrice > previousOffer) {
      buyerNewOffer = min(playerTargetPrice, previousOffer + 1000);
    }

    int newCount = currentOffer.counterCount + 1;

    if (newCount >= currentOffer.maxCounters) {
      // Max counters reached -> Buyer gives final ultimatum offer
      final msg = _getFinalOfferMessage(activeCustomer?.archetype, buyerNewOffer);
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

    final msg = _getMiddleCounterMessage(activeCustomer?.archetype, buyerNewOffer, playerTargetPrice);
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
    final priceStr = CurrencyFormatter.format(price);
    final options = switch (archetype) {
      CustomerArchetype.skepticalOfficial => [
        'Anlaştık ustam. $priceStr memur bütçeme uydu, evrakları hazırlayıp notere geçelim.',
        'Hayırlı olsun. Ekspertizdeki şeffaflık ve dürüstlüğün için teşekkür ederim, $priceStr kabulümdür.',
        'Kafamdaki soru işaretleri giderildi. $priceStr nakit devir için bankadan parayı çekiyorum.',
        'Dürüst esnaflık kalmamış derlerdi, helal olsun. $priceStr fiyata anlaştık.',
      ],
      CustomerArchetype.impatientYouth => [
        'Tamamdır usta! $priceStr fiyata makine benimdir, hemen notere geçip anahtarı alayım!',
        'Reis adamsın! $priceStr saydım gitti, bu akşam sahil turunda gazlıyoruz!',
        'Harika rakam, el sıkıştık say! Yarın ilk iş jant ve egzoz siparişini veriyorum.',
        'Helal olsun usta, kırmadın bizi! $priceStr nakit hemen hesaba geçiyorum.',
      ],
      CustomerArchetype.greedyFlipper => [
        'Kurtardı esnafım. Bize de üç kuruş ekmek bıraktın, $priceStr peşin hesaba geçiyorum.',
        'Tamamdır usta, esnaf esnafı kırmaz. $priceStr deste masada, çekiciyi yanaştırıyorum.',
        'Peki usta, aramızda kalsın bu rakam. Hemen notere geçip satışı verelim.',
        'İki esnaf helalleştik. $priceStr nakit çalışır, hayırlı bereketli olsun.',
      ],
      _ => [
        'Anlaştık ustam! $priceStr aile bütçemize uydu, Allah utandırmasın hayırlı olsun.',
        'Güzel samimi ticaret oldu. $priceStr nakit devir için notere geçebiliriz.',
        'İkna oldum, esnaflığın ve ikramın için sağ ol. $priceStr fiyata el sıkışalım.',
        'Çoluk çocuk çok beğendi arabayı. $priceStr helali hoş olsun, devri alalım.',
      ],
    };
    return options[_random.nextInt(options.length)];
  }

  static String _getWalkawayMessage(CustomerArchetype? archetype, String diff, {required bool isExtreme}) {
    if (isExtreme) {
      final options = switch (archetype) {
        CustomerArchetype.skepticalOfficial => [
          'Alıcı $diff aşırı farkı görünce çantasını topladı: — "Bu paraya bayiden sıfır araç bakarım usta, hayırlı işler."',
          'Memur bey $diff uçurum farkı duyunca evrakları masaya bıraktı: — "Piyasa rayicinin çok üstünde, benim bütçemi aşar."',
          'Alıcı şaşkınlıkla masadan kalktı: — "Biz buraya ciddi araç almaya geldik ama bu rakam akıl kârı değil."',
        ],
        CustomerArchetype.impatientYouth => [
          'Genç alıcı $diff farkı duyunca rest çekti: — "Reis o paraya üst kasa turbolu makine alırım, kolay gelsin!"',
          'Alıcı kapıyı çarpıp çıktı: — "Bu fiyata satamazsın kral, altın kaplama sanki!"',
          'Genç hevesle gelmişti ama $diff farkı görünce vazgeçti: — "Sanayide sıfırdan toplasam bu kadar tutmaz."',
        ],
        CustomerArchetype.greedyFlipper => [
          'Al-satçı esnaf $diff farkı görünce güldü: — "Bize hiç ekmek bırakmadın usta, bu fiyata müşteri bulursan bana da haber et."',
          'Galerici $diff fark yüzünden masadan kalktı: — "Piyasa durgun diyoruz sen liste fiyatının üstüne çıkıyorsun, kurtarmaz."',
          'Esnaf çayını yarıda bıraktı: — "Böyle ticaret olmaz usta, piyasada nakit dönen tek adamım yine de kurtarmıyor."',
        ],
        _ => [
          'Alıcı $diff fark yüzünden masadan kalktı: — "Bütçemi fazlasıyla aşıyor, başka arabalara bakacağım."',
          'Müşteri $diff fiyat farkını görünce teşekkür edip ayrıldı: — "Bu rakam ailemizi aşar ustam."',
          'Alıcı pazarlığı bitirdi: — "Fiyat çok şişirilmiş, piyasada daha uygun emsalleri var."',
        ],
      };
      return options[_random.nextInt(options.length)];
    }

    final options = switch (archetype) {
      CustomerArchetype.skepticalOfficial => [
        'Alıcı $diff fark yüzünden tereddüt etti ve vazgeçti: — "Hesaplarıma uymadı, kısmet değilmiş."',
        'Alıcı masadan kalktı: — "Maaşımın üstünde bir fark, riske giremem usta."',
      ],
      CustomerArchetype.impatientYouth => [
        'Genç alıcı $diff farkı karşılayamadığı için ayrıldı: — "Cebimdeki limit bu kadardı usta, nasip."',
        'Alıcı başka ilana yöneldi: — "Bütçem yetmiyor kral, başka araba bakacağım."',
      ],
      CustomerArchetype.greedyFlipper => [
        'Al-satçı $diff fark yüzünden masadan kalktı: — "Marj kalmadı esnafım, dükkana koyamam bu fiyata."',
        'Esnaf kafasını salladı: — "Zararına araba bağlayamam, hayırlı pazarlar."',
      ],
      _ => [
        'Alıcı $diff farkla masadan kalktı: — "Bütçemi aştı, biraz daha birikim yapıp bakayım."',
        'Müşteri $diff fark yüzünden anlaşamadı ve ayrıldı: — "Hayırlı müşteriler usta."',
      ],
    };
    return options[_random.nextInt(options.length)];
  }

  static String _getMiddleCounterMessage(CustomerArchetype? archetype, double buyerOffer, double targetPrice) {
    final buyerStr = CurrencyFormatter.format(buyerOffer);
    final targetStr = CurrencyFormatter.format(targetPrice);
    final options = switch (archetype) {
      CustomerArchetype.skepticalOfficial => [
        '$targetStr memur maaşımı aşıyor usta. Ekspertiz raporunu inceledim, bütçemi zorlayıp $buyerStr verebilirim.',
        'Maaş hesabımı ve kışlık bakım masraflarını hesapladım. En son $buyerStr nakit ödeyebilirim, ne dersin?',
        'Triger seti ve lastik masrafını da üstüme alıyorum. $buyerStr peşin vereyim, el sıkışalım.',
      ],
      CustomerArchetype.impatientYouth => [
        'Usta $targetStr beni çok zorlar. Kredi kartı nakit avansını da ekleyip $buyerStr yapayım, bitirelim bu işi!',
        'Arabayı çok tuttum ama param $buyerStr kadar çıkıyor. Orta yolu bulalım, bu akşam notere geçelim.',
        'Reis kırma beni, $buyerStr hazır sayıyorum hemen devri alayım!',
      ],
      CustomerArchetype.greedyFlipper => [
        'Esnafım $targetStr kurtarmaz, dükkanda yatar bu araba. Ben de ekmek yiyeceğim, $buyerStr peşin deste masada.',
        'Piyasada nakit dönmüyor usta. Bana $buyerStr bırakırsan yarım saate noterde devri alırız.',
        'Biz de esnafız usta, $buyerStr nakit çalışır. İşine gelirse çekiciyi çağırayım.',
      ],
      _ => [
        '$targetStr bütçemizi biraz aşıyor ama ailemiz çok beğendi. Bütçemizi zorlayıp $buyerStr verebiliriz.',
        'Çocukların okul masrafı var usta. $buyerStr nakit denkleştirdik, uyarsa hayrını görelim.',
        'Temizliğine güvendik geldik. $buyerStr peşin verelim, helalleşelim.',
      ],
    };
    return options[_random.nextInt(options.length)];
  }

  static String _getFinalOfferMessage(CustomerArchetype? archetype, double buyerOffer) {
    final buyerStr = CurrencyFormatter.format(buyerOffer);
    final options = switch (archetype) {
      CustomerArchetype.skepticalOfficial => [
        'Ustam son sözüm $buyerStr. Üstüne bir kuruş dahi çıkamam, kabul ediyorsan notere geçelim.',
        'Memur bütçemin son damlası $buyerStr. Uymazsa başka araca bakacağım, karar senin.',
      ],
      CustomerArchetype.impatientYouth => [
        'Reis cebimdeki son kuruş $buyerStr! Veriyorsan ver, vermiyorsan başka kasaya bakacağım.',
        'Son teklifim $buyerStr nakit kral. Anahtarı veriyorsan hemen alayım, yoksa masadan kalkıyorum.',
      ],
      CustomerArchetype.greedyFlipper => [
        'Esnafım son limitim $buyerStr. Deste nakit masada, verdin verdin vermedin araba sende kalır.',
        'Bu paraya başkası almaz usta, son teklifim $buyerStr. Kararını ver.',
      ],
      _ => [
        'Ustam ailece bütçemizin son sınırı $buyerStr. Kabul edersen el sıkışalım, yoksa nasip değilmiş deriz.',
        'Son teklifimiz $buyerStr peşin. Düşün taşın, karar senin ustam.',
      ],
    };
    return options[_random.nextInt(options.length)];
  }

  /// Generates a bonus offer from a loyal returning customer (CRM feature)
  static OfferModel generateLoyalCustomerOffer({
    required CarModel car,
    required String customerName,
    int? currentDay,
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
      expiresOnDay: (currentDay ?? 1) + 2 + _random.nextInt(2),
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
