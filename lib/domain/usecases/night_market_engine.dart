import 'dart:math';
import '../../data/models/car_model.dart';

class NightRivalModel {
  final String id;
  final String name;
  final String title;
  final String carName;
  final String modificationSummary;
  final int tier; // 1: Çaylak/Esnaf, 2: Cadde Modifiyeli, 3: Yeraltı Efsanesi
  final int basePower;
  final String badge;

  const NightRivalModel({
    required this.id,
    required this.name,
    required this.title,
    required this.carName,
    required this.modificationSummary,
    required this.tier,
    required this.basePower,
    required this.badge,
  });
}

class NightRaceResult {
  final bool isWon;
  final double prizeMoney;
  final int reputationBonus;
  final String raceSummary;
  final String rivalName;
  final String rivalCarName;
  final String rivalTitle;
  final int playerPowerScore;
  final int rivalPowerScore;

  String get raceLog => raceSummary;

  const NightRaceResult({
    required this.isWon,
    required this.prizeMoney,
    required this.reputationBonus,
    required this.raceSummary,
    required this.rivalName,
    required this.rivalCarName,
    this.rivalTitle = 'Sanayi Rakibi',
    this.playerPowerScore = 50,
    this.rivalPowerScore = 50,
  });
}

class NightMarketEngine {
  static final _random = Random();

  /// Comprehensive roster of 12 authentic street opponents across 3 difficulty tiers
  static const List<NightRivalModel> allRivals = [
    // --- Tier 1: Sanayi Çırakları & Mahalle Gazcıları (Güç: 75 - 130 HP) ---
    NightRivalModel(
      id: 'rival_t1_1',
      name: 'Çırak Samet',
      title: 'Sanayi Çaylağı',
      carName: 'Tofaş Doğan SLX',
      modificationSummary: 'Açık Filtre & Düz Boru • +6 HP',
      tier: 1,
      basePower: 86,
      badge: 'ÇAYLAK',
    ),
    NightRivalModel(
      id: 'rival_t1_2',
      name: 'Yedek Parçacı Kadir',
      title: 'Hurda Avcısı',
      carName: 'Renault 12 Toros',
      modificationSummary: 'Weber Karbüratör & Çelik Jant',
      tier: 1,
      basePower: 75,
      badge: 'ESNAF',
    ),
    NightRivalModel(
      id: 'rival_t1_3',
      name: 'Kurye Emre',
      title: 'Otoban Faresi',
      carName: 'Fiat Fiorino 1.3 MJet',
      modificationSummary: 'Dumansız Stage 1 Yazılım • +15 HP',
      tier: 1,
      basePower: 105,
      badge: 'TİCARİ',
    ),
    NightRivalModel(
      id: 'rival_t1_4',
      name: 'Mahalle Delikanlısı Can',
      title: 'Semt Gazcısı',
      carName: 'Fiat Palio 1.4 Sporting',
      modificationSummary: 'Kısa Şanzıman & Spor Yay',
      tier: 1,
      basePower: 115,
      badge: 'SEMT',
    ),
    NightRivalModel(
      id: 'rival_t1_5',
      name: 'Sanayi Çırağı Şahin',
      title: 'Yanlama Meraklısı',
      carName: 'Tofaş Şahin 1.6 S',
      modificationSummary: 'Kep Kep Karbüratör & 5 Kol Jant',
      tier: 1,
      basePower: 92,
      badge: 'ÇIRAK',
    ),
    NightRivalModel(
      id: 'rival_t1_6',
      name: 'Çorbacı Mahmut Dayı',
      title: 'Gece Müdavimi',
      carName: 'Mercedes 200E W124',
      modificationSummary: 'LPG Ayarlı Ağır Kasa Klasiği',
      tier: 1,
      basePower: 118,
      badge: 'KLASİK',
    ),

    // --- Tier 2: Cadde Çocukları & Stage 1/2 Tuning (Güç: 180 - 350 HP) ---
    NightRivalModel(
      id: 'rival_t2_1',
      name: 'Yazılımcı Alper',
      title: 'Cadde Yarışçısı',
      carName: 'VW Polo GTI 1.4 TSI',
      modificationSummary: 'Pop & Bang Yazılım & Downpipe • +35 HP',
      tier: 2,
      basePower: 215,
      badge: 'CADDE',
    ),
    NightRivalModel(
      id: 'rival_t2_2',
      name: 'Egzozcu Yaşar Usta',
      title: 'Atmosferikçi',
      carName: 'Honda Civic 1.6 VTi',
      modificationSummary: 'VTEC Açan Headers & Düz Boru • +30 HP',
      tier: 2,
      basePower: 190,
      badge: 'USTA',
    ),
    NightRivalModel(
      id: 'rival_t2_3',
      name: 'Gece Kuşu Kemal',
      title: 'Çevre Yolu Hayaleti',
      carName: 'BMW 3.20d E90 M-Tech',
      modificationSummary: 'Stage 2 Dumancı Hibrit Turbo • +65 HP',
      tier: 2,
      basePower: 245,
      badge: 'DUMANCI',
    ),
    NightRivalModel(
      id: 'rival_t2_4',
      name: 'Sanayi Fenomeni Berk',
      title: 'Pist Heveslisi',
      carName: 'VW Golf 7 GTI Performance',
      modificationSummary: 'Intercooler & Forge Blow-Off • +80 HP',
      tier: 2,
      basePower: 300,
      badge: 'FENOMEN',
    ),
    NightRivalModel(
      id: 'rival_t2_5',
      name: 'Driftçi Berkcan',
      title: 'Yanlama Ustası',
      carName: 'BMW 3.28i E36 Coupe',
      modificationSummary: 'M52B28 Yazılım & Kilitli Diferansiyel',
      tier: 2,
      basePower: 230,
      badge: 'DRİFT',
    ),
    NightRivalModel(
      id: 'rival_t2_6',
      name: 'Gece Yarışçısı Type-R',
      title: 'VTEC Efsanesi',
      carName: 'Honda Civic Type-R FK8',
      modificationSummary: 'Invidia Titanyum Egzoz & Karbon Kanat',
      tier: 2,
      basePower: 315,
      badge: 'YARIŞÇI',
    ),

    // --- Tier 3: Yeraltı Efsaneleri & Süper Sporlar (Güç: 420 - 1050 HP) ---
    NightRivalModel(
      id: 'rival_t3_1',
      name: 'Gölge İbrahim',
      title: 'Otoban Baronu',
      carName: 'Mercedes E55 AMG V8',
      modificationSummary: 'Kompressor Kasnak & Supercharger',
      tier: 3,
      basePower: 476,
      badge: 'BARON',
    ),
    NightRivalModel(
      id: 'rival_t3_2',
      name: 'Driftçi Batuhan',
      title: 'Viraj Katili',
      carName: 'Nissan 200SX S13',
      modificationSummary: 'SR20DET Big Turbo & Kilitli Dif',
      tier: 3,
      basePower: 420,
      badge: 'DRİFT',
    ),
    NightRivalModel(
      id: 'rival_t3_3',
      name: 'Galeri Veliahtı Sarp',
      title: 'M Power Koleksiyoneri',
      carName: 'BMW M3 Competition Hamann',
      modificationSummary: 'Hamann Stage 3 & Karbon Gövde',
      tier: 3,
      basePower: 580,
      badge: 'VIP',
    ),
    NightRivalModel(
      id: 'rival_t3_4',
      name: 'Yeraltı Kralı Ejder',
      title: 'Sokakların Efendisi',
      carName: 'Nissan GT-R R35 Black Edition',
      modificationSummary: '1000 HP Çift Alpha Turbo & Launch',
      tier: 3,
      basePower: 950,
      badge: 'EFSANE',
    ),
    NightRivalModel(
      id: 'rival_t3_5',
      name: 'Galericiler Sitesi Ağası',
      title: 'V10 Efsanesi',
      carName: 'BMW M5 E60 V10',
      modificationSummary: 'Eisenmann Egzoz & 8500 RPM Çığlığı',
      tier: 3,
      basePower: 520,
      badge: 'AĞA',
    ),
    NightRivalModel(
      id: 'rival_t3_6',
      name: 'Zengin Züppesi Doruk',
      title: 'Pist Şımarığı',
      carName: 'Porsche 911 Turbo S',
      modificationSummary: 'Akrapovic Titanyum & Launch Kontrol',
      tier: 3,
      basePower: 680,
      badge: 'SÜPER SPOR',
    ),
  ];

