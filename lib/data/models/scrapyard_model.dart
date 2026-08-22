import 'dart:math';
import 'package:flutter/material.dart';

enum PartQualityTier {
  worn,      // Çürük - Ağır Aşınmış
  usable,    // Kullanılabilir - Çıkma
  good,      // İyi Durumda
  pristine,  // Mükemmel - Sıfır Ayarında
}

enum ScrapyardZoneType {
  ostim,
  maslak,
  sasmaz,
  harabe,
}

extension ScrapyardZoneExtension on ScrapyardZoneType {
  String get title {
    switch (this) {
      case ScrapyardZoneType.ostim:
        return 'Ostim Ağır Sanayi';
      case ScrapyardZoneType.maslak:
        return 'Maslak Tuning Hangarları';
      case ScrapyardZoneType.sasmaz:
        return 'Şaşmaz Hurdalık Deposu';
      case ScrapyardZoneType.harabe:
        return 'Terk Edilmiş Çiftlik';
    }
  }

  String get description {
    switch (this) {
      case ScrapyardZoneType.ostim:
        return 'Döküm motor blokları, şanzıman ve ağır yürüyen aksamlar';
      case ScrapyardZoneType.maslak:
        return 'Yarış beyinleri, spor egzoz, turbo ve alaşım jantlar';
      case ScrapyardZoneType.sasmaz:
        return 'Klasik Alman ve Amerikan parça, retro döşeme ve gövde';
      case ScrapyardZoneType.harabe:
        return 'Eski samanlıklarda unutulmuş efsanevi şasiler ve ralli sandıkları';
    }
  }

  double get cost {
    switch (this) {
      case ScrapyardZoneType.ostim:
        return 2500.0;
      case ScrapyardZoneType.maslak:
        return 6000.0;
      case ScrapyardZoneType.sasmaz:
        return 4000.0;
      case ScrapyardZoneType.harabe:
        return 12000.0;
    }
  }

  IconData get icon {
    switch (this) {
      case ScrapyardZoneType.ostim:
        return Icons.factory_rounded;
      case ScrapyardZoneType.maslak:
        return Icons.speed_rounded;
      case ScrapyardZoneType.sasmaz:
        return Icons.warehouse_rounded;
      case ScrapyardZoneType.harabe:
        return Icons.agriculture_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ScrapyardZoneType.ostim:
        return const Color(0xFFF59E0B);
      case ScrapyardZoneType.maslak:
        return const Color(0xFFA855F7);
      case ScrapyardZoneType.sasmaz:
        return const Color(0xFF3B82F6);
      case ScrapyardZoneType.harabe:
        return const Color(0xFF10B981);
    }
  }

  static String getDailySanayiRumor(int currentDay) {
    const rumors = [
      'Ostim de gümrük tasfiye tırı yanaştı • Ağır şanzıman ve blok parçaları bol!',
      'Maslak Tuning Hangarlarında yarış sezonu başladı • Spor parçalar revaçta!',
      'Şaşmaz Hurdalığında klasik Alman serisi döküldü • Orijinal parçalar keşfedilebilir!',
      'Terk Edilmiş Çiftlik samanlıklarında eski ralli ve efsane klasik şasileri tespit edildi!',
      'Geri dönüşüm tesisine taze hurda konvoyu girdi • Söküm kâr marjları yüksek!',
    ];
    return rumors[currentDay % rumors.length];
  }
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

  /// Refurbishing cost in the workshop
  double get refurbishCost {
    final cost = (estimatedValue * 0.18).clamp(800.0, 5000.0);
    return (cost / 100).roundToDouble() * 100;
  }

  bool get canRefurbish => tier != PartQualityTier.pristine && conditionPercent < 90;

