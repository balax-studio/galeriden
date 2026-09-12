import 'dart:math';
import '../../data/models/car_model.dart';
import '../../data/models/outsourced_tuning_model.dart';

/// Business logic engine for VIP Contract Tuning Houses
class OutsourcedTuningEngine {
  static const List<OutsourcedTuningStudio> allStudios = [
    OutsourcedTuningStudio(
      id: 'sanayi_yasar',
      nameKey: 'tuning_studio_yasar_name',
      taglineKey: 'tuning_studio_yasar_tagline',
      descKey: 'tuning_studio_yasar_desc',
      badgeKey: 'tuning_studio_yasar_badge',
      minLevel: 2,
      acceptedBrands: [],
      acceptedCategories: [],
      baseCost: 35000.0,
      durationMinutes: 15,
      inGameDaysEquivalent: 1,
      hpMultiplier: 1.15,
      torqueMultiplier: 1.12,
      valueGainMultiplier: 1.25,
      colorThemeHex: 0xFFFF5722, // Deep Orange
    ),
    OutsourcedTuningStudio(
      id: 'tokyo_jdm',
      nameKey: 'tuning_studio_jdm_name',
      taglineKey: 'tuning_studio_jdm_tagline',
      descKey: 'tuning_studio_jdm_desc',
      badgeKey: 'tuning_studio_jdm_badge',
      minLevel: 4,
      acceptedBrands: ['Tota', 'Nisso', 'Hondi', 'Mitsu', 'Subi', 'Mazdi', 'Lexus'],
      acceptedCategories: [],
      baseCost: 180000.0,
      durationMinutes: 30,
      inGameDaysEquivalent: 2,
      hpMultiplier: 1.28,
      torqueMultiplier: 1.30,
      valueGainMultiplier: 1.38,
      colorThemeHex: 0xFF00E5FF, // Cyan
    ),
    OutsourcedTuningStudio(
      id: 'bavaria_klaus',
      nameKey: 'tuning_studio_klaus_name',
      taglineKey: 'tuning_studio_klaus_tagline',
      descKey: 'tuning_studio_klaus_desc',
      badgeKey: 'tuning_studio_klaus_badge',
      minLevel: 6,
      acceptedBrands: ['Bavyera', 'Merso', 'Porş', 'Volk', 'Audi', 'Opal'],
      acceptedCategories: [],
      baseCost: 850000.0,
      durationMinutes: 60,
      inGameDaysEquivalent: 3,
      hpMultiplier: 1.35,
      torqueMultiplier: 1.38,
      valueGainMultiplier: 1.45,
      colorThemeHex: 0xFFFFD600, // Brutal Yellow
    ),
    OutsourcedTuningStudio(
      id: 'nostalji_hilmi',
      nameKey: 'tuning_studio_hilmi_name',
      taglineKey: 'tuning_studio_hilmi_tagline',
      descKey: 'tuning_studio_hilmi_desc',
      badgeKey: 'tuning_studio_hilmi_badge',
      minLevel: 7,
      acceptedBrands: [],
      acceptedCategories: [],
      maxModelYear: 2002,
      isClassicOnly: true,
      baseCost: 1500000.0,
      durationMinutes: 90,
      inGameDaysEquivalent: 4,
      hpMultiplier: 1.40,
      torqueMultiplier: 1.42,
      valueGainMultiplier: 1.55,
      colorThemeHex: 0xFFFF9100, // Amber / Retro Bronze
    ),
    OutsourcedTuningStudio(
      id: 'monaco_hypercraft',
      nameKey: 'tuning_studio_monaco_name',
      taglineKey: 'tuning_studio_monaco_tagline',
      descKey: 'tuning_studio_monaco_desc',
      badgeKey: 'tuning_studio_monaco_badge',
      minLevel: 9,
      acceptedBrands: [],
      acceptedCategories: [],
      isExoticHyperOnly: true,
      baseCost: 12000000.0,
      durationMinutes: 120,
      inGameDaysEquivalent: 5,
      hpMultiplier: 1.45,
      torqueMultiplier: 1.50,
      valueGainMultiplier: 1.50,
      colorThemeHex: 0xFFE040FB, // Magenta / Purple
    ),
  ];

