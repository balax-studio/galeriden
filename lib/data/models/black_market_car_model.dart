class BlackMarketCarModel {
  final String id;
  final String brand;
  final String modelName;
  final int modelYear;
  final double askingPrice; // %50 ucuza kelepir teklif
  final double realMarketValue;
  final String riskType; // 'change_vin', 'stolen_paperwork', 'smuggled_exotic', 'salvage_hidden'
  final int riskLevelPercent; // 15 to 45% police raid risk
  final String sellerAlias;
  final String riskDescription;
  final bool isPurchased;

  const BlackMarketCarModel({
    required this.id,
    required this.brand,
    required this.modelName,
    required this.modelYear,
    required this.askingPrice,
    required this.realMarketValue,
    required this.riskType,
    required this.riskLevelPercent,
    required this.sellerAlias,
    required this.riskDescription,
    this.isPurchased = false,
  });

  BlackMarketCarModel copyWith({
    String? id,
    String? brand,
    String? modelName,
    int? modelYear,
    double? askingPrice,
    double? realMarketValue,
    String? riskType,
    int? riskLevelPercent,
    String? sellerAlias,
    String? riskDescription,
    bool? isPurchased,
  }) {
    return BlackMarketCarModel(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      modelName: modelName ?? this.modelName,
      modelYear: modelYear ?? this.modelYear,
      askingPrice: askingPrice ?? this.askingPrice,
      realMarketValue: realMarketValue ?? this.realMarketValue,
      riskType: riskType ?? this.riskType,
      riskLevelPercent: riskLevelPercent ?? this.riskLevelPercent,
      sellerAlias: sellerAlias ?? this.sellerAlias,
      riskDescription: riskDescription ?? this.riskDescription,
      isPurchased: isPurchased ?? this.isPurchased,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'modelName': modelName,
      'modelYear': modelYear,
      'askingPrice': askingPrice,
      'realMarketValue': realMarketValue,
      'riskType': riskType,
      'riskLevelPercent': riskLevelPercent,
      'sellerAlias': sellerAlias,
      'riskDescription': riskDescription,
      'isPurchased': isPurchased,
    };
  }

  factory BlackMarketCarModel.fromJson(Map<String, dynamic> json) {
    return BlackMarketCarModel(
      id: json['id'] as String,
      brand: json['brand'] as String,
      modelName: json['modelName'] as String,
      modelYear: json['modelYear'] as int,
      askingPrice: (json['askingPrice'] as num).toDouble(),
      realMarketValue: (json['realMarketValue'] as num).toDouble(),
      riskType: json['riskType'] as String,
      riskLevelPercent: json['riskLevelPercent'] as int,
      sellerAlias: json['sellerAlias'] as String,
      riskDescription: json['riskDescription'] as String,
      isPurchased: json['isPurchased'] as bool? ?? false,
    );
  }
}