  /// Refurbish / Restore the part in workshop
  SalvagedPart refurbish() {
    if (!canRefurbish) return this;

    final newCondition = (conditionPercent + 35).clamp(55, 95);
    PartQualityTier newTier;
    double valueMultiplier;

    if (newCondition >= 90) {
      newTier = PartQualityTier.pristine;
      valueMultiplier = 1.45;
    } else if (newCondition >= 65) {
      newTier = PartQualityTier.good;
      valueMultiplier = 1.30;
    } else {
      newTier = PartQualityTier.usable;
      valueMultiplier = 1.20;
    }

    final newValue = (estimatedValue * valueMultiplier / 100).roundToDouble() * 100;

    return copyWith(
      conditionPercent: newCondition,
      tier: newTier,
      estimatedValue: newValue,
    );
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
  final int chassisScrapMetalWeightKg;
  final double chassisScrapValue;
  final String? surpriseFindItem;
  final double surpriseFindValue;

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
    this.chassisScrapMetalWeightKg = 1100,
    this.chassisScrapValue = 6600.0,
    this.surpriseFindItem,
    this.surpriseFindValue = 0.0,
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
    int? chassisScrapMetalWeightKg,
    double? chassisScrapValue,
    String? surpriseFindItem,
    double? surpriseFindValue,
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
      chassisScrapMetalWeightKg: chassisScrapMetalWeightKg ?? this.chassisScrapMetalWeightKg,
      chassisScrapValue: chassisScrapValue ?? this.chassisScrapValue,
      surpriseFindItem: surpriseFindItem ?? this.surpriseFindItem,
      surpriseFindValue: surpriseFindValue ?? this.surpriseFindValue,
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
      'chassisScrapMetalWeightKg': chassisScrapMetalWeightKg,
      'chassisScrapValue': chassisScrapValue,
      'surpriseFindItem': surpriseFindItem,
      'surpriseFindValue': surpriseFindValue,
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
      chassisScrapMetalWeightKg: json['chassisScrapMetalWeightKg'] as int? ?? 1100,
      chassisScrapValue: (json['chassisScrapValue'] as num?)?.toDouble() ?? 6600.0,
      surpriseFindItem: json['surpriseFindItem'] as String?,
      surpriseFindValue: (json['surpriseFindValue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// 12 Categories of Auto Parts Generator with Realistic Turkish Scrapyard Tuning
  static List<SalvagedPart> generateRandomParts(String carName, double carBasePrice) {
    final rand = Random();
    final categories = [
      {'cat': 'engine', 'name': 'Komple Motor Bloğu', 'baseMult': 0.28},
      {'cat': 'transmission', 'name': 'Otomatik/Manuel Şanzıman', 'baseMult': 0.18},
      {'cat': 'turbo', 'name': 'Orijinal Turbo Şarj', 'baseMult': 0.12},
      {'cat': 'ecu', 'name': 'Motor Beyni • ECU', 'baseMult': 0.08},
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
        estimatedValue: (baseVal.roundToDouble() / 100).round() * 100,
      );
    }).toList();
  }
}

class ChassisCrushResult {
  final bool success;
  final double scrapMetalEarned;
  final double surpriseEarned;
  final String? surpriseItemName;
  final String message;

  const ChassisCrushResult({
    required this.success,
    required this.scrapMetalEarned,
    required this.surpriseEarned,
    this.surpriseItemName,
    required this.message,
  });
}

class B2BPartOrder {
  final String id;
  final String mechanicName;
  final String mechanicAvatar;
  final String requiredCategory;
  final String? requiredCarBrand;
  final PartQualityTier minQualityTier;
  final double offeredPrice;
  final int reputationReward;
  final String description;
  final int expiresInDays;
  final bool isCompleted;

  IconData get avatarIcon {
    switch (mechanicAvatar) {
      case 'haydar':
        return Icons.engineering_rounded;
      case 'ibo':
        return Icons.inventory_2_rounded;
      case 'berk':
        return Icons.sports_score_rounded;
      case 'sahin':
        return Icons.bolt_rounded;
      default:
        return Icons.build_rounded;
    }
  }

