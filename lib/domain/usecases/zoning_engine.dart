import 'dart:math';

class ZoningUnitMix {
  final int units1Plus1;
  final int units2Plus1;
  final int units3Plus1;

  const ZoningUnitMix({
    required this.units1Plus1,
    required this.units2Plus1,
    required this.units3Plus1,
  });

  int get totalUnits => units1Plus1 + units2Plus1 + units3Plus1;

  String get summaryText =>
      '$units1Plus1 adet 1+1 • $units2Plus1 adet 2+1 • $units3Plus1 adet 3+1';
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

  /// Calculates zoning and architectural yield metrics for a given land parcel
  static ZoningProfile calculateZoning({
    required double parcelSquareMeters,
    double? customTaks,
    double? customKaks,
    int? customMaxFloors,
    double? baseMarketValue,
  }) {
    final safeArea = parcelSquareMeters <= 0 ? 100.0 : parcelSquareMeters;

    // Determine realistic zoning coefficients based on parcel area
    final taks = customTaks ?? (safeArea >= 1500 ? 0.35 : 0.30);
    final kaks = customKaks ?? (safeArea >= 1500 ? 2.10 : (safeArea >= 800 ? 1.80 : 1.50));
    final maxFloors = customMaxFloors ?? (safeArea >= 1500 ? 7 : 5);

    final baseGroundArea = (safeArea * taks).roundToDouble();
    final totalConstructionArea = (safeArea * kaks).roundToDouble();

    final rawFloors = baseGroundArea > 0 ? (totalConstructionArea / baseGroundArea).ceil() : 4;
    final calculatedFloors = rawFloors.clamp(3, maxFloors);

    // Usable net apartment area calculation • 85% usable, 15% core / shaft / stairwell
    final netResidentialArea = totalConstructionArea * 0.85;

    // Unit mix distribution: 20% 1+1 (55m²), 50% 2+1 (85m²), 30% 3+1 (120m²)
    int u1 = (netResidentialArea * 0.20 / 55.0).round();
    int u2 = (netResidentialArea * 0.50 / 85.0).round();
    int u3 = (netResidentialArea * 0.30 / 120.0).round();

    // Ensure at least minimum viable project distribution
    if (u1 + u2 + u3 < 4) {
      u1 = max(1, u1);
      u2 = max(2, u2);
      u3 = max(1, u3);
    }

    final unitMix = ZoningUnitMix(
      units1Plus1: u1,
      units2Plus1: u2,
      units3Plus1: u3,
    );

    final totalUnits = unitMix.totalUnits;

    // Duration formula: 120 + (totalUnits * 8) + (calculatedFloors * 5) calendar days
    final estimatedDurationDays = 120 + (totalUnits * 8) + (calculatedFloors * 5);
    // In-game milestone steps: standard 5-6 in-game days
    final inGameDays = (estimatedDurationDays / 25).ceil().clamp(4, 12);

    final marketValue = baseMarketValue ?? (safeArea * 5000.0);
    final turnkeyUnitPrice = totalUnits > 0
        ? ((marketValue * 2.6) / totalUnits).roundToDouble()
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
}
