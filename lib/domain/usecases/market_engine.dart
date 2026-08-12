import 'dart:math';
import '../../core/constants/game_constants.dart';
import '../../data/models/car_model.dart';
import '../../data/models/expertise_model.dart';
import '../../data/models/listing_model.dart';

class MarketEngine {
  static final Random _random = Random();

  static List<ListingModel> generateRandomListings({int count = 6, int playerLevel = 1}) {
    List<ListingModel> listings = [];
    for (int i = 0; i < count; i++) {
      listings.add(_generateSingleListing(playerLevel));
    }
    return listings;
  }

  static ListingModel _generateSingleListing(int playerLevel) {
    final brand = GameConstants.carBrands[_random.nextInt(GameConstants.carBrands.length)];
    final bodyType = GameConstants.bodyTypes[_random.nextInt(GameConstants.bodyTypes.length)];
    final year = 2014 + _random.nextInt(12);
    final id = 'car_${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(999)}';

    // Mileage & Tramer
    final mileage = 15000 + _random.nextInt(220000);
    final hasTramer = _random.nextDouble() > 0.4;
    final tramerAmount = hasTramer ? (1500 + _random.nextInt(45000)) : 0;
    final isTampered = _random.nextDouble() < 0.15; // 15% risk of tampered KM

    // Body parts status
    final bodyParts = <String, PartStatus>{
      'Kaput': _getRandomPartStatus(),
      'Tavan': _getRandomPartStatus(tavanMultiplier: true),
      'Sol Ön Çamurluk': _getRandomPartStatus(),
      'Sağ Ön Çamurluk': _getRandomPartStatus(),
      'Sol Arka Çamurluk': _getRandomPartStatus(),
      'Bagaj': _getRandomPartStatus(),
      'Şasi/Podye': _getRandomPartStatus(shasiMultiplier: true),
    };

    final engineCondition = (60.0 + _random.nextInt(38)).clamp(40.0, 100.0);
    final transCondition = (65.0 + _random.nextInt(33)).clamp(50.0, 100.0);

    final expertise = ExpertiseReport(
      engineCondition: engineCondition,
      transmissionCondition: transCondition,
      tramerAmount: tramerAmount,
      mileage: mileage,
      isMileageTampered: isTampered,
      bodyParts: bodyParts,
    );

    // Value calculation
    double baseValue = 40000.0 + (playerLevel * 35000.0) + (year - 2014) * 8000.0;
    if (bodyType == 'Spor') baseValue *= 1.35;
    if (bodyType == 'SUV') baseValue *= 1.25;

    // Seller traits
    final sellerProfile = GameConstants.sellerProfiles[_random.nextInt(GameConstants.sellerProfiles.length)];
    double discount = _random.nextDouble() * 0.15; // 0-15% below market
    if (sellerProfile['urgency'] == 'high') discount += 0.10;

    double askingPrice = (baseValue * (1.0 - discount)).roundToDouble();

    final car = CarModel(
      id: id,
      brand: brand,
      modelName: '$bodyType X${year % 100}',
      modelYear: year,
      bodyType: bodyType,
      colorHex: _getRandomColorHex(),
      baseMarketValue: baseValue,
      currentPurchasePrice: askingPrice,
      expertise: expertise,
    );

    final cities = ['İstanbul', 'Ankara', 'İzmir', 'Bursa', 'Antalya', 'Adana'];
    final sellerCity = cities[_random.nextInt(cities.length)];

    return ListingModel(
      id: 'listing_$id',
      car: car,
      sellerName: '${sellerProfile['name']} (${_getRandomSellerName()})',
      sellerTrait: sellerProfile['trait']!,
      sellerCity: sellerCity,
      title: '$year $brand $bodyType - ${sellerProfile['name']}',
      description: 'Temiz kullanılmıştır, bakımları zamanında yapılmıştır. Nakit satılık.',
      askingPrice: askingPrice,
      isExpertiseCompleted: false,
      createdAt: DateTime.now(),
    );
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
