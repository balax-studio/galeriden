import 'dart:math';
import '../../core/utils/slot_text_composer.dart';
import '../../data/models/real_estate_category.dart';
import '../../data/models/real_estate_model.dart';

class RealEstateTactic {
  final String id;
  final String title;
  final String badgeText;
  final String description;
  final String iconKey;
  final int baseBonusPercent;
  final bool isRescue;
  final List<RealEstateSellerType> preferredSellerTypes;
  final List<RealEstateCategory> preferredCategories;
  final String successDialogue;
  final String failureDialogue;
  final String walkawayDialogue;

  const RealEstateTactic({
    required this.id,
    required this.title,
    required this.badgeText,
    required this.description,
    required this.iconKey,
    required this.baseBonusPercent,
    this.isRescue = false,
    this.preferredSellerTypes = const [],
    this.preferredCategories = const [],
    required this.successDialogue,
    required this.failureDialogue,
    required this.walkawayDialogue,
  });
}

class RealEstateTacticRollOutcome {
  final bool isSuccess;
  final bool isWalkaway;
  final int diceRoll;
  final int threshold;
  final int bonusChance;
  final String message;
  final String tacticTitle;
  final int patienceChange;

  const RealEstateTacticRollOutcome({
    required this.isSuccess,
    required this.isWalkaway,
    required this.diceRoll,
    required this.threshold,
    required this.bonusChance,
    required this.message,
    required this.tacticTitle,
    required this.patienceChange,
  });
}

class RealEstateDiscrepancyInfo {
  final bool hasDiscrepancy;
  final String key;
  final String title;
  final String description;
  final double extraDiscountPercent;

  const RealEstateDiscrepancyInfo({
    required this.hasDiscrepancy,
    required this.key,
    required this.title,
    required this.description,
    required this.extraDiscountPercent,
  });

  static const RealEstateDiscrepancyInfo clean = RealEstateDiscrepancyInfo(
    hasDiscrepancy: false,
    key: 'clean',
    title: 'Temiz Tapu Kaydı',
    description: 'Tapu ve belediye kayıtlarında herhangi bir haciz, şerh veya iskansızlık bulunmuyor.',
    extraDiscountPercent: 0.0,
  );
}

class RealEstateNegotiationOutcome {
  final double currentOfferedPrice;
  final String responseMessage;
  final bool isAccepted;
  final bool isWalkaway;
  final int updatedPatience;
  final RealEstateTacticRollOutcome? tacticOutcome;

  const RealEstateNegotiationOutcome({
    required this.currentOfferedPrice,
    required this.responseMessage,
    required this.isAccepted,
    required this.isWalkaway,
    required this.updatedPatience,
    this.tacticOutcome,
  });
}

class RealEstateNegotiationEngine {
  static final Random _random = Random();

