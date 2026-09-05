import 'dart:math';

/// Daire tipi ve metrekare standartları
enum ApartmentType {
  onePlusOne(55, '1+1', 0.55),
  twoPlusOne(85, '2+1', 0.85),
  threePlusOne(120, '3+1', 1.20);

  final int squareMeters;
  final String label;
  final double valueMultiplier;

  const ApartmentType(this.squareMeters, this.label, this.valueMultiplier);
}

/// Mimari proje konsept şablonu
enum ArchitecturalConcept {
  balanced, // Dengeli Aile & Yatırım (%20 1+1, %50 2+1, %30 3+1)
  compact, // Yatırımcı & Öğrenci Odaklı (%60 1+1, %40 2+1)
  familyLuxury, // Geniş Lüks Aile Konsepti (%50 2+1, %50 3+1)
}

/// Hesaplanmış daire karması ve değerleme sonucu
class ArchitecturalProjectPlan {
  final double parcelSquareMeters;
  final double taks;
  final double kaks;
  final double footprintArea;
  final double grossConstructionArea;
  final double netResidentialArea;
  final int calculatedFloors;
  final int units1Plus1;
  final int units2Plus1;
  final int units3Plus1;
  final double pricePerUnit1Plus1;
  final double pricePerUnit2Plus1;
  final double pricePerUnit3Plus1;
  final ArchitecturalConcept concept;

  const ArchitecturalProjectPlan({
    required this.parcelSquareMeters,
    required this.taks,
    required this.kaks,
    required this.footprintArea,
    required this.grossConstructionArea,
    required this.netResidentialArea,
    required this.calculatedFloors,
    required this.units1Plus1,
    required this.units2Plus1,
    required this.units3Plus1,
    required this.pricePerUnit1Plus1,
    required this.pricePerUnit2Plus1,
    required this.pricePerUnit3Plus1,
    required this.concept,
  });

  int get totalUnits => units1Plus1 + units2Plus1 + units3Plus1;

  double get totalProjectGrossValue =>
      (units1Plus1 * pricePerUnit1Plus1) +
      (units2Plus1 * pricePerUnit2Plus1) +
      (units3Plus1 * pricePerUnit3Plus1);

  double get averageUnitPrice =>
      totalUnits > 0 ? totalProjectGrossValue / totalUnits : 0.0;

  String get summaryText =>
      '$units1Plus1 adet 1+1 • $units2Plus1 adet 2+1 • $units3Plus1 adet 3+1 • Toplam $totalUnits Daire';

  ArchitecturalProjectPlan copyWith({
    int? units1Plus1,
    int? units2Plus1,
    int? units3Plus1,
    double? pricePerUnit1Plus1,
    double? pricePerUnit2Plus1,
    double? pricePerUnit3Plus1,
    ArchitecturalConcept? concept,
  }) {
    return ArchitecturalProjectPlan(
      parcelSquareMeters: parcelSquareMeters,
      taks: taks,
      kaks: kaks,
      footprintArea: footprintArea,
      grossConstructionArea: grossConstructionArea,
      netResidentialArea: netResidentialArea,
      calculatedFloors: calculatedFloors,
      units1Plus1: units1Plus1 ?? this.units1Plus1,
      units2Plus1: units2Plus1 ?? this.units2Plus1,
      units3Plus1: units3Plus1 ?? this.units3Plus1,
      pricePerUnit1Plus1: pricePerUnit1Plus1 ?? this.pricePerUnit1Plus1,
      pricePerUnit2Plus1: pricePerUnit2Plus1 ?? this.pricePerUnit2Plus1,
      pricePerUnit3Plus1: pricePerUnit3Plus1 ?? this.pricePerUnit3Plus1,
      concept: concept ?? this.concept,
    );
  }
}

