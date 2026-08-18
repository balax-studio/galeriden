import 'dart:math';
import '../../data/models/mission_model.dart';
import '../../data/models/contract_model.dart';

class MissionFactory {
  static final Random _random = Random();

  /// Generates a set of daily rotating missions with Endowed Progress (§2.3)
  /// Guaranteed Soft-Lock Free: Only includes missions accessible at the player's level/unlocked branches.
  /// XP Rewards are strictly balanced to 5 - 15 XP band for daily side quests.
  static List<MissionModel> generateDailyMissions(
    int playerLevel, {
    Set<String> unlockedBuildings = const {},
  }) {
    final lvl = playerLevel.clamp(1, 10);
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // 15+ Varied Mission Templates categorized by prerequisites
    final candidatePool = <MissionModel>[];

    // ==========================================
    // TIER 1 MISSIONS (Available from Level 1)
    // ==========================================
    candidatePool.addAll([
      // 1. Buy Cars
      MissionModel(
        id: 'daily_buy_$timestamp',
        title: 'Pazar Avı • Hediye Başlangıç',
        description: 'İkinci el pazarından ${lvl > 2 ? 3 : 2} araç satın al. • 1 adım hediye verildi!',
        type: MissionType.buyCars,
        currentProgress: 1, // Endowed Progress §2.3
        targetGoal: lvl > 2 ? 3 : 2,
        rewardMoney: 4000 + (lvl * 1000),
        rewardXP: 10,
      ),

      // 2. Sell Cars
      MissionModel(
        id: 'daily_sell_$timestamp',
        title: 'Hızlı Satış & Vitrin',
        description: 'Galerinden ${lvl > 3 ? 3 : 2} araç satışı gerçekleştir. • 1 adım hediye verildi!',
        type: MissionType.sellCars,
        currentProgress: 1, // Endowed Progress §2.3
        targetGoal: lvl > 3 ? 3 : 2,
        rewardMoney: 5000 + (lvl * 1000),
        rewardXP: 10,
      ),

      // 3. Expertise
      MissionModel(
        id: 'daily_expertise_$timestamp',
        title: 'Titiz Ekspertiz',
        description: '${lvl > 2 ? 2 : 1} araca detaylı ekspertiz testi yaptır.',
        type: MissionType.doExpertise,
        currentProgress: 0,
        targetGoal: lvl > 2 ? 2 : 1,
        rewardMoney: 3000 + (lvl * 500),
        rewardXP: 8,
      ),

      // 4. 5664 SMS Tramer Query
      MissionModel(
        id: 'daily_sms_$timestamp',
        title: 'Tramer Dedektifi',
        description: 'Pazardaki şüpheli araçlara 2 kez 5664 SMS sorgusu yap.',
        type: MissionType.smsInquiry,
        currentProgress: 0,
        targetGoal: 2,
        rewardMoney: 2500 + (lvl * 500),
        rewardXP: 5,
      ),

      // 5. Commercial Profit
      MissionModel(
        id: 'daily_profit_$timestamp',
        title: 'Kasa Katlama',
        description: 'Araç alım satımından toplam ₺${(15000 * lvl)} kâr elde et. • ₺3.000 hediye başlangıç!',
        type: MissionType.earnProfit,
        currentProgress: 3000, // Endowed Progress
        targetGoal: 15000 * lvl,
        rewardMoney: 6000 + (lvl * 1500),
        rewardXP: 12,
      ),

      // 6. Night Market Hunting
      MissionModel(
        id: 'daily_night_market_$timestamp',
        title: 'Gece Kuşu Ticareti',
        description: 'Gece pazarına uğra veya kelepir fırsat ilanı yakala.',
        type: MissionType.nightMarketVisit,
        currentProgress: 0,
        targetGoal: 1,
        rewardMoney: 3500 + (lvl * 500),
        rewardXP: 8,
      ),
    ]);

    // ==========================================
    // TIER 2 MISSIONS (Level 2+ or Unlocked Branches)
    // ==========================================
    final hasCarWash = lvl >= 2 || unlockedBuildings.contains('/car-wash');
    if (hasCarWash) {
      candidatePool.addAll([
        // 7. Wash Cars / Detailing
        MissionModel(
          id: 'daily_wash_$timestamp',
          title: 'Köpüklü Detailing',
          description: 'Oto yıkamada 2 aracı pırıl pırıl temizlet.',
          type: MissionType.washCars,
          currentProgress: 0,
          targetGoal: 2,
          rewardMoney: 4500 + (lvl * 500),
          rewardXP: 6,
        ),

        // 8. Bank Deposit
        MissionModel(
          id: 'daily_bank_$timestamp',
          title: 'Akıllı Fon Yönetimi',
          description: 'Banka mevduat hesabına para yatır veya vadeli fon aç.',
          type: MissionType.bankInvestment,
          currentProgress: 0,
          targetGoal: 1,
          rewardMoney: 4000 + (lvl * 1000),
          rewardXP: 8,
        ),

        // 9. Scrapyard Dismantling
        MissionModel(
          id: 'daily_scrapyard_$timestamp',
          title: 'Çıkmacı İbo Mesaisi',
          description: 'Hurdalıktan 1 parça sök veya revize et.',
          type: MissionType.scrapyardDismantle,
          currentProgress: 0,
          targetGoal: 1,
          rewardMoney: 5000 + (lvl * 1000),
          rewardXP: 9,
        ),
      ]);
    }

    // ==========================================
    // TIER 3+ MISSIONS (Level 3+ or Workshop Unlocked)
    // ==========================================
    final hasWorkshop = lvl >= 3 || unlockedBuildings.contains('/workshop');
    if (hasWorkshop) {
      candidatePool.addAll([
        // 10. Repair Parts
        MissionModel(
          id: 'daily_repair_$timestamp',
          title: 'Sanayi Mesaisi',
          description: 'Atölyede ${1 + (lvl ~/ 2)} adet kaporta veya mekanik parça onar. • 1 adım hediye!',
          type: MissionType.repairParts,
          currentProgress: 1, // Endowed Progress
          targetGoal: 1 + (lvl ~/ 2),
          rewardMoney: 6000 + (lvl * 1000),
          rewardXP: 12,
        ),

        // 11. Tuning / Modification
        MissionModel(
          id: 'daily_tuning_$timestamp',
          title: 'Tuning Ustası',
          description: 'Tuning stüdyosunda 1 araca modifiye parçası tak.',
          type: MissionType.tuneCar,
          currentProgress: 0,
          targetGoal: 1,
          rewardMoney: 7000 + (lvl * 1000),
          rewardXP: 12,
        ),

        // 12. Staff Management & Academy
        MissionModel(
          id: 'daily_staff_$timestamp',
          title: 'Takım Ruhu',
          description: 'Personeline ikram ısmarla veya akademide eğitim aldır.',
          type: MissionType.hireStaff,
          currentProgress: 0,
          targetGoal: 1,
          rewardMoney: 5500 + (lvl * 1000),
          rewardXP: 10,
        ),
      ]);
    }

    // Shuffle and guarantee distinct mission types for variety
    candidatePool.shuffle(_random);
    final selected = <MissionModel>[];
    final usedTypes = <MissionType>{};

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
