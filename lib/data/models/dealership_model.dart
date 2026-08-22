import 'car_model.dart';
import 'offer_model.dart';
import 'loan_model.dart';
import 'part_order_model.dart';
import 'staff_model.dart';
import 'customer_review_model.dart';
import 'player_skills.dart';
import 'player_achievements.dart';
import 'expertise_model.dart';
import 'mission_model.dart';
import 'market_trend_model.dart';
import 'sale_record_model.dart';
import 'cheque_model.dart';
import 'installment_contract_model.dart';
import 'rental_agreement_model.dart';
import 'side_business_model.dart';
import 'stock_model.dart';
import 'game_event_model.dart';
import 'market_news_model.dart';
import 'scrapyard_model.dart';
import 'black_market_car_model.dart';
import 'story_card_model.dart';
import 'dramatic_card_model.dart';
import 'contract_model.dart';
import 'trade_in_offer_model.dart';
import 'gossip_item_model.dart';
import 'weather_model.dart';
import 'lifestyle_item_model.dart';
import 'pr_campaign_model.dart';
import 'branch_model.dart';

enum GameSeason {
  spring, // İlkbahar (Days 1-7, 29-35...)
  summer, // Yaz (Days 8-14, 36-42...)
  autumn, // Sonbahar (Days 15-21, 43-49...)
  winter, // Kış (Days 22-28, 50-56...)
}

enum CharacterOrigin {
  sanayiCiragi,     // Sanayi Çırağı: Onarım maliyetleri -%15, +2 Ekspertiz Sezgisi, Başlangıç Sermayesi ₺50.000
  tuccarTorunu,     // Tüccar Torunu: Alım fiyatlarında -%8, +2 Pazarlık, Atölye kilitli (Lv3'e kadar)
  sehirliYatirimci, // Şehirli Yatırımcı: Başlangıç ₺150.000, Banka faizi -%20, Ekspertiz Sezgisi tavanı 7
  koleksiyoncuYegeni, // Koleksiyoncu Yeğeni: Miras nadir araç ile başlar, Nadir araç değeri +%20, Sabit gider +%25
}

enum SpecializationPath {
  none,     // Henüz uzmanlaşma seçilmedi
  restorer, // Restoratör: Kaporta onarımı %100 başarı, Restore araçlarda +%25 değer, Hurdalıkta nadir parça şansı ×2
  trader,   // Tüccar: Pazarlıkta +2 hak, Müşteri arketipini önceden bilme, Alımda -%10 ek indirim
  boss,     // Patron: Yan işletme geliri +%30, Personel maaşı -%20, +2 Garaj slotu
}

class DealershipModel {
  final double balance;
  final int level;
  final int maxGarageSlots;
  final List<CarModel> ownedCars;
  final List<OfferModel> incomingOffers;
  final double totalProfit;
  final int carsSold;
  final DateTime lastActiveTime;
  final PlayerSkills skills;
  final List<AchievementItem> achievements;
  final int loginStreak;
  final DateTime lastLoginDate;
  final List<MissionModel> activeMissions;
  final MarketTrendModel marketTrend;
  final int reputationScore;
  final List<LoanModel> activeLoans;
  final List<PartOrderModel> pendingOrders;
  final List<StaffModel> hiredStaff;
  final List<CustomerReviewModel> customerReviews;
  final List<SaleRecordModel> salesHistory;
  final List<Cheque> activeCheques;
  final List<InstallmentContract> activeInstallments;
  final List<RentalAgreement> activeRentals;
  final bool tutorialCompleted;
  final int tutorialStepIndex;
  final int currentDay;
  final String playerName;
  final String dealershipName;
  final String logoEmblemId;
  final DateTime? lastRewardClaimDate;

  // RPG Kimlik, Köken, Uzmanlık ve NPC İlişkileri
  final CharacterOrigin characterOrigin;
  final SpecializationPath specializationPath;
  final Map<String, int> npcRelationships;
  final int dynastyGeneration;
  final List<String> dynastyHistoryLog;
  
  // Yeni Pasif Gelir ve Ekonomi Alanları
  final List<SideBusinessModel> sideBusinesses;
  final List<StockModel> marketStocks;
  final List<PlayerStockModel> ownedStocks;
  final List<PlayerForexModel> ownedForex;
  final List<ForexGoldModel> marketForex;
  final List<IpoOfferModel> activeIpos;
  final List<PlayerIpoRequestModel> playerIpoRequests;
  final List<GameEventModel> recentEvents;
  final double dailyTaxRate;

  // Yeni Haber, Hurdalık ve Karaborsa Alanları
  final MarketNewsModel? activeNews;
  final List<SalvagedPart> salvagedParts;
  final List<ScrapyardCar> scrapyardCars;
  final List<BlackMarketCarModel> blackMarketCars;
  final List<B2BPartOrder> b2bPartOrders;

  final Set<String> unlockedBuildings;

  // Story-Driven Rewarded Encounter Engine Fields
  final List<String> seenStoryCardIds;
  final int daysSinceLastStoryAd;
  final int nextStoryAdTargetDays;
  final StoryCardModel? pendingStoryCard;

  // Dramatic Decision Dilemma Cards Engine Fields
  final List<String> seenDramaticCardIds;
  final int daysSinceLastDramaticCard;
  final int nextDramaticCardTargetDays;
  final DramaticCardModel? pendingDramaticCard;

  // Random Event Engine Fields
  final List<String> seenRandomEventIds;
  final int daysSinceLastRandomEvent;
  final int nextRandomEventTargetDays;
  final GameEventModel? pendingRandomEvent;

  // Banka ve Personel Akademisi Kalıcı Durum Alanları
  final double bankDepositBalance;
  final double bankCreditLimit;
  final List<String> purchasedAcademyCourses;
  final List<String> unlockedDecorIds;
  final DateTime? lastScrapyardGigDate;
  final List<Map<String, dynamic>> pendingDopedOffers;
  final List<WantedCarContract> activeContracts;

  // Retention, Prestige & Collection Album Fields
  final bool hasStreakFreeze;
  final int prestigeLevel;
  final double prestigeMultiplier;
  final List<String> discoveredCarModelIds;
  final List<String> loyalCustomerNames;

  // Semt Hakimiyeti & Şehir Pazar Payı (§4.1)
  final Map<String, double> districtMarketShare;

  // İlk Kez Yapılan İşlem Takibi (First-Time Action Motivation)
  final Set<String> completedFirstTimeActions;

  // Son 7 Günlük Operasyonel Aktivite Sayaçları (Doluluk Katsayısı İçin - §1.2)
  final int carsWashedLast7Days;
  final int expertisesPerformedLast7Days;
  final int partsRepairedLast7Days;
  final int towedCarsLast7Days;
  final int rentalsCountLast7Days;

  // Müşteri İtibar Yankısı & Dürüst Esnaf Prestiji (§4.5)
  final int dirtyRecordCount;
  final int cleanSaleStreak;
  final String? pendingDisputeNotice;

  // Yeni Ekstra Mekanikler (§4.6)
  final List<TradeInOfferModel> incomingTradeInOffers; // Araba Takas Sistemi (§4.6.2)
  final List<GossipItemModel> activeGossips;           // Sanayi Dedikodu Hattı (§4.6.3)
  final WeatherType currentWeather;                   // Dinamik Hava Durumu (§4.6.5)
  final List<CarModel> consignmentOffers;             // Konsinye & Emanet Araçlar (§4.6.1)
  final int dailyRacesRemaining;                      // Gece Yarışı Günlük Kalan Hak (Exploit Koruması)
  final DateTime? nextAuctionAvailableDate;           // İhale Oturumu Kalıcı Bekleme Süresi (Exploit Koruması)

  // Ofis ve Günlük Reklam Fırsatları Takibi
  final int lastOfficeGrantClaimDay;
  final int lastSmartHookUsedDay;
  final int officeSeed;

  // Mağaza Puanlama & Öneri Tek Seferlik Ödül Takibi
  final bool hasReceivedReviewReward;

  // Tapu & Gayrimenkul Mülkiyet Alanları
  final Set<String> ownedBranchDeeds;

  // Medya & Fenomen PR Ajansı Kampanyası
  final ActivePrCampaign? activePrCampaign;

  // Kişisel Yaşam Tarzı, Gardırop & Prestij Masası
  final Set<String> ownedLifestyleItems;
  final String? equippedSuitId;
  final String? equippedAccessoryId;
  final String? equippedOfficeDecorId;

  bool get isOfficeGrantClaimedToday => lastOfficeGrantClaimDay >= currentDay;
  bool get isSmartHookClaimedToday => lastSmartHookUsedDay >= currentDay;

  double get totalDeedValue {
    double total = 0;
    for (final branch in BranchModel.getAllBranches(ownedDeeds: ownedBranchDeeds)) {
      if (ownedBranchDeeds.contains(branch.id)) {
        total += branch.deedCost;
      }
    }
    return total;
  }

  double get lifestyleNegotiationBonus {
    double bonus = 0.0;
    for (final item in LifestyleItemModel.allItems) {
      if (item.id == equippedSuitId || item.id == equippedAccessoryId || item.id == equippedOfficeDecorId) {
        bonus += item.negotiationBonus;
      }
    }
    return bonus;
  }

  double get lifestyleRichCustomerBonus {
    double bonus = 0.0;
    for (final item in LifestyleItemModel.allItems) {
      if (item.id == equippedSuitId || item.id == equippedAccessoryId || item.id == equippedOfficeDecorId) {
        bonus += item.richCustomerBonus;
      }
    }
    return bonus;
  }

  double get lifestyleInterestDiscount {
    double discount = 0.0;
    for (final item in LifestyleItemModel.allItems) {
      if (item.id == equippedSuitId || item.id == equippedAccessoryId || item.id == equippedOfficeDecorId) {
        discount += item.interestDiscount;
      }
    }
    return discount;
  }

  int get emblemIndex => int.tryParse(logoEmblemId.replaceAll(RegExp(r'\D'), '')) ?? 0;

  double get money => balance;
  int get reputation => reputationScore;
  int get experience => skills.xp;
  List<CarModel> get myCars => ownedCars;

  /// Kurumsal Kademe (Prestige Tiers §1.6)
  int get corporateTier {
    if (level >= 13) return 5; // Galeriler Şahı
    if (level >= 11) return 4; // Otomotiv Baronu
    if (level >= 9) return 3;  // Plaza Sahibi
    if (level >= 7) return 2;  // Bölge Bayii
    if (level >= 5) return 1;  // Sanayi Esnafı
    return 0; // Çırak & Küçük Esnaf
  }