  const B2BPartOrder({
    required this.id,
    required this.mechanicName,
    this.mechanicAvatar = 'mechanic',
    required this.requiredCategory,
    this.requiredCarBrand,
    required this.minQualityTier,
    required this.offeredPrice,
    required this.reputationReward,
    required this.description,
    required this.expiresInDays,
    this.isCompleted = false,
  });

  B2BPartOrder copyWith({
    String? id,
    String? mechanicName,
    String? mechanicAvatar,
    String? requiredCategory,
    String? requiredCarBrand,
    PartQualityTier? minQualityTier,
    double? offeredPrice,
    int? reputationReward,
    String? description,
    int? expiresInDays,
    bool? isCompleted,
  }) {
    return B2BPartOrder(
      id: id ?? this.id,
      mechanicName: mechanicName ?? this.mechanicName,
      mechanicAvatar: mechanicAvatar ?? this.mechanicAvatar,
      requiredCategory: requiredCategory ?? this.requiredCategory,
      requiredCarBrand: requiredCarBrand ?? this.requiredCarBrand,
      minQualityTier: minQualityTier ?? this.minQualityTier,
      offeredPrice: offeredPrice ?? this.offeredPrice,
      reputationReward: reputationReward ?? this.reputationReward,
      description: description ?? this.description,
      expiresInDays: expiresInDays ?? this.expiresInDays,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mechanicName': mechanicName,
      'mechanicAvatar': mechanicAvatar,
      'requiredCategory': requiredCategory,
      'requiredCarBrand': requiredCarBrand,
      'minQualityTier': minQualityTier.name,
      'offeredPrice': offeredPrice,
      'reputationReward': reputationReward,
      'description': description,
      'expiresInDays': expiresInDays,
      'isCompleted': isCompleted,
    };
  }

