import '../../core/constants/car_specifications.dart';
import 'expertise_model.dart';

enum ListingDeclarationType {
  honest,
  minorFlawHidden,
  flawlessClaim,
  tamperedMileageClaim,
}

class CarModel {
  final String id;
  final String brand;
  final String modelName;
  final int modelYear;
  final String bodyType; // Sedan, Hatchback, SUV, Spor, Klasik
  final String colorHex;
  final double baseMarketValue;
  final double currentPurchasePrice;
  final bool isDetailedCleaned;
  final bool isWashed;
  final bool isPolished;
  final bool isRare;
  final ExpertiseReport expertise;
  final ListingDeclarationType declarationType;
  final double? customListingPrice;
  final List<String> appliedDetailingOptionIds;
  final bool isRented;
  final bool isDoped;
  final bool isChassisRepaired;
  final bool isLockedInShowcase;
  final int daysListed;
  final bool isHeroShowcase;
  final bool isBarnFind;
  final bool isBarnFindRestored;
  final List<String> provenanceLog;
  final bool allowsInstallments;
  final String listingPhotoLocation;
  final int listingPhotoCount;
  final String listingTone;
  final bool hideDamagedPhotos;
  final bool hasNonOriginalParts;
  final String plateNumber;
  final String plateRarity; // 'standard', 'repeated', 'symmetric', 'legendary'
  final String colorRarity; // 'standard', 'rare', 'legendary'
  final String colorDisplayName;
  final int barnFindStage; // 0..5 (5 = completely restored)
  final bool isBarnFindOriginalParts; // All original salvage/OEM parts used
  final bool hasGloveboxSearched;
  final String? gloveboxItem;
  final String carSpirit; // 'normal', 'lucky', 'cursed', 'loyal', 'cranky', 'legendary'
  final bool isConsignment; // Consignment vehicle owned by NPC (§4.6.1)
  final double consignmentCommissionRate; // Gallery cut percentage (e.g. 0.12 = %12)
  final String? consignmentOwnerName;
  final int consignmentDaysRemaining; // Expires in 14 days if not sold
  final bool isBlackMarket; // Sourced from illegal black market
  final String? blackMarketRiskType; // 'change_vin', 'stolen_paperwork', 'smuggled_exotic', 'salvage_hidden', 'mafia_debt'
  final int blackMarketRiskPercent; // 15..50% risk rate
  final String? blackMarketSellerAlias;
  final bool isPeriodicMaintained; // 10.000 KM periodic maintenance performed

  CarModel({
    required this.id,
    required this.brand,
    required String modelName,
    required this.modelYear,
    required this.bodyType,
    required this.colorHex,
    required this.baseMarketValue,
    required this.currentPurchasePrice,
    this.isDetailedCleaned = false,
    this.isWashed = false,
    this.isPolished = false,
    this.isRare = false,
    required this.expertise,
    this.declarationType = ListingDeclarationType.honest,
    this.customListingPrice,
    this.appliedDetailingOptionIds = const [],
    this.isRented = false,
    this.isDoped = false,
    this.isChassisRepaired = false,
    this.isLockedInShowcase = false,
    this.daysListed = 0,
    this.isHeroShowcase = false,
    this.isBarnFind = false,
    this.isBarnFindRestored = false,
    this.provenanceLog = const [],
    this.allowsInstallments = false,
    this.listingPhotoLocation = 'dealership',
    this.listingPhotoCount = 4,
    this.listingTone = 'standard',
    this.hideDamagedPhotos = false,
    this.hasNonOriginalParts = false,
    this.plateNumber = '34 GAL 1923',
    this.plateRarity = 'standard',
    this.colorRarity = 'standard',
    this.colorDisplayName = 'Standart Boya',
    this.barnFindStage = 0,
    this.isBarnFindOriginalParts = false,
    this.hasGloveboxSearched = false,
    this.gloveboxItem,
    this.carSpirit = 'normal',
    this.isConsignment = false,
    this.consignmentCommissionRate = 0.10,
    this.consignmentOwnerName,
    this.consignmentDaysRemaining = 14,
    this.isBlackMarket = false,
    this.blackMarketRiskType,
    this.blackMarketRiskPercent = 20,
    this.blackMarketSellerAlias,
    this.isPeriodicMaintained = false,
  }) : modelName = sanitizeModelName(brand, modelName);

