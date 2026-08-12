import 'expertise_model.dart';

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
  final ExpertiseReport expertise;

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
    required this.expertise,
  });

  /// Calculates estimated overall value after repair & cleaning
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

    return (baseMarketValue * factor).clamp(baseMarketValue * 0.4, baseMarketValue * 1.5);
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
      'expertise': expertise.toJson(),
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
      expertise: ExpertiseReport.fromJson(json['expertise'] as Map<String, dynamic>),
    );
  }

  CarModel copyWith({
    bool? isDetailedCleaned,
    ExpertiseReport? expertise,
  }) {
    return CarModel(
      id: id,
      brand: brand,
      modelName: modelName,
      modelYear: modelYear,
      bodyType: bodyType,
      colorHex: colorHex,
      baseMarketValue: baseMarketValue,
      currentPurchasePrice: currentPurchasePrice,
      isDetailedCleaned: isDetailedCleaned ?? this.isDetailedCleaned,
      expertise: expertise ?? this.expertise,
    );
  }
}
