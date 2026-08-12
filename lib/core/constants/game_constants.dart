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

  static const String appName = 'Galerisinden';
  static const String appVersion = '1.2.0';

  // Economy Defaults
  static const double startingBalance = 50000.0;
  static const int startingLevel = 1;
  static const int maxShowroomSlotsInitial = 3;

  // Costs & Fee Constants
  static const double expertiseBaseCost = 1500.0;
  static const double repairCostMultiplier = 450.0;
  static const double detailingCost = 2500.0;

  // Telif-Safe Real-Sounding Car Brands & Models
  static const List<CarBrandData> carBrands = [
    CarBrandData(name: 'Avdi', segment: 'premium', popularityWeight: 18, models: ['A3x', 'A4x', 'Q5x', 'TTs']),
    CarBrandData(name: 'BWM', segment: 'premium', popularityWeight: 17, models: ['316i', '520d', 'X3s', 'Z4s']),
    CarBrandData(name: 'Mersedes', segment: 'lüks', popularityWeight: 15, models: ['C180', 'E200', 'GLA', 'CLS']),
    CarBrandData(name: 'FW', segment: 'halk', popularityWeight: 22, models: ['Golfi', 'Pasat', 'Polo', 'Tiguan']),
    CarBrandData(name: 'Toyata', segment: 'güvenilir', popularityWeight: 20, models: ['Corola', 'Yars', 'RAV4', 'Camri']),
    CarBrandData(name: 'Hondo', segment: 'güvenilir', popularityWeight: 14, models: ['Civci', 'Accrd', 'CRVx', 'Jazz']),
    CarBrandData(name: 'Ferd', segment: 'halk', popularityWeight: 16, models: ['Focus', 'Fiesta', 'Puma', 'Kuga']),
    CarBrandData(name: 'Renolt', segment: 'halk', popularityWeight: 19, models: ['Cliox', 'Megan', 'Kadjar', 'Captur']),
    CarBrandData(name: 'Fiet', segment: 'ekonomi', popularityWeight: 13, models: ['Egea', 'Linea', '500x', 'Tipo']),
    CarBrandData(name: 'Hyundi', segment: 'popüler', popularityWeight: 12, models: ['i20', 'i30', 'Tucson', 'Kona']),
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