  /// Strips redundant brand name prefixes if present (e.g. 'Merso G-63' with brand 'Merso' -> 'G-63')
  static String sanitizeModelName(String brand, String rawModelName) {
    final trimmedBrand = brand.trim();
    final trimmedModel = rawModelName.trim();
    if (trimmedBrand.isNotEmpty &&
        trimmedModel.toLowerCase().startsWith(trimmedBrand.toLowerCase())) {
      final stripped = trimmedModel.substring(trimmedBrand.length).trim();
      if (stripped.isNotEmpty) {
        return stripped;
      }
    }
    return trimmedModel;
  }

  /// True if car is listed for 10 or more days without selling
  bool get isStaleListing => isListed && daysListed >= 10;

  /// True if vehicle has received interior and upholstery steam detailing
  bool get isInteriorCleaned => appliedDetailingOptionIds.contains('interior_detailing');

  /// True if vehicle has received VIP ceramic coating
  bool get isCeramicCoated => appliedDetailingOptionIds.contains('ceramic_coating');

  /// True if headlights have been restored with chlorovapor and sanding
  bool get hasRestoredHeadlights => appliedDetailingOptionIds.contains('headlight_restoration');

  /// True if wheels have received iron decontaminant cleaning
  bool get hasIronDecon => appliedDetailingOptionIds.contains('iron_decon');

  /// True if vehicle has passed 2-year TÜVTÜRK inspection certification
  bool get hasTuvturkCertified => appliedDetailingOptionIds.contains('tuvturk_certified');

  /// True if bodywork dents were fixed using Paintless Dent Repair (PDR)
  bool get hasPdrRepaired => appliedDetailingOptionIds.contains('pdr_repaired');

  /// Identifier of the active scent hung on the rearview mirror
  String? get appliedScentId {
    final match = appliedDetailingOptionIds.where((id) => id.startsWith('scent_')).toList();
    return match.isNotEmpty ? match.first : null;
  }

  /// True if a scent is hung on the rearview mirror
  bool get hasScent => appliedScentId != null && appliedScentId!.isNotEmpty;

  /// Net estimated profit comparing listing price (or fair value) to purchase price
  double get netEstimatedProfit => listingPrice - currentPurchasePrice;

  /// Net profit margin percentage
  double get profitMarginPercent {
    if (currentPurchasePrice <= 0) return 0.0;
    return ((listingPrice - currentPurchasePrice) / currentPurchasePrice) * 100.0;
  }

  /// Profit heat color indicator status: 'green' (>25%), 'yellow' (10-25%), 'orange' (0-10%), 'red' (loss)
  String get profitHeatStatus {
    final margin = profitMarginPercent;
    if (margin > 25.0) return 'green';
    if (margin >= 10.0) return 'yellow';
    if (margin >= 0.0) return 'orange';
    return 'red';
  }

  /// Plate bonus multiplier
  double get plateValueMultiplier {
    switch (plateRarity) {
      case 'legendary':
        return 1.35; // +35% value
      case 'symmetric':
        return 1.12; // +12% value
      case 'repeated':
        return 1.08; // +8% value
      default:
        return 1.0;
    }
  }

  /// Rare color bonus multiplier
  double get colorValueMultiplier {
    switch (colorRarity) {
      case 'legendary':
        return 1.18; // +18% value
      case 'rare':
        return 1.05; // +5% value
      default:
        return 1.0;
    }
  }

  /// Alias for currentPurchasePrice to prevent runtime NoSuchMethodError
  @pragma('vm:entry-point')
  double get purchasePrice => currentPurchasePrice;

  @pragma('vm:entry-point')
  double get price => currentPurchasePrice;

  @pragma('vm:entry-point')
  double get currentValue => estimatedRealValue;

  @pragma('vm:entry-point')
  String get carTitle => '$brand $modelName';

  @pragma('vm:entry-point')
  String get carModelName => '$brand $modelName';

  /// Check if car is actively listed for sale (strictly false if rented or showcase locked)
  bool get isListed => !isRented && !isLockedInShowcase && customListingPrice != null && customListingPrice! > 0;

  /// Effective listing price (custom if set by player, otherwise estimated real value)
  double get listingPrice => customListingPrice ?? estimatedRealValue;

  /// Authentic factory horsepower from automotive specifications database
  int get factoryHorsepower => CarSpecifications.getFactoryHorsepower(brand, modelName, bodyType: bodyType);

