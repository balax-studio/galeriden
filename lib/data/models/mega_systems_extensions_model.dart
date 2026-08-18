import 'package:flutter/material.dart';
import 'car_model.dart';

/// 1. Galerici Lakapları & Ünvan Sistemi (§5)
enum DealerTitle {
  caylak(
    id: 'caylak',
    title: 'Çaylak Galericik',
    description: 'Mesleğe yeni adım atmış hevesli esnaf.',
    perkDescription: 'Temel başlangıç seviyesi',
    icon: Icons.person_outline_rounded,
    color: Color(0xFF94A3B8),
  ),
  samanlikKurdu(
    id: 'samanlik_kurdu',
    title: 'Samanlık Kurdu',
    description: 'Köy garajlarında yatan unutulmuş kelepirleri kokusundan tanır.',
    perkDescription: 'Samanlık ve kelepir araç alımlarında +%15 kâr marjı',
    icon: Icons.agriculture_rounded,
    color: Color(0xFFD97706),
  ),
  otocenterBaronu(
    id: 'otocenter_baronu',
    title: 'Oto Center Baronu',
    description: 'Piyasadaki tüm alıcıların ve satıcıların çekindiği kurt tüccar.',
    perkDescription: 'Tüm pazarlıklarda müşterinin inadını %20 daha hızlı kırar',
    icon: Icons.domain_rounded,
    color: Color(0xFFFFDE59),
  ),
  halkinEsnafi(
    id: 'halkin_esnafi',
    title: 'Halkın Güvenilir Esnafı',
    description: 'Dürüstlüğüyle nam salmış, mahallenin sevilen ağabeyi.',
    perkDescription: 'Satış sonrası kazanılan itibar puanlarına +%25 bonus',
    icon: Icons.verified_user_rounded,
    color: Color(0xFF00E575),
  ),
  kuponKoleksiyoncusu(
    id: 'kupon_koleksiyoncusu',
    title: 'Kupon Koleksiyoncusu',
    description: 'Nadir, klasik ve prestijli araçların aranan uzmanı.',
    perkDescription: 'Nadir araçlara gelen alıcı teklif sıklığı 2 katına çıkar',
    icon: Icons.diamond_rounded,
    color: Color(0xFFA855F7),
  );

  final String id;
  final String title;
  final String description;
  final String perkDescription;
  final IconData icon;
  final Color color;

  const DealerTitle({
    required this.id,
    required this.title,
    required this.description,
    required this.perkDescription,
    required this.icon,
    required this.color,
  });

  static DealerTitle fromId(String? id) {
    return DealerTitle.values.firstWhere(
      (t) => t.id == id,
      orElse: () => DealerTitle.caylak,
    );
  }
}

/// 2. Ekspertiz Paketleri (§9)
enum ExpertisePackageTier {
  economic(
    name: 'Ekonomik Paket',
    cost: 750.0,
    description: 'Kaporta & Boya/Değişen Kontrolü',
    icon: Icons.shield_outlined,
    color: Color(0xFF38BDF8),
  ),
  standard(
    name: 'Standart Paket',
    cost: 1800.0,
    description: 'Kaporta + Motor & Şanzıman + 5664 Tramer',
    icon: Icons.verified_rounded,
    color: Color(0xFFFFDE59),
  ),
  vipFull(
    name: 'Full VIP Ekspertiz & Dyno',
    cost: 3500.0,
    description: 'Kaporta + Dyno Motor HP Testi + Airbag & Beyin Analizi',
    icon: Icons.stars_rounded,
    color: Color(0xFF00E575),
  );

  final String name;
  final double cost;
  final String description;
  final IconData icon;
  final Color color;

  const ExpertisePackageTier({
    required this.name,
    required this.cost,
    required this.description,
    required this.icon,
    required this.color,
  });
}

