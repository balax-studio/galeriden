class AchievementItem {
  final String id;
  final String title;
  final String description;
  final int rewardMoney;
  final int rewardXP;
  final bool isUnlocked;

  AchievementItem({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardMoney,
    required this.rewardXP,
    this.isUnlocked = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'rewardMoney': rewardMoney,
        'rewardXP': rewardXP,
        'isUnlocked': isUnlocked,
      };

  factory AchievementItem.fromJson(Map<String, dynamic> json) => AchievementItem(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        rewardMoney: json['rewardMoney'] as int,
        rewardXP: json['rewardXP'] as int,
        isUnlocked: json['isUnlocked'] as bool? ?? false,
      );

  AchievementItem copyWith({bool? isUnlocked}) => AchievementItem(
        id: id,
        title: title,
        description: description,
        rewardMoney: rewardMoney,
        rewardXP: rewardXP,
        isUnlocked: isUnlocked ?? this.isUnlocked,
      );
}

class PlayerAchievements {
  static List<AchievementItem> get initialList => [
        AchievementItem(id: 'first_buy', title: 'İlk Adım', description: 'Pazardan ilk arabanı satın al', rewardMoney: 2500, rewardXP: 50),
        AchievementItem(id: 'first_sale', title: 'Siftah', description: 'İlk arabanı kârla sat', rewardMoney: 5000, rewardXP: 100),
        AchievementItem(id: 'expert_master', title: 'Dedektif', description: '5 defa ekspertiz raporu al', rewardMoney: 3000, rewardXP: 75),
        AchievementItem(id: 'restoration_king', title: 'Usta Elleri', description: 'Bir aracı %100 yenile ve temizle', rewardMoney: 7500, rewardXP: 150),
        AchievementItem(id: 'dealer_baron', title: 'Galeri Baronu', description: 'Toplam ₺250.000 kâra ulaş', rewardMoney: 25000, rewardXP: 500),
        AchievementItem(id: 'streak_7', title: 'Kararlı Tüccar', description: '7 gün üst üste oyuna giriş yap', rewardMoney: 15000, rewardXP: 300),
      ];
}
