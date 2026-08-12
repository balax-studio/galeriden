class GameConstants {
  GameConstants._();

  static const String appName = 'Galerisinden';
  static const String appVersion = '1.0.0';

  // Economy Defaults
  static const double startingBalance = 50000.0;
  static const int startingLevel = 1;
  static const int maxShowroomSlotsInitial = 3;

  // Costs & Fee Constants
  static const double expertiseBaseCost = 1500.0;
  static const double repairCostMultiplier = 450.0; // per percentage point of damage
  static const double detailingCost = 2500.0;

  // Fiction Brand Names
  static const List<String> carBrands = [
    'Voltex',
    'Draco',
    'Zenith',
    'Apex',
    'Nomad',
    'Veloce',
    'Aether',
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
