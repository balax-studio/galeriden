import 'dart:math';
import '../../data/models/car_model.dart';
import '../../data/models/expertise_model.dart';

class ConsignmentEngine {
  static final Random _random = Random();

  /// Contextual NPC owners categorized by the 8 Dealership Branch Tiers (§4.6.1)
  static const Map<int, List<Map<String, dynamic>>> _tierOwners = {
    // --- Tier 1: Kaldırım Başı Ayakçı Galerisi ---
    1: [
      {
        'name': 'Taksici Niyazi Dayı',
        'trait': 'Ticari plakaya geçeceğim için eski emektarı acil satıyorum.',
        'rate': 0.22,
      },
      {
        'name': 'Pazarcı Halil Usta',
        'trait': 'Meyve sebze taşıdığım arabayı bıraktım, nakit lazım.',
        'rate': 0.20,
      },
      {
        'name': 'Emekli Şükrü Bey',
        'trait': 'Yaşlandım artık süremiyorum, garajda çürümesin satın.',
        'rate': 0.18,
      },
    ],

    // --- Tier 2: Mahalle Tipi Açık Oto Galeri ---
    2: [
      {
        'name': 'Öğretmen Selim Hoca',
        'trait': 'Model yükselteceğim, temiz aile arabamı galerinize emanet ediyorum.',
        'rate': 0.18,
      },
      {
        'name': 'Bankacı Merve Hanım',
        'trait': 'Ev peşinatı için az yakan hatchback aracımı konsinye verdim.',
        'rate': 0.16,
      },
      {
        'name': 'Esnaf Lokantacı Bekir',
        'trait': 'Toptancı borçları için temiz arabamı emanete bıraktım.',
        'rate': 0.17,
      },
    ],

    // --- Tier 3: Sanayi Sitesi Esnaf Galerisi ---
    3: [
      {
        'name': 'Torna Ustası Hayati',
        'trait': 'Sanayide gözüm gibi baktığım ticari panelvanımı bırakıyorum.',
        'rate': 0.16,
      },
      {
        'name': 'Nakliyeci Murat',
        'trait': 'Filo yeniliyoruz, diri hafif ticariyi galerinize emanet ettim.',
        'rate': 0.15,
      },
      {
        'name': 'Tesisatçı Erhan',
        'trait': 'İşleri büyüttük, emektar hafif ticariyi satın komisyonunuzu alın.',
        'rate': 0.16,
      },
    ],

    // --- Tier 4: Cadde Üstü Butik Oto Galeri ---
    4: [
      {
        'name': 'Yazılımcı Bora',
        'trait': 'Yurt dışına taşınıyorum, dolu paket hatchback arabamı sergileyin.',
        'rate': 0.14,
      },
      {
        'name': 'Mimar Aslı Hanım',
        'trait': 'Yeni SUV siparişim geldi, bakımlı cadde arabamı satınız.',
        'rate': 0.13,
      },
      {
        'name': 'Doktor Cihan Bey',
        'trait': 'Nöbetlerden satmaya vaktim yok, hastane otoparkında yatmasın.',
        'rate': 0.15,
      },
    ],

    // --- Tier 5: Oto Center Kurumsal Galeri ---
    5: [
      {
        'name': 'Müteahhit Rıfat Bey',
        'trait': 'Şantiye denetimlerinde bindiğim kurumsal Passat\'ı bırakıyorum.',
        'rate': 0.13,
      },
      {
        'name': 'Filo Müdürü Zafer',
        'trait': 'Şirket üst yönetiminden dönen temiz D-Segment aracı veriyoruz.',
        'rate': 0.12,
      },
      {
        'name': 'Eczacı Nazan Hanım',
        'trait': 'Yeni araç aldım, tertemiz kurumsal makam aracımı emanet ediyorum.',
        'rate': 0.14,
      },
    ],

    // --- Tier 6: Premium Cam Showroom Plaza ---
    6: [
      {
        'name': 'Avukat Tarık Çetin',
        'trait': 'Duruşmalar yoğun, makam arabam showroomunuzun camında parlasın.',
        'rate': 0.12,
      },
      {
        'name': 'Sanayici Tevfik Bey',
        'trait': 'Fabrika garajındaki lüks sedanımı vitrininize emanet ettim.',
        'rate': 0.11,
      },
      {
        'name': 'Borsa Yatırımcısı Efe',
        'trait': 'Yeni fon açılışı için lüks coupe aracımı konsinye bıraktım.',
        'rate': 0.13,
      },
    ],

    // --- Tier 7: Lüks Koleksiyoner VIP Galeri ---
    7: [
      {
        'name': 'Koleksiyoner Haldun Bey',
        'trait': 'Koleksiyonumu seyreltiyorum, garaj sakini özel VIP aracı sergileyin.',
        'rate': 0.11,
      },
      {
        'name': 'Armatör Selçuk Bey',
        'trait': 'Yat limanında duracağına VIP galerinizde alıcısını bulsun.',
        'rate': 0.10,
      },
      {
        'name': 'Pop Yıldızı Arya',
        'trait': 'Klip çekimlerinde kullandığım lüks SUV aracımı emin ellere bırakıyorum.',
        'rate': 0.12,
      },
    ],

    // --- Tier 8: Mega Otomotiv Holding Plazası ---
    8: [
      {
        'name': 'Holding Yön. Kur. Başkanı Kenan Bey',
        'trait': 'VIP zırhlı ultra prestij makam aracımı holding plazanızda satışa sunun.',
        'rate': 0.10,
      },
      {
        'name': 'Uluslararası Diplomat Alistair',
        'trait': 'Görev sürem bitti, diplomatik statüdeki ultra egzotik aracı bırakıyorum.',
        'rate': 0.09,
      },
      {
        'name': 'İş Adamı Bedri Vural',
        'trait': 'Özel sipariş süper spor aracım holding plazanızın baş köşesinde dursun.',
        'rate': 0.11,
      },
    ],
  };

