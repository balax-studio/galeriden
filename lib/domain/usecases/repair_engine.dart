import 'dart:math';
import '../../data/models/car_model.dart';
import '../../data/models/expertise_model.dart';

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

  /// Restores engine & transmission to 100% with craftsman tier
  static RepairResult repairEngine(CarModel car, RepairTier tier) {
    if (car.expertise.engineCondition >= 100.0) {
      return RepairResult(
        updatedCar: car,
        isSuccess: false,
        message: 'Motor ve Şanzıman zaten %100 kusursuz, tamir gerekmiyor!',
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

    final updatedExpertise = ExpertiseReport(
      engineCondition: 100.0,
      transmissionCondition: 100.0,
      tramerAmount: car.expertise.tramerAmount,
      mileage: car.expertise.mileage,
      isMileageTampered: car.expertise.isMileageTampered,
      bodyParts: car.expertise.bodyParts,
    );

    return RepairResult(
      updatedCar: car.copyWith(expertise: updatedExpertise),
      isSuccess: true,
      message: 'Motor ve Şanzıman saat gibi %100 kondisyona ulaştırıldı!',
      costPaid: actualCost,
    );
  }

  /// Performs full detailing
  static CarModel performDetailing(CarModel car) {
    return car.copyWith(isDetailedCleaned: true);
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
}
