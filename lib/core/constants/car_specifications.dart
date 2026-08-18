/// Authentic factory automotive specifications database for all in-game brands and models.
class CarSpecsData {
  final int horsepower;
  final int torqueNm;
  final double zeroToHundredSeconds;

  const CarSpecsData({
    required this.horsepower,
    required this.torqueNm,
    required this.zeroToHundredSeconds,
  });
}

class CarSpecifications {
  CarSpecifications._();

  static const CarSpecsData _defaultSpec = CarSpecsData(
    horsepower: 120,
    torqueNm: 180,
    zeroToHundredSeconds: 10.2,
  );

  /// Map of ModelName substring / key -> Authentic Factory Specs
  static const Map<String, CarSpecsData> _modelSpecs = {
    // --- Tofaşk ---
    'Şahin': CarSpecsData(horsepower: 80, torqueNm: 125, zeroToHundredSeconds: 13.2),
    'Doğan': CarSpecsData(horsepower: 86, torqueNm: 132, zeroToHundredSeconds: 12.5),
    'Kartal': CarSpecsData(horsepower: 83, torqueNm: 128, zeroToHundredSeconds: 13.5),
    'Hacı Murat': CarSpecsData(horsepower: 65, torqueNm: 95, zeroToHundredSeconds: 15.8),
    'Serçe': CarSpecsData(horsepower: 60, torqueNm: 88, zeroToHundredSeconds: 16.5),
    'Murat 131': CarSpecsData(horsepower: 75, torqueNm: 115, zeroToHundredSeconds: 14.1),

    // --- Anadolum ---
    'A-Bir': CarSpecsData(horsepower: 68, torqueNm: 116, zeroToHundredSeconds: 15.0),
    'STC-16': CarSpecsData(horsepower: 88, torqueNm: 142, zeroToHundredSeconds: 11.2),
    'Böcek': CarSpecsData(horsepower: 54, torqueNm: 86, zeroToHundredSeconds: 17.5),
    'SV-1600': CarSpecsData(horsepower: 68, torqueNm: 116, zeroToHundredSeconds: 14.8),

    // --- Fiyasko / Fiat ---
    'Ege': CarSpecsData(horsepower: 95, torqueNm: 200, zeroToHundredSeconds: 11.8),
    'Egea': CarSpecsData(horsepower: 95, torqueNm: 200, zeroToHundredSeconds: 11.8),
    'Doblo': CarSpecsData(horsepower: 105, torqueNm: 290, zeroToHundredSeconds: 12.0),
    'Lineer': CarSpecsData(horsepower: 90, torqueNm: 200, zeroToHundredSeconds: 12.2),
    'Linea': CarSpecsData(horsepower: 90, torqueNm: 200, zeroToHundredSeconds: 12.2),
    'Uno': CarSpecsData(horsepower: 118, torqueNm: 165, zeroToHundredSeconds: 8.4),
    'Tempra': CarSpecsData(horsepower: 115, torqueNm: 159, zeroToHundredSeconds: 10.4),

    // --- Reno / Renault ---
    'Klio': CarSpecsData(horsepower: 130, torqueNm: 240, zeroToHundredSeconds: 9.0),
    'Clio': CarSpecsData(horsepower: 130, torqueNm: 240, zeroToHundredSeconds: 9.0),
    'Megan': CarSpecsData(horsepower: 115, torqueNm: 260, zeroToHundredSeconds: 10.5),
    'Megane': CarSpecsData(horsepower: 115, torqueNm: 260, zeroToHundredSeconds: 10.5),
    'Toros': CarSpecsData(horsepower: 72, torqueNm: 110, zeroToHundredSeconds: 15.4),
    'Brodvey': CarSpecsData(horsepower: 72, torqueNm: 105, zeroToHundredSeconds: 14.9),
    'Broadway': CarSpecsData(horsepower: 72, torqueNm: 105, zeroToHundredSeconds: 14.9),
    'Tılsım': CarSpecsData(horsepower: 160, torqueNm: 380, zeroToHundredSeconds: 9.2),
    'Talisman': CarSpecsData(horsepower: 160, torqueNm: 380, zeroToHundredSeconds: 9.2),

    // --- Vosgen / Volkswagen ---
    'Pas-At': CarSpecsData(horsepower: 150, torqueNm: 340, zeroToHundredSeconds: 8.9),
    'Passat': CarSpecsData(horsepower: 150, torqueNm: 340, zeroToHundredSeconds: 8.9),
    'Golf': CarSpecsData(horsepower: 150, torqueNm: 250, zeroToHundredSeconds: 8.5),
    'Polo': CarSpecsData(horsepower: 95, torqueNm: 175, zeroToHundredSeconds: 10.8),
    'Trans-Portakal': CarSpecsData(horsepower: 150, torqueNm: 340, zeroToHundredSeconds: 11.2),
    'Transporter': CarSpecsData(horsepower: 150, torqueNm: 340, zeroToHundredSeconds: 11.2),
    'Art-Karizma': CarSpecsData(horsepower: 190, torqueNm: 400, zeroToHundredSeconds: 7.8),
    'Arteon': CarSpecsData(horsepower: 190, torqueNm: 400, zeroToHundredSeconds: 7.8),

    // --- Opelyus / Opel ---
    'Astrolog': CarSpecsData(horsepower: 136, torqueNm: 320, zeroToHundredSeconds: 9.6),
    'Astra': CarSpecsData(horsepower: 136, torqueNm: 320, zeroToHundredSeconds: 9.6),
    'Korsan': CarSpecsData(horsepower: 100, torqueNm: 205, zeroToHundredSeconds: 10.9),
    'Corsa': CarSpecsData(horsepower: 100, torqueNm: 205, zeroToHundredSeconds: 10.9),
    'Vektör': CarSpecsData(horsepower: 136, torqueNm: 188, zeroToHundredSeconds: 10.0),
    'Vectra': CarSpecsData(horsepower: 136, torqueNm: 188, zeroToHundredSeconds: 10.0),
    'İnsinya': CarSpecsData(horsepower: 170, torqueNm: 400, zeroToHundredSeconds: 8.7),
    'Insignia': CarSpecsData(horsepower: 170, torqueNm: 400, zeroToHundredSeconds: 8.7),

    // --- Sitroen / Citroen ---
    'C-Üç': CarSpecsData(horsepower: 110, torqueNm: 205, zeroToHundredSeconds: 10.0),
    'C3': CarSpecsData(horsepower: 110, torqueNm: 205, zeroToHundredSeconds: 10.0),
    'Berlingoz': CarSpecsData(horsepower: 100, torqueNm: 250, zeroToHundredSeconds: 11.5),
    'Berlingo': CarSpecsData(horsepower: 100, torqueNm: 250, zeroToHundredSeconds: 11.5),
    'C-Elize': CarSpecsData(horsepower: 92, torqueNm: 230, zeroToHundredSeconds: 11.2),
    'C-Elysee': CarSpecsData(horsepower: 92, torqueNm: 230, zeroToHundredSeconds: 11.2),
    'C-Dört': CarSpecsData(horsepower: 130, torqueNm: 230, zeroToHundredSeconds: 8.9),
    'C4': CarSpecsData(horsepower: 130, torqueNm: 230, zeroToHundredSeconds: 8.9),

    // --- Pöjo / Peugeot ---
    'İkiYüzSekiz': CarSpecsData(horsepower: 130, torqueNm: 230, zeroToHundredSeconds: 8.7),
    '208': CarSpecsData(horsepower: 130, torqueNm: 230, zeroToHundredSeconds: 8.7),
    'ÜçBinSekiz': CarSpecsData(horsepower: 130, torqueNm: 300, zeroToHundredSeconds: 10.8),
    '3008': CarSpecsData(horsepower: 130, torqueNm: 300, zeroToHundredSeconds: 10.8),
    'BeşYüzSekiz': CarSpecsData(horsepower: 180, torqueNm: 250, zeroToHundredSeconds: 7.9),
    '508': CarSpecsData(horsepower: 180, torqueNm: 250, zeroToHundredSeconds: 7.9),
    'İkiYüzAltı': CarSpecsData(horsepower: 177, torqueNm: 202, zeroToHundredSeconds: 7.4),
    '206': CarSpecsData(horsepower: 177, torqueNm: 202, zeroToHundredSeconds: 7.4),

    // --- Hondam / Honda ---
    'Civciv Type-R': CarSpecsData(horsepower: 320, torqueNm: 400, zeroToHundredSeconds: 5.7),
    'Civic Type-R': CarSpecsData(horsepower: 320, torqueNm: 400, zeroToHundredSeconds: 5.7),
    'Type-R': CarSpecsData(horsepower: 320, torqueNm: 400, zeroToHundredSeconds: 5.7),
    'Civciv': CarSpecsData(horsepower: 129, torqueNm: 180, zeroToHundredSeconds: 9.8),
    'Civic': CarSpecsData(horsepower: 129, torqueNm: 180, zeroToHundredSeconds: 9.8),
    'S-İkiBin': CarSpecsData(horsepower: 240, torqueNm: 208, zeroToHundredSeconds: 6.2),
    'S2000': CarSpecsData(horsepower: 240, torqueNm: 208, zeroToHundredSeconds: 6.2),
    'CR-V': CarSpecsData(horsepower: 150, torqueNm: 190, zeroToHundredSeconds: 10.2),

    // --- Toyo / Toyota ---
    'Hilaks': CarSpecsData(horsepower: 150, torqueNm: 400, zeroToHundredSeconds: 11.5),
    'Hilux': CarSpecsData(horsepower: 150, torqueNm: 400, zeroToHundredSeconds: 11.5),
    'Korola': CarSpecsData(horsepower: 122, torqueNm: 142, zeroToHundredSeconds: 10.9),
    'Corolla': CarSpecsData(horsepower: 122, torqueNm: 142, zeroToHundredSeconds: 10.9),
    'Yarışçı': CarSpecsData(horsepower: 111, torqueNm: 136, zeroToHundredSeconds: 11.0),
    'Yaris': CarSpecsData(horsepower: 111, torqueNm: 136, zeroToHundredSeconds: 11.0),
    'Supra': CarSpecsData(horsepower: 330, torqueNm: 440, zeroToHundredSeconds: 4.9),

    // --- Fort / Ford ---
    'Fokus': CarSpecsData(horsepower: 120, torqueNm: 300, zeroToHundredSeconds: 10.0),
    'Focus': CarSpecsData(horsepower: 120, torqueNm: 300, zeroToHundredSeconds: 10.0),
    'Trans-İt': CarSpecsData(horsepower: 130, torqueNm: 385, zeroToHundredSeconds: 12.0),
    'Transit': CarSpecsData(horsepower: 130, torqueNm: 385, zeroToHundredSeconds: 12.0),
    'Müstang': CarSpecsData(horsepower: 450, torqueNm: 529, zeroToHundredSeconds: 4.3),
    'Mustang': CarSpecsData(horsepower: 450, torqueNm: 529, zeroToHundredSeconds: 4.3),
    'Kurye': CarSpecsData(horsepower: 100, torqueNm: 215, zeroToHundredSeconds: 12.0),
    'Courier': CarSpecsData(horsepower: 100, torqueNm: 215, zeroToHundredSeconds: 12.0),
    'Fiyesta': CarSpecsData(horsepower: 200, torqueNm: 290, zeroToHundredSeconds: 6.5),
    'Fiesta': CarSpecsData(horsepower: 200, torqueNm: 290, zeroToHundredSeconds: 6.5),

    // --- Bemeve / BMW ---
    '3.20': CarSpecsData(horsepower: 177, torqueNm: 350, zeroToHundredSeconds: 7.9),
    '320': CarSpecsData(horsepower: 177, torqueNm: 350, zeroToHundredSeconds: 7.9),
    '5.20': CarSpecsData(horsepower: 190, torqueNm: 400, zeroToHundredSeconds: 7.5),
    '520': CarSpecsData(horsepower: 190, torqueNm: 400, zeroToHundredSeconds: 7.5),
    'E-30': CarSpecsData(horsepower: 170, torqueNm: 226, zeroToHundredSeconds: 8.3),
    'E30': CarSpecsData(horsepower: 170, torqueNm: 226, zeroToHundredSeconds: 8.3),
    'M-Dört': CarSpecsData(horsepower: 510, torqueNm: 650, zeroToHundredSeconds: 3.9),
    'M4': CarSpecsData(horsepower: 510, torqueNm: 650, zeroToHundredSeconds: 3.9),
    'M3': CarSpecsData(horsepower: 510, torqueNm: 650, zeroToHundredSeconds: 3.9),
    'M-Üç': CarSpecsData(horsepower: 510, torqueNm: 650, zeroToHundredSeconds: 3.9),
    'X-Beş': CarSpecsData(horsepower: 265, torqueNm: 620, zeroToHundredSeconds: 6.5),
    'X5': CarSpecsData(horsepower: 265, torqueNm: 620, zeroToHundredSeconds: 6.5),

    // --- Avdi / Audi ---
    'A-Üç': CarSpecsData(horsepower: 150, torqueNm: 250, zeroToHundredSeconds: 8.4),
    'A3': CarSpecsData(horsepower: 150, torqueNm: 250, zeroToHundredSeconds: 8.4),
    'A-Altı': CarSpecsData(horsepower: 204, torqueNm: 400, zeroToHundredSeconds: 7.6),
    'A6': CarSpecsData(horsepower: 204, torqueNm: 400, zeroToHundredSeconds: 7.6),
    'RS-Altı': CarSpecsData(horsepower: 600, torqueNm: 800, zeroToHundredSeconds: 3.6),
    'RS6': CarSpecsData(horsepower: 600, torqueNm: 800, zeroToHundredSeconds: 3.6),
    'TT': CarSpecsData(horsepower: 230, torqueNm: 370, zeroToHundredSeconds: 5.8),

    // --- Merso / Mercedes ---
    'E-250': CarSpecsData(horsepower: 204, torqueNm: 500, zeroToHundredSeconds: 7.5),
    'E250': CarSpecsData(horsepower: 204, torqueNm: 500, zeroToHundredSeconds: 7.5),
    'C-200': CarSpecsData(horsepower: 184, torqueNm: 280, zeroToHundredSeconds: 7.7),
    'C200': CarSpecsData(horsepower: 184, torqueNm: 280, zeroToHundredSeconds: 7.7),
    'G-63': CarSpecsData(horsepower: 585, torqueNm: 850, zeroToHundredSeconds: 4.5),
    'G63': CarSpecsData(horsepower: 585, torqueNm: 850, zeroToHundredSeconds: 4.5),
    'S-400': CarSpecsData(horsepower: 330, torqueNm: 700, zeroToHundredSeconds: 5.4),
    'S400': CarSpecsData(horsepower: 330, torqueNm: 700, zeroToHundredSeconds: 5.4),
    'W-124': CarSpecsData(horsepower: 136, torqueNm: 225, zeroToHundredSeconds: 10.6),
    'W124': CarSpecsData(horsepower: 136, torqueNm: 225, zeroToHundredSeconds: 10.6),

    // --- Porş / Porsche ---
    '9-1-2': CarSpecsData(horsepower: 580, torqueNm: 750, zeroToHundredSeconds: 3.0),
    '911': CarSpecsData(horsepower: 580, torqueNm: 750, zeroToHundredSeconds: 3.0),
    'Pana-Mera': CarSpecsData(horsepower: 440, torqueNm: 550, zeroToHundredSeconds: 4.3),
    'Panamera': CarSpecsData(horsepower: 440, torqueNm: 550, zeroToHundredSeconds: 4.3),
    'Mekan': CarSpecsData(horsepower: 380, torqueNm: 520, zeroToHundredSeconds: 4.8),
    'Macan': CarSpecsData(horsepower: 380, torqueNm: 520, zeroToHundredSeconds: 4.8),
    'Kaynana': CarSpecsData(horsepower: 640, torqueNm: 850, zeroToHundredSeconds: 3.3),
    'Cayenne': CarSpecsData(horsepower: 640, torqueNm: 850, zeroToHundredSeconds: 3.3),

    // --- Çelikvolvo / Volvo ---
    'XK-Doksan': CarSpecsData(horsepower: 235, torqueNm: 480, zeroToHundredSeconds: 7.6),
    'XC90': CarSpecsData(horsepower: 235, torqueNm: 480, zeroToHundredSeconds: 7.6),
    'S-Altmış': CarSpecsData(horsepower: 190, torqueNm: 400, zeroToHundredSeconds: 7.9),
    'S60': CarSpecsData(horsepower: 190, torqueNm: 400, zeroToHundredSeconds: 7.9),
    'V-Kırk': CarSpecsData(horsepower: 152, torqueNm: 250, zeroToHundredSeconds: 8.3),
    'V40': CarSpecsData(horsepower: 152, torqueNm: 250, zeroToHundredSeconds: 8.3),
    'XK-Altmış': CarSpecsData(horsepower: 190, torqueNm: 400, zeroToHundredSeconds: 8.4),
    'XC60': CarSpecsData(horsepower: 190, torqueNm: 400, zeroToHundredSeconds: 8.4),

    // --- Teslo / Tesla ---
    'Model-Üç': CarSpecsData(horsepower: 283, torqueNm: 450, zeroToHundredSeconds: 5.6),
    'Model 3': CarSpecsData(horsepower: 283, torqueNm: 450, zeroToHundredSeconds: 5.6),
    'Model-Y': CarSpecsData(horsepower: 347, torqueNm: 527, zeroToHundredSeconds: 5.0),
    'Model Y': CarSpecsData(horsepower: 347, torqueNm: 527, zeroToHundredSeconds: 5.0),
    'Model-S': CarSpecsData(horsepower: 1020, torqueNm: 1420, zeroToHundredSeconds: 2.1),
    'Model S': CarSpecsData(horsepower: 1020, torqueNm: 1420, zeroToHundredSeconds: 2.1),

    // --- Milli T-Oniks / Togg ---
    '10X': CarSpecsData(horsepower: 218, torqueNm: 350, zeroToHundredSeconds: 7.8),
    'T-Sekiz': CarSpecsData(horsepower: 218, torqueNm: 350, zeroToHundredSeconds: 7.4),
    'T10X': CarSpecsData(horsepower: 218, torqueNm: 350, zeroToHundredSeconds: 7.8),
    'T8X': CarSpecsData(horsepower: 218, torqueNm: 350, zeroToHundredSeconds: 7.4),

    // --- Lambo / Lamborghini ---
    'Hura-Can': CarSpecsData(horsepower: 610, torqueNm: 560, zeroToHundredSeconds: 3.2),
    'Huracan': CarSpecsData(horsepower: 610, torqueNm: 560, zeroToHundredSeconds: 3.2),
    'Uruz': CarSpecsData(horsepower: 650, torqueNm: 850, zeroToHundredSeconds: 3.6),
    'Urus': CarSpecsData(horsepower: 650, torqueNm: 850, zeroToHundredSeconds: 3.6),
    'Aven-Tador': CarSpecsData(horsepower: 740, torqueNm: 690, zeroToHundredSeconds: 2.9),
    'Aventador': CarSpecsData(horsepower: 740, torqueNm: 690, zeroToHundredSeconds: 2.9),

    // --- Ferro / Ferrari ---
    'Dört-Beş-Sekiz': CarSpecsData(horsepower: 570, torqueNm: 540, zeroToHundredSeconds: 3.4),
    '458': CarSpecsData(horsepower: 570, torqueNm: 540, zeroToHundredSeconds: 3.4),
    'F-Sekiz': CarSpecsData(horsepower: 720, torqueNm: 770, zeroToHundredSeconds: 2.9),
    'F8': CarSpecsData(horsepower: 720, torqueNm: 770, zeroToHundredSeconds: 2.9),
    'SF-Doksan': CarSpecsData(horsepower: 1000, torqueNm: 800, zeroToHundredSeconds: 2.5),
    'SF90': CarSpecsData(horsepower: 1000, torqueNm: 800, zeroToHundredSeconds: 2.5),
  };

