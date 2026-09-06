import 'dart:math';
import '../../data/models/car_model.dart';
import '../../data/models/expertise_model.dart';
import '../../data/models/part_order_model.dart';

enum RepairTier { apprentice, journeyman, master }

class RepairResult {
  final CarModel updatedCar;
  final bool isSuccess;
  final String message;
  final double costPaid;

  RepairResult({
    required this.updatedCar,
    required this.isSuccess,
    required this.message,
    required this.costPaid,
  });
}

class RepairEngine {
  static final Random _random = Random();

  static const double basePaintCost = 3500.0;
  static const double baseBodyChangeCost = 7500.0;
  static const double baseEngineCostPerPercent = 300.0;
  static const double detailedCleanCost = 2500.0;

  /// Calculates realistic, dynamic repair/replacement costs based on vehicle value, part type, and order tier
  static double calculatePartRepairCost(CarModel car, String partName, OrderType orderType, {double discountFactor = 1.0}) {
    if (orderType == OrderType.salvagedScrap) {
      return 0.0; // Çıkma parça montajı ücretsizdir
    }

    final carValue = max(100000.0, car.currentPurchasePrice > 0 ? car.currentPurchasePrice : car.estimatedRealValue);

    final normalizedPart = partName.toLowerCase();
    final (partFactor, minFloor) = _getPartCostProfile(normalizedPart);
    final rawOemCost = max(minFloor, carValue * partFactor);

    int seed = (car.id + partName).hashCode;
    double varianceMultiplier = 0.88 + ((seed.abs() % 25) / 100.0);
    double fullOemCost = rawOemCost * varianceMultiplier;

    double finalCost;
    switch (orderType) {
      case OrderType.quickPatch:
        finalCost = fullOemCost * 0.30;
        break;
      case OrderType.masterRepair:
        finalCost = fullOemCost * 0.60;
        break;
      case OrderType.newOemPart:
        finalCost = fullOemCost;
        break;
      case OrderType.salvagedScrap:
        finalCost = 0.0;
        break;
    }

    finalCost *= discountFactor;
    return (finalCost / 100.0).round() * 100.0;
  }

  static double getCostMultiplier(RepairTier tier) {
    switch (tier) {
      case RepairTier.apprentice:
        return 0.55;
      case RepairTier.journeyman:
        return 1.0;
      case RepairTier.master:
        return 1.75;
    }
  }

  static double getSuccessRate(RepairTier tier) {
    switch (tier) {
      case RepairTier.apprentice:
        return 0.68;
      case RepairTier.journeyman:
        return 0.88;
      case RepairTier.master:
        return 1.0;
    }
  }

  /// Restores a body part with craftsman tier
  static RepairResult repairBodyPart(CarModel car, String partName, RepairTier tier) {
    final currentStatus = car.expertise.bodyParts[partName];
    if (currentStatus == PartStatus.original || currentStatus == null) {
      return RepairResult(
        updatedCar: car,
        isSuccess: false,
        message: '$partName zaten orijinal kondisyonda, tamir gerekmiyor!',
        costPaid: 0.0,
      );
    }

    double baseCost = currentStatus == PartStatus.painted ? basePaintCost : baseBodyChangeCost;
    double actualCost = (baseCost * getCostMultiplier(tier)).roundToDouble();

    bool success = _random.nextDouble() < getSuccessRate(tier);

    if (!success) {
      return RepairResult(
        updatedCar: car,
        isSuccess: false,
        message: 'Çırak usta boyayı tuturamadı, renk dalgalanması oldu! İşlem başarısız.',
        costPaid: actualCost,
      );
    }

    final updatedParts = Map<String, PartStatus>.from(car.expertise.bodyParts);
    updatedParts[partName] = PartStatus.original;

    final updatedExpertise = ExpertiseReport(
      engineCondition: car.expertise.engineCondition,
      transmissionCondition: car.expertise.transmissionCondition,
      tramerAmount: car.expertise.tramerAmount,
      mileage: car.expertise.mileage,
      isMileageTampered: car.expertise.isMileageTampered,
      bodyParts: updatedParts,
    );

    return RepairResult(
      updatedCar: car.copyWith(expertise: updatedExpertise),
      isSuccess: true,
      message: '$partName sıfır gibi orijinal kondisyona getirildi!',
      costPaid: actualCost,
    );
  }