  /// Authentic factory torque (Nm)
  int get factoryTorque => CarSpecifications.getFactoryTorque(brand, modelName, bodyType: bodyType);

  /// Authentic factory 0-100 km/h acceleration (seconds)
  double get factoryZeroToHundred => CarSpecifications.getFactoryZeroToHundred(brand, modelName, bodyType: bodyType);

  /// Dynamic effective horsepower taking engine health and tuning modifications into account
  int get effectiveHorsepower {
    final healthFactor = (expertise.engineCondition / 100.0).clamp(0.40, 1.0);
    int tuningHp = 0;
    if (appliedDetailingOptionIds.contains('tune_ecu_stg3_plus')) tuningHp += 165;
    if (appliedDetailingOptionIds.contains('tune_meth_injection')) tuningHp += 45;
    if (appliedDetailingOptionIds.contains('tune_titanium_intake')) tuningHp += 22;
    if (appliedDetailingOptionIds.contains('tune_turbo_stg3')) tuningHp += 120;
    if (appliedDetailingOptionIds.contains('tune_ecu_stg2')) tuningHp += 75;
    if (appliedDetailingOptionIds.contains('tune_ecu_stg1')) tuningHp += 35;
    if (appliedDetailingOptionIds.contains('tune_exhaust')) tuningHp += 15;
    if (appliedDetailingOptionIds.contains('tune_straight_pipe_flame')) tuningHp += 28;
    if (isDoped) tuningHp += 25;

    final calculated = (factoryHorsepower * (0.70 + 0.30 * healthFactor)).round() + tuningHp;
    return calculated < 40 ? 40 : calculated;
  }

  /// True if vehicle has 0 tramer, all 12 body panels original, mileage not tampered, and good mechanical health
  bool get isPristineOriginal {
    if (expertise.tramerAmount > 0 || expertise.isMileageTampered) return false;
    if (expertise.engineCondition < 80.0 || expertise.transmissionCondition < 80.0) return false;
    for (final status in expertise.bodyParts.values) {
      if (status != PartStatus.original) return false;
    }
    return true;
  }

  /// Returns true if car has 3+ aggressive/loud tuning mods or 5+ total performance mods
  bool get isOverTuned {
    const aggressiveIds = [
      'tune_turbo_stg3',
      'tune_ecu_stg3_plus',
      'tune_straight_pipe_flame',
      'tune_popcorn_map',
      'tune_widebody',
      'tune_air_suspension',
      'tune_custom_forged_slick',
      'tune_meth_injection',
    ];
    int aggressiveCount = 0;
    for (final id in appliedDetailingOptionIds) {
      if (aggressiveIds.contains(id)) aggressiveCount++;
    }
    return aggressiveCount >= 3 || appliedDetailingOptionIds.where((id) => id.startsWith('tune_')).length >= 5;
  }

