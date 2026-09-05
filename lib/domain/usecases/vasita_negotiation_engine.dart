import 'dart:math';
import '../../data/models/listing_model.dart';
import '../../data/models/vehicle_category.dart';

class VasitaTactic {
  final String id;
  final String title;
  final String badgeText;
  final String description;
  final String iconKey;
  final int baseBonusPercent;
  final bool isRescue;
  final List<VehicleCategory> allowedCategories; // Empty means all categories
  final String successDialogue;
  final String failureDialogue;
  final String walkawayDialogue;

  const VasitaTactic({
    required this.id,
    required this.title,
    required this.badgeText,
    required this.description,
    required this.iconKey,
    required this.baseBonusPercent,
    this.isRescue = false,
    this.allowedCategories = const [],
    required this.successDialogue,
    required this.failureDialogue,
    required this.walkawayDialogue,
  });

  bool isApplicable(VehicleCategory category) {
    if (allowedCategories.isEmpty) return true;
    return allowedCategories.contains(category);
  }
}

class VasitaTacticRollOutcome {
  final bool isSuccess;
  final bool isWalkaway;
  final int diceRoll;
  final int threshold;
  final int bonusChance;
  final String message;
  final String tacticTitle;
  final int patienceChange;

  const VasitaTacticRollOutcome({
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

class VasitaNegotiationOutcome {
  final double currentOfferedPrice;
  final String responseMessage;
  final bool isAccepted;
  final bool isWalkaway;
  final int updatedPatience;
  final VasitaTacticRollOutcome? tacticOutcome;

  const VasitaNegotiationOutcome({
    required this.currentOfferedPrice,
    required this.responseMessage,
    required this.isAccepted,
    required this.isWalkaway,
    required this.updatedPatience,
    this.tacticOutcome,
  });
}

class VasitaNegotiationEngine {
  static final Random _random = Random();

  /// Fixed registration & plate change fee (₺850)
  static const double registrationFee = 850.0;

  /// Dynamic Notary fee: 2 per mille (0.2% = binde 2) of agreed price
  static double calculateNoterFee(double agreedPrice) {
    return (agreedPrice * 0.002).roundToDouble();
  }

  /// Total Notary transfer cost breakdown
  static double calculateTotalAcquisitionCost(double agreedPrice) {
    return agreedPrice + calculateNoterFee(agreedPrice) + registrationFee;
  }

  // --- VEHICLE ESNAF TACTICS POOL ---
  static const List<VasitaTactic> allTactics = [
    // 1. Universal Cash Payment Power
    VasitaTactic(
      id: 'pesin_noter',
      title: 'Peşin Para • Notere Hemen Geçelim',
      badgeText: 'Nakit Gücü',
      description: 'Çantada hazır nakit parayı masaya koyup anında noter randevusu almayı teklif et.',
      iconKey: 'cash',
      baseBonusPercent: 20,
      successDialogue: 'Paranın hazır olduğunu gören satıcı gülümsedi • "Madem nakit hazır, noterde işi bitirelim" dedi!',
      failureDialogue: 'Satıcı • Para herkesin cebinde var usta, malımın değeri bu • diyerek tok durdu.',
      walkawayDialogue: 'Satıcı • Paranız cebinizde kalsın, bu fiyata anahtar vermem! • Masayı terk etti.',
    ),

    // 2. Universal Tramer & Damage Check
    VasitaTactic(
      id: 'tramer_baski',
      title: 'Tramer Kaydı ve Hasar Geçmişi',
      badgeText: 'Kayıt Baskısı',
      description: 'SBM tramer sorgusunu ve boyalı parçaları öne sürerek fiyatı aşağı çek.',
      iconKey: 'record',
      baseBonusPercent: 22,
      allowedCategories: [
        VehicleCategory.car,
        VehicleCategory.minivan,
        VehicleCategory.commercial,
        VehicleCategory.rentalFleet,
        VehicleCategory.damaged,
      ],
      successDialogue: 'Tramer dökümünü gören satıcı duraksadı • "Haklısın, boyası var, fiyatta biraz daha inelim" dedi!',
      failureDialogue: 'Satıcı • Aracın şaselerinde podyelerinde işlem yok, kaporta çizik boyası bu • diyerek geri adım atmadı.',
      walkawayDialogue: 'Satıcı • Sıfır araba mı alıyorsun kardeşim? Git bayiden al! • Masadan kalktı.',
    ),

    // 3. Mechanic & Lift Inspection
    VasitaTactic(
      id: 'usta_lift',
      title: 'Usta Çağır • Lifte Kaldıralım',
      badgeText: 'Mekanik Muayene',
      description: 'Sanayiden motor ustası çağırıp alt takım ve şanzıman boşluklarını incelet.',
      iconKey: 'build',
      baseBonusPercent: 18,
      allowedCategories: [
        VehicleCategory.car,
        VehicleCategory.minivan,
        VehicleCategory.commercial,
        VehicleCategory.atv,
        VehicleCategory.utv,
        VehicleCategory.classic,
      ],
      successDialogue: 'Ustanın motor sesini dinlemesi üzerine satıcı yumuşadı • "Ustanın hatrına biraz daha ikram yaparım" dedi!',
      failureDialogue: 'Satıcı • Aracım her gün yollarda, motoruna şanzımanına kefilim • diyerek taviz vermedi.',
      walkawayDialogue: 'Satıcı • Arabamı kurcalatmam! Alacaksan al, almayacaksan güle güle • dedi.',
    ),

    // 4. Motorcycle Specific
    VasitaTactic(
      id: 'moto_sasi',
      title: 'Şasi ve Kaza Takozu Kontrolü',
      badgeText: 'Gidon Muayenesi',
      description: 'Gidondaki çekmeyi, grenaj tırnaklarını ve yan yatma izlerini koz olarak kullan.',
      iconKey: 'two_wheeler',
      baseBonusPercent: 25,
      allowedCategories: [VehicleCategory.motorcycle],
      successDialogue: 'Grenaj tırnaklarındaki kırığı fark edince satıcı utandı • "Ufak bir yan yatması vardı, düşelim fiyattan" dedi!',
      failureDialogue: 'Satıcı • Motorum ciğerli, tek teker bile yapılmadı, fiyatım son • dedi.',
      walkawayDialogue: 'Satıcı • İki tekerden anlamayana motor satmam! • Masayı terk etti.',
    ),

    // 5. Caravan Specific
    VasitaTactic(
      id: 'karavan_izolasyon',
      title: 'Güneş Paneli ve İzolasyon Testi',
      badgeText: 'Yaşam Alanı',
      description: 'Lityum akü çevrim ömrünü, hidrofor basıncını ve tavan yalıtımını masaya koy.',
      iconKey: 'cottage',
      baseBonusPercent: 24,
      allowedCategories: [VehicleCategory.caravan],
      successDialogue: 'Akü kapasitesinin düştüğünü kabul eden karavancı • "Akü masrafını fiyattan düşelim hemşerim" dedi!',
      failureDialogue: 'Satıcı • Bu karavanla eksi yirmi derecede kamp yaptık, yalıtımı taş gibidir • diyerek diretir.',
      walkawayDialogue: 'Satıcı • Emek verdiğim karavanımı öldürmem! • Görüşmeyi sonlandırdı.',
    ),

    // 6. Marine Specific
    VasitaTactic(
      id: 'deniz_ozmoz',
      title: 'Gövde Ozmoz ve Kuyruk Yağı Kontrolü',
      badgeText: 'Draft Muayenesi',
      description: 'Fiber teknenin karina ozmoz durumunu ve tutya korozyonunu pazarlık kozu yap.',
      iconKey: 'directions_boat',
      baseBonusPercent: 26,
      allowedCategories: [VehicleCategory.marine],
      successDialogue: 'Karina bakımının yaklaştığını bilen kaptan • "Zehirli boya ve tutya masrafını anlaşmadan keselim" dedi!',
      failureDialogue: 'Kaptan • Teknem her sezon karaya çekilip titizlikle korundu, deniz görse aşık olursun • dedi.',
      walkawayDialogue: 'Kaptan • Denizci adam böyle pazarlık yapmaz! • Palamarı çözüp gitti.',
    ),

    // 7. Off-Road / ATV / UTV Specific
    VasitaTactic(
      id: 'arazi_diferansiyel',
      title: '4x4 Diferansiyel ve Şnorkel Muayenesi',
      badgeText: 'Arazi Yorgunluğu',
      description: 'Kilitli diferansiyel aşınmasını ve şasinin çamur korozyonunu öne sür.',
      iconKey: 'terrain',
      baseBonusPercent: 23,
      allowedCategories: [VehicleCategory.atv, VehicleCategory.utv],
      successDialogue: 'Diferansiyeldeki hafif boşluğu kabul eden satıcı • "Ağır çamura sokmadık ama pazarlık sünnettir" dedi!',
      failureDialogue: 'Satıcı • Bu makine dağ keçisi, diferansiyel kilitleri saat gibi çalışıyor • dedi.',
      walkawayDialogue: 'Satıcı • Şehir züppesi arazi aracının değerini bilemez! • Çekip gitti.',
    ),

    // 8. Classic Car Specific
    VasitaTactic(
      id: 'klasik_seri',
      title: 'Şasi No ve Parça Orijinalliği Eşleştirme',
      badgeText: 'Koleksiyon Değeri',
      description: 'Sonradan takılan yan sanayi parçaları ve boya tonu farklarını ortaya koy.',
      iconKey: 'history_edu',
      baseBonusPercent: 25,
      allowedCategories: [VehicleCategory.classic],
      successDialogue: 'Parça uyumsuzluğunu fark eden koleksiyoner • "Gözünden bir şey kaçmadı, fiyatta jest yapıyorum" dedi!',
      failureDialogue: 'Satıcı • Kırk yıllık gözbebeğim bu, civatasına kadar orijinaldir • diyerek direndi.',
      walkawayDialogue: 'Satıcı • Sen klasik ruhundan anlamıyorsun, arabamı sana satmıyorum! • Masadan kalktı.',
    ),

    // 9. Damaged Car Specific
    VasitaTactic(
      id: 'hasarli_kurtarici',
      title: 'Çekici ve Toplama Masrafı İndirimi',
      badgeText: 'Sanayi Maliyeti',
      description: 'Kaporta düzeltme, far ve airbag maliyetlerini listeleyip fiyattan doğrudan düş.',
      iconKey: 'car_crash',
      baseBonusPercent: 28,
      allowedCategories: [VehicleCategory.damaged],
      successDialogue: 'Usta masraf listesini gören satıcı • "Zaten uğraşacak vaktim yok, dediğin rakama yakın bırakıyorum" dedi!',
      failureDialogue: 'Satıcı • Parçaları çıkma taksan iki günde biter, bu fiyata pertçi bile vermez • dedi.',
      walkawayDialogue: 'Satıcı • Hurda fiyatına araba arıyorsan başka kapıya! • Masayı terk etti.',
    ),

    // 10. Universal Rescue Tactic (Sanayi Çayı Ismarla)
    VasitaTactic(
      id: 'sanayi_cayi',
      title: 'Sanayi Çayı Ismarla • Masayı Kurtar',
      badgeText: 'Esnaf İkramı',
      description: 'Masayı terk etmeye kalkan satıcıya tavşan kanı demli çay söyleyip ortamı yumuşat.',
      iconKey: 'local_cafe',
      baseBonusPercent: 15,
      isRescue: true,
      successDialogue: 'Çayı yudumlayan satıcının yüzü güldü • "Esnaflığın hatrına oturup baştan konuşalım" dedi!',
      failureDialogue: 'Satıcı çayı içti ama • Ağzımız tatlandı ama cebimiz tatlanmadı usta • diyerek duruşunu korudu.',
      walkawayDialogue: 'Satıcı • Çayın için sağ ol ama bu ticaret olmaz kardeşim • diyerek masayı büsbütün terk etti.',
    ),
  ];

  /// Get tactics available for a specific vehicle category
  static List<VasitaTactic> getTacticsForCategory(VehicleCategory category) {
    return allTactics.where((t) => t.isApplicable(category)).toList();
  }

  /// Alias for getTacticsForCategory
  static List<VasitaTactic> getTacticsForVehicle(VehicleCategory category) =>
      getTacticsForCategory(category);

  /// Alias for calculateBuyerSuccessChance with ListingModel parameter
  static int calculateOfferSuccessProbability({
    required ListingModel listing,
    required double offeredPrice,
    required int patience,
    required int playerLevel,
    double extraBonusPercent = 0.0,
  }) {
    return calculateBuyerSuccessChance(
      askingPrice: listing.askingPrice,
      offeredPrice: offeredPrice,
      playerLevel: playerLevel,
      sellerTrait: listing.sellerTrait,
      extraBonusPercent: extraBonusPercent,
    );
  }

  /// Alias for executeTactic
  static VasitaTacticRollOutcome rollTactic({
    required VasitaTactic tactic,
    required ListingModel listing,
    required int currentPatience,
    required int playerLevel,
  }) {
    return executeTactic(
      tactic: tactic,
      listing: listing,
      currentPatience: currentPatience,
      playerLevel: playerLevel,
    );
  }

  /// Calculates success chance percentage (0 - 100)
  static int calculateBuyerSuccessChance({
    required double askingPrice,
    required double offeredPrice,
    required int playerLevel,
    required String sellerTrait,
    double extraBonusPercent = 0.0,
  }) {
    if (askingPrice <= 0) return 0;
    if (offeredPrice >= askingPrice) return 98;

    final ratio = offeredPrice / askingPrice;

    // Base chance curve
    double chance;
    if (ratio >= 0.95) {
      chance = 80.0 + ((ratio - 0.95) * 20.0) * 18.0;
    } else if (ratio >= 0.90) {
      chance = 55.0 + ((ratio - 0.90) * 20.0) * 25.0;
    } else if (ratio >= 0.85) {
      chance = 35.0 + ((ratio - 0.85) * 20.0) * 20.0;
    } else if (ratio >= 0.80) {
      chance = 18.0 + ((ratio - 0.80) * 20.0) * 17.0;
    } else if (ratio >= 0.70) {
      chance = 5.0 + ((ratio - 0.70) * 10.0) * 13.0;
    } else {
      chance = 2.0;
    }

    // Player level advantage (+1.5% per level above Level 1)
    final levelBonus = (playerLevel - 1) * 1.5;
    chance += levelBonus;

    // Seller trait modifier
    final trait = sellerTrait.toLowerCase();
    if (trait.contains('aceleci') || trait.contains('acil')) {
      chance += 12.0;
    } else if (trait.contains('tok')) {
      chance -= 12.0;
    } else if (trait.contains('galerici') || trait.contains('esnaf')) {
      chance -= 5.0;
    } else if (trait.contains('memur') || trait.contains('emekli')) {
      chance += 4.0;
    }

    // Add accumulated tactic bonuses
    chance += (extraBonusPercent * 100.0);

    return chance.clamp(2.0, 98.0).round();
  }

  /// Evaluates tactic roll and impact on seller patience
  static VasitaTacticRollOutcome executeTactic({
    required VasitaTactic tactic,
    required ListingModel listing,
    required int currentPatience,
    required int playerLevel,
  }) {
    final dice = _random.nextInt(100) + 1;
    int threshold = 50 - (playerLevel * 2);

    final trait = listing.sellerTrait.toLowerCase();
    if (trait.contains('aceleci')) threshold -= 10;
    if (trait.contains('tok')) threshold += 12;

    threshold = threshold.clamp(20, 85);

    if (dice >= threshold) {
      // Success
      return VasitaTacticRollOutcome(
        isSuccess: true,
        isWalkaway: false,
        diceRoll: dice,
        threshold: threshold,
        bonusChance: tactic.baseBonusPercent,
        message: tactic.successDialogue,
        tacticTitle: tactic.title,
        patienceChange: tactic.isRescue ? 25 : 5,
      );
    } else {
      // Failure
      final walkawayRisk = (100 - currentPatience) > 60;
      final isWalkaway = walkawayRisk && _random.nextDouble() < 0.40;

      return VasitaTacticRollOutcome(
        isSuccess: false,
        isWalkaway: isWalkaway,
        diceRoll: dice,
        threshold: threshold,
        bonusChance: 0,
        message: isWalkaway ? tactic.walkawayDialogue : tactic.failureDialogue,
        tacticTitle: tactic.title,
        patienceChange: isWalkaway ? -currentPatience : -15,
      );
    }
  }

  /// Evaluates an offer submitted by the player
  static VasitaNegotiationOutcome evaluateOffer({
    required ListingModel listing,
    required double offeredPrice,
    required int currentPatience,
    required int playerLevel,
    double extraBonusPercent = 0.0,
  }) {
    final chance = calculateBuyerSuccessChance(
      askingPrice: listing.askingPrice,
      offeredPrice: offeredPrice,
      playerLevel: playerLevel,
      sellerTrait: listing.sellerTrait,
      extraBonusPercent: extraBonusPercent,
    );

    final roll = _random.nextInt(100) + 1;
    final isAccepted = roll <= chance;

    if (isAccepted) {
      return VasitaNegotiationOutcome(
        currentOfferedPrice: offeredPrice,
        responseMessage: 'Satıcı elini uzattı • "Hayırlı olsun hemşerim, el sıkıştık! Hemen notere geçip imzaları atalım." dedi.',
        isAccepted: true,
        isWalkaway: false,
        updatedPatience: currentPatience,
      );
    }

    final ratio = offeredPrice / listing.askingPrice;
    final patienceDrop = ratio < 0.80 ? 25 : (ratio < 0.90 ? 15 : 10);
    final newPatience = (currentPatience - patienceDrop).clamp(0, 100);

    if (newPatience <= 0) {
      return VasitaNegotiationOutcome(
        currentOfferedPrice: offeredPrice,
        responseMessage: 'Satıcı anahtarı cebine koyup ayağa kalktı • "Bu fiyata bu aracı vermem, boşuna vaktimi çalma!" diyerek masayı terk etti.',
        isAccepted: false,
        isWalkaway: true,
        updatedPatience: 0,
      );
    }

    String counterDialogue;
    if (ratio < 0.85) {
      counterDialogue = 'Satıcı kaşlarını çattı • "Bu teklif benim arabamın değerini çok düşürüyor usta, biraz daha mantıklı bir rakam söyle."';
    } else {
      counterDialogue = 'Satıcı başını salladı • "Teklifin fena değil ama liste fiyatına biraz daha yaklaşman lazım."';
    }

    return VasitaNegotiationOutcome(
      currentOfferedPrice: offeredPrice,
      responseMessage: counterDialogue,
      isAccepted: false,
      isWalkaway: false,
      updatedPatience: newPatience,
    );
  }

  /// Generates dynamic initial seller dialogue
  static String generateDynamicSellerDialogue({
    required String sellerName,
    required String sellerTrait,
    required double offeredPrice,
    required double askingPrice,
    required int patience,
  }) {
    final trait = sellerTrait.toLowerCase();
    if (trait.contains('aceleci') || trait.contains('acil')) {
      return '$sellerName • "Hayırlı günler hemşerim. Nakite sıkıştığım için ilana koydum. Ciddi alıcıysan masada anlaşırız."';
    } else if (trait.contains('tok')) {
      return '$sellerName • "Selamlar. Aracımın acelesi yok, değerini bilen alsın diye bekletiyorum. Ölü tekliflerle gelmeyin."';
    } else if (trait.contains('galerici') || trait.contains('esnaf')) {
      return '$sellerName • "Hoş geldiniz meslektaşım. Esnaf usulü pazarlığımızı yaparız, makul teklif her zaman değerlendirilir."';
    } else if (trait.contains('memur') || trait.contains('emekli')) {
      return '$sellerName • "Merhaba evladım. Arabam tek elden kullanıldı, servis bakımlıdır. Noter tescilini hemen yapabiliriz."';
    }

    return '$sellerName • "Aracımın tüm bilgileri ilanda yazıldığı gibidir. Makul bir pazarlığa açığım."';
  }
}
