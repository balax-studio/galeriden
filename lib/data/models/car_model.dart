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
  });

  /// Effective listing price (custom if set by player, otherwise estimated real value)
  double get listingPrice => customListingPrice ?? estimatedRealValue;

  /// Calculates estimated overall value after repair & cleaning & rarity & detailing
  double get estimatedRealValue {
    double factor = (expertise.engineCondition / 100.0) * 0.4 +
        (expertise.transmissionCondition / 100.0) * 0.3;

    int changedOrDamagedCount = expertise.bodyParts.values
        .where((s) => s == PartStatus.changed || s == PartStatus.damaged)
        .length;

    factor += (1.0 - (changedOrDamagedCount * 0.08)).clamp(0.1, 0.3);

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
    };
  }

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['id'] as String,
      brand: json['brand'] as String,
      modelName: json['modelName'] as String,
      modelYear: json['modelYear'] as int,
      bodyType: json['bodyType'] as String,
      colorHex: json['colorHex'] as String,
      baseMarketValue: (json['baseMarketValue'] as num).toDouble(),
      currentPurchasePrice: (json['currentPurchasePrice'] as num).toDouble(),
      isDetailedCleaned: json['isDetailedCleaned'] as bool? ?? false,
      isWashed: json['isWashed'] as bool? ?? false,
      isPolished: json['isPolished'] as bool? ?? false,
      isRare: json['isRare'] as bool? ?? false,
      expertise: ExpertiseReport.fromJson(json['expertise'] as Map<String, dynamic>),
      declarationType: json['declarationType'] != null
          ? ListingDeclarationType.values.firstWhere(
              (e) => e.name == json['declarationType'],
              orElse: () => ListingDeclarationType.honest,
            )
          : ListingDeclarationType.honest,
      customListingPrice: json['customListingPrice'] != null ? (json['customListingPrice'] as num).toDouble() : null,
      appliedDetailingOptionIds: (json['appliedDetailingOptionIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      isRented: json['isRented'] as bool? ?? false,
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
    List<String>? appliedDetailingOptionIds,
    bool? isRented,
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
      customListingPrice: customListingPrice ?? this.customListingPrice,
      appliedDetailingOptionIds: appliedDetailingOptionIds ?? this.appliedDetailingOptionIds,
      isRented: isRented ?? this.isRented,
    );
  }
}
