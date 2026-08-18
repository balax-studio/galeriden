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

  /// Applies an installed part order to restore vehicle part condition
  static CarModel applyInstalledPart(CarModel car, String partName, OrderType type) {
    final updatedParts = Map<String, PartStatus>.from(car.expertise.bodyParts);
    final updatedConditions = Map<String, double>.from(car.expertise.partConditions);

    if (updatedParts.containsKey(partName)) {
      switch (type) {
        case OrderType.quickPatch:
          updatedParts[partName] = PartStatus.painted;
          updatedConditions[partName] = 75.0;
          break;
        case OrderType.masterRepair:
          // Usta işçiliğiyle kusursuz boyandı ve onarıldı (%95 kondisyon, boyalı statüsü)
          updatedParts[partName] = PartStatus.painted;
          updatedConditions[partName] = 95.0;
          break;
        case OrderType.newOemPart:
          // Sıfır orijinal fabrika parçası montajı ile %100 orijinal kondisyona döner
          updatedParts[partName] = PartStatus.original;
          updatedConditions[partName] = 100.0;
          break;
        case OrderType.salvagedScrap:
          // Çıkma sağlam parça montajı (%90 orijinal kondisyon)
          updatedParts[partName] = PartStatus.original;
          updatedConditions[partName] = 90.0;
          break;
      }
    }

    // Engine & transmission restoration if requested for Motor / Şanzıman
    double engineCond = car.expertise.engineCondition;
    double transCond = car.expertise.transmissionCondition;
    if (partName.contains('Motor') || partName.contains('Şanzıman')) {
      if (type == OrderType.quickPatch) {
        engineCond = max(engineCond, 65.0);
        transCond = max(transCond, 65.0);
      } else if (type == OrderType.masterRepair) {
        engineCond = max(engineCond, 90.0);
        transCond = max(transCond, 90.0);
      } else {
        engineCond = 100.0;
        transCond = 100.0;
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

    return car.copyWith(expertise: updatedExpertise);
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

