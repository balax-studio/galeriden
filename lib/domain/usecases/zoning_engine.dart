import 'dart:math';

class ZoningUnitMix {
  final int units1Plus0; // Stüdyo • 45 m² brüt • 38 m² net
  final int units1Plus1; // 1+1 Kompakt • 65 m² brüt • 55 m² net
  final int units2Plus0; // 2+0 Amerikan Mutfak • 80 m² brüt • 68 m² net
  final int units2Plus1; // 2+1 Standart Aile • 105 m² brüt • 88 m² net
  final int units3Plus1; // 3+1 Ferah Rezidans • 135 m² brüt • 115 m² net
  final int units4Plus1; // 4+1 Geniş Dubleks • 175 m² brüt • 150 m² net

  const ZoningUnitMix({
    this.units1Plus0 = 0,
    required this.units1Plus1,
    this.units2Plus0 = 0,
    required this.units2Plus1,
    required this.units3Plus1,
    this.units4Plus1 = 0,
  });

  static const double grossArea1Plus0 = 45.0;
  static const double netArea1Plus0 = 38.0;

  static const double grossArea1Plus1 = 65.0;
  static const double netArea1Plus1 = 55.0;

  static const double grossArea2Plus0 = 80.0;
  static const double netArea2Plus0 = 68.0;

  static const double grossArea2Plus1 = 105.0;
  static const double netArea2Plus1 = 88.0;

  static const double grossArea3Plus1 = 135.0;
  static const double netArea3Plus1 = 115.0;

  static const double grossArea4Plus1 = 175.0;
  static const double netArea4Plus1 = 150.0;

  int get totalUnits =>
      units1Plus0 +
      units1Plus1 +
      units2Plus0 +
      units2Plus1 +
      units3Plus1 +
      units4Plus1;

  double get totalGrossArea =>
      (units1Plus0 * grossArea1Plus0) +
      (units1Plus1 * grossArea1Plus1) +
      (units2Plus0 * grossArea2Plus0) +
      (units2Plus1 * grossArea2Plus1) +
      (units3Plus1 * grossArea3Plus1) +
      (units4Plus1 * grossArea4Plus1);

  double get totalNetArea =>
      (units1Plus0 * netArea1Plus0) +
      (units1Plus1 * netArea1Plus1) +
      (units2Plus0 * netArea2Plus0) +
      (units2Plus1 * netArea2Plus1) +
      (units3Plus1 * netArea3Plus1) +
      (units4Plus1 * netArea4Plus1);

  ZoningUnitMix copyWith({
    int? units1Plus0,
    int? units1Plus1,
    int? units2Plus0,
    int? units2Plus1,
    int? units3Plus1,
    int? units4Plus1,
  }) {
    return ZoningUnitMix(
      units1Plus0: units1Plus0 ?? this.units1Plus0,
      units1Plus1: units1Plus1 ?? this.units1Plus1,
      units2Plus0: units2Plus0 ?? this.units2Plus0,
      units2Plus1: units2Plus1 ?? this.units2Plus1,
      units3Plus1: units3Plus1 ?? this.units3Plus1,
      units4Plus1: units4Plus1 ?? this.units4Plus1,
    );
  }

  Map<String, dynamic> toMap() => {
        'units1Plus0': units1Plus0,
        'units1Plus1': units1Plus1,
        'units2Plus0': units2Plus0,
        'units2Plus1': units2Plus1,
        'units3Plus1': units3Plus1,
        'units4Plus1': units4Plus1,
      };

  factory ZoningUnitMix.fromMap(Map<String, dynamic> map) {
    return ZoningUnitMix(
      units1Plus0: (map['units1Plus0'] as num?)?.toInt() ?? 0,
      units1Plus1: (map['units1Plus1'] as num?)?.toInt() ?? 0,
      units2Plus0: (map['units2Plus0'] as num?)?.toInt() ?? 0,
      units2Plus1: (map['units2Plus1'] as num?)?.toInt() ?? 0,
      units3Plus1: (map['units3Plus1'] as num?)?.toInt() ?? 0,
      units4Plus1: (map['units4Plus1'] as num?)?.toInt() ?? 0,
    );
  }

