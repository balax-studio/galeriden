import 'dart:math' as math;
import '../../data/models/car_model.dart';
import '../../data/models/expertise_model.dart';

enum MysteryContainerTier {
  standard,
  rare,
  exotic,
  legendaryHyper,
}

class MysteryContainerResult {
  final CarModel car;
  final MysteryContainerTier tier;
  final double costPaid;
  final double estimatedValue;
  final double profitMargin;

  const MysteryContainerResult({
    required this.car,
    required this.tier,
    required this.costPaid,
    required this.estimatedValue,
    required this.profitMargin,
  });
}

class BlackMarketContainerEngine {
  static const double containerCost = 3500000.0;
  static const int cooldownDays = 7;

  /// Probability weights:
  /// Standard (%15): ₺2.000.000 - ₺4.200.000
  /// Rare (%40): ₺4.200.000 - ₺6.500.000
  /// Exotic (%30): ₺7.000.000 - ₺10.500.000
  /// Hypercar (%15): ₺13.500.000 - ₺22.000.000
  static const double standardWeight = 0.15;
  static const double rareWeight = 0.40;
  static const double exoticWeight = 0.30;
  static const double hyperWeight = 0.15;

  static const List<Map<String, dynamic>> _standardPool = [
    {'brand': 'Volkswagen', 'model': 'Golf R 4Motion', 'year': 2022, 'body': 'Hatchback', 'minVal': 2200000.0, 'maxVal': 2700000.0},
    {'brand': 'Honda', 'model': 'Civic Type-R FL5', 'year': 2023, 'body': 'Hatchback', 'minVal': 2600000.0, 'maxVal': 3200000.0},
    {'brand': 'Audi', 'model': 'S3 Sportback Quattro', 'year': 2022, 'body': 'Hatchback', 'minVal': 2800000.0, 'maxVal': 3400000.0},
    {'brand': 'BMW', 'model': 'M135i xDrive', 'year': 2022, 'body': 'Hatchback', 'minVal': 2500000.0, 'maxVal': 3100000.0},
    {'brand': 'Mercedes-Benz', 'model': 'A45 AMG S 4MATIC+', 'year': 2021, 'body': 'Hatchback', 'minVal': 3200000.0, 'maxVal': 4100000.0},
    {'brand': 'Hyundai', 'model': 'i30 N Performance', 'year': 2023, 'body': 'Hatchback', 'minVal': 2000000.0, 'maxVal': 2500000.0},
    {'brand': 'Cupra', 'model': 'Formentor VZ5 2.5 TSI', 'year': 2023, 'body': 'SUV', 'minVal': 3100000.0, 'maxVal': 4150000.0},
  ];

  static const List<Map<String, dynamic>> _rareClassicJdmPool = [
    {'brand': 'BMW', 'model': 'E30 M3 Sport Evolution', 'year': 1990, 'body': 'Sedan', 'minVal': 4800000.0, 'maxVal': 6200000.0},
    {'brand': 'Ford', 'model': 'Mustang Fastback Boss 429', 'year': 1969, 'body': 'Klasik', 'minVal': 4400000.0, 'maxVal': 5800000.0},
    {'brand': 'Mercedes-Benz', 'model': '190E 2.5-16 Evolution II', 'year': 1990, 'body': 'Sedan', 'minVal': 5200000.0, 'maxVal': 6500000.0},
    {'brand': 'Toyota', 'model': 'Supra RZ Twin Turbo 2JZ', 'year': 1998, 'body': 'Spor', 'minVal': 4500000.0, 'maxVal': 6000000.0},
    {'brand': 'Mazda', 'model': 'RX-7 FD3S Spirit R Type-A', 'year': 2002, 'body': 'Spor', 'minVal': 4300000.0, 'maxVal': 5600000.0},
    {'brand': 'Nissan', 'model': 'Silvia S15 Spec-R Aero', 'year': 2001, 'body': 'Spor', 'minVal': 4200000.0, 'maxVal': 5100000.0},
    {'brand': 'Porsche', 'model': '911 Carrera 3.2 G-Model', 'year': 1988, 'body': 'Klasik', 'minVal': 4900000.0, 'maxVal': 6400000.0},
  ];

