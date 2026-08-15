import 'dart:math';

enum PartQualityTier {
  worn,      // Çürük / Ağır Aşınmış (%10 - %25)
  usable,    // Kullanılabilir / Çıkma (%30 - %60)
  good,      // İyi Durumda (%65 - %85)
  pristine,  // Mükemmel / Sıfır Ayarında (%90 - %100)
}

class SalvagedPart {
  final String id;
  final String name;
  final String carModelName;
  final String category; // 'engine', 'transmission', 'turbo', 'ecu', 'catalytic', 'radiator', 'brakes', 'suspension', 'headlights', 'seats', 'ac', 'wheels'
  final int conditionPercent; // 10 to 100
  final PartQualityTier tier;
  final double estimatedValue;
  final bool isSold;

  const SalvagedPart({
    required this.id,
    required this.name,
    required this.carModelName,
    required this.category,
    required this.conditionPercent,
    this.tier = PartQualityTier.usable,
    required this.estimatedValue,
    this.isSold = false,
  });

  String get tierName {
    switch (tier) {
      case PartQualityTier.worn:
        return 'Aşınmış / Çürük';
      case PartQualityTier.usable:
        return 'Kullanılabilir Çıkma';
      case PartQualityTier.good:
        return 'İyi Kondisyonda';
      case PartQualityTier.pristine:
        return 'Sıfır Ayarında';
    }
  }

  SalvagedPart copyWith({
    String? id,
    String? name,
    String? carModelName,
    String? category,
    int? conditionPercent,
    PartQualityTier? tier,
    double? estimatedValue,
    bool? isSold,
  }) {
    return SalvagedPart(
      id: id ?? this.id,
      name: name ?? this.name,
      carModelName: carModelName ?? this.carModelName,
      category: category ?? this.category,
      conditionPercent: conditionPercent ?? this.conditionPercent,
      tier: tier ?? this.tier,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      isSold: isSold ?? this.isSold,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'carModelName': carModelName,
      'category': category,
      'conditionPercent': conditionPercent,
      'tier': tier.name,
      'estimatedValue': estimatedValue,
      'isSold': isSold,
    };
  }

  factory SalvagedPart.fromJson(Map<String, dynamic> json) {
    return SalvagedPart(
      id: json['id'] as String? ?? 'part_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name'] as String? ?? 'Yedek Parça',
      carModelName: json['carModelName'] as String? ?? 'Genel Model',
      category: json['category'] as String? ?? 'engine',
      conditionPercent: json['conditionPercent'] as int? ?? 65,
      tier: PartQualityTier.values.firstWhere(
        (e) => e.name == json['tier'],
        orElse: () => PartQualityTier.usable,
      ),
      estimatedValue: (json['estimatedValue'] as num?)?.toDouble() ?? 5000.0,
      isSold: json['isSold'] as bool? ?? false,
    );
  }
}

class ScrapyardCar {
  final String id;
  final String brand;
  final String modelName;
  final int modelYear;
  final double scrapPrice;
  final double estimatedPartTotalValue;
  final String damageNote;
  final List<SalvagedPart> parts;
  final bool isPurchased;

  const ScrapyardCar({
    required this.id,
    required this.brand,
    required this.modelName,
    required this.modelYear,
    required this.scrapPrice,
    required this.estimatedPartTotalValue,
    required this.damageNote,
    required this.parts,
    this.isPurchased = false,
  });

  ScrapyardCar copyWith({
    String? id,
    String? brand,
    String? modelName,
    int? modelYear,
    double? scrapPrice,
    double? estimatedPartTotalValue,
    String? damageNote,
    List<SalvagedPart>? parts,
    bool? isPurchased,
  }) {
    return ScrapyardCar(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      modelName: modelName ?? this.modelName,
      modelYear: modelYear ?? this.modelYear,
      scrapPrice: scrapPrice ?? this.scrapPrice,
      estimatedPartTotalValue: estimatedPartTotalValue ?? this.estimatedPartTotalValue,
      damageNote: damageNote ?? this.damageNote,
      parts: parts ?? this.parts,
      isPurchased: isPurchased ?? this.isPurchased,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'modelName': modelName,
      'modelYear': modelYear,
      'scrapPrice': scrapPrice,
      'estimatedPartTotalValue': estimatedPartTotalValue,
      'damageNote': damageNote,
      'parts': parts.map((p) => p.toJson()).toList(),
      'isPurchased': isPurchased,
    };
  }