  String get corporateTierTitle {
    switch (corporateTier) {
      case 5:
        return 'Galeriler Şahı • Kademe V';
      case 4:
        return 'Otomotiv Baronu • Kademe IV';
      case 3:
        return 'Plaza Sahibi • Kademe III';
      case 2:
        return 'Bölge Bayii • Kademe II';
      case 1:
        return 'Sanayi Esnafı • Kademe I';
      default:
        return 'Yerel Galeri • Başlangıç';
    }
  }

  DateTime get inGameTime => DateTime.now();

  /// Dynamic 28-day seasonal cycle
  GameSeason get currentSeason {
    final dayInCycle = ((currentDay - 1) % 28) + 1;
    if (dayInCycle <= 7) return GameSeason.spring;
    if (dayInCycle <= 14) return GameSeason.summer;
    if (dayInCycle <= 21) return GameSeason.autumn;
    return GameSeason.winter;
  }

  String get currentSeasonName {
    switch (currentSeason) {
      case GameSeason.spring:
        return 'İlkbahar';
      case GameSeason.summer:
        return 'Yaz';
      case GameSeason.autumn:
        return 'Sonbahar';
      case GameSeason.winter:
        return 'Kış';
    }
  }

  int get daysRemainingInSeason {
    final dayInCycle = ((currentDay - 1) % 28) + 1;
    final dayInSeason = ((dayInCycle - 1) % 7) + 1;
    return 7 - dayInSeason + 1;
  }

  /// Dynamic RPG Title combining Level and Esnaf Rep Score (§1.3, §2.3)
  String get rpgTitle {
    if (level <= 2) {
      if (reputationScore >= 80) return 'Dürüst Çırak';
      if (reputationScore >= 40) return 'Sanayi Çırağı';
      return 'Kurnaz Çırak';
    } else if (level <= 4) {
      if (reputationScore >= 80) return 'Güvenilir Esnaf';
      if (reputationScore >= 40) return 'Sanayi Esnafı';
      return 'Açıkgöz Galerici';
    } else if (level <= 7) {
      if (reputationScore >= 80) return 'Sanayinin Namuslu Adamı';
      if (reputationScore >= 40) return 'Usta Galerici';
      return 'Piyasa Kurdu';
    } else if (level <= 11) {
      if (reputationScore >= 80) return 'Duayen Galerici';
      if (reputationScore >= 40) return 'Oto Plaza Sahibi';
      return 'Oto Tüccarı';
    } else {
      if (reputationScore >= 80) return 'Galeriler Şahı';
      if (reputationScore >= 40) return 'Otomotiv Baronu';
      return 'Piyasa Hakimi';
    }
  }

  String get originTitle {
    switch (characterOrigin) {
      case CharacterOrigin.sanayiCiragi:
        return 'Sanayi Çırağı';
      case CharacterOrigin.tuccarTorunu:
        return 'Tüccar Torunu';
      case CharacterOrigin.sehirliYatirimci:
        return 'Şehirli Yatırımcı';
      case CharacterOrigin.koleksiyoncuYegeni:
        return 'Koleksiyoncu Yeğeni';
    }
  }

  String get originBonusDescription {
    switch (characterOrigin) {
      case CharacterOrigin.sanayiCiragi:
        return 'Onarım maliyetleri -%15, +2 Başlangıç Ekspertiz Sezgisi.';
      case CharacterOrigin.tuccarTorunu:
        return 'Araç alım fiyatlarında -%8, +2 Başlangıç Pazarlık Gücü.';
      case CharacterOrigin.sehirliYatirimci:
        return 'Başlangıç sermayesi ₺150.000, Banka faizlerinde -%20 avantaj.';
      case CharacterOrigin.koleksiyoncuYegeni:
        return 'Miras nadir koleksiyon aracı, Nadir araç piyasa değeri +%20.';
    }
  }

  String get specializationTitle {
    switch (specializationPath) {
      case SpecializationPath.none:
        return 'Genel Galericilik';
      case SpecializationPath.restorer:
        return 'Restoratör & Usta';
      case SpecializationPath.trader:
        return 'Pazar Kurdu & Tüccar';
      case SpecializationPath.boss:
        return 'Oto Baronu & Patron';
    }
  }

  String get specializationDescription {
    switch (specializationPath) {
      case SpecializationPath.none:
        return 'Seviye 4 veya 5\'e ulaştığında uzmanlık sınıfı seçebilirsin.';
      case SpecializationPath.restorer:
        return 'Kaporta & Mekanik onarımında %100 başarı, Restore araçlarda +%25 değer, Hurdalıkta nadir parça şansı ×2.';
      case SpecializationPath.trader:
        return 'Pazarlıkta +2 ek teklif hakkı, Müşteri niyetini anında bilme, Araç alımlarında -%10 ek indirim.';
      case SpecializationPath.boss:
        return 'Yan işletme gelirleri +%30, Personel maaşları -%20, +2 Bedava Garaj Slotu.';
    }
  }

  // Showroom Decor & Architecture RPG Helpers
  bool hasDecor(String decorId) => unlockedDecorIds.contains(decorId);
  int get unlockedDecorCount => unlockedDecorIds.length;
  double get negotiationPersuasionBonusPercent => hasDecor('decor_leather_chair_desk') ? 4.0 : 0.0;
  double get buyerWalkawayReductionPercent => hasDecor('decor_tesbih_lighter_stand') ? 20.0 : 0.0;
  double get consignmentDemandBonusPercent => hasDecor('decor_copper_samovar') ? 25.0 : 0.0;
  double get cashSaleProfitBonusMultiplier => hasDecor('decor_money_counter_safe') ? 1.02 : 1.0;
  bool get hasFullSecurityProtection => hasDecor('decor_security_cctv') || hasDecor('decor_laser_alarm_system');

  int getNpcRelation(String npcId) {
    return npcRelationships[npcId] ?? 50;
  }

  bool hasHighNpcTrust(String npcId) {
    return getNpcRelation(npcId) >= 70;
  }

  /// Season-based market demand modifier by car body type
  double getSeasonBodyTypeMultiplier(String bodyType) {
    final b = bodyType.toLowerCase();
    switch (currentSeason) {
      case GameSeason.spring:
        if (b.contains('hatchback') || b.contains('sedan')) return 1.15;
        if (b.contains('suv')) return 0.90;
        return 1.0;
      case GameSeason.summer:
        if (b.contains('spor') || b.contains('klasik') || b.contains('cabrio')) return 1.30;
        if (b.contains('suv') || b.contains('van')) return 0.85;
        return 1.0;
      case GameSeason.autumn:
        if (b.contains('sedan')) return 1.15;
        if (b.contains('spor')) return 0.85;
        return 1.0;
      case GameSeason.winter:
        if (b.contains('suv') || b.contains('4x4')) return 1.35;
        if (b.contains('spor')) return 0.75;
        return 1.0;
    }
  }

  static int getRequiredLevel(String route) {
    switch (route) {
      case '/marketplace':
      case '/showroom':
      case '/expertise':
      case '/branches':
      case '/character-growth':
      case '/settings':
      case '/dealership-identity':
      case '/theme-store':
        return 1;
      case '/car-wash':
      case '/history':
        return 2;
      case '/workshop':
      case '/staff':
      case '/staff-academy':
        return 3;
      case '/tuning-studio':
      case '/showroom-decor':
        return 4;
      case '/auction':
      case '/finance':
      case '/reviews':
        return 5;
      case '/bank-investments':
      case '/stock-market':
        return 6;
      case '/rent-a-car':
      case '/black-market':
      case '/district-market':
      case '/districts':
      case '/gossip-hotline':
      case '/gossip':
        return 7;
      case '/scrapyard':
      case '/side-businesses':
      case '/consignment-market':
      case '/consignment':
      case '/second-branch':
      case '/vip-appointments':
      case '/customs-import':
      case '/guild-chamber':
      case '/franchise':
      case '/prestige-dynasty':
        return 8;
      default:
        return 1;
    }
  }

  static String getRequiredBranchName(String route) {
    final reqLvl = getRequiredLevel(route);
    switch (reqLvl) {
      case 1:
        return 'Kaldırım Başı Ayakçı Galerisi • Seviye 1';
      case 2:
        return 'Mahalle Tipi Açık Oto Galeri • Seviye 2';
      case 3:
        return 'Sanayi Sitesi Esnaf Galerisi • Seviye 3';
      case 4:
        return 'Cadde Üstü Butik Oto Galeri • Seviye 4';
      case 5:
        return 'Oto Center Kurumsal Galeri • Seviye 5';
      case 6:
        return 'Premium Cam Showroom Plaza • Seviye 6';
      case 7:
        return 'Lüks Koleksiyoner VIP Galeri • Seviye 7';
      case 8:
        return 'Mega Otomotiv Holding Plazası • Seviye 8';
      default:
        return 'Kaldırım Başı Ayakçı Galerisi';
    }
  }

  static String getBranchNameForTier(int tier) {
    switch (tier) {
      case 1:
        return 'Kaldırım Başı Ayakçı Galerisi • Seviye 1';
      case 2:
        return 'Mahalle Tipi Açık Oto Galeri • Seviye 2';
      case 3:
        return 'Sanayi Sitesi Esnaf Galerisi • Seviye 3';
      case 4:
        return 'Cadde Üstü Butik Oto Galeri • Seviye 4';
      case 5:
        return 'Oto Center Kurumsal Galeri • Seviye 5';
      case 6:
        return 'Premium Cam Showroom Plaza • Seviye 6';
      case 7:
        return 'Lüks Koleksiyoner VIP Galeri • Seviye 7';
      case 8:
        return 'Mega Otomotiv Holding Plazası • Seviye 8';
      default:
        return 'Kaldırım Başı Ayakçı Galerisi • Seviye 1';
    }
  }

  int get currentBranchTier {
    if (unlockedBuildings.contains('property_tier_8')) return 8;
    if (unlockedBuildings.contains('property_tier_7')) return 7;
    if (unlockedBuildings.contains('property_tier_6')) return 6;
    if (unlockedBuildings.contains('property_tier_5')) return 5;
    if (unlockedBuildings.contains('property_tier_4')) return 4;
    if (unlockedBuildings.contains('property_tier_3')) return 3;
    if (unlockedBuildings.contains('property_tier_2')) return 2;
    return 1;
  }