  /// Tier-specific vehicle templates for authentic car generation
  static const Map<int, List<Map<String, dynamic>>> _tierCarTemplates = {
    1: [
      {'brand': 'Tofaşk', 'model': 'Şahin-S Yanlama', 'body': 'Sedan', 'minVal': 55000.0, 'maxVal': 95000.0, 'minYr': 1993, 'maxYr': 2001},
      {'brand': 'Tofaşk', 'model': 'Doğan Görünümlü SLX', 'body': 'Sedan', 'minVal': 65000.0, 'maxVal': 110000.0, 'minYr': 1994, 'maxYr': 2002},
      {'brand': 'Reno', 'model': 'Broad-Vey Efsane', 'body': 'Sedan', 'minVal': 50000.0, 'maxVal': 85000.0, 'minYr': 1991, 'maxYr': 1998},
      {'brand': 'Tofaşk', 'model': 'Kartal Bagajlı', 'body': 'Station Wagon', 'minVal': 60000.0, 'maxVal': 105000.0, 'minYr': 1992, 'maxYr': 2000},
    ],
    2: [
      {'brand': 'Fiyaka', 'model': 'Egea Ezber Bozan', 'body': 'Sedan', 'minVal': 220000.0, 'maxVal': 340000.0, 'minYr': 2016, 'maxYr': 2020},
      {'brand': 'Reno', 'model': 'Klio Şehir Çıtırı', 'body': 'Hatchback', 'minVal': 200000.0, 'maxVal': 320000.0, 'minYr': 2014, 'maxYr': 2019},
      {'brand': 'Opelyus', 'model': 'Korsa Genç İşi', 'body': 'Hatchback', 'minVal': 210000.0, 'maxVal': 330000.0, 'minYr': 2013, 'maxYr': 2018},
      {'brand': 'Toyotacı', 'model': 'Yaris Pratik', 'body': 'Hatchback', 'minVal': 240000.0, 'maxVal': 360000.0, 'minYr': 2015, 'maxYr': 2020},
    ],
    3: [
      {'brand': 'Fiyaka', 'model': 'Doblo Enişte Paketi', 'body': 'Ticari Van', 'minVal': 380000.0, 'maxVal': 580000.0, 'minYr': 2015, 'maxYr': 2021},
      {'brand': 'Vosgen', 'model': 'Kedi Van Caddy', 'body': 'Ticari Van', 'minVal': 450000.0, 'maxVal': 680000.0, 'minYr': 2016, 'maxYr': 2022},
      {'brand': 'Fordist', 'model': 'Kurye Ticari Fırtına', 'body': 'Ticari Van', 'minVal': 360000.0, 'maxVal': 540000.0, 'minYr': 2017, 'maxYr': 2022},
      {'brand': 'Vosgen', 'model': 'Trans-Portakal Van', 'body': 'Minibüs', 'minVal': 520000.0, 'maxVal': 750000.0, 'minYr': 2014, 'maxYr': 2020},
    ],
    4: [
      {'brand': 'Vosgen', 'model': 'Golf Sekiz R-Line', 'body': 'Hatchback', 'minVal': 850000.0, 'maxVal': 1350000.0, 'minYr': 2018, 'maxYr': 2023},
      {'brand': 'Hondacı', 'model': 'Sivik VTEC Kral', 'body': 'Sedan', 'minVal': 780000.0, 'maxVal': 1250000.0, 'minYr': 2017, 'maxYr': 2022},
      {'brand': 'Toyotacı', 'model': 'Korolla Ölümsüz', 'body': 'Sedan', 'minVal': 820000.0, 'maxVal': 1280000.0, 'minYr': 2019, 'maxYr': 2023},
      {'brand': 'Opelyus', 'model': 'Astra Dinamik Turbo', 'body': 'Hatchback', 'minVal': 750000.0, 'maxVal': 1180000.0, 'minYr': 2018, 'maxYr': 2022},
    ],
    5: [
      {'brand': 'Vosgen', 'model': 'Pas-At 2.0 TDi Aşiret', 'body': 'Sedan', 'minVal': 1600000.0, 'maxVal': 2600000.0, 'minYr': 2018, 'maxYr': 2023},
      {'brand': 'Toyotacı', 'model': 'Korolla Kros SUV', 'body': 'SUV', 'minVal': 1500000.0, 'maxVal': 2400000.0, 'minYr': 2020, 'maxYr': 2024},
      {'brand': 'Nisanyan', 'model': 'Kaşkay Şehir Gezgini', 'body': 'SUV', 'minVal': 1400000.0, 'maxVal': 2200000.0, 'minYr': 2019, 'maxYr': 2023},
      {'brand': 'Fordist', 'model': 'Mondeo Makam Titanium', 'body': 'Sedan', 'minVal': 1450000.0, 'maxVal': 2300000.0, 'minYr': 2018, 'maxYr': 2022},
    ],
    6: [
      {'brand': 'Merso', 'model': 'E-250 Gözlüklü AMG', 'body': 'Sedan', 'minVal': 3200000.0, 'maxVal': 5200000.0, 'minYr': 2018, 'maxYr': 2023},
      {'brand': 'Bemeve', 'model': '5.20d Otoban Canavarı', 'body': 'Sedan', 'minVal': 3400000.0, 'maxVal': 5500000.0, 'minYr': 2019, 'maxYr': 2024},
      {'brand': 'Odi', 'model': 'A6 Makam Quattro', 'body': 'Sedan', 'minVal': 3100000.0, 'maxVal': 4900000.0, 'minYr': 2018, 'maxYr': 2023},
      {'brand': 'İsveçli', 'model': 'S-Doksan Güvenlik Tankı', 'body': 'Sedan', 'minVal': 3000000.0, 'maxVal': 4800000.0, 'minYr': 2019, 'maxYr': 2023},
    ],
    7: [
      {'brand': 'Porş', 'model': 'DokuzYüzOnbir Turbo S', 'body': 'Spor', 'minVal': 8500000.0, 'maxVal': 16000000.0, 'minYr': 2020, 'maxYr': 2025},
      {'brand': 'Merso', 'model': 'G-63 Tuğla V8 Biturbo', 'body': 'SUV', 'minVal': 9500000.0, 'maxVal': 18500000.0, 'minYr': 2021, 'maxYr': 2025},
      {'brand': 'Bemeve', 'model': 'M-Dört Pist Fırtınası', 'body': 'Spor', 'minVal': 7500000.0, 'maxVal': 13500000.0, 'minYr': 2020, 'maxYr': 2024},
      {'brand': 'Porş', 'model': 'Kayen Patron SUV GTS', 'body': 'SUV', 'minVal': 8000000.0, 'maxVal': 15000000.0, 'minYr': 2021, 'maxYr': 2025},
    ],
    8: [
      {'brand': 'İngiliz', 'model': 'Fantom Saray Long (Rolls)', 'body': 'Lüks Sedan', 'minVal': 28000000.0, 'maxVal': 52000000.0, 'minYr': 2022, 'maxYr': 2026},
      {'brand': 'İtalyan', 'model': 'F-Sekiz Haraççı V8 (Ferrari)', 'body': 'Süper Spor', 'minVal': 24000000.0, 'maxVal': 46000000.0, 'minYr': 2022, 'maxYr': 2026},
      {'brand': 'İtalyan', 'model': 'Hurakan V10 Boğası (Lambo)', 'body': 'Süper Spor', 'minVal': 22000000.0, 'maxVal': 42000000.0, 'minYr': 2021, 'maxYr': 2025},
      {'brand': 'Merso', 'model': 'Maybach S-680 V12 Exclusive', 'body': 'Lüks Sedan', 'minVal': 25000000.0, 'maxVal': 48000000.0, 'minYr': 2023, 'maxYr': 2026},
    ],
  };