  /// Restores engine to 100% with craftsman tier (does NOT touch transmission)
  static RepairResult repairEngine(CarModel car, RepairTier tier) {
    if (car.expertise.engineCondition >= 95.0) {
      return RepairResult(
        updatedCar: car,
        isSuccess: false,
        message: 'Motor zaten %95 üzeri kusursuz kondisyonda • Rektefiye gerekmiyor.',
        costPaid: 0.0,
      );
    }

    double needed = 100.0 - car.expertise.engineCondition;
    double baseCost = needed * baseEngineCostPerPercent;
    double actualCost = (baseCost * getCostMultiplier(tier)).roundToDouble();

    bool success = _random.nextDouble() < getSuccessRate(tier);

    if (!success) {
      return RepairResult(
        updatedCar: car,
        isSuccess: false,
        message: 'Motor rektefiye sırasında ayar tutturulamadı. Usta tekrar bakmalı!',
        costPaid: actualCost,
      );
    }

    final updatedExpertise = car.expertise.copyWith(
      engineCondition: 100.0,
    );

    return RepairResult(
      updatedCar: car.copyWith(expertise: updatedExpertise),
      isSuccess: true,
      message: 'Motor saat gibi %100 kondisyona ulaştırıldı!',
      costPaid: actualCost,
    );
  }

  /// Restores transmission to 100% with craftsman tier (does NOT touch engine)
  static RepairResult repairTransmission(CarModel car, RepairTier tier) {
    if (car.expertise.transmissionCondition >= 95.0) {
      return RepairResult(
        updatedCar: car,
        isSuccess: false,
        message: 'Şanzıman ve baskı balata zaten %95 üzeri kusursuz • Revizyon gerekmiyor.',
        costPaid: 0.0,
      );
    }

    double needed = 100.0 - car.expertise.transmissionCondition;
    double baseCost = needed * baseEngineCostPerPercent * 0.85;
    double actualCost = (baseCost * getCostMultiplier(tier)).roundToDouble();

    bool success = _random.nextDouble() < getSuccessRate(tier);

    if (!success) {
      return RepairResult(
        updatedCar: car,
        isSuccess: false,
        message: 'Şanzıman montajı sırasında senkromeç oturmadı. Usta tekrar bakmalı!',
        costPaid: actualCost,
      );
    }

    final updatedExpertise = car.expertise.copyWith(
      transmissionCondition: 100.0,
    );

    return RepairResult(
      updatedCar: car.copyWith(expertise: updatedExpertise),
      isSuccess: true,
      message: 'Şanzıman ve baskı balata %100 kusursuz kondisyona getirildi!',
      costPaid: actualCost,
    );
  }

  /// Performs full detailing
  static CarModel performDetailing(CarModel car) {
    return car.copyWith(isDetailedCleaned: true);
  }