class ArchitecturalYieldEngine {
  /// KAKS ve arsa metrekaresine göre konsept bazlı mimari plan üretir
  static ArchitecturalProjectPlan generatePlan({
    required double parcelSquareMeters,
    double? customTaks,
    double? customKaks,
    double? baseMarketValue,
    ArchitecturalConcept concept = ArchitecturalConcept.balanced,
  }) {
    final safeArea = parcelSquareMeters <= 0 ? 100.0 : parcelSquareMeters;
    final taks = customTaks ?? (safeArea >= 1500 ? 0.35 : 0.30);
    final kaks = customKaks ??
        (safeArea >= 1500 ? 2.10 : (safeArea >= 800 ? 1.80 : 1.50));

    final footprintArea = (safeArea * taks).roundToDouble();
    final grossConstructionArea = (safeArea * kaks).roundToDouble();
    final netResidentialArea = grossConstructionArea * 0.85;

    final rawFloors = footprintArea > 0
        ? (grossConstructionArea / footprintArea).ceil()
        : 4;
    final maxAllowedFloors = safeArea >= 1500 ? 7 : 5;
    final calculatedFloors = rawFloors.clamp(3, maxAllowedFloors);

    int u1 = 0;
    int u2 = 0;
    int u3 = 0;

    switch (concept) {
      case ArchitecturalConcept.balanced:
        u1 = (netResidentialArea * 0.20 / ApartmentType.onePlusOne.squareMeters)
            .round();
        u2 = (netResidentialArea * 0.50 / ApartmentType.twoPlusOne.squareMeters)
            .round();
        u3 = (netResidentialArea * 0.30 / ApartmentType.threePlusOne.squareMeters)
            .round();
        break;
      case ArchitecturalConcept.compact:
        u1 = (netResidentialArea * 0.60 / ApartmentType.onePlusOne.squareMeters)
            .round();
        u2 = (netResidentialArea * 0.40 / ApartmentType.twoPlusOne.squareMeters)
            .round();
        u3 = 0;
        break;
      case ArchitecturalConcept.familyLuxury:
        u1 = 0;
        u2 = (netResidentialArea * 0.50 / ApartmentType.twoPlusOne.squareMeters)
            .round();
        u3 = (netResidentialArea * 0.50 / ApartmentType.threePlusOne.squareMeters)
            .round();
        break;
    }

    if (u1 + u2 + u3 < 3) {
      u1 = max(1, u1);
      u2 = max(1, u2);
      u3 = max(1, u3);
    }

    // Birim baz fiyat tahminleri (Arsa rayici üzerinden türetilir)
    final baselineLandValue = baseMarketValue ?? (safeArea * 12000.0);
    final baseTotalApartmentPool = baselineLandValue * 1.8;
    final totalWeightedArea = (u1 * ApartmentType.onePlusOne.squareMeters) +
        (u2 * ApartmentType.twoPlusOne.squareMeters) +
        (u3 * ApartmentType.threePlusOne.squareMeters);

    final double pricePerM2 = totalWeightedArea > 0
        ? baseTotalApartmentPool / totalWeightedArea
        : 35000.0;

    final p1 = ((pricePerM2 * ApartmentType.onePlusOne.squareMeters) / 25000)
            .round() *
        25000.0;
    final p2 = ((pricePerM2 * ApartmentType.twoPlusOne.squareMeters) / 25000)
            .round() *
        25000.0;
    final p3 = ((pricePerM2 * ApartmentType.threePlusOne.squareMeters) / 25000)
            .round() *
        25000.0;

    return ArchitecturalProjectPlan(
      parcelSquareMeters: safeArea,
      taks: taks,
      kaks: kaks,
      footprintArea: footprintArea,
      grossConstructionArea: grossConstructionArea,
      netResidentialArea: netResidentialArea,
      calculatedFloors: calculatedFloors,
      units1Plus1: u1,
      units2Plus1: u2,
      units3Plus1: u3,
      pricePerUnit1Plus1: max(1200000.0, p1),
      pricePerUnit2Plus1: max(1900000.0, p2),
      pricePerUnit3Plus1: max(2600000.0, p3),
      concept: concept,
    );
  }

  /// Oyuncunun belirlediği özel daire miksinin KAKS sınırlarına uygunluğunu denetler
  static bool validateCustomMix({
    required double parcelSquareMeters,
    required double kaks,
    required int units1Plus1,
    required int units2Plus1,
    required int units3Plus1,
  }) {
    final netResidentialArea = (parcelSquareMeters * kaks) * 0.85;
    final requiredArea =
        (units1Plus1 * ApartmentType.onePlusOne.squareMeters) +
        (units2Plus1 * ApartmentType.twoPlusOne.squareMeters) +
        (units3Plus1 * ApartmentType.threePlusOne.squareMeters);
    return requiredArea <= (netResidentialArea * 1.05); // %5 pay payı
  }
}