  static const List<Map<String, dynamic>> _luxuryExoticGtPool = [
    {'brand': 'Ferrari', 'model': '458 Italia V8', 'year': 2014, 'body': 'Spor', 'minVal': 7200000.0, 'maxVal': 9200000.0},
    {'brand': 'Lamborghini', 'model': 'Huracán LP610-4', 'year': 2017, 'body': 'Spor', 'minVal': 7800000.0, 'maxVal': 9800000.0},
    {'brand': 'Porsche', 'model': '911 GT3 RS Weissach', 'year': 2021, 'body': 'Spor', 'minVal': 8500000.0, 'maxVal': 10500000.0},
    {'brand': 'McLaren', 'model': '720S Performance Coupé', 'year': 2019, 'body': 'Spor', 'minVal': 7500000.0, 'maxVal': 9500000.0},
    {'brand': 'Audi', 'model': 'R8 V10 Performance Quattro', 'year': 2021, 'body': 'Spor', 'minVal': 7000000.0, 'maxVal': 8800000.0},
    {'brand': 'Aston Martin', 'model': 'DBS Superleggera V12', 'year': 2020, 'body': 'Spor', 'minVal': 8000000.0, 'maxVal': 10200000.0},
  ];

  static const List<Map<String, dynamic>> _legendaryHypercarPool = [
    {'brand': 'Bugatti', 'model': 'Chiron Pur Sport W16', 'year': 2021, 'body': 'Spor', 'minVal': 17000000.0, 'maxVal': 22000000.0},
    {'brand': 'Pagani', 'model': 'Zonda Cinque Coupé', 'year': 2010, 'body': 'Spor', 'minVal': 16000000.0, 'maxVal': 21000000.0},
    {'brand': 'Koenigsegg', 'model': 'Agera RS 1MW Edition', 'year': 2017, 'body': 'Spor', 'minVal': 15500000.0, 'maxVal': 20500000.0},
    {'brand': 'Ferrari', 'model': 'LaFerrari Hybrid V12', 'year': 2015, 'body': 'Spor', 'minVal': 14500000.0, 'maxVal': 19000000.0},
    {'brand': 'Porsche', 'model': '918 Spyder Weissach Package', 'year': 2015, 'body': 'Spor', 'minVal': 13500000.0, 'maxVal': 18000000.0},
  ];

  static const List<String> _colors = [
    '#0F172A', // Midnight Slate
    '#E11D48', // Crimson Red
    '#F59E0B', // Racing Amber
    '#10B981', // British Racing Emerald
    '#3B82F6', // Riviera Blue
    '#8B5CF6', // Purple Metallic
    '#FFFFFF', // Pearl White
    '#475569', // Nardo Grey
  ];

  /// Days remaining until the player can buy another mystery container.
  static int daysRemaining({required int lastPurchaseDay, required int currentDay}) {
    if (lastPurchaseDay <= 0) return 0;
    final diff = currentDay - lastPurchaseDay;
    if (diff >= cooldownDays) return 0;
    return cooldownDays - diff;
  }

  /// Whether the mystery container can be purchased on current day.
  static bool isAvailable({required int lastPurchaseDay, required int currentDay}) {
    return daysRemaining(lastPurchaseDay: lastPurchaseDay, currentDay: currentDay) == 0;
  }