  /// Calculates estimated overall value after repair & cleaning & rarity & detailing
  double get estimatedRealValue {
    double factor = (expertise.engineCondition / 100.0) * 0.4 +
        (expertise.transmissionCondition / 100.0) * 0.3;

    final totalParts = expertise.bodyParts.length;
    final damageRatio = totalParts == 0
        ? 0.0
        : expertise.bodyParts.values
                .where((s) => s == PartStatus.changed || s == PartStatus.damaged)
                .length /
            totalParts;
    final paintedRatio = totalParts == 0
        ? 0.0
        : expertise.bodyParts.values
                .where((s) => s == PartStatus.painted)
                .length /
            totalParts;

    double structuralPenalty = 0.0;
    for (final key in const ['Tavan', 'Şasi/Podye', 'Podye']) {
      final st = expertise.bodyParts[key];
      if (st == PartStatus.changed || st == PartStatus.damaged) {
        structuralPenalty += 0.06;
      } else if (st == PartStatus.painted) {
        structuralPenalty += 0.03;
      }
    }

    factor += (0.30 - damageRatio * 0.25 - paintedRatio * 0.10 - structuralPenalty)
        .clamp(0.05, 0.30);

    // 1. Cleaning & Washing Bonus (Capped at +8%)
    if (isDetailedCleaned || (isWashed && isPolished)) {
      factor += 0.08;
    } else if (isWashed || isPolished) {
      factor += 0.04;
    }

    // 2. Cosmetic & Certification Detailing Bonus (Far, Demir tozu, PDR, Dyno, Ozon, TÜVTÜRK - +2.5% each, Capped at +10%)
    final detailingCount = appliedDetailingOptionIds
        .where((id) => !id.startsWith('tune_') && !id.startsWith('stage_'))
        .length;
    factor += (detailingCount * 0.025).clamp(0.0, 0.10);

    // 3. Performance & Stance Tuning Bonus (Stage 1/2/3, Turbo, Bodykit, Coilover, Exhaust - +4% each, Capped at +25%)
    double rawTuningBoost = 0.0;
    for (final id in appliedDetailingOptionIds) {
      if (id.startsWith('tune_') || id.startsWith('stage_')) {
        rawTuningBoost += 0.04;
      }
    }
    factor += rawTuningBoost.clamp(0.0, 0.25);

    if (isRare) {
      factor += 0.15;
    }

    if (hasNonOriginalParts) {
      factor -= 0.05;
    }

    // Plate & Color value multipliers
    factor *= plateValueMultiplier;
    factor *= colorValueMultiplier;

    if (isBarnFind && !isBarnFindRestored) {
      // Partially restored bonus per stage
      final stageFactor = 0.20 + (barnFindStage * 0.05); // 0.20 up to 0.45
      factor = factor.clamp(0.20, stageFactor);
    } else if (isBarnFind && isBarnFindRestored) {
      factor += 0.40; // Restored classic gem
      if (isBarnFindOriginalParts) {
        factor += 0.25; // Numaratör Orijinal bonus (§4.3)
      }
    }

    return (baseMarketValue * factor).clamp(baseMarketValue * 0.2, baseMarketValue * 2.5);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'modelName': modelName,
      'modelYear': modelYear,
      'bodyType': bodyType,
      'colorHex': colorHex,
      'baseMarketValue': baseMarketValue,
      'currentPurchasePrice': currentPurchasePrice,
      'isDetailedCleaned': isDetailedCleaned,
      'isWashed': isWashed,
      'isPolished': isPolished,
      'isRare': isRare,
      'expertise': expertise.toJson(),
      'declarationType': declarationType.name,
      'customListingPrice': customListingPrice,
      'appliedDetailingOptionIds': appliedDetailingOptionIds,
      'isRented': isRented,
      'isDoped': isDoped,
      'isChassisRepaired': isChassisRepaired,
      'isLockedInShowcase': isLockedInShowcase,
      'daysListed': daysListed,
      'isHeroShowcase': isHeroShowcase,
      'isBarnFind': isBarnFind,
      'isBarnFindRestored': isBarnFindRestored,
      'provenanceLog': provenanceLog,
      'allowsInstallments': allowsInstallments,
      'listingPhotoLocation': listingPhotoLocation,
      'listingPhotoCount': listingPhotoCount,
      'listingTone': listingTone,
      'hideDamagedPhotos': hideDamagedPhotos,
      'hasNonOriginalParts': hasNonOriginalParts,
      'plateNumber': plateNumber,
      'plateRarity': plateRarity,
      'colorRarity': colorRarity,
      'colorDisplayName': colorDisplayName,
      'barnFindStage': barnFindStage,
      'isBarnFindOriginalParts': isBarnFindOriginalParts,
      'hasGloveboxSearched': hasGloveboxSearched,
      'gloveboxItem': gloveboxItem,
      'carSpirit': carSpirit,
      'isConsignment': isConsignment,
      'consignmentCommissionRate': consignmentCommissionRate,
      'consignmentOwnerName': consignmentOwnerName,
      'consignmentDaysRemaining': consignmentDaysRemaining,
      'isBlackMarket': isBlackMarket,
      'blackMarketRiskType': blackMarketRiskType,
      'blackMarketRiskPercent': blackMarketRiskPercent,
      'blackMarketSellerAlias': blackMarketSellerAlias,
      'isPeriodicMaintained': isPeriodicMaintained,
    };
  }

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['id'] as String? ?? 'car_${DateTime.now().millisecondsSinceEpoch}',
      brand: json['brand'] as String? ?? 'Bilinmeyen',
      modelName: json['modelName'] as String? ?? 'Model',
      modelYear: json['modelYear'] as int? ?? 2020,
      bodyType: json['bodyType'] as String? ?? 'Sedan',
      colorHex: json['colorHex'] as String? ?? '0xFFCCCCCC',
      baseMarketValue: (json['baseMarketValue'] as num?)?.toDouble() ?? 500000.0,
      currentPurchasePrice: (json['currentPurchasePrice'] as num?)?.toDouble() ?? (json['purchasePrice'] as num?)?.toDouble() ?? 450000.0,
      isDetailedCleaned: json['isDetailedCleaned'] as bool? ?? false,
      isWashed: json['isWashed'] as bool? ?? false,
      isPolished: json['isPolished'] as bool? ?? false,
      isRare: json['isRare'] as bool? ?? false,
      expertise: json['expertise'] != null
          ? ExpertiseReport.fromJson(json['expertise'] as Map<String, dynamic>)
          : ExpertiseReport.fromJson(const {}),
      declarationType: json['declarationType'] != null
          ? ListingDeclarationType.values.firstWhere(
              (e) => e.name == json['declarationType'],
              orElse: () => ListingDeclarationType.honest,
            )
          : ListingDeclarationType.honest,
      customListingPrice: json['customListingPrice'] != null ? (json['customListingPrice'] as num?)?.toDouble() : null,
      appliedDetailingOptionIds: (json['appliedDetailingOptionIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      isRented: json['isRented'] as bool? ?? false,
      isDoped: json['isDoped'] as bool? ?? false,
      isChassisRepaired: json['isChassisRepaired'] as bool? ?? false,
      isLockedInShowcase: json['isLockedInShowcase'] as bool? ?? false,
      daysListed: json['daysListed'] as int? ?? 0,
      isHeroShowcase: json['isHeroShowcase'] as bool? ?? false,
      isBarnFind: json['isBarnFind'] as bool? ?? false,
      isBarnFindRestored: json['isBarnFindRestored'] as bool? ?? false,
      provenanceLog: (json['provenanceLog'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      allowsInstallments: json['allowsInstallments'] as bool? ?? false,
      listingPhotoLocation: json['listingPhotoLocation'] as String? ?? 'dealership',
      listingPhotoCount: json['listingPhotoCount'] as int? ?? 4,
      listingTone: json['listingTone'] as String? ?? 'standard',
      hideDamagedPhotos: json['hideDamagedPhotos'] as bool? ?? false,
      hasNonOriginalParts: json['hasNonOriginalParts'] as bool? ?? false,
      plateNumber: json['plateNumber'] as String? ?? '34 GAL 1923',
      plateRarity: json['plateRarity'] as String? ?? 'standard',
      colorRarity: json['colorRarity'] as String? ?? 'standard',
      colorDisplayName: json['colorDisplayName'] as String? ?? 'Standart Boya',
      barnFindStage: json['barnFindStage'] as int? ?? 0,
      isBarnFindOriginalParts: json['isBarnFindOriginalParts'] as bool? ?? false,
      hasGloveboxSearched: json['hasGloveboxSearched'] as bool? ?? false,
      gloveboxItem: json['gloveboxItem'] as String?,
      carSpirit: json['carSpirit'] as String? ?? 'normal',
      isConsignment: json['isConsignment'] as bool? ?? false,
      consignmentCommissionRate: (json['consignmentCommissionRate'] as num?)?.toDouble() ?? 0.10,
      consignmentOwnerName: json['consignmentOwnerName'] as String?,
      consignmentDaysRemaining: json['consignmentDaysRemaining'] as int? ?? 14,
      isBlackMarket: json['isBlackMarket'] as bool? ?? false,
      blackMarketRiskType: json['blackMarketRiskType'] as String?,
      blackMarketRiskPercent: json['blackMarketRiskPercent'] as int? ?? 20,
      blackMarketSellerAlias: json['blackMarketSellerAlias'] as String?,
      isPeriodicMaintained: json['isPeriodicMaintained'] as bool? ?? false,
    );
  }

  CarModel copyWith({
    String? id,
    String? brand,
    String? modelName,
    int? modelYear,
    String? bodyType,
    String? colorHex,
    double? baseMarketValue,
    double? currentPurchasePrice,
    bool? isDetailedCleaned,
    bool? isWashed,
    bool? isPolished,
    bool? isRare,
    ExpertiseReport? expertise,
    ListingDeclarationType? declarationType,
    double? customListingPrice,
    bool clearListingPrice = false,
    List<String>? appliedDetailingOptionIds,
    bool? isRented,
    bool? isDoped,
    bool? isChassisRepaired,
    bool? isLockedInShowcase,
    int? daysListed,
    bool? isHeroShowcase,
    bool? isBarnFind,
    bool? isBarnFindRestored,
    List<String>? provenanceLog,
    bool? allowsInstallments,
    String? listingPhotoLocation,
    int? listingPhotoCount,
    String? listingTone,
    bool? hideDamagedPhotos,
    bool? hasNonOriginalParts,
    String? plateNumber,
    String? plateRarity,
    String? colorRarity,
    String? colorDisplayName,
    int? barnFindStage,
    bool? isBarnFindOriginalParts,
    bool? hasGloveboxSearched,
    String? gloveboxItem,
    String? carSpirit,
    bool? isConsignment,
    double? consignmentCommissionRate,
    String? consignmentOwnerName,
    int? consignmentDaysRemaining,
    bool? isBlackMarket,
    String? blackMarketRiskType,
    int? blackMarketRiskPercent,
    String? blackMarketSellerAlias,
    bool? isPeriodicMaintained,
  }) {
    return CarModel(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      modelName: modelName ?? this.modelName,
      modelYear: modelYear ?? this.modelYear,
      bodyType: bodyType ?? this.bodyType,
      colorHex: colorHex ?? this.colorHex,
      baseMarketValue: baseMarketValue ?? this.baseMarketValue,
      currentPurchasePrice: currentPurchasePrice ?? this.currentPurchasePrice,
      isDetailedCleaned: isDetailedCleaned ?? this.isDetailedCleaned,
      isWashed: isWashed ?? this.isWashed,
      isPolished: isPolished ?? this.isPolished,
      isRare: isRare ?? this.isRare,
      expertise: expertise ?? this.expertise,
      declarationType: declarationType ?? this.declarationType,
      customListingPrice: clearListingPrice ? null : (customListingPrice ?? this.customListingPrice),
      appliedDetailingOptionIds: appliedDetailingOptionIds ?? this.appliedDetailingOptionIds,
      isRented: isRented ?? this.isRented,
      isDoped: isDoped ?? this.isDoped,
      isChassisRepaired: isChassisRepaired ?? this.isChassisRepaired,
      isLockedInShowcase: isLockedInShowcase ?? this.isLockedInShowcase,
      daysListed: daysListed ?? this.daysListed,
      isHeroShowcase: isHeroShowcase ?? this.isHeroShowcase,
      isBarnFind: isBarnFind ?? this.isBarnFind,
      isBarnFindRestored: isBarnFindRestored ?? this.isBarnFindRestored,
      provenanceLog: provenanceLog ?? this.provenanceLog,
      allowsInstallments: allowsInstallments ?? this.allowsInstallments,
      listingPhotoLocation: listingPhotoLocation ?? this.listingPhotoLocation,
      listingPhotoCount: listingPhotoCount ?? this.listingPhotoCount,
      listingTone: listingTone ?? this.listingTone,
      hideDamagedPhotos: hideDamagedPhotos ?? this.hideDamagedPhotos,
      hasNonOriginalParts: hasNonOriginalParts ?? this.hasNonOriginalParts,
      plateNumber: plateNumber ?? this.plateNumber,
      plateRarity: plateRarity ?? this.plateRarity,
      colorRarity: colorRarity ?? this.colorRarity,
      colorDisplayName: colorDisplayName ?? this.colorDisplayName,
      barnFindStage: barnFindStage ?? this.barnFindStage,
      isBarnFindOriginalParts: isBarnFindOriginalParts ?? this.isBarnFindOriginalParts,
      hasGloveboxSearched: hasGloveboxSearched ?? this.hasGloveboxSearched,
      gloveboxItem: gloveboxItem ?? this.gloveboxItem,
      carSpirit: carSpirit ?? this.carSpirit,
      isConsignment: isConsignment ?? this.isConsignment,
      consignmentCommissionRate: consignmentCommissionRate ?? this.consignmentCommissionRate,
      consignmentOwnerName: consignmentOwnerName ?? this.consignmentOwnerName,
      consignmentDaysRemaining: consignmentDaysRemaining ?? this.consignmentDaysRemaining,
      isBlackMarket: isBlackMarket ?? this.isBlackMarket,
      blackMarketRiskType: blackMarketRiskType ?? this.blackMarketRiskType,
      blackMarketRiskPercent: blackMarketRiskPercent ?? this.blackMarketRiskPercent,
      blackMarketSellerAlias: blackMarketSellerAlias ?? this.blackMarketSellerAlias,
      isPeriodicMaintained: isPeriodicMaintained ?? this.isPeriodicMaintained,
    );
  }
}