  /// Random trash-talk and defeat taunts when player loses
  static String getRandomDefeatTaunt(NightRivalModel rival) {
    final taunts = [
      'Bu arabayla ancak bakkala gidersin esnafım!',
      'Bir dahaki sefere motoru da yükle de gel!',
      'Tozumu yuttun! İntikam istiyorsan masaya iki katını koy!',
      'Biz bu sokaklara dün çıkmadık, biraz daha tecrübe lazım sana!',
      'O vites geçişi neydi öyle? Arabanın ciğerini söktün ama yetişemedin!',
      'Sanayide iyi bir ustaya uğra, belki bir dahaki sefere farkı kapatırsın!',
    ];
    return taunts[_random.nextInt(taunts.length)];
  }

  /// Checks if current real-world hour is within Night Shift (22:00 - 04:00) or simulation (§4.4)
  static bool isNightShiftActive({DateTime? customTime}) {
    final hour = (customTime ?? DateTime.now()).hour;
    return hour >= 22 || hour < 4;
  }

  /// Calculates a comprehensive street horsepower score for any player car
  static int calculatePlayerPower(CarModel playerCar) {
    int totalPower = playerCar.effectiveHorsepower;

    // Chassis alignment and aerodynamic polish bonus
    if (playerCar.expertise.isChassisAligned) {
      totalPower += (totalPower * 0.04).round();
    }
    if (playerCar.isDetailedCleaned || (playerCar.isWashed && playerCar.isPolished)) {
      totalPower += 5;
    }

    return totalPower < 40 ? 40 : totalPower;
  }

