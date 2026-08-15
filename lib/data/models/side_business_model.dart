enum SideBusinessType {
  carWash,
  vendingMachine,
  towTruck,
  billboard,
  autoShop,
  inspectionStation,
  carRental,
  evCharging,
  corporateExpertise,
  sparePartsStore,
  wrapStudio,
}

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

  // Manager hiring & operational fields
  final bool hasManager;
  final String managerTitle;
  final double managerCost;
  final double managerSalary;
  final double managerBonusPercent;

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
    this.hasManager = false,
    this.managerTitle = 'İşletme Müdürü',
    this.managerCost = 15000.0,
    this.managerSalary = 200.0,
    this.managerBonusPercent = 0.30,
  });

  double get grossDailyIncome {
    if (!isOwned) return 0.0;
    final base = dailyIncome * (1 + (level - 1) * 0.35);
    final upgradeBonuses = upgrades.where((u) => u.isPurchased).fold(0.0, (sum, u) => sum + u.bonusDailyIncome);
    double total = base + upgradeBonuses;
    if (hasManager) {
      total = total * (1 + managerBonusPercent);
    }
    return total;
  }

  double get dailyMaintenanceExpense {
    if (!isOwned) return 0.0;
    double expense = grossDailyIncome * 0.15;
    if (hasManager) {
      expense += managerSalary;
    }
    return expense;
  }

  double get effectiveDailyIncome {
    if (!isOwned) return 0.0;
    final net = grossDailyIncome - dailyMaintenanceExpense;
    return net;
  }

  double get nextLevelUpgradeCost {
    if (level >= 5) return 0.0;
    return cost * 1.20 * (level * level);
  }

  double get totalInvested {
    double total = cost;
    if (level > 1) {
      for (int i = 1; i < level; i++) {
        total += cost * 1.5 * i;
      }
    }
    final purchasedUpgradesCost = upgrades.where((u) => u.isPurchased).fold(0.0, (sum, u) => sum + u.cost);
    total += purchasedUpgradesCost;
    if (hasManager) total += managerCost;
    return total;
  }

  int get roiDays {
    final daily = effectiveDailyIncome;
    if (daily <= 0) return 999;
    return (totalInvested / daily).ceil();
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
    'hasManager': hasManager,
    'managerTitle': managerTitle,
    'managerCost': managerCost,
    'managerSalary': managerSalary,
    'managerBonusPercent': managerBonusPercent,
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
    hasManager: json['hasManager'] as bool? ?? false,
    managerTitle: json['managerTitle'] as String? ?? 'İşletme Müdürü',
    managerCost: (json['managerCost'] as num?)?.toDouble() ?? 15000.0,
    managerSalary: (json['managerSalary'] as num?)?.toDouble() ?? 200.0,
    managerBonusPercent: (json['managerBonusPercent'] as num?)?.toDouble() ?? 0.30,
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
    bool? hasManager,
    String? managerTitle,
    double? managerCost,
    double? managerSalary,
    double? managerBonusPercent,
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
      hasManager: hasManager ?? this.hasManager,
      managerTitle: managerTitle ?? this.managerTitle,
      managerCost: managerCost ?? this.managerCost,
      managerSalary: managerSalary ?? this.managerSalary,
      managerBonusPercent: managerBonusPercent ?? this.managerBonusPercent,
    );
  }
}