  // --- REAL ESTATE ESNAF TACTICS POOL ---
  static const List<RealEstateTactic> allTactics = [
    RealEstateTactic(
      id: 'blokeli_cek',
      title: 'Blokeli Çek Masada',
      badgeText: 'Peşin Gücü',
      description: 'Banka blokeli çeki masaya koyup anında Web - Tapu randevusu almayı teklif et.',
      iconKey: 'check',
      baseBonusPercent: 22,
      preferredSellerTypes: [RealEstateSellerType.individual, RealEstateSellerType.agency],
      successDialogue: 'Banka blokeli çeki gören satıcı rahat bir nefes aldı • "Para hazırsa hemen Web - Tapu başvurusunu yapalım" dedi!',
      failureDialogue: 'Satıcı • Çek güvenli ama bu rakama mülkümü devretmem mümkün değil usta • diyerek tok durdu.',
      walkawayDialogue: 'Satıcı • Çekiniz cebinizde kalsın, benim mülküm kelepir değil! • Masayı terk etti.',
    ),
    RealEstateTactic(
      id: 'imar_kusuru',
      title: 'İmar ve Tapu Kusurunu Masaya Koy',
      badgeText: 'Hukuki Baskı',
      description: 'Mülkteki iskansızlık, hisseli tapu veya şerh kusurunu öne sürerek fiyatı aşağı çek.',
      iconKey: 'legal',
      baseBonusPercent: 24,
      preferredSellerTypes: [RealEstateSellerType.individual, RealEstateSellerType.agency],
      successDialogue: 'Belediye ve tapu kayıtlarındaki pürüzleri tek tek saydın • Satıcı köşeye sıkıştı ve indirimi kabul etti!',
      failureDialogue: 'Satıcı • Bu bölgedeki bütün binalar böyle kardeşim, bilerek alıyorsun • diyerek geri adım atmadı.',
      walkawayDialogue: 'Satıcı hiddetlendi • Kusur bulacaksan sıfır rezidans al beyefendi, pazarlık bitmiştir! • Görüşmeyi sonlandırdı.',
    ),
    RealEstateTactic(
      id: 'komisyonu_kir',
      title: 'Komisyonu Kır Emlakçı Bey',
      badgeText: 'Ofis Pazarlığı',
      description: 'Emlak danışmanına portföyün uzun süredir yattığını hatırlatıp komisyondan feragat etmesini iste.',
      iconKey: 'commission',
      baseBonusPercent: 20,
      preferredSellerTypes: [RealEstateSellerType.agency],
      successDialogue: 'Emlak danışmanı düşündü • "Portföy uzun süredir bekliyordu, benim komisyonumdan 1 puan düşelim, el sıkışalım" dedi!',
      failureDialogue: 'Emlakçı • Biz de bu ofisi çeviriyoruz kardeşim, resmi komisyon oranımız sabittir • dedi.',
      walkawayDialogue: 'Emlakçı sinirlendi • Emeğimize saygınız yoksa başka emlak ofisleriyle çalışın! • Evrakları topladı.',
    ),
    RealEstateTactic(
      id: 'yuksek_faiz',
      title: 'Yüksek Faiz Resti',
      badgeText: 'Piyasa Gerçeği',
      description: 'Konut kredisi faizlerinin uçtuğunu ve nakit alıcının bulunmadığı bu dönemde fırsatı kaçırmamasını söyle.',
      iconKey: 'interest',
      baseBonusPercent: 18,
      preferredSellerTypes: [RealEstateSellerType.individual, RealEstateSellerType.bankAuction],
      successDialogue: 'Piyasa gerçekleri satıcının aklına yattı • "Haklısın, krediler kapalıyken nakit alıcıyı kaçırmayayım" dedi!',
      failureDialogue: 'Satıcı • Faizler yüksekse gayrimenkulün kıymeti daha da artar, acil satılık değilim • diyerek direndi.',
      walkawayDialogue: 'Satıcı • Benim paraya ihtiyacım yok, faiz düşene kadar kiraya veririm! • Masadan kalktı.',
    ),
    RealEstateTactic(
      id: 'tapu_harci_bolus',
      title: 'Tapu Harcını Bölüşelim',
      badgeText: 'Maliyet Paylaşımı',
      description: 'Yüzde 4 tapu harcının ve döner sermaye bedelinin fiyattan mahsup edilmesini talep et.',
      iconKey: 'deed',
      baseBonusPercent: 16,
      preferredSellerTypes: [RealEstateSellerType.individual, RealEstateSellerType.agency],
      successDialogue: 'Satıcı harç yükünün adil paylaşılmasını makul buldu • Toplam maliyet avantajı sağlandı!',
      failureDialogue: 'Satıcı • Teamül gereği masraflar alıcıya aittir, harca karışmam • diyerek reddetti.',
      walkawayDialogue: 'Satıcı • Ufak harçların hesabını yapıyorsan gayrimenkul alma kardeşim! • Masayı terk etti.',
    ),
    RealEstateTactic(
      id: 'sozlesme_kahvesi',
      title: 'Sözleşme Kahvesi & Kapora',
      badgeText: 'Kurtarma Hamlesi',
      description: 'Masadan kalkmak üzere olan satıcıya sıcak kahve ikram edip hemen 50.000 ₺ kapora teklif ederek sabrı toparla.',
      iconKey: 'coffee',
      baseBonusPercent: 15,
      isRescue: true,
      preferredSellerTypes: [RealEstateSellerType.individual, RealEstateSellerType.agency, RealEstateSellerType.bankAuction],
      successDialogue: 'Köpüklü Türk kahvesi eşliğinde kapora sözleşmesi açıldı • Satıcının gerginliği tamamen dağıldı ve masaya geri oturdu!',
      failureDialogue: 'Satıcı kahveyi yudumladı ama • Kahveniz güzelmiş lakin bu fiyata imza atmam • dedi.',
      walkawayDialogue: 'Satıcı • Kahveyle aklımı çelemezsin, niyetin ciddiyetsiz! • Çantasını alıp çıktı.',
    ),
    RealEstateTactic(
      id: 'arsa_imar_taks',
      title: 'İmar Planı ve TAKS - KAKS Analizi',
      badgeText: 'Emsal Baskısı',
      description: 'Arsanın çekme mesafelerini ve taban alanı katsayısını öne sürerek metrekare birim fiyatını kır.',
      iconKey: 'terrain',
      baseBonusPercent: 24,
      preferredCategories: [RealEstateCategory.land],
      preferredSellerTypes: [RealEstateSellerType.individual, RealEstateSellerType.agency],
      successDialogue: 'İmar katsayıları ve emsal sınırlamalarını belgeleriyle sundun • Satıcı metrekarede indirimi kabul etti!',
      failureDialogue: 'Satıcı • Bu arsanın önünden bulvar geçecek, emsal artışı eli kulağında • diyerek fiyatını savundu.',
      walkawayDialogue: 'Satıcı • İmarı bahane edip kupon arsayı öldüremezsin! • Masayı terk etti.',
    ),
    RealEstateTactic(
      id: 'ticari_tabela_ciro',
      title: 'Stopaj ve Tabela Değeri İskontosu',
      badgeText: 'Ticari Rayiç',
      description: 'Dükkanın cadde cephesini ve yıllık stopaj maliyetini masaya koyarak fiyatı aşağı çek.',
      iconKey: 'store',
      baseBonusPercent: 22,
      preferredCategories: [RealEstateCategory.commercial],
      preferredSellerTypes: [RealEstateSellerType.individual, RealEstateSellerType.agency],
      successDialogue: 'Stopaj yükü ve ticari amortisman hesabını gören dükkan sahibi • "Esnaf adamsın, fiyatta jest yapıyorum" dedi!',
      failureDialogue: 'Satıcı • Burası ana cadde üstü dükkan, tabela değerini kimse inkar edemez • diyerek geri adım atmadı.',
      walkawayDialogue: 'Satıcı • Cadde dükkanını ara sokak fiyatına isteyenle işim olmaz! • Çekip gitti.',
    ),
    RealEstateTactic(
      id: 'plaza_amortisman',
      title: 'Kira Çarpanı ve Amortisman Hesabı',
      badgeText: 'Kurumsal Getiri',
      description: 'Plazanın 15 yılı aşan yatırım geri dönüş süresini ve ortak gider yükünü pazarlık kozu yap.',
      iconKey: 'apartment',
      baseBonusPercent: 25,
      preferredCategories: [RealEstateCategory.building],
      preferredSellerTypes: [RealEstateSellerType.individual, RealEstateSellerType.agency, RealEstateSellerType.bankAuction],
      successDialogue: 'Finansal amortisman raporunu gören plaza temsilcisi • "Kurumsal alıcı hatrına fiyatta revizyona gidiyoruz" dedi!',
      failureDialogue: 'Satıcı • Binamız plaza standartlarında ve kurumsal kiracılıdır, amortismanı taş gibidir • dedi.',
      walkawayDialogue: 'Satıcı • Koskoca plazayı apartman dairesi gibi pazarlık edemezsiniz! • Görüşmeyi sonlandırdı.',
    ),
    RealEstateTactic(
      id: 'konut_aidat_kredi',
      title: 'Konut Kredisi ve Site Aidat Yükü',
      badgeText: 'Yaşam Maliyeti',
      description: 'Yüksek konut kredisi faizlerini ve aylık site aidatlarını öne sürerek fiyatta esneklik iste.',
      iconKey: 'home',
      baseBonusPercent: 20,
      preferredCategories: [RealEstateCategory.housing],
      preferredSellerTypes: [RealEstateSellerType.individual, RealEstateSellerType.agency],
      successDialogue: 'Piyasa faizleri ve aidat yükü satıcının kafasına yattı • "Madem nakit alacaksın, pazarlık sünnettir" dedi!',
      failureDialogue: 'Satıcı • Dairem lüks sitede havuzlu güvenliklidir, aidatını dert eden almasın • dedi.',
      walkawayDialogue: 'Satıcı • Bütçeniz yetmiyorsa varoşlardan daire bakın! • Masadan kalktı.',
    ),
  ];

