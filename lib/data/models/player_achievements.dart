class AchievementItem {
  final String id;
  final String title;
  final String description;
  final int rewardMoney;
  final int rewardXP;
  final int rewardSkillPoints;
  final int tier; // 1, 2, 3
  final bool isUnlocked;
  final bool isClaimed;

  AchievementItem({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardMoney,
    required this.rewardXP,
    this.rewardSkillPoints = 1,
    this.tier = 1,
    this.isUnlocked = false,
    this.isClaimed = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'rewardMoney': rewardMoney,
        'rewardXP': rewardXP,
        'rewardSkillPoints': rewardSkillPoints,
        'tier': tier,
        'isUnlocked': isUnlocked,
        'isClaimed': isClaimed,
      };

  factory AchievementItem.fromJson(Map<String, dynamic> json) => AchievementItem(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        rewardMoney: json['rewardMoney'] as int,
        rewardXP: json['rewardXP'] as int,
        rewardSkillPoints: json['rewardSkillPoints'] as int? ?? 1,
        tier: json['tier'] as int? ?? 1,
        isUnlocked: json['isUnlocked'] as bool? ?? false,
        isClaimed: json['isClaimed'] as bool? ?? false,
      );

  AchievementItem copyWith({
    bool? isUnlocked,
    bool? isClaimed,
  }) =>
      AchievementItem(
        id: id,
        title: title,
        description: description,
        rewardMoney: rewardMoney,
        rewardXP: rewardXP,
        rewardSkillPoints: rewardSkillPoints,
        tier: tier,
        isUnlocked: isUnlocked ?? this.isUnlocked,
        isClaimed: isClaimed ?? this.isClaimed,
      );
}

class PlayerAchievements {
  static List<AchievementItem> get initialList => [
        // --- Satış & Ticaret Başarımları (Tier 1-3) ---
        AchievementItem(id: 'first_buy', title: 'İlk Adım • Tier I', description: 'Dede mirası ilk arabanı teslim al', rewardMoney: 2500, rewardXP: 50, rewardSkillPoints: 1, tier: 1, isUnlocked: true),
        AchievementItem(id: 'first_sale', title: 'Siftah • Tier I', description: 'İlk arabanı kârla sat', rewardMoney: 5000, rewardXP: 100, rewardSkillPoints: 1, tier: 1),
        AchievementItem(id: 'sales_10', title: 'Galeri Tüccarı • Tier II', description: 'Toplam 10 araç satışı yap', rewardMoney: 15000, rewardXP: 250, rewardSkillPoints: 2, tier: 2),
        AchievementItem(id: 'sales_50', title: 'Otomotiv İmparatoru • Tier III', description: 'Toplam 50 araç satışı yap', rewardMoney: 75000, rewardXP: 1000, rewardSkillPoints: 3, tier: 3),

        // --- Ekspertiz & Restorasyon Başarımları ---
        AchievementItem(id: 'expert_master', title: 'Dedektif • Tier I', description: '5 defa ekspertiz raporu al', rewardMoney: 3000, rewardXP: 75, rewardSkillPoints: 1, tier: 1),
        AchievementItem(id: 'restoration_king', title: 'Usta Elleri • Tier I', description: 'Bir aracı %100 yenile ve temizle', rewardMoney: 7500, rewardXP: 150, rewardSkillPoints: 1, tier: 1),
        AchievementItem(id: 'restoration_5', title: 'Sanayi Efsanesi • Tier II', description: '5 aracı tamamen yenile', rewardMoney: 25000, rewardXP: 500, rewardSkillPoints: 2, tier: 2),

        // --- Finans & Pasif Gelir Başarımları ---
        AchievementItem(id: 'side_business_1', title: 'Girişimci • Tier I', description: 'İlk yan işletmeni kur', rewardMoney: 10000, rewardXP: 200, rewardSkillPoints: 1, tier: 1),
        AchievementItem(id: 'stock_investor', title: 'Borsa Spekülatörü • Tier I', description: 'İlk borsa hisse senedi alımını yap', rewardMoney: 5000, rewardXP: 100, rewardSkillPoints: 1, tier: 1),
        AchievementItem(id: 'dealer_baron', title: 'Galeri Baronu • Tier III', description: 'Toplam ₺250.000 kâra ulaş', rewardMoney: 50000, rewardXP: 1000, rewardSkillPoints: 3, tier: 3),
        AchievementItem(id: 'streak_7', title: 'Kararlı Tüccar • Tier II', description: '7 gün üst üste oyuna giriş yap', rewardMoney: 15000, rewardXP: 300, rewardSkillPoints: 2, tier: 2),
      ];
}