/// Dyno Beygir Gücü & Tork Test Raporu (§9)
class DynoTestReport {
  final int factoryHp;
  final int measuredHp;
  final int factoryTorque;
  final int measuredTorque;
  final double healthPercentage;

  const DynoTestReport({
    required this.factoryHp,
    required this.measuredHp,
    required this.factoryTorque,
    required this.measuredTorque,
    required this.healthPercentage,
  });

  static DynoTestReport generate(CarModel car) {
    final baseHp = car.factoryHorsepower;
    final baseTorque = car.factoryTorque;
    final conditionFactor = (car.expertise.engineCondition / 100.0).clamp(0.40, 1.0);
    
    // Effective measured HP includes engine health + tuning mods
    final measured = car.effectiveHorsepower;
    final measuredTorq = (baseTorque * (0.75 + 0.25 * conditionFactor)).round();

    return DynoTestReport(
      factoryHp: baseHp,
      measuredHp: measured,
      factoryTorque: baseTorque,
      measuredTorque: measuredTorq,
      healthPercentage: ((measured / (baseHp == 0 ? 1 : baseHp)) * 100).clamp(30.0, 180.0),
    );
  }
}

/// 3. Chip Tuning & Modifiye Sistemleri (§22)
enum ChipTuningStage {
  none(id: 'none', name: 'Fabrikasyon ECU', hpBoost: 0, cost: 0.0, valueBoostMultiplier: 1.0),
  stage1(id: 'stage_1_ecu', name: 'Stage 1 Yazılım (ECU Remap)', hpBoost: 35, cost: 4500.0, valueBoostMultiplier: 1.10),
  stage2(id: 'stage_2_ecu', name: 'Stage 2 Yazılım & Downpipe', hpBoost: 75, cost: 9500.0, valueBoostMultiplier: 1.22);

  final String id;
  final String name;
  final int hpBoost;
  final double cost;
  final double valueBoostMultiplier;

  const ChipTuningStage({
    required this.id,
    required this.name,
    required this.hpBoost,
    required this.cost,
    required this.valueBoostMultiplier,
  });
}

/// 4. Pazarlık Masası Çay & Kahve İkramları (§24)
enum NegotiationTreat {
  tea(
    id: 'tea',
    name: 'Tavşan Kanı İnce Belli Çay',
    cost: 50.0,
    patienceBoost: 0.20,
    stubbornnessDrop: 0.15,
    dialogue: 'Ustam ocaktan yeni çıktı, tavşan kanı çayımızı içelim tatlıya bağlayalım!',
    icon: Icons.emoji_food_beverage_rounded,
    color: Color(0xFFEF4444),
  ),
  turkishCoffee(
    id: 'coffee',
    name: 'Közde Okkalı Türk Kahvesi',
    cost: 150.0,
    patienceBoost: 0.40,
    stubbornnessDrop: 0.30,
    dialogue: 'Közde 40 yıllık hatrı olan Türk kahvemizi ikram edeyim, ticaret bahane dostluk baki.',
    icon: Icons.local_cafe_rounded,
    color: Color(0xFFD97706),
  );

  final String id;
  final String name;
  final double cost;
  final double patienceBoost;
  final double stubbornnessDrop;
  final String dialogue;
  final IconData icon;
  final Color color;

  const NegotiationTreat({
    required this.id,
    required this.name,
    required this.cost,
    required this.patienceBoost,
    required this.stubbornnessDrop,
    required this.dialogue,
    required this.icon,
    required this.color,
  });
}

/// 5. Faktoring & Çek Kırdırma Fırsatı (§10)
class FactoringDeal {
  final String chequeId;
  final double faceValue;
  final double discountRate; // 0.08 - 0.10
  final double payoutCash;

  const FactoringDeal({
    required this.chequeId,
    required this.faceValue,
    required this.discountRate,
    required this.payoutCash,
  });

