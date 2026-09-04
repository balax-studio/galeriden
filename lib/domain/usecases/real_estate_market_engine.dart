import 'dart:math';
import '../../data/models/real_estate_category.dart';
import '../../data/models/real_estate_model.dart';

class RealEstateTemplate {
  final RealEstateCategory category;
  final String titlePrefix;
  final String roomCount;
  final int minM2;
  final int maxM2;
  final double minBaseValue;
  final double maxBaseValue;
  final List<String> typicalCities;
  final List<String> descriptions;

  const RealEstateTemplate({
    required this.category,
    required this.titlePrefix,
    required this.roomCount,
    required this.minM2,
    required this.maxM2,
    required this.minBaseValue,
    required this.maxBaseValue,
    required this.typicalCities,
    required this.descriptions,
  });
}

class RealEstateMarketEngine {
  static final Random _random = Random();

  static const List<String> _districtsIstanbul = [
    'Kadıköy',
    'Beşiktaş',
    'Sarıyer',
    'Beylikdüzü',
    'Pendik',
    'Başakşehir',
    'Şişli',
    'Üsküdar',
  ];

  static const List<String> _districtsAnkara = [
    'Çankaya',
    'Keçiören',
    'Yenimahalle',
    'Gölbaşı',
    'Etimesgut',
  ];

  static const List<String> _districtsIzmir = [
    'Karşıyaka',
    'Bornova',
    'Çeşme',
    'Urla',
    'Konak',
  ];

  static const List<String> _districtsAntalya = [
    'Muratpaşa',
    'Alanya',
    'Kaş',
    'Kemer',
    'Konyaaltı',
  ];

  static const List<String> _districtsBursa = [
    'Nilüfer',
    'Osmangazi',
    'Mudanya',
    'Yıldırım',
  ];

  static const List<String> _districtsMugla = [
    'Bodrum',
    'Fethiye',
    'Marmaris',
    'Datça',
  ];

  static const List<String> _individualSellers = [
    'Mehmet Bey',
    'Ayşe Hanım',
    'Hacı Muzaffer Bey',
    'Emekli Öğretmen Salih',
    'Mimar Selin Hanım',
    'Avukat Cengiz Bey',
    'Doktor Tarık Bey',
    'Fatma Teyze',
  ];

  static const List<String> _parodyAgencies = [
    'Remaks Gayrimenkul',
    'Turyaprak Emlak',
    'Koldvel Türkiye',
    'Emlakbank Esnafı',
    'Centurio 21 Danışmanlık',
  ];

  static const List<String> _agencyAdvisors = [
    'Emlak Danışmanı Hakan',
    'Broker Murat Bey',
    'Portföy Yöneticisi Cansu',
    'Gayrimenkul Uzmanı Kerem',
    'Ofis Müdürü Serdar',
  ];

