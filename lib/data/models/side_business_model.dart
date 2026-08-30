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

extension SideBusinessTypeExtension on SideBusinessType {
  String getLocalizedName([String? lang]) {
    final l = lang ?? 'tr';
    switch (this) {
      case SideBusinessType.carWash:
        switch (l) {
          case 'en': return 'Car Wash & Detailing';
          case 'de': return 'Autowäsche & Detailing';
          case 'pt': return 'Lava-Jato & Detalhamento';
          case 'es': return 'Lavado y Detallado de Coches';
          case 'ru': return 'Автомойка и Детейлинг';
          case 'ar': return 'غسيل وتلميع السيارات';
          default: return 'Oto Yıkama & Detaylı Temizlik';
        }
      case SideBusinessType.vendingMachine:
        switch (l) {
          case 'en': return 'Vending & Coffee Station';
          case 'de': return 'Verkaufsautomat & Kaffeebar';
          case 'pt': return 'Máquinas de Venda & Café';
          case 'es': return 'Máquina Expendedora y Café';
          case 'ru': return 'Вендинг и Кофе-бар';
          case 'ar': return 'ماكينة بيع آلي ومحطة قهوة';
          default: return 'Otomat & Kahve İstasyonu';
        }
      case SideBusinessType.towTruck:
        switch (l) {
          case 'en': return 'Towing & Recovery Service';
          case 'de': return 'Abschleppdienst & Pannenhilfe';
          case 'pt': return 'Guincho & Socorro 24h';
          case 'es': return 'Servicio de Grúa y Rescate';
          case 'ru': return 'Эвакуатор и Служба спасения';
          case 'ar': return 'خدمة سحب وإنقاذ السيارات';
          default: return 'Oto Kurtarma & Çekici Hizmeti';
        }
      case SideBusinessType.billboard:
        switch (l) {
          case 'en': return 'Digital Billboard & Ads';
          case 'de': return 'Digitale Plakatwand & Werbung';
          case 'pt': return 'Painel Digital & Anúncios';
          case 'es': return 'Valla Digital y Publicidad';
          case 'ru': return 'Цифровой билборд и Реклама';
          case 'ar': return 'لوحة إعلانات رقمية';
          default: return 'Dijital Reklam & Billboard';
        }
      case SideBusinessType.autoShop:
        switch (l) {
          case 'en': return 'Quick Lube & Oil Change Shop';
          case 'de': return 'Schnellservice & Ölwechsel';
          case 'pt': return 'Troca de Óleo & Manutenção Rápida';
          case 'es': return 'Cambio de Aceite y Mantenimiento';
          case 'ru': return 'Экспресс-сервис и Замена масла';
          case 'ar': return 'خدمة سريعة وتغيير زيت';
          default: return 'Hızlı Bakım & Yağ Değişim Noktası';
        }
      case SideBusinessType.inspectionStation:
        switch (l) {
          case 'en': return 'Vehicle Inspection & Pre-Check';
          case 'de': return 'Fahrzeugprüfstelle & Vorab-Check';
          case 'pt': return 'Vistoria & Pré-Inspeção Veicular';
          case 'es': return 'Inspección y Revisión Previa';
          case 'ru': return 'Пункт техосмотра и Диагностика';
          case 'ar': return 'فحص فني ومعاينة مسبقة';
          default: return 'Araç Muayene & Ön Kontrol İstasyonu';
        }
      case SideBusinessType.carRental:
        switch (l) {
          case 'en': return 'Rent-A-Car & Fleet Leasing';
          case 'de': return 'Mietwagen & Flottenverleih';
          case 'pt': return 'Aluguel de Carros & Frotas';
          case 'es': return 'Alquiler de Coches y Flotas';
          case 'ru': return 'Прокат авто и Аренда парка';
          case 'ar': return 'تأجير سيارات وتأجير أساطيل';
          default: return 'Rent a Car & Filo Kiralama';
        }
      case SideBusinessType.evCharging:
        switch (l) {
          case 'en': return 'EV Fast Charging Station';
          case 'de': return 'E-Auto Schnellladestation';
          case 'pt': return 'Estação de Recarga Rápida EV';
          case 'es': return 'Estación de Carga Rápida VE';
          case 'ru': return 'Станция быстрой зарядки электромобилей';
          case 'ar': return 'محطة شحن سريع للسيارات الكهربائية';
          default: return 'Elektrikli Araç Şarj İstasyonu';
        }
      case SideBusinessType.corporateExpertise:
        switch (l) {
          case 'en': return 'Corporate Inspection & Dyno Center';
          case 'de': return 'Prüfzentrum & Dyno-Messstand';
          case 'pt': return 'Centro de Perícia & Dyno';
          case 'es': return 'Centro de Peritaje y Dyno';
          case 'ru': return 'Экспертный центр и Диностенд';
          case 'ar': return 'مركز فحص فني وداينو احترافي';
          default: return 'Kurumsal Ekspertiz & Dyno Merkezi';
        }
      case SideBusinessType.sparePartsStore:
        switch (l) {
          case 'en': return 'Spare Parts & Accessories Store';
          case 'de': return 'Ersatzteile- & Zubehör-Shop';
          case 'pt': return 'Loja de Autopeças & Acessórios';
          case 'es': return 'Tienda de Recambios y Accesorios';
          case 'ru': return 'Магазин автозапчастей и Аксессуаров';
          case 'ar': return 'متجر قطع غيار وإكسسوارات';
          default: return 'Yedek Parça & Aksesuar Mağazası';
        }
      case SideBusinessType.wrapStudio:
        switch (l) {
          case 'en': return 'Car Wrap & PPF Studio';
          case 'de': return 'Folierungs- & PPF-Studio';
          case 'pt': return 'Estúdio de Envelopamento & PPF';
          case 'es': return 'Estudio de Vinilado y PPF';
          case 'ru': return 'Студия оклейки и Защиты PPF';
          case 'ar': return 'استوديو تجليد وحماية السيارات PPF';
          default: return 'Araç Kaplama & PPF Koruma Stüdyosu';
        }
    }
  }

