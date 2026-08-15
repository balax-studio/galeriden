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
        'headline': 'Bahar Ayı Yaza Doğru SUV & Spor Araç Fiyatları %15 Yükselişte!',
        'Sedan': 1.0,
        'Hatchback': 0.95,
        'SUV': 1.15,
        'Spor': 1.20,
        'Klasik': 1.05,
      },
      {
        'headline': 'Yakıt Zamları Sonrası Ekonomi & Hatchback Araçlara Talep Patladı!',
        'Sedan': 0.98,
        'Hatchback': 1.18,
        'SUV': 0.88,
        'Spor': 0.85,
        'Klasik': 1.0,
      },
      {
        'headline': 'Lüks & Klasik Araç Koleksiyonerleri Piyasayı Hareketlendirdi!',
        'Sedan': 1.05,
        'Hatchback': 1.0,
        'SUV': 1.05,
        'Spor': 1.15,
        'Klasik': 1.30,
      },
      {
        'headline': 'İkinci El Piyasasında Durgunluk — Kelepir Araç Fırsatları Artıyor.',
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
    int count = 10,
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
    
    // Determine body type and year based on brand and model
    String bodyType = GameConstants.bodyTypes[_random.nextInt(GameConstants.bodyTypes.length)];
    int year = 2010 + _random.nextInt(15); // 2010 - 2024 default

    bool isClassicModel = modelName.contains('Murat') ||
        modelName.contains('Toros') ||
        modelName.contains('Broad-Vey') ||
        modelName.contains('A-Bir') ||
        modelName.contains('STC') ||
        modelName.contains('Böcek') ||
        modelName.contains('E-30') ||
        modelName.contains('W-124') ||
        modelName.contains('Supra') ||
        modelName.contains('S-İkiBin') ||
        modelName.contains('Uno') ||
        modelName.contains('Temprament') ||
        modelName.contains('Serçe') ||
        modelName.contains('Kartal') ||
        modelName.contains('Şahin') ||
        modelName.contains('Doğan');

    if (isClassicModel) {
      bodyType = 'Klasik';
      year = 1974 + _random.nextInt(32); // 1974 - 2005
    } else if (modelName.contains('SUV') || modelName.contains('Keçisi') || modelName.contains('Tuğla') || modelName.contains('Gezgini') || modelName.contains('Hilaks') || modelName.contains('Aslan SUV') || modelName.contains('T-Oniks') || modelName.contains('Kros') || modelName.contains('Boğası')) {
      bodyType = 'SUV';
    } else if (modelName.contains('9-1-2') || modelName.contains('M-Dört') || modelName.contains('Haraççı') || modelName.contains('Canavar') || modelName.contains('V10') || modelName.contains('V12') || modelName.contains('Müstang') || modelName.contains('S-İkiBin') || modelName.contains('Roket')) {
      bodyType = 'Spor';
    }

    final id = 'car_${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(999)}';

    // 12% chance of Rare vehicle drop (or classic model is inherently collectible)
    final isRare = isClassicModel || (_random.nextDouble() < 0.12);

    // Mileage & Tramer
    final mileage = isRare
        ? (12000 + _random.nextInt(180000))
        : (5000 + _random.nextInt(345000));
    final hasTramer = isRare ? (_random.nextDouble() < 0.3) : (_random.nextDouble() < 0.55);
    final tramerAmount = hasTramer ? (1500 + _random.nextInt(43500)) : 0;
    final isTampered = _random.nextDouble() < 0.08;

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

    final engineCondition = (40.0 + _random.nextInt(61)).clamp(40.0, 100.0);
    final transCondition = (45.0 + _random.nextInt(56)).clamp(45.0, 100.0);

    final expertise = ExpertiseReport(
      engineCondition: engineCondition.toDouble(),
      transmissionCondition: transCondition.toDouble(),
      tramerAmount: tramerAmount,
      mileage: mileage,
      isMileageTampered: isTampered,
      bodyParts: bodyParts,
    );

    // Realistic Segment-Based Base Value Calculation
    double baseValue;
    if (isClassicModel) {
      baseValue = isRare ? (320000.0 + _random.nextInt(480000)) : (140000.0 + _random.nextInt(190000));
    } else {
      final int yearDiff = (year >= 2005) ? (year - 2005) : 0;
      switch (brandData.segment) {
        case 'efsane':
        case 'klasik':
          baseValue = isRare ? (320000.0 + _random.nextInt(480000)) : (140000.0 + _random.nextInt(190000));
          break;
        case 'ekonomi':
          baseValue = 350000.0 + yearDiff * 28000.0;
          break;
        case 'halk':
          baseValue = 480000.0 + yearDiff * 35000.0;
          break;
        case 'popüler':
        case 'güvenilir':
          baseValue = 580000.0 + yearDiff * 42000.0;
          break;
        case 'premium':
        case 'lüks':
        case 'güvenlik':
          baseValue = 1100000.0 + yearDiff * 85000.0;
          break;
        case 'elektrikli':
          baseValue = 1800000.0 + (year >= 2018 ? (year - 2018) : 0) * 90000.0;
          break;
        case 'süperspor':
          baseValue = 3800000.0 + (year >= 2010 ? (year - 2010) : 0) * 220000.0;
          break;
        case 'egzotik':
          baseValue = 7500000.0 + (year >= 2015 ? (year - 2015) : 0) * 450000.0;
          break;
        default:
          baseValue = 450000.0 + yearDiff * 35000.0;
      }
    }

    if (baseValue < 100000.0) baseValue = 100000.0;

    if (bodyType == 'Spor') baseValue *= 1.25;
    if (bodyType == 'SUV') baseValue *= 1.20;

    // Apply market trend multiplier!
    final trendMult = trend.bodyTypeMultipliers[bodyType] ?? 1.0;
    baseValue *= trendMult;

    // Rare collector multiplier
    if (isRare && isClassicModel) {
      baseValue *= 1.35;
    }

    // Seller profile
    final sellerProfile = GameConstants.sellerProfiles[_random.nextInt(GameConstants.sellerProfiles.length)];
    final isFlashDeal = _random.nextDouble() < 0.12;

    final carTemp = CarModel(
      id: id,
      brand: brandData.name,
      modelName: modelName,
      modelYear: year,
      bodyType: bodyType,
      colorHex: _getRandomColorHex(),
      baseMarketValue: baseValue,
      currentPurchasePrice: baseValue,
      isRare: isRare,
      expertise: expertise,
    );

    // Realistic seller asking price between 70% and 130% of fair market value
    double randomMarginFactor = 0.70 + (_random.nextDouble() * 0.60); // 0.70 to 1.30
    if (isFlashDeal) randomMarginFactor = 0.65 + (_random.nextDouble() * 0.15); // 0.65 to 0.80

    double askingPrice = (carTemp.estimatedRealValue * randomMarginFactor).roundToDouble();
    if (askingPrice < 50000) askingPrice = 50000;

    final car = carTemp.copyWith(currentPurchasePrice: askingPrice);

    final cities = ['İstanbul', 'Ankara', 'İzmir', 'Bursa', 'Antalya', 'Adana', 'Konya', 'Gaziantep', 'Trabzon'];
    final sellerCity = cities[_random.nextInt(cities.length)];

    String title = '$year ${brandData.name} $modelName';
    if (isRare) title = '⭐ [KOLEKSİYON] $title';

    String description = isFlashDeal
        ? '🔥 ACİL SATILIK KELEPİR FİYAT! İlk arayan alır, pazarlık sünnettir.'
        : (isRare
            ? 'Garaj arabası, düşük km, özenle saklanmış koleksiyonluk nadide araç!'
            : 'Bakımları yetkili serviste yapılmıştır. Masrafsız, nakit veya mantıklı takasa uygundur.');

    return ListingModel(
      id: 'listing_$id',
      car: car,
      sellerName: '${sellerProfile['name']} (${_getRandomSellerName()})',
      sellerTrait: isRare ? 'Koleksiyonluk Nadir Araç' : (isFlashDeal ? 'Fırsat İlanı! Çok Acele' : sellerProfile['trait']!),
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