  String get summaryText {
    final parts = <String>[];
    if (units1Plus0 > 0) parts.add('$units1Plus0 adet 1+0');
    if (units1Plus1 > 0) parts.add('$units1Plus1 adet 1+1');
    if (units2Plus0 > 0) parts.add('$units2Plus0 adet 2+0');
    if (units2Plus1 > 0) parts.add('$units2Plus1 adet 2+1');
    if (units3Plus1 > 0) parts.add('$units3Plus1 adet 3+1');
    if (units4Plus1 > 0) parts.add('$units4Plus1 adet 4+1');
    if (parts.isEmpty) return '0 Daire';
    return parts.join(' • ');
  }
}

class ZoningProfile {
  final double parcelSquareMeters;
  final double taks; // Taban Alanı Kat Sayısı • 0.20 - 0.40
  final double kaks; // Kat Alanı Kat Sayısı / Emsal • 1.20 - 2.50
  final int maxFloors;
  final double baseGroundArea;
  final double totalConstructionArea;
  final int calculatedFloors;
  final ZoningUnitMix unitMix;
  final int estimatedDurationDays;
  final int inGameEstimatedDays;
  final double turnkeyEstimatedUnitValue;
  final double totalProjectGrossValue;

  const ZoningProfile({
    required this.parcelSquareMeters,
    required this.taks,
    required this.kaks,
    required this.maxFloors,
    required this.baseGroundArea,
    required this.totalConstructionArea,
    required this.calculatedFloors,
    required this.unitMix,
    required this.estimatedDurationDays,
    required this.inGameEstimatedDays,
    required this.turnkeyEstimatedUnitValue,
    required this.totalProjectGrossValue,
  });

  int get totalUnits => unitMix.totalUnits;
  double get footprintArea => baseGroundArea;
  double get estimatedProjectValue => totalProjectGrossValue;

  /// Net residential independent section area • 85% of total gross emsal area
  double get netResidentialArea => totalConstructionArea * 0.85;

  /// Currently consumed gross apartment emsal area from the unit mix
  double get consumedEmsalArea => unitMix.totalGrossArea;

  /// Remaining allowable emsal area for construction
  double get remainingEmsalArea =>
      (netResidentialArea - consumedEmsalArea).clamp(0.0, netResidentialArea);

  /// Emsal capacity utilization ratio • 0.0 to 1.0+
  double get emsalUtilizationRatio =>
      netResidentialArea > 0 ? (consumedEmsalArea / netResidentialArea) : 0.0;

  /// Whether current mix exceeds municipal zoning limit
  bool get isEmsalExceeded => consumedEmsalArea > netResidentialArea + 0.01;
}

class ContractorProfile {
  final String id;
  final String name;
  final String title;
  final int defaultPlayerSharePercent; // 40 to 60
  final double durationMultiplier;
  final double reliabilityScore; // 0.0 to 1.0
  final String description;

  const ContractorProfile({
    required this.id,
    required this.name,
    required this.title,
    required this.defaultPlayerSharePercent,
    required this.durationMultiplier,
    required this.reliabilityScore,
    required this.description,
  });

  int get minShare => 40;
  int get maxShare => 60;
  double get rating => reliabilityScore * 5.0;
}

class ZoningEngine {
  static const List<ContractorProfile> standardContractors = [
    ContractorProfile(
      id: 'metropol_yapi',
      name: 'Metropol Yapı Mimarlık',
      title: 'Kurumsal ve Yüksek Prestij',
      defaultPlayerSharePercent: 50,
      durationMultiplier: 1.0,
      reliabilityScore: 0.95,
      description: 'Zamanında teslim garantisi ve C35 betonarme kalitesi sunan kurumsal inşaat firması.',
    ),
    ContractorProfile(
      id: 'oz_gozde_insaat',
      name: 'Öz - Gözde İnşaat',
      title: 'Hızlı ve Pratik Teslimat',
      defaultPlayerSharePercent: 55,
      durationMultiplier: 0.85,
      reliabilityScore: 0.88,
      description: 'Geniş taşeron ağıyla şantiyeyi hızla tamamlar, kardan daha yüksek pay bırakır.',
    ),
    ContractorProfile(
      id: 'kardesler_kolektif',
      name: 'Taşeron Kardeşler Kollektif',
      title: 'Ekonomik ve Esnek',
      defaultPlayerSharePercent: 45,
      durationMultiplier: 1.15,
      reliabilityScore: 0.80,
      description: 'Agresif maliyet düşüşü hedefler ancak tedarik zinciri aksamalarına açıktır.',
    ),
  ];