  /// Detects whether listing has any legal or architectural discrepancy
  static RealEstateDiscrepancyInfo evaluateDiscrepancy(RealEstateListingModel listing) {
    if (listing.realEstate.deedType == DeedType.unlicensedBuilding) {
      return const RealEstateDiscrepancyInfo(
        hasDiscrepancy: true,
        key: 'unlicensedBuilding',
        title: 'İskansız Yapı • Şantiye Elektriği',
        description: 'Yapı kullanım izin belgesi yok. Elektrik ve su şantiye tarifesinden ödeniyor.',
        extraDiscountPercent: 0.15,
      );
    }
    if (listing.realEstate.deedType == DeedType.sharedDeed) {
      return const RealEstateDiscrepancyInfo(
        hasDiscrepancy: true,
        key: 'sharedDeed',
        title: 'Hisseli Tapu • Şufa Davası Riski',
        description: 'Mülk müşterek mülkiyetli. Diğer hissedarların ön alım - şufa davası açma riski var.',
        extraDiscountPercent: 0.12,
      );
    }
    if (listing.discrepancyKey == 'mortgageEncumbrance') {
      return const RealEstateDiscrepancyInfo(
        hasDiscrepancy: true,
        key: 'mortgageEncumbrance',
        title: 'Tapuda Banka İpotek Şerhi',
        description: 'Önceki malikin kredi borcu nedeniyle tapu kaydında 1. derece banka ipoteği bulunuyor.',
        extraDiscountPercent: 0.10,
      );
    }
    if (listing.discrepancyKey == 'illegalRoofDuplex') {
      return const RealEstateDiscrepancyInfo(
        hasDiscrepancy: true,
        key: 'illegalRoofDuplex',
        title: 'Ruhsatsız Çatı Katı İlavesi',
        description: 'Çatı katı onaylı mimari projede görünmüyor. Kaçak imalat belediyece mühürlenebilir.',
        extraDiscountPercent: 0.08,
      );
    }
    if (listing.discrepancyKey == 'historicPreservationSite') {
      return const RealEstateDiscrepancyInfo(
        hasDiscrepancy: true,
        key: 'historicPreservationSite',
        title: 'Anıtlar Kurulu Sit Alanı Şerhi',
        description: 'Tarihi sit alanı kısıtlaması nedeniyle çivi çakmak bile koruma kurulu iznine tabi.',
        extraDiscountPercent: 0.14,
      );
    }
    if (listing.discrepancyKey == 'stubbornTenant') {
      return const RealEstateDiscrepancyInfo(
        hasDiscrepancy: true,
        key: 'stubbornTenant',
        title: 'Tahliye Taahhütsüz Eski Kiracı',
        description: 'İçeride sembolik kira ödeyen ve çıkmak istemeyen eski kiracı bulunuyor.',
        extraDiscountPercent: 0.07,
      );
    }
    return RealEstateDiscrepancyInfo.clean;
  }

