import '../../../data/models/car_model.dart';
import '../../../data/models/side_business_model.dart';
import '../../../data/models/dealership_model.dart';

/// Pure domain usecase engine for side business revenue calculation,
/// specialization bonuses, and cross-business synergies.
class SideBusinessEngine {
  /// Calculates daily passive income across all owned side businesses.
  static (double, List<SideBusinessModel>) processDailyEarnings({
    required double balance,
    required List<CarModel> cars,
    required List<SideBusinessModel> businesses,
    required SpecializationPath specializationPath,
    required int carsWashedLast7Days,
    required int expertisesPerformedLast7Days,
    required int partsRepairedLast7Days,
    required int towedCarsLast7Days,
    required int activeRentalsCount,
  }) {
    final double businessMultiplier = specializationPath == SpecializationPath.boss ? 1.30 : 1.0;
    final bool hasBillboard = businesses.any((b) => b.isOperational && b.type == SideBusinessType.billboard);
    final updatedBusinesses = List<SideBusinessModel>.from(businesses);
    double currentBalance = balance;

    final listedCarsCount = cars.where((c) => c.isListed).length;

    for (int i = 0; i < updatedBusinesses.length; i++) {
      final b = updatedBusinesses[i];
      if (b.isOperational) {
        // Billboard cross-business synergy: +15% boost on rental fleet income
        double synergyFactor = 1.0;
        if (hasBillboard && b.type == SideBusinessType.carRental) {
          synergyFactor = 1.15;
        }

        double operationalBonus = 0.0;
        // Yan işletme canlı dinamik operasyon olayları (Sadece sahip olunan işletmeler için)
        if (b.type == SideBusinessType.carWash && carsWashedLast7Days > 5) {
          operationalBonus += 1500.0; // Yüksek yıkama trafiği primi
        } else if (b.type == SideBusinessType.towTruck && towedCarsLast7Days > 3) {
          operationalBonus += 3000.0; // Sanayi çekici filo primi
        } else if (b.type == SideBusinessType.corporateExpertise && expertisesPerformedLast7Days > 5) {
          operationalBonus += 4000.0; // Kurumsal filo ekspertiz anlaşması
        }

        final income = (b.effectiveIncomeWithUtilization(
          washedLast7Days: carsWashedLast7Days,
          expertisesLast7Days: expertisesPerformedLast7Days,
          listedCarsCount: listedCarsCount,
          partsRepairedLast7Days: partsRepairedLast7Days,
          towedCarsLast7Days: towedCarsLast7Days,
          activeRentalsCount: activeRentalsCount,
        ) * businessMultiplier * synergyFactor) + operationalBonus;

        currentBalance += income;
        updatedBusinesses[i] = b.copyWith(totalEarned: b.totalEarned + income);
      }
    }
    return (currentBalance, updatedBusinesses);
  }
}
