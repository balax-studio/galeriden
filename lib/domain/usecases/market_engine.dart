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
      minCount = 20;
      maxCount = 40;
    } else if (playerLevel == 2) {
      minCount = 25;
      maxCount = 50;
    } else if (playerLevel == 3) {
      minCount = 30;
      maxCount = 55;
    } else if (playerLevel == 4) {
      minCount = 30;
      maxCount = 60;
    } else {
      minCount = 35;
      maxCount = 70;
    }

    // Adjust based on market trend sentiments
    if (trend != null) {
      final headline = trend.headline.toLowerCase();
      if (headline.contains('durgunluk') || headline.contains('düşüş') || headline.contains('azalma')) {
        minCount = max(20, minCount - 5);
        maxCount = max(minCount + 10, maxCount - 10);
      } else if (headline.contains('yükseliş') || headline.contains('talep') || headline.contains('hareket') || headline.contains('patladı')) {
        minCount = min(60, minCount + 5);
        maxCount = min(70, maxCount + 10);
      }
    }

    final count = minCount + rng.nextInt(maxCount - minCount + 1);
    return count.clamp(20, 70);
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

    final cities = ['İstanbul', 'Ankara', 'İzmir', 'Bursa', 'Adana', 'Konya'];
    final sellerCity = cities[_random.nextInt(cities.length)];
    final paint = _getRandomPaintColor();
    final plate = generateLicensePlate(city: sellerCity);

    final carTemp = CarModel(
      id: id,
      brand: brandData.name,
      modelName: modelName,
      modelYear: year,
      bodyType: 'Sedan',
      colorHex: paint.hex,
      colorDisplayName: paint.name,
      colorRarity: paint.rarity,
      plateNumber: plate.number,
      plateRarity: plate.rarity,
      baseMarketValue: baseValue,
      currentPurchasePrice: baseValue,
      isRare: false,
      isBarnFind: false,
      declarationType: ListingDeclarationType.honest,
      expertise: expertise,
    );

    final targetPrice = (carTemp.estimatedRealValue * (0.80 + _random.nextDouble() * 0.20)).clamp(35000.0, budgetLimit).roundToDouble();
    final car = carTemp.copyWith(currentPurchasePrice: targetPrice);

    return ListingModel(
      id: 'listing_$id',
      car: car,
      sellerName: 'İlk Sahibinden Borçtan • ${_getRandomSellerName()}',
      sellerTrait: 'Fiyat esnek, tamire ihtiyacı var',
      sellerCity: sellerCity,
      title: '$year ${brandData.name} $modelName',
      description: 'Acil nakit ihtiyacından kelepir fiyata satılık ayağı yerden kesecek başlangıç arabası!',
      askingPrice: targetPrice,
      isExpertiseCompleted: false,
      createdAt: DateTime.now(),
    );
  }

  static (String bodyType, int year, bool isClassicModel) _determineBodyTypeAndYear(String modelName) {
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
    
    return (bodyType, year, isClassicModel);
  }

  static double _calculateBaseValue(String segment, int year, bool isClassicModel, bool isRare) {
    if (isClassicModel) {
      return isRare ? (180000.0 + _random.nextInt(220000)) : (45000.0 + _random.nextInt(45000));
    }
    
    final int yearDiff = (year >= 2005) ? (year - 2005) : 0;
    
    switch (segment) {
      case 'efsane':
        return isRare ? (180000.0 + _random.nextInt(220000)) : (45000.0 + _random.nextInt(45000));
      case 'klasik':
        return isRare ? (220000.0 + _random.nextInt(260000)) : (55000.0 + _random.nextInt(45000));
      case 'ekonomi':
        return 140000.0 + yearDiff * 18000.0;
      case 'halk':
        return 240000.0 + yearDiff * 25000.0;
      case 'popüler':
      case 'güvenilir':
        return 380000.0 + yearDiff * 32000.0;
      case 'premium':
      case 'lüks':
      case 'güvenlik':
        return 900000.0 + yearDiff * 75000.0;
      case 'elektrikli':
        return 1500000.0 + (year >= 2018 ? (year - 2018) : 0) * 80000.0;
      case 'süperspor':
        return 3500000.0 + (year >= 2010 ? (year - 2010) : 0) * 200000.0;
      case 'egzotik':
        return 6500000.0 + (year >= 2015 ? (year - 2015) : 0) * 400000.0;
      default:
        return 320000.0 + yearDiff * 28000.0;
    }
  }

  static String _generateTitle(int year, String brand, String modelName, bool isBarnFind, bool isRare, {bool isPristine = false}) {
    String title = '$year $brand $modelName';
    if (isBarnFind) return '[SAMANLIK KELEPİRİ] $title';
    if (isPristine) return '[HATASIZ BOYASIZ] $title';
    if (isRare) return '[KOLEKSİYON] $title';
    return title;
  }

  static String _generateDescription({
    bool isBarnFind = false,
    bool isFlashDeal = false,
    bool isRare = false,
    bool isPristine = false,
    ListingDeclarationType declarationType = ListingDeclarationType.honest,
  }) {
    if (isBarnFind) {
      final barnDescriptions = [
        'Köydeki dede yadigarı garajdan/samanlıktan yeni çıkarıldı! Yıllardır dokunulmadı, restorasyon projesi için bulunmaz fırsat.',
        'Kapalı depoda uzun yıllar muhafaza edilmiş orijinal gövde. Klasik restorasyon meraklısına kelepir fiyata devredilecektir.',
        'Samanlık buluntusu! Motor ve yürüyen elden geçmeli, gövde hatları düzgün. Proje aracı arayanlar için kaçırılmayacak fırsat.',
      ];
      return barnDescriptions[_random.nextInt(barnDescriptions.length)];
    }
    if (isPristine) {
      final pristineDescriptions = [
        'FABRİKASYON HATASIZ & BOYASIZ! İlk sahibinden yetkili servis bakımlı, tek kuruş masrafsız garaj arabası.',
        'Boya, değişen, tramer kesinlikle YOKTUR. Tüm gövde panelleri ve cıvataları orijinaldir. Ekspertize açıktır.',
        'Sıfır kokusu üzerinde! Nokta hatasız, tamponlarında dahi çizik yoktur. Kapalı garajda muhafaza edilmiştir.',
      ];
      return pristineDescriptions[_random.nextInt(pristineDescriptions.length)];
    }
    if (isFlashDeal) {
      final flashDescriptions = [
        'ACİL NAKİT İHTİYACINDAN KELEPİR FİYAT! İlk gelen alır, araç başında cüzi pazarlık olur.',
        'Yurtdışına taşınma sebebiyle çok acil satılık! Fiyatı piyasa değerinin altında tuttum, kaçıran üzülür.',
        'Ödemelerim sebebiyle birkaç günlüğüne bu fiyattır. Takas teklif etmeyiniz, sadece nakit satılık.',
      ];
      return flashDescriptions[_random.nextInt(flashDescriptions.length)];
    }
    if (isRare) {
      final rareDescriptions = [
        'Koleksiyon kondisyonunda, özenle saklanmış nadide araç! Kapalı garajda muhafaza edilmektedir.',
        'Özel seri, düşük kilometre ve hatasız kondisyonda. Değerini bilen gerçek koleksiyonculara hayırlı olsun.',
        'Hafta sonları keyifle binilmiş pırıl pırıl koleksiyon arabası. Tüm fabrika etiketleri ve orijinal parçaları üzerindedir.',
      ];
      return rareDescriptions[_random.nextInt(rareDescriptions.length)];
    }

    if (declarationType == ListingDeclarationType.honest) {
      final honestDescriptions = [
        'Bakımları zamanında eksiksiz yapılmıştır. Şehir içi sürtmelerden ufak boyaları vardır, şasiler tavan orijinaldir.',
        'İlk sahibinden temiz aile aracı. Boyalı parçaları aşağıda dürüstçe işaretlenmiştir. Yürüyeni kusursuzdur.',
        'Memurdan kullanılmış araç. Tüm periyodik bakımları serviste yapılmış olup ekspertiz raporu mevcuttur.',
        'Araçta değişen parçalar belirtilmiştir. Motoru ve şanzımanı saat gibi, masrafsız binilecek araçtır.',
      ];
      return honestDescriptions[_random.nextInt(honestDescriptions.length)];
    }

    final standardDescriptions = [
      'Bakımları zamanında eksiksiz yapılmıştır. Yürüyen aksamı ve motoru kusursuzdur, masrafsız binilecek araçtır.',
      'İlk sahibinden temiz aile aracı. İç döşemelerinde yanık yırtık yoktur, periyodik bakımları yeni tamamlandı.',
      'Memurdan temiz kullanılmış, uzun yolda yorulmamış araç. Lastikleri yeni, muayenesi günceldir.',
      'Şehir içi iş-ev arası titizlikle kullanılmıştır. Ekspertiz raporuna açıktır, alıcısına şimdiden hayırlı uğurlu olsun.',
      'Kapalı garaj arabasıdır. Yedek anahtarı ve kitapçıkları mevcuttur. Pazarlık araç başında usulünce yapılır.',
    ];
    return standardDescriptions[_random.nextInt(standardDescriptions.length)];
  }

  static ListingModel _generateSingleListing(int playerLevel, MarketTrendModel trend) {
    final brandData = _selectWeightedBrand();
    final modelName = brandData.models[_random.nextInt(brandData.models.length)];
    
    final (bodyType, year, isClassicModel) = _determineBodyTypeAndYear(modelName);
    final id = 'car_${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(999)}';

    // 28% chance of Pristine ("Hatasız & Boyasız") Vehicle
    final isPristine = !isClassicModel && (_random.nextDouble() < 0.28);

    // 12% chance of Rare vehicle drop (or classic model is inherently collectible)
    final isRare = isClassicModel || (_random.nextDouble() < 0.12);

    // Mileage & Tramer
    final mileage = isPristine
        ? (15000 + _random.nextInt(65000))
        : (isRare ? (12000 + _random.nextInt(180000)) : (5000 + _random.nextInt(345000)));

    final hasTramer = isPristine ? false : (isRare ? (_random.nextDouble() < 0.3) : (_random.nextDouble() < 0.55));
    final tramerAmount = hasTramer ? (1500 + _random.nextInt(43500)) : 0;
    
    // Seller Honesty Distribution (§2.2):
    // 40% Honest, 35% Minor flaw hidden, 25% Major flaw hidden
    final ListingDeclarationType declarationType;
    if (isPristine) {
      declarationType = ListingDeclarationType.honest;
    } else {
      final honestyRoll = _random.nextDouble();
      if (honestyRoll < 0.40) {
        declarationType = ListingDeclarationType.honest;
      } else if (honestyRoll < 0.75) {
        declarationType = ListingDeclarationType.minorFlawHidden;
      } else {
        declarationType = (_random.nextDouble() < 0.30)
            ? ListingDeclarationType.tamperedMileageClaim
            : ListingDeclarationType.flawlessClaim;
      }
    }

    final isTampered = (declarationType == ListingDeclarationType.tamperedMileageClaim);

    final Map<String, PartStatus> bodyParts;
    if (isPristine) {
      bodyParts = <String, PartStatus>{
        'Kaput': PartStatus.original,
        'Tavan': PartStatus.original,
        'Sol Ön Çamurluk': PartStatus.original,
        'Sağ Ön Çamurluk': PartStatus.original,
        'Sol Arka Çamurluk': PartStatus.original,
        'Sağ Arka Çamurluk': PartStatus.original,
        'Sol Ön Kapı': PartStatus.original,
        'Sağ Ön Kapı': PartStatus.original,
        'Sol Arka Kapı': PartStatus.original,
        'Sağ Arka Kapı': PartStatus.original,
        'Bagaj': PartStatus.original,
        'Şasi/Podye': PartStatus.original,
      };
    } else {
      bodyParts = <String, PartStatus>{
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
    }

    final engineCondition = isPristine
        ? (88.0 + _random.nextInt(13)).clamp(85.0, 100.0)
        : (40.0 + _random.nextInt(61)).clamp(40.0, 100.0);
    final transCondition = isPristine
        ? (88.0 + _random.nextInt(13)).clamp(85.0, 100.0)
        : (45.0 + _random.nextInt(56)).clamp(45.0, 100.0);

    final expertise = ExpertiseReport(
      engineCondition: engineCondition.toDouble(),
      transmissionCondition: transCondition.toDouble(),
      tramerAmount: tramerAmount,
      mileage: mileage,
      isMileageTampered: isTampered,
      bodyParts: bodyParts,
    );

    double baseValue = _calculateBaseValue(brandData.segment, year, isClassicModel, isRare);
    if (baseValue < 35000.0) baseValue = 35000.0;

    if (bodyType == 'Spor') baseValue *= 1.25;
    if (bodyType == 'SUV') baseValue *= 1.20;

    // Apply market trend multiplier!
    final trendMult = trend.bodyTypeMultipliers[bodyType] ?? 1.0;
    baseValue *= trendMult;

    // Pristine collector premium
    if (isPristine) {
      baseValue *= 1.15;
    }

    // Rare collector multiplier
    if (isRare && isClassicModel) {
      baseValue *= 1.35;
    }

    // Seller profile
    final sellerProfile = GameConstants.sellerProfiles[_random.nextInt(GameConstants.sellerProfiles.length)];
    final isFlashDeal = !isPristine && (_random.nextDouble() < 0.12);

    // 4% chance of Barn Find (Samanlık Kelepiri)
    final isBarnFind = !isPristine && (isClassicModel || _random.nextDouble() < 0.04) && _random.nextDouble() < 0.40;

    final cities = ['İstanbul', 'Ankara', 'İzmir', 'Bursa', 'Antalya', 'Adana', 'Konya', 'Gaziantep', 'Trabzon'];
    final sellerCity = cities[_random.nextInt(cities.length)];
    final paint = _getRandomPaintColor();
    final plate = generateLicensePlate(city: sellerCity);

    final carTemp = CarModel(
      id: id,
      brand: brandData.name,
      modelName: modelName,
      modelYear: year,
      bodyType: bodyType,
      colorHex: paint.hex,
      colorDisplayName: paint.name,
      colorRarity: paint.rarity,
      plateNumber: plate.number,
      plateRarity: plate.rarity,
      baseMarketValue: baseValue,
      currentPurchasePrice: baseValue,
      isRare: isRare || isBarnFind || isPristine,
      isBarnFind: isBarnFind,
      declarationType: declarationType,
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
    if (isPristine) randomMarginFactor = 1.05 + (_random.nextDouble() * 0.15); // Clean pristine pricing
    if (isFlashDeal) randomMarginFactor = 0.65 + (_random.nextDouble() * 0.15); // 0.65 to 0.80
    if (isBarnFind) randomMarginFactor = 0.35 + (_random.nextDouble() * 0.20); // 0.35 to 0.55 (Dirt cheap kelepir!)

    double askingPrice = (carTemp.estimatedRealValue * randomMarginFactor).roundToDouble();
    if (askingPrice < 35000) askingPrice = 35000;

    final car = carTemp.copyWith(currentPurchasePrice: askingPrice);

    return ListingModel(
      id: 'listing_$id',
      car: car,
      sellerName: isPristine
          ? 'Titiz Sahibinden • ${_getRandomSellerName()}'
          : '${sellerProfile['name']} • ${_getRandomSellerName()}',
      sellerTrait: isPristine
          ? 'Hatasız & Orijinal Garaj Arabası'
          : (isBarnFind
              ? 'Terk Edilmiş Kelepir Araç'
              : (isRare ? 'Koleksiyonluk Nadir Araç' : (isFlashDeal ? 'Fırsat İlanı! Çok Acele' : sellerProfile['trait']!))),
      sellerCity: sellerCity,
      title: _generateTitle(year, brandData.name, modelName, isBarnFind, isRare, isPristine: isPristine),
      description: _generateDescription(
        isBarnFind: isBarnFind,
        isFlashDeal: isFlashDeal,
        isRare: isRare,
        isPristine: isPristine,
        declarationType: declarationType,
      ),
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

  /// Generates dynamic realistic Turkish license plates with city code and rarity
  static ({String number, String rarity}) generateLicensePlate({String? city}) {
    final cityCodeMap = {
      'İstanbul': '34',
      'Ankara': '06',
      'İzmir': '35',
      'Bursa': '16',
      'Antalya': '07',
      'Adana': '01',
      'Konya': '42',
      'Gaziantep': '27',
      'Trabzon': '61',
      'Samsun': '55',
      'Eskişehir': '26',
      'Kocaeli': '41',
      'Balıkesir': '10',
      'Denizli': '20',
      'Kayseri': '38',
      'Diyarbakır': '21',
      'Aydın': '09',
      'Muğla': '48',
      'Mersin': '33',
    };

    final cityCode = city != null && cityCodeMap.containsKey(city)
        ? cityCodeMap[city]!
        : (['34', '06', '35', '16', '07', '01', '42', '61', '55', '26', '41', '38', '27'][_random.nextInt(13)]);

    // 4% chance of Legendary Special Plate
    if (_random.nextDouble() < 0.04) {
      final legendaryPlates = [
        ('$cityCode ATA 1881', 'legendary'),
        ('$cityCode GS 1905', 'legendary'),
        ('$cityCode FB 1907', 'legendary'),
        ('$cityCode BJK 1903', 'legendary'),
        ('61 TS 1967', 'legendary'),
        ('$cityCode VIP 001', 'legendary'),
        ('$cityCode BOSS 99', 'legendary'),
        ('$cityCode KRL 01', 'legendary'),
        ('$cityCode PRO 777', 'legendary'),
        ('$cityCode M 9999', 'repeated'),
        ('$cityCode TC 001', 'legendary'),
        ('$cityCode GAL 1923', 'legendary'),
      ];
      final pick = legendaryPlates[_random.nextInt(legendaryPlates.length)];
      return (number: pick.$1, rarity: pick.$2);
    }

    // 8% chance of Repeated / Symmetric Plate
    if (_random.nextDouble() < 0.08) {
      final letters2 = ['AA', 'BB', 'CC', 'DD', 'EE', 'FF', 'GG', 'HH', 'JJ', 'KK', 'LL', 'MM', 'NN', 'PP', 'RR', 'SS', 'TT', 'VV', 'YY', 'ZZ'];
      final letter = letters2[_random.nextInt(letters2.length)];
      final repeatedDigits = ['111', '222', '333', '444', '555', '666', '777', '888', '999', '1111', '5555', '7777', '9999'];
      final numStr = repeatedDigits[_random.nextInt(repeatedDigits.length)];
      return (number: '$cityCode $letter $numStr', rarity: 'repeated');
    }

    // Standard Plate: 2 or 3 letters + 2 to 4 digits
    final use3Letters = _random.nextBool();
    String letters;
    if (use3Letters) {
      final series3 = ['GAL', 'OTO', 'ALP', 'CAN', 'EGE', 'MRA', 'YSR', 'BLX', 'DEV', 'CAR', 'CEM', 'DEN', 'BER', 'KER', 'MUR', 'BUR', 'POL', 'KAS', 'HAN', 'KOC', 'TAY', 'BAK', 'YLM', 'KAP', 'YLD', 'SEN', 'AYD', 'OZK', 'DEM'];
      letters = series3[_random.nextInt(series3.length)];
    } else {
      final alphabet = 'ABCDEFGHJKLMNPRSTUVYZ';
      final l1 = alphabet[_random.nextInt(alphabet.length)];
      final l2 = alphabet[_random.nextInt(alphabet.length)];
      letters = '$l1$l2';
    }

    final digits = use3Letters
        ? (10 + _random.nextInt(90)).toString()
        : (100 + _random.nextInt(9000)).toString();

    // Check symmetry like 1221, 3003
    if (digits.length == 4 && digits[0] == digits[3] && digits[1] == digits[2]) {
      return (number: '$cityCode $letters $digits', rarity: 'symmetric');
    }

    return (number: '$cityCode $letters $digits', rarity: 'standard');
  }

  /// Generates dynamic authentic Turkish automotive paint colors
  static ({String hex, String name, String rarity}) _getRandomPaintColor() {
    final colors = [
      (hex: '#FFFFFF', name: 'Opak Beyaz', rarity: 'standard', weight: 15),
      (hex: '#F8F9FA', name: 'Kutup Beyazı', rarity: 'standard', weight: 12),
      (hex: '#F0F3F4', name: 'İnci Beyazı', rarity: 'rare', weight: 8),
      (hex: '#0D0D0F', name: 'Gece Siyahı', rarity: 'standard', weight: 14),
      (hex: '#1A1A1D', name: 'Obsidyen Siyahı', rarity: 'rare', weight: 7),
      (hex: '#111111', name: 'Karbon Siyah', rarity: 'legendary', weight: 4),
      (hex: '#7F8C8D', name: 'Titanyum Gri', rarity: 'standard', weight: 12),
      (hex: '#5D6D7E', name: 'Kurşun Gri', rarity: 'standard', weight: 10),
      (hex: '#8E9398', name: 'Nardo Gri', rarity: 'rare', weight: 8),
      (hex: '#3E4444', name: 'Füme Gri', rarity: 'standard', weight: 10),
      (hex: '#1B4F72', name: 'Kozmik Mavi', rarity: 'standard', weight: 8),
      (hex: '#152238', name: 'Gece Mavisi', rarity: 'rare', weight: 6),
      (hex: '#2874A6', name: 'Okyanus Mavisi', rarity: 'standard', weight: 6),
      (hex: '#C0392B', name: 'Yakut Kırmızı', rarity: 'standard', weight: 7),
      (hex: '#E74C3C', name: 'Lansman Kırmızısı', rarity: 'rare', weight: 6),
      (hex: '#7B241C', name: 'Bordo', rarity: 'standard', weight: 7),
      (hex: '#D4AC0D', name: 'Şampanya Sarısı', rarity: 'standard', weight: 5),
      (hex: '#F1C40F', name: 'Safir Sarı', rarity: 'rare', weight: 4),
      (hex: '#1E8449', name: 'Yarış Yeşili', rarity: 'rare', weight: 4),
      (hex: '#145A32', name: 'Zümrüt Yeşil', rarity: 'standard', weight: 4),
      (hex: '#6E2C00', name: 'Tütün Kahvesi', rarity: 'rare', weight: 3),
      (hex: '#2C3E50', name: 'Simli Mat Füme', rarity: 'legendary', weight: 3),
    ];

    final totalWeight = colors.fold<int>(0, (sum, c) => sum + c.weight);
    int roll = _random.nextInt(totalWeight);
    int currentSum = 0;

    for (var c in colors) {
      currentSum += c.weight;
      if (roll < currentSum) {
        return (hex: c.hex, name: c.name, rarity: c.rarity);
      }
    }
    return (hex: '#0D0D0F', name: 'Gece Siyahı', rarity: 'standard');
  }

  static String _getRandomSellerName() {
    final names = ['Ahmet Y.', 'Mehmet K.', 'Caner S.', 'Mustafa B.', 'Emre T.', 'Burak M.'];
    return names[_random.nextInt(names.length)];
  }
}