  String get currentBranchName => getBranchNameForTier(currentBranchTier);

  bool isFeatureUnlocked(String route) {
    if (route == '/gossip' || route == '/gossip-hotline') {
      return unlockedBuildings.contains('/gossip') ||
          unlockedBuildings.contains('/gossip-hotline') ||
          unlockedBuildings.contains('property_tier_7') ||
          unlockedBuildings.contains('property_tier_8');
    }
    if (route == '/consignment' || route == '/consignment-market') {
      return unlockedBuildings.contains('/consignment') ||
          unlockedBuildings.contains('/consignment-market') ||
          unlockedBuildings.contains('property_tier_8');
    }
    if (route == '/districts' || route == '/district-market') {
      return unlockedBuildings.contains('/districts') ||
          unlockedBuildings.contains('/district-market') ||
          unlockedBuildings.contains('property_tier_7') ||
          unlockedBuildings.contains('property_tier_8');
    }
    if (route == '/night-market') {
      return true;
    }
    return unlockedBuildings.contains(route);
  }

  DealershipModel({
    required this.balance,
    required this.level,
    required this.maxGarageSlots,
    required this.ownedCars,
    required this.incomingOffers,
    required this.totalProfit,
    required this.carsSold,
    required this.lastActiveTime,
    required this.skills,
    required this.achievements,
    required this.loginStreak,
    required this.lastLoginDate,
    required this.activeMissions,
    required this.marketTrend,
    this.reputationScore = 100,
    this.activeLoans = const [],
    this.pendingOrders = const [],
    this.hiredStaff = const [],
    this.customerReviews = const [],
    this.salesHistory = const [],
    this.activeCheques = const [],
    this.activeInstallments = const [],
    this.activeRentals = const [],
    this.tutorialCompleted = false,
    this.tutorialStepIndex = 0,
    this.currentDay = 1,
    this.playerName = 'Kaptan',
    this.dealershipName = 'Miras Oto Galeri',
    this.logoEmblemId = 'crown',
    this.lastRewardClaimDate,
    this.sideBusinesses = const [],
    this.marketStocks = const [],
    this.ownedStocks = const [],
    this.ownedForex = const [],
    this.marketForex = const [],
    this.activeIpos = const [],
    this.playerIpoRequests = const [],
    this.recentEvents = const [],
    this.dailyTaxRate = 150.0,
    this.activeNews,
    this.salvagedParts = const [],
    this.scrapyardCars = const [],
    this.blackMarketCars = const [],
    this.b2bPartOrders = const [],
    this.unlockedBuildings = const {},
    this.seenStoryCardIds = const [],
    this.daysSinceLastStoryAd = 0,
    this.nextStoryAdTargetDays = 14,
    this.pendingStoryCard,
    this.seenDramaticCardIds = const [],
    this.daysSinceLastDramaticCard = 0,
    this.nextDramaticCardTargetDays = 20,
    this.pendingDramaticCard,
    this.seenRandomEventIds = const [],
    this.daysSinceLastRandomEvent = 0,
    this.nextRandomEventTargetDays = 7,
    this.pendingRandomEvent,
    this.bankDepositBalance = 0.0,
    this.bankCreditLimit = 250000.0,
    this.purchasedAcademyCourses = const [],
    this.unlockedDecorIds = const [],
    this.lastScrapyardGigDate,
    this.pendingDopedOffers = const [],
    this.activeContracts = const [],
    this.hasStreakFreeze = false,
    this.prestigeLevel = 0,
    this.prestigeMultiplier = 1.0,
    this.discoveredCarModelIds = const [],
    this.loyalCustomerNames = const [],
    this.characterOrigin = CharacterOrigin.sanayiCiragi,
    this.specializationPath = SpecializationPath.none,
    this.npcRelationships = const {
      'haydar_usta': 50,
      'cikmaci_ibo': 50,
      'golge_ibrahim': 50,
      'vlogger_berk': 50,
      'necati': 50,
      'usta_selim': 50,
    },
    this.dynastyGeneration = 1,
    this.dynastyHistoryLog = const [],
    this.districtMarketShare = const {
      'İkitelli Sanayi': 0.05,
      'Maslak Plaza': 0.05,
      'Bağcılar Oto Pazarı': 0.05,
      'Nişantaşı Vitrin': 0.02,
      'Kadıköy Klasik Sokağı': 0.02,
      'Ankara Kızılay Hattı': 0.05,
    },
    this.carsWashedLast7Days = 0,
    this.expertisesPerformedLast7Days = 0,
    this.partsRepairedLast7Days = 0,
    this.towedCarsLast7Days = 0,
    this.rentalsCountLast7Days = 0,
    this.dirtyRecordCount = 0,
    this.cleanSaleStreak = 0,
    this.pendingDisputeNotice,
    this.incomingTradeInOffers = const [],
    this.activeGossips = const [],
    this.currentWeather = WeatherType.sunny,
    this.consignmentOffers = const [],
    this.dailyRacesRemaining = 3,
    this.nextAuctionAvailableDate,
    this.completedFirstTimeActions = const {},
    this.lastOfficeGrantClaimDay = 0,
    this.lastSmartHookUsedDay = 0,
    this.officeSeed = 0,
    this.hasReceivedReviewReward = false,
    this.ownedBranchDeeds = const {},
    this.activePrCampaign,
    this.ownedLifestyleItems = const {},
    this.equippedSuitId,
    this.equippedAccessoryId,
    this.equippedOfficeDecorId,
  });

