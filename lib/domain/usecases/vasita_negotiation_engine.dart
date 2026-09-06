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
  final double? nearMissAmount;

  const VasitaNegotiationOutcome({
    required this.currentOfferedPrice,
    required this.responseMessage,
    required this.isAccepted,
    required this.isWalkaway,
    required this.updatedPatience,
    this.tacticOutcome,
    this.nearMissAmount,
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

    // 11. Tofaş / Yerli Araç Specific (LPG ve Çürük)
    VasitaTactic(
      id: 'tofas_lpg',
      title: 'LPG Beyni ve Çürük Kontrolü',
      badgeText: 'Kuş Serisi Kozu',
      description: 'Tüp beyninin kaçırdığını ve marşpiyellerdeki macun çatlaklarını koz yap.',
      iconKey: 'local_gas_station',
      baseBonusPercent: 24,
      allowedCategories: [VehicleCategory.car, VehicleCategory.damaged],
      successDialogue: 'Tüp beyninin kaçırdığını gören satıcı • "Haklısın usta, gaz ayarı masrafını düşelim" dedi!',
      failureDialogue: 'Satıcı • Bu araba tek marşta çalışır, gazda da benzinde de fişek gibidir • dedi.',
      walkawayDialogue: 'Satıcı • Kuş serisinin değerini bilmeyenle ticaret yapmam! • Masadan kalktı.',
    ),

    // 12. German / Premium Specific
    VasitaTactic(
      id: 'alman_servis',
      title: 'Yetkili Servis ve Zincir Seti',
      badgeText: 'Ağır Bakım Baskısı',
      description: 'Ağır bakım geçmişini ve şanzıman kavrama boşluğunu masaya koy.',
      iconKey: 'settings_suggest',
      baseBonusPercent: 25,
      allowedCategories: [VehicleCategory.car, VehicleCategory.rentalFleet],
      successDialogue: 'Servis kaydının eksikliğini kabul eden satıcı • "Ağır bakım payını fiyattan düşüyorum" dedi!',
      failureDialogue: 'Satıcı • Alman mühendisliği bu, bakımları saat gibidir, kuruş inmem • dedi.',
      walkawayDialogue: 'Satıcı • Kaliteye bütçesi yetmeyen gitmesin pazara! • Çekip gitti.',
    ),

    // 13. Commercial / Minivan Specific
    VasitaTactic(
      id: 'ticari_kantar',
      title: 'Kantar Yorgunluğu ve Şasi Esnemesi',
      badgeText: 'Ağır Tonaj Kozu',
      description: 'Aracın ağır yükte çalıştığını ve makasların çöktüğünü öne sür.',
      iconKey: 'local_shipping',
      baseBonusPercent: 26,
      allowedCategories: [VehicleCategory.commercial, VehicleCategory.minivan],
      successDialogue: 'Yük gördüğünü itiraf eden esnaf • "Makas bakımını fiyattan kıralım" dedi!',
      failureDialogue: 'Satıcı • Arabam hafif yük taşıdı, şasisi ok gibi dimdiktir • diyerek direndi.',
      walkawayDialogue: 'Satıcı • Ekmek teknemi öldürtmem, ticaret bitti! • Masayı terk etti.',
    ),

    // 14. Classic / Rare Specific
    VasitaTactic(
      id: 'klasik_garaj',
      title: 'Kapalı Garaj ve Orijinal Döşeme',
      badgeText: 'Nostalji Kozu',
      description: 'Döşemedeki güneş yanıklarını ve nikelaj korozyonunu pazarlık kozu yap.',
      iconKey: 'garage',
      baseBonusPercent: 27,
      allowedCategories: [VehicleCategory.classic],
      successDialogue: 'Nikelajlardaki matlaşmayı gören satıcı • "Gözünden kaçmadı, ikram yapıyorum" dedi!',
      failureDialogue: 'Satıcı • Yılların hatırası var bu arabada, pazarlık kabul etmem • dedi.',
      walkawayDialogue: 'Satıcı • Hatırası olan arabaya paha biçilmez! • Masayı terk etti.',
    ),
  ];

  /// Default thinking suspense step translation keys fallback
  static const List<String> thinkingStepKeys = [
    'vasita_think_step_1',
    'vasita_think_step_2',
    'vasita_think_step_3',
  ];

  /// Contextual thinking steps tailored specifically to the vehicle archetype
  static List<String> getThinkingStepsForListing(ListingModel listing) {
    final cat = listing.car.vehicleCategory;
    final car = listing.car;
    final year = car.modelYear;
    final brand = car.brand.toLowerCase();
    final model = car.modelName.toLowerCase();
    final bType = car.bodyType.toLowerCase();

    List<String> steps;
    // 1. Commercial / Fleet
    if (cat == VehicleCategory.commercial ||
        bType.contains('ticari') ||
        bType.contains('van') ||
        bType.contains('kamyonet') ||
        model.contains('caddy') ||
        model.contains('doblo') ||
        model.contains('transporter') ||
        model.contains('transit') ||
        model.contains('çelikvolvo') ||
        model.contains('celikvolvo')) {
      steps = [
        'vasita_think_comm_1',
        'vasita_think_comm_2',
        'vasita_think_comm_3',
        'vasita_think_comm_4',
      ];
    }
    // 2. Performance / Sport / Exotic
    else if (car.isRare ||
        bType.contains('spor') ||
        bType.contains('cabrio') ||
        brand.contains('porsche') ||
        brand.contains('ferrari') ||
        brand.contains('lamborghini') ||
        brand.contains('amg') ||
        model.contains('m3') ||
        model.contains('m4') ||
        model.contains('m5') ||
        model.contains('rs') ||
        model.contains('gti')) {
      steps = [
        'vasita_think_perf_1',
        'vasita_think_perf_2',
        'vasita_think_perf_3',
        'vasita_think_perf_4',
      ];
    }
    // 3. Classic / Older / Street Legend
    else if (year < 2005 ||
        cat == VehicleCategory.classic ||
        bType.contains('klasik') ||
        brand.contains('tofaş') ||
        brand.contains('tofas') ||
        model.contains('şahin') ||
        model.contains('sahin') ||
        model.contains('doğan') ||
        model.contains('dogan') ||
        model.contains('kartal') ||
        model.contains('toros')) {
      steps = [
        'vasita_think_classic_1',
        'vasita_think_classic_2',
        'vasita_think_classic_3',
        'vasita_think_classic_4',
      ];
    }
    // 4. SUV / 4x4 / Off-Road
    else if (bType.contains('suv') ||
        bType.contains('arazi') ||
        brand.contains('jeep') ||
        brand.contains('land rover') ||
        model.contains('duster')) {
      steps = [
        'vasita_think_suv_1',
        'vasita_think_suv_2',
        'vasita_think_suv_3',
        'vasita_think_suv_4',
      ];
    }
    // 5. Standard Passenger
    else {
      steps = [
        'vasita_think_std_1',
        'vasita_think_std_2',
        'vasita_think_std_3',
        'vasita_think_std_4',
      ];
    }

    if (listing.askingPrice >= 2000000) {
      return [...steps, 'vasita_think_high_stakes'];
    }
    return steps;
  }

  /// Calculates per-step delay in milliseconds based on vehicle tier
  static int getThinkingStepDurationMs(ListingModel listing) {
    if (listing.askingPrice >= 2000000) return 1050;
    final cat = listing.car.vehicleCategory;
    final bType = listing.car.bodyType.toLowerCase();
    if (cat == VehicleCategory.commercial) return 1000;
    if (listing.car.isRare || bType.contains('spor')) return 1000;
    return 850;
  }

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

    // Add accumulated tactic bonuses • capped at 35% to prevent guaranteed accepts
    final cappedBonus = (extraBonusPercent * 100.0).clamp(0.0, 35.0);
    chance += cappedBonus;

    return chance.clamp(2.0, 98.0).round();
  }

  /// Calculates seller satiety / resistance score (0 - 100)
  static int calculateSellerTokluk(String sellerTrait) {
    final trait = sellerTrait.toLowerCase();
    if (trait.contains('tok')) return 75;
    if (trait.contains('galerici') || trait.contains('esnaf')) return 55;
    if (trait.contains('memur') || trait.contains('emekli')) return 45;
    if (trait.contains('aceleci') || trait.contains('acil')) return 20;
    return 40;
  }

  /// Calculates tactic success score using mathematical formula:
  /// BasariPuani = OyuncuKarizmasi * 0.4 + KozAgirligi * 0.3 - SaticiToklukDerecesi * 0.3
  static double calculateTacticSuccessScore({
    required int playerCharisma,
    required int tacticWeight,
    required int sellerTokluk,
  }) {
    return (playerCharisma * 0.4) + (tacticWeight * 0.3) - (sellerTokluk * 0.3);
  }

  /// Evaluates tactic roll and impact on seller patience with dynamic resistance
  static VasitaTacticRollOutcome executeTactic({
    required VasitaTactic tactic,
    required ListingModel listing,
    required int currentPatience,
    required int playerLevel,
  }) {
    final playerCharisma = (playerLevel * 7).clamp(15, 95);
    final tacticWeight = (tactic.baseBonusPercent * 3.5).round().clamp(30, 95);
    final sellerTokluk = calculateSellerTokluk(listing.sellerTrait);

    final baseScore = calculateTacticSuccessScore(
      playerCharisma: playerCharisma,
      tacticWeight: tacticWeight,
      sellerTokluk: sellerTokluk,
    );

    // Dynamic variance of +/- 15 points
    final variance = _random.nextInt(31) - 15;
    final finalScore = (baseScore + variance).clamp(0.0, 100.0);
    final isSuccess = finalScore >= 50.0;

    if (isSuccess) {
      // Success
      final successVariants = [
        tactic.successDialogue,
        '${tactic.title} konusunda haklısın • "Bunu hesaba katmamıştım, teklifte biraz esneyeceğim" dedi.',
        'Satıcı durumu kabullendi • "${tactic.title} tespitin yerinde, fiyatta sana bir kolaylık sağlayacağım."',
        'Satıcı başını salladı • "Usta gözünden hiçbir şey kaçmıyor, fiyattan fedakarlık yapalım o zaman."',
      ];
      final chosenMsg = successVariants[_random.nextInt(successVariants.length)];

      return VasitaTacticRollOutcome(
        isSuccess: true,
        isWalkaway: false,
        diceRoll: finalScore.round(),
        threshold: 50,
        bonusChance: tactic.baseBonusPercent,
        message: chosenMsg,
        tacticTitle: tactic.title,
        patienceChange: tactic.isRescue ? 25 : 5,
      );
    } else {
      // Failure / Resistance
      final walkawayRisk = (100 - currentPatience) > 60;
      final isWalkaway = walkawayRisk && _random.nextDouble() < 0.40;

      String chosenMsg;
      if (isWalkaway) {
        final walkawayVariants = [
          tactic.walkawayDialogue,
          'Satıcı sertçe ayağa kalktı • "Her şeye bir kulp taktın, benim bu arabayı sana satacak sabrım kalmadı!"',
          'Satıcı kapıyı işaret etti • "Kusur arayacaksan sıfır araç bayisine git, pazarlık bitti!"',
          'Satıcı anahtarı aldı • "Sürekli bahanelerle fiyat öldüren adamla işim olmaz!" diyerek çıktı.',
        ];
        chosenMsg = walkawayVariants[_random.nextInt(walkawayVariants.length)];
      } else {
        final failVariants = [
          tactic.failureDialogue,
          'Satıcı oralı bile olmadı • "Bunu bana koz olarak sunma usta, arabanın her şeyi ortada."',
          'Satıcı başını iki yana salladı • "Bu bahanelerle fiyat kıramazsın, araç kendini anlatıyor zaten."',
          'Satıcı gülümsedi • "O saydığın kusur bu modelin fıtratında var, fiyattan kuruş inmem."',
        ];
        chosenMsg = failVariants[_random.nextInt(failVariants.length)];
      }

      return VasitaTacticRollOutcome(
        isSuccess: false,
        isWalkaway: isWalkaway,
        diceRoll: finalScore.round(),
        threshold: 50,
        bonusChance: 0,
        message: chosenMsg,
        tacticTitle: tactic.title,
        patienceChange: isWalkaway ? -currentPatience : -12,
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
      final acceptedPool = [
        'Satıcı elini uzattı • "Hayırlı olsun hemşerim, el sıkıştık! Hemen notere geçip imzaları atalım." dedi.',
        'Satıcı gülümseyerek anahtarı masaya bıraktı • "Söz ağızdan bir kere çıkar, araba senindir. Notere geçelim!" dedi.',
        'Satıcı memnuniyetle başını salladı • "Pazarlık sünnettir, tatlıya bağladık. Hayrını gör kardeşim!" dedi.',
        'Satıcı çayını tazeleyip tokalaştı • "Helal hoş olsun, tam istediğim gibi bir alıcı buldum. Evrakları hazırlayalım." dedi.',
      ];
      return VasitaNegotiationOutcome(
        currentOfferedPrice: offeredPrice,
        responseMessage: acceptedPool[_random.nextInt(acceptedPool.length)],
        isAccepted: true,
        isWalkaway: false,
        updatedPatience: currentPatience,
      );
    }

    final ratio = offeredPrice / listing.askingPrice;
    final patienceDrop = ratio < 0.80 ? 25 : (ratio < 0.90 ? 15 : 10);
    final newPatience = (currentPatience - patienceDrop).clamp(0, 100);

    if (newPatience <= 0) {
      final walkawayPool = [
        'Satıcı anahtarı cebine koyup ayağa kalktı • "Bu fiyata bu aracı vermem, boşuna vaktimi çalma!" diyerek masayı terk etti.',
        'Satıcı ceketini alıp kapıya yöneldi • "Piyasayı bu kadar öldüren biriyle oturacak vaktim yok benim." dedi.',
        'Satıcı elini masaya vurdu • "Biz buraya ticaret yapmaya geldik, sadaka vermeye değil! Anlaşma bitti." diyerek ayrıldı.',
        'Satıcı sert bir bakışla başını iki yana salladı • "Bu rakam arabaya hakarettir. Masayı kapatıyoruz!" dedi.',
      ];
      return VasitaNegotiationOutcome(
        currentOfferedPrice: offeredPrice,
        responseMessage: walkawayPool[_random.nextInt(walkawayPool.length)],
        isAccepted: false,
        isWalkaway: true,
        updatedPatience: 0,
      );
    }

    String counterDialogue;
    double? nearMissAmount;
    if (ratio < 0.85) {
      final lowCounterPool = [
        'Satıcı kaşlarını çattı • "Bu teklif benim arabamın değerini çok düşürüyor usta, biraz daha mantıklı bir rakam söyle." dedi.',
        'Satıcı derin bir iç çekti • "Sen piyasayı hiç takip etmiyorsun galiba usta, bu fiyata ancak pertini alırsın." dedi.',
        'Satıcı telefonunu kontrol etti • "Arayanım çok, bu fiyata bırakmam imkansız. Teklifini ciddi bir seviyeye çekmelisin." dedi.',
        'Satıcı omuz silkti • "Zararına verecek arabam yok benim. Biraz daha yukarı çıkmazsan vakit kaybediyoruz." dedi.',
      ];
      counterDialogue = lowCounterPool[_random.nextInt(lowCounterPool.length)];
    } else {
      final nearCounterPool = [
        'Satıcı başını salladı • "Teklifin fena değil ama liste fiyatına biraz daha yaklaşman lazım." dedi.',
        'Satıcı bıyığını sıvazladı • "Çok yaklaştın ama ufak bir adım daha atarsan noter masraflarını da çözeriz." dedi.',
        'Satıcı sakince çayını yudumladı • "Esnaf adamsın belli, ama bu rakamın üzerine biraz daha koyman şart." dedi.',
        'Satıcı hesap makinesine baktı • "Teklifin mantıklı sınıra geldi ancak son bir gayret daha bekliyorum." dedi.',
      ];
      counterDialogue = nearCounterPool[_random.nextInt(nearCounterPool.length)];
      // Calculate realistic near-miss shortfall amount safely bounded by distance to asking price
      final distanceToAsking = (listing.askingPrice - offeredPrice).clamp(0.0, double.infinity);
      if (distanceToAsking > 0) {
        final rawDiff = (listing.askingPrice * 0.95) - offeredPrice;
        final targetShortfall = rawDiff > 0 ? rawDiff : (distanceToAsking * 0.5);
        nearMissAmount = targetShortfall.clamp(500.0, distanceToAsking);
      }
    }

    return VasitaNegotiationOutcome(
      currentOfferedPrice: offeredPrice,
      responseMessage: counterDialogue,
      isAccepted: false,
      isWalkaway: false,
      updatedPatience: newPatience,
      nearMissAmount: nearMissAmount,
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
