import '../../data/models/car_model.dart';
import '../../data/models/expertise_model.dart';

class RepairEngine {
  static const double paintRepairCost = 3500.0;
  static const double bodyChangeCost = 7500.0;
  static const double engineRebuildCostPerPercent = 300.0; // Per % point restored
  static const double detailedCleanCost = 2500.0;

  /// Restores a body part to original condition
  static CarModel repairBodyPart(CarModel car, String partName) {
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

    return car.copyWith(expertise: updatedExpertise);
  }

  /// Restores engine & transmission to 100%
  static CarModel repairEngine(CarModel car) {
    final updatedExpertise = ExpertiseReport(
      engineCondition: 100.0,
      transmissionCondition: 100.0,
      tramerAmount: car.expertise.tramerAmount,
      mileage: car.expertise.mileage,
      isMileageTampered: car.expertise.isMileageTampered,
      bodyParts: car.expertise.bodyParts,
    );

    return car.copyWith(expertise: updatedExpertise);
  }

  /// Performs full detailing (wax, interior clean, ceramic polish)
  static CarModel performDetailing(CarModel car) {
    return car.copyWith(isDetailedCleaned: true);
  }

  /// Calculates total cost to fully restore vehicle
  static double calculateFullRestorationCost(CarModel car) {
    double total = 0.0;
    car.expertise.bodyParts.forEach((part, status) {
      if (status == PartStatus.painted) total += paintRepairCost;
      if (status == PartStatus.changed || status == PartStatus.damaged) total += bodyChangeCost;
    });

    double engineNeeded = 100.0 - car.expertise.engineCondition;
    total += engineNeeded * engineRebuildCostPerPercent;

    if (!car.isDetailedCleaned) {
      total += detailedCleanCost;
    }

    return total;
  }
}