  /// Returns studio by id or null if not found
  static OutsourcedTuningStudio? getStudioById(String id) {
    for (final s in allStudios) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// Evaluates whether a car can be accepted by the given studio
  static bool isCarAccepted(
    OutsourcedTuningStudio studio,
    CarModel car,
    int playerLevel,
  ) {
    if (playerLevel < studio.minLevel) return false;
    if (car.isOutsourcedTuning) return false;
    if (car.isListed) return false;
    if (car.isRented) return false;
    if (car.isPainting) return false;

    // Brand checks
    if (studio.acceptedBrands.isNotEmpty) {
      final brandUpper = car.brand.toUpperCase();
      final hasMatch = studio.acceptedBrands.any(
        (b) => brandUpper.contains(b.toUpperCase()),
      );
      if (!hasMatch) return false;
    }

    // Classic / Retro check
    if (studio.isClassicOnly) {
      final isYearEligible = car.modelYear <= (studio.maxModelYear ?? 2002);
      final isBarnOrRare = car.isBarnFind || car.isBarnFindRestored || car.isRare;
      if (!isYearEligible && !isBarnOrRare) return false;
    }

    // Exotic / Hyper check
    if (studio.isExoticHyperOnly) {
      final isHighValue = car.baseMarketValue >= 4500000.0;
      final isSpecialCar = car.isRare || _isExoticBrandOrModel(car);
      if (!isHighValue && !isSpecialCar) return false;
    }

    return true;
  }

  static bool _isExoticBrandOrModel(CarModel car) {
    final b = car.brand.toUpperCase();
    final m = car.modelName.toUpperCase();
    if (b.contains('PORŞ') ||
        b.contains('PORS') ||
        b.contains('FERRO') ||
        b.contains('LAMBO') ||
        b.contains('BUGAT') ||
        b.contains('PAGANI') ||
        b.contains('KOENIG') ||
        b.contains('MCLAR') ||
        b.contains('ASTON')) {
      return true;
    }
    if (m.contains('GT') ||
        m.contains('RS') ||
        m.contains('HYPER') ||
        m.contains('SUPER') ||
        m.contains('AMG') ||
        m.contains('M8')) {
      return true;
    }
    return false;
  }

  /// Calculates dynamic tuning cost based on car value and studio formula
  static double calculateCost(
    OutsourcedTuningStudio studio,
    CarModel car, {
    int discountPercent = 0,
  }) {
    double rawCost;
    switch (studio.id) {
      case 'sanayi_yasar':
        rawCost = (car.baseMarketValue * 0.04).clamp(25000.0, 85000.0);
        break;
      case 'tokyo_jdm':
        rawCost = (car.baseMarketValue * 0.06).clamp(120000.0, 450000.0);
        break;
      case 'bavaria_klaus':
        rawCost = (car.baseMarketValue * 0.08).clamp(650000.0, 2500000.0);
        break;
      case 'nostalji_hilmi':
        rawCost = (car.baseMarketValue * 0.10).clamp(950000.0, 4500000.0);
        break;
      case 'monaco_hypercraft':
        rawCost = (car.baseMarketValue * 0.12).clamp(8000000.0, 45000000.0);
        break;
      default:
        rawCost = studio.baseCost;
    }

    if (discountPercent > 0) {
      final factor = (1.0 - (discountPercent / 100.0)).clamp(0.1, 1.0);
      rawCost *= factor;
    }

    // Round to clean hundreds or thousands
    if (rawCost > 100000) {
      return (rawCost / 1000).round() * 1000.0;
    }
    return (rawCost / 500).round() * 500.0;
  }

  /// Calculates guaranteed resale boost
  static double calculateExpectedValueGain(
    OutsourcedTuningStudio studio,
    double cost,
  ) {
    final gain = cost * studio.valueGainMultiplier;
    return (gain / 1000).round() * 1000.0;
  }

  /// Creates a new tuning order for the car
  static TuningOrder createOrder({
    required OutsourcedTuningStudio studio,
    required CarModel car,
    required int currentDay,
    int discountPercent = 0,
  }) {
    final cost = calculateCost(studio, car, discountPercent: discountPercent);
    final expectedGain = calculateExpectedValueGain(studio, cost);
    final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}_${car.id}';

    return TuningOrder(
      orderId: orderId,
      carId: car.id,
      carBrand: car.brand,
      carModelName: car.modelName,
      studioId: studio.id,
      cost: cost,
      expectedValueGain: expectedGain,
      startDay: currentDay,
      targetDay: currentDay + studio.inGameDaysEquivalent,
      orderedAt: DateTime.now(),
      durationSeconds: studio.durationSeconds,
      speedupCount: 0,
      status: TuningOrderStatus.inProgress,
    );
  }

  /// Cuts remaining duration by 50% for rewarded ad speedup
  static TuningOrder applySpeedup(TuningOrder order) {
    if (order.isTimerExpired || order.status != TuningOrderStatus.inProgress) {
      return order;
    }

    final elapsed = order.elapsedSeconds;
    final remaining = order.remainingSeconds;
    final halvedRemaining = (remaining / 2).round();

    // Rebase orderedAt so that total duration minus elapsed equals new remaining
    final newDuration = elapsed + halvedRemaining;
    return order.copyWith(
      durationSeconds: max(10, newDuration),
      speedupCount: order.speedupCount + 1,
    );
  }

  /// Advances time when an in-game day passes (each day passes ~300s of active work)
  static TuningOrder advanceDayForOrder(TuningOrder order) {
    if (order.isTimerExpired || order.status != TuningOrderStatus.inProgress) {
      return order;
    }
    // Shift orderedAt 300 seconds backwards into the past
    final newOrderedAt = order.orderedAt.subtract(const Duration(seconds: 300));
    final updated = order.copyWith(orderedAt: newOrderedAt);
    if (updated.isTimerExpired) {
      return updated.copyWith(status: TuningOrderStatus.readyForPickup);
    }
    return updated;
  }

  /// Applies completed tuning modifications to the vehicle
  static CarModel applyCompletedTuning({
    required CarModel car,
    required TuningOrder order,
    required OutsourcedTuningStudio studio,
  }) {
    final updatedOptions = List<String>.from(car.appliedDetailingOptionIds);
    final studioOptionTag = 'contract_tune_${studio.id}';
    if (!updatedOptions.contains(studioOptionTag)) {
      updatedOptions.add(studioOptionTag);
    }
    if (!updatedOptions.contains(studio.badgeKey)) {
      updatedOptions.add(studio.badgeKey);
    }

    final updatedProvenance = List<String>.from(car.provenanceLog);
    updatedProvenance.add(
      'VIP Atolye: ${studio.id} tarafindan ozel muhendislik ve yuksek performans modifiyesi tamamlandi.',
    );

    final newValue = car.baseMarketValue + order.expectedValueGain;
    final shouldBeRare =
        car.isRare || studio.isClassicOnly || studio.isExoticHyperOnly;

    return car.copyWith(
      baseMarketValue: newValue,
      appliedDetailingOptionIds: updatedOptions,
      provenanceLog: updatedProvenance,
      isRare: shouldBeRare,
      isOutsourcedTuning: false,
      clearActiveTuningOrder: true,
    );
  }
}
