enum PartStatus { original, painted, changed, damaged, localPainted }

class ExpertiseReport {
  final double engineCondition; // 0 - 100%
  final double transmissionCondition; // 0 - 100%
  final int tramerAmount; // ₺ TL Damage history record
  final int mileage; // km
  final bool isMileageTampered;
  final Map<String, PartStatus> bodyParts; // e.g. 'Kaput', 'Tavan', 'Sol Kapı'
  final Map<String, double> partConditions; // 0 - 100% condition score per part
  final bool isEcuCleaned;
  final bool isChassisAligned;
  final bool hasAirbagDeployed;

  ExpertiseReport({
    required this.engineCondition,
    required this.transmissionCondition,
    required this.tramerAmount,
    required this.mileage,
    required this.isMileageTampered,
    required this.bodyParts,
    Map<String, double>? partConditions,
    this.isEcuCleaned = false,
    this.isChassisAligned = true,
    this.hasAirbagDeployed = false,
  }) : partConditions = partConditions ?? _defaultConditions(bodyParts);

  static Map<String, double> _defaultConditions(Map<String, PartStatus> parts) {
    return parts.map((key, status) {
      switch (status) {
        case PartStatus.original:
          return MapEntry(key, 100.0);
        case PartStatus.painted:
          return MapEntry(key, 75.0);
        case PartStatus.localPainted:
          return MapEntry(key, 85.0);
        case PartStatus.changed:
          return MapEntry(key, 50.0);
        case PartStatus.damaged:
          return MapEntry(key, 20.0);
      }
    });
  }

  Map<String, dynamic> toJson() {
    return {
      'engineCondition': engineCondition,
      'transmissionCondition': transmissionCondition,
      'tramerAmount': tramerAmount,
      'mileage': mileage,
      'isMileageTampered': isMileageTampered,
      'bodyParts': bodyParts.map((key, value) => MapEntry(key, value.name)),
      'partConditions': partConditions,
      'isEcuCleaned': isEcuCleaned,
      'isChassisAligned': isChassisAligned,
      'hasAirbagDeployed': hasAirbagDeployed,
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

    final rawConditions = json['partConditions'] as Map<String, dynamic>?;
    final conditionsMap = rawConditions != null
        ? rawConditions.map((key, value) => MapEntry(key, (value as num?)?.toDouble() ?? 100.0))
        : _defaultConditions(bodyPartsMap);

    final tramer = (json['tramerAmount'] as num?)?.toInt() ?? 0;
    final isChassis = json['isChassisAligned'] as bool? ??
        (bodyPartsMap['Şasi/Podye'] != PartStatus.changed && bodyPartsMap['Şasi/Podye'] != PartStatus.damaged);
    final isAirbag = json['hasAirbagDeployed'] as bool? ?? (!isChassis && tramer > 45000);

    return ExpertiseReport(
      engineCondition: (json['engineCondition'] as num?)?.toDouble() ?? 100.0,
      transmissionCondition: (json['transmissionCondition'] as num?)?.toDouble() ?? 100.0,
      tramerAmount: tramer,
      mileage: (json['mileage'] as num?)?.toInt() ?? 50000,
      isMileageTampered: json['isMileageTampered'] as bool? ?? false,
      bodyParts: bodyPartsMap,
      partConditions: conditionsMap,
      isEcuCleaned: json['isEcuCleaned'] as bool? ?? false,
      isChassisAligned: isChassis,
      hasAirbagDeployed: isAirbag,
    );
  }

  ExpertiseReport copyWith({
    double? engineCondition,
    double? transmissionCondition,
    int? tramerAmount,
    int? mileage,
    bool? isMileageTampered,
    Map<String, PartStatus>? bodyParts,
    Map<String, double>? partConditions,
    bool? isEcuCleaned,
    bool? isChassisAligned,
    bool? hasAirbagDeployed,
  }) {
    return ExpertiseReport(
      engineCondition: engineCondition ?? this.engineCondition,
      transmissionCondition: transmissionCondition ?? this.transmissionCondition,
      tramerAmount: tramerAmount ?? this.tramerAmount,
      mileage: mileage ?? this.mileage,
      isMileageTampered: isMileageTampered ?? this.isMileageTampered,
      bodyParts: bodyParts ?? Map.from(this.bodyParts),
      partConditions: partConditions ?? Map.from(this.partConditions),
      isEcuCleaned: isEcuCleaned ?? this.isEcuCleaned,
      isChassisAligned: isChassisAligned ?? this.isChassisAligned,
      hasAirbagDeployed: hasAirbagDeployed ?? this.hasAirbagDeployed,
    );
  }

  bool get isCleanPristine =>
      tramerAmount == 0 &&
      !isMileageTampered &&
      isChassisAligned &&
      !hasAirbagDeployed &&
      engineCondition >= 85.0 &&
      transmissionCondition >= 85.0 &&
      bodyParts.values.every((v) => v == PartStatus.original);
}
