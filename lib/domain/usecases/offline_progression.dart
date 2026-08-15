import 'dart:math';
import '../../data/models/dealership_model.dart';
import '../../data/models/offer_model.dart';
import '../../data/models/staff_model.dart';
import '../../data/models/car_model.dart';
import 'negotiation_engine.dart';

class OfflineProgression {
  /// Calculates offline time and generates realistic simulated economic & customer activity (max 12h)
  static Map<String, dynamic> processOfflineTime(
    DealershipModel dealership, {
    DateTime? currentTime,
  }) {
    final now = currentTime ?? DateTime.now();
    final elapsedMinutes = now.difference(dealership.lastActiveTime).inMinutes.clamp(0, 720); // max 12 hours
    final hoursAway = (elapsedMinutes / 60).floor();

    if (elapsedMinutes < 2) {
      return {
        'elapsedMinutes': elapsedMinutes,
        'hoursAway': hoursAway,
        'daysElapsed': 0,
        'passiveIncome': 0.0,
        'expensesPaid': 0.0,
        'newOffersCount': 0,
        'updatedDealership': dealership.copyWith(lastActiveTime: now),
      };
    }

    double newBalance = dealership.balance;
    int nextDay = dealership.currentDay;
    double totalPassiveEarned = 0.0;
    double totalExpenses = 0.0;

    // 1. Calculate simulated days (1 in-game day per 30-60 offline minutes)
    final simulatedDays = (elapsedMinutes / 30).floor().clamp(1, 12);

    // 2. Property Daily Burn calculation
    double propertyDailyBurn = 500.0;
    if (dealership.unlockedBuildings.contains('property_tier_4')) {
      propertyDailyBurn = 45000.0;
    } else if (dealership.unlockedBuildings.contains('property_tier_3')) {
      propertyDailyBurn = 12000.0;
    } else if (dealership.unlockedBuildings.contains('property_tier_2')) {
      propertyDailyBurn = 3000.0;
    }

    // 3. Staff Salaries
    double totalDailySalaries = dealership.hiredStaff.fold(0.0, (sum, s) => sum + s.role.dailySalary);

    // 4. Side businesses passive income
    double totalDailyPassive = dealership.sideBusinesses
        .where((b) => b.isOwned)
        .fold(0.0, (sum, b) => sum + b.effectiveDailyIncome);

    for (int day = 0; day < simulatedDays; day++) {
      nextDay++;
      // Passive earnings
      newBalance += totalDailyPassive;
      totalPassiveEarned += totalDailyPassive;

      // Expenses
      final dayExpense = propertyDailyBurn + totalDailySalaries;
      if (newBalance >= dayExpense) {
        newBalance -= dayExpense;
        totalExpenses += dayExpense;
      } else {
        // Partial payment if funds run low
        totalExpenses += newBalance > 0 ? newBalance : 0.0;
        newBalance = max(0.0, newBalance - dayExpense);
      }
    }

    // 5. Staff Auto-Actions during offline time
    List<CarModel> updatedCars = List.from(dealership.ownedCars);
    final hasWasher = dealership.hiredStaff.any((s) => s.role == StaffRole.washer);
    final hasMechanic = dealership.hiredStaff.any((s) => s.role == StaffRole.masterMechanic);

    if (hasWasher) {
      updatedCars = updatedCars.map((c) => c.copyWith(isWashed: true)).toList();
    }
    if (hasMechanic) {
      updatedCars = updatedCars.map((c) {
        if (c.expertise.engineCondition < 70 || c.expertise.transmissionCondition < 70) {
          return c.copyWith(
            expertise: c.expertise.copyWith(
              engineCondition: max(c.expertise.engineCondition, 85.0),
              transmissionCondition: max(c.expertise.transmissionCondition, 85.0),
            ),
          );
        }
        return c;
      }).toList();
    }

    // 6. Generate Incoming Offers
    int repLevel = dealership.skills.reputation;
    int maxOffersLimit = 8 + repLevel;
    int minutesPerOffer = (15 - (repLevel * 0.8).round()).clamp(5, 15);
    int potentialOffers = (elapsedMinutes / minutesPerOffer).floor().clamp(1, 8);

    var updatedOffers = List<OfferModel>.from(dealership.incomingOffers);
    int newOffersGenerated = 0;

    for (int i = 0; i < potentialOffers; i++) {
      if (updatedCars.isNotEmpty && updatedOffers.length < maxOffersLimit) {
        final car = updatedCars[i % updatedCars.length];
        double repOfferBonus = 1.0 + (repLevel * 0.02);
        final offer = NegotiationEngine.generateBuyerOffer(car, car.estimatedRealValue * 1.15 * repOfferBonus);
        updatedOffers.add(offer);
        newOffersGenerated++;
      }
    }

    final updatedDealership = dealership.copyWith(
      balance: newBalance,
      currentDay: nextDay,
      ownedCars: updatedCars,
      incomingOffers: updatedOffers,
      lastActiveTime: now,
    );

    return {
      'elapsedMinutes': elapsedMinutes,
      'hoursAway': hoursAway,
      'daysElapsed': simulatedDays,
      'passiveIncome': totalPassiveEarned,
      'expensesPaid': totalExpenses,
      'netEarned': totalPassiveEarned - totalExpenses,
      'newOffersCount': newOffersGenerated,
      'updatedDealership': updatedDealership,
    };
  }
}