  static const List<RealEstateTemplate> templates = [
    // 1. Konut (779.231)
    RealEstateTemplate(
      category: RealEstateCategory.housing,
      titlePrefix: 'Kupon Daire • Balkonlu Geniş Manzara',
      roomCount: '3+1',
      minM2: 95,
      maxM2: 155,
      minBaseValue: 2400000,
      maxBaseValue: 5800000,
      typicalCities: ['İstanbul', 'Ankara', 'İzmir', 'Bursa'],
      descriptions: [
        'Metroya 5 dakika yürüme mesafesinde, güney cephe, aydınlık ve masrafsız ferah daire.',
        'Merkezi lokasyonda, aile apartmanında, çift banyolu ve otoparklı lüks konut.',
        'Kentsel dönüşüm potansiyeli yüksek, kira çarpanı cazip köşe başı daire.',
      ],
    ),
    RealEstateTemplate(
      category: RealEstateCategory.housing,
      titlePrefix: 'Yatırımlık Rezidans Stüdyo',
      roomCount: '1+1',
      minM2: 45,
      maxM2: 70,
      minBaseValue: 1600000,
      maxBaseValue: 3400000,
      typicalCities: ['İstanbul', 'Ankara', 'İzmir', 'Antalya'],
      descriptions: [
        'Üniversite ve iş merkezleri aksında, yüksek kira getirili full eşyalı modern rezidans.',
        'Resepsiyonlu, kapalı havuz ve fitness merkezli sitede ara kat stüdyo.',
      ],
    ),

    // 2. İş Yeri (152.000)
    RealEstateTemplate(
      category: RealEstateCategory.commercial,
      titlePrefix: 'Cadde Üstü Tabela Değeri Yüksek Dükkan',
      roomCount: 'Dükkan',
      minM2: 80,
      maxM2: 240,
      minBaseValue: 4500000,
      maxBaseValue: 14000000,
      typicalCities: ['İstanbul', 'Ankara', 'İzmir', 'Bursa'],
      descriptions: [
        'Yaya trafiğinin yoğun olduğu ana cadde üstünde, kurumsal market veya bankaya uygun dükkan.',
        'Geniş vitrin cepheli, bacalı, kafe veya restorana uygun köşe başı ticari mülk.',
      ],
    ),
    RealEstateTemplate(
      category: RealEstateCategory.commercial,
      titlePrefix: 'Plaza Ofis Katı • Prestijli Lokasyon',
      roomCount: 'Ofis Katı',
      minM2: 120,
      maxM2: 350,
      minBaseValue: 5200000,
      maxBaseValue: 18000000,
      typicalCities: ['İstanbul', 'Ankara', 'İzmir'],
      descriptions: [
        'Finans merkezine komşu A Plus plazada, hazır bölmeli ve otopark tahsisli lüks ofis katı.',
      ],
    ),

    // 3. Arsa (255.603)
    RealEstateTemplate(
      category: RealEstateCategory.land,
      titlePrefix: 'İmarlı Villa Parseli • Doğa ve Deniz Manzaralı',
      roomCount: 'İmarlı Arsa',
      minM2: 450,
      maxM2: 1800,
      minBaseValue: 3200000,
      maxBaseValue: 12500000,
      typicalCities: ['Antalya', 'Muğla', 'İzmir', 'Bursa'],
      descriptions: [
        'Yüzde 20 - 40 villa imarlı, yolu açılmış, elektrik ve su altyapısı hazır müstakil parsel.',
        'Koy manzaralı, turizm ve yazlık konut gelişim aksında prim potansiyeli yüksek arsa.',
      ],
    ),
    RealEstateTemplate(
      category: RealEstateCategory.land,
      titlePrefix: 'Ticari ve Lojistik Depolama İmarı',
      roomCount: 'Sanayi Parseli',
      minM2: 1200,
      maxM2: 5000,
      minBaseValue: 8000000,
      maxBaseValue: 28000000,
      typicalCities: ['İstanbul', 'Kocaeli', 'Bursa', 'Ankara'],
      descriptions: [
        'Otoban bağlantısına 2 km mesafede, tır girişine uygun ağır sanayi ve depo imarlı arsa.',
      ],
    ),

    // 4. Konut Projeleri (1.376)
    RealEstateTemplate(
      category: RealEstateCategory.housingProjects,
      titlePrefix: 'Lansman Fiyatıyla Projeden Satılık Daire',
      roomCount: '2+1',
      minM2: 85,
      maxM2: 130,
      minBaseValue: 3800000,
      maxBaseValue: 7500000,
      typicalCities: ['İstanbul', 'Ankara', 'İzmir'],
      descriptions: [
        'Teslimine 6 ay kalan markalı projede peşin alıma özel yüzde 15 lansman avantajı.',
        'Geniş peyzaj alanları, yapay gölet ve sosyal tesisleri olan etapta birinci sınıf daire.',
      ],
    ),

    // 5. Bina (8.867)
    RealEstateTemplate(
      category: RealEstateCategory.building,
      titlePrefix: 'Komple Satılık 4 Katlı Apartman',
      roomCount: '8 Daire • 1 Dükkan',
      minM2: 600,
      maxM2: 1200,
      minBaseValue: 16000000,
      maxBaseValue: 42000000,
      typicalCities: ['İstanbul', 'İzmir', 'Ankara', 'Bursa'],
      descriptions: [
        'Her katta 2 daire ve zemin dükkan bulunan, düzenli kira getiren komple müstakil bina.',
        'Kentsel dönüşüme hazır, taban oturumu geniş, parsel değeri yüksek komple yapı.',
      ],
    ),

    // 6. Devre Mülk (2.562)
    RealEstateTemplate(
      category: RealEstateCategory.timeshare,
      titlePrefix: 'Termal & Spa Tatil Köyü Devre Mülk',
      roomCount: '1+1 Süit',
      minM2: 55,
      maxM2: 85,
      minBaseValue: 350000,
      maxBaseValue: 850000,
      typicalCities: ['Yalova', 'Afyon', 'Bolu', 'Bursa'],
      descriptions: [
        'Kırmızı dönem • Yılın 15 günü şifalı termal su havuzlu süitte tatil hakkı ve tapulu mülkiyet.',
        'Otel konseptinde işletilen, kullanılmadığında kiralama havuzuna devredilen termal mülk.',
      ],
    ),

    // 7. Turistik Tesis (1.470)
    RealEstateTemplate(
      category: RealEstateCategory.tourismFacility,
      titlePrefix: 'Bodrum Koyu Butik Otel & Beach Club',
      roomCount: '18 Oda • Havuzlu',
      minM2: 900,
      maxM2: 2400,
      minBaseValue: 26000000,
      maxBaseValue: 78000000,
      typicalCities: ['Muğla', 'Antalya', 'İzmir'],
      descriptions: [
        'Denize sıfır, özel iskeleli, taş mimarili ve yüksek sezon doluluk oranına sahip butik otel.',
        'Turizm işletme belgeli, restoran ve spa alanı tam teşekküllü resort mülk.',
      ],
    ),
  ];