  /// Resolves matching key in bodyParts map handling various naming conventions (e.g. 'Ön Kaput' -> 'Kaput')
  static String? resolveBodyPartKey(Map<String, PartStatus> bodyParts, String partName) {
    if (bodyParts.containsKey(partName)) return partName;

    final targetLower = partName.toLowerCase().trim();

    // 1. Direct case-insensitive match
    for (final key in bodyParts.keys) {
      if (key.toLowerCase().trim() == targetLower) return key;
    }

    // 2. Canonical mapping for common Turkish workshop naming variants
    const aliases = <String, List<String>>{
      'kaput': ['kaput', 'ön kaput'],
      'bagaj': ['bagaj', 'bagaj kapağı', 'arka bagaj'],
      'tavan': ['tavan'],
      'sol ön kapı': ['sol ön kapı', 'sol kapı'],
      'sağ ön kapı': ['sağ ön kapı', 'sağ kapı'],
      'sol arka kapı': ['sol arka kapı'],
      'sağ arka kapı': ['sağ arka kapı'],
      'sol ön çamurluk': ['sol ön çamurluk', 'sol çamurluk'],
      'sağ ön çamurluk': ['sağ ön çamurluk', 'sağ çamurluk'],
      'sol arka çamurluk': ['sol arka çamurluk'],
      'sağ arka çamurluk': ['sağ arka çamurluk'],
      'ön tampon': ['ön tampon', 'tampon'],
      'arka tampon': ['arka tampon'],
      'şasi/podye': ['şasi', 'podye', 'şasi/podye'],
    };

    for (final entry in aliases.entries) {
      if (entry.value.any((alias) => targetLower == alias || targetLower.contains(alias))) {
        for (final key in bodyParts.keys) {
          final keyLower = key.toLowerCase();
          if (keyLower == entry.key || entry.value.contains(keyLower)) {
            return key;
          }
        }
      }
    }

    // 3. Fallback partial containment
    for (final key in bodyParts.keys) {
      final keyLower = key.toLowerCase();
      if (targetLower.contains(keyLower) || keyLower.contains(targetLower)) {
        return key;
      }
    }

    return null;
  }

  /// Extracts the list of parts that actually require replacement or repair for a specific car
  static List<String> getNeededPartsForCar(CarModel car) {
    final needed = <String>[];
    car.expertise.bodyParts.forEach((part, status) {
      if (status == PartStatus.changed ||
          status == PartStatus.damaged ||
          status == PartStatus.painted ||
          status == PartStatus.localPainted) {
        needed.add(part);
      }
    });

    if (car.expertise.engineCondition < 95.0) {
      needed.add('Motor Bloğu & Piston');
    }

    if (car.expertise.transmissionCondition < 95.0) {
      needed.add('Şanzıman & Debriyaj');
    }

    return needed;
  }

  /// Returns a clean, localized description of the part condition on the car (strictly zero parentheses)
  static String getPartConditionDescription(CarModel car, String partName) {
    final lower = partName.toLowerCase().trim();
    if (lower.contains('motor') || lower.contains('piston') || lower.contains('blok')) {
      return 'Aşınmış Motor • %${car.expertise.engineCondition.round()} Sağlık';
    }
    if (lower.contains('şanzıman') || lower.contains('debriyaj') || lower.contains('gearbox')) {
      return 'Aşınmış Şanzıman • %${car.expertise.transmissionCondition.round()} Sağlık';
    }

    final resolved = resolveBodyPartKey(car.expertise.bodyParts, partName);
    if (resolved != null) {
      final status = car.expertise.bodyParts[resolved];
      final cond = car.expertise.partConditions[resolved] ?? 100.0;
      switch (status) {
        case PartStatus.damaged:
          return 'Hasarlı • %${cond.round()} Kondisyon';
        case PartStatus.changed:
          return 'Değişen • %${cond.round()} Kondisyon';
        case PartStatus.painted:
          return 'Boyalı • %${cond.round()} Kondisyon';
        case PartStatus.localPainted:
          return 'Lokal Boyalı • %${cond.round()} Kondisyon';
        case PartStatus.original:
        default:
          return 'Orijinal • %${cond.round()} Kondisyon';
      }
    }

    return 'Gerekli Parça';
  }