  /// Calculates success probability of offered purchase price
  static int calculateBuyerSuccessChance({
    required double askingPrice,
    required double offeredPrice,
    required int playerLevel,
    required RealEstateSellerType sellerType,
    double extraBonusPercent = 0.0,
  }) {
    if (askingPrice <= 0 || offeredPrice >= askingPrice) return 100;
    final discountPercent = ((askingPrice - offeredPrice) / askingPrice) * 100;
    double baseChance = 100.0 - (discountPercent * 4.5);

    // Seller type modifiers
    switch (sellerType) {
      case RealEstateSellerType.individual:
        baseChance -= 5.0; // Emotional attachment
        break;
      case RealEstateSellerType.agency:
        baseChance += 5.0; // Wants deal done for commission
        break;
      case RealEstateSellerType.bankAuction:
        baseChance -= 2.0; // Bureaucratic algorithm
        break;
    }

    final levelBonus = playerLevel * 3.0;
    final total = (baseChance + levelBonus + (extraBonusPercent * 100)).clamp(5.0, 95.0);
    return total.round();
  }

  /// Executes an esnaf tactic roll
  static RealEstateTacticRollOutcome executeTactic({
    required RealEstateTactic tactic,
    required RealEstateListingModel listing,
    required int currentPatience,
    required int playerLevel,
  }) {
    final diceRoll = _random.nextInt(100) + 1;
    int threshold = 50 - (tactic.baseBonusPercent);

    if (tactic.preferredSellerTypes.contains(listing.realEstate.sellerType)) {
      threshold -= 15; // +15 bonus chance if matched archetype
    }
    if (tactic.preferredCategories.contains(listing.realEstate.category)) {
      threshold -= 15; // +15 bonus chance if matched property category
    }
    threshold -= (playerLevel * 2);
    threshold = threshold.clamp(10, 85);

    final isSuccess = diceRoll >= threshold;
    final bool isWalkaway = !isSuccess && currentPatience < 25 && _random.nextDouble() < 0.40;

    int patienceChange = 0;
    if (tactic.isRescue) {
      patienceChange = isSuccess ? 35 : -10;
    } else {
      patienceChange = isSuccess ? 10 : -15;
    }

    String msg;
    if (isWalkaway) {
      msg = tactic.walkawayDialogue;
    } else if (isSuccess) {
      msg = tactic.successDialogue;
    } else {
      msg = tactic.failureDialogue;
    }

    return RealEstateTacticRollOutcome(
      isSuccess: isSuccess,
      isWalkaway: isWalkaway,
      diceRoll: diceRoll,
      threshold: threshold,
      bonusChance: (100 - threshold).clamp(5, 95),
      message: SlotTextComposer.sanitizeText(msg),
      tacticTitle: tactic.title,
      patienceChange: patienceChange,
    );
  }

