import 'dart:math';

enum PlateCategory {
  all,
  legendary,
  team,
  names,
  symmetric,
}

class SpecialPlateItem {
  final String id;
  final String plateNumber;
  final String city;
  final String rarity; // 'legendary', 'symmetric', 'repeated', 'standard'
  final String title;
  final String description;
  final double price;
  final int valueBonusPercent;
  final int reputationReward;
  final PlateCategory category;

  const SpecialPlateItem({
    required this.id,
    required this.plateNumber,
    required this.city,
    required this.rarity,
    required this.title,
    required this.description,
    required this.price,
    required this.valueBonusPercent,
    required this.reputationReward,
    required this.category,
  });
}

class SpecialPlateEngine {
  static final Random _random = Random();

  /// Curated catalogue of iconic Turkish special license plates
  static const List<SpecialPlateItem> curatedPlates = [
    // 1. Efsanevi & Prestij (Legendary Tier)
    SpecialPlateItem(
      id: 'plate_ata_1881',
      plateNumber: '34 ATA 1881',
      city: 'İstanbul',
      rarity: 'legendary',
      title: 'Ata Özel Serisi',
      description: 'Cumhuriyet hatırası en prestijli özel tescil plaka • Araç değerini %10a kadar • Maks ₺250.000 artırır.',
      price: 150000.0,
      valueBonusPercent: 10,
      reputationReward: 20,
      category: PlateCategory.legendary,
    ),
    SpecialPlateItem(
      id: 'plate_vip_001',
      plateNumber: '34 VIP 001',
      city: 'İstanbul',
      rarity: 'legendary',
      title: 'Protokol VIP Seri',
      description: 'Zirve iş dünyası ve protokol tescilli özel numara • Prestij ve itibar artışı.',
      price: 120000.0,
      valueBonusPercent: 10,
      reputationReward: 18,
      category: PlateCategory.legendary,
    ),
    SpecialPlateItem(
      id: 'plate_boss_01',
      plateNumber: '06 BOSS 01',
      city: 'Ankara',
      rarity: 'legendary',
      title: 'Başkent Patron Serisi',
      description: 'Otorite ve saygınlık simgesi tek haneli başkent plakası.',
      price: 110000.0,
      valueBonusPercent: 10,
      reputationReward: 16,
      category: PlateCategory.legendary,
    ),
    SpecialPlateItem(
      id: 'plate_kral_99',
      plateNumber: '34 KRAL 99',
      city: 'İstanbul',
      rarity: 'legendary',
      title: 'Cadde Hükümdarı',
      description: 'Özel taleple basılmış nadide harf grubu • Genç alıcıların gözdesi.',
      price: 95000.0,
      valueBonusPercent: 10,
      reputationReward: 15,
      category: PlateCategory.legendary,
    ),
    SpecialPlateItem(
      id: 'plate_tc_001',
      plateNumber: '06 TC 001',
      city: 'Ankara',
      rarity: 'legendary',
      title: 'Makam Tescili',
      description: 'Resmi makam ağırlığında tescilli nadir plaka.',
      price: 135000.0,
      valueBonusPercent: 10,
      reputationReward: 19,
      category: PlateCategory.legendary,
    ),
    SpecialPlateItem(
      id: 'plate_gal_1923',
      plateNumber: '34 GAL 1923',
      city: 'İstanbul',
      rarity: 'legendary',
      title: 'Galeriden Özel İmzası',
      description: 'Galericiler cemiyeti ve cumhuriyet kuruluş hatırası özel seri.',
      price: 105000.0,
      valueBonusPercent: 10,
      reputationReward: 17,
      category: PlateCategory.legendary,
    ),
    SpecialPlateItem(
      id: 'plate_reis_01',
      plateNumber: '06 REIS 01',
      city: 'Ankara',
      rarity: 'legendary',
      title: 'Ağır Esnaf Reisi',
      description: 'Sektörün ileri gelenlerine yakışır tescil.',
      price: 90000.0,
      valueBonusPercent: 10,
      reputationReward: 15,
      category: PlateCategory.legendary,
    ),

    // 2. Takım & Taraftar Plakaları (Team Tier)
    SpecialPlateItem(
      id: 'plate_gs_1905',
      plateNumber: '34 GS 1905',
      city: 'İstanbul',
      rarity: 'legendary',
      title: 'Sarı Kırmızı Efsane',
      description: '1905 tescilli sarı kırmızı taraftar gururu • Koleksiyon değeri taşır.',
      price: 85000.0,
      valueBonusPercent: 10,
      reputationReward: 14,
      category: PlateCategory.team,
    ),
    SpecialPlateItem(
      id: 'plate_fb_1907',
      plateNumber: '06 FB 1907',
      city: 'Ankara',
      rarity: 'legendary',
      title: 'Sarı Lacivert Asalet',
      description: '1907 tescilli sarı lacivert camiasının aranan efsanevi plakası.',
      price: 85000.0,
      valueBonusPercent: 10,
      reputationReward: 14,
      category: PlateCategory.team,
    ),
    SpecialPlateItem(
      id: 'plate_bjk_1903',
      plateNumber: '34 BJK 1903',
      city: 'İstanbul',
      rarity: 'legendary',
      title: 'Siyah Beyaz Tutku',
      description: '1903 tescilli kartal arması özel taraftar serisi.',
      price: 85000.0,
      valueBonusPercent: 10,
      reputationReward: 14,
      category: PlateCategory.team,
    ),
    SpecialPlateItem(
      id: 'plate_ts_1967',
      plateNumber: '61 TS 1967',
      city: 'Trabzon',
      rarity: 'legendary',
      title: 'Fırtına Karadeniz',
      description: 'Bordo mavi Karadeniz fırtınası efsanevi 1967 kuruluşu.',
      price: 80000.0,
      valueBonusPercent: 10,
      reputationReward: 14,
      category: PlateCategory.team,
    ),
    SpecialPlateItem(
      id: 'plate_goz_1925',
      plateNumber: '35 GOZ 1925',
      city: 'İzmir',
      rarity: 'legendary',
      title: 'İzmir Göztepe Ruhu',
      description: 'Ege sahillerinin efsanevi 1925 kuruluş sarı kırmızı serisi.',
      price: 70000.0,
      valueBonusPercent: 10,
      reputationReward: 12,
      category: PlateCategory.team,
    ),

    // 3. Özel İsim & Kelime Plakaları (Names Tier)
    SpecialPlateItem(
      id: 'plate_can_34',
      plateNumber: '34 CAN 34',
      city: 'İstanbul',
      rarity: 'legendary',
      title: 'Çift Şehirli Can Serisi',
      description: 'Hem isim hem il kodu simetrisi taşıyan prestijli plaka.',
      price: 65000.0,
      valueBonusPercent: 10,
      reputationReward: 12,
      category: PlateCategory.names,
    ),
    SpecialPlateItem(
      id: 'plate_efe_06',
      plateNumber: '06 EFE 06',
      city: 'Ankara',
      rarity: 'legendary',
      title: 'Başkent Efesi',
      description: 'İsme özel simetrik harf grubu.',
      price: 60000.0,
      valueBonusPercent: 10,
      reputationReward: 11,
      category: PlateCategory.names,
    ),
    SpecialPlateItem(
      id: 'plate_cem_35',
      plateNumber: '35 CEM 35',
      city: 'İzmir',
      rarity: 'legendary',
      title: 'Ege Cem Serisi',
      description: 'Özel isim simetrisiyle basılmış nadide tescil.',
      price: 55000.0,
      valueBonusPercent: 10,
      reputationReward: 10,
      category: PlateCategory.names,
    ),
    SpecialPlateItem(
      id: 'plate_ali_34',
      plateNumber: '34 ALI 34',
      city: 'İstanbul',
      rarity: 'legendary',
      title: 'İstanbul Ali İmzası',
      description: 'Popüler isim tescili • Alıcı ilgisini katlar.',
      price: 58000.0,
      valueBonusPercent: 10,
      reputationReward: 11,
      category: PlateCategory.names,
    ),
    SpecialPlateItem(
      id: 'plate_han_99',
      plateNumber: '34 HAN 99',
      city: 'İstanbul',
      rarity: 'legendary',
      title: 'Hanedan Serisi',
      description: 'Kudret ve asalet simgesi tescil.',
      price: 52000.0,
      valueBonusPercent: 10,
      reputationReward: 10,
      category: PlateCategory.names,
    ),

    // 4. Simetrik & Tekrarlayan Plakalar (Symmetric & Repeated Tier)
    SpecialPlateItem(
      id: 'plate_aa_434',
      plateNumber: '34 AA 434',
      city: 'İstanbul',
      rarity: 'symmetric',
      title: 'Tam Simetrik Ayna',
      description: 'İl kodu ve rakam dizilimi ayna gibi örtüşen özel seri • Araç değerini %5e kadar • Maks ₺120.000 artırır.',
      price: 38000.0,
      valueBonusPercent: 5,
      reputationReward: 8,
      category: PlateCategory.symmetric,
    ),
    SpecialPlateItem(
      id: 'plate_bb_606',
      plateNumber: '06 BB 606',
      city: 'Ankara',
      rarity: 'symmetric',
      title: 'Başkent İkiz Rakam',
      description: 'Simetrik 606 dizilimiyle dikkat çeken plaka • Araç değerini %5e kadar • Maks ₺120.000 artırır.',
      price: 35000.0,
      valueBonusPercent: 5,
      reputationReward: 8,
      category: PlateCategory.symmetric,
    ),
    SpecialPlateItem(
      id: 'plate_jj_999',
      plateNumber: '34 JJ 999',
      city: 'İstanbul',
      rarity: 'repeated',
      title: 'Üçüz Dokuzlar',
      description: 'Arka arkaya dizilen üçüz rakamlar • Karizmatik duruş • Araç değerini %3e kadar • Maks ₺75.000 artırır.',
      price: 28000.0,
      valueBonusPercent: 3,
      reputationReward: 6,
      category: PlateCategory.symmetric,
    ),
    SpecialPlateItem(
      id: 'plate_mm_555',
      plateNumber: '35 MM 555',
      city: 'İzmir',
      rarity: 'repeated',
      title: 'Üçüz Beşler',
      description: 'Göz alıcı tekrar eden rakam grubu • Araç değerini %3e kadar • Maks ₺75.000 artırır.',
      price: 26000.0,
      valueBonusPercent: 3,
      reputationReward: 6,
      category: PlateCategory.symmetric,
    ),
    SpecialPlateItem(
      id: 'plate_rr_1111',
      plateNumber: '16 RR 1111',
      city: 'Bursa',
      rarity: 'repeated',
      title: 'Dörtlü Birler Serisi',
      description: 'Bursa tescilli dörtlü seri numara • Araç değerini %3e kadar • Maks ₺75.000 artırır.',
      price: 32000.0,
      valueBonusPercent: 3,
      reputationReward: 7,
      category: PlateCategory.symmetric,
    ),
  ];

