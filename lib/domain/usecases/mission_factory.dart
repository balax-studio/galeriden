import 'dart:math';
import '../../data/models/dealership_model.dart';
import '../../data/models/mission_model.dart';
import '../../data/models/contract_model.dart';

class MissionFactory {
  static final Random _random = Random();

  /// Checks if a feature route is unlocked based on player level and unlockedBuildings.
  static bool isRouteUnlocked(String? route, int playerLevel, Set<String> unlockedBuildings) {
    if (route == null) return true;
    final reqLvl = DealershipModel.getRequiredLevel(route);
    return playerLevel >= reqLvl || unlockedBuildings.contains(route);
  }

  /// Generates a set of 3 daily rotating missions dynamically adapted to player level (§2.3)
  /// Guaranteed Soft-Lock Free: Only includes missions accessible at the player's level/unlocked branches.
  /// Discovery Priority: At least 1 slot is dedicated to newly unlocked feature mechanics at current level.
  static List<MissionModel> generateDailyMissions(
    int playerLevel, {
    Set<String> unlockedBuildings = const {},
    Set<String>? recentlyUnlockedRoutes,
  }) {
    final lvl = playerLevel.clamp(1, 10);
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Full catalog of all mission templates across all gameplay mechanics
    final allTemplates = <MissionModel>[      // ==========================================
      // TIER 1 MISSIONS (Available from Level 1)
      // ==========================================
      MissionModel(
        id: 'daily_buy_$timestamp',
        title: 'Pazar Avı • Hediye Başlangıç',
        description: 'İkinci el pazarından ${lvl > 3 ? 3 : 2} araç satın al. • 1 adım hediye verildi!',
        titleKey: 'mission_buy_title',
        descriptionKey: 'mission_buy_desc',
        templateParams: {'count': lvl > 3 ? 3 : 2},
        type: MissionType.buyCars,
        currentProgress: 1, // Endowed Progress §2.3
        targetGoal: lvl > 3 ? 3 : 2,
        rewardMoney: 4000 + (lvl * 1000),
        rewardXP: (6 + lvl).clamp(5, 15),
        featureRoute: '/marketplace',
      ),
      MissionModel(
        id: 'daily_sell_$timestamp',
        title: 'Hızlı Satış & Vitrin',
        description: 'Galerinden ${lvl > 3 ? 3 : 2} araç satışı gerçekleştir. • 1 adım hediye verildi!',
        titleKey: 'mission_sell_title',
        descriptionKey: 'mission_sell_desc',
        templateParams: {'count': lvl > 3 ? 3 : 2},
        type: MissionType.sellCars,
        currentProgress: 1, // Endowed Progress §2.3
        targetGoal: lvl > 3 ? 3 : 2,
        rewardMoney: 4500 + (lvl * 1000),
        rewardXP: (6 + lvl).clamp(5, 15),
        featureRoute: '/showroom',
      ),
      MissionModel(
        id: 'daily_expertise_$timestamp',
        title: 'Titiz Ekspertiz',
        description: '${lvl > 2 ? 2 : 1} araca detaylı ekspertiz testi yaptır.',
        titleKey: 'mission_expertise_title',
        descriptionKey: 'mission_expertise_desc',
        templateParams: {'count': lvl > 2 ? 2 : 1},
        type: MissionType.doExpertise,
        currentProgress: 0,
        targetGoal: lvl > 2 ? 2 : 1,
        rewardMoney: 3000 + (lvl * 800),
        rewardXP: (5 + lvl).clamp(5, 12),
        featureRoute: '/expertise',
      ),
      MissionModel(
        id: 'daily_sms_$timestamp',
        title: 'Tramer Dedektifi',
        description: 'Pazardaki araçlara 2 kez 5664 SMS sorgusu yap.',
        titleKey: 'mission_sms_title',
        descriptionKey: 'mission_sms_desc',
        templateParams: {'count': 2},
        type: MissionType.smsInquiry,
        currentProgress: 0,
        targetGoal: 2,
        rewardMoney: 2500 + (lvl * 500),
        rewardXP: 5,
        featureRoute: '/marketplace',
      ),
      MissionModel(
        id: 'daily_profit_$timestamp',
        title: 'Kasa Katlama',
        description: 'Araç alım satımından toplam ₺${(15000 * lvl)} kâr elde et. • ₺3.000 hediye başlangıç!',
        titleKey: 'mission_profit_title',
        descriptionKey: 'mission_profit_desc',
        templateParams: {'amount': (15000 * lvl)},
        type: MissionType.earnProfit,
        currentProgress: 3000, // Endowed Progress
        targetGoal: 15000 * lvl,
        rewardMoney: 5000 + (lvl * 1500),
        rewardXP: (7 + lvl).clamp(5, 15),
        featureRoute: '/showroom',
      ),

      // ==========================================
      // TIER 2 MISSIONS (Level 2: Car Wash & Night Market)
      // ==========================================
      MissionModel(
        id: 'daily_wash_$timestamp',
        title: 'Köpüklü Detailing',
        description: 'Oto yıkamada ${lvl > 3 ? 2 : 1} aracı pırıl pırıl temizlet.',
        titleKey: 'mission_wash_title',
        descriptionKey: 'mission_wash_desc',
        templateParams: {'count': lvl > 3 ? 2 : 1},
        type: MissionType.washCars,
        currentProgress: 0,
        targetGoal: lvl > 3 ? 2 : 1,
        rewardMoney: 3500 + (lvl * 800),
        rewardXP: (6 + lvl).clamp(5, 14),
        featureRoute: '/car-wash',
      ),
      MissionModel(
        id: 'daily_night_market_$timestamp',
        title: 'Gece Kuşu Ticareti',
        description: 'Gece pazarına uğra veya kelepir fırsat ilanı yakala.',
        titleKey: 'mission_night_market_title',
        descriptionKey: 'mission_night_market_desc',
        templateParams: {'count': 1},
        type: MissionType.nightMarketVisit,
        currentProgress: 0,
        targetGoal: 1,
        rewardMoney: 3000 + (lvl * 600),
        rewardXP: (5 + lvl).clamp(5, 12),
        featureRoute: '/night-market',
      ),

      // ==========================================
      // TIER 3 MISSIONS (Level 3: Workshop & Staff)
      // ==========================================
      MissionModel(
        id: 'daily_repair_$timestamp',
        title: 'Sanayi Mesaisi',
        description: 'Atölyede ${1 + (lvl ~/ 3)} adet kaporta veya mekanik parça onar. • 1 adım hediye!',
        titleKey: 'mission_repair_title',
        descriptionKey: 'mission_repair_desc',
        templateParams: {'count': 1 + (lvl ~/ 3)},
        type: MissionType.repairParts,
        currentProgress: 1, // Endowed Progress
        targetGoal: 1 + (lvl ~/ 3),
        rewardMoney: 5000 + (lvl * 1200),
        rewardXP: (7 + lvl).clamp(5, 15),
        featureRoute: '/workshop',
      ),
      MissionModel(
        id: 'daily_staff_$timestamp',
        title: 'Takım Ruhu',
        description: 'Personeline ikram ısmarla veya akademide eğitim aldır.',
        titleKey: 'mission_staff_title',
        descriptionKey: 'mission_staff_desc',
        templateParams: {'count': 1},
        type: MissionType.hireStaff,
        currentProgress: 0,
        targetGoal: 1,
        rewardMoney: 4500 + (lvl * 1000),
        rewardXP: (6 + lvl).clamp(5, 14),
        featureRoute: '/staff',
      ),

      // ==========================================
      // TIER 4 MISSIONS (Level 4: Tuning Studio & Decor)
      // ==========================================
      MissionModel(
        id: 'daily_tuning_$timestamp',
        title: 'Tuning Ustası',
        description: 'Tuning stüdyosunda 1 araca modifiye parçası tak.',
        titleKey: 'mission_tune_title',
        descriptionKey: 'mission_tune_desc',
        templateParams: {'count': 1},
        type: MissionType.tuneCar,
        currentProgress: 0,
        targetGoal: 1,
        rewardMoney: 6000 + (lvl * 1200),
        rewardXP: (8 + lvl).clamp(5, 15),
        featureRoute: '/tuning-studio',
      ),

      // ==========================================
      // TIER 5 MISSIONS (Level 5: Auction & Bank Finance)
      // ==========================================
      MissionModel(
        id: 'daily_auction_$timestamp',
        title: 'Müzayede Heyecanı',
        description: 'Canlı açık artırmada 1 kez pey ver veya araç kazan.',
        titleKey: 'mission_auction_title',
        descriptionKey: 'mission_auction_desc',
        templateParams: {'count': 1},
        type: MissionType.auctionBid,
        currentProgress: 0,
        targetGoal: 1,
        rewardMoney: 7000 + (lvl * 1200),
        rewardXP: (9 + lvl).clamp(5, 15),
        featureRoute: '/auction',
      ),
      MissionModel(
        id: 'daily_bank_$timestamp',
        title: 'Akıllı Fon Yönetimi',
        description: 'Banka mevduat hesabına para yatır veya vadeli fon aç.',
        titleKey: 'mission_bank_title',
        descriptionKey: 'mission_bank_desc',
        templateParams: {'count': 1},
        type: MissionType.bankInvestment,
        currentProgress: 0,
        targetGoal: 1,
        rewardMoney: 4000 + (lvl * 800),
        rewardXP: (6 + lvl).clamp(5, 14),
        featureRoute: '/finance',
      ),

      // ==========================================
      // TIER 6 MISSIONS (Level 6: Stock Market & Casino)
      // ==========================================
      MissionModel(
        id: 'daily_stock_$timestamp',
        title: 'Borsa Brokeri',
        description: 'Borsada 1 hisse senedi veya döviz işlemi gerçekleştir.',
        titleKey: 'mission_stock_title',
        descriptionKey: 'mission_stock_desc',
        templateParams: {'count': 1},
        type: MissionType.stockTrade,
        currentProgress: 0,
        targetGoal: 1,
        rewardMoney: 7500 + (lvl * 1200),
        rewardXP: (9 + lvl).clamp(5, 15),
        featureRoute: '/stock-market',
      ),
      MissionModel(
        id: 'daily_casino_$timestamp',
        title: 'VIP Kumarhane Keyfi',
        description: 'VIP kumarhane kulübünde 1 tur mini oyun oyna.',
        titleKey: 'mission_casino_title',
        descriptionKey: 'mission_casino_desc',
        templateParams: {'count': 1},
        type: MissionType.casinoPlay,
        currentProgress: 0,
        targetGoal: 1,
        rewardMoney: 5000 + (lvl * 800),
        rewardXP: (6 + lvl).clamp(5, 14),
        featureRoute: '/casino',
      ),

      // ==========================================
      // TIER 7 MISSIONS (Level 7: Rental, Black Market, Gossip)
      // ==========================================
      MissionModel(
        id: 'daily_rent_$timestamp',
        title: 'Filo Kiralama',
        description: 'Filo kiralama sistemine 1 araç bağla veya sözleşme imzala.',
        titleKey: 'mission_rent_title',
        descriptionKey: 'mission_rent_desc',
        templateParams: {'count': 1},
        type: MissionType.rentCar,
        currentProgress: 0,
        targetGoal: 1,
        rewardMoney: 8000 + (lvl * 1500),
        rewardXP: (10 + lvl).clamp(5, 15),
        featureRoute: '/rent-a-car',
      ),
      MissionModel(
        id: 'daily_black_market_$timestamp',
        title: 'Gölge İbrahim Pazarı',
        description: 'Karaborsadan 1 konteyner aç veya kaçak araç incele.',
        titleKey: 'mission_black_market_title',
        descriptionKey: 'mission_black_market_desc',
        templateParams: {'count': 1},
        type: MissionType.blackMarketTrade,
        currentProgress: 0,
        targetGoal: 1,
        rewardMoney: 9000 + (lvl * 1500),
        rewardXP: (10 + lvl).clamp(5, 15),
        featureRoute: '/black-market',
      ),
      MissionModel(
        id: 'daily_gossip_$timestamp',
        title: 'Piyasa Kulisleri',
        description: 'Sektör kulislerinden 1 adet sıcak istihbarat satın al.',
        titleKey: 'mission_gossip_title',
        descriptionKey: 'mission_gossip_desc',
        templateParams: {'count': 1},
        type: MissionType.gossipListen,
        currentProgress: 0,
        targetGoal: 1,
        rewardMoney: 6000 + (lvl * 1000),
        rewardXP: (8 + lvl).clamp(5, 15),
        featureRoute: '/gossip',
      ),

      // ==========================================
      // TIER 8+ MISSIONS (Level 8: Scrapyard, Consignment, Side Biz)
      // ==========================================
      MissionModel(
        id: 'daily_scrapyard_$timestamp',
        title: 'Çıkmacı İbo Mesaisi',
        description: 'Hurdalıktan 1 parça sök veya revize et.',
        titleKey: 'mission_scrapyard_title',
        descriptionKey: 'mission_scrapyard_desc',
        templateParams: {'count': 1},
        type: MissionType.scrapyardDismantle,
        currentProgress: 0,
        targetGoal: 1,
        rewardMoney: 8500 + (lvl * 1500),
        rewardXP: (10 + lvl).clamp(5, 15),
        featureRoute: '/scrapyard',
      ),
      MissionModel(
        id: 'daily_consignment_$timestamp',
        title: 'Konsinye Vitrini',
        description: 'Galerine 1 adet komisyonlu konsinye araç kabul et.',
        titleKey: 'mission_consignment_title',
        descriptionKey: 'mission_consignment_desc',
        templateParams: {'count': 1},
        type: MissionType.consignmentAccept,
        currentProgress: 0,
        targetGoal: 1,
        rewardMoney: 8000 + (lvl * 1500),
        rewardXP: (10 + lvl).clamp(5, 15),
        featureRoute: '/consignment',
      ),
      MissionModel(
        id: 'daily_side_biz_$timestamp',
        title: 'Yan İşletme Geliri',
        description: 'Yan işletmelerini geliştir veya günlük gelirini topla.',
        titleKey: 'mission_side_biz_title',
        descriptionKey: 'mission_side_biz_desc',
        templateParams: {'count': 1},
        type: MissionType.sideBusinessCollect,
        currentProgress: 0,
        targetGoal: 1,
        rewardMoney: 9000 + (lvl * 1500),
        rewardXP: (10 + lvl).clamp(5, 15),
        featureRoute: '/side-businesses',
      ),
    ];

    // Filter strictly unlocked candidate missions
    final candidatePool = allTemplates
        .where((m) => isRouteUnlocked(m.featureRoute, lvl, unlockedBuildings))
        .toList();

    final selected = <MissionModel>[];
    final usedTypes = <MissionType>{};

    // ==========================================
    // DISCOVERY MISSION PRIORITY (§Discovery Rule)
    // ==========================================
    // If the player is at a tier where new features unlock (or recently unlocked routes exist),
    // allocate Slot 1 to a newly unlocked discovery mission.
    final discoveryCandidates = candidatePool.where((m) {
      if (m.featureRoute == null) return false;
      final reqLvl = DealershipModel.getRequiredLevel(m.featureRoute!);
      final isCurrentTierUnlock = reqLvl == lvl && lvl >= 2;
      final isRecentRouteUnlock = recentlyUnlockedRoutes != null &&
          recentlyUnlockedRoutes.contains(m.featureRoute);
      return isCurrentTierUnlock || isRecentRouteUnlock;
    }).toList();

    if (discoveryCandidates.isNotEmpty) {
      discoveryCandidates.shuffle(_random);
      final discoveryMission = discoveryCandidates.first.copyWith(
        isDiscoveryMission: true,
      );
      selected.add(discoveryMission);
      usedTypes.add(discoveryMission.type);
    }

    // Shuffle remaining unlocked candidate missions for variety
    candidatePool.shuffle(_random);

    for (final mission in candidatePool) {
      if (!usedTypes.contains(mission.type)) {
        selected.add(mission);
        usedTypes.add(mission.type);
        if (selected.length >= 3) break;
      }
    }

    // Fallback if not enough distinct types
    if (selected.length < 3) {
      for (final mission in candidatePool) {
        if (!selected.any((m) => m.id == mission.id)) {
          selected.add(mission);
          if (selected.length >= 3) break;
        }
      }
    }

    return selected;
  }

