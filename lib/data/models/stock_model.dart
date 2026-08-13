class StockModel {
  final String symbol;
  final String name;
  final double currentPrice;
  final double previousPrice;

  StockModel({
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.previousPrice,
  });
  
  double get changePercentage => previousPrice == 0 ? 0 : ((currentPrice - previousPrice) / previousPrice) * 100;

  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'name': name,
    'currentPrice': currentPrice,
    'previousPrice': previousPrice,
  };

  factory StockModel.fromJson(Map<String, dynamic> json) => StockModel(
    symbol: json['symbol'] as String,
    name: json['name'] as String,
    currentPrice: (json['currentPrice'] as num).toDouble(),
    previousPrice: (json['previousPrice'] as num).toDouble(),
  );

  StockModel copyWith({
    String? symbol,
    String? name,
    double? currentPrice,
    double? previousPrice,
  }) {
    return StockModel(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      currentPrice: currentPrice ?? this.currentPrice,
      previousPrice: previousPrice ?? this.previousPrice,
    );
  }
}

class PlayerStockModel {
  final String symbol;
  final int quantity;
  final double averageCost;

  PlayerStockModel({
    required this.symbol,
    required this.quantity,
    required this.averageCost,
  });

  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'quantity': quantity,
    'averageCost': averageCost,
  };

  factory PlayerStockModel.fromJson(Map<String, dynamic> json) => PlayerStockModel(
    symbol: json['symbol'] as String,
    quantity: json['quantity'] as int,
    averageCost: (json['averageCost'] as num).toDouble(),
  );

  PlayerStockModel copyWith({
    String? symbol,
    int? quantity,
    double? averageCost,
  }) {
    return PlayerStockModel(
      symbol: symbol ?? this.symbol,
      quantity: quantity ?? this.quantity,
      averageCost: averageCost ?? this.averageCost,
    );
  }
}