  /// Returns district-based zoning benchmarks (F1·2, F1·3)
  static ({double taks, double kaks, int maxFloors}) getDistrictZoningDefaults(String? district, double safeArea) {
    if (district != null && district.trim().isNotEmpty) {
      final d = district.toLowerCase();
      // High-density business/skyscraper hubs (Maslak, Şişli, Levent, Ataşehir)
      if (d.contains('maslak') || d.contains('şişli') || d.contains('sisli') || d.contains('levent') || d.contains('ataşehir') || d.contains('atasehir')) {
        return (taks: 0.38, kaks: 2.40, maxFloors: 12);
      }
      // Low-density villa / suburban / coastal / green districts (Sarıyer, Beylikdüzü, Gölbaşı, Urla, Çeşme, Bodrum)
      if (d.contains('sarıyer') || d.contains('sariyer') || d.contains('beylikdüzü') || d.contains('beylikduzu') || d.contains('gölbaşı') || d.contains('golbasi') || d.contains('urla') || d.contains('çeşme') || d.contains('cesme') || d.contains('bodrum') || d.contains('şile') || d.contains('sile')) {
        return (taks: 0.28, kaks: 1.35, maxFloors: 4);
      }
      // Standard urban core districts (Kadıköy, Beşiktaş, Üsküdar, Çankaya, Karşıyaka)
      if (d.contains('kadıköy') || d.contains('kadikoy') || d.contains('beşiktaş') || d.contains('besiktas') || d.contains('üsküdar') || d.contains('uskudar') || d.contains('çankaya') || d.contains('cankaya') || d.contains('karşıyaka') || d.contains('karsiyaka')) {
        return (taks: 0.32, kaks: 1.85, maxFloors: 7);
      }
    }
    // Fallback based on parcel size
    final defTaks = safeArea >= 1500 ? 0.35 : 0.30;
    final defKaks = safeArea >= 1500 ? 2.10 : (safeArea >= 800 ? 1.80 : 1.50);
    final defFloors = safeArea >= 1500 ? 7 : 5;
    return (taks: defTaks, kaks: defKaks, maxFloors: defFloors);
  }

  /// Calculates zoning and architectural yield metrics for a given land parcel
  static ZoningProfile calculateZoning({
    required double parcelSquareMeters,
    String? district,
    double? customTaks,
    double? customKaks,
    int? customMaxFloors,
    double? baseMarketValue,
    ZoningUnitMix? customUnitMix,
  }) {
    final safeArea = parcelSquareMeters <= 0 ? 100.0 : parcelSquareMeters;
    final defaults = getDistrictZoningDefaults(district, safeArea);

    // Determine realistic zoning coefficients based on district and parcel area
    final taks = customTaks ?? defaults.taks;
    final kaks = customKaks ?? defaults.kaks;
    final maxFloors = customMaxFloors ?? defaults.maxFloors;

    final baseGroundArea = (safeArea * taks).roundToDouble();
    final totalConstructionArea = (safeArea * kaks).roundToDouble();

    final rawFloors = baseGroundArea > 0 ? (totalConstructionArea / baseGroundArea).ceil() : 4;
    final calculatedFloors = rawFloors.clamp(3, maxFloors);

    // Usable net apartment area calculation • 85% usable, 15% core / shaft / stairwell
    final netResidentialArea = totalConstructionArea * 0.85;

    final unitMix = customUnitMix ?? optimizeUnitMix(netResidentialArea);
    final totalUnits = max(1, unitMix.totalUnits);

    // Duration formula: 120 + (totalUnits * 8) + (calculatedFloors * 5) calendar days
    final estimatedDurationDays = 120 + (totalUnits * 8) + (calculatedFloors * 5);
    // In-game milestone steps: standard 5-6 in-game days
    final inGameDays = (estimatedDurationDays / 25).ceil().clamp(4, 12);

    final marketValue = baseMarketValue ?? (safeArea * 5000.0);
    // F1·4: Emsal ve imar kalitesi primi (yüksek emsalli projede birim değer artar)
    final emsalPremium = 1.0 + ((kaks - 1.5) * 0.10).clamp(-0.15, 0.25);
    final turnkeyUnitPrice = totalUnits > 0
        ? (((marketValue * 2.6) / totalUnits) * emsalPremium).roundToDouble()
        : 3500000.0;
    final totalProjectGrossValue = (turnkeyUnitPrice * totalUnits).roundToDouble();

    return ZoningProfile(
      parcelSquareMeters: safeArea,
      taks: taks,
      kaks: kaks,
      maxFloors: maxFloors,
      baseGroundArea: baseGroundArea,
      totalConstructionArea: totalConstructionArea,
      calculatedFloors: calculatedFloors,
      unitMix: unitMix,
      estimatedDurationDays: estimatedDurationDays,
      inGameEstimatedDays: inGameDays,
      turnkeyEstimatedUnitValue: turnkeyUnitPrice,
      totalProjectGrossValue: totalProjectGrossValue,
    );
  }