  factory ScrapyardCar.fromJson(Map<String, dynamic> json) {
    return ScrapyardCar(
      id: json['id'] as String? ?? 'scrap_${DateTime.now().millisecondsSinceEpoch}',
      brand: json['brand'] as String? ?? 'Tofaşk',
      modelName: json['modelName'] as String? ?? 'Tofaşk Şahin-S Yanlama',
      modelYear: json['modelYear'] as int? ?? 1998,
      scrapPrice: (json['scrapPrice'] as num?)?.toDouble() ?? 25000.0,
      estimatedPartTotalValue: (json['estimatedPartTotalValue'] as num?)?.toDouble() ?? 45000.0,
      damageNote: json['damageNote'] as String? ?? 'Pert Araç',
      parts: (json['parts'] as List<dynamic>?)
              ?.map((p) => SalvagedPart.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      isPurchased: json['isPurchased'] as bool? ?? false,
    );
  }

  /// 12 Categories of Auto Parts Generator
  static List<SalvagedPart> generateRandomParts(String carName, double carBasePrice) {
    final rand = Random();
    final categories = [
      {'cat': 'engine', 'name': 'Komple Motor Bloğu', 'baseMult': 0.28},
      {'cat': 'transmission', 'name': 'Otomatik/Manuel Şanzıman', 'baseMult': 0.18},
      {'cat': 'turbo', 'name': 'Orijinal Turbo Şarj', 'baseMult': 0.12},
      {'cat': 'ecu', 'name': 'Motor Beyni (ECU)', 'baseMult': 0.08},
      {'cat': 'catalytic', 'name': 'Katalitik Konvertör & Egzoz', 'baseMult': 0.09},
      {'cat': 'radiator', 'name': 'Alüminyum Radyatör & Fan', 'baseMult': 0.05},
      {'cat': 'brakes', 'name': 'Brembo Fren Kaliperleri', 'baseMult': 0.07},
      {'cat': 'suspension', 'name': 'Spor Helezon & Amortisör Seti', 'baseMult': 0.06},
      {'cat': 'headlights', 'name': 'Bi-Xenon / LED Ön Far Takımı', 'baseMult': 0.08},
      {'cat': 'seats', 'name': 'Deri Koltuk & Döşeme Takımı', 'baseMult': 0.10},
      {'cat': 'ac', 'name': 'Klima Kompresörü & Radyatörü', 'baseMult': 0.06},
      {'cat': 'wheels', 'name': '18 İnç Orijinal Alaşım Jant Seti', 'baseMult': 0.14},
    ];

    categories.shuffle(rand);
    final count = 3 + rand.nextInt(4); // 3 to 6 parts
    final selected = categories.take(count);

    return selected.map((item) {
      final roll = rand.nextDouble();
      PartQualityTier tier;
      int condition;
      double tierMultiplier;

      if (roll < 0.20) {
        tier = PartQualityTier.worn;
        condition = 15 + rand.nextInt(15);
        tierMultiplier = 0.45;
      } else if (roll < 0.60) {
        tier = PartQualityTier.usable;
        condition = 35 + rand.nextInt(28);
        tierMultiplier = 0.75;
      } else if (roll < 0.88) {
        tier = PartQualityTier.good;
        condition = 68 + rand.nextInt(18);
        tierMultiplier = 1.05;
      } else {
        tier = PartQualityTier.pristine;
        condition = 90 + rand.nextInt(10);
        tierMultiplier = 1.45;
      }

      final baseVal = carBasePrice * (item['baseMult'] as double) * tierMultiplier;

      return SalvagedPart(
        id: 'part_${DateTime.now().microsecondsSinceEpoch}_${rand.nextInt(999)}',
        name: item['name'] as String,
        carModelName: carName,
        category: item['cat'] as String,
        conditionPercent: condition,
        tier: tier,
        estimatedValue: (baseVal.roundToDouble() / 100).round() * 100, // Round to nearest 100
      );
    }).toList();
  }
}