  /// Generates a Chained Campaign Mission (§2.4: Araç Al -> Ekspertiz -> Onar -> İlana Koy & Sat)
  /// Main Milestones serve as the primary source of substantial XP (50 - 200 XP).
  static MissionModel generateChainedCampaignMission({required int step, required int level}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final lvl = level.clamp(1, 10);
    switch (step) {
      case 1:
        return MissionModel(
          id: 'chain_1_$timestamp',
          title: 'Zincir 1/4: Kelepir Avı',
          description: 'Pazardan kâr marjı yüksek bir fırsat aracı satın al.',
          type: MissionType.buyCars,
          currentProgress: 0,
          targetGoal: 1,
          rewardMoney: 15000 + (lvl * 3000),
          rewardXP: 50 + (lvl * 5),
          featureRoute: '/marketplace',
        );
      case 2:
        return MissionModel(
          id: 'chain_2_$timestamp',
          title: 'Zincir 2/4: Kusursuz Teşhis',
          description: 'Aldığın aracı Haydar Usta\'nın ekspertiz istasyonuna sok.',
          type: MissionType.doExpertise,
          currentProgress: 0,
          targetGoal: 1,
          rewardMoney: 20000 + (lvl * 4000),
          rewardXP: 75 + (lvl * 5),
          featureRoute: '/expertise',
        );
      case 3:
        return MissionModel(
          id: 'chain_3_$timestamp',
          title: 'Zincir 3/4: Sanayi Restorasyonu',
          description: 'Aracın kusurlu mekanik veya kaporta parçalarını onar.',
          type: MissionType.repairParts,
          currentProgress: 0,
          targetGoal: 1,
          rewardMoney: 30000 + (lvl * 5000),
          rewardXP: 100 + (lvl * 10),
          featureRoute: '/workshop',
        );
      case 4:
      default:
        return MissionModel(
          id: 'chain_4_$timestamp',
          title: 'Zincir 4/4: Büyük Final Satışı',
          description: 'Restore ettiğin aracı vitrine koy ve kârla satışı tamamla!',
          type: MissionType.sellCars,
          currentProgress: 0,
          targetGoal: 1,
          rewardMoney: 75000 + (lvl * 15000),
          rewardXP: 200 + (lvl * 20),
          featureRoute: '/showroom',
        );
    }
  }

