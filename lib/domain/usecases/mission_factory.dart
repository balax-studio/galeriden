import 'dart:math';
import '../../data/models/mission_model.dart';
import '../../data/models/contract_model.dart';

class MissionFactory {
  static final Random _random = Random();

  /// Generates a set of daily rotating missions with Endowed Progress (§2.3)
  static List<MissionModel> generateDailyMissions(int playerLevel) {
    final lvl = playerLevel.clamp(1, 10);
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final pool = <MissionModel>[
      // 1. Buy Cars (Endowed progress: Starts at 1/2 or 1/3)
      MissionModel(
        id: 'daily_buy_$timestamp',
        title: 'Pazar Avı (Hediye Başlangıç)',
        description: 'İkinci el pazarından ${lvl > 2 ? 3 : 2} araç satın al. (1 adım hediye verildi!)',
        type: MissionType.buyCars,
        currentProgress: 1, // Endowed Progress §2.3
        targetGoal: lvl > 2 ? 3 : 2,
        rewardMoney: 8000 * lvl,
        rewardXP: 100 * lvl,
      ),

      // 2. Sell Cars (Endowed progress)
      MissionModel(
        id: 'daily_sell_$timestamp',
        title: 'Hızlı Satış & Vitrin',
        description: 'Galerinden ${lvl > 3 ? 3 : 2} araç satışı gerçekleştir. (1 adım hediye verildi!)',
        type: MissionType.sellCars,
        currentProgress: 1, // Endowed Progress §2.3
        targetGoal: lvl > 3 ? 3 : 2,
        rewardMoney: 12000 * lvl,
        rewardXP: 150 * lvl,
      ),

      // 3. Repair Parts (Endowed progress)
      MissionModel(
        id: 'daily_repair_$timestamp',
        title: 'Sanayi Mesaisi',
        description: 'Atölyede ${2 + lvl} adet kaporta veya mekanik parça onar. (1 adım hediye!)',
        type: MissionType.repairParts,
        currentProgress: 1, // Endowed Progress §2.3
        targetGoal: 2 + lvl,
        rewardMoney: 10000 * lvl,
        rewardXP: 120 * lvl,
      ),

      // 4. Expertise
      MissionModel(
        id: 'daily_expertise_$timestamp',
        title: 'Titiz Ekspertiz',
        description: '${lvl > 2 ? 3 : 2} araca detaylı ekspertiz testi yaptır. (1 adım hediye!)',
        type: MissionType.doExpertise,
        currentProgress: 1, // Endowed Progress §2.3
        targetGoal: lvl > 2 ? 3 : 2,
        rewardMoney: 6000 * lvl,
        rewardXP: 80 * lvl,
      ),

      // 5. Earn Profit
      MissionModel(
        id: 'daily_profit_$timestamp',
        title: 'Kasa Katlama',
        description: 'Araç ve borsa işlemlerinden toplam ₺${(30000 * lvl)} kâr elde et. (₺5.000 hediye başlangıç!)',
        type: MissionType.earnProfit,
        currentProgress: 5000, // Endowed Progress §2.3
        targetGoal: 30000 * lvl,
        rewardMoney: 15000 * lvl,
        rewardXP: 200 * lvl,
      ),
    ];

    // Pick 3-4 random missions
    pool.shuffle(_random);
    return pool.take(3).toList();
  }

  /// Generates a Chained Campaign Mission (§2.4: Araç Al -> Ekspertiz -> Onar -> İlana Koy & Sat)
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
          rewardMoney: 5000 * lvl,
          rewardXP: 80 * lvl,
        );
      case 2:
        return MissionModel(
          id: 'chain_2_$timestamp',
          title: 'Zincir 2/4: Kusursuz Teşhis',
          description: 'Aldığın aracı Haydar Usta\'nın ekspertiz istasyonuna sok.',
          type: MissionType.doExpertise,
          currentProgress: 0,
          targetGoal: 1,
          rewardMoney: 6000 * lvl,
          rewardXP: 90 * lvl,
        );
      case 3:
        return MissionModel(
          id: 'chain_3_$timestamp',
          title: 'Zincir 3/4: Sanayi Restorasyonu',
          description: 'Aracın kusurlu mekanik veya kaporta parçalarını onar.',
          type: MissionType.repairParts,
          currentProgress: 0,
          targetGoal: 1,
          rewardMoney: 8000 * lvl,
          rewardXP: 110 * lvl,
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
          rewardMoney: 25000 * lvl,
          rewardXP: 300 * lvl,
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
      description: '${client['name']} özel bir sipariş verdi: ${client['targetBrand'] ?? client['brand']} (${client['type']}) arıyor. Teslimatta ek ₺${bonus.toInt()} prim ödeyecek.',
    );
  }
}