  /// Applies an installed part order to restore vehicle part condition
  static CarModel applyInstalledPart(CarModel car, String partName, OrderType type) {
    final updatedParts = Map<String, PartStatus>.from(car.expertise.bodyParts);
    final updatedConditions = Map<String, double>.from(car.expertise.partConditions);

    final resolvedKey = resolveBodyPartKey(updatedParts, partName);
    if (resolvedKey != null) {
      switch (type) {
        case OrderType.quickPatch:
          updatedParts[resolvedKey] = PartStatus.painted;
          updatedConditions[resolvedKey] = 75.0;
          break;
        case OrderType.masterRepair:
          // Usta işçiliğiyle kusursuz boyandı ve onarıldı (%95 kondisyon, boyalı statüsü)
          updatedParts[resolvedKey] = PartStatus.painted;
          updatedConditions[resolvedKey] = 95.0;
          break;
        case OrderType.newOemPart:
          // Sıfır orijinal fabrika parçası montajı ile %100 orijinal kondisyona döner
          updatedParts[resolvedKey] = PartStatus.original;
          updatedConditions[resolvedKey] = 100.0;
          break;
        case OrderType.salvagedScrap:
          // Çıkma sağlam parça montajı (%90 orijinal kondisyon)
          updatedParts[resolvedKey] = PartStatus.original;
          updatedConditions[resolvedKey] = 90.0;
          break;
      }
    }

    // Independent engine and transmission restoration
    double engineCond = car.expertise.engineCondition;
    double transCond = car.expertise.transmissionCondition;
    final lowerPart = partName.toLowerCase();

    if (lowerPart.contains('motor') || lowerPart.contains('piston') || lowerPart.contains('blok')) {
      if (type == OrderType.quickPatch) {
        engineCond = max(engineCond, 65.0);
      } else if (type == OrderType.masterRepair) {
        engineCond = max(engineCond, 90.0);
      } else if (type == OrderType.salvagedScrap) {
        engineCond = max(engineCond, 85.0);
      } else {
        engineCond = 100.0;
      }
    }

    if (lowerPart.contains('şanzıman') ||
        lowerPart.contains('debriyaj') ||
        lowerPart.contains('gearbox') ||
        lowerPart.contains('transm')) {
      if (type == OrderType.quickPatch) {
        transCond = max(transCond, 65.0);
      } else if (type == OrderType.masterRepair) {
        transCond = max(transCond, 90.0);
      } else if (type == OrderType.salvagedScrap) {
        transCond = max(transCond, 85.0);
      } else {
        transCond = 100.0;
      }
    }

    bool hasNonOriginal = car.hasNonOriginalParts;
    if (type == OrderType.quickPatch || type == OrderType.salvagedScrap) {
      hasNonOriginal = true;
    } else if (type == OrderType.newOemPart) {
      if (updatedParts.values.every((s) => s == PartStatus.original)) {
        hasNonOriginal = false;
      }
    }

    final updatedExpertise = ExpertiseReport(
      engineCondition: engineCond,
      transmissionCondition: transCond,
      tramerAmount: car.expertise.tramerAmount,
      mileage: car.expertise.mileage,
      isMileageTampered: car.expertise.isMileageTampered,
      bodyParts: updatedParts,
      partConditions: updatedConditions,
    );

    return car.copyWith(
      expertise: updatedExpertise,
      hasNonOriginalParts: hasNonOriginal,
    );
  }

  /// Calculates total cost to fully restore vehicle at Journeyman tier
  static double calculateFullRestorationCost(CarModel car) {
    double total = 0.0;
    car.expertise.bodyParts.forEach((part, status) {
      if (status == PartStatus.painted) total += basePaintCost;
      if (status == PartStatus.changed || status == PartStatus.damaged) total += baseBodyChangeCost;
    });

    double engineNeeded = 100.0 - car.expertise.engineCondition;
    total += engineNeeded * baseEngineCostPerPercent;

    if (!car.isDetailedCleaned) {
      total += detailedCleanCost;
    }

    return total;
  }

  static (double factor, double minFloor) _getPartCostProfile(String normalizedPart) {
    if (normalizedPart.contains('motor') || normalizedPart.contains('şanzıman')) {
      return (0.10, 18000.0);
    }
    if (normalizedPart.contains('şasi') || normalizedPart.contains('podye')) {
      return (0.08, 14000.0);
    }
    if (normalizedPart.contains('tavan') || normalizedPart.contains('kaput') || normalizedPart.contains('bagaj')) {
      return (0.045, 6500.0);
    }
    if (normalizedPart.contains('kapı')) {
      return (0.035, 4800.0);
    }
    if (normalizedPart.contains('çamurluk')) {
      return (0.025, 3800.0);
    }
    return (0.020, 2500.0);
  }
}

