import 'expertise_model.dart';

enum ListingDeclarationType {
  honest,
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

  CarModel({
    required this.id,
    required this.brand,
    required this.modelName,
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
  });

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

  /// Check if car is actively listed for sale
  bool get isListed => customListingPrice != null && customListingPrice! > 0;

  /// Effective listing price (custom if set by player, otherwise estimated real value)
  double get listingPrice => customListingPrice ?? estimatedRealValue;

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

    if (isDetailedCleaned || (isWashed && isPolished)) {
      factor += 0.08;
    } else if (isWashed || isPolished) {
      factor += 0.04;
    }

    // Boost factor per applied custom detailing option
    factor += appliedDetailingOptionIds.length * 0.06;

    if (isRare) {
      factor += 0.15;
    }

    return (baseMarketValue * factor).clamp(baseMarketValue * 0.4, baseMarketValue * 2.2);
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
    );
  }

  CarModel copyWith({
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
  }) {
    return CarModel(
      id: id,
      brand: brand,
      modelName: modelName,
      modelYear: modelYear,
      bodyType: bodyType,
      colorHex: colorHex,
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
    );
  }
}