  /// Evaluates the player's direct price counter-offer
  static RealEstateNegotiationOutcome evaluateOffer({
    required RealEstateListingModel listing,
    required double offeredPrice,
    required int currentPatience,
    required int playerLevel,
    double extraBonusPercent = 0.0,
  }) {
    final chance = calculateBuyerSuccessChance(
      askingPrice: listing.askingPrice,
      offeredPrice: offeredPrice,
      playerLevel: playerLevel,
      sellerType: listing.realEstate.sellerType,
      extraBonusPercent: extraBonusPercent,
    );

    final roll = _random.nextInt(100) + 1;
    final isAccepted = roll <= chance;

    if (isAccepted) {
      final msg = SlotTextComposer.sanitizeText(
        '${listing.sellerName} • Teklif ettiğin ₺${offeredPrice.round()} rakamını kabul ediyorum. Web - Tapu başvurusunu yapıp harçları yatıralım.',
      );
      return RealEstateNegotiationOutcome(
        currentOfferedPrice: offeredPrice,
        responseMessage: msg,
        isAccepted: true,
        isWalkaway: false,
        updatedPatience: currentPatience,
      );
    }

    // Offer rejected
    final discountPercent = ((listing.askingPrice - offeredPrice) / listing.askingPrice) * 100;
    final patienceDrop = (discountPercent > 20 ? 25 : 12) + _random.nextInt(8);
    final newPatience = (currentPatience - patienceDrop).clamp(0, 100);

    final bool isWalkaway = newPatience <= 0;

    String responseMsg;
    if (isWalkaway) {
      responseMsg = SlotTextComposer.sanitizeText(
        '${listing.sellerName} • ₺${offeredPrice.round()} teklifin gayrimenkulümün değerini hiçe sayıyor. Pazarlık bitmiştir, tapu dairesine gitmiyoruz!',
      );
    } else {
      responseMsg = generateDynamicSellerDialogue(
        sellerName: listing.sellerName,
        sellerType: listing.realEstate.sellerType,
        category: listing.realEstate.category,
        offeredPrice: offeredPrice,
        askingPrice: listing.askingPrice,
        patience: newPatience,
      );
    }

    return RealEstateNegotiationOutcome(
      currentOfferedPrice: offeredPrice,
      responseMessage: responseMsg,
      isAccepted: false,
      isWalkaway: isWalkaway,
      updatedPatience: newPatience,
    );
  }

