class SalvagedPart {
  final String id;
  final String name;
  final String carModelName;
  final String category; // 'engine', 'transmission', 'turbo', 'wheels', 'bodywork', 'audio'
  final int conditionPercent; // 50 to 98
  final double estimatedValue;
  final bool isSold;

  const SalvagedPart({
    required this.id,
    required this.name,
    required this.carModelName,
    required this.category,
    required this.conditionPercent,
    required this.estimatedValue,
    this.isSold = false,
  });

  SalvagedPart copyWith({
    String? id,
    String? name,
    String? carModelName,
    String? category,
    int? conditionPercent,
    double? estimatedValue,
    bool? isSold,
  }) {
    return SalvagedPart(
      id: id ?? this.id,
      name: name ?? this.name,
      carModelName: carModelName ?? this.carModelName,
      category: category ?? this.category,
      conditionPercent: conditionPercent ?? this.conditionPercent,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      isSold: isSold ?? this.isSold,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'carModelName': carModelName,
      'category': category,
      'conditionPercent': conditionPercent,
      'estimatedValue': estimatedValue,
      'isSold': isSold,
    };
  }

  factory SalvagedPart.fromJson(Map<String, dynamic> json) {
    return SalvagedPart(
      id: json['id'] as String,
      name: json['name'] as String,
      carModelName: json['carModelName'] as String,
      category: json['category'] as String,
      conditionPercent: json['conditionPercent'] as int,
      estimatedValue: (json['estimatedValue'] as num).toDouble(),
      isSold: json['isSold'] as bool? ?? false,
    );
  }
}

class ScrapyardCar {
  final String id;
  final String brand;
  final String modelName;
  final int modelYear;
  final double scrapPrice;
  final double estimatedPartTotalValue;
  final String damageNote;
  final List<SalvagedPart> parts;
  final bool isPurchased;

  const ScrapyardCar({
    required this.id,
    required this.brand,
    required this.modelName,
    required this.modelYear,
    required this.scrapPrice,
    required this.estimatedPartTotalValue,
    required this.damageNote,
    required this.parts,
    this.isPurchased = false,
  });

  ScrapyardCar copyWith({
    String? id,
    String? brand,
    String? modelName,
    int? modelYear,
    double? scrapPrice,
    double? estimatedPartTotalValue,
    String? damageNote,
    List<SalvagedPart>? parts,
    bool? isPurchased,
  }) {
    return ScrapyardCar(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      modelName: modelName ?? this.modelName,
      modelYear: modelYear ?? this.modelYear,
      scrapPrice: scrapPrice ?? this.scrapPrice,
      estimatedPartTotalValue: estimatedPartTotalValue ?? this.estimatedPartTotalValue,
      damageNote: damageNote ?? this.damageNote,
      parts: parts ?? this.parts,
      isPurchased: isPurchased ?? this.isPurchased,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'modelName': modelName,
      'modelYear': modelYear,
      'scrapPrice': scrapPrice,
      'estimatedPartTotalValue': estimatedPartTotalValue,
      'damageNote': damageNote,
      'parts': parts.map((p) => p.toJson()).toList(),
      'isPurchased': isPurchased,
    };
  }

  factory ScrapyardCar.fromJson(Map<String, dynamic> json) {
    return ScrapyardCar(
      id: json['id'] as String,
      brand: json['brand'] as String,
      modelName: json['modelName'] as String,
      modelYear: json['modelYear'] as int,
      scrapPrice: (json['scrapPrice'] as num).toDouble(),
      estimatedPartTotalValue: (json['estimatedPartTotalValue'] as num).toDouble(),
      damageNote: json['damageNote'] as String,
      parts: (json['parts'] as List<dynamic>)
          .map((p) => SalvagedPart.fromJson(p as Map<String, dynamic>))
          .toList(),
      isPurchased: json['isPurchased'] as bool? ?? false,
    );
  }
}
