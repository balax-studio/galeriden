import 'dart:math';

class PlayerSkills {
  final int negotiationLevel; // 1-10: Pazarlık Yeteneği (alıcılardan daha yüksek teklif & ucuz alım)
  final int eyeForDetail;     // 1-10: Ekspertiz Sezgisi (gizli kusuru sezme & ekspertiz indirimi)
  final int marketSense;      // 1-10: Piyasa Tahmini / Doping Etkinliği
  final int reputation;       // 1-10: İtibar (daha sık & zengin alıcı çekme)
  final int financeSense;     // 1-10: Finansal Zeka (düşük faiz & çek risk düşürme)
  final int xp;               // Toplam Deneyim Puanı
  final int bonusSkillPoints; // Başarımlardan kazanılan ekstra yetenek puanları

  PlayerSkills({
    this.negotiationLevel = 1,
    this.eyeForDetail = 1,
    this.marketSense = 1,
    this.reputation = 1,
    this.financeSense = 1,
    this.xp = 0,
    this.bonusSkillPoints = 0,
  });

  /// Calibrated early win progression: Level 1 -> 2 in first 3-5 mins, then smooth logarithmic curve
  static int requiredXpForLevel(int level) {
    if (level <= 1) return 1250;
    if (level == 2) return 3500;
    if (level == 3) return 8000;
    if (level == 4) return 15000;
    return (15000 * pow(1.35, level - 4)).round();
  }

  /// Calculates level based on accumulated total XP
  int get currentLevel {
    int lvl = 1;
    int accumulatedXp = 0;
    while (true) {
      final req = requiredXpForLevel(lvl);
      if (accumulatedXp + req > xp) {
        return lvl;
      }
      accumulatedXp += req;
      lvl++;
    }
  }

  /// XP needed in current level
  int get xpInCurrentLevel {
    int lvl = 1;
    int accumulatedXp = 0;
    while (true) {
      final req = requiredXpForLevel(lvl);
      if (accumulatedXp + req > xp) {
        return xp - accumulatedXp;
      }
      accumulatedXp += req;
      lvl++;
    }
  }

  /// Target XP for current level
  int get currentLevelTargetXp => requiredXpForLevel(currentLevel);

  /// Total skill points earned from leveling up + bonus skill points
  int get totalSkillPointsEarned => (currentLevel - 1) + bonusSkillPoints;

  /// Total skill points spent in upgrading skills
  int get totalSkillPointsSpent =>
      (negotiationLevel - 1) +
      (eyeForDetail - 1) +
      (marketSense - 1) +
      (reputation - 1) +
      (financeSense - 1);

  /// Skill points available to spend
  int get availableSkillPoints => totalSkillPointsEarned - totalSkillPointsSpent;

  // --- Skill Multipliers ---

  /// Pazarlık indirimi / kâr marjı (%2 per level, max %18)
  double get negotiationMultiplier => min(0.20, (negotiationLevel - 1) * 0.02);

  /// Ekspertiz indirim oranı (%5 per level, max %45)
  double get expertiseCostDiscount => min(0.50, (eyeForDetail - 1) * 0.05);

  /// Doping ve İlan teklif sıklık bonusu (%15 per level)
  double get marketingDopingBonus => (marketSense - 1) * 0.15;

  /// Kredi faizi indirim oranı (%1 per level, max %9)
  double get financeInterestDiscount => min(0.10, (financeSense - 1) * 0.01);

  /// Çek karşılıksız çıkma riski azalışı (%0.5 per level)
  double get chequeRiskReduction => min(0.045, (financeSense - 1) * 0.005);

  Map<String, dynamic> toJson() => {
        'negotiationLevel': negotiationLevel,
        'eyeForDetail': eyeForDetail,
        'marketSense': marketSense,
        'reputation': reputation,
        'financeSense': financeSense,
        'xp': xp,
        'bonusSkillPoints': bonusSkillPoints,
      };

  factory PlayerSkills.fromJson(Map<String, dynamic> json) => PlayerSkills(
        negotiationLevel: json['negotiationLevel'] as int? ?? 1,
        eyeForDetail: json['eyeForDetail'] as int? ?? 1,
        marketSense: json['marketSense'] as int? ?? 1,
        reputation: json['reputation'] as int? ?? 1,
        financeSense: json['financeSense'] as int? ?? 1,
        xp: json['xp'] as int? ?? 0,
        bonusSkillPoints: json['bonusSkillPoints'] as int? ?? 0,
      );

  PlayerSkills copyWith({
    int? negotiationLevel,
    int? eyeForDetail,
    int? marketSense,
    int? reputation,
    int? financeSense,
    int? xp,
    int? bonusSkillPoints,
  }) {
    return PlayerSkills(
      negotiationLevel: negotiationLevel ?? this.negotiationLevel,
      eyeForDetail: eyeForDetail ?? this.eyeForDetail,
      marketSense: marketSense ?? this.marketSense,
      reputation: reputation ?? this.reputation,
      financeSense: financeSense ?? this.financeSense,
      xp: xp ?? this.xp,
      bonusSkillPoints: bonusSkillPoints ?? this.bonusSkillPoints,
    );
  }
}

