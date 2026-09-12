enum TuningOrderStatus {
  inProgress,
  readyForPickup,
  completed,
}

/// Model definition for contract performance & tuning studios
class OutsourcedTuningStudio {
  final String id;
  final String nameKey;
  final String taglineKey;
  final String descKey;
  final String badgeKey;
  final int minLevel;
  final List<String> acceptedBrands; // Empty means all brands accepted
  final List<String> acceptedCategories; // Empty means all categories accepted
  final int? maxModelYear; // e.g. 2002 for retro restomod
  final bool isClassicOnly;
  final bool isExoticHyperOnly;
  final double baseCost;
  final int durationMinutes;
  final int inGameDaysEquivalent;
  final double hpMultiplier;
  final double torqueMultiplier;
  final double valueGainMultiplier;
  final int colorThemeHex;

  const OutsourcedTuningStudio({
    required this.id,
    required this.nameKey,
    required this.taglineKey,
    required this.descKey,
    required this.badgeKey,
    required this.minLevel,
    this.acceptedBrands = const [],
    this.acceptedCategories = const [],
    this.maxModelYear,
    this.isClassicOnly = false,
    this.isExoticHyperOnly = false,
    required this.baseCost,
    required this.durationMinutes,
    required this.inGameDaysEquivalent,
    required this.hpMultiplier,
    required this.torqueMultiplier,
    required this.valueGainMultiplier,
    required this.colorThemeHex,
  });

  int get durationSeconds => durationMinutes * 60;
}

/// Active contract tuning order tracking model
class TuningOrder {
  final String orderId;
  final String carId;
  final String carBrand;
  final String carModelName;
  final String studioId;
  final double cost;
  final double expectedValueGain;
  final int startDay;
  final int targetDay;
  final DateTime orderedAt;
  final int durationSeconds;
  final int speedupCount;
  final TuningOrderStatus status;

  const TuningOrder({
    required this.orderId,
    required this.carId,
    required this.carBrand,
    required this.carModelName,
    required this.studioId,
    required this.cost,
    required this.expectedValueGain,
    required this.startDay,
    required this.targetDay,
    required this.orderedAt,
    required this.durationSeconds,
    this.speedupCount = 0,
    this.status = TuningOrderStatus.inProgress,
  });

  int get elapsedSeconds {
    final diff = DateTime.now().difference(orderedAt).inSeconds;
    return diff < 0 ? 0 : diff;
  }

  int get remainingSeconds {
    final rem = durationSeconds - elapsedSeconds;
    return rem < 0 ? 0 : rem;
  }

  bool get isTimerExpired => remainingSeconds <= 0;

  double get progressFraction {
    if (durationSeconds <= 0) return 1.0;
    return (elapsedSeconds / durationSeconds).clamp(0.0, 1.0);
  }

  bool get isReadyForPickup =>
      status == TuningOrderStatus.readyForPickup ||
      (status == TuningOrderStatus.inProgress && isTimerExpired);

  TuningOrder copyWith({
    String? orderId,
    String? carId,
    String? carBrand,
    String? carModelName,
    String? studioId,
    double? cost,
    double? expectedValueGain,
    int? startDay,
    int? targetDay,
    DateTime? orderedAt,
    int? durationSeconds,
    int? speedupCount,
    TuningOrderStatus? status,
  }) {
    return TuningOrder(
      orderId: orderId ?? this.orderId,
      carId: carId ?? this.carId,
      carBrand: carBrand ?? this.carBrand,
      carModelName: carModelName ?? this.carModelName,
      studioId: studioId ?? this.studioId,
      cost: cost ?? this.cost,
      expectedValueGain: expectedValueGain ?? this.expectedValueGain,
      startDay: startDay ?? this.startDay,
      targetDay: targetDay ?? this.targetDay,
      orderedAt: orderedAt ?? this.orderedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      speedupCount: speedupCount ?? this.speedupCount,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'carId': carId,
      'carBrand': carBrand,
      'carModelName': carModelName,
      'studioId': studioId,
      'cost': cost,
      'expectedValueGain': expectedValueGain,
      'startDay': startDay,
      'targetDay': targetDay,
      'orderedAt': orderedAt.toIso8601String(),
      'durationSeconds': durationSeconds,
      'speedupCount': speedupCount,
      'status': status.name,
    };
  }

  factory TuningOrder.fromJson(Map<String, dynamic> json) {
    return TuningOrder(
      orderId: json['orderId'] as String,
      carId: json['carId'] as String,
      carBrand: json['carBrand'] as String? ?? '',
      carModelName: json['carModelName'] as String? ?? '',
      studioId: json['studioId'] as String,
      cost: (json['cost'] as num).toDouble(),
      expectedValueGain: (json['expectedValueGain'] as num).toDouble(),
      startDay: json['startDay'] as int? ?? 1,
      targetDay: json['targetDay'] as int? ?? 1,
      orderedAt: DateTime.tryParse(json['orderedAt'] as String? ?? '') ?? DateTime.now(),
      durationSeconds: json['durationSeconds'] as int? ?? 900,
      speedupCount: json['speedupCount'] as int? ?? 0,
      status: TuningOrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TuningOrderStatus.inProgress,
      ),
    );
  }
}

/// Random daily promotional deal offered by contract studios
class StudioDeal {
  final String studioId;
  final int discountPercent;
  final String titleKey;
  final String descKey;
  final int validDay;

  const StudioDeal({
    required this.studioId,
    required this.discountPercent,
    required this.titleKey,
    required this.descKey,
    required this.validDay,
  });

  Map<String, dynamic> toJson() => {
    'studioId': studioId,
    'discountPercent': discountPercent,
    'titleKey': titleKey,
    'descKey': descKey,
    'validDay': validDay,
  };

  factory StudioDeal.fromJson(Map<String, dynamic> json) => StudioDeal(
    studioId: json['studioId'] as String,
    discountPercent: json['discountPercent'] as int? ?? 25,
    titleKey: json['titleKey'] as String? ?? '',
    descKey: json['descKey'] as String? ?? '',
    validDay: json['validDay'] as int? ?? 1,
  );
}