  /// Generates a "Wanted Vehicle" special contract from a VIP customer
  static WantedCarContract generateWantedCarContract({int level = 1}) {
    final lvl = level.clamp(1, 10);
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final clients = [
      {'name': 'Doktor Selim Bey', 'archetype': 'Pretij & Konfor', 'brand': 'Merso', 'type': 'Sedan'},
      {'name': 'Mimar Aylin Hanım', 'archetype': 'Şehirli SUV', 'brand': 'Vosgen', 'type': 'SUV'},
      {'name': 'Yazılımcı Berk', 'archetype': 'Hızlı & Dinamik', 'brand': 'Bemeve', 'type': 'Sedan'},
      {'name': 'Usta Balatacı Hasan', 'archetype': 'Klasik & Nostalji', 'brand': 'Tofaşk', 'type': 'Klasik'},
      {'name': 'Avukat Kemal Bey', 'archetype': 'Executive & Ağır', 'brand': 'Avdi', 'type': 'Sedan'},
      {'name': 'Öğretmen Zeynep Hanım', 'archetype': 'Ekonomik & Masrafsız', 'brand': 'Toyo', 'type': 'Hatchback'},
    ];

    final client = clients[_random.nextInt(clients.length)];
    final baseBudget = (200000.0 * lvl) + (_random.nextInt(100) * 1000.0);
    final bonus = (baseBudget * 0.15).roundToDouble();

    return WantedCarContract(
      id: 'contract_$timestamp',
      clientName: client['name']!,
      targetBrand: client['brand']!,
      targetBodyType: client['type'],
      minYear: 2000 + (lvl * 2).clamp(0, 22),
      maxMileage: (280000 - (lvl * 15000)).clamp(50000, 300000),
      budget: baseBudget,
      rewardBonus: bonus,
      deadlineDays: 4 + _random.nextInt(4), // 4-7 in-game days
      description: '${client['name']} özel bir sipariş verdi: ${client['targetBrand'] ?? client['brand']} • ${client['type']} arıyor. Teslimatta ek ₺${bonus.toInt()} prim ödeyecek.',
    );
  }
}
