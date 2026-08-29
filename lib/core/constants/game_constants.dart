import 'package:flutter/foundation.dart';

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
  static const String appVersion = '1.0.1';
  static const String privacyPolicyUrl =
      'https://docs.google.com/document/d/e/2PACX-1vSIja6S76xfAAy2wwWh12Mi0rEdjiMailne09VQj5gbPnhDTSpFVU5SKmwb2AdeuqO41L3EjjSI0kfd/pub';

  // Store URLs & Reviews
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.balax.galeriden';
  static const String appStoreUrl =
      'https://apps.apple.com/app/id6802756838?action=write-review';
  static const String appStoreWebUrl =
      'https://apps.apple.com/app/galeriden/id6802756838';

  /// Returns the platform-specific store URL for rating & reviews.
  static String get storeReviewUrl {
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return appStoreUrl;
    }
    return playStoreUrl;
  }

  // Economy Defaults
  static const double startingBalance = 50000.0;
  static const int startingLevel = 1;
  static const int maxShowroomSlotsInitial = 3;
  static const int minReputationScore = 0;
  static const int maxReputationScore = 1000;

  // Costs & Fee Constants
  static const double expertiseBaseCost = 1500.0;
  static const double repairCostMultiplier = 450.0;
  static const double detailingCost = 2500.0;
  static const double notaryFraudCompensationAmount = 3500.0;
  static const double nightRaceEntryFee = 5000.0;
  static const double socialMediaPrCost = 2000.0;
  static const double customerCompensationCost = 500.0;
  static const double dopingCost = 2500.0;
  static const double refreshListingCost = 1500.0;

  // Turkish Street Slang & Sanayi Jargonu Automotive Brands
  static const List<CarBrandData> carBrands = [
    // Yerli & Klasik Sanayi Efsaneleri
    CarBrandData(
      name: 'Tofaşk',
      segment: 'efsane',
      popularityWeight: 26,
      models: [
        'Şahin-S Yanlama',
        'Doğan Görünümlü SLX',
        'Kartal Bagajlı',
        'Hacı Murat 124 • Dede Mirası',
        'Serçe Çıtır Şehirli',
        'Murat 131 Nostalji Kralı',
      ],
    ),
    CarBrandData(
      name: 'Anadolum',
      segment: 'klasik',
      popularityWeight: 10,
      models: [
        'A-Bir Nostalji',
        'STC-16 Canavarı',
        'Böcek Sahil Çılgını',
        'SV-1600 Aile Klasiği',
      ],
    ),

    // Alman Sanayi & Otoban Efsaneleri
    CarBrandData(
      name: 'Merso',
      segment: 'lüks',
      popularityWeight: 22,
      models: [
        'E-250 Gözlüklü',
        'C-200 Makam AMG',
        'G-63 Tuğla V8',
        'S-400 Patron Long',
        'W-124 Taksici Efsanesi',
      ],
    ),
    CarBrandData(
      name: 'Bemeve',
      segment: 'premium',
      popularityWeight: 24,
      models: [
        '3.20d Yanlama E-90',
        '5.20d Otoban Canavarı',
        'E-30 Yanlama Paketi',
        'M-Dört Pist Fırtınası',
        'X-Beş Dağ Keçisi',
      ],
    ),
    CarBrandData(
      name: 'Vosgen',
      segment: 'halk',
      popularityWeight: 25,
      models: [
        'Pas-At 2.0 TDi Aşiret',
        'Golf Sekiz R-Line',
        'Polo Şehir Faresi',
        'Trans-Portakal Van',
        'Art-Karizma 2.0 TDI',
      ],
    ),
    CarBrandData(
      name: 'Avdi',
      segment: 'premium',
      popularityWeight: 18,
      models: [
        'A-Üç Sedan S-Hattı',
        'A-Altı 2.0 TDI Kuatro',
        'RS-Altı Canavar',
        'TT-Kupa Hızlı Çizgi',
      ],
    ),
    CarBrandData(
      name: 'Porş',
      segment: 'süperspor',
      popularityWeight: 8,
      models: [
        '9-1-2 Kurbağa Turbo',
        'Pana-Mera 4S',
        'Mekan GTS',
        'Kaynana Turbo GT',
      ],
    ),
    CarBrandData(
      name: 'Opelyus',
      segment: 'halk',
      popularityWeight: 16,
      models: [
        'Astrolog K Dinamik',
        'Korsan F Şehirli',
        'Vektör B 2.0 CD',
        'İnsinya Gran Spor',
      ],
    ),

    // Fransız & İtalyan Filo Jargonu
    CarBrandData(
      name: 'Reno',
      segment: 'halk',
      popularityWeight: 23,
      models: [
        'Klio Beş RS',
        'Megan Dört Sedan',
        'Toros Dağ Aslanı SW',
        'Brodvey 1.4 Yaylı',
        'Tılsım 2.0 dCi',
      ],
    ),
    CarBrandData(
      name: 'Fiyasko',
      segment: 'ekonomi',
      popularityWeight: 24,
      models: [
        'Ege-Paket 1.3 Multijet',
        'Doblo Enişte Combi',
        'Lineer Dizel',
        'Uno Turbo Çılgın',
        'Temprament 2.0 SX',
      ],
    ),
    CarBrandData(
      name: 'Pöjo',
      segment: 'popüler',
      popularityWeight: 17,
      models: [
        'İkiYüzSekiz GT',
        'ÜçBinSekiz Aslan SUV',
        'BeşYüzSekiz Karizma',
        'İkiYüzAltı RC Roket',
      ],
    ),
    CarBrandData(
      name: 'Sitroen',
      segment: 'ekonomi',
      popularityWeight: 14,
      models: [
        'C-Üç Havalı Kros',
        'Berlingoz Usta',
        'C-Elize Eko',
        'C-Dört X Parlak',
      ],
    ),

    // Asya & Amerikan Jargonu
    CarBrandData(
      name: 'Hondam',
      segment: 'güvenilir',
      popularityWeight: 20,
      models: [
        'Civciv 1.5 VTEC',
        'Civciv Type-R Vututu',
        'S-İkiBin Rüzgarı',
        'CR-Vututu SUV',
      ],
    ),
    CarBrandData(
      name: 'Toyo',
      segment: 'güvenilir',
      popularityWeight: 22,
      models: [
        'To-Yıkılmaz Hilaks 4x4',
        'Korola 1.8 Hibrit Eko',
        'Yarışçı 1.5 Kompakt',
        'Süper-Supra MK4 TwinTurbo',
      ],
    ),
    CarBrandData(
      name: 'Fort',
      segment: 'halk',
      popularityWeight: 19,
      models: [
        'Fokus-At 1.5 Dizel',
        'Trans-İt 100T Pazar Servisi',
        'Müstang V8 Vahşi At',
        'Kurye-Van Ticari',
        'Fiyesta ST',
      ],
    ),

    // Egzotik, Güvenlik & Yerli
    CarBrandData(
      name: 'Lambo',
      segment: 'egzotik',
      popularityWeight: 4,
      models: [
        'Hura-Can V10',
        'Uruz 4.0 Çöl Boğası',
        'Aven-Tador V12',
      ],
    ),
    CarBrandData(
      name: 'Ferro',
      segment: 'egzotik',
      popularityWeight: 4,
      models: [
        'Dört-Beş-Sekiz İtalyano',
        'F-Sekiz Haraççı',
        'SF-Doksan Hibrit',
      ],
    ),
    CarBrandData(
      name: 'Çelikvolvo',
      segment: 'güvenlik',
      popularityWeight: 12,
      models: [
        'XK-Doksan Çelik Zırh',
        'S-Altmış R-Stil',
        'V-Kırk Köy Kasaba',
        'XK-Altmış Prestij',
      ],
    ),
    CarBrandData(
      name: 'Teslo',
      segment: 'elektrikli',
      popularityWeight: 10,
      models: [
        'Model-Üç Pilli',
        'Model-Y Aile Roketi',
        'Model-S Pled Uzay Mekiği',
      ],
    ),
    CarBrandData(
      name: 'Milli T-Oniks',
      segment: 'yerli',
      popularityWeight: 16,
      models: [
        '10X Akıllı SUV',
        'T-Sekiz Sedan Prototip',
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
    {'name': 'Memurdan Sigara İçilmemiş', 'trait': 'Bakımları tam, fiyatta inatçı', 'urgency': 'medium'},
    {'name': 'Yurt Dışına Çıkacağı İçin', 'trait': 'Zamanı dar, nakit arıyor', 'urgency': 'high'},
    {'name': 'Keyfe Keder Satılık', 'trait': 'Satmaya niyeti yok, piyasa yokluyor', 'urgency': 'low'},
    {'name': 'Öğretmenden Servis Bakımlı', 'trait': 'Dürüst, masrafı az', 'urgency': 'medium'},
    {'name': 'Askerden Dönüş Aciliyetli', 'trait': 'Nakit paraya sıkışmış, hızlı satış', 'urgency': 'high'},
    {'name': 'Müteahhitten Takaslı', 'trait': 'Üste para alacağı araç arıyor', 'urgency': 'medium'},
    {'name': 'Ev Alacağı İçin Satılık', 'trait': 'Acil peşinat lazım, fiyatta kırar', 'urgency': 'high'},
  ];
}