  int get baseConstructionDays {
    switch (this) {
      case SideBusinessType.vendingMachine:
        return 0;
      case SideBusinessType.billboard:
        return 1;
      case SideBusinessType.autoShop:
      case SideBusinessType.carWash:
        return 2;
      case SideBusinessType.towTruck:
      case SideBusinessType.sparePartsStore:
      case SideBusinessType.wrapStudio:
        return 3;
      case SideBusinessType.evCharging:
      case SideBusinessType.inspectionStation:
        return 4;
      case SideBusinessType.corporateExpertise:
      case SideBusinessType.carRental:
        return 5;
    }
  }
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

  // Construction & permit fields
  final bool isUnderConstruction;
  final int constructionDaysRemaining;
  final int totalConstructionDays;

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
    this.isUnderConstruction = false,
    this.constructionDaysRemaining = 0,
    this.totalConstructionDays = 0,
  });

  bool get isOperational => isOwned && !isUnderConstruction;

  double get constructionProgress {
    if (totalConstructionDays <= 0) return 1.0;
    return (1.0 - (constructionDaysRemaining / totalConstructionDays)).clamp(0.0, 1.0);
  }

  double get grossDailyIncome {
    if (!isOperational) return 0.0;
    final base = dailyIncome * (1 + (level - 1) * 0.35);
    final upgradeBonuses = upgrades.where((u) => u.isPurchased).fold(0.0, (sum, u) => sum + u.bonusDailyIncome);
    double total = base + upgradeBonuses;
    if (hasManager) {
      total = total * (1 + managerBonusPercent);
    }
    return total;
  }

  double get dailyMaintenanceExpense {
    if (!isOperational) return 0.0;
    double expense = grossDailyIncome * 0.15;
    if (hasManager) {
      expense += managerSalary;
    }
    return (expense * 100).roundToDouble() / 100.0;
  }

  double get effectiveDailyIncome {
    if (!isOperational) return 0.0;
    final net = grossDailyIncome - dailyMaintenanceExpense;
    return net;
  }

  /// Calculates the dynamic utilization multiplier (0.05 to 1.60) based on player's recent activities (§1.2)
  double calculateUtilizationMultiplier({
    int washedLast7Days = 0,
    int expertisesLast7Days = 0,
    int listedCarsCount = 0,
    int partsRepairedLast7Days = 0,
    int towedCarsLast7Days = 0,
    int activeRentalsCount = 0,
  }) {
    if (!isOperational) return 0.0;

    // Inactivity Decay: If the dealership has 0 inventory and 0 operational activity in the last 7 days,
    // side business customer footfall drops dramatically to prevent day-skip infinite wealth generation.
    final bool isGalleryDormant = listedCarsCount == 0 &&
        washedLast7Days == 0 &&
        expertisesLast7Days == 0 &&
        partsRepairedLast7Days == 0 &&
        towedCarsLast7Days == 0 &&
        activeRentalsCount == 0;

    if (isGalleryDormant) {
      return 0.05; // Minimal dormant maintenance utilization
    }

    switch (type) {
      case SideBusinessType.carWash:
        // 0 wash = 0.25, 4+ wash = 1.60
        return (0.25 + (washedLast7Days * 0.35)).clamp(0.25, 1.60);
      case SideBusinessType.inspectionStation:
      case SideBusinessType.corporateExpertise:
        // 0 expertise = 0.25, 3+ expertise = 1.60
        return (0.25 + (expertisesLast7Days * 0.45)).clamp(0.25, 1.60);
      case SideBusinessType.billboard:
        // 0 listed = 0.30, 4+ listed = 1.50
        return (0.30 + (listedCarsCount * 0.30)).clamp(0.30, 1.50);
      case SideBusinessType.sparePartsStore:
      case SideBusinessType.autoShop:
        // 0 repairs = 0.25, 4+ repairs = 1.60
        return (0.25 + (partsRepairedLast7Days * 0.35)).clamp(0.25, 1.60);
      case SideBusinessType.towTruck:
        // 0 towed = 0.30, 3+ towed = 1.50
        return (0.30 + (towedCarsLast7Days * 0.40)).clamp(0.30, 1.50);
      case SideBusinessType.carRental:
        // 0 rentals = 0.20, 3+ rentals = 1.70
        return (0.20 + (activeRentalsCount * 0.50)).clamp(0.20, 1.70);
      case SideBusinessType.wrapStudio:
        return (0.30 + (partsRepairedLast7Days * 0.30)).clamp(0.30, 1.50);
      case SideBusinessType.evCharging:
      case SideBusinessType.vendingMachine:
        // Baseline operational utilization based on gallery vehicle volume
        return (0.40 + (listedCarsCount * 0.20)).clamp(0.40, 1.50);
    }
  }

  /// Calculates effective daily income adjusted for utilization rate
  double effectiveIncomeWithUtilization({
    int washedLast7Days = 0,
    int expertisesLast7Days = 0,
    int listedCarsCount = 0,
    int partsRepairedLast7Days = 0,
    int towedCarsLast7Days = 0,
    int activeRentalsCount = 0,
  }) {
    if (!isOperational) return 0.0;
    final multiplier = calculateUtilizationMultiplier(
      washedLast7Days: washedLast7Days,
      expertisesLast7Days: expertisesLast7Days,
      listedCarsCount: listedCarsCount,
      partsRepairedLast7Days: partsRepairedLast7Days,
      towedCarsLast7Days: towedCarsLast7Days,
      activeRentalsCount: activeRentalsCount,
    );
    return (effectiveDailyIncome * multiplier).roundToDouble();
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
    'isUnderConstruction': isUnderConstruction,
    'constructionDaysRemaining': constructionDaysRemaining,
    'totalConstructionDays': totalConstructionDays,
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
    isUnderConstruction: json['isUnderConstruction'] as bool? ?? false,
    constructionDaysRemaining: json['constructionDaysRemaining'] as int? ?? 0,
    totalConstructionDays: json['totalConstructionDays'] as int? ?? 0,
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
    bool? isUnderConstruction,
    int? constructionDaysRemaining,
    int? totalConstructionDays,
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
      isUnderConstruction: isUnderConstruction ?? this.isUnderConstruction,
      constructionDaysRemaining: constructionDaysRemaining ?? this.constructionDaysRemaining,
      totalConstructionDays: totalConstructionDays ?? this.totalConstructionDays,
    );
  }
}
