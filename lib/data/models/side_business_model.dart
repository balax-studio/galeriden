enum SideBusinessType { carWash, vendingMachine, towTruck, billboard, autoShop }

class SideBusinessUpgradeModel {
  final String id;
  final String title;
  final String description;
  final double cost;
  final double bonusDailyIncome;
  final bool isPurchased;
  final String iconName;

  SideBusinessUpgradeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.cost,
    required this.bonusDailyIncome,
    this.isPurchased = false,
    this.iconName = 'store',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'cost': cost,
    'bonusDailyIncome': bonusDailyIncome,
    'isPurchased': isPurchased,
    'iconName': iconName,
  };

  factory SideBusinessUpgradeModel.fromJson(Map<String, dynamic> json) => SideBusinessUpgradeModel(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String? ?? '',
    cost: (json['cost'] as num).toDouble(),
    bonusDailyIncome: (json['bonusDailyIncome'] as num).toDouble(),
    isPurchased: json['isPurchased'] as bool? ?? false,
    iconName: json['iconName'] as String? ?? 'store',
  );

  SideBusinessUpgradeModel copyWith({
    String? id,
    String? title,
    String? description,
    double? cost,
    double? bonusDailyIncome,
    bool? isPurchased,
    String? iconName,
  }) {
    return SideBusinessUpgradeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      cost: cost ?? this.cost,
      bonusDailyIncome: bonusDailyIncome ?? this.bonusDailyIncome,
      isPurchased: isPurchased ?? this.isPurchased,
      iconName: iconName ?? this.iconName,
    );
  }
}

class SideBusinessModel {
  final String id;
  final String name;
  final String description;
  final SideBusinessType type;
  final double dailyIncome;
  final double cost;
  final bool isOwned;
  final int level;
  final List<SideBusinessUpgradeModel> upgrades;
  final double totalEarned;

  SideBusinessModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.type,
    required this.dailyIncome,
    required this.cost,
    this.isOwned = false,
    this.level = 1,
    this.upgrades = const [],
    this.totalEarned = 0.0,
  });

  double get effectiveDailyIncome {
    if (!isOwned) return 0.0;
    final base = dailyIncome * (1 + (level - 1) * 0.4);
    final upgradeBonuses = upgrades.where((u) => u.isPurchased).fold(0.0, (sum, u) => sum + u.bonusDailyIncome);
    return base + upgradeBonuses;
  }

  int get purchasedUpgradeCount => upgrades.where((u) => u.isPurchased).length;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'type': type.name,
    'dailyIncome': dailyIncome,
    'cost': cost,
    'isOwned': isOwned,
    'level': level,
    'upgrades': upgrades.map((u) => u.toJson()).toList(),
    'totalEarned': totalEarned,
  };

  factory SideBusinessModel.fromJson(Map<String, dynamic> json) => SideBusinessModel(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    type: SideBusinessType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => SideBusinessType.vendingMachine,
    ),
    dailyIncome: (json['dailyIncome'] as num).toDouble(),
    cost: (json['cost'] as num?)?.toDouble() ?? (json['purchaseCost'] as num?)?.toDouble() ?? 0.0,
    isOwned: json['isOwned'] as bool? ?? false,
    level: json['level'] as int? ?? 1,
    upgrades: json['upgrades'] != null
        ? (json['upgrades'] as List).map((u) => SideBusinessUpgradeModel.fromJson(u)).toList()
        : const [],
    totalEarned: (json['totalEarned'] as num?)?.toDouble() ?? 0.0,
  );

  SideBusinessModel copyWith({
    String? id,
    String? name,
    String? description,
    SideBusinessType? type,
    double? dailyIncome,
    double? cost,
    bool? isOwned,
    int? level,
    List<SideBusinessUpgradeModel>? upgrades,
    double? totalEarned,
  }) {
    return SideBusinessModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      dailyIncome: dailyIncome ?? this.dailyIncome,
      cost: cost ?? this.cost,
      isOwned: isOwned ?? this.isOwned,
      level: level ?? this.level,
      upgrades: upgrades ?? this.upgrades,
      totalEarned: totalEarned ?? this.totalEarned,
    );
  }
}
