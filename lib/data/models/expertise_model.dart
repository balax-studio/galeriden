enum PartStatus { original, painted, changed, damaged }

class ExpertiseReport {
  final double engineCondition; // 0 - 100%
  final double transmissionCondition; // 0 - 100%
  final int tramerAmount; // ₺ TL Damage history record
  final int mileage; // km
  final bool isMileageTampered;
  final Map<String, PartStatus> bodyParts; // e.g. 'Kaput', 'Tavan', 'Sol Kapı'

  ExpertiseReport({
    required this.engineCondition,
    required this.transmissionCondition,
    required this.tramerAmount,
    required this.mileage,
    required this.isMileageTampered,
    required this.bodyParts,
  });

  Map<String, dynamic> toJson() {
    return {
      'engineCondition': engineCondition,
      'transmissionCondition': transmissionCondition,
      'tramerAmount': tramerAmount,
      'mileage': mileage,
      'isMileageTampered': isMileageTampered,
      'bodyParts': bodyParts.map((key, value) => MapEntry(key, value.name)),
    };
  }

  factory ExpertiseReport.fromJson(Map<String, dynamic> json) {
    final rawParts = json['bodyParts'] as Map<String, dynamic>? ?? {};
    final bodyPartsMap = rawParts.map((key, value) {
      final status = PartStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => PartStatus.original,
      );
      return MapEntry(key, status);
    });

    return ExpertiseReport(
      engineCondition: (json['engineCondition'] as num).toDouble(),
      transmissionCondition: (json['transmissionCondition'] as num).toDouble(),
      tramerAmount: json['tramerAmount'] as int,
      mileage: json['mileage'] as int,
      isMileageTampered: json['isMileageTampered'] as bool? ?? false,
      bodyParts: bodyPartsMap,
    );
  }
}