  factory DealershipModel.initial() {
    final now = DateTime.now();
    // Inherited Heritage Car from grandfather Hasan Usta
    final heritageCar = CarModel(
      id: 'car_heritage_dede',
      brand: 'Tofaşk',
      modelName: 'Tofaşk Hacı Murat 124 • Dede Mirası',
      modelYear: 1978,
      bodyType: 'Klasik',
      colorHex: '0xFF8B4513', // Saddle Brown
      colorDisplayName: 'Tütün Kahvesi',
      colorRarity: 'rare',
      plateNumber: '34 DEDE 78',
      plateRarity: 'legendary',
      baseMarketValue: 240000.0,
      currentPurchasePrice: 0.0, // Inherited for free
      isRare: true,
      expertise: ExpertiseReport(
        engineCondition: 40.0, // Low condition engine
        transmissionCondition: 50.0, // Low condition gearbox
        tramerAmount: 12500,
        mileage: 215000,
        isMileageTampered: false,
        bodyParts: {
          'Kaput': PartStatus.damaged,
          'Tavan': PartStatus.painted,
          'Sol Kapı': PartStatus.changed,
          'Sağ Kapı': PartStatus.damaged,
          'Bagaj': PartStatus.painted,
        },
        partConditions: {
          'Kaput': 25.0,
          'Tavan': 65.0,
          'Sol Kapı': 45.0,
          'Sağ Kapı': 30.0,
          'Bagaj': 70.0,
        },
      ),
    );

    return DealershipModel(
      balance: 75000.0, // Starting money: 75k TL
      level: 1,
      maxGarageSlots: 3,
      ownedCars: [heritageCar],
      incomingOffers: [],
      totalProfit: 0.0,
      carsSold: 0,
      lastActiveTime: now,
      skills: PlayerSkills(),
      achievements: PlayerAchievements.initialList,
      loginStreak: 1,
      lastLoginDate: now,
      activeMissions: [
        MissionModel(
          id: 'm_heritage_1',
          title: 'Dede Mirası',
          description: 'Miras arabayı onarıp ilk satışını yap',
          type: MissionType.sellCars,
          currentProgress: 0,
          targetGoal: 1,
          rewardMoney: 35000,
          rewardXP: 250,
        ),
      ],
      marketTrend: MarketTrendModel.defaultTrend(),
      activeLoans: const [],
      pendingOrders: const [],
      activeCheques: const [],
      activeInstallments: const [],
      activeRentals: const [],
      salesHistory: const [],
      tutorialCompleted: false,
      tutorialStepIndex: 0,
      sideBusinesses: [
        SideBusinessModel(
          id: 'sb_1',
          name: 'Otomat & Kahve İstasyonu',
          description: 'Galeri müşterilerine taze çekirdek espresso ve soğuk meşrubat satarak günlük pasif gelir sağla.',
          type: SideBusinessType.vendingMachine,
          dailyIncome: 450.0,
          cost: 25000.0,
          managerTitle: 'Kafeterya Sorumlusu Canan Hanım',
          managerCost: 15000.0,
          managerSalary: 120.0,
          managerBonusPercent: 0.20,
          upgrades: [
            SideBusinessUpgradeModel(id: 'sb_1_u1', title: 'İtalyan Espresso Öğütücü', description: 'Gelen müşterilerin bekleme süresinde taze kahve tüketimini artıran barista modülü.', cost: 9000.0, bonusDailyIncome: 250.0, iconName: 'coffee'),
            SideBusinessUpgradeModel(id: 'sb_1_u2', title: 'Soğuk İçecek & Enerji Kutusu Modülü', description: 'Yaz aylarında otomat satışlarını ikiye katlayan soğutucu hazne.', cost: 15000.0, bonusDailyIncome: 450.0, iconName: 'local_drink'),
            SideBusinessUpgradeModel(id: 'sb_1_u3', title: 'Temassız POS Ödeme Terminali', description: 'Nakit taşımayan müşterilerin doğrudan NFC & Kredi Kartı ile ödeme yapmasını sağlar.', cost: 27000.0, bonusDailyIncome: 750.0, iconName: 'credit_card'),
            SideBusinessUpgradeModel(id: 'sb_1_u4', title: 'Akıllı Atıştırmalık & Sandviç Dolabı', description: 'Gece ve gündüz 24 saat kesintisiz taze gıda imkanı.', cost: 42000.0, bonusDailyIncome: 1200.0, iconName: 'restaurant'),
          ],
        ),
        SideBusinessModel(
          id: 'sb_2',
          name: 'Oto Yıkama & Detaylandırma Merkezi',
          description: 'Galerinin yanında profesyonel oto yıkama, köpük tüneli ve iç temizleme peronu kur.',
          type: SideBusinessType.carWash,
          dailyIncome: 1400.0,
          cost: 95000.0,
          managerTitle: 'Yıkama Amiri İsmail Usta',
          managerCost: 45000.0,
          managerSalary: 300.0,
          managerBonusPercent: 0.20,
          upgrades: [
            SideBusinessUpgradeModel(id: 'sb_2_u1', title: 'Köpük Tabancası & Seramik Şampuan', description: 'Hızlı yıkama kapasitesini artırır ve araç başına kâr marjını yükseltir.', cost: 36000.0, bonusDailyIncome: 900.0, iconName: 'water_drop'),
            SideBusinessUpgradeModel(id: 'sb_2_u2', title: 'Otomatik Fırçasız Yıkama Tüneli', description: 'Dakikada 2 araç yıkayan tam otomatik yüksek basınçlı konveyör tünel.', cost: 75000.0, bonusDailyIncome: 1950.0, iconName: 'precision_manufacturing'),
            SideBusinessUpgradeModel(id: 'sb_2_u3', title: 'VIP Buharlı Sterilizasyon & Detay', description: 'Araç içi bakterileri yok eden, deri ve döşeme yenileyen VIP alan.', cost: 135000.0, bonusDailyIncome: 3600.0, iconName: 'clean_hands'),
            SideBusinessUpgradeModel(id: 'sb_2_u4', title: 'Seramik Kaplama & Pasta Cila Pad’i', description: 'Sıfır ve ikinci el araçlara profesyonel boya koruma uygulaması.', cost: 225000.0, bonusDailyIncome: 6300.0, iconName: 'auto_awesome'),
          ],
        ),
        SideBusinessModel(
          id: 'sb_3',
          name: 'Dijital Reklam Panosu & Medya Cephesi',
          description: 'Galerinin caddeye bakan cephesine LED panolar kurarak dev markalardan kurumsal reklam al.',
          type: SideBusinessType.billboard,
          dailyIncome: 2800.0,
          cost: 220000.0,
          managerTitle: 'Medya & Reklam Müdürü Sibel Hanım',
          managerCost: 75000.0,
          managerSalary: 450.0,
          managerBonusPercent: 0.20,
          upgrades: [
            SideBusinessUpgradeModel(id: 'sb_3_u1', title: '4K Ultra HD LED Panel Upgrade', description: 'Yüksek çözünürlüklü ekranlarla premium markalardan reklam al.', cost: 105000.0, bonusDailyIncome: 2250.0, iconName: 'tv'),
            SideBusinessUpgradeModel(id: 'sb_3_u2', title: 'Lazer Gece Gösterisi & 3D Projektör', description: 'Gece trafiğinde sürücülerin dikkatini çeken ikonik lazer gösterisi.', cost: 195000.0, bonusDailyIncome: 4500.0, iconName: 'wb_incandescent'),
            SideBusinessUpgradeModel(id: 'sb_3_u3', title: 'Kurumsal Sigorta & Akaryakıt Sponsorluğu', description: 'Ulusal oto sigorta ve petrol devleriyle sabit yıllık reklam sözleşmesi.', cost: 330000.0, bonusDailyIncome: 7800.0, iconName: 'handshake'),
            SideBusinessUpgradeModel(id: 'sb_3_u4', title: 'AI Odaklı Canlı Trafik Reklam Sistemi', description: 'Kamera verileriyle yoldan geçen araç segmentine göre anlık reklam değiştirir.', cost: 510000.0, bonusDailyIncome: 12600.0, iconName: 'psychology'),
          ],
        ),
        SideBusinessModel(
          id: 'sb_4',
          name: '7/24 Oto Çekici & Kurtarma Filosu',
          description: 'Otobanda veya şehir içinde yolda kalan araçlara 7/24 çekici ve vinç hizmeti ver.',
          type: SideBusinessType.towTruck,
          dailyIncome: 5200.0,
          cost: 450000.0,
          managerTitle: 'Filo Başşoförü Kadir Usta',
          managerCost: 105000.0,
          managerSalary: 750.0,
          managerBonusPercent: 0.20,
          upgrades: [
            SideBusinessUpgradeModel(id: 'sb_4_u1', title: 'Hidrolik Kayar Kasa Vinç', description: 'Lüks ve alçak tabanlı spor araçları sıfır hasarla çekme yeteneği.', cost: 180000.0, bonusDailyIncome: 4200.0, iconName: 'minor_crash'),
            SideBusinessUpgradeModel(id: 'sb_4_u2', title: 'Gece Acil Yol Yardım Sözleşmesi', description: 'Sigorta acenteleriyle anlaşarak gece çağrılarına özel yüksek tarife uygula.', cost: 330000.0, bonusDailyIncome: 8400.0, iconName: 'emergency'),
            SideBusinessUpgradeModel(id: 'sb_4_u3', title: 'Çift Araç Taşıyıcı Ağır Treyler', description: 'Aynı anda 2 aracı birden taşıyabilen ağır hizmet çekici kamyonu.', cost: 540000.0, bonusDailyIncome: 14400.0, iconName: 'fire_truck'),
            SideBusinessUpgradeModel(id: 'sb_4_u4', title: 'Otoyol Devriye Lojistik Merkezi', description: 'Otoyol gişelerine yakın lojistik istasyonuyla çağrı süresini 10 dakikaya indirir.', cost: 840000.0, bonusDailyIncome: 24000.0, iconName: 'alt_route'),
          ],
        ),
        SideBusinessModel(
          id: 'sb_5',
          name: 'Oto Aksesuar & Tuning Store',
          description: 'Galerinin içinde yedek parça, kokpit aksesuarları, jant ve ses sistemleri satan mağaza aç.',
          type: SideBusinessType.autoShop,
          dailyIncome: 2500.0,
          cost: 180000.0,
          managerTitle: 'Tuning Mağaza Müdürü Hakan Bey',
          managerCost: 60000.0,
          managerSalary: 360.0,
          managerBonusPercent: 0.20,
          upgrades: [
            SideBusinessUpgradeModel(id: 'sb_5_u1', title: 'Oto Kokusu & Seramik Bakım Stantı', description: 'Hızlı tüketim araç bakım kimyasalları ve lüks oto kokuları stantı.', cost: 75000.0, bonusDailyIncome: 1650.0, iconName: 'sanitizer'),
            SideBusinessUpgradeModel(id: 'sb_5_u2', title: 'Performans Egzoz & Tuning Reyonu', description: 'Spor araç tutkunları için açık hava filtreleri, chip tuning ve egzoz sistemleri.', cost: 135000.0, bonusDailyIncome: 3300.0, iconName: 'speed'),
            SideBusinessUpgradeModel(id: 'sb_5_u3', title: 'Lüks Jant & Lastik Teşhir Vitrini', description: 'Çelik ve döküm alaşım 18-22 inç performans jant takımları vitrini.', cost: 240000.0, bonusDailyIncome: 6000.0, iconName: 'tire_repair'),
            SideBusinessUpgradeModel(id: 'sb_5_u4', title: 'Online E-Ticaret & Kargo Entegrasyonu', description: 'Tüm Türkiye’ye İnternet üzerinden aksesuar ve tuning parçaları kargolama.', cost: 390000.0, bonusDailyIncome: 10200.0, iconName: 'local_shipping'),
          ],
        ),
        SideBusinessModel(
          id: 'sb_6',
          name: 'Oto Ekspertiz & Muayene İstasyonu',
          description: 'İkinci el araç alım-satımında motor, kaporta, şase ve beyin ekspertizi yaparak kurumsal güven sağla.',
          type: SideBusinessType.inspectionStation,
          dailyIncome: 4200.0,
          cost: 350000.0,
          managerTitle: 'Başeksper Turgut Usta',
          managerCost: 90000.0,
          managerSalary: 600.0,
          managerBonusPercent: 0.25,
          upgrades: [
            SideBusinessUpgradeModel(id: 'sb_6_u1', title: 'Dinamometre Dyno Güç Test Cihazı', description: 'Motor BG ve tork performansını milisaniyelik ölçen silindir dyno testi.', cost: 120000.0, bonusDailyIncome: 2850.0, iconName: 'speed'),
            SideBusinessUpgradeModel(id: 'sb_6_u2', title: 'Dijital Süspansiyon & Fren Test Hattı', description: 'Amortisör verimliliği ve fren sapmalarını bilgisayarlı rampada test etme.', cost: 225000.0, bonusDailyIncome: 5400.0, iconName: 'build_circle'),
            SideBusinessUpgradeModel(id: 'sb_6_u3', title: 'OBD2 Ağır Vasıta Beyin Tarayıcı', description: 'Gizlenen kilometre ve geçmiş arıza kodlarını ortaya çıkaran lisanslı tarayıcı.', cost: 390000.0, bonusDailyIncome: 9900.0, iconName: 'memory'),
            SideBusinessUpgradeModel(id: 'sb_6_u4', title: 'Mikron Kaporta & Şase Lazer Cihazı', description: 'Kazalı veya boyalı parçaları mikron hassasiyetinde tespit eden mikroskopik tarayıcı.', cost: 630000.0, bonusDailyIncome: 16500.0, iconName: 'center_focus_strong'),
          ],
        ),
        SideBusinessModel(
          id: 'sb_7',
          name: 'Oto Kiralama & VIP Filo Hizmetleri',
          description: 'Galerideki araçları veya özel filoyu günlük, haftalık ve kurumsal bazda kiralayarak yüksek gelir elde et.',
          type: SideBusinessType.carRental,
          dailyIncome: 7800.0,
          cost: 650000.0,
          managerTitle: 'Filo Operasyon Müdürü Zeynep Hanım',
          managerCost: 135000.0,
          managerSalary: 900.0,
          managerBonusPercent: 0.25,
          upgrades: [
            SideBusinessUpgradeModel(id: 'sb_7_u1', title: 'Şehir İçi Günlük Kiralama Filosu', description: 'Havalimanı ve otogarlarda turistlere ve iş insanlarına araç teslimi.', cost: 270000.0, bonusDailyIncome: 6000.0, iconName: 'flight_land'),
            SideBusinessUpgradeModel(id: 'sb_7_u2', title: 'VIP Makam Aracı & Şoförlü Transfer', description: 'Siyah camlı lüks SUV ve sedan araçlarla özel lansman transferleri.', cost: 480000.0, bonusDailyIncome: 12000.0, iconName: 'airline_seat_recline_extra'),
            SideBusinessUpgradeModel(id: 'sb_7_u3', title: 'Kurumsal Şirket Filo Sözleşmeleri', description: 'Holdinglere 12 aylık filo kiralama yaparak düzenli nakit akışı oluşturma.', cost: 810000.0, bonusDailyIncome: 21600.0, iconName: 'business_center'),
            SideBusinessUpgradeModel(id: 'sb_7_u4', title: 'Akıllı Mobil Araç Paylaşım Uygulaması', description: 'Müşterilerin cep telefonundan kapısını açıp dakika bazlı kiralama yapması.', cost: 1260000.0, bonusDailyIncome: 34500.0, iconName: 'phone_android'),
          ],
        ),
        SideBusinessModel(
          id: 'sb_8',
          name: 'Oto Elektrik & EV Hızlı Şarj Hub’ı',
          description: 'Geleceğin otomotiv teknolojisi: Elektrikli araçlar için ultra hızlı DC şarj istasyonu ve batarya servisi.',
          type: SideBusinessType.evCharging,
          dailyIncome: 10500.0,
          cost: 900000.0,
          managerTitle: 'Elektrik Mühendisi Burak Bey',
          managerCost: 165000.0,
          managerSalary: 1200.0,
          managerBonusPercent: 0.25,
          upgrades: [
            SideBusinessUpgradeModel(id: 'sb_8_u1', title: 'AC Type-2 22kW Şarj Prizleri', description: 'Park halindeki araçların 2-4 saatte şarj olmasını sağlayan standart peronlar.', cost: 360000.0, bonusDailyIncome: 8400.0, iconName: 'electric_car'),
            SideBusinessUpgradeModel(id: 'sb_8_u2', title: 'DC 180kW Ultra Hızlı Supercharger', description: '20 dakikada %80 şarj sağlayan sıvı soğutmalı yüksek voltajlı şarj üniteleri.', cost: 660000.0, bonusDailyIncome: 16500.0, iconName: 'bolt'),
            SideBusinessUpgradeModel(id: 'sb_8_u3', title: 'Güneş Panelli Depolama Çatısı', description: 'İstasyon çatısına kurulan solar panellerle elektrik maliyetini sıfırlama.', cost: 1080000.0, bonusDailyIncome: 28500.0, iconName: 'solar_power'),
            SideBusinessUpgradeModel(id: 'sb_8_u4', title: 'Batarya Sağlık Ölçüm & Değişim Merkezi', description: 'EV araç bataryalarının hücre bazında tamiri ve hızlı batarya takas istasyonu.', cost: 1650000.0, bonusDailyIncome: 45000.0, iconName: 'battery_charging_full'),
          ],
        ),
        SideBusinessModel(
          id: 'sb_9',
          name: 'Kurumsal Oto Ekspertiz Bayii',
          description: 'Noter onaylı, garantili ekspertiz raporları ve ekspertiz sigortası ile alım-satım işlemlerine tam güven sağla.',
          type: SideBusinessType.corporateExpertise,
          dailyIncome: 22500.0,
          cost: 550000.0,
          managerTitle: 'Ekspertiz Şube Müdürü Erhan Bey',
          managerCost: 105000.0,
          managerSalary: 900.0,
          managerBonusPercent: 0.25,
          upgrades: [
            SideBusinessUpgradeModel(id: 'sb_9_u1', title: 'Lazer Şase Ölçüm Çatısı', description: 'Şase eğriliklerini 0.1 mm hassasiyetle tespit eden lazer rampa.', cost: 135000.0, bonusDailyIncome: 5400.0, iconName: 'precision_manufacturing'),
            SideBusinessUpgradeModel(id: 'sb_9_u2', title: 'Noter & Sigorta Entegrasyon Lisansı', description: 'Devir işlemlerinde anında noter onaylı dijital rapor üretimi.', cost: 240000.0, bonusDailyIncome: 10500.0, iconName: 'verified'),
            SideBusinessUpgradeModel(id: 'sb_9_u3', title: 'Ağır Vasıta & Ticari Dyno Testi', description: 'Kamyonet ve ticari filolar için yüksek torklu ekspertiz peronu.', cost: 420000.0, bonusDailyIncome: 18600.0, iconName: 'speed'),
            SideBusinessUpgradeModel(id: 'sb_9_u4', title: 'Garantili Ekspertiz Kasko Sigortası', description: 'Raporlanan araçlara 1 yıl 50.000 km mekanik garanti teminatı.', cost: 660000.0, bonusDailyIncome: 31500.0, iconName: 'shield'),
          ],
        ),
        SideBusinessModel(
          id: 'sb_10',
          name: 'Oto Yedek Parça & Depo Merkezi',
          description: 'Orijinal OEM ve muadil yedek parça satışı, toptan sanayi dağıtımı ve e-ticaret lojistiği.',
          type: SideBusinessType.sparePartsStore,
          dailyIncome: 42000.0,
          cost: 950000.0,
          managerTitle: 'Depo & Lojistik Müdürü Selim Bey',
          managerCost: 150000.0,
          managerSalary: 1350.0,
          managerBonusPercent: 0.25,
          upgrades: [
            SideBusinessUpgradeModel(id: 'sb_10_u1', title: 'Otomatik Dikey Depo Raf Sistemi', description: 'Parça arama süresini 5 saniyeye indiren akıllı robotik raf alanı.', cost: 225000.0, bonusDailyIncome: 9600.0, iconName: 'inventory_2'),
            SideBusinessUpgradeModel(id: 'sb_10_u2', title: 'B2B Sanayi Dağıtım Filosu', description: 'Şehirdeki tüm tamirhanelere günlük düzenli yedek parça servisi.', cost: 390000.0, bonusDailyIncome: 18000.0, iconName: 'local_shipping'),
            SideBusinessUpgradeModel(id: 'sb_10_u3', title: 'Almanya & Japonya İthalat Lisansı', description: 'Doğrudan üreticiden parça ithal ederek kâr marjını 2 katına çıkar.', cost: 660000.0, bonusDailyIncome: 33000.0, iconName: 'flight_takeoff'),
            SideBusinessUpgradeModel(id: 'sb_10_u4', title: 'Oto Parça E-Ticaret & Pazaryeri Entegrasyonu', description: 'İnternet üzerinden tüm Türkiye’ye dakikada 5 parça siparişi kargolama.', cost: 1050000.0, bonusDailyIncome: 54000.0, iconName: 'shopping_cart'),
          ],
        ),
        SideBusinessModel(
          id: 'sb_11',
          name: 'Lüks Araç Wrap & Folyo Stüdyosu',
          description: 'Süper spor ve lüks otomobiller için PPF şeffaf koruma folyosu, renk değişimi ve özel tasarım kaplama.',
          type: SideBusinessType.wrapStudio,
          dailyIncome: 95000.0,
          cost: 1800000.0,
          managerTitle: 'Master Wrap Tasarımcısı Murat Bey',
          managerCost: 240000.0,
          managerSalary: 2100.0,
          managerBonusPercent: 0.30,
          upgrades: [
            SideBusinessUpgradeModel(id: 'sb_11_u1', title: 'Self-Healing TPU PPF Kaplama Seti', description: 'Çizikleri ısı ile kendi kendine onaran 200 mikron şeffaf koruma zırhı.', cost: 450000.0, bonusDailyIncome: 21000.0, iconName: 'auto_fix_high'),
            SideBusinessUpgradeModel(id: 'sb_11_u2', title: 'Mat & Krom Özel Renk Kataloğu', description: 'Ekzotik mat, buzağı ve bukalemun renk değişim folyoları stantı.', cost: 780000.0, bonusDailyIncome: 39000.0, iconName: 'palette'),
            SideBusinessUpgradeModel(id: 'sb_11_u3', title: 'İklim Kontrollü Tozsuz Steril Kabin', description: 'Sıfır toz garantisiyle kusursuz folyo kaplama yapılan özel hava kabini.', cost: 1260000.0, bonusDailyIncome: 66000.0, iconName: 'air'),
            SideBusinessUpgradeModel(id: 'sb_11_u4', title: 'Karbon Fiber & Aerodinamik Body Kit Stüdyosu', description: 'Gerçek kuru karbon kaput, kanat ve aero parçaları montaj alanı.', cost: 1950000.0, bonusDailyIncome: 105000.0, iconName: 'sports_motorsports'),
          ],
        ),
      ],
      marketStocks: StockModel.defaultStocks,
      ownedStocks: const [],
      ownedForex: const [],
      marketForex: ForexGoldModel.defaultForex,
      activeIpos: IpoOfferModel.defaultIpos(1),
      playerIpoRequests: const [],
      recentEvents: const [],
      dailyTaxRate: 150.0,
      unlockedBuildings: const {
        '/marketplace',
        '/showroom',
        '/expertise',
        '/character-growth',
        '/settings',
        '/dealership-identity',
        '/theme-store',
        '/branches',
      },
      discoveredCarModelIds: const ['Tofaşk Hacı Murat 124 • Dede Mirası'],
      pendingDopedOffers: const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'level': level,
      'maxGarageSlots': maxGarageSlots,
      'ownedCars': ownedCars.map((c) => c.toJson()).toList(),
      'incomingOffers': incomingOffers.map((o) => o.toJson()).toList(),
      'totalProfit': totalProfit,
      'carsSold': carsSold,
      'lastActiveTime': lastActiveTime.toIso8601String(),
      'skills': skills.toJson(),
      'achievements': achievements.map((a) => a.toJson()).toList(),
      'loginStreak': loginStreak,
      'lastLoginDate': lastLoginDate.toIso8601String(),
      'activeMissions': activeMissions.map((m) => m.toJson()).toList(),
      'marketTrend': marketTrend.toJson(),
      'reputationScore': reputationScore,
      'activeLoans': activeLoans.map((l) => l.toJson()).toList(),
      'pendingOrders': pendingOrders.map((p) => p.toJson()).toList(),
      'hiredStaff': hiredStaff.map((s) => s.toJson()).toList(),
      'customerReviews': customerReviews.map((r) => r.toJson()).toList(),
      'salesHistory': salesHistory.map((s) => s.toJson()).toList(),
      'activeCheques': activeCheques.map((c) => c.toJson()).toList(),
      'activeInstallments': activeInstallments.map((i) => i.toJson()).toList(),
      'activeRentals': activeRentals.map((r) => r.toJson()).toList(),
      'tutorialCompleted': tutorialCompleted,
      'tutorialStepIndex': tutorialStepIndex,
      'currentDay': currentDay,
      'playerName': playerName,
      'dealershipName': dealershipName,
      'logoEmblemId': logoEmblemId,
      'lastRewardClaimDate': lastRewardClaimDate?.toIso8601String(),
      'sideBusinesses': sideBusinesses.map((e) => e.toJson()).toList(),
      'marketStocks': marketStocks.map((e) => e.toJson()).toList(),
      'ownedStocks': ownedStocks.map((e) => e.toJson()).toList(),
      'ownedForex': ownedForex.map((f) => f.toJson()).toList(),
      'marketForex': marketForex.map((f) => f.toJson()).toList(),
      'activeIpos': activeIpos.map((i) => i.toJson()).toList(),
      'playerIpoRequests': playerIpoRequests.map((r) => r.toJson()).toList(),
      'recentEvents': recentEvents.map((e) => e.toJson()).toList(),
      'dailyTaxRate': dailyTaxRate,
      'activeNews': activeNews?.toJson(),
      'salvagedParts': salvagedParts.map((p) => p.toJson()).toList(),
      'scrapyardCars': scrapyardCars.map((c) => c.toJson()).toList(),
      'blackMarketCars': blackMarketCars.map((c) => c.toJson()).toList(),
      'b2bPartOrders': b2bPartOrders.map((o) => o.toJson()).toList(),
      'unlockedBuildings': unlockedBuildings.toList(),
      'seenStoryCardIds': seenStoryCardIds,
      'daysSinceLastStoryAd': daysSinceLastStoryAd,
      'nextStoryAdTargetDays': nextStoryAdTargetDays,
      'pendingStoryCard': pendingStoryCard?.toJson(),
      'seenDramaticCardIds': seenDramaticCardIds,
      'daysSinceLastDramaticCard': daysSinceLastDramaticCard,
      'nextDramaticCardTargetDays': nextDramaticCardTargetDays,
      'pendingDramaticCard': pendingDramaticCard?.toJson(),
      'seenRandomEventIds': seenRandomEventIds,
      'daysSinceLastRandomEvent': daysSinceLastRandomEvent,
      'nextRandomEventTargetDays': nextRandomEventTargetDays,
      'pendingRandomEvent': pendingRandomEvent?.toJson(),
      'bankDepositBalance': bankDepositBalance,
      'bankCreditLimit': bankCreditLimit,
      'purchasedAcademyCourses': purchasedAcademyCourses,
      'unlockedDecorIds': unlockedDecorIds,
      'lastScrapyardGigDate': lastScrapyardGigDate?.toIso8601String(),
      'nextAuctionAvailableDate': nextAuctionAvailableDate?.toIso8601String(),
      'pendingDopedOffers': pendingDopedOffers,
      'activeContracts': activeContracts.map((c) => c.toJson()).toList(),
      'hasStreakFreeze': hasStreakFreeze,
      'prestigeLevel': prestigeLevel,
      'prestigeMultiplier': prestigeMultiplier,
      'discoveredCarModelIds': discoveredCarModelIds,
      'loyalCustomerNames': loyalCustomerNames,
      'characterOrigin': characterOrigin.name,
      'specializationPath': specializationPath.name,
      'npcRelationships': npcRelationships,
      'dynastyGeneration': dynastyGeneration,
      'dynastyHistoryLog': dynastyHistoryLog,
      'districtMarketShare': districtMarketShare,
      'carsWashedLast7Days': carsWashedLast7Days,
      'expertisesPerformedLast7Days': expertisesPerformedLast7Days,
      'partsRepairedLast7Days': partsRepairedLast7Days,
      'towedCarsLast7Days': towedCarsLast7Days,
      'rentalsCountLast7Days': rentalsCountLast7Days,
      'dirtyRecordCount': dirtyRecordCount,
      'cleanSaleStreak': cleanSaleStreak,
      'pendingDisputeNotice': pendingDisputeNotice,
      'incomingTradeInOffers': incomingTradeInOffers.map((t) => t.toJson()).toList(),
      'activeGossips': activeGossips.map((g) => g.toJson()).toList(),
      'currentWeather': currentWeather.name,
      'consignmentOffers': consignmentOffers.map((c) => c.toJson()).toList(),
      'dailyRacesRemaining': dailyRacesRemaining,
      'completedFirstTimeActions': completedFirstTimeActions.toList(),
      'lastOfficeGrantClaimDay': lastOfficeGrantClaimDay,
      'lastSmartHookUsedDay': lastSmartHookUsedDay,
      'officeSeed': officeSeed,
      'hasReceivedReviewReward': hasReceivedReviewReward,
    };
  }