  /// Rolls a random container drop with the calibrated 4-tier distribution.
  static MysteryContainerResult generateContainerDrop({
    required int currentDay,
    math.Random? random,
  }) {
    final rng = random ?? math.Random();
    final roll = rng.nextDouble(); // 0.0 .. 1.0

    MysteryContainerTier tier;
    List<Map<String, dynamic>> pool;

    if (roll < standardWeight) {
      // 0.00 .. 0.15 (15%)
      tier = MysteryContainerTier.standard;
      pool = _standardPool;
    } else if (roll < (standardWeight + rareWeight)) {
      // 0.15 .. 0.55 (40%)
      tier = MysteryContainerTier.rare;
      pool = _rareClassicJdmPool;
    } else if (roll < (standardWeight + rareWeight + exoticWeight)) {
      // 0.55 .. 0.85 (30%)
      tier = MysteryContainerTier.exotic;
      pool = _luxuryExoticGtPool;
    } else {
      // 0.85 .. 1.00 (15%)
      tier = MysteryContainerTier.legendaryHyper;
      pool = _legendaryHypercarPool;
    }

    final carTemplate = pool[rng.nextInt(pool.length)];
    final brand = carTemplate['brand'] as String;
    final modelName = carTemplate['model'] as String;
    final year = carTemplate['year'] as int;
    final bodyType = carTemplate['body'] as String;
    final minVal = carTemplate['minVal'] as double;
    final maxVal = carTemplate['maxVal'] as double;

    // Generate interpolated market value within range
    final marketValue = minVal + rng.nextDouble() * (maxVal - minVal);
    final roundedMarketValue = (marketValue / 10000).round() * 10000.0;

    final colorChoice = _colors[rng.nextInt(_colors.length)];
    final cityCode = (10 + rng.nextInt(72)).toString();
    final plateLetters = '${String.fromCharCode(65 + rng.nextInt(26))}${String.fromCharCode(65 + rng.nextInt(26))}';
    final plateDigits = (100 + rng.nextInt(900)).toString();
    final plateNumber = '$cityCode $plateLetters $plateDigits';

    // High condition because it's an imported/preserved container vehicle
    final mechanicalHealth = 92.0 + rng.nextDouble() * 8.0; // 92..100%
    final km = (tier == MysteryContainerTier.legendaryHyper)
        ? (1200 + rng.nextInt(8000))
        : (15000 + rng.nextInt(55000));

    final expertise = ExpertiseReport(
      engineCondition: mechanicalHealth,
      transmissionCondition: mechanicalHealth,
      tramerAmount: 0,
      mileage: km,
      isMileageTampered: false,
      bodyParts: {
        'Kaput': PartStatus.original,
        'Tavan': PartStatus.original,
        'Sol Ön Çamurluk': PartStatus.original,
        'Sağ Ön Çamurluk': PartStatus.original,
        'Sol Ön Kapı': PartStatus.original,
        'Sağ Ön Kapı': PartStatus.original,
        'Sol Arka Kapı': PartStatus.original,
        'Sağ Arka Kapı': PartStatus.original,
        'Sol Arka Çamurluk': PartStatus.original,
        'Sağ Arka Çamurluk': PartStatus.original,
        'Bagaj': PartStatus.original,
      },
      isEcuCleaned: true,
      isChassisAligned: true,
    );

    final car = CarModel(
      id: 'container_${DateTime.now().millisecondsSinceEpoch}_${rng.nextInt(10000)}',
      brand: brand,
      modelName: modelName,
      modelYear: year,
      bodyType: bodyType,
      colorHex: colorChoice,
      baseMarketValue: roundedMarketValue,
      currentPurchasePrice: containerCost,
      isRare: (tier == MysteryContainerTier.rare || tier == MysteryContainerTier.legendaryHyper),
      expertise: expertise,
      plateNumber: plateNumber,
      plateRarity: (tier == MysteryContainerTier.legendaryHyper) ? 'legendary' : 'standard',
      colorRarity: (tier == MysteryContainerTier.legendaryHyper) ? 'legendary' : 'standard',
      colorDisplayName: 'Konteyner Özel Boyası',
      isBlackMarket: true,
      blackMarketRiskPercent: 0, // Cleared at customs
      blackMarketSellerAlias: 'Liman Gümrük Masası',
      provenanceLog: [
        'Uluslararası limandan mühürlü gümrük konteyneri içinde ithal edildi.',
        'Konteyner açılışı $currentDay. günde gerçekleştirildi.',
      ],
    );

    final profitMargin = roundedMarketValue - containerCost;

    return MysteryContainerResult(
      car: car,
      tier: tier,
      costPaid: containerCost,
      estimatedValue: roundedMarketValue,
      profitMargin: profitMargin,
    );
  }
}
