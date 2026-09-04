import 'dart:math';
import '../../data/models/car_model.dart';
import '../../data/models/expertise_model.dart';
import '../../data/models/listing_model.dart';
import '../../data/models/vehicle_category.dart';

class VasitaTemplate {
  final VehicleCategory category;
  final String brand;
  final String modelName;
  final String bodyType;
  final double minBaseValue;
  final double maxBaseValue;
  final int minYear;
  final int maxYear;
  final List<String> typicalCities;

  const VasitaTemplate({
    required this.category,
    required this.brand,
    required this.modelName,
    required this.bodyType,
    required this.minBaseValue,
    required this.maxBaseValue,
    required this.minYear,
    required this.maxYear,
    required this.typicalCities,
  });
}

class VasitaMarketEngine {
  static final Random _random = Random();

  static const List<VasitaTemplate> templates = [
    // 1. Motosiklet (125.979)
    VasitaTemplate(
      category: VehicleCategory.motorcycle,
      brand: 'Yamaho',
      modelName: 'MT-07 Tork Canavarı',
      bodyType: 'Naked',
      minBaseValue: 320000,
      maxBaseValue: 450000,
      minYear: 2019,
      maxYear: 2024,
      typicalCities: ['İstanbul', 'İzmir', 'Antalya', 'Bursa'],
    ),
    VasitaTemplate(
      category: VehicleCategory.motorcycle,
      brand: 'Hondam',
      modelName: 'CBR 650R Kırmızı Şimşek',
      bodyType: 'Racing',
      minBaseValue: 420000,
      maxBaseValue: 560000,
      minYear: 2020,
      maxYear: 2024,
      typicalCities: ['İstanbul', 'Ankara', 'İzmir', 'Adana'],
    ),
    VasitaTemplate(
      category: VehicleCategory.motorcycle,
      brand: 'Bemeve',
      modelName: 'R 1250 GS Dağ Keçisi',
      bodyType: 'Enduro',
      minBaseValue: 850000,
      maxBaseValue: 1250000,
      minYear: 2020,
      maxYear: 2024,
      typicalCities: ['Ankara', 'İstanbul', 'Muğla'],
    ),
    VasitaTemplate(
      category: VehicleCategory.motorcycle,
      brand: 'Dukati',
      modelName: 'Panigale V4 İtalyan Aygırı',
      bodyType: 'Superbike',
      minBaseValue: 1100000,
      maxBaseValue: 1750000,
      minYear: 2021,
      maxYear: 2024,
      typicalCities: ['İstanbul', 'İzmir'],
    ),
    VasitaTemplate(
      category: VehicleCategory.motorcycle,
      brand: 'Kavazaki',
      modelName: 'Ninja ZX-6R Yeşil Dev',
      bodyType: 'Racing',
      minBaseValue: 580000,
      maxBaseValue: 890000,
      minYear: 2020,
      maxYear: 2024,
      typicalCities: ['Antalya', 'İstanbul', 'Bursa'],
    ),

    // 2. Minivan & Panelvan (75.097)
    VasitaTemplate(
      category: VehicleCategory.minivan,
      brand: 'Fort',
      modelName: 'Transit Custom İş Ortağı',
      bodyType: 'Panelvan',
      minBaseValue: 650000,
      maxBaseValue: 980000,
      minYear: 2018,
      maxYear: 2023,
      typicalCities: ['İstanbul', 'Kocaeli', 'Bursa', 'Gaziantep'],
    ),
    VasitaTemplate(
      category: VehicleCategory.minivan,
      brand: 'Vosgen',
      modelName: 'Caddy Maxi Aile Ticari',
      bodyType: 'Kombi',
      minBaseValue: 720000,
      maxBaseValue: 1150000,
      minYear: 2019,
      maxYear: 2024,
      typicalCities: ['Ankara', 'Konya', 'Kayseri', 'Samsun'],
    ),
    VasitaTemplate(
      category: VehicleCategory.minivan,
      brand: 'Merso',
      modelName: 'Vito Tourer 119 CDI VIP Makam',
      bodyType: 'VIP Minibüs',
      minBaseValue: 1350000,
      maxBaseValue: 2200000,
      minYear: 2020,
      maxYear: 2024,
      typicalCities: ['İstanbul', 'Antalya', 'Muğla', 'Trabzon'],
    ),
    VasitaTemplate(
      category: VehicleCategory.minivan,
      brand: 'Fiyasko',
      modelName: 'Doblo Maxi Enişte Kasa',
      bodyType: 'Kombi',
      minBaseValue: 420000,
      maxBaseValue: 680000,
      minYear: 2017,
      maxYear: 2022,
      typicalCities: ['Bursa', 'İzmir', 'Denizli', 'Adana'],
    ),

    // 3. Ticari Araçlar (48.944)
    VasitaTemplate(
      category: VehicleCategory.commercial,
      brand: 'Merso',
      modelName: 'Actros 1845 Yol Kaptanı',
      bodyType: 'Ağır Ticari',
      minBaseValue: 2800000,
      maxBaseValue: 4400000,
      minYear: 2018,
      maxYear: 2023,
      typicalCities: ['Mersin', 'Kayseri', 'Gaziantep', 'Kocaeli'],
    ),
    VasitaTemplate(
      category: VehicleCategory.commercial,
      brand: 'Skaniya',
      modelName: 'R 500 V8 Otoban Boğası',
      bodyType: 'Ağır Ticari Çekici',
      minBaseValue: 3100000,
      maxBaseValue: 4900000,
      minYear: 2019,
      maxYear: 2024,
      typicalCities: ['Bursa', 'Kocaeli', 'İzmir', 'Ankara'],
    ),
    VasitaTemplate(
      category: VehicleCategory.commercial,
      brand: 'İsuzi',
      modelName: 'NPR 10 Long Evden Eve',
      bodyType: 'Kamyon',
      minBaseValue: 1200000,
      maxBaseValue: 1850000,
      minYear: 2019,
      maxYear: 2023,
      typicalCities: ['İstanbul', 'Konya', 'Diyarbakır', 'Manisa'],
    ),
    VasitaTemplate(
      category: VehicleCategory.commercial,
      brand: 'İveko',
      modelName: 'Daily 35S15 Kamyonet',
      bodyType: 'Kamyonet',
      minBaseValue: 750000,
      maxBaseValue: 1100000,
      minYear: 2018,
      maxYear: 2022,
      typicalCities: ['Ankara', 'Bursa', 'Eskişehir', 'Tekirdağ'],
    ),
    VasitaTemplate(
      category: VehicleCategory.commercial,
      brand: 'Çelikvolvo',
      modelName: 'FH 540 Demir Yürek',
      bodyType: 'Ağır Ticari Çekici',
      minBaseValue: 3500000,
      maxBaseValue: 5600000,
      minYear: 2020,
      maxYear: 2024,
      typicalCities: ['Mersin', 'İstanbul', 'İzmir'],
    ),

    // 4. Kiralık Araçlar (10.539)
    VasitaTemplate(
      category: VehicleCategory.rentalFleet,
      brand: 'Reno',
      modelName: 'Megane Sedan Joy Şirket Aracı',
      bodyType: 'Filo Sedan',
      minBaseValue: 680000,
      maxBaseValue: 880000,
      minYear: 2021,
      maxYear: 2024,
      typicalCities: ['Antalya', 'İstanbul', 'İzmir', 'Muğla'],
    ),
    VasitaTemplate(
      category: VehicleCategory.rentalFleet,
      brand: 'Fiyasko',
      modelName: 'Egea Easy 1.4 Filo Paketi',
      bodyType: 'Filo Sedan',
      minBaseValue: 520000,
      maxBaseValue: 710000,
      minYear: 2021,
      maxYear: 2024,
      typicalCities: ['Adana', 'Trabzon', 'Ankara', 'Gaziantep'],
    ),
    VasitaTemplate(
      category: VehicleCategory.rentalFleet,
      brand: 'Toyo',
      modelName: 'Korola Hibrit Filo Müdürü',
      bodyType: 'Filo Sedan',
      minBaseValue: 850000,
      maxBaseValue: 1150000,
      minYear: 2021,
      maxYear: 2024,
      typicalCities: ['İstanbul', 'Ankara', 'İzmir'],
    ),

    // 5. Deniz Araçları (10.929)
    VasitaTemplate(
      category: VehicleCategory.marine,
      brand: 'Su-Doo',
      modelName: 'Spark Sahil Fırtınası Jet Ski',
      bodyType: 'Su Jeti',
      minBaseValue: 480000,
      maxBaseValue: 720000,
      minYear: 2021,
      maxYear: 2024,
      typicalCities: ['Bodrum', 'Marmaris', 'Çeşme', 'Antalya'],
    ),
    VasitaTemplate(
      category: VehicleCategory.marine,
      brand: 'Janu Marine',
      modelName: 'Cap Camarat 7.5 Balıkçı Sürat Teknesi',
      bodyType: 'Sürat Teknesi',
      minBaseValue: 2400000,
      maxBaseValue: 3900000,
      minYear: 2019,
      maxYear: 2023,
      typicalCities: ['Göcek', 'Bodrum', 'İstanbul', 'Kuşadası'],
    ),
    VasitaTemplate(
      category: VehicleCategory.marine,
      brand: 'Riva Lüks',
      modelName: 'Rivamare 38 Özel Motoryat',
      bodyType: 'Motoryat',
      minBaseValue: 12000000,
      maxBaseValue: 22000000,
      minYear: 2020,
      maxYear: 2024,
      typicalCities: ['Bodrum', 'İstanbul', 'Göcek'],
    ),
    VasitaTemplate(
      category: VehicleCategory.marine,
      brand: 'Aksopar',
      modelName: '37 Sun-Top Açık Deniz Canavarı',
      bodyType: 'Sürat Teknesi',
      minBaseValue: 6500000,
      maxBaseValue: 9800000,
      minYear: 2021,
      maxYear: 2024,
      typicalCities: ['Marmaris', 'Bodrum', 'Göcek'],
    ),

    // 6. Hasarlı Araçlar (4.391)
    VasitaTemplate(
      category: VehicleCategory.damaged,
      brand: 'Bemeve',
      modelName: '320i M Kaporta Masraflı',
      bodyType: 'Sedan',
      minBaseValue: 1400000,
      maxBaseValue: 2100000,
      minYear: 2020,
      maxYear: 2023,
      typicalCities: ['Ankara', 'İstanbul', 'Gaziantep', 'Konya'],
    ),
    VasitaTemplate(
      category: VehicleCategory.damaged,
      brand: 'Vosgen',
      modelName: 'Golf R-Line Önden Tıklamalı',
      bodyType: 'Hatchback',
      minBaseValue: 1100000,
      maxBaseValue: 1600000,
      minYear: 2021,
      maxYear: 2024,
      typicalCities: ['Bursa', 'İzmir', 'Kayseri', 'Kocaeli'],
    ),
    VasitaTemplate(
      category: VehicleCategory.damaged,
      brand: 'Merso',
      modelName: 'C200d Sigorta Şişirmesi Hasarlı',
      bodyType: 'Sedan',
      minBaseValue: 1350000,
      maxBaseValue: 1950000,
      minYear: 2019,
      maxYear: 2023,
      typicalCities: ['İstanbul', 'Adana', 'Antalya'],
    ),

    // 7. Karavan (5.814)
    VasitaTemplate(
      category: VehicleCategory.caravan,
      brand: 'Adriana',
      modelName: 'Matrix 670 SL 4 Mevsim Motokaravan',
      bodyType: 'Motokaravan',
      minBaseValue: 2600000,
      maxBaseValue: 3800000,
      minYear: 2020,
      maxYear: 2024,
      typicalCities: ['İzmir', 'Antalya', 'Muğla', 'Bursa'],
    ),
    VasitaTemplate(
      category: VehicleCategory.caravan,
      brand: 'Haymer',
      modelName: 'MasterLine 780 Entegre Saray',
      bodyType: 'Entegre Karavan',
      minBaseValue: 4500000,
      maxBaseValue: 7200000,
      minYear: 2021,
      maxYear: 2024,
      typicalCities: ['İstanbul', 'Muğla', 'Antalya'],
    ),
    VasitaTemplate(
      category: VehicleCategory.caravan,
      brand: 'Kınavs',
      modelName: 'Gezgin Çekme Karavan Yayla Paketi',
      bodyType: 'Çekme Karavan',
      minBaseValue: 750000,
      maxBaseValue: 1250000,
      minYear: 2020,
      maxYear: 2024,
      typicalCities: ['Bolu', 'Trabzon', 'Ankara', 'Çanakkale'],
    ),

    // 8. Klasik Araçlar (1.848)
    VasitaTemplate(
      category: VehicleCategory.classic,
      brand: 'Fort',
      modelName: 'Mustang Fastback 1969 V8 Amerikan Rüyası',
      bodyType: 'Klasik Spor',
      minBaseValue: 3200000,
      maxBaseValue: 5500000,
      minYear: 1969,
      maxYear: 1969,
      typicalCities: ['İstanbul', 'Ankara', 'İzmir'],
    ),
    VasitaTemplate(
      category: VehicleCategory.classic,
      brand: 'Merso',
      modelName: '280 SL Pagoda 1970 Hakiki Nostalji',
      bodyType: 'Klasik Cabrio',
      minBaseValue: 4800000,
      maxBaseValue: 8200000,
      minYear: 1970,
      maxYear: 1970,
      typicalCities: ['İstanbul', 'Bodrum'],
    ),
    VasitaTemplate(
      category: VehicleCategory.classic,
      brand: 'Vosgen',
      modelName: 'Kaplumbağa 1303 1974 Vosvos',
      bodyType: 'Klasik Nostalji',
      minBaseValue: 350000,
      maxBaseValue: 650000,
      minYear: 1974,
      maxYear: 1974,
      typicalCities: ['Eskişehir', 'İzmir', 'İstanbul'],
    ),

    // 9. Hava Araçları (13)
    VasitaTemplate(
      category: VehicleCategory.aircraft,
      brand: 'Cesna',
      modelName: 'Gökyel 172 PPL Eğitim Uçağı',
      bodyType: 'Piston Uçak',
      minBaseValue: 8500000,
      maxBaseValue: 14000000,
      minYear: 2018,
      maxYear: 2023,
      typicalCities: ['İstanbul', 'Ankara', 'İzmir', 'Antalya'],
    ),
    VasitaTemplate(
      category: VehicleCategory.aircraft,
      brand: 'Sirus',
      modelName: 'SR22 Paraşütlü Özel Uçak',
      bodyType: 'Piston Uçak',
      minBaseValue: 16000000,
      maxBaseValue: 26000000,
      minYear: 2019,
      maxYear: 2024,
      typicalCities: ['İstanbul', 'Bodrum', 'Ankara'],
    ),
    VasitaTemplate(
      category: VehicleCategory.aircraft,
      brand: 'Bel Helikopter',
      modelName: '206L LongRanger VIP Helikopter',
      bodyType: 'Helikopter',
      minBaseValue: 22000000,
      maxBaseValue: 36000000,
      minYear: 2019,
      maxYear: 2024,
      typicalCities: ['İstanbul', 'Bodrum', 'Göcek'],
    ),

    // 10. ATV (3.217)
    VasitaTemplate(
      category: VehicleCategory.atv,
      brand: 'Kanam',
      modelName: 'Outlander MAX XT 1000 Çamur Canavarı',
      bodyType: 'Arazi 4x4',
      minBaseValue: 540000,
      maxBaseValue: 790000,
      minYear: 2021,
      maxYear: 2024,
      typicalCities: ['Antalya', 'Bolu', 'Rize', 'Muğla'],
    ),
    VasitaTemplate(
      category: VehicleCategory.atv,
      brand: 'Polaris Dağkurdu',
      modelName: 'Sportsman 570 Çift Çeker',
      bodyType: 'Arazi 4x4',
      minBaseValue: 420000,
      maxBaseValue: 620000,
      minYear: 2020,
      maxYear: 2024,
      typicalCities: ['Bursa', 'Trabzon', 'Kastamonu'],
    ),

    // 11. UTV (443)
    VasitaTemplate(
      category: VehicleCategory.utv,
      brand: 'Polaris Dağkurdu',
      modelName: 'RZR Pro XP Ultimate Çöl Roketi',
      bodyType: 'Side-by-Side',
      minBaseValue: 1200000,
      maxBaseValue: 1750000,
      minYear: 2022,
      maxYear: 2024,
      typicalCities: ['Antalya', 'Muğla', 'İzmir', 'Kapadokya'],
    ),
    VasitaTemplate(
      category: VehicleCategory.utv,
      brand: 'Kanam',
      modelName: 'Maverick X3 Turbo Kum Fırtınası',
      bodyType: 'Side-by-Side',
      minBaseValue: 1450000,
      maxBaseValue: 2100000,
      minYear: 2022,
      maxYear: 2024,
      typicalCities: ['Muğla', 'Antalya', 'Bodrum'],
    ),
  ];

