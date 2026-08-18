import 'dart:math';

class StockModel {
  final String symbol;
  final String name;
  final double currentPrice;
  final double previousPrice;
  final List<double> priceHistory;
  final double dividendYield; // Annual dividend yield, e.g. 0.08 (8%)
  final String sectorCategory; // 'Otomotiv & Üretim', 'Yedek Parça & Sanayi', 'Teknoloji & Yazılım', 'Enerji & Akaryakıt', 'Lojistik & Taşımacılık', 'Finans & Sigorta'

  StockModel({
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.previousPrice,
    List<double>? priceHistory,
    this.dividendYield = 0.08,
    this.sectorCategory = 'Otomotiv & Sanayi',
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
        'dividendYield': dividendYield,
        'sectorCategory': sectorCategory,
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
        dividendYield: (json['dividendYield'] as num?)?.toDouble() ?? 0.08,
        sectorCategory: json['sectorCategory'] as String? ?? 'Otomotiv & Sanayi',
      );

  StockModel copyWith({
    String? symbol,
    String? name,
    double? currentPrice,
    double? previousPrice,
    List<double>? priceHistory,
    double? dividendYield,
    String? sectorCategory,
  }) {
    return StockModel(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      currentPrice: currentPrice ?? this.currentPrice,
      previousPrice: previousPrice ?? this.previousPrice,
      priceHistory: priceHistory ?? this.priceHistory,
      dividendYield: dividendYield ?? this.dividendYield,
      sectorCategory: sectorCategory ?? this.sectorCategory,
    );
  }

  /// Default 12 Turkish Automotive & Industrial Stocks with Sectors and Dividend Yields
  static List<StockModel> get defaultStocks => [
        StockModel(
          symbol: 'TOFK',
          name: 'Tofaşk Sanayi & Otomotiv Holding',
          currentPrice: 285.50,
          previousPrice: 280.0,
          priceHistory: [260, 268, 272, 275, 280, 285.5],
          dividendYield: 0.11, // %11 Temettü
          sectorCategory: 'Otomotiv & Üretim',
        ),
        StockModel(
          symbol: 'OTOP',
          name: 'Oto Yedek Parça Sanayi A.Ş.',
          currentPrice: 64.20,
          previousPrice: 65.0,
          priceHistory: [55, 58, 62, 60, 65, 64.2],
          dividendYield: 0.07,
          sectorCategory: 'Yedek Parça & Sanayi',
        ),
        StockModel(
          symbol: 'GART',
          name: 'Garaj Teknoloji & Yazılım',
          currentPrice: 142.80,
          previousPrice: 138.0,
          priceHistory: [110, 120, 125, 132, 138, 142.8],
          dividendYield: 0.04,
          sectorCategory: 'Teknoloji & Yazılım',
        ),
        StockModel(
          symbol: 'LAST',
          name: 'Lastik Dünyası & Kauçuk',
          currentPrice: 88.40,
          previousPrice: 89.0,
          priceHistory: [82, 85, 87, 86, 89, 88.4],
          dividendYield: 0.09,
          sectorCategory: 'Yedek Parça & Sanayi',
        ),
        StockModel(
          symbol: 'AKAR',
          name: 'Akaryakıt & Petrol Dağıtım',
          currentPrice: 48.60,
          previousPrice: 47.2,
          priceHistory: [42, 44, 45, 46, 47.2, 48.6],
          dividendYield: 0.12, // %12 Temettü
          sectorCategory: 'Enerji & Akaryakıt',
        ),
        StockModel(
          symbol: 'SIGO',
          name: 'Oto Kasko & Sigorta Plus',
          currentPrice: 32.10,
          previousPrice: 31.5,
          priceHistory: [28, 29, 30, 31, 31.5, 32.1],
          dividendYield: 0.08,
          sectorCategory: 'Finans & Sigorta',
        ),
        StockModel(
          symbol: 'LUXM',
          name: 'Lüks Motors İthalat & Distribütör',
          currentPrice: 512.00,
          previousPrice: 495.0,
          priceHistory: [440, 460, 475, 485, 495, 512.0],
          dividendYield: 0.06,
          sectorCategory: 'Otomotiv & Üretim',
        ),
        StockModel(
          symbol: 'SCEL',
          name: 'Sanayi Çelik & Karoser A.Ş.',
          currentPrice: 76.50,
          previousPrice: 78.0,
          priceHistory: [70, 72, 75, 76, 78, 76.5],
          dividendYield: 0.10,
          sectorCategory: 'Yedek Parça & Sanayi',
        ),
        StockModel(
          symbol: 'BATR',
          name: 'EV Batarya Sistemleri & Şarj',
          currentPrice: 198.00,
          previousPrice: 190.0,
          priceHistory: [150, 165, 175, 182, 190, 198.0],
          dividendYield: 0.05,
          sectorCategory: 'Teknoloji & Yazılım',
        ),
        StockModel(
          symbol: 'OLOG',
          name: 'Oto Lojistik & Tır Taşımacılığı',
          currentPrice: 53.40,
          previousPrice: 54.0,
          priceHistory: [48, 50, 52, 53, 54, 53.4],
          dividendYield: 0.08,
          sectorCategory: 'Lojistik & Taşımacılık',
        ),
        StockModel(
          symbol: 'EKSP',
          name: 'Kurumsal Ekspertiz Zinciri',
          currentPrice: 41.80,
          previousPrice: 40.5,
          priceHistory: [35, 37, 38, 39, 40.5, 41.8],
          dividendYield: 0.07,
          sectorCategory: 'Finans & Sigorta',
        ),
        StockModel(
          symbol: 'HURD',
          name: 'Milli Hurdacılar & Geri Dönüşüm',
          currentPrice: 24.50,
          previousPrice: 23.8,
          priceHistory: [20, 21, 22, 23, 23.8, 24.5],
          dividendYield: 0.09,
          sectorCategory: 'Yedek Parça & Sanayi',
        ),
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

/// Macro: BIST Otomotiv Endeksi (XAUTO)
class BistIndexModel {
  final double points;
  final double previousPoints;
  final String trendName;
  final List<double> pointsHistory;

  const BistIndexModel({
    required this.points,
    required this.previousPoints,
    required this.trendName,
    required this.pointsHistory,
  });

  double get changePercentage =>
      previousPoints == 0 ? 0 : ((points - previousPoints) / previousPoints) * 100;

  bool get isUp => points >= previousPoints;

  static BistIndexModel calculateIndex(List<StockModel> stocks) {
    if (stocks.isEmpty) {
      return const BistIndexModel(
        points: 8450.0,
        previousPoints: 8400.0,
        trendName: 'Yatay / Dengeli',
        pointsHistory: [8200, 8300, 8350, 8400, 8450],
      );
    }

    double totalWeighted = 0;
    double prevWeighted = 0;
    for (var s in stocks) {
      totalWeighted += s.currentPrice;
      prevWeighted += s.previousPrice;
    }

    final currentPoints = (totalWeighted * 6.2).roundToDouble();
    final prevPoints = (prevWeighted * 6.2).roundToDouble();
    final diff = currentPoints - prevPoints;

    String trend;
    if (diff > 120) {
      trend = 'Otomotiv Boğa Rallisi';
    } else if (diff > 0) {
      trend = 'İyimser Yükseliş Trendi';
    } else if (diff < -120) {
      trend = 'Ayı Baskısı & Düşüş';
    } else {
      trend = 'Yatay / Konsolidasyon';
    }

    return BistIndexModel(
      points: currentPoints,
      previousPoints: prevPoints,
      trendName: trend,
      pointsHistory: [prevPoints * 0.96, prevPoints * 0.98, prevPoints, currentPoints],
    );
  }
}

/// Macro: Döviz & Altın Modeli
class ForexGoldModel {
  final String symbol; // 'USD', 'EUR', 'GOLD'
  final String name;
  final double buyRate;
  final double sellRate;
  final double previousRate;
  final List<double> rateHistory;

  const ForexGoldModel({
    required this.symbol,
    required this.name,
    required this.buyRate,
    required this.sellRate,
    required this.previousRate,
    required this.rateHistory,
  });

  double get changePercentage =>
      previousRate == 0 ? 0 : ((buyRate - previousRate) / previousRate) * 100;

  bool get isUp => buyRate >= previousRate;

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'name': name,
        'buyRate': buyRate,
        'sellRate': sellRate,
        'previousRate': previousRate,
        'rateHistory': rateHistory,
      };

  factory ForexGoldModel.fromJson(Map<String, dynamic> json) => ForexGoldModel(
        symbol: json['symbol'] as String? ?? 'USD',
        name: json['name'] as String? ?? 'Döviz',
        buyRate: (json['buyRate'] as num?)?.toDouble() ?? 34.50,
        sellRate: (json['sellRate'] as num?)?.toDouble() ?? 34.20,
        previousRate: (json['previousRate'] as num?)?.toDouble() ?? 34.40,
        rateHistory: (json['rateHistory'] as List<dynamic>?)
                ?.map((e) => (e as num).toDouble())
                .toList() ??
            [34.0, 34.2, 34.4, 34.5],
      );

  ForexGoldModel copyWith({
    String? symbol,
    String? name,
    double? buyRate,
    double? sellRate,
    double? previousRate,
    List<double>? rateHistory,
  }) {
    return ForexGoldModel(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      buyRate: buyRate ?? this.buyRate,
      sellRate: sellRate ?? this.sellRate,
      previousRate: previousRate ?? this.previousRate,
      rateHistory: rateHistory ?? this.rateHistory,
    );
  }

  static List<ForexGoldModel> get defaultForex => const [
        ForexGoldModel(
          symbol: 'USD',
          name: 'Amerikan Doları',
          buyRate: 34.50,
          sellRate: 34.20,
          previousRate: 34.35,
          rateHistory: [33.80, 34.00, 34.15, 34.35, 34.50],
        ),
        ForexGoldModel(
          symbol: 'EUR',
          name: 'Euro',
          buyRate: 37.80,
          sellRate: 37.50,
          previousRate: 37.65,
          rateHistory: [37.10, 37.30, 37.45, 37.65, 37.80],
        ),
        ForexGoldModel(
          symbol: 'GOLD',
          name: 'Gram Altın • 24 Ayar',
          buyRate: 2850.0,
          sellRate: 2820.0,
          previousRate: 2835.0,
          rateHistory: [2750.0, 2780.0, 2810.0, 2835.0, 2850.0],
        ),
      ];
}

class PlayerForexModel {
  final String symbol;
  final double amount;
  final double averageRate;

  const PlayerForexModel({
    required this.symbol,
    required this.amount,
    required this.averageRate,
  });

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'amount': amount,
        'averageRate': averageRate,
      };

  factory PlayerForexModel.fromJson(Map<String, dynamic> json) => PlayerForexModel(
        symbol: json['symbol'] as String? ?? 'USD',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        averageRate: (json['averageRate'] as num?)?.toDouble() ?? 0.0,
      );

  PlayerForexModel copyWith({
    String? symbol,
    double? amount,
    double? averageRate,
  }) {
    return PlayerForexModel(
      symbol: symbol ?? this.symbol,
      amount: amount ?? this.amount,
      averageRate: averageRate ?? this.averageRate,
    );
  }
}

/// Macro: Halka Arz (IPO) Modeli
class IpoOfferModel {
  final String id;
  final String companyName;
  final String symbol;
  final double lotPrice;
  final int totalLotsAvailable;
  final int maxLotPerUser;
  final int daysUntilListing;
  final double listingMultiplier; // Expected listing gain e.g. 1.40 (+40%)
  final String description;
  final bool isListed;