  /// Finds a balanced and exciting rival matched to the player's car power
  static NightRivalModel getMatchedRival(CarModel playerCar) {
    final playerPower = calculatePlayerPower(playerCar);

    int targetTier;
    if (playerPower >= 380) {
      targetTier = 3;
    } else if (playerPower >= 150) {
      targetTier = 2;
    } else {
      targetTier = 1;
    }

    final tierRivals = allRivals.where((r) => r.tier == targetTier).toList();
    tierRivals.sort((a, b) => (a.basePower - playerPower).abs().compareTo((b.basePower - playerPower).abs()));
    
    // Pick from the closest 2 suitable rivals for variety while maintaining tight balance
    final candidates = tierRivals.take(2).toList();
    return candidates[_random.nextInt(candidates.length)];
  }

  /// Returns a random rival from a specific tier, optionally excluding a given rival ID
  static NightRivalModel getRandomRivalForTier(int tier, {String? excludeId}) {
    final tierRivals = allRivals.where((r) => r.tier == tier && r.id != excludeId).toList();
    if (tierRivals.isEmpty) {
      return allRivals.firstWhere((r) => r.tier == tier, orElse: () => allRivals.first);
    }
    return tierRivals[_random.nextInt(tierRivals.length)];
  }

  /// Estimates the win percentage (15% to 95%) of the player against a specific rival
  static int estimateWinChance(CarModel playerCar, NightRivalModel rival) {
    final playerPower = calculatePlayerPower(playerCar).toDouble();
    final rivalPower = rival.basePower.toDouble();
    if (playerPower + rivalPower <= 0) return 50;

    // Second-order Bradley-Terry probability model
    final p2 = playerPower * playerPower;
    final r2 = rivalPower * rivalPower;
    final probability = (p2 / (p2 + r2)) * 100;
    return probability.round().clamp(15, 95);
  }

  /// Simulates an underground street modification race (§4.4)
  static NightRaceResult simulateNightRace(CarModel playerCar, {NightRivalModel? rival}) {
    final activeRival = rival ?? getMatchedRival(playerCar);
    final playerBasePower = calculatePlayerPower(playerCar);

    // Dynamic race variance factor (-5 to +10 for player momentum, -3 to +8 for rival)
    final playerRacePower = playerBasePower + _random.nextInt(16) - 5;
    final rivalRacePower = activeRival.basePower + _random.nextInt(12) - 3;

    final isWon = playerRacePower >= rivalRacePower;
    final margin = playerRacePower - rivalRacePower;

    // Dynamic prize and reputation scaling by rival tier
    double basePrize = 25000.0;
    int repBonus = 4;
    if (activeRival.tier == 2) {
      basePrize = 45000.0 + _random.nextInt(25000);
      repBonus = 6;
    } else if (activeRival.tier == 3) {
      basePrize = 80000.0 + _random.nextInt(45000);
      repBonus = 10;
    } else {
      basePrize = 25000.0 + _random.nextInt(15000);
      repBonus = 4;
    }

    String summary;
    if (isWon) {
      if (margin >= 12) {
        summary = 'Açık ara zafer! ${playerCar.modelName} müthiş bir kalkış yaparak ${activeRival.name} • ${activeRival.carName} karşısında ilk 200 metrede 3 boy fark açtı ve finişi ezici bir üstünlükle geçti!';
      } else {
        summary = 'Nefes kesen mücadele! Son 100 metrede ${activeRival.name} ile tampon tampona girdin. Vites geçişindeki kusursuz refleksinle yarım boy farkla çizgiyi önde geçtin!';
      }

      return NightRaceResult(
        isWon: true,
        prizeMoney: basePrize,
        reputationBonus: repBonus,
        raceSummary: summary,
        rivalName: activeRival.name,
        rivalCarName: activeRival.carName,
        rivalTitle: activeRival.title,
        playerPowerScore: playerRacePower,
        rivalPowerScore: rivalRacePower,
      );
    } else {
      if (margin <= -12) {
        summary = 'Rakip çok güçlüydü! ${activeRival.name} • ${activeRival.modificationSummary} yüksek turbo basıncı ve üstün çekişiyle düzlükte farkı açarak yarışı kazandı.';
      } else {
        summary = 'Kıl payı kaçtı! ${activeRival.name} • ${activeRival.carName} viraj çıkışındaki agresif hamlesiyle son anda öne geçti. Küçük bir modifiye veya motor bakımıyla bir dahaki sefere alırsın!';
      }

      return NightRaceResult(
        isWon: false,
        prizeMoney: 0.0,
        reputationBonus: -1,
        raceSummary: summary,
        rivalName: activeRival.name,
        rivalCarName: activeRival.carName,
        rivalTitle: activeRival.title,
        playerPowerScore: playerRacePower,
        rivalPowerScore: rivalRacePower,
      );
    }
  }
}