  static List<RealEstateListingModel> generateListings({
    RealEstateCategory? categoryFilter,
    int count = 12,
    int currentDay = 1,
  }) {
    final candidateTemplates = categoryFilter != null
        ? templates.where((t) => t.category == categoryFilter).toList()
        : templates;

    if (candidateTemplates.isEmpty) return const [];

    final listings = <RealEstateListingModel>[];

    for (int i = 0; i < count; i++) {
      final template = candidateTemplates[_random.nextInt(candidateTemplates.length)];
      final city = template.typicalCities[_random.nextInt(template.typicalCities.length)];
      final district = _pickDistrictForCity(city);

      final squareMeters = template.minM2 +
          _random.nextInt(max(1, template.maxM2 - template.minM2));
      final buildingAge = _random.nextInt(28);

      // Deed type distribution
      final deedRoll = _random.nextDouble();
      final DeedType deedType;
      if (deedRoll < 0.60) {
        deedType = DeedType.ownershipDeed; // Kat Mülkiyetli
      } else if (deedRoll < 0.82) {
        deedType = DeedType.constructionServitude; // Kat İrtifaklı
      } else if (deedRoll < 0.92) {
        deedType = DeedType.sharedDeed; // Hisseli Tapu
      } else {
        deedType = DeedType.unlicensedBuilding; // İskansız Yapı
      }

      // Seller type distribution
      final sellerRoll = _random.nextDouble();
      final RealEstateSellerType sellerType;
      String sellerName;
      String? agencyName;

      if (sellerRoll < 0.45) {
        sellerType = RealEstateSellerType.individual;
        sellerName = _individualSellers[_random.nextInt(_individualSellers.length)];
      } else if (sellerRoll < 0.88) {
        sellerType = RealEstateSellerType.agency;
        agencyName = _parodyAgencies[_random.nextInt(_parodyAgencies.length)];
        sellerName = '$agencyName • ${_agencyAdvisors[_random.nextInt(_agencyAdvisors.length)]}';
      } else {
        sellerType = RealEstateSellerType.bankAuction;
        sellerName = 'Vakıfbank / Ziraat Tasfiye Portföyü';
      }

      final baseMarketValue = (template.minBaseValue +
              _random.nextDouble() * (template.maxBaseValue - template.minBaseValue))
          .roundToDouble();

      // Hot deal check (15% chance)
      final isHotDeal = _random.nextDouble() < 0.15;
      double askingPriceMultiplier = 0.95 + (_random.nextDouble() * 0.15); // 0.95 to 1.10
      if (isHotDeal) {
        askingPriceMultiplier = 0.78 + (_random.nextDouble() * 0.08); // 0.78 to 0.86
      }
      final askingPrice = (baseMarketValue * askingPriceMultiplier * deedType.valueMultiplier).roundToDouble();

      // Discrepancy injection
      String? discrepancyKey;
      if (deedType == DeedType.unlicensedBuilding) {
        discrepancyKey = 'unlicensedBuilding';
      } else if (deedType == DeedType.sharedDeed) {
        discrepancyKey = 'sharedDeed';
      } else if (_random.nextDouble() < 0.20) {
        final hiddenFlaws = [
          'mortgageEncumbrance',
          'illegalRoofDuplex',
          'historicPreservationSite',
          'stubbornTenant',
        ];
        discrepancyKey = hiddenFlaws[_random.nextInt(hiddenFlaws.length)];
      }

      final realEstate = RealEstateModel(
        id: 're_${currentDay}_${i}_${DateTime.now().millisecondsSinceEpoch}',
        title: '${template.titlePrefix} • $city $district',
        category: template.category,
        city: city,
        district: district,
        squareMeters: squareMeters,
        roomCount: template.roomCount,
        buildingAge: buildingAge,
        deedType: deedType,
        sellerType: sellerType,
        baseMarketValue: baseMarketValue,
        currentPurchasePrice: askingPrice,
      );

      final description = template.descriptions[_random.nextInt(template.descriptions.length)];

      listings.add(
        RealEstateListingModel(
          id: 'list_re_${currentDay}_$i',
          realEstate: realEstate,
          askingPrice: askingPrice,
          sellerName: sellerName,
          sellerAgencyName: agencyName,
          sellerTrait: isHotDeal ? 'Acil Nakit İhtiyacı • Kelepir' : 'Piyasa Emsali Satış',
          description: description,
          isHotDeal: isHotDeal,
          discrepancyKey: discrepancyKey,
        ),
      );
    }

    return listings;
  }

  static String _pickDistrictForCity(String city) {
    switch (city) {
      case 'İstanbul':
        return _districtsIstanbul[_random.nextInt(_districtsIstanbul.length)];
      case 'Ankara':
        return _districtsAnkara[_random.nextInt(_districtsAnkara.length)];
      case 'İzmir':
        return _districtsIzmir[_random.nextInt(_districtsIzmir.length)];
      case 'Antalya':
        return _districtsAntalya[_random.nextInt(_districtsAntalya.length)];
      case 'Bursa':
        return _districtsBursa[_random.nextInt(_districtsBursa.length)];
      case 'Muğla':
        return _districtsMugla[_random.nextInt(_districtsMugla.length)];
      default:
        return 'Merkez';
    }
  }
}