  static FactoringDeal calculate(String chequeId, double faceValue) {
    const rate = 0.085; // %8.5 komisyon
    final payout = faceValue * (1.0 - rate);
    return FactoringDeal(
      chequeId: chequeId,
      faceValue: faceValue,
      discountRate: rate,
      payoutCash: payout,
    );
  }
}

/// 6. Karaborsa Polis Baskını Kararı (§2)
enum PoliceEncounterAction {
  bribe(
    id: 'bribe',
    title: 'Çorba Parası / Rüşvet Teklif Et',
    cost: 7500.0,
    successChance: 0.65,
    icon: Icons.monetization_on_rounded,
    color: Color(0xFFFFDE59),
  ),
  legalDefense(
    id: 'legal',
    title: 'Avukat Çağır & İtiraz Et',
    cost: 3000.0,
    successChance: 0.45,
    icon: Icons.gavel_rounded,
    color: Color(0xFF38BDF8),
  ),
  surrenderCar(
    id: 'surrender',
    title: 'Aracı Yediemine Teslim Et',
    cost: 0.0,
    successChance: 1.0,
    icon: Icons.cancel_outlined,
    color: Color(0xFFEF4444),
  );

  final String id;
  final String title;
  final double cost;
  final double successChance;
  final IconData icon;
  final Color color;

  const PoliceEncounterAction({
    required this.id,
    required this.title,
    required this.cost,
    required this.successChance,
    required this.icon,
    required this.color,
  });
}

/// 7. VIP Dizi / Reklam Çekimi Kiralama Sözleşmesi (§15)
class VipSetRentalContract {
  final String id;
  final String carId;
  final String productionName;
  final int days;
  final double dailyRate;
  final double totalPayout;

  const VipSetRentalContract({
    required this.id,
    required this.carId,
    required this.productionName,
    required this.days,
    required this.dailyRate,
    required this.totalPayout,
  });

  static VipSetRentalContract generate(CarModel car) {
    final baseDaily = (car.estimatedRealValue * 0.015).clamp(2500.0, 15000.0);
    final days = 3;
    final total = baseDaily * days;
    return VipSetRentalContract(
      id: 'vip_set_${DateTime.now().millisecondsSinceEpoch}',
      carId: car.id,
      productionName: 'Ay Yapım - Mafya & Holding Dizisi Çekimi',
      days: days,
      dailyRate: baseDaily,
      totalPayout: total,
    );
  }
}

/// 8. Finansal Sağlık Skoru (§8)
enum HealthGrade {
  aPlus(grade: 'A+', label: 'Kusursuz Finansal Güç', color: Color(0xFF00E575)),
  a(grade: 'A', label: 'Güçlü Nakit & Likidite', color: Color(0xFF10B981)),
  b(grade: 'B', label: 'Dengeli Esnaf Bilançosu', color: Color(0xFFFFDE59)),
  c(grade: 'C', label: 'Dikkat: Borç Yükü Yüksek', color: Color(0xFFF59E0B)),
  d(grade: 'D', label: 'Riskli: Nakit Sıkışıklığı', color: Color(0xFFEF4444)),
  f(grade: 'F', label: 'İflas Tehlikesi & Haciz Riski', color: Color(0xFF991B1B));

  final String grade;
  final String label;
  final Color color;

  const HealthGrade({
    required this.grade,
    required this.label,
    required this.color,
  });

  static HealthGrade calculate({
    required double balance,
    required double totalDebt,
    required double totalInventoryValue,
    required double dailyExpenses,
  }) {
    final netWorth = balance + totalInventoryValue - totalDebt;
    if (netWorth < 0 || balance < dailyExpenses * 2) return HealthGrade.f;
    if (totalDebt > balance * 3) return HealthGrade.d;
    if (totalDebt > balance * 1.5) return HealthGrade.c;
    if (balance > totalDebt && netWorth > 1000000) return HealthGrade.aPlus;
    if (balance > totalDebt) return HealthGrade.a;
    return HealthGrade.b;
  }
}
