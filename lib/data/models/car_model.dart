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
  final bool isRare;
  final ExpertiseReport expertise;
  final ListingDeclarationType declarationType;
  final double? customListingPrice;

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
    this.isRare = false,
    required this.expertise,
    this.declarationType = ListingDeclarationType.honest,
    this.customListingPrice,
  });

  /// Effective listing price (custom if set by player, otherwise estimated real value)
  double get listingPrice => customListingPrice ?? estimatedRealValue;

  /// Calculates estimated overall value after repair & cleaning & rarity
  double get estimatedRealValue {
    double factor = (expertise.engineCondition / 100.0) * 0.4 +
        (expertise.transmissionCondition / 100.0) * 0.3;

    int changedOrDamagedCount = expertise.bodyParts.values
        .where((s) => s == PartStatus.changed || s == PartStatus.damaged)
        .length;

    factor += (1.0 - (changedOrDamagedCount * 0.08)).clamp(0.1, 0.3);

    if (isDetailedCleaned) {
      factor += 0.08;
    }

    if (isRare) {
      factor += 0.15;
    }

    return (baseMarketValue * factor).clamp(baseMarketValue * 0.4, baseMarketValue * 1.8);
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
      'isRare': isRare,
      'expertise': expertise.toJson(),
      'declarationType': declarationType.name,
      'customListingPrice': customListingPrice,
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
      isRare: json['isRare'] as bool? ?? false,
      expertise: ExpertiseReport.fromJson(json['expertise'] as Map<String, dynamic>),
      declarationType: json['declarationType'] != null
          ? ListingDeclarationType.values.firstWhere(
              (e) => e.name == json['declarationType'],
              orElse: () => ListingDeclarationType.honest,
            )
          : ListingDeclarationType.honest,
      customListingPrice: json['customListingPrice'] != null ? (json['customListingPrice'] as num).toDouble() : null,
    );
  }

  CarModel copyWith({
    double? baseMarketValue,
    double? currentPurchasePrice,
    bool? isDetailedCleaned,
    bool? isRare,
    ExpertiseReport? expertise,
    ListingDeclarationType? declarationType,
    double? customListingPrice,
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
      isRare: isRare ?? this.isRare,
      expertise: expertise ?? this.expertise,
      declarationType: declarationType ?? this.declarationType,
      customListingPrice: customListingPrice ?? this.customListingPrice,
    );
  }
}
