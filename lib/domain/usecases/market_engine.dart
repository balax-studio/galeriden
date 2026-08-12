import 'dart:math';
import '../../core/constants/game_constants.dart';
import '../../data/models/car_model.dart';
import '../../data/models/expertise_model.dart';
import '../../data/models/listing_model.dart';
import '../../data/models/market_trend_model.dart';

class MarketEngine {
  static final Random _random = Random();

  /// Generate dynamic random market trends
  static MarketTrendModel generateMarketTrend() {
    final trends = [
      {
        'headline': '🔥 Bahar Ayı Yaza Doğru SUV & Spor Araç Fiyatları %15 Yükselişte!',
        'Sedan': 1.0,
        'Hatchback': 0.95,
        'SUV': 1.15,
        'Spor': 1.20,
        'Klasik': 1.05,
      },
      {
        'headline': '⛽ Yakıt Zamları Sonrası Ekonomi & Hatchback Araçlara Talep Patladı!',
        'Sedan': 0.98,
        'Hatchback': 1.18,
        'SUV': 0.88,
        'Spor': 0.85,
        'Klasik': 1.0,
      },
      {
        'headline': '👑 Lüks & Klasik Araç Koleksiyonerleri Piyasayı Hareketlendirdi!',
        'Sedan': 1.05,
        'Hatchback': 1.0,
        'SUV': 1.05,
        'Spor': 1.15,
        'Klasik': 1.30,
      },
      {
        'headline': '📊 İkinci El Piyasasında Durgunluk — Kelepir Araç Fırsatları Artıyor.',
        'Sedan': 0.92,
        'Hatchback': 0.90,
        'SUV': 0.93,
        'Spor': 0.90,
        'Klasik': 0.95,
      },
    ];

    final chosen = trends[_random.nextInt(trends.length)];
    final headline = chosen['headline'] as String;
    final multipliers = <String, double>{
      'Sedan': chosen['Sedan'] as double,
      'Hatchback': chosen['Hatchback'] as double,
      'SUV': chosen['SUV'] as double,
      'Spor': chosen['Spor'] as double,
      'Klasik': chosen['Klasik'] as double,
    };

    return MarketTrendModel(
      headline: headline,
      bodyTypeMultipliers: multipliers,
      generatedAt: DateTime.now(),
    );
  }

  static List<ListingModel> generateRandomListings({
    int count = 7,
    int playerLevel = 1,
    MarketTrendModel? trend,
  }) {
    final activeTrend = trend ?? generateMarketTrend();
    List<ListingModel> listings = [];
    for (int i = 0; i < count; i++) {
      listings.add(_generateSingleListing(playerLevel, activeTrend));
    }
    return listings;
  }

