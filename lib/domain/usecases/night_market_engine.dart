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
    // --- Tier 1: Sanayi Çırakları & Mahalle Gazcıları (Güç: 32 - 46) ---
    NightRivalModel(
      id: 'rival_t1_1',
      name: 'Çırak Samet',
      title: 'Sanayi Çaylağı',
      carName: 'Tofaş Doğan SLX',
      modificationSummary: 'Açık Filtre & Düz Boru',
      tier: 1,
      basePower: 34,
      badge: 'ÇAYLAK',
    ),
    NightRivalModel(
      id: 'rival_t1_2',
      name: 'Yedek Parçacı Kadir',
      title: 'Hurda Avcısı',
      carName: 'Renault 12 Toros',
      modificationSummary: 'Weber Karbüratör & Çelik Jant',
      tier: 1,
      basePower: 36,
      badge: 'ESNAF',
    ),
    NightRivalModel(
      id: 'rival_t1_3',
      name: 'Kurye Emre',
      title: 'Otoban Faresi',
      carName: 'Fiat Fiorino 1.3 MJet',
      modificationSummary: 'Dumansız Stage 1 Yazılım',
      tier: 1,
      basePower: 40,
      badge: 'TİCARİ',
    ),
    NightRivalModel(
      id: 'rival_t1_4',
      name: 'Mahalle Delikanlısı Can',
      title: 'Semt Gazcısı',
      carName: 'Fiat Palio 1.4 Sporting',
      modificationSummary: 'Kısa Şanzıman & Spor Yay',
      tier: 1,
      basePower: 44,
      badge: 'SEMT',
    ),

    // --- Tier 2: Cadde Çocukları & Stage 1/2 Tuning (Güç: 58 - 74) ---
    NightRivalModel(
      id: 'rival_t2_1',
      name: 'Yazılımcı Alper',
      title: 'Cadde Yarışçısı',
      carName: 'VW Polo GTI 1.4 TSI',
      modificationSummary: 'Pop & Bang Yazılım & Downpipe',
      tier: 2,
      basePower: 60,
      badge: 'CADDE',
    ),
    NightRivalModel(
      id: 'rival_t2_2',
      name: 'Egzozcu Yaşar Usta',
      title: 'Atmosferikçi',
      carName: 'Honda Civic 1.6 VTi',
      modificationSummary: 'VTEC Açan Headers & Düz Boru',
      tier: 2,
      basePower: 64,
      badge: 'USTA',
    ),
    NightRivalModel(
      id: 'rival_t2_3',
      name: 'Gece Kuşu Kemal',
      title: 'Çevre Yolu Hayaleti',
      carName: 'BMW 3.20d E90 M-Tech',
      modificationSummary: 'Stage 2 Dumancı Hibrit Turbo',
      tier: 2,
      basePower: 68,
      badge: 'DUMANCI',
    ),
    NightRivalModel(
      id: 'rival_t2_4',
      name: 'Sanayi Fenomeni Berk',
      title: 'Pist Heveslisi',
      carName: 'VW Golf 7 GTI Performance',
      modificationSummary: 'Intercooler & Forge Blow-Off',
      tier: 2,
      basePower: 72,
      badge: 'FENOMEN',
    ),

    // --- Tier 3: Yeraltı Efsaneleri & Süper Sporlar (Güç: 85 - 110) ---
    NightRivalModel(
      id: 'rival_t3_1',
      name: 'Gölge İbrahim',
      title: 'Otoban Baronu',
      carName: 'Mercedes E55 AMG V8',
      modificationSummary: 'Kompressor Kasnak & Supercharger',
      tier: 3,
      basePower: 86,
      badge: 'BARON',
    ),
    NightRivalModel(
      id: 'rival_t3_2',
      name: 'Driftçi Batuhan',
      title: 'Viraj Katili',
      carName: 'Nissan 200SX S13',
      modificationSummary: 'SR20DET Big Turbo & Kilitli Dif',
      tier: 3,
      basePower: 92,
      badge: 'DRİFT',
    ),
    NightRivalModel(
      id: 'rival_t3_3',
      name: 'Galeri Veliahtı Sarp',
      title: 'M Power Koleksiyoneri',
      carName: 'BMW M3 Competition Hamann',
      modificationSummary: 'Hamann Stage 3 & Karbon Gövde',
      tier: 3,
      basePower: 98,
      badge: 'VIP',
    ),
    NightRivalModel(
      id: 'rival_t3_4',
      name: 'Yeraltı Kralı Ejder',
      title: 'Sokakların Efendisi',
      carName: 'Nissan GT-R R35 Black Edition',
      modificationSummary: '1000 HP Çift Alpha Turbo & Launch',
      tier: 3,
      basePower: 108,
      badge: 'EFSANE',
    ),
  ];

  /// Checks if current real-world hour is within Night Shift (22:00 - 04:00) or simulation (§4.4)
  static bool isNightShiftActive({DateTime? customTime}) {
    final hour = (customTime ?? DateTime.now()).hour;
    return hour >= 22 || hour < 4;
  }

  /// Calculates a comprehensive street power score for any player car
  static int calculatePlayerPower(CarModel playerCar) {
    // 1. Base mechanical health score (max 70)
    final enginePower = playerCar.expertise.engineCondition * 0.40;
    final transPower = playerCar.expertise.transmissionCondition * 0.30;
    final chassisPower = playerCar.expertise.isChassisAligned ? 8.0 : 0.0;

    // 2. Market Tier Bonus (higher performance base classes)
    double baseTierBonus = 0;
    if (playerCar.baseMarketValue >= 5000000) {
      baseTierBonus = 35;
    } else if (playerCar.baseMarketValue >= 1500000) {
      baseTierBonus = 22;
    } else if (playerCar.baseMarketValue >= 500000) {
      baseTierBonus = 12;
    } else if (playerCar.baseMarketValue >= 150000) {
      baseTierBonus = 6;
    }

    // 3. Applied Modifications & Detailing Options
    int tuningHpBoost = 0;
    if (playerCar.appliedDetailingOptionIds.contains('tune_ecu_stg2')) tuningHpBoost += 25;
    if (playerCar.appliedDetailingOptionIds.contains('tune_ecu_stg1')) tuningHpBoost += 15;
    if (playerCar.appliedDetailingOptionIds.contains('tune_exhaust')) tuningHpBoost += 10;
    if (playerCar.appliedDetailingOptionIds.contains('tune_bodykit')) tuningHpBoost += 8;
    if (playerCar.appliedDetailingOptionIds.contains('tune_air_suspension')) tuningHpBoost += 7;

    // Detailing aesthetics / polish gives traction & aerodynamic confidence
    final detailingCount = playerCar.appliedDetailingOptionIds.where((id) => !id.startsWith('tune_')).length;
    final detailingBonus = detailingCount * 4;

    final dopingBonus = playerCar.isDoped ? 12 : 0;

    return (enginePower + transPower + chassisPower + baseTierBonus + tuningHpBoost + detailingBonus + dopingBonus).round();
  }

  /// Finds a balanced and exciting rival matched to the player's car power
  static NightRivalModel getMatchedRival(CarModel playerCar) {
    final playerPower = calculatePlayerPower(playerCar);

    int targetTier = 1;
    if (playerPower >= 80) {
      targetTier = 3;
    } else if (playerPower >= 52) {
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
      basePrize = 40000.0 + _random.nextInt(25000);
      repBonus = 6;
    } else if (activeRival.tier == 3) {
      basePrize = 75000.0 + _random.nextInt(45000);
      repBonus = 10;
    } else {
      basePrize = 20000.0 + _random.nextInt(15000);
      repBonus = 4;
    }

    String summary;
    if (isWon) {
      if (margin >= 12) {
        summary = 'Açık ara zafer! ${playerCar.modelName} müthiş bir kalkış yaparak ${activeRival.name} (${activeRival.carName}) karşısında ilk 200 metrede 3 boy fark açtı ve finişi ezici bir üstünlükle geçti!';
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
        summary = 'Rakip çok güçlüydü! ${activeRival.name} (${activeRival.modificationSummary}) yüksek turbo basıncı ve üstün çekişiyle düzlükte farkı açarak yarışı kazandı.';
      } else {
        summary = 'Kıl payı kaçtı! ${activeRival.name} (${activeRival.carName}) viraj çıkışındaki agresif hamlesiyle son anda öne geçti. Küçük bir modifiye veya motor bakımıyla bir dahaki sefere alırsın!';
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

