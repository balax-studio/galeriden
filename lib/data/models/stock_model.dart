class StockModel {
  final String symbol;
  final String name;
  final double currentPrice;
  final double previousPrice;
  final List<double> priceHistory;

  StockModel({
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.previousPrice,
    List<double>? priceHistory,
  }) : priceHistory = priceHistory ?? [previousPrice, currentPrice];

  double get changePercentage =>
      previousPrice == 0 ? 0 : ((currentPrice - previousPrice) / previousPrice) * 100;

  bool get isUp => currentPrice >= previousPrice;

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'name': name,
        'currentPrice': currentPrice,
        'previousPrice': previousPrice,
        'priceHistory': priceHistory,
      };

  factory StockModel.fromJson(Map<String, dynamic> json) => StockModel(
        symbol: json['symbol'] as String? ?? 'TOF',
        name: json['name'] as String? ?? 'Hisse',
        currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 10.0,
        previousPrice: (json['previousPrice'] as num?)?.toDouble() ?? 10.0,
        priceHistory: (json['priceHistory'] as List<dynamic>?)
                ?.map((e) => (e as num).toDouble())
                .toList() ??
            [(json['previousPrice'] as num?)?.toDouble() ?? 10.0, (json['currentPrice'] as num?)?.toDouble() ?? 10.0],
      );

  StockModel copyWith({
    String? symbol,
    String? name,
    double? currentPrice,
    double? previousPrice,
    List<double>? priceHistory,
  }) {
    return StockModel(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      currentPrice: currentPrice ?? this.currentPrice,
      previousPrice: previousPrice ?? this.previousPrice,
      priceHistory: priceHistory ?? this.priceHistory,
    );
  }

  /// Default 12 Turkish Automotive & Industrial Stocks
  static List<StockModel> get defaultStocks => [
        StockModel(symbol: 'TOFK', name: 'Tofaşk Sanayi & Otomotiv Holding', currentPrice: 285.50, previousPrice: 280.0, priceHistory: [260, 268, 272, 275, 280, 285.5]),
        StockModel(symbol: 'OTOP', name: 'Oto Yedek Parça Sanayi A.Ş.', currentPrice: 64.20, previousPrice: 65.0, priceHistory: [55, 58, 62, 60, 65, 64.2]),
        StockModel(symbol: 'GART', name: 'Garaj Teknoloji & Yazılım', currentPrice: 142.80, previousPrice: 138.0, priceHistory: [110, 120, 125, 132, 138, 142.8]),
        StockModel(symbol: 'LAST', name: 'Lastik Dünyası & Kauçuk', currentPrice: 88.40, previousPrice: 89.0, priceHistory: [82, 85, 87, 86, 89, 88.4]),
        StockModel(symbol: 'AKAR', name: 'Akaryakıt & Petrol Dağıtım', currentPrice: 48.60, previousPrice: 47.2, priceHistory: [42, 44, 45, 46, 47.2, 48.6]),
        StockModel(symbol: 'SIGO', name: 'Oto Kasko & Sigorta Plus', currentPrice: 32.10, previousPrice: 31.5, priceHistory: [28, 29, 30, 31, 31.5, 32.1]),
        StockModel(symbol: 'LUXM', name: 'Lüks Motors İthalat & Distribütör', currentPrice: 512.00, previousPrice: 495.0, priceHistory: [440, 460, 475, 485, 495, 512.0]),
        StockModel(symbol: 'SCEL', name: 'Sanayi Çelik & Karoser A.Ş.', currentPrice: 76.50, previousPrice: 78.0, priceHistory: [70, 72, 75, 76, 78, 76.5]),
        StockModel(symbol: 'BATR', name: 'EV Batarya Sistemleri & Şarj', currentPrice: 198.00, previousPrice: 190.0, priceHistory: [150, 165, 175, 182, 190, 198.0]),
        StockModel(symbol: 'OLOG', name: 'Oto Lojistik & Tır Taşımacılığı', currentPrice: 53.40, previousPrice: 54.0, priceHistory: [48, 50, 52, 53, 54, 53.4]),
        StockModel(symbol: 'EKSP', name: 'Kurumsal Ekspertiz Zinciri', currentPrice: 41.80, previousPrice: 40.5, priceHistory: [35, 37, 38, 39, 40.5, 41.8]),
        StockModel(symbol: 'HURD', name: 'Milli Hurdacılar & Geri Dönüşüm', currentPrice: 24.50, previousPrice: 23.8, priceHistory: [20, 21, 22, 23, 23.8, 24.5]),
      ];
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
        symbol: json['symbol'] as String? ?? 'TOF',
        quantity: json['quantity'] as int? ?? 0,
        averageCost: (json['averageCost'] as num?)?.toDouble() ?? 0.0,
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