  /// Automatically optimizes apartment distribution to match 95% - 100% of available net emsal area
  static ZoningUnitMix optimizeUnitMix(double netResidentialArea) {
    if (netResidentialArea <= 0) {
      return const ZoningUnitMix(
        units1Plus0: 0,
        units1Plus1: 1,
        units2Plus0: 0,
        units2Plus1: 1,
        units3Plus1: 1,
        units4Plus1: 0,
      );
    }

    // Typical urban yield ratio:
    // 1+0: 8%, 1+1: 22%, 2+0: 12%, 2+1: 34%, 3+1: 18%, 4+1: 6% (if area > 1000)
    int u1_0 = (netResidentialArea * 0.08 / ZoningUnitMix.grossArea1Plus0).floor();
    int u1_1 = (netResidentialArea * 0.22 / ZoningUnitMix.grossArea1Plus1).floor();
    int u2_0 = (netResidentialArea * 0.12 / ZoningUnitMix.grossArea2Plus0).floor();
    int u2_1 = (netResidentialArea * 0.34 / ZoningUnitMix.grossArea2Plus1).floor();
    int u3_1 = (netResidentialArea * 0.18 / ZoningUnitMix.grossArea3Plus1).floor();
    int u4_1 = netResidentialArea >= 1200
        ? (netResidentialArea * 0.06 / ZoningUnitMix.grossArea4Plus1).floor()
        : 0;

    // Calculate current consumption
    double currentGross = (u1_0 * ZoningUnitMix.grossArea1Plus0) +
        (u1_1 * ZoningUnitMix.grossArea1Plus1) +
        (u2_0 * ZoningUnitMix.grossArea2Plus0) +
        (u2_1 * ZoningUnitMix.grossArea2Plus1) +
        (u3_1 * ZoningUnitMix.grossArea3Plus1) +
        (u4_1 * ZoningUnitMix.grossArea4Plus1);

    // Greedily fit remaining square meters into 1+1, 2+1 or 1+0
    double remaining = netResidentialArea - currentGross;
    while (remaining >= ZoningUnitMix.grossArea1Plus0) {
      if (remaining >= ZoningUnitMix.grossArea2Plus1) {
        u2_1++;
        remaining -= ZoningUnitMix.grossArea2Plus1;
      } else if (remaining >= ZoningUnitMix.grossArea1Plus1) {
        u1_1++;
        remaining -= ZoningUnitMix.grossArea1Plus1;
      } else {
        u1_0++;
        remaining -= ZoningUnitMix.grossArea1Plus0;
      }
    }

    // Ensure at least minimum viable unit mix
    if (u1_0 + u1_1 + u2_0 + u2_1 + u3_1 + u4_1 == 0) {
      u1_1 = 1;
      u2_1 = 1;
      u3_1 = 1;
    }

    return ZoningUnitMix(
      units1Plus0: max(0, u1_0),
      units1Plus1: max(0, u1_1),
      units2Plus0: max(0, u2_0),
      units2Plus1: max(0, u2_1),
      units3Plus1: max(0, u3_1),
      units4Plus1: max(0, u4_1),
    );
  }
}