  /// Composes realistic Turkish seller dialogues based on patience, seller type and property category
  static String generateDynamicSellerDialogue({
    required String sellerName,
    required RealEstateSellerType sellerType,
    RealEstateCategory? category,
    required double offeredPrice,
    required double askingPrice,
    required int patience,
  }) {
    final formattedOffer = '₺${offeredPrice.round()}';

    if (patience < 25) {
      final slot1 = [
        '$sellerName • Sabrımı tüketiyorsun.',
        '$sellerName • Bu son ikazımdır.',
        '$sellerName • Artık canımı sıkmaya başladı bu pazarlık.',
      ];
      final slot2 = <String>[];
      if (category == RealEstateCategory.land) {
        slot2.addAll([
          'Arsamı üç kuruşa kapatıp müteahhide kat karşılığı vermeyi mi düşünüyorsun?',
          'İmarı açık kupon arsayı tarla parasına bırakmam usta.',
        ]);
      } else if (category == RealEstateCategory.commercial) {
        slot2.addAll([
          'Cadde üstü dükkanı ara sokak bodrum fiyatına alamazsınız!',
          'Tabela değeri ve cirosu yüksek dükkandır, bu teklif hakarettir.',
        ]);
      } else if (category == RealEstateCategory.building) {
        slot2.addAll([
          'Komple binayı apartman dairesi parasına kapatmaya çalışıyorsunuz!',
          'Kat mülkiyetli plaza bu paralara elden çıkar mı beyefendi?',
        ]);
      } else {
        slot2.addAll([
          '$formattedOffer rakamı bu mülkün metrekare birim maliyetini bile karşılamaz.',
          'Mülküm kupon mülktür, bu paralara vermektense boş tutarım.',
          'Böyle komik rakamlarla masaya oturacaksanız vaktimi çalmayın.',
        ]);
      }
      return SlotTextComposer.compose2(slot1: slot1, slot2: slot2);
    }

    switch (sellerType) {
      case RealEstateSellerType.individual:
        final slot1 = [
          '$sellerName • Selamlar usta.',
          '$sellerName • Beyefendi iyi günler.',
          '$sellerName • İlanımı incelediğiniz için teşekkürler.',
        ];
        final slot2 = <String>[];
        if (category == RealEstateCategory.land) {
          slot2.addAll([
            'Arsamın emsali ve yol terkleri yapılmış durumda, geleceği çok parlak.',
            'Yatırımlık kupon arsadır, müteahhitler kapımda bekliyor.',
          ]);
        } else if (category == RealEstateCategory.commercial) {
          slot2.addAll([
            'Dükkanımın kiracısı hazır ve düzenli ödüyor, tabela değeri çok yüksek.',
            'Cadde cepheli dükkan bulmak bu devirde kolay değil.',
          ]);
        } else if (category == RealEstateCategory.building) {
          slot2.addAll([
            'Binamızın statik projesi ve betonarme kalitesi birinci sınıftır.',
            'Düzenli kira getiren komple binadır, amortismanı çok cazip.',
          ]);
        } else {
          slot2.addAll([
            'Dede yadigarı mülkümdür, acil nakit ihtiyacım olmasa satmam.',
            'Bölgenin emsal satış fiyatları ortada, çok alta inemem.',
            'Konut kredisi faizleri yüzünden piyasa yavaş ama ben tok satıcıyım.',
          ]);
        }
        final slot3 = [
          '$formattedOffer kurtarmaz, ₺${(askingPrice * 0.96).round()} seviyesinde anlaşırsak tapuya geçebiliriz.',
          '$formattedOffer çok düşük kaldı, ₺${(askingPrice * 0.97).round()} altına kesinlikle imza atmam.',
          '$formattedOffer teklifinize karşı son teklifim ₺${(askingPrice * 0.95).round()} olur.',
        ];
        return SlotTextComposer.compose3(slot1: slot1, slot2: slot2, slot3: slot3);

      case RealEstateSellerType.agency:
        final slot1 = [
          '$sellerName • Ofisimize hoş geldiniz.',
          '$sellerName • Portföyümüz çok canlı usta.',
          '$sellerName • Emlak piyasasında fırsatlar hızlı tükenir.',
        ];
        final slot2 = <String>[];
        if (category == RealEstateCategory.land) {
          slot2.addAll([
            'Bölge yeni sanayi ve konut imar planı aksında hızla prim yapıyor.',
            'TAKS ve KAKS oranları oldukça avantajlı bir imar parselidir.',
          ]);
        } else if (category == RealEstateCategory.commercial) {
          slot2.addAll([
            'İşlek cadde üzerinde yaya sirkülasyonu en yoğun noktadadır.',
            'Kurumsal kiracı potansiyeli yüksek, amortismanı hızlı bir dükkan.',
          ]);
        } else if (category == RealEstateCategory.building) {
          slot2.addAll([
            'Plazamız kurumsal şirketlere kiralanmaya hazır durumdadır.',
            'Tek tapu müstakil bina arayan yatırımcılar için kaçırılmayacak fırsat.',
          ]);
        } else {
          slot2.addAll([
            'Mal sahibiyle dün görüştüm, fiyatta çok fazla esneklik payı bırakmadı.',
            'Bu lokasyonda bu metrekarede gayrimenkul bulmak artık imkansız.',
            'Bölge kentsel dönüşüm ve yeni metro hattı güzergahında değerleniyor.',
          ]);
        }
        final slot3 = [
          '$formattedOffer teklifinizi mal sahibine iletsem masadan kovar. ₺${(askingPrice * 0.95).round()} olursa ikna ederim.',
          '$formattedOffer ile el sıkışamayız, ₺${(askingPrice * 0.96).round()} peşin çalışırsa hemen sözleşmeyi hazırlarım.',
          '$formattedOffer çok kırıcı oldu. ₺${(askingPrice * 0.97).round()} yapalım, iki tarafın da gönlü olsun.',
        ];
        return SlotTextComposer.compose3(slot1: slot1, slot2: slot2, slot3: slot3);

      case RealEstateSellerType.bankAuction:
        final slot1 = [
          '$sellerName • İhale Takip Birimi.',
          '$sellerName • Banka Gayrimenkul Tasfiye Masası.',
        ];
        final slot2 = [
          'Ekspertiz değerleme raporu resmi olarak onaylanmıştır.',
          'Banka kurul kararı olmaksızın taban fiyatın altına inilemez.',
        ];
        final slot3 = [
          '$formattedOffer teklifi ihale taban fiyatı sınırını karşılamıyor. Teklifinizi ₺${(askingPrice * 0.97).round()} seviyesine revize ediniz.',
          '$formattedOffer kurul onayından geçmez. Asgari kabul sınırı ₺${(askingPrice * 0.96).round()} olarak belirlenmiştir.',
        ];
        return SlotTextComposer.compose3(slot1: slot1, slot2: slot2, slot3: slot3);
    }
  }
}
