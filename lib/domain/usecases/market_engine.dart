import 'dart:math';
import '../../core/constants/game_constants.dart';
import '../../core/utils/anti_repetition_queue.dart';
import '../../core/utils/slot_text_composer.dart';
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
    bool hasHighNecatiTrust = false,
  }) {
    final activeTrend = trend ?? generateMarketTrend();
    final actualCount = count ?? calculateDynamicListingCount(playerLevel: playerLevel, trend: activeTrend);
    List<ListingModel> listings = [];
    for (int i = 0; i < actualCount; i++) {
      listings.add(_generateSingleListing(
        playerLevel,
        activeTrend,
        playerBalance: playerBalance,
        hasHighNecatiTrust: hasHighNecatiTrust,
      ));
    }

    // Soft-lock prevention: If player has very low balance, ensure at least one naturally affordable starter model
    final effectiveBalance = (playerBalance != null && playerBalance > 0) ? playerBalance : 75000.0;
    final maxAffordablePrice = max(40000.0, effectiveBalance * 0.95);

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

    final hasDamagedParts = bodyParts.values.any((s) => s != PartStatus.original);
    final tramerAmount = hasDamagedParts ? (2500 + _random.nextInt(7500)) : 0;

    final expertise = ExpertiseReport(
      engineCondition: engineCondition.toDouble(),
      transmissionCondition: transCondition.toDouble(),
      tramerAmount: tramerAmount,
      mileage: mileage,
      isMileageTampered: false,
      bodyParts: bodyParts,
    );

    final cityData = GameConstants.cities[_random.nextInt(min(6, GameConstants.cities.length))];
    final sellerCity = cityData.trName;
    final sellerCityKey = cityData.key;
    final paint = _getRandomPaintColor();
    final plate = generateLicensePlate(city: sellerCity);
    final sellerData = _getRandomSellerData();

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

    final descKey = tramerAmount > 0 ? 'desc_honest_with_tramer' : 'desc_honest_clean_no_tramer';

    return ListingModel(
      id: 'listing_$id',
      car: car,
      sellerName: 'İlk Sahibinden Borçtan • ${sellerData.trName}',
      sellerTrait: 'Fiyat esnek, tamire ihtiyacı var',
      sellerCity: sellerCity,
      title: '$year ${brandData.name} $modelName',
      description: 'Acil nakit ihtiyacından kelepir fiyata satılık ayağı yerden kesecek başlangıç arabası!',
      askingPrice: targetPrice,
      isExpertiseCompleted: false,
      createdAt: DateTime.now(),
      sellerProfileKey: 'debt',
      sellerNameKey: sellerData.key,
      sellerCityKey: sellerCityKey,
      titlePrefixKey: 'normal_1',
      descriptionKey: descKey,
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

  static final AntiRepetitionQueue<String> _titlePrefixQueue = AntiRepetitionQueue<String>(capacity: 10);
  static final AntiRepetitionQueue<String> _descriptionQueue = AntiRepetitionQueue<String>(capacity: 25);

  static ({String title, String? prefixKey}) _generateTitle(int year, String brand, String modelName, bool isBarnFind, bool isRare, {bool isPristine = false}) {
    final baseTitle = '$year $brand $modelName';
    if (isBarnFind) {
      final prefixes = [
        'SAMANLIK BULUNTUSU KELEPİR',
        'GARAJ BULUNTUSU RESTORASYONLUK',
        'YILLARIN NOSTALJİSİ',
        'ÖZEL PROJE ARACI',
      ];
      final prefix = _titlePrefixQueue.selectNext(prefixes, randomInstance: _random);
      return (title: '$prefix • $baseTitle', prefixKey: 'barn');
    }
    if (isPristine) {
      final prefixes = [
        'HATASIZ BOYASIZ EMSALSİZ',
        'FABRİKASYON İLK GÜNKÜ GİBİ',
        'SIFIR KOKUSU ÜZERİNDE',
        'SERVİS BAKIMLI KUSURSUZ',
      ];
      final prefix = _titlePrefixQueue.selectNext(prefixes, randomInstance: _random);
      return (title: '$prefix • $baseTitle', prefixKey: 'pristine');
    }
    if (isRare) {
      final prefixes = [
        'ÖZEL KOLEKSİYONLUK',
        'NADİR BULUNAN KASA',
        'MERAKLISINA ÖZEL SERİ',
        'GARAJDA SAKLANMIŞ NADİDE',
      ];
      final prefix = _titlePrefixQueue.selectNext(prefixes, randomInstance: _random);
      return (title: '$prefix • $baseTitle', prefixKey: 'rare');
    }

    final normalPrefixes = [
      ('İLK SAHİBİNDEN TİTİZLİKLE', 'normal_1'),
      ('MASRAFSIZ DOSTA GİDER', 'normal_2'),
      ('MEMURDAN TEMİZ KULLANILMIŞ', 'normal_3'),
      ('BAKIMLARI YENİ MASRAFSIZ', 'normal_4'),
      ('AİLE ARACI EKSPERTİZE AÇIK', 'normal_5'),
    ];
    if (_random.nextDouble() < 0.65) {
      final pick = normalPrefixes[_random.nextInt(normalPrefixes.length)];
      return (title: '${pick.$1} • $baseTitle', prefixKey: pick.$2);
    }
    return (title: baseTitle, prefixKey: null);
  }

  static ({String description, String descriptionKey}) _generateDescription({
    bool isBarnFind = false,
    bool isFlashDeal = false,
    bool isRare = false,
    bool isPristine = false,
    ListingDeclarationType declarationType = ListingDeclarationType.honest,
    int tramerAmount = 0,
  }) {
    if (isBarnFind) {
      final slot1 = [
        'Köydeki dede yadigarı samanlıktan yeni gün yüzüne çıkarıldı.',
        'Kapalı depoda uzun yıllar muhafaza edilmiş orijinal gövde.',
        'Yıllardır dokunulmamış, nostalji kokan özel bir garaj buluntusu.',
        'Tozlu garajdan çekiciyle kurtarılmış hakiki klasik kasa.',
      ];
      final slot2 = [
        'Motor ve yürüyen aksam restorasyon istiyor, kaporta hatları şaşırtıcı derecede düzgün.',
        'Gövde panelleri ve orijinal detayları üzerinde duruyor, proje meraklısına bulunmaz fırsat.',
        'Taban sacında çürük az, motor blok numarası ve şasisi orijinal.',
        'İç döşemeleri elden geçmeli fakat restorasyon sonrası iki katı değer kazanır.',
      ];
      final slot3 = [
        'Klasik meraklısına kelepir fiyata devredilecektir • Proje aracı arayanlar kaçırmasın.',
        'Çekiciyle teslim edilir • Ciddi restorasyon ustalarına hayırlı olsun.',
        'Pazarlık araç başında cüzi miktarda olur • Alıcısına şimdiden hayırlı uğurlu olsun.',
      ];
      final res = SlotTextComposer.compose3(slot1: slot1, slot2: slot2, slot3: slot3, randomInstance: _random);
      _descriptionQueue.push(res);
      return (description: res, descriptionKey: 'desc_barn_find_1');
    }

    if (isPristine) {
      final slot1 = [
        'FABRİKASYON HATASIZ VE BOYASIZ! İlk sahibinden yetkili servis bakımlı.',
        'Sıfır kondisyonunda kapalı garaj arabası! Nokta kadar ezik çizik dahi yoktur.',
        'Tüm fabrika etiketleri ve orijinal mühürleri üzerindedir • Kusursuz temizliktedir.',
        'İlk günden beri tek elden titizlikle kullanılmış emsalsiz bir araçtır.',
      ];
      final slot2 = [
        'Boya, değişen, tramer kaydı kesinlikle YOKTUR • Tüm paneller fabrikasyon mikrondadır.',
        'Motor ve şanzıman saat gibi çalışır, en ufak ses veya yağ kaçağı bulunmaz.',
        'İç döşemelerinde, direksiyonunda ve butonlarında sıfır deformasyon vardır.',
        'Periyodik bakımları eksiksiz yapılmış, lastikleri ve aküsü sıfır ayarındadır.',
      ];
      final slot3 = [
        'Dilediğiniz kurumsal ekspertize ve yetkili servise açıktır • Tek kuruş masrafsızdır.',
        'Kapalı garajda yeni sahibini bekliyor • Pazarlık semboliktir.',
        'Kuruş masrafsız dosta gidecek nadide araç • Alıcısına hayırlı olsun.',
      ];
      final res = SlotTextComposer.compose3(slot1: slot1, slot2: slot2, slot3: slot3, randomInstance: _random);
      _descriptionQueue.push(res);
      return (description: res, descriptionKey: 'desc_pristine_1');
    }

    if (declarationType == ListingDeclarationType.flawlessClaim) {
      final slot1 = [
        'KUSURSUZ VE HATASIZ İDDİASIYLA SATILIK! İlk sahibinden garaj aracı.',
        'Kazasız belasız, tek elden kullanılmış masrafsız aile aracı.',
        'İddia ediyoruz bu temizlikte bu fiyata ikinci bir araç bulamazsınız.',
      ];
      final slot2 = [
        'Motoru yürüyeni sorunsuzdur, masraf istemez.',
        'Kaportası diridir, içi dışı pırıl pırıl temizliktedir.',
        'Tüm bakımları zamanında yapılmıştır.',
      ];
      final slot3 = [
        'Ekspertize açıktır • Pazarlık araç başında usulünce yapılır.',
        'Nakit satılıktır • Alıcısına şimdiden hayırlı olsun.',
      ];
      final res = SlotTextComposer.compose3(slot1: slot1, slot2: slot2, slot3: slot3, randomInstance: _random);
      _descriptionQueue.push(res);
      return (description: res, descriptionKey: 'desc_flawless_claim_1');
    }

    if (isFlashDeal) {
      final isUrgentRelocation = _random.nextBool();
      final slot1 = isUrgentRelocation
          ? [
              'Yurtdışına taşınma sebebiyle çok acil satılıktır!',
              'ACİL NAKİT İHTİYACINDAN DOLAYI KELEPİR FİYAT!',
            ]
          : [
              'Ev alımı için peşinat ihtiyacından dolayı satılık!',
              'Ödemelerim sebebiyle birkaç günlüğüne piyasa değerinin altında bırakıyorum!',
            ];
      final slot2 = [
        'Aracın yürüyeninde motorunda hiçbir sıkıntı yoktur, bakımları tazedir.',
        'İlk gelen alır, araç başında ufak bir ikramım olur.',
        'Gönül rahatlığıyla binilecek diri bir kasadır.',
      ];
      final slot3 = [
        'Takas teklif etmeyiniz, sadece nakit satılıktır • Kaçıran üzülür.',
        'Noter hemen verilir • Alıcısına şimdiden hayırlı olsun.',
      ];
      final res = SlotTextComposer.compose3(slot1: slot1, slot2: slot2, slot3: slot3, randomInstance: _random);
      _descriptionQueue.push(res);
      return (
        description: res,
        descriptionKey: isUrgentRelocation ? 'desc_flash_urgent_1' : 'desc_flash_house_1',
      );
    }

    if (isRare) {
      final slot1 = [
        'Koleksiyon kondisyonunda, özenle saklanmış nadide bir kasa!',
        'Özel donanımlı ve düşük kilometreli nadir bulunan seri.',
        'Hafta sonları keyifle binilmiş pırıl pırıl koleksiyon arabası.',
      ];
      final slot2 = [
        'Tüm orijinal fabrika etiketleri ve aksesuarları üzerindedir.',
        'Kapalı garajda muhafaza edilmekte olup mekanik kondisyonu zirvededir.',
        'Döşemeleri ve kokpiti ilk günkü tazeliğini korumaktadır.',
      ];
      final slot3 = [
        'Değerini bilen gerçek meraklısına ve koleksiyonere hayırlı olsun.',
        'Ciddi alıcılar iletişime geçsin • Araç başında pazarlık yapılır.',
      ];
      final res = SlotTextComposer.compose3(slot1: slot1, slot2: slot2, slot3: slot3, randomInstance: _random);
      _descriptionQueue.push(res);
      return (description: res, descriptionKey: 'desc_rare_collector_1');
    }

    if (declarationType == ListingDeclarationType.honest) {
      final slot1 = [
        'İlk sahibinden temiz kullanılmış aile aracı.',
        'Memurdan titizlikle kullanılmış, uzun yolda yorulmamış diri araç.',
        'Bakımları aksatılmadan zamanında eksiksiz yapılmıştır.',
        'Şehir içi iş ev arası kullanılmış, kurcalanmamış orijinal kasa.',
      ];
      final slot2 = tramerAmount > 0
          ? [
              'Geçmişten sadece ₺$tramerAmount tramer hasar kaydı vardır • Şasiler, direkler ve tavan orijinaldir.',
              'Tramer kaydı ₺$tramerAmount olup boyalı parçalar ilanda dürüstçe belirtilmiştir.',
              'Ufak sürtmelerden kaynaklı ₺$tramerAmount trameri vardır • Yürüyen aksamı kusursuzdur.',
            ]
          : [
              'Tramer hasar kaydı YOKTUR • Şasiler, podyeler ve tavan tamamen orijinaldir.',
              'Hasar kayıtsız olup yürüyeni ve motoru ilk günkü diriliğindedir.',
              'Tramer kaydı bulunmamaktadır • Ekspertiz raporunda tam puan almıştır.',
            ];
      final slot3 = [
        'Lastikleri yeni, muayenesi günceldir • Masrafsız binilecek araçtır.',
        'İç döşemelerinde yanık yırtık yoktur, klima ve tüm elektronik aksam faaldir.',
        'Yedek anahtarı ve kitapçıkları mevcuttur • Kuruş masrafı yoktur.',
      ];
      final slot4 = [
        'Ekspertize açıktır • Pazarlık araç başında usulünce yapılır.',
        'Alıcısına şimdiden hayırlı uğurlu olsun.',
        'Dosta gidecek temizliktedir • Yeni sahibine hayırlı olsun.',
      ];
      final res = SlotTextComposer.compose4(slot1: slot1, slot2: slot2, slot3: slot3, slot4: slot4, randomInstance: _random);
      _descriptionQueue.push(res);
      return (
        description: res,
        descriptionKey: tramerAmount > 0 ? 'desc_honest_with_tramer' : 'desc_honest_clean_no_tramer',
      );
    }

    final standardSlot1 = [
      'Bakımları zamanında eksiksiz yapılmış masrafsız araç.',
      'Temiz kullanılmış, yürüyeni ve motoru diri aile arabası.',
      'Şehir içi düzenli kullanılmış, yıpranmamış sağlam kasa.',
      'Kapalı garajda muhafaza edilmiş temiz kondisyonda araç.',
    ];
    final standardSlot2 = [
      'Motorunda ve şanzımanında en ufak bir sorun veya yağ kaçağı yoktur.',
      'Ön takım ve amortisörler elden geçmiş, alt takımı sessizdir.',
      'İç kozmetiği temizdir, döşemelerinde yırtık bulunmaz.',
    ];
    final standardSlot3 = [
      'Yedek anahtarı ve muayenesi mevcuttur • Masrafsız binilecek durumdadır.',
      'Lastikleri iyi durumda, periyodik bakımı yeni yapılmıştır.',
      'Ekspertiz raporuna açıktır • Pazarlık araç başında usulünce yapılır.',
    ];
    final res = SlotTextComposer.compose3(slot1: standardSlot1, slot2: standardSlot2, slot3: standardSlot3, randomInstance: _random);
    _descriptionQueue.push(res);
    return (description: res, descriptionKey: 'desc_honest_clean_no_tramer');
  }

  static ListingModel _generateSingleListing(
    int playerLevel,
    MarketTrendModel trend, {
    double? playerBalance,
    bool hasHighNecatiTrust = false,
  }) {
    final brandData = _selectWeightedBrand(playerBalance: playerBalance, playerLevel: playerLevel);
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

    // Seller profile & Flash Deal chance (Necati Dayı perk increases kelepir deals to 22%)
    final sellerProfile = GameConstants.sellerProfiles[_random.nextInt(GameConstants.sellerProfiles.length)];
    final flashChance = hasHighNecatiTrust ? 0.22 : 0.12;
    final isFlashDeal = !isPristine && (_random.nextDouble() < flashChance);

    // Barn Find chance (Necati Dayı perk increases barn finds to 10%)
    final barnBaseChance = hasHighNecatiTrust ? 0.10 : 0.04;
    final isBarnFind = !isPristine && (isClassicModel || _random.nextDouble() < barnBaseChance) && _random.nextDouble() < 0.40;

    final cityData = GameConstants.cities[_random.nextInt(GameConstants.cities.length)];
    final sellerCity = cityData.trName;
    final sellerCityKey = cityData.key;
    final paint = _getRandomPaintColor();
    final plate = generateLicensePlate(city: sellerCity);

    final sellerData = _getRandomSellerData();
    final sellerProfileKey = isPristine
        ? 'pristine'
        : (isBarnFind
            ? 'barn_find'
            : (isRare
                ? 'rare'
                : (isFlashDeal ? 'flash_deal' : (sellerProfile['key'] ?? 'urgent_cash'))));

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

    final titleData = _generateTitle(year, brandData.name, modelName, isBarnFind, isRare, isPristine: isPristine);
    final descData = _generateDescription(
      isBarnFind: isBarnFind,
      isFlashDeal: isFlashDeal,
      isRare: isRare,
      isPristine: isPristine,
      declarationType: declarationType,
      tramerAmount: tramerAmount,
    );

    return ListingModel(
      id: 'listing_$id',
      car: car,
      sellerName: isPristine
          ? 'Titiz Sahibinden • ${sellerData.trName}'
          : '${sellerProfile['name']} • ${sellerData.trName}',
      sellerTrait: isPristine
          ? 'Hatasız & Orijinal Garaj Arabası'
          : (isBarnFind
              ? 'Terk Edilmiş Kelepir Araç'
              : (isRare ? 'Koleksiyonluk Nadir Araç' : (isFlashDeal ? 'Fırsat İlanı! Çok Acele' : sellerProfile['trait']!))),
      sellerCity: sellerCity,
      title: titleData.title,
      description: descData.description,
      askingPrice: askingPrice,
      isExpertiseCompleted: false,
      createdAt: DateTime.now(),
      sellerProfileKey: sellerProfileKey,
      sellerNameKey: sellerData.key,
      sellerCityKey: sellerCityKey,
      titlePrefixKey: titleData.prefixKey,
      descriptionKey: descData.descriptionKey,
    );
  }

  static CarBrandData _selectWeightedBrand({double? playerBalance, int playerLevel = 1}) {
    // Determine dynamic segment weights according to player balance
    double getSegmentMultiplier(String segment) {
      if (playerBalance == null || playerBalance <= 0) return 1.0;

      if (playerBalance < 150000) {
        // Low budget: Economy, Legend, Classic, and Common brands heavily favored
        switch (segment) {
          case 'efsane':
          case 'klasik':
          case 'ekonomi':
            return 4.0;
          case 'halk':
            return 2.5;
          case 'popüler':
          case 'güvenilir':
            return 0.8;
          case 'premium':
          case 'lüks':
            return 0.3;
          case 'süperspor':
          case 'egzotik':
            return 0.1;
          default:
            return 1.0;
        }
      } else if (playerBalance < 800000) {
        // Mid budget: Economy, Popular, Reliable, Common, and moderate Premium
        switch (segment) {
          case 'halk':
          case 'popüler':
          case 'güvenilir':
          case 'ekonomi':
            return 2.5;
          case 'premium':
            return 1.5;
          case 'lüks':
            return 0.8;
          case 'süperspor':
          case 'egzotik':
            return 0.4;
          default:
            return 1.0;
        }
      } else {
        // High budget / Tycoon: Premium, Luxury, Super Sport, Exotic, Electric favored
        switch (segment) {
          case 'süperspor':
          case 'egzotik':
          case 'lüks':
          case 'premium':
          case 'elektrikli':
            return 3.5;
          case 'popüler':
          case 'güvenilir':
            return 1.5;
          case 'efsane':
          case 'klasik':
            return 1.2;
          default:
            return 0.6;
        }
      }
    }

    double totalWeight = 0.0;
    for (var brand in GameConstants.carBrands) {
      totalWeight += brand.popularityWeight * getSegmentMultiplier(brand.segment);
    }

    double roll = _random.nextDouble() * totalWeight;
    double currentSum = 0.0;

    for (var brand in GameConstants.carBrands) {
      currentSum += brand.popularityWeight * getSegmentMultiplier(brand.segment);
      if (roll <= currentSum) return brand;
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
        ('$cityCode TS 1967', 'legendary'),
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

  static ({String key, String trName}) _getRandomSellerData() {
    final names = GameConstants.sellerNames;
    return names[_random.nextInt(names.length)];
  }
}