  const IpoOfferModel({
    required this.id,
    required this.companyName,
    required this.symbol,
    required this.lotPrice,
    required this.totalLotsAvailable,
    this.maxLotPerUser = 100,
    required this.daysUntilListing,
    this.listingMultiplier = 1.40,
    required this.description,
    this.isListed = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'companyName': companyName,
        'symbol': symbol,
        'lotPrice': lotPrice,
        'totalLotsAvailable': totalLotsAvailable,
        'maxLotPerUser': maxLotPerUser,
        'daysUntilListing': daysUntilListing,
        'listingMultiplier': listingMultiplier,
        'description': description,
        'isListed': isListed,
      };

  factory IpoOfferModel.fromJson(Map<String, dynamic> json) => IpoOfferModel(
        id: json['id'] as String? ?? 'ipo_1',
        companyName: json['companyName'] as String? ?? 'Şirket',
        symbol: json['symbol'] as String? ?? 'IPO',
        lotPrice: (json['lotPrice'] as num?)?.toDouble() ?? 25.0,
        totalLotsAvailable: (json['totalLotsAvailable'] as num?)?.toInt() ?? 100000,
        maxLotPerUser: (json['maxLotPerUser'] as num?)?.toInt() ?? 100,
        daysUntilListing: (json['daysUntilListing'] as num?)?.toInt() ?? 3,
        listingMultiplier: (json['listingMultiplier'] as num?)?.toDouble() ?? 1.40,
        description: json['description'] as String? ?? '',
        isListed: json['isListed'] as bool? ?? false,
      );

  IpoOfferModel copyWith({
    String? id,
    String? companyName,
    String? symbol,
    double? lotPrice,
    int? totalLotsAvailable,
    int? daysUntilListing,
    double? listingMultiplier,
    String? description,
    bool? isListed,
  }) {
    return IpoOfferModel(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      symbol: symbol ?? this.symbol,
      lotPrice: lotPrice ?? this.lotPrice,
      totalLotsAvailable: totalLotsAvailable ?? this.totalLotsAvailable,
      daysUntilListing: daysUntilListing ?? this.daysUntilListing,
      listingMultiplier: listingMultiplier ?? this.listingMultiplier,
      description: description ?? this.description,
      isListed: isListed ?? this.isListed,
    );
  }

  static List<IpoOfferModel> defaultIpos(int day) {
    final allIpos = [
      const IpoOfferModel(
        id: 'ipo_volt_charge',
        companyName: 'VoltŞarj İstasyonları & Enerji A.Ş.',
        symbol: 'VOLT',
        lotPrice: 42.0,
        totalLotsAvailable: 800000,
        daysUntilListing: 2,
        listingMultiplier: 1.50,
        description: 'Türkiye geneli 81 ilde ultra hızlı elektrikli araç şarj ağı genişletme yatırımı.',
      ),
      const IpoOfferModel(
        id: 'ipo_titan_karoser',
        companyName: 'Titan Hafif Alaşım Karoser Sanayi',
        symbol: 'TITN',
        lotPrice: 28.50,
        totalLotsAvailable: 500000,
        daysUntilListing: 4,
        listingMultiplier: 1.35,
        description: 'Almanya ve Avrupa otomotiv devlerine hafif şasi parçası ihracatı.',
      ),
      const IpoOfferModel(
        id: 'ipo_anadolu_batarya',
        companyName: 'Anadolu Lityum Hücre & Batarya A.Ş.',
        symbol: 'ANBT',
        lotPrice: 56.0,
        totalLotsAvailable: 600000,
        daysUntilListing: 3,
        listingMultiplier: 1.65,
        description: 'Yerli elektrikli araçlar için prizmatik batarya hücresi seri üretim tesisi.',
      ),
      const IpoOfferModel(
        id: 'ipo_oto_yazilim',
        companyName: 'OtoYazılım Bulut & Telemetri Teknolojileri',
        symbol: 'OYAZ',
        lotPrice: 34.0,
        totalLotsAvailable: 450000,
        daysUntilListing: 2,
        listingMultiplier: 1.45,
        description: 'Akıllı filo takip ve yapay zekalı araç arıza tespit yazılım altyapısı.',
      ),
      const IpoOfferModel(
        id: 'ipo_ege_jant',
        companyName: 'Ege Dövme Çelik & Alaşım Jant Sanayi',
        symbol: 'EGEJ',
        lotPrice: 22.0,
        totalLotsAvailable: 750000,
        daysUntilListing: 5,
        listingMultiplier: 1.30,
        description: 'Ticari ve binek araçlar için hafif alaşımlı jant ihracat kapasite artışı.',
      ),
      const IpoOfferModel(
        id: 'ipo_marmara_lojistik',
        companyName: 'Marmara Oto Lojistik & Taşıma Filosu',
        symbol: 'MARL',
        lotPrice: 19.50,
        totalLotsAvailable: 900000,
        daysUntilListing: 3,
        listingMultiplier: 1.28,
        description: 'Gümrük ve limanlar arası çok katlı araç taşıma tır filosu modernizasyonu.',
      ),
    ];

    final rand = Random(day * 13 + 7);
    allIpos.shuffle(rand);
    return allIpos.take(3).toList();
  }
}

class PlayerIpoRequestModel {
  final String ipoId;
  final int requestedLots;
  final int allottedLots;
  final double totalSpent;
  final bool isListed;
  final double profitEarned;