  /// Returns authentic factory horsepower for a brand/model
  static int getFactoryHorsepower(String brand, String modelName, {String? bodyType}) {
    final spec = getSpecs(brand, modelName, bodyType: bodyType);
    return spec.horsepower;
  }

  /// Returns authentic factory torque (Nm) for a brand/model
  static int getFactoryTorque(String brand, String modelName, {String? bodyType}) {
    final spec = getSpecs(brand, modelName, bodyType: bodyType);
    return spec.torqueNm;
  }

  /// Returns authentic 0-100 km/h acceleration time
  static double getFactoryZeroToHundred(String brand, String modelName, {String? bodyType}) {
    final spec = getSpecs(brand, modelName, bodyType: bodyType);
    return spec.zeroToHundredSeconds;
  }

  /// Looks up closest matching specification or fallback based on brand/bodyType
  static CarSpecsData getSpecs(String brand, String modelName, {String? bodyType}) {
    CarSpecsData? bestMatch;
    int longestKey = 0;
    for (final entry in _modelSpecs.entries) {
      if (modelName.contains(entry.key) && entry.key.length > longestKey) {
        bestMatch = entry.value;
        longestKey = entry.key.length;
      }
    }
    if (bestMatch != null) return bestMatch;

    final normalizedBrand = switch (brand.toLowerCase().trim()) {
      'bmw' || 'bemeve' => 'Bemeve',
      'audi' || 'avdi' => 'Avdi',
      'mercedes' || 'mercedes-benz' || 'merso' => 'Merso',
      'volkswagen' || 'vw' || 'vosgen' => 'Vosgen',
      'porsche' || 'porş' => 'Porş',
      'ferrari' || 'ferro' => 'Ferro',
      'lamborghini' || 'lambo' => 'Lambo',
      'tesla' || 'teslo' => 'Teslo',
      'ford' || 'fort' => 'Fort',
      'fiat' || 'fiyasko' => 'Fiyasko',
      'renault' || 'reno' => 'Reno',
      'opel' || 'opelyus' => 'Opelyus',
      'peugeot' || 'pöjo' => 'Pöjo',
      'citroen' || 'sitroen' => 'Sitroen',
      'honda' || 'hondam' => 'Hondam',
      'toyota' || 'toyo' => 'Toyo',
      'volvo' || 'çelikvolvo' => 'Çelikvolvo',
      'tofaş' || 'tofas' || 'tofaşk' => 'Tofaşk',
      'togg' || 'milli t-oniks' => 'Milli T-Oniks',
      _ => brand,
    };

    // Fallback based on normalized brand segment / bodyType
    switch (normalizedBrand) {
      case 'Tofaşk':
      case 'Anadolum':
        return const CarSpecsData(horsepower: 75, torqueNm: 115, zeroToHundredSeconds: 14.0);
      case 'Fiyasko':
      case 'Sitroen':
        return const CarSpecsData(horsepower: 95, torqueNm: 200, zeroToHundredSeconds: 11.5);
      case 'Reno':
      case 'Opelyus':
      case 'Vosgen':
      case 'Pöjo':
      case 'Fort':
        return const CarSpecsData(horsepower: 120, torqueNm: 250, zeroToHundredSeconds: 10.0);
      case 'Hondam':
      case 'Toyo':
        return const CarSpecsData(horsepower: 130, torqueNm: 220, zeroToHundredSeconds: 9.8);
      case 'Bemeve':
      case 'Avdi':
      case 'Merso':
      case 'Çelikvolvo':
        return const CarSpecsData(horsepower: 190, torqueNm: 400, zeroToHundredSeconds: 7.6);
      case 'Milli T-Oniks':
        return const CarSpecsData(horsepower: 218, torqueNm: 350, zeroToHundredSeconds: 7.8);
      case 'Porş':
      case 'Teslo':
        return const CarSpecsData(horsepower: 450, torqueNm: 600, zeroToHundredSeconds: 4.2);
      case 'Lambo':
      case 'Ferro':
        return const CarSpecsData(horsepower: 650, torqueNm: 750, zeroToHundredSeconds: 3.2);
      default:
        if (bodyType == 'Spor') {
          return const CarSpecsData(horsepower: 250, torqueNm: 350, zeroToHundredSeconds: 6.2);
        } else if (bodyType == 'SUV') {
          return const CarSpecsData(horsepower: 150, torqueNm: 320, zeroToHundredSeconds: 10.5);
        }
        return _defaultSpec;
    }
  }
}