  /// Generates consignment vehicle offers scaled dynamically to the player's Dealership Branch Tier (§4.6.1)
  static List<CarModel> generateConsignmentOffers({
    required int inGameDay,
    int branchTier = 1,
    int reputationScore = 100,
  }) {
    final clampedTier = branchTier.clamp(1, 8);
    final count = clampedTier >= 6 ? 4 : (clampedTier >= 3 ? 3 : 2);
    
    final owners = _tierOwners[clampedTier] ?? _tierOwners[1]!;
    final carTemplates = _tierCarTemplates[clampedTier] ?? _tierCarTemplates[1]!;
    final results = <CarModel>[];

    // High dealer reputation grants higher commission rate incentives
    final repBonus = reputationScore > 50 ? min(0.04, (reputationScore - 50) * 0.0002) : 0.0;

    for (int i = 0; i < count; i++) {
      final owner = owners[i % owners.length];
      final template = carTemplates[i % carTemplates.length];
      final baseRate = (owner['rate'] as double) + repBonus;

      final minVal = template['minVal'] as double;
      final maxVal = template['maxVal'] as double;
      final baseValue = minVal + _random.nextDouble() * (maxVal - minVal);

      final minYr = template['minYr'] as int;
      final maxYr = template['maxYr'] as int;
      final year = minYr + _random.nextInt(maxYr - minYr + 1);

      final mileage = (clampedTier <= 2)
          ? 120000 + _random.nextInt(180000)
          : (clampedTier <= 5 ? 45000 + _random.nextInt(95000) : 8000 + _random.nextInt(35000));

      final id = 'car_consignment_${DateTime.now().microsecondsSinceEpoch}_$i';

      final car = CarModel(
        id: id,
        brand: template['brand'] as String,
        modelName: template['model'] as String,
        modelYear: year,
        bodyType: template['body'] as String,
        colorHex: '#2563EB',
        baseMarketValue: baseValue,
        currentPurchasePrice: 0.0, // Zero capital requirement
        isConsignment: true,
        consignmentCommissionRate: baseRate,
        consignmentOwnerName: owner['name'] as String,
        consignmentDaysRemaining: 12 + _random.nextInt(6),
        expertise: ExpertiseReport(
          engineCondition: 70.0 + _random.nextInt(28),
          transmissionCondition: 70.0 + _random.nextInt(28),
          tramerAmount: clampedTier <= 3 ? _random.nextInt(25000) : _random.nextInt(85000),
          mileage: mileage,
          isMileageTampered: false,
          bodyParts: {
            'Kaput': PartStatus.original,
            'Tavan': PartStatus.original,
            'Sol Ön Çamurluk': _random.nextBool() ? PartStatus.painted : PartStatus.original,
            'Sağ Ön Çamurluk': PartStatus.original,
            'Bagaj': PartStatus.original,
          },
        ),
      );

      results.add(car);
    }

    return results;
  }

  /// Calculates daily parking & showcase fee earned by the gallery per active consignment car
  static double calculateDailyParkingFee(int branchTier) {
    switch (branchTier.clamp(1, 8)) {
      case 1:
        return 300.0;
      case 2:
        return 600.0;
      case 3:
        return 1200.0;
      case 4:
        return 2500.0;
      case 5:
        return 5000.0;
      case 6:
        return 10000.0;
      case 7:
        return 22000.0;
      case 8:
        return 45000.0;
      default:
        return 300.0;
    }
  }

  /// Calculates net commission earnings for the gallery upon selling a consignment car
  static double calculateCommissionEarnings(CarModel car, double salePrice) {
    if (!car.isConsignment) return 0.0;
    return salePrice * car.consignmentCommissionRate;
  }
}