  static const List<String> sellerFirstNames = [
    'Kemal', 'Serdar', 'Cemil', 'Deniz', 'Hakan',
    'Volkan', 'Kaan', 'Murat', 'Barış', 'Eren',
    'Alper', 'Okan', 'Tufan', 'Metin', 'Zafer',
  ];

  static const List<String> sellerLastNames = [
    'Kaptan', 'Reis', 'Demir', 'Yıldız', 'Koç',
    'Yılmaz', 'Aksoy', 'Öztürk', 'Kurt', 'Şahin',
    'Güneş', 'Acar', 'Soylu', 'Çetin', 'Karadağ',
  ];

  /// Generate dynamic listings pool for alternative vehicles
  static List<ListingModel> generateListings({
    int count = 20,
    VehicleCategory? categoryFilter,
    int playerLevel = 3,
  }) {
    final List<ListingModel> listings = [];
    final availableTemplates = categoryFilter == null
        ? templates
        : templates.where((t) => t.category == categoryFilter).toList();

    if (availableTemplates.isEmpty) return [];

    for (int i = 0; i < count; i++) {
      final template = _selectWeightedTemplate(availableTemplates);
      final listing = _generateSingleListing(template, playerLevel);
      listings.add(listing);
    }

    return listings;
  }

  static VasitaTemplate _selectWeightedTemplate(List<VasitaTemplate> pool) {
    if (pool.length == 1) return pool.first;

    // Weight selection based on catalog counts
    int totalCatalogWeight = 0;
    for (final t in pool) {
      // Aircraft has very low occurrence (13 in catalog), damp down so it is an epic find
      final weight = t.category == VehicleCategory.aircraft
          ? 1
          : (t.category.catalogCount ~/ 1000).clamp(2, 60);
      totalCatalogWeight += weight;
    }

    int roll = _random.nextInt(max(1, totalCatalogWeight));
    int cumulative = 0;
    for (final t in pool) {
      final weight = t.category == VehicleCategory.aircraft
          ? 1
          : (t.category.catalogCount ~/ 1000).clamp(2, 60);
      cumulative += weight;
      if (roll < cumulative) {
        return t;
      }
    }
    return pool[_random.nextInt(pool.length)];
  }

