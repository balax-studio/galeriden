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

  /// Calculates dynamic market listing capacity based on player level and active market trends
  static int calculateDynamicListingCount({
    int playerLevel = 1,
    MarketTrendModel? trend,
    Random? randomOverride,
  }) {
    final rng = randomOverride ?? _random;
    int minCount;
    int maxCount;

    if (playerLevel <= 1) {
      minCount = 4;
      maxCount = 8;
    } else if (playerLevel == 2) {
      minCount = 5;
      maxCount = 10;
    } else if (playerLevel == 3) {
      minCount = 6;
      maxCount = 11;
    } else if (playerLevel == 4) {
      minCount = 6;
      maxCount = 12;
    } else {
      minCount = 7;
      maxCount = 14;
    }

    // Adjust based on market trend sentiments
    if (trend != null) {
      final headline = trend.headline.toLowerCase();
      if (headline.contains('durgunluk') || headline.contains('düşüş') || headline.contains('azalma')) {
        minCount = max(4, minCount - 1);
        maxCount = max(minCount + 2, maxCount - 2);
      } else if (headline.contains('yükseliş') || headline.contains('talep') || headline.contains('hareket') || headline.contains('patladı')) {
        minCount = min(12, minCount + 1);
        maxCount = min(14, maxCount + 2);
      }
    }

    final count = minCount + rng.nextInt(maxCount - minCount + 1);
    return count.clamp(4, 14);
  }

  static List<ListingModel> generateRandomListings({
    int? count,
    int playerLevel = 1,
    MarketTrendModel? trend,
    double? playerBalance,
  }) {
    final activeTrend = trend ?? generateMarketTrend();
    final actualCount = count ?? calculateDynamicListingCount(playerLevel: playerLevel, trend: activeTrend);
    List<ListingModel> listings = [];
    for (int i = 0; i < actualCount; i++) {
      listings.add(_generateSingleListing(playerLevel, activeTrend));
    }

    // Soft-lock prevention: Always guarantee at least 1 budget-friendly starter car
    // that the player can comfortably purchase with current balance or starting budget.
    final effectiveBalance = (playerBalance != null && playerBalance > 0) ? playerBalance : 75000.0;
    final maxAffordablePrice = max(35000.0, effectiveBalance * 0.90);

    final hasAffordable = listings.any((l) => l.askingPrice <= maxAffordablePrice);
    if (!hasAffordable && listings.isNotEmpty) {
      listings[0] = _generateAffordableStarterListing(playerLevel, activeTrend, maxBudget: maxAffordablePrice);
    }

    return listings;
  }

  static ListingModel _generateAffordableStarterListing(
    int playerLevel,
    MarketTrendModel trend, {
    required double maxBudget,
  }) {
    // Pick starter friendly brands
    final starterBrands = GameConstants.carBrands
        .where((b) => b.segment == 'efsane' || b.segment == 'klasik' || b.segment == 'ekonomi' || b.name == 'Reno' || b.name == 'Opelyus')
        .toList();
    final brandData = starterBrands.isNotEmpty
        ? starterBrands[_random.nextInt(starterBrands.length)]
        : GameConstants.carBrands.first;

    final modelName = brandData.models[_random.nextInt(brandData.models.length)];
    final id = 'car_starter_${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(999)}';
    final year = 1990 + _random.nextInt(15); // 1990 - 2005 budget years

    // Budget friendly starter base value (₺35.000 - ₺65.000)
    final budgetLimit = max(35000.0, min(maxBudget, 80000.0));
    final baseValue = 35000.0 + _random.nextInt(max(1, (budgetLimit - 35000.0).toInt() + 1));

    final engineCondition = (45.0 + _random.nextInt(40)).clamp(40.0, 90.0);
    final transCondition = (50.0 + _random.nextInt(35)).clamp(45.0, 90.0);
    final mileage = 120000 + _random.nextInt(160000);
    final tramerAmount = _random.nextInt(12000);

    final bodyParts = <String, PartStatus>{
      'Kaput': _getRandomPartStatus(),
      'Tavan': PartStatus.original,
      'Sol Ön Çamurluk': _getRandomPartStatus(),
      'Sağ Ön Çamurluk': _getRandomPartStatus(),
      'Sol Arka Çamurluk': _getRandomPartStatus(),
      'Sağ Arka Çamurluk': _getRandomPartStatus(),
      'Sol Ön Kapı': _getRandomPartStatus(),
      'Sağ Ön Kapı': _getRandomPartStatus(),
      'Sol Arka Kapı': _getRandomPartStatus(),
      'Sağ Arka Kapı': _getRandomPartStatus(),
      'Bagaj': _getRandomPartStatus(),
      'Şasi/Podye': PartStatus.original,
    };

    final expertise = ExpertiseReport(
      engineCondition: engineCondition.toDouble(),
      transmissionCondition: transCondition.toDouble(),
      tramerAmount: tramerAmount,
      mileage: mileage,
      isMileageTampered: false,
      bodyParts: bodyParts,
    );

    final targetPrice = (baseValue * (0.80 + _random.nextDouble() * 0.20)).clamp(35000.0, budgetLimit).roundToDouble();

    final car = CarModel(
      id: id,
      brand: brandData.name,
      modelName: modelName,
      modelYear: year,
      bodyType: 'Sedan',
      colorHex: _getRandomColorHex(),
      baseMarketValue: baseValue,
      currentPurchasePrice: targetPrice,
      isRare: false,
      isBarnFind: false,
      expertise: expertise,
    );

    final cities = ['İstanbul', 'Ankara', 'İzmir', 'Bursa', 'Adana', 'Konya'];
    final sellerCity = cities[_random.nextInt(cities.length)];

    return ListingModel(
      id: 'listing_$id',
      car: car,
      sellerName: 'İlk Sahibinden Borçtan (${_getRandomSellerName()})',
      sellerTrait: 'Fiyat esnek, tamire ihtiyacı var',
      sellerCity: sellerCity,
      title: '$year ${brandData.name} $modelName',
      description: 'Acil nakit ihtiyacından kelepir fiyata satılık ayağı yerden kesecek başlangıç arabası!',
      askingPrice: targetPrice,
      isExpertiseCompleted: false,
      createdAt: DateTime.now(),
    );
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
        modelName.contains('Brodvey') ||
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
      baseValue = isRare ? (180000.0 + _random.nextInt(220000)) : (45000.0 + _random.nextInt(45000));
    } else {
      final int yearDiff = (year >= 2005) ? (year - 2005) : 0;
      switch (brandData.segment) {
        case 'efsane':
          baseValue = isRare ? (180000.0 + _random.nextInt(220000)) : (45000.0 + _random.nextInt(45000));
          break;
        case 'klasik':
          baseValue = isRare ? (220000.0 + _random.nextInt(260000)) : (55000.0 + _random.nextInt(45000));
          break;
        case 'ekonomi':
          baseValue = 140000.0 + yearDiff * 18000.0;
          break;
        case 'halk':
          baseValue = 240000.0 + yearDiff * 25000.0;
          break;
        case 'popüler':
        case 'güvenilir':
          baseValue = 380000.0 + yearDiff * 32000.0;
          break;
        case 'premium':
        case 'lüks':
        case 'güvenlik':
          baseValue = 900000.0 + yearDiff * 75000.0;
          break;
        case 'elektrikli':
          baseValue = 1500000.0 + (year >= 2018 ? (year - 2018) : 0) * 80000.0;
          break;
        case 'süperspor':
          baseValue = 3500000.0 + (year >= 2010 ? (year - 2010) : 0) * 200000.0;
          break;
        case 'egzotik':
          baseValue = 6500000.0 + (year >= 2015 ? (year - 2015) : 0) * 400000.0;
          break;
        default:
          baseValue = 320000.0 + yearDiff * 28000.0;
      }
    }

    if (baseValue < 35000.0) baseValue = 35000.0;

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

    // 4% chance of Barn Find (Samanlık Kelepiri)
    final isBarnFind = (isClassicModel || _random.nextDouble() < 0.04) && _random.nextDouble() < 0.40;

    final carTemp = CarModel(
      id: id,
      brand: brandData.name,
      modelName: modelName,
      modelYear: year,
      bodyType: bodyType,
      colorHex: _getRandomColorHex(),
      baseMarketValue: baseValue,
      currentPurchasePrice: baseValue,
      isRare: isRare || isBarnFind,
      isBarnFind: isBarnFind,
      expertise: isBarnFind
          ? ExpertiseReport(
              engineCondition: (25.0 + _random.nextInt(20)).toDouble(),
              transmissionCondition: (20.0 + _random.nextInt(25)).toDouble(),
              tramerAmount: 0,
              mileage: 45000 + _random.nextInt(90000),
              isMileageTampered: false,
              bodyParts: {
                'Kaput': PartStatus.painted,
                'Tavan': PartStatus.original,
                'Sol Ön Çamurluk': PartStatus.changed,
                'Sağ Ön Çamurluk': PartStatus.painted,
                'Sol Arka Çamurluk': PartStatus.painted,
                'Sağ Arka Çamurluk': PartStatus.original,
                'Sol Ön Kapı': PartStatus.painted,
                'Sağ Ön Kapı': PartStatus.original,
                'Sol Arka Kapı': PartStatus.original,
                'Sağ Arka Kapı': PartStatus.painted,
                'Bagaj': PartStatus.original,
                'Şasi/Podye': PartStatus.original,
              },
            )
          : expertise,
    );

    // Realistic seller asking price between 70% and 130% of fair market value
    double randomMarginFactor = 0.70 + (_random.nextDouble() * 0.60); // 0.70 to 1.30
    if (isFlashDeal) randomMarginFactor = 0.65 + (_random.nextDouble() * 0.15); // 0.65 to 0.80
    if (isBarnFind) randomMarginFactor = 0.35 + (_random.nextDouble() * 0.20); // 0.35 to 0.55 (Dirt cheap kelepir!)

    double askingPrice = (carTemp.estimatedRealValue * randomMarginFactor).roundToDouble();
    if (askingPrice < 35000) askingPrice = 35000;

    final car = carTemp.copyWith(currentPurchasePrice: askingPrice);

    final cities = ['İstanbul', 'Ankara', 'İzmir', 'Bursa', 'Antalya', 'Adana', 'Konya', 'Gaziantep', 'Trabzon'];
    final sellerCity = cities[_random.nextInt(cities.length)];

    String title = '$year ${brandData.name} $modelName';
    if (isBarnFind) {
      title = '[SAMANLIK KELEPİRİ] $title';
    } else if (isRare) {
      title = '[KOLEKSİYON] $title';
    }

    String description = isBarnFind
        ? 'Köydeki dede yadigarı garajdan/samanlıktan yeni çıkarıldı! 15 yıldır çalıştırılmadı, restorasyon yapacak usta arıyor.'
        : (isFlashDeal
            ? 'ACİL SATILIK KELEPİR FİYAT! İlk arayan alır, pazarlık sünnettir.'
            : (isRare
                ? 'Garaj arabası, düşük km, özenle saklanmış koleksiyonluk nadide araç!'
                : 'Bakımları yetkili serviste yapılmıştır. Masrafsız, nakit veya mantıklı takasa uygundur.'));

    return ListingModel(
      id: 'listing_$id',
      car: car,
      sellerName: '${sellerProfile['name']} (${_getRandomSellerName()})',
      sellerTrait: isBarnFind
          ? 'Terk Edilmiş Kelepir Araç'
          : (isRare ? 'Koleksiyonluk Nadir Araç' : (isFlashDeal ? 'Fırsat İlanı! Çok Acele' : sellerProfile['trait']!)),
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