  /// Turkish city code map
  static const Map<String, String> cityCodeMap = {
    '01': 'Adana',
    '06': 'Ankara',
    '07': 'Antalya',
    '09': 'Aydın',
    '10': 'Balıkesir',
    '16': 'Bursa',
    '20': 'Denizli',
    '21': 'Diyarbakır',
    '26': 'Eskişehir',
    '27': 'Gaziantep',
    '33': 'Mersin',
    '34': 'İstanbul',
    '35': 'İzmir',
    '38': 'Kayseri',
    '41': 'Kocaeli',
    '42': 'Konya',
    '48': 'Muğla',
    '55': 'Samsun',
    '61': 'Trabzon',
  };

  /// Evaluates custom plate creation in real-time, determining rarity, price and value boost
  static SpecialPlateItem evaluateCustomPlate({
    required String cityCode,
    required String letters,
    required String digits,
  }) {
    final cleanCity = cityCode.trim().padLeft(2, '0');
    final cleanLetters = letters.trim().toUpperCase().replaceAll(RegExp(r'[^A-ZÇĞİÖŞÜ]'), '');
    final cleanDigits = digits.trim().replaceAll(RegExp(r'[^0-9]'), '');

    final formattedNumber = '$cleanCity $cleanLetters $cleanDigits';
    final cityName = cityCodeMap[cleanCity] ?? 'Özel İl Tescili';

    // 1. Check for legendary keywords
    const legendaryKeywords = [
      'ATA', 'VIP', 'BOSS', 'KRAL', 'PRO', 'TC', 'GAL', 'POLIS', 'REIS', 'LIDER',
      'GS', 'FB', 'BJK', 'TS', 'GOZ', 'KSK', 'ES', 'CAN', 'EFE', 'CEM', 'ALI',
      'HAN', 'BEY', 'ALP', 'EGE', 'NUR', 'AGA', 'DEV', 'TURK', 'BABA', 'BOMBA',
    ];

    bool isLegendaryWord = legendaryKeywords.contains(cleanLetters);
    bool isRepeatedLetters = cleanLetters.length >= 2 && cleanLetters.split('').toSet().length == 1;
    bool isRepeatedDigits = cleanDigits.length >= 3 && cleanDigits.split('').toSet().length == 1;
    bool isSymmetric = (cleanDigits == cleanCity) ||
        (cleanDigits.length == 3 && cleanDigits[0] == cleanDigits[2] && !isRepeatedDigits) ||
        (cleanDigits.length == 4 && cleanDigits.substring(0, 2) == cleanDigits.substring(2) && !isRepeatedDigits);

    String rarity = 'standard';
    double price = 15000.0;
    int bonusPercent = 2;
    int repReward = 3;
    String title = 'Özel Tescil Plaka';
    String description = 'Kişiye özel harf ve rakam kombinasyonu • Değer artışı sağlar.';

    if (isLegendaryWord) {
      rarity = 'legendary';
      price = 80000.0 + (_random.nextInt(4) * 10000.0);
      bonusPercent = 10;
      repReward = 15;
      title = 'Efsanevi Kelime Tescili';
      description = 'Nadir tescilli efsane harf grubu • Araç değerini %10a kadar • Maks ₺250.000 artırır.';
    } else if (isRepeatedLetters || isRepeatedDigits) {
      rarity = 'repeated';
      price = 30000.0;
      bonusPercent = 3;
      repReward = 6;
      title = 'Tekrarlı Rakam/Harf Serisi';
      description = 'Tekrar eden karizmatik seri • Araç değerini %3e kadar • Maks ₺75.000 artırır.';
    } else if (isSymmetric || (cleanDigits.endsWith(cleanCity) && cleanDigits.length >= 2)) {
      rarity = 'symmetric';
      price = 42000.0;
      bonusPercent = 5;
      repReward = 8;
      title = 'Simetrik Uyumlu Seri';
      description = 'İl kodu ve rakam uyumlu simetrik tescil • Araç değerini %5e kadar • Maks ₺120.000 artırır.';
    } else {
      rarity = 'standard';
      price = 16000.0;
      bonusPercent = 2;
      repReward = 4;
      title = 'Özel Talep Plaka';
      description = 'Kişisel sipariş tescil plakası • Araç değerini %2ye kadar • Maks ₺50.000 artırır.';
    }

    return SpecialPlateItem(
      id: 'custom_${formattedNumber.replaceAll(' ', '_')}',
      plateNumber: formattedNumber,
      city: cityName,
      rarity: rarity,
      title: title,
      description: description,
      price: price,
      valueBonusPercent: bonusPercent,
      reputationReward: repReward,
      category: isLegendaryWord
          ? PlateCategory.legendary
          : (isSymmetric ? PlateCategory.symmetric : PlateCategory.all),
    );
  }
}