  factory DealershipModel.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();

    List<T> parseList<T>(List<dynamic>? raw, T Function(Map<String, dynamic>) factory) {
      if (raw == null) return [];
      final list = <T>[];
      for (final item in raw) {
        if (item is Map) {
          try {
            final map = Map<String, dynamic>.from(item);
            list.add(factory(map));
          } catch (_) {}
        }
      }
      return list;
    }

    return DealershipModel(
      balance: (json['balance'] as num?)?.toDouble() ?? 50000.0,
      level: json['level'] as int? ?? 1,
      maxGarageSlots: json['maxGarageSlots'] as int? ?? 4,
      ownedCars: parseList(json['ownedCars'] as List<dynamic>?, CarModel.fromJson),
      incomingOffers: parseList(json['incomingOffers'] as List<dynamic>?, OfferModel.fromJson),
      totalProfit: (json['totalProfit'] as num?)?.toDouble() ?? 0.0,
      carsSold: json['carsSold'] as int? ?? 0,
      lastActiveTime: DateTime.tryParse(json['lastActiveTime'] as String? ?? '') ?? now,
      skills: json['skills'] is Map ? PlayerSkills.fromJson(Map<String, dynamic>.from(json['skills'] as Map)) : PlayerSkills(),
      achievements: parseList(json['achievements'] as List<dynamic>?, AchievementItem.fromJson).isNotEmpty
          ? parseList(json['achievements'] as List<dynamic>?, AchievementItem.fromJson)
          : PlayerAchievements.initialList,
      loginStreak: json['loginStreak'] as int? ?? 1,
      lastLoginDate: DateTime.tryParse(json['lastLoginDate'] as String? ?? '') ?? now,
      activeMissions: parseList(json['activeMissions'] as List<dynamic>?, MissionModel.fromJson).isNotEmpty
          ? parseList(json['activeMissions'] as List<dynamic>?, MissionModel.fromJson)
          : DealershipModel.initial().activeMissions,
      marketTrend: json['marketTrend'] is Map
          ? MarketTrendModel.fromJson(Map<String, dynamic>.from(json['marketTrend'] as Map))
          : MarketTrendModel.defaultTrend(),
      reputationScore: json['reputationScore'] as int? ?? 100,
      activeLoans: parseList(json['activeLoans'] as List<dynamic>?, LoanModel.fromJson),
      pendingOrders: parseList(json['pendingOrders'] as List<dynamic>?, PartOrderModel.fromJson),
      hiredStaff: parseList(json['hiredStaff'] as List<dynamic>?, StaffModel.fromJson),
      customerReviews: parseList(json['customerReviews'] as List<dynamic>?, CustomerReviewModel.fromJson),
      salesHistory: parseList(json['salesHistory'] as List<dynamic>?, SaleRecordModel.fromJson),
      activeCheques: parseList(json['activeCheques'] as List<dynamic>?, Cheque.fromJson),
      activeInstallments: parseList(json['activeInstallments'] as List<dynamic>?, InstallmentContract.fromJson),
      activeRentals: parseList(json['activeRentals'] as List<dynamic>?, RentalAgreement.fromJson),
      tutorialCompleted: json['tutorialCompleted'] as bool? ?? false,
      tutorialStepIndex: json['tutorialStepIndex'] as int? ?? 0,
      currentDay: json['currentDay'] as int? ?? 1,
      playerName: json['playerName'] as String? ?? 'Kaptan',
      dealershipName: json['dealershipName'] as String? ?? 'Miras Oto Galeri',
      logoEmblemId: json['logoEmblemId'] as String? ?? 'crown',
      lastRewardClaimDate: json['lastRewardClaimDate'] != null ? DateTime.tryParse(json['lastRewardClaimDate'] as String) : null,
      sideBusinesses: _parseAndMergeSideBusinesses(parseList(json['sideBusinesses'] as List<dynamic>?, SideBusinessModel.fromJson)),
      marketStocks: parseList(json['marketStocks'] as List<dynamic>?, StockModel.fromJson).isNotEmpty
          ? parseList(json['marketStocks'] as List<dynamic>?, StockModel.fromJson)
          : DealershipModel.initial().marketStocks,
      ownedStocks: parseList(json['ownedStocks'] as List<dynamic>?, PlayerStockModel.fromJson),
      ownedForex: parseList(json['ownedForex'] as List<dynamic>?, PlayerForexModel.fromJson),
      marketForex: parseList(json['marketForex'] as List<dynamic>?, ForexGoldModel.fromJson).isNotEmpty
          ? parseList(json['marketForex'] as List<dynamic>?, ForexGoldModel.fromJson)
          : ForexGoldModel.defaultForex,
      activeIpos: parseList(json['activeIpos'] as List<dynamic>?, IpoOfferModel.fromJson).isNotEmpty
          ? parseList(json['activeIpos'] as List<dynamic>?, IpoOfferModel.fromJson)
          : IpoOfferModel.defaultIpos(1),
      playerIpoRequests: parseList(json['playerIpoRequests'] as List<dynamic>?, PlayerIpoRequestModel.fromJson),
      recentEvents: parseList(json['recentEvents'] as List<dynamic>?, GameEventModel.fromJson),
      dailyTaxRate: (json['dailyTaxRate'] as num?)?.toDouble() ?? 150.0,
      activeNews: json['activeNews'] is Map ? MarketNewsModel.fromJson(Map<String, dynamic>.from(json['activeNews'] as Map)) : null,
      salvagedParts: parseList(json['salvagedParts'] as List<dynamic>?, SalvagedPart.fromJson),
      scrapyardCars: parseList(json['scrapyardCars'] as List<dynamic>?, ScrapyardCar.fromJson),
      blackMarketCars: parseList(json['blackMarketCars'] as List<dynamic>?, BlackMarketCarModel.fromJson),
      b2bPartOrders: parseList(json['b2bPartOrders'] as List<dynamic>?, B2BPartOrder.fromJson),
      unlockedBuildings: (json['unlockedBuildings'] as List<dynamic>?)?.map((e) => e.toString()).toSet() ?? const {
        '/marketplace',
        '/showroom',
        '/expertise',
        '/character-growth',
        '/settings',
        '/dealership-identity',
        '/theme-store',
        '/branches',
      },
      seenStoryCardIds: (json['seenStoryCardIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      daysSinceLastStoryAd: (json['daysSinceLastStoryAd'] as num?)?.toInt() ?? 0,
      nextStoryAdTargetDays: (json['nextStoryAdTargetDays'] as num?)?.toInt() ?? 14,
      pendingStoryCard: json['pendingStoryCard'] != null ? StoryCardModel.fromJson(Map<String, dynamic>.from(json['pendingStoryCard'] as Map)) : null,
      seenDramaticCardIds: (json['seenDramaticCardIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      daysSinceLastDramaticCard: (json['daysSinceLastDramaticCard'] as num?)?.toInt() ?? 0,
      nextDramaticCardTargetDays: (json['nextDramaticCardTargetDays'] as num?)?.toInt() ?? 20,
      pendingDramaticCard: json['pendingDramaticCard'] != null ? DramaticCardModel.fromJson(Map<String, dynamic>.from(json['pendingDramaticCard'] as Map)) : null,
      seenRandomEventIds: (json['seenRandomEventIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      daysSinceLastRandomEvent: (json['daysSinceLastRandomEvent'] as num?)?.toInt() ?? 0,
      nextRandomEventTargetDays: (json['nextRandomEventTargetDays'] as num?)?.toInt() ?? 7,
      pendingRandomEvent: json['pendingRandomEvent'] != null ? GameEventModel.fromJson(Map<String, dynamic>.from(json['pendingRandomEvent'] as Map)) : null,
      bankDepositBalance: (json['bankDepositBalance'] as num?)?.toDouble() ?? 0.0,
      bankCreditLimit: (json['bankCreditLimit'] as num?)?.toDouble() ?? 250000.0,
      purchasedAcademyCourses: (json['purchasedAcademyCourses'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      unlockedDecorIds: (json['unlockedDecorIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      lastScrapyardGigDate: json['lastScrapyardGigDate'] != null ? DateTime.tryParse(json['lastScrapyardGigDate'] as String) : null,
      nextAuctionAvailableDate: json['nextAuctionAvailableDate'] != null ? DateTime.tryParse(json['nextAuctionAvailableDate'] as String) : null,
      pendingDopedOffers: (json['pendingDopedOffers'] as List<dynamic>?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? const [],
      activeContracts: parseList(json['activeContracts'] as List<dynamic>?, WantedCarContract.fromJson),
      hasStreakFreeze: json['hasStreakFreeze'] as bool? ?? false,
      prestigeLevel: json['prestigeLevel'] as int? ?? 0,
      prestigeMultiplier: (json['prestigeMultiplier'] as num?)?.toDouble() ?? 1.0,
      discoveredCarModelIds: (json['discoveredCarModelIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      loyalCustomerNames: (json['loyalCustomerNames'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      characterOrigin: CharacterOrigin.values.firstWhere(
        (e) => e.name == json['characterOrigin'],
        orElse: () => CharacterOrigin.sanayiCiragi,
      ),
      specializationPath: SpecializationPath.values.firstWhere(
        (e) => e.name == json['specializationPath'],
        orElse: () => SpecializationPath.none,
      ),
      npcRelationships: (json['npcRelationships'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toInt()),
          ) ??
          const {
            'haydar_usta': 50,
            'cikmaci_ibo': 50,
            'golge_ibrahim': 50,
            'vlogger_berk': 50,
            'necati': 50,
            'usta_selim': 50,
          },
      dynastyGeneration: (json['dynastyGeneration'] as num?)?.toInt() ?? 1,
      dynastyHistoryLog: (json['dynastyHistoryLog'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      districtMarketShare: (json['districtMarketShare'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          const {
            'İkitelli Sanayi': 0.05,
            'Maslak Plaza': 0.05,
            'Bağcılar Oto Pazarı': 0.05,
            'Nişantaşı Vitrin': 0.02,
            'Kadıköy Klasik Sokağı': 0.02,
            'Ankara Kızılay Hattı': 0.05,
          },
      carsWashedLast7Days: json['carsWashedLast7Days'] as int? ?? 0,
      expertisesPerformedLast7Days: json['expertisesPerformedLast7Days'] as int? ?? 0,
      partsRepairedLast7Days: json['partsRepairedLast7Days'] as int? ?? 0,
      towedCarsLast7Days: json['towedCarsLast7Days'] as int? ?? 0,
      rentalsCountLast7Days: json['rentalsCountLast7Days'] as int? ?? 0,
      dirtyRecordCount: json['dirtyRecordCount'] as int? ?? 0,
      cleanSaleStreak: json['cleanSaleStreak'] as int? ?? 0,
      pendingDisputeNotice: json['pendingDisputeNotice'] as String?,
      incomingTradeInOffers: parseList(json['incomingTradeInOffers'] as List<dynamic>?, TradeInOfferModel.fromJson),
      activeGossips: parseList(json['activeGossips'] as List<dynamic>?, GossipItemModel.fromJson),
      currentWeather: WeatherType.values.firstWhere(
        (e) => e.name == json['currentWeather'],
        orElse: () => WeatherType.sunny,
      ),
      consignmentOffers: parseList(json['consignmentOffers'] as List<dynamic>?, CarModel.fromJson),
      dailyRacesRemaining: json['dailyRacesRemaining'] as int? ?? 3,
      completedFirstTimeActions: (json['completedFirstTimeActions'] as List<dynamic>?)?.map((e) => e.toString()).toSet() ?? const {},
      lastOfficeGrantClaimDay: json['lastOfficeGrantClaimDay'] as int? ?? 0,
      lastSmartHookUsedDay: json['lastSmartHookUsedDay'] as int? ?? 0,
      officeSeed: json['officeSeed'] as int? ?? 0,
      hasReceivedReviewReward: json['hasReceivedReviewReward'] as bool? ?? false,
    );
  }

  static List<SideBusinessModel> _parseAndMergeSideBusinesses(List<SideBusinessModel> parsed) {
    final initialList = DealershipModel.initial().sideBusinesses;
    if (parsed.isEmpty) {
      return initialList;
    }

    final Map<String, SideBusinessModel> parsedMap = {
      for (final b in parsed) b.id: b,
    };

    final merged = <SideBusinessModel>[];
    for (final initialBusiness in initialList) {
      if (parsedMap.containsKey(initialBusiness.id)) {
        merged.add(parsedMap[initialBusiness.id]!);
      } else {
        merged.add(initialBusiness);
      }
    }

    for (final parsedBusiness in parsed) {
      if (!merged.any((b) => b.id == parsedBusiness.id)) {
        merged.add(parsedBusiness);
      }
    }

    return merged;
  }

  DealershipModel copyWith({
    double? balance,
    int? level,
    int? maxGarageSlots,
    List<CarModel>? ownedCars,
    List<OfferModel>? incomingOffers,
    double? totalProfit,
    int? carsSold,
    DateTime? lastActiveTime,
    PlayerSkills? skills,
    List<AchievementItem>? achievements,
    int? loginStreak,
    DateTime? lastLoginDate,
    List<MissionModel>? activeMissions,
    MarketTrendModel? marketTrend,
    int? reputationScore,
    List<LoanModel>? activeLoans,
    List<PartOrderModel>? pendingOrders,
    List<StaffModel>? hiredStaff,
    List<CustomerReviewModel>? customerReviews,
    List<SaleRecordModel>? salesHistory,
    List<Cheque>? activeCheques,
    List<InstallmentContract>? activeInstallments,
    List<RentalAgreement>? activeRentals,
    bool? tutorialCompleted,
    int? tutorialStepIndex,
    int? currentDay,
    String? playerName,
    String? dealershipName,
    String? logoEmblemId,
    int? emblemIndex,
    DateTime? lastRewardClaimDate,
    List<SideBusinessModel>? sideBusinesses,
    List<StockModel>? marketStocks,
    List<PlayerStockModel>? ownedStocks,
    List<PlayerForexModel>? ownedForex,
    List<ForexGoldModel>? marketForex,
    List<IpoOfferModel>? activeIpos,
    List<PlayerIpoRequestModel>? playerIpoRequests,
    List<GameEventModel>? recentEvents,
    double? dailyTaxRate,
    MarketNewsModel? activeNews,
    List<SalvagedPart>? salvagedParts,
    List<ScrapyardCar>? scrapyardCars,
    List<BlackMarketCarModel>? blackMarketCars,
    List<B2BPartOrder>? b2bPartOrders,
    Set<String>? unlockedBuildings,
    List<String>? seenStoryCardIds,
    int? daysSinceLastStoryAd,
    int? nextStoryAdTargetDays,
    StoryCardModel? pendingStoryCard,
    bool clearPendingStoryCard = false,
    List<String>? seenDramaticCardIds,
    int? daysSinceLastDramaticCard,
    int? nextDramaticCardTargetDays,
    DramaticCardModel? pendingDramaticCard,
    bool clearPendingDramaticCard = false,
    List<String>? seenRandomEventIds,
    int? daysSinceLastRandomEvent,
    int? nextRandomEventTargetDays,
    GameEventModel? pendingRandomEvent,
    bool clearPendingRandomEvent = false,
    double? bankDepositBalance,
    double? bankCreditLimit,
    List<String>? purchasedAcademyCourses,
    List<String>? unlockedDecorIds,
    DateTime? lastScrapyardGigDate,
    DateTime? nextAuctionAvailableDate,
    List<Map<String, dynamic>>? pendingDopedOffers,
    List<WantedCarContract>? activeContracts,
    bool? hasStreakFreeze,
    int? prestigeLevel,
    double? prestigeMultiplier,
    List<String>? discoveredCarModelIds,
    List<String>? loyalCustomerNames,
    CharacterOrigin? characterOrigin,
    SpecializationPath? specializationPath,
    Map<String, int>? npcRelationships,
    int? dynastyGeneration,
    List<String>? dynastyHistoryLog,
    Map<String, double>? districtMarketShare,
    int? carsWashedLast7Days,
    int? expertisesPerformedLast7Days,
    int? partsRepairedLast7Days,
    int? towedCarsLast7Days,
    int? rentalsCountLast7Days,
    int? dirtyRecordCount,
    int? cleanSaleStreak,
    String? pendingDisputeNotice,
    bool clearPendingDisputeNotice = false,
    List<TradeInOfferModel>? incomingTradeInOffers,
    List<GossipItemModel>? activeGossips,
    WeatherType? currentWeather,
    List<CarModel>? consignmentOffers,
    int? dailyRacesRemaining,
    Set<String>? completedFirstTimeActions,
    int? lastOfficeGrantClaimDay,
    int? lastSmartHookUsedDay,
    int? officeSeed,
    bool? hasReceivedReviewReward,
    Set<String>? ownedBranchDeeds,
    ActivePrCampaign? activePrCampaign,
    bool clearActivePrCampaign = false,
    Set<String>? ownedLifestyleItems,
    String? equippedSuitId,
    String? equippedAccessoryId,
    String? equippedOfficeDecorId,
  }) {
    return DealershipModel(
      balance: balance ?? this.balance,
      level: level ?? this.level,
      maxGarageSlots: maxGarageSlots ?? this.maxGarageSlots,
      ownedCars: ownedCars ?? this.ownedCars,
      incomingOffers: incomingOffers ?? this.incomingOffers,
      totalProfit: totalProfit ?? this.totalProfit,
      carsSold: carsSold ?? this.carsSold,
      lastActiveTime: lastActiveTime ?? this.lastActiveTime,
      skills: skills ?? this.skills,
      achievements: achievements ?? this.achievements,
      loginStreak: loginStreak ?? this.loginStreak,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      activeMissions: activeMissions ?? this.activeMissions,
      marketTrend: marketTrend ?? this.marketTrend,
      reputationScore: reputationScore ?? this.reputationScore,
      activeLoans: activeLoans ?? this.activeLoans,
      pendingOrders: pendingOrders ?? this.pendingOrders,
      hiredStaff: hiredStaff ?? this.hiredStaff,
      customerReviews: customerReviews ?? this.customerReviews,
      salesHistory: salesHistory ?? this.salesHistory,
      activeCheques: activeCheques ?? this.activeCheques,
      activeInstallments: activeInstallments ?? this.activeInstallments,
      activeRentals: activeRentals ?? this.activeRentals,
      tutorialCompleted: tutorialCompleted ?? this.tutorialCompleted,
      tutorialStepIndex: tutorialStepIndex ?? this.tutorialStepIndex,
      currentDay: currentDay ?? this.currentDay,
      playerName: playerName ?? this.playerName,
      dealershipName: dealershipName ?? this.dealershipName,
      logoEmblemId: emblemIndex != null ? 'emblem_$emblemIndex' : (logoEmblemId ?? this.logoEmblemId),
      lastRewardClaimDate: lastRewardClaimDate ?? this.lastRewardClaimDate,
      sideBusinesses: sideBusinesses ?? this.sideBusinesses,
      marketStocks: marketStocks ?? this.marketStocks,
      ownedStocks: ownedStocks ?? this.ownedStocks,
      ownedForex: ownedForex ?? this.ownedForex,
      marketForex: marketForex ?? this.marketForex,
      activeIpos: activeIpos ?? this.activeIpos,
      playerIpoRequests: playerIpoRequests ?? this.playerIpoRequests,
      recentEvents: recentEvents ?? this.recentEvents,
      dailyTaxRate: dailyTaxRate ?? this.dailyTaxRate,
      activeNews: activeNews ?? this.activeNews,
      salvagedParts: salvagedParts ?? this.salvagedParts,
      scrapyardCars: scrapyardCars ?? this.scrapyardCars,
      blackMarketCars: blackMarketCars ?? this.blackMarketCars,
      b2bPartOrders: b2bPartOrders ?? this.b2bPartOrders,
      unlockedBuildings: unlockedBuildings ?? this.unlockedBuildings,
      seenStoryCardIds: seenStoryCardIds ?? this.seenStoryCardIds,
      daysSinceLastStoryAd: daysSinceLastStoryAd ?? this.daysSinceLastStoryAd,
      nextStoryAdTargetDays: nextStoryAdTargetDays ?? this.nextStoryAdTargetDays,
      pendingStoryCard: clearPendingStoryCard ? null : (pendingStoryCard ?? this.pendingStoryCard),
      seenDramaticCardIds: seenDramaticCardIds ?? this.seenDramaticCardIds,
      daysSinceLastDramaticCard: daysSinceLastDramaticCard ?? this.daysSinceLastDramaticCard,
      nextDramaticCardTargetDays: nextDramaticCardTargetDays ?? this.nextDramaticCardTargetDays,
      pendingDramaticCard: clearPendingDramaticCard ? null : (pendingDramaticCard ?? this.pendingDramaticCard),
      seenRandomEventIds: seenRandomEventIds ?? this.seenRandomEventIds,
      daysSinceLastRandomEvent: daysSinceLastRandomEvent ?? this.daysSinceLastRandomEvent,
      nextRandomEventTargetDays: nextRandomEventTargetDays ?? this.nextRandomEventTargetDays,
      pendingRandomEvent: clearPendingRandomEvent ? null : (pendingRandomEvent ?? this.pendingRandomEvent),
      bankDepositBalance: bankDepositBalance ?? this.bankDepositBalance,
      bankCreditLimit: bankCreditLimit ?? this.bankCreditLimit,
      purchasedAcademyCourses: purchasedAcademyCourses ?? this.purchasedAcademyCourses,
      unlockedDecorIds: unlockedDecorIds ?? this.unlockedDecorIds,
      lastScrapyardGigDate: lastScrapyardGigDate ?? this.lastScrapyardGigDate,
      nextAuctionAvailableDate: nextAuctionAvailableDate ?? this.nextAuctionAvailableDate,
      pendingDopedOffers: pendingDopedOffers ?? this.pendingDopedOffers,
      activeContracts: activeContracts ?? this.activeContracts,
      hasStreakFreeze: hasStreakFreeze ?? this.hasStreakFreeze,
      prestigeLevel: prestigeLevel ?? this.prestigeLevel,
      prestigeMultiplier: prestigeMultiplier ?? this.prestigeMultiplier,
      discoveredCarModelIds: discoveredCarModelIds ?? this.discoveredCarModelIds,
      loyalCustomerNames: loyalCustomerNames ?? this.loyalCustomerNames,
      characterOrigin: characterOrigin ?? this.characterOrigin,
      specializationPath: specializationPath ?? this.specializationPath,
      npcRelationships: npcRelationships ?? this.npcRelationships,
      dynastyGeneration: dynastyGeneration ?? this.dynastyGeneration,
      dynastyHistoryLog: dynastyHistoryLog ?? this.dynastyHistoryLog,
      districtMarketShare: districtMarketShare ?? this.districtMarketShare,
      carsWashedLast7Days: carsWashedLast7Days ?? this.carsWashedLast7Days,
      expertisesPerformedLast7Days: expertisesPerformedLast7Days ?? this.expertisesPerformedLast7Days,
      partsRepairedLast7Days: partsRepairedLast7Days ?? this.partsRepairedLast7Days,
      towedCarsLast7Days: towedCarsLast7Days ?? this.towedCarsLast7Days,
      rentalsCountLast7Days: rentalsCountLast7Days ?? this.rentalsCountLast7Days,
      dirtyRecordCount: dirtyRecordCount ?? this.dirtyRecordCount,
      cleanSaleStreak: cleanSaleStreak ?? this.cleanSaleStreak,
      pendingDisputeNotice: clearPendingDisputeNotice ? null : (pendingDisputeNotice ?? this.pendingDisputeNotice),
      incomingTradeInOffers: incomingTradeInOffers ?? this.incomingTradeInOffers,
      activeGossips: activeGossips ?? this.activeGossips,
      currentWeather: currentWeather ?? this.currentWeather,
      consignmentOffers: consignmentOffers ?? this.consignmentOffers,
      dailyRacesRemaining: dailyRacesRemaining ?? this.dailyRacesRemaining,
      completedFirstTimeActions: completedFirstTimeActions ?? this.completedFirstTimeActions,
      lastOfficeGrantClaimDay: lastOfficeGrantClaimDay ?? this.lastOfficeGrantClaimDay,
      lastSmartHookUsedDay: lastSmartHookUsedDay ?? this.lastSmartHookUsedDay,
      officeSeed: officeSeed ?? this.officeSeed,
      hasReceivedReviewReward: hasReceivedReviewReward ?? this.hasReceivedReviewReward,
      ownedBranchDeeds: ownedBranchDeeds ?? this.ownedBranchDeeds,
      activePrCampaign: clearActivePrCampaign ? null : (activePrCampaign ?? this.activePrCampaign),
      ownedLifestyleItems: ownedLifestyleItems ?? this.ownedLifestyleItems,
      equippedSuitId: equippedSuitId ?? this.equippedSuitId,
      equippedAccessoryId: equippedAccessoryId ?? this.equippedAccessoryId,
      equippedOfficeDecorId: equippedOfficeDecorId ?? this.equippedOfficeDecorId,
    );
  }

  /// Perform New Game+ Prestige / Dynasty Reset
  DealershipModel performPrestigeReset({CharacterOrigin? newOrigin}) {
    final nextPrestigeLevel = prestigeLevel + 1;
    final nextMultiplier = 1.0 + (nextPrestigeLevel * 0.15);
    final nextDynastyGen = dynastyGeneration + 1;
    final newHistory = List<String>.from(dynastyHistoryLog);
    newHistory.add('$dynastyGeneration. Nesil • $rpgTitle: $carsSold araç satıldı, ₺${totalProfit.round()} kâr ile $dealershipName devredildi.');

    // Keep cars that are locked in showcase (§2.6, §2.7)
    final preservedShowcaseCars = ownedCars.where((c) => c.isLockedInShowcase).toList();

    return copyWith(
      balance: 150000.0,
      level: 1,
      ownedCars: preservedShowcaseCars,
      incomingOffers: [],
      activeLoans: [],
      pendingOrders: [],
      activeCheques: [],
      activeInstallments: [],
      activeRentals: [],
      prestigeLevel: nextPrestigeLevel,
      prestigeMultiplier: nextMultiplier,
      dynastyGeneration: nextDynastyGen,
      dynastyHistoryLog: newHistory,
      characterOrigin: newOrigin ?? characterOrigin,
      specializationPath: SpecializationPath.none,
    );
  }

  bool isBuildingUnlocked(String route) => unlockedBuildings.contains(route);
}