  static ListingModel _generateSingleListing(VasitaTemplate t, int playerLevel) {
    final year = t.minYear == t.maxYear
        ? t.minYear
        : t.minYear + _random.nextInt(t.maxYear - t.minYear + 1);

    final rawValue = t.minBaseValue +
        _random.nextDouble() * (t.maxBaseValue - t.minBaseValue);
    final baseMarketValue = (rawValue / 10000).round() * 10000.0;

    final isDamagedCategory = t.category == VehicleCategory.damaged;
    final isAircraft = t.category == VehicleCategory.aircraft;

    // Asking price logic
    double askingMultiplier;
    if (isDamagedCategory) {
      // Heavily discounted: 45% - 65% of market value
      askingMultiplier = 0.45 + (_random.nextDouble() * 0.20);
    } else if (isAircraft) {
      // Prestigious: 95% - 105%
      askingMultiplier = 0.95 + (_random.nextDouble() * 0.10);
    } else {
      // Standard: 88% - 102%
      askingMultiplier = 0.88 + (_random.nextDouble() * 0.14);
    }

    final askingPrice = ((baseMarketValue * askingMultiplier) / 5000).round() * 5000.0;

    // Mileage
    int mileage;
    if (isAircraft) {
      mileage = 400 + _random.nextInt(1800); // Flight hours
    } else if (t.category == VehicleCategory.marine) {
      mileage = 50 + _random.nextInt(350); // Engine hours
    } else if (isDamagedCategory) {
      mileage = 15000 + _random.nextInt(60000);
    } else if (t.category == VehicleCategory.classic) {
      mileage = 45000 + _random.nextInt(95000);
    } else {
      mileage = 8000 + _random.nextInt(75000);
    }

    // Engine and Transmission Conditions
    double engineCond;
    double transCond;
    double tramer;

    if (isDamagedCategory) {
      engineCond = 45.0 + _random.nextDouble() * 30.0;
      transCond = 50.0 + _random.nextDouble() * 30.0;
      tramer = 120000.0 + _random.nextInt(280000);
    } else if (isAircraft) {
      engineCond = 95.0 + _random.nextDouble() * 5.0;
      transCond = 96.0 + _random.nextDouble() * 4.0;
      tramer = 0.0;
    } else {
      engineCond = 75.0 + _random.nextDouble() * 24.0;
      transCond = 78.0 + _random.nextDouble() * 21.0;
      tramer = _random.nextDouble() < 0.4 ? 0.0 : 5000.0 + _random.nextInt(35000);
    }

    final expertise = ExpertiseReport(
      engineCondition: engineCond.clamp(10.0, 100.0),
      transmissionCondition: transCond.clamp(10.0, 100.0),
      tramerAmount: tramer.round(),
      mileage: mileage,
      isMileageTampered: false,
      bodyParts: isDamagedCategory
          ? {
              'frontBumper': PartStatus.changed,
              'hood': PartStatus.painted,
              'frontFenderRight': PartStatus.painted,
            }
          : {},
    );

    final firstName = sellerFirstNames[_random.nextInt(sellerFirstNames.length)];
    final lastName = sellerLastNames[_random.nextInt(sellerLastNames.length)];
    final city = t.typicalCities[_random.nextInt(t.typicalCities.length)];

    final car = CarModel(
      id: 'vasita_${t.category.name}_${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(999)}',
      brand: t.brand,
      modelName: t.modelName,
      modelYear: year,
      bodyType: t.bodyType,
      colorHex: _getCategoryDefaultColorHex(t.category),
      baseMarketValue: baseMarketValue,
      currentPurchasePrice: askingPrice,
      isRare: t.category == VehicleCategory.aircraft ||
          t.category == VehicleCategory.classic ||
          t.category == VehicleCategory.utv,
      expertise: expertise,
      vehicleCategory: t.category,
    );

    final title = '${t.brand} ${t.modelName} • $year';
    final desc = _generateCategoryDescription(t.category, t.brand, t.modelName, city);
    final trait = _getCategorySellerTrait(t.category);

    return ListingModel(
      id: 'listing_${car.id}',
      car: car,
      sellerName: '$firstName $lastName',
      sellerTrait: trait,
      sellerCity: city,
      title: title,
      description: desc,
      askingPrice: askingPrice,
      createdAt: DateTime.now().subtract(Duration(hours: _random.nextInt(72))),
    );
  }