  const PlayerIpoRequestModel({
    required this.ipoId,
    required this.requestedLots,
    this.allottedLots = 0,
    required this.totalSpent,
    this.isListed = false,
    this.profitEarned = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'ipoId': ipoId,
        'requestedLots': requestedLots,
        'allottedLots': allottedLots,
        'totalSpent': totalSpent,
        'isListed': isListed,
        'profitEarned': profitEarned,
      };

  factory PlayerIpoRequestModel.fromJson(Map<String, dynamic> json) => PlayerIpoRequestModel(
        ipoId: json['ipoId'] as String? ?? '',
        requestedLots: (json['requestedLots'] as num?)?.toInt() ?? 0,
        allottedLots: (json['allottedLots'] as num?)?.toInt() ?? 0,
        totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
        isListed: json['isListed'] as bool? ?? false,
        profitEarned: (json['profitEarned'] as num?)?.toDouble() ?? 0.0,
      );

  PlayerIpoRequestModel copyWith({
    String? ipoId,
    int? requestedLots,
    int? allottedLots,
    double? totalSpent,
    bool? isListed,
    double? profitEarned,
  }) {
    return PlayerIpoRequestModel(
      ipoId: ipoId ?? this.ipoId,
      requestedLots: requestedLots ?? this.requestedLots,
      allottedLots: allottedLots ?? this.allottedLots,
      totalSpent: totalSpent ?? this.totalSpent,
      isListed: isListed ?? this.isListed,
      profitEarned: profitEarned ?? this.profitEarned,
    );
  }
}
