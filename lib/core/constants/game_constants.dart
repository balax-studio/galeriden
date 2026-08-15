class CarBrandData {
  final String name;
  final String segment;
  final int popularityWeight; // Higher = appears more frequently
  final List<String> models;

  const CarBrandData({
    required this.name,
    required this.segment,
    required this.popularityWeight,
    required this.models,
  });
}

class GameConstants {
  GameConstants._();

  static const String appName = 'Galeriden';
  static const String appVersion = '1.2.0';

  // Economy Defaults
  static const double startingBalance = 50000.0;
  static const int startingLevel = 1;
  static const int maxShowroomSlotsInitial = 3;

  // Costs & Fee Constants
  static const double expertiseBaseCost = 1500.0;
  static const double repairCostMultiplier = 450.0;
  static const double detailingCost = 2500.0;

  // Turkish Street Slang & Sanayi Jargonu Automotive Brands
  static const List<CarBrandData> carBrands = [
    // Yerli & Klasik Sanayi Efsaneleri
    CarBrandData(
      name: 'Tofaşk',
      segment: 'efsane',
      popularityWeight: 26,
      models: [
        'Tofaşk Şahin-S Yanlama',
        'Tofaşk Doğan Görünümlü SLX',
        'Tofaşk Kartal Bagajlı',
        'Tofaşk Hacı Murat 124 (Dede Mirası)',
        'Tofaşk Serçe Çıtır Şehirli',
        'Tofaşk Murat 131 Nostalji Kralı',
      ],
    ),
    CarBrandData(
      name: 'Anadolum',
      segment: 'klasik',
      popularityWeight: 10,
      models: [
        'Anadolum A-Bir Nostalji',
        'Anadolum STC-16 Canavarı',
        'Anadolum Böcek Sahil Çılgını',
        'Anadolum SV-1600 Aile Klasiği',
      ],
    ),

    // Alman Sanayi & Otoban Efsaneleri
    CarBrandData(
      name: 'Merso',
      segment: 'lüks',
      popularityWeight: 22,
      models: [
        'Merso E-250 Gözlüklü',
        'Merso C-200 Makam AMG',
        'Merso G-63 Tuğla V8',
        'Merso S-400 Patron Long',
        'Merso W-124 Taksici Efsanesi',
      ],
    ),
    CarBrandData(
      name: 'Bemeve',
      segment: 'premium',
      popularityWeight: 24,
      models: [
        'Bemeve 3.20d Yanlama E-90',
        'Bemeve 5.20d Otoban Canavarı',
        'Bemeve E-30 Yanlama Paketi',
        'Bemeve M-Dört Pist Fırtınası',
        'Bemeve X-Beş Dağ Keçisi',
      ],
    ),
    CarBrandData(
      name: 'Vosgen',
      segment: 'halk',
      popularityWeight: 25,
      models: [
        'Vosgen Pas-At 2.0 TDi Aşiret',
        'Vosgen Golf Sekiz R-Line',
        'Vosgen Polo Şehir Faresi',
        'Vosgen Trans-Portakal Van',
        'Vosgen Art-Karizma 2.0 TDI',
      ],
    ),
    CarBrandData(
      name: 'Avdi',
      segment: 'premium',
      popularityWeight: 18,
      models: [
        'Avdi A-Üç Sedan S-Hattı',
        'Avdi A-Altı 2.0 TDI Kuatro',
        'Avdi RS-Altı Canavar',
        'Avdi TT-Kupa Hızlı Çizgi',
      ],
    ),
    CarBrandData(
      name: 'Porş',
      segment: 'süperspor',
      popularityWeight: 8,
      models: [
        'Porş 9-1-2 Kurbağa Turbo',
        'Porş Pana-Mera 4S',
        'Porş Mekan GTS',
        'Porş Kaynana Turbo GT',
      ],
    ),
    CarBrandData(
      name: 'Opelyus',
      segment: 'halk',
      popularityWeight: 16,
      models: [
        'Opelyus Astrolog K Dinamik',
        'Opelyus Korsan F Şehirli',
        'Opelyus Vektör B 2.0 CD',
        'Opelyus İnsinya Gran Spor',
      ],
    ),

    // Fransız & İtalyan Filo Jargonu
    CarBrandData(
      name: 'Reno',
      segment: 'halk',
      popularityWeight: 23,
      models: [
        'Reno Klio Beş RS',
        'Reno Megan Dört Sedan',
        'Reno Toros Dağ Aslanı SW',
        'Reno Brodvey 1.4 Yaylı',
        'Reno Tılsım 2.0 dCi',
      ],
    ),
    CarBrandData(
      name: 'Fiyasko',
      segment: 'ekonomi',
      popularityWeight: 24,
      models: [
        'Fiyasko Ege-Paket 1.3 Multijet',
        'Fiyasko Doblo Enişte Combi',
        'Fiyasko Lineer Dizel',
        'Fiyasko Uno Turbo Çılgın',
        'Fiyasko Temprament 2.0 SX',
      ],
    ),
    CarBrandData(
      name: 'Pöjo',
      segment: 'popüler',
      popularityWeight: 17,
      models: [
        'Pöjo İkiYüzSekiz GT',
        'Pöjo ÜçBinSekiz Aslan SUV',
        'Pöjo BeşYüzSekiz Karizma',
        'Pöjo İkiYüzAltı RC Roket',
      ],
    ),
    CarBrandData(
      name: 'Sitroen',
      segment: 'ekonomi',
      popularityWeight: 14,
      models: [
        'Sitroen C-Üç Havalı Kros',
        'Sitroen Berlingoz Usta',
        'Sitroen C-Elize Eko',
        'Sitroen C-Dört X Parlak',
      ],
    ),

    // Asya & Amerikan Jargonu
    CarBrandData(
      name: 'Hondam',
      segment: 'güvenilir',
      popularityWeight: 20,
      models: [
        'Hondam Civciv 1.5 VTEC',
        'Hondam Civciv Type-R Vututu',
        'Hondam S-İkiBin Rüzgarı',
        'Hondam CR-Vututu SUV',
      ],
    ),
    CarBrandData(
      name: 'Toyo',
      segment: 'güvenilir',
      popularityWeight: 22,
      models: [
        'Toyo To-Yıkılmaz Hilaks 4x4',
        'Toyo Korola 1.8 Hibrit Eko',
        'Toyo Yarışçı 1.5 Kompakt',
        'Toyo Süper-Supra MK4 TwinTurbo',
      ],
    ),
    CarBrandData(
      name: 'Fort',
      segment: 'halk',
      popularityWeight: 19,
      models: [
        'Fort Fokus-At 1.5 Dizel',
        'Fort Trans-İt 100T Pazar Servisi',
        'Fort Müstang V8 Vahşi At',
        'Fort Kurye-Van Ticari',
        'Fort Fiyesta ST',
      ],
    ),

    // Egzotik, Güvenlik & Yerli
    CarBrandData(
      name: 'Lambo',
      segment: 'egzotik',
      popularityWeight: 4,
      models: [
        'Lambo Hura-Can V10',
        'Lambo Uruz 4.0 Çöl Boğası',
        'Lambo Aven-Tador V12',
      ],
    ),
    CarBrandData(
      name: 'Ferro',
      segment: 'egzotik',
      popularityWeight: 4,
      models: [
        'Ferro Dört-Beş-Sekiz İtalyano',
        'Ferro F-Sekiz Haraççı',
        'Ferro SF-Doksan Hibrit',
      ],
    ),
    CarBrandData(
      name: 'Çelikvolvo',
      segment: 'güvenlik',
      popularityWeight: 12,
      models: [
        'Çelikvolvo XK-Doksan Çelik Zırh',
        'Çelikvolvo S-Altmış R-Stil',
        'Çelikvolvo V-Kırk Köy Kasaba',
        'Çelikvolvo XK-Altmış Prestij',
      ],
    ),
    CarBrandData(
      name: 'Teslo',
      segment: 'elektrikli',
      popularityWeight: 10,
      models: [
        'Teslo Model-Üç Pilli',
        'Teslo Model-Y Aile Roketi',
        'Teslo Model-S Pled Uzay Mekiği',
      ],
    ),
    CarBrandData(
      name: 'Milli T-Oniks',
      segment: 'yerli',
      popularityWeight: 16,
      models: [
        'Milli T-Oniks 10X Akıllı SUV',
        'Milli T-Sekiz Sedan Prototip',
      ],
    ),
  ];

  // Car Categories
  static const List<String> bodyTypes = [
    'Sedan',
    'Hatchback',
    'SUV',
    'Spor',
    'Klasik',
  ];

  // Seller Profiles for Offline Market
  static const List<Map<String, String>> sellerProfiles = [
    {'name': 'Doktordan Temiz', 'trait': 'Titiz, az pazarlık yapar', 'urgency': 'low'},
    {'name': 'Acil Satılık Sahibinden', 'trait': 'Aceleci, kelepir fiyata verebilir', 'urgency': 'high'},
    {'name': 'Galeriden Takaslı', 'trait': 'Pazarlığa açık, kar marjı makul', 'urgency': 'medium'},
    {'name': 'İlk Sahibinden Borçtan', 'trait': 'Fiyat esnek, tamire ihtiyacı var', 'urgency': 'high'},
    {'name': 'Koleksiyoner', 'trait': 'Fiyatı yüksek tutar, araç temizdir', 'urgency': 'low'},
  ];
}