  static ListingModel _generateSingleListing(int playerLevel, MarketTrendModel trend) {
    final brandData = _selectWeightedBrand();
    final modelName = brandData.models[_random.nextInt(brandData.models.length)];
    final bodyType = GameConstants.bodyTypes[_random.nextInt(GameConstants.bodyTypes.length)];
    final year = 2007 + _random.nextInt(17); // 2007 - 2023
    final id = 'car_${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(999)}';

    // 5% chance of Rare vehicle drop!
    final isRare = _random.nextDouble() < 0.05;

    // Mileage & Tramer
    final mileage = isRare ? (15000 + _random.nextInt(45000)) : (25000 + _random.nextInt(260000));
    final hasTramer = isRare ? false : (_random.nextDouble() > 0.4);
    final tramerAmount = hasTramer ? (3500 + _random.nextInt(85000)) : 0;
    final isTampered = isRare ? false : (_random.nextDouble() < 0.15);

    final bodyParts = <String, PartStatus>{
      'Kaput': isRare ? PartStatus.original : _getRandomPartStatus(),
      'Tavan': isRare ? PartStatus.original : _getRandomPartStatus(tavanMultiplier: true),
      'Sol Ön Çamurluk': _getRandomPartStatus(),
      'Sağ Ön Çamurluk': _getRandomPartStatus(),
      'Sol Arka Çamurluk': _getRandomPartStatus(),
      'Sağ Arka Çamurluk': _getRandomPartStatus(),
      'Sol Ön Kapı': _getRandomPartStatus(),
      'Sağ Ön Kapı': _getRandomPartStatus(),
      'Sol Arka Kapı': _getRandomPartStatus(),
      'Sağ Arka Kapı': _getRandomPartStatus(),
      'Bagaj': _getRandomPartStatus(),
      'Şasi/Podye': isRare ? PartStatus.original : _getRandomPartStatus(shasiMultiplier: true),
    };

    final engineCondition = isRare ? (85.0 + _random.nextInt(15)) : (60.0 + _random.nextInt(38)).clamp(40.0, 100.0);
    final transCondition = isRare ? (88.0 + _random.nextInt(12)) : (65.0 + _random.nextInt(33)).clamp(50.0, 100.0);

    final expertise = ExpertiseReport(
      engineCondition: engineCondition.toDouble(),
      transmissionCondition: transCondition.toDouble(),
      tramerAmount: tramerAmount,
      mileage: mileage,
      isMileageTampered: isTampered,
      bodyParts: bodyParts,
    );

    // Realistic Turkish Market Base Value Calculation
    double baseValue = 380000.0 + (year - 2007) * 45000.0 + (playerLevel - 1) * 60000.0;
    if (brandData.name == 'Avdi' || brandData.name == 'BWM' || brandData.name == 'Mersedes') {
      baseValue *= 1.45;
    }
    if (bodyType == 'Spor') baseValue *= 1.35;
    if (bodyType == 'SUV') baseValue *= 1.25;

    // Apply market trend multiplier!
    final trendMult = trend.bodyTypeMultipliers[bodyType] ?? 1.0;
    baseValue *= trendMult;

    // Rare bonus
    if (isRare) {
      baseValue *= 1.25;
    }

    // Seller traits
    final sellerProfile = GameConstants.sellerProfiles[_random.nextInt(GameConstants.sellerProfiles.length)];
    double discount = _random.nextDouble() * 0.12;
    if (sellerProfile['urgency'] == 'high') discount += 0.08;

    final isFlashDeal = _random.nextDouble() < 0.10;
    if (isFlashDeal) {
      discount += 0.20;
    }

    double askingPrice = (baseValue * (1.0 - discount)).roundToDouble();

    final car = CarModel(
      id: id,
      brand: brandData.name,
      modelName: modelName,
      modelYear: year,
      bodyType: bodyType,
      colorHex: _getRandomColorHex(),
      baseMarketValue: baseValue,
      currentPurchasePrice: askingPrice,
      isRare: isRare,
      expertise: expertise,
    );

    final cities = ['İstanbul', 'Ankara', 'İzmir', 'Bursa', 'Antalya', 'Adana'];
    final sellerCity = cities[_random.nextInt(cities.length)];

    String title = '$year ${brandData.name} $modelName';
    if (isRare) title = '💎 [NADİR KOLEKSİYON] $title';

    String description = isFlashDeal
        ? '⚡ ACİL NAKİT İHTİYACINDAN KELEPİR FİYAT! İlk gelen alır.'
        : (isRare
            ? '💎 Garaj arabası, düşük km, hatasız boyasız koleksiyonluk fırsat!'
            : 'Temiz kullanılmıştır, bakımları zamanında yapılmıştır. Nakit satılık.');

    return ListingModel(
      id: 'listing_$id',
      car: car,
      sellerName: '${sellerProfile['name']} (${_getRandomSellerName()})',
      sellerTrait: isRare ? '💎 Koleksiyonluk Nadir Araç' : (isFlashDeal ? '⚡ Fırsat İlanı! Çok Acele' : sellerProfile['trait']!),
      sellerCity: sellerCity,
      title: title,
      description: description,
      askingPrice: askingPrice,
      isExpertiseCompleted: false,
      createdAt: DateTime.now(),
    );
  }

  static CarBrandData _selectWeightedBrand() {
    int totalWeight = GameConstants.carBrands.fold(0, (sum, item) => sum + item.popularityWeight);
    int roll = _random.nextInt(totalWeight);
    int currentSum = 0;

    for (var brand in GameConstants.carBrands) {
      currentSum += brand.popularityWeight;
      if (roll < currentSum) return brand;
    }
    return GameConstants.carBrands.first;
  }

  static PartStatus _getRandomPartStatus({bool tavanMultiplier = false, bool shasiMultiplier = false}) {
    double roll = _random.nextDouble();
    if (shasiMultiplier) {
      if (roll < 0.85) return PartStatus.original;
      if (roll < 0.95) return PartStatus.painted;
      return PartStatus.damaged;
    }
    if (tavanMultiplier) {
      if (roll < 0.80) return PartStatus.original;
      if (roll < 0.93) return PartStatus.painted;
      return PartStatus.changed;
    }
    if (roll < 0.50) return PartStatus.original;
    if (roll < 0.75) return PartStatus.painted;
    if (roll < 0.90) return PartStatus.changed;
    return PartStatus.damaged;
  }

  static String _getRandomColorHex() {
    final colors = ['#0D0D0F', '#FFFFFF', '#C4484A', '#2C3E50', '#7F8C8D', '#D4AC0D'];
    return colors[_random.nextInt(colors.length)];
  }

  static String _getRandomSellerName() {
    final names = ['Ahmet Y.', 'Mehmet K.', 'Caner S.', 'Mustafa B.', 'Emre T.', 'Burak M.'];
    return names[_random.nextInt(names.length)];
  }
}