  static String _getCategorySellerTrait(VehicleCategory cat) {
    switch (cat) {
      case VehicleCategory.marine:
        return 'Deniz Kaptanı';
      case VehicleCategory.aircraft:
        return 'Özel Pilot';
      case VehicleCategory.motorcycle:
        return 'İki Teker Tutkunu';
      case VehicleCategory.minivan:
        return 'Esnaf Enişte';
      case VehicleCategory.commercial:
        return 'Lojistik Filosu';
      case VehicleCategory.rentalFleet:
        return 'Kurumsal Filo Yetkilisi';
      case VehicleCategory.damaged:
        return 'Sigorta İhalesi';
      case VehicleCategory.caravan:
        return 'Doğa Gezgini';
      case VehicleCategory.classic:
        return 'Klasik Koleksiyoneri';
      case VehicleCategory.atv:
      case VehicleCategory.utv:
        return 'Off-Road Sporcusu';
      case VehicleCategory.car:
        return 'Sahibinden Satıcı';
    }
  }

  static String _getCategoryDefaultColorHex(VehicleCategory cat) {
    switch (cat) {
      case VehicleCategory.marine:
        return '0xFF0284C7';
      case VehicleCategory.aircraft:
        return '0xFFE2E8F0';
      case VehicleCategory.motorcycle:
        return '0xFFDC2626';
      case VehicleCategory.commercial:
        return '0xFF475569';
      case VehicleCategory.caravan:
        return '0xFF16A34A';
      case VehicleCategory.classic:
        return '0xFFB91C1C';
      case VehicleCategory.atv:
      case VehicleCategory.utv:
        return '0xFFD97706';
      default:
        return '0xFF334155';
    }
  }