  factory B2BPartOrder.fromJson(Map<String, dynamic> json) {
    return B2BPartOrder(
      id: json['id'] as String? ?? 'order_${DateTime.now().millisecondsSinceEpoch}',
      mechanicName: json['mechanicName'] as String? ?? 'Sanayi Ustası',
      mechanicAvatar: json['mechanicAvatar'] as String? ?? 'mechanic',
      requiredCategory: json['requiredCategory'] as String? ?? 'engine',
      requiredCarBrand: json['requiredCarBrand'] as String?,
      minQualityTier: PartQualityTier.values.firstWhere(
        (e) => e.name == json['minQualityTier'],
        orElse: () => PartQualityTier.usable,
      ),
      offeredPrice: (json['offeredPrice'] as num?)?.toDouble() ?? 15000.0,
      reputationReward: json['reputationReward'] as int? ?? 5,
      description: json['description'] as String? ?? 'Acil parça aranıyor.',
      expiresInDays: json['expiresInDays'] as int? ?? 3,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  /// Generate dynamic B2B orders from Sanayi NPCs
  static List<B2BPartOrder> generateDailyOrders(int day) {
    final allOrders = [
      B2BPartOrder(
        id: 'order_${day}_haydar',
        mechanicName: 'Haydar Usta • Motor & Mekanik',
        mechanicAvatar: 'haydar',
        requiredCategory: 'transmission',
        requiredCarBrand: 'Volkswagen',
        minQualityTier: PartQualityTier.usable,
        offeredPrice: 36000.0,
        reputationReward: 6,
        description: 'Müşterinin Passat aracı liftte askıda kaldı, acil temiz şanzıman aranıyor!',
        expiresInDays: 3,
      ),
      B2BPartOrder(
        id: 'order_${day}_ibo',
        mechanicName: 'Çıkmacı İbo • Yedek Parça Deposu',
        mechanicAvatar: 'ibo',
        requiredCategory: 'engine',
        requiredCarBrand: 'BMW',
        minQualityTier: PartQualityTier.usable,
        offeredPrice: 48000.0,
        reputationReward: 8,
        description: 'E46 / E90 kasaya uyumlu 6 silindir veya temiz motor bloğu lazım, peşin öderim!',
        expiresInDays: 4,
      ),
      B2BPartOrder(
        id: 'order_${day}_berk',
        mechanicName: 'Tuning Berk • Performans Garajı',
        mechanicAvatar: 'berk',
        requiredCategory: 'turbo',
        requiredCarBrand: null,
        minQualityTier: PartQualityTier.good,
        offeredPrice: 28000.0,
        reputationReward: 5,
        description: 'Pist projesi için sağlam turbo şarj arıyoruz. Kondisyonu yüksek olmalı!',
        expiresInDays: 2,
      ),
      B2BPartOrder(
        id: 'order_${day}_sahin',
        mechanicName: 'Elektrikçi Şahin Usta',
        mechanicAvatar: 'sahin',
        requiredCategory: 'ecu',
        requiredCarBrand: null,
        minQualityTier: PartQualityTier.usable,
        offeredPrice: 18000.0,
        reputationReward: 4,
        description: 'Beyin arızalı bir araç geldi, sağlam ve temiz bir motor beyni aranıyor.',
        expiresInDays: 3,
      ),
      B2BPartOrder(
        id: 'order_${day}_riza',
        mechanicName: 'Kaportacı Rıza Usta',
        mechanicAvatar: 'haydar',
        requiredCategory: 'seats',
        requiredCarBrand: 'Mercedes-Benz',
        minQualityTier: PartQualityTier.good,
        offeredPrice: 32000.0,
        reputationReward: 6,
        description: 'Restorasyondaki W124 için hatasız orijinal deri koltuk takımı arıyorum.',
        expiresInDays: 4,
      ),
      B2BPartOrder(
        id: 'order_${day}_veli',
        mechanicName: 'Egzozcu Veli',
        mechanicAvatar: 'berk',
        requiredCategory: 'catalytic',
        requiredCarBrand: null,
        minQualityTier: PartQualityTier.usable,
        offeredPrice: 22000.0,
        reputationReward: 5,
        description: 'Muayeneden kalan bir araç için orijinal katalitik konvertör lazım, acil.',
        expiresInDays: 2,
      ),
      B2BPartOrder(
        id: 'order_${day}_selahattin',
        mechanicName: 'Frenci Selahattin',
        mechanicAvatar: 'haydar',
        requiredCategory: 'brakes',
        requiredCarBrand: 'Audi',
        minQualityTier: PartQualityTier.good,
        offeredPrice: 19500.0,
        reputationReward: 4,
        description: 'Quattro fren revizyonu için temiz kaliper ve hava kanallı disk takımı.',
        expiresInDays: 3,
      ),
      B2BPartOrder(
        id: 'order_${day}_kadir',
        mechanicName: 'Radyatörcü Kadir',
        mechanicAvatar: 'sahin',
        requiredCategory: 'radiator',
        requiredCarBrand: null,
        minQualityTier: PartQualityTier.usable,
        offeredPrice: 14000.0,
        reputationReward: 3,
        description: 'Hararet yapan ticari minibüs için sağlam çift fanlı radyatör arıyoruz.',
        expiresInDays: 2,
      ),
    ];

    final rand = Random(day * 43 + 89);
    allOrders.shuffle(rand);
    return allOrders.take(4).toList();
  }
}

class SinglePartDismantleResult {
  final bool success;
  final bool isSalvaged;
  final SalvagedPart? part;
  final String message;

  const SinglePartDismantleResult({
    required this.success,
    required this.isSalvaged,
    this.part,
    required this.message,
  });
}

class BulkScrapDismantleResult {
  final bool success;
  final int totalPartsCount;
  final int salvagedCount;
  final int lostCount;
  final List<SalvagedPart> salvagedParts;
  final List<SalvagedPart> lostParts;
  final double costPaid;
  final String message;

  const BulkScrapDismantleResult({
    required this.success,
    this.totalPartsCount = 0,
    this.salvagedCount = 0,
    this.lostCount = 0,
    this.salvagedParts = const [],
    this.lostParts = const [],
    this.costPaid = 0.0,
    required this.message,
  });
}

