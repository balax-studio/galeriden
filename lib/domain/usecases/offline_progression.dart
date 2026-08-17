import 'dart:math';
import '../../data/models/dealership_model.dart';
import '../../data/models/offer_model.dart';
import '../../data/models/staff_model.dart';
import '../../data/models/car_model.dart';
import 'negotiation_engine.dart';

class OfflineProgression {
  /// Calculates offline time and generates realistic simulated economic & customer activity (max 16h / §3.6)
  static Map<String, dynamic> processOfflineTime(
    DealershipModel dealership, {
    DateTime? currentTime,
  }) {
    final now = currentTime ?? DateTime.now();
    // 16 hours max cap = 960 minutes (§3.6)
    final elapsedMinutes = now.difference(dealership.lastActiveTime).inMinutes.clamp(0, 960);
    final hoursAway = (elapsedMinutes / 60).floor();

    if (elapsedMinutes < 2) {
      return {
        'elapsedMinutes': elapsedMinutes,
        'hoursAway': hoursAway,
        'offlineHours': hoursAway,
        'daysElapsed': 0,
        'passiveIncome': 0.0,
        'earnedIncome': 0.0,
        'expensesPaid': 0.0,
        'netEarned': 0.0,
        'partsArrivedCount': 0,
        'newOffersCount': 0,
        'missedOpportunities': <String>[],
        'updatedDealership': dealership.copyWith(lastActiveTime: now),
      };
    }

    double newBalance = dealership.balance;
    int nextDay = dealership.currentDay;
    double totalPassiveEarned = 0.0;
    double totalExpenses = 0.0;

    // 1. Calculate simulated days (4 offline minutes = 1 in-game day / §3.6)
    final simulatedDays = (elapsedMinutes / 4).floor().clamp(1, 240);

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
    double totalDailySalaries = dealership.hiredStaff.fold(0.0, (sum, s) => sum + s.dailySalary);

    // 4. Side businesses passive income with 60% offline baseline efficiency (§3.6)
    // If offline > 8 hours (480 mins), economy cools down to 30% efficiency
    final double passiveEfficiency = elapsedMinutes > 480 ? 0.30 : 0.60;

    double totalDailyPassive = dealership.sideBusinesses
        .where((b) => b.isOwned)
        .fold(0.0, (sum, b) => sum + b.effectiveIncomeWithUtilization(
          washedLast7Days: dealership.carsWashedLast7Days,
          expertisesLast7Days: dealership.expertisesPerformedLast7Days,
          listedCarsCount: dealership.ownedCars.where((c) => c.isListed).length,
          partsRepairedLast7Days: dealership.partsRepairedLast7Days,
          towedCarsLast7Days: dealership.towedCarsLast7Days,
          activeRentalsCount: dealership.activeRentals.length,
        )) * passiveEfficiency;

    for (int day = 0; day < min(simulatedDays, 60); day++) {
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
        totalExpenses += newBalance > 0 ? newBalance : 0.0;
        newBalance = max(0.0, newBalance - dayExpense);
      }
    }

    if (newBalance < 0) newBalance = 0;

    // Organic offers during absence (100% efficiency)
    int repLevel = dealership.skills.reputation;
    int minutesPerOffer = 60;
    if (repLevel >= 3) minutesPerOffer = 40;
    if (repLevel >= 4) minutesPerOffer = 25;

    int maxOffersLimit = 8;
    if (dealership.unlockedBuildings.contains('property_tier_3')) maxOffersLimit = 12;
    if (dealership.unlockedBuildings.contains('property_tier_4')) maxOffersLimit = 16;

    int potentialOffers = (elapsedMinutes / minutesPerOffer).floor().clamp(1, 10);

    var updatedOffers = List<OfferModel>.from(dealership.incomingOffers);
    int newOffersGenerated = 0;

    // 5. Staff Auto-Actions during offline time
    List<CarModel> updatedCars = List.from(dealership.ownedCars);
    final hasWasher = dealership.hiredStaff.any((s) => s.role == StaffRole.washer);
    final hasMechanic = dealership.hiredStaff.any((s) => s.role == StaffRole.masterMechanic);

    if (hasWasher) {
      updatedCars = updatedCars.map((c) => c.copyWith(isWashed: true, isPolished: true)).toList();
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

    for (int i = 0; i < potentialOffers; i++) {
      if (updatedCars.isNotEmpty && updatedOffers.length < maxOffersLimit) {
        final car = updatedCars[i % updatedCars.length];
        final offer = NegotiationEngine.generateBuyerOffer(car, car.listingPrice);
        updatedOffers.add(offer);
        newOffersGenerated++;
      }
    }

    // 6. Generate Contextual Missed Opportunities (fair & informative / §3.6)
    final List<String> missedOpportunities = [];
    if (elapsedMinutes >= 180) {
      missedOpportunities.add('Bir VIP koleksiyoner temiz Klasik araç aradı ancak galeride bulunamadın.');
    }
    if (elapsedMinutes >= 360 && dealership.ownedCars.any((c) => c.isStaleListing)) {
      missedOpportunities.add('Vitrinde bekleyen ilanına bir takas müşterisi uğradı fakat temas kurulamadı.');
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
      'offlineHours': hoursAway,
      'daysElapsed': simulatedDays,
      'passiveIncome': totalPassiveEarned,
      'earnedIncome': totalPassiveEarned,
      'expensesPaid': totalExpenses,
      'netEarned': totalPassiveEarned - totalExpenses,
      'partsArrivedCount': 0,
      'newOffersCount': newOffersGenerated,
      'missedOpportunities': missedOpportunities,
      'updatedDealership': updatedDealership,
    };
  }
}