  static String _generateCategoryDescription(
      VehicleCategory cat, String brand, String model, String city) {
    final rand = _random.nextInt(4);
    switch (cat) {
      case VehicleCategory.marine:
        final stories = [
          '$city marinasında palamar kirası artışı ve üst boy motoryata geçiş sebebiyle satılıktır. Zehirli boya ve kuyruk bakımları yeni.',
          'Sadece yaz aylarında ailemizle koylarda keyif için kullanıldı. Kışın kapalı hangarda korundu, seyir cihazları eksiksiz.',
          'Motor saatleri orijinaldir. Palamar ve çapa tertibatı taze sıfırlandı. Sezona masrafsız, marşa bas seyire çık.',
          'Emeklilik hayaliyle almıştık, sağlık sebepleriyle denize çıkamadığımız için devrediyoruz. Sintine ve osmoz testi temiz.',
        ];
        return stories[rand];

      case VehicleCategory.aircraft:
        final stories = [
          'PPL hususi pilot lisans uçuş saatimi doldurdum. Ticari CPL aşamasına geçtiğim için özel uçağımı devrediyorum.',
          'Yıllık ARC uçuşa elverişlilik sertifikası yeni onaylandı. Garmin aviyonik dokunmatik ekranlar takılı, hangar teslim.',
          'Ortaklık feshinden dolayı satılık. Motor revizyonuna daha 800 uçuş saati var, bakımları yetkili teknisyen onaylı.',
          'Gökyüzünün en güvenli piston makinesi. Her uçuş sonrası hangar bakımı yapılmış, logbook kayıtları eksiksiz.',
        ];
        return stories[rand];

      case VehicleCategory.motorcycle:
        final stories = [
          'Evlendik, iki tekere veda vakti geldi. Kapalı garajda branda altında muhafaza edildi, zincir dişli ve akü sıfır.',
          'A2 ehliyetten A sınıfına geçiyorum, 1000cc makine alacağım için satılık. Teker vs yapılmamış ciğerli motordur.',
          'Yurt dışı tayini sebebiyle acil satılık. Düşmesi kalkması trameri yoktur. Yanında koruma demirleri hediye.',
          'Sadece hafta sonları boğazda kahve içmeye gidildi. Yağmur çamur görmedi, lastikler sıfır ayarında.',
        ];
        return stories[rand];

      case VehicleCategory.minivan:
        final stories = [
          'Dükkanı kapattığımız için boşa çıktı. Ağır yük görmedi, mobilya ve tekstil taşındı. Bakımları günü gününe yapıldı.',
          'İki sene şehir içi kargo dağıtımında tek elden kullanıldı. Motorunda üfleme duman atma kesinlikle yoktur.',
          'Aile aracı olarak kullanıldı, arkasına özel VIP koltuk yapıldı. Bagajı devasa, piknik ve yayla gördü.',
          'Büyük kasaya geçeceğimiz için satılık. Yağ ve filtre bakımları yeni yapılmış, masrafsız ekmek teknesi.',
        ];
        return stories[rand];

      case VehicleCategory.commercial:
        final stories = [
          'Uluslararası hatta çalışan aracımız filo yenileme sebebiyle satılıktır. Retarder ve webasto faal, lastikler yüzde 90.',
          'Meyve sebze halinde boş dolu çalıştı, tonaj basılmadı. Makaslar diri, muayenesi bu ay yeni yapıldı.',
          'Şoför bulamadığımız için aracı parkta yatırmak istemiyoruz. Mazotu koy işe başla ekmek teknesi.',
          'Fabrika servis taşımacılığından çıkma, şantiyeye hiç girmedi. Diferansiyel ve şanzıman kusursuz.',
        ];
        return stories[rand];

      case VehicleCategory.rentalFleet:
        final stories = [
          '3 yıllık kurumsal operasyonel kiralama sözleşmesi bitti. Tüm periyodik bakımları yetkili serviste yapıldı.',
          'Şirket bölge müdürleri tarafından uzun yolda kullanıldı. Orijinal kilometre ve servis dökümleri mevcut.',
          'Turizm sezonu bittiği için filomuzu gençleştiriyoruz. Detaylı oto kuaför ve pasta cilası yeni yapıldı.',
          'Filo çıkması diri araç. Şirket muhasebesine tam fatura kesilecektir, yürüyen aksamı masrafsızdır.',
        ];
        return stories[rand];

      case VehicleCategory.damaged:
        final stories = [
          'Kavşakta sağ önden hafif temas yaşandı. Radyatör ve şaseler temiz, sadece kaporta ve far işçiliği var.',
          'Kaskodan para almak için sigorta şişirmesi ağır kayıt girilmiş. Yürüründe motorunda tık ses yoktur.',
          'Otoparktan çıkarken kolona sürtüldü. Sanayide tanıdığı usta olan için yüksek kâr bırakacak kelepir.',
          'Düşük süratte önden kazalı. Hava yastıkları açmamış, toparlandığında piyasa değerinin çok üstünde kazandırır.',
        ];
        return stories[rand];

      case VehicleCategory.caravan:
        final stories = [
          'Eşimle 81 il Türkiye turumuzu tamamladık, hevesimizi aldık. Güneş panelleri, lityum akü ve Webasto aktif çalışıyor.',
          'Bebek dünyaya geldiği için kamp hayatına 2 yıl ara veriyoruz. İzolasyonu taşyünü, kışın eksi 15 derecede sıcacık.',
          'Off-grid donanımlı, hidrofor, kasetli tuvalet ve dış duş eksiksiz. Ruhsatta M1 karavan işli, muayenesi tam.',
          'Özenle tasarlanmış marin kontra mobilyalar, temiz su deposu ve tente dahil anahtar teslim kaçış aracı.',
        ];
        return stories[rand];

      case VehicleCategory.classic:
        final stories = [
          '3 yıl süren titiz restorasyon projemiz bitti. Tüm krom çıtaları ve parçaları orijinal getirildi.',
          'Kapalı garajımızın kentsel dönüşüme girmesi sebebiyle yer darlığından satmak zorundayım. Hakiki koleksiyonluk.',
          'Babamın 40 yıllık gözbebeği. Yağmur çamur görmedi, sadece pazar günleri keyif turu atıldı. Motor saati gibi.',
          'Fabrika çıkış kondisyonunda korunmuş nadide parça. Çürük çarık yoktur, kapalı garajda örtü altında bekliyor.',
        ];
        return stories[rand];

      case VehicleCategory.atv:
      case VehicleCategory.utv:
        final stories = [
          'Yazlık villamızı sattığımız için boşa çıktı. Plakalı ve ruhsatlı, B ehliyet şehirde ve arazide kullanabilir.',
          'Off-road ekibimizle sadece kuru dere yatağında gezdik, bataklığa sokulmadı. Vinç ve çeki demiri hediye verilecektir.',
          'Hafta sonu yayla turlarında kullanıldı, kayış ve varyatör bakımları yeni. Çift çeker defransiyel kilidi faal.',
          'Arazi canavarı. Sıfır ayarında arazi lastikleri takılı, torku mükemmel ve römorkuyla birlikte devredilecektir.',
        ];
        return stories[rand];

      case VehicleCategory.car:
        return 'İlk sahibinden titizlikle kullanılmış, tüm bakımları zamanında yapılmış masrafsız binek araç.';
    }
  }
}
