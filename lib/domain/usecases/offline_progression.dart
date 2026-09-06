import 'dart:math';
import '../../data/models/dealership_model.dart';
import '../../data/models/offer_model.dart';
import '../../data/models/car_model.dart';
import '../../data/models/dramatic_card_model.dart';
import '../../data/models/loan_model.dart';
import '../../data/models/installment_contract_model.dart';
import '../../data/models/cheque_model.dart';
import '../services/daily_staff_processor.dart';
import 'loan_settlement_engine.dart';
import 'negotiation_engine.dart';

class OfflineProgression {
  /// Calculates offline time and generates realistic simulated economic & customer activity (max 16h / §3.6)
  static Map<String, dynamic> processOfflineTime(
    DealershipModel dealership, {
    DateTime? currentTime,
  }) {
    final now = currentTime ?? DateTime.now();
    final rawDiff = now.difference(dealership.lastActiveTime).inMinutes;

    // Clock rollback detection: Prevent time-travel exploitation
    if (rawDiff < 0) {
      return {
        'elapsedMinutes': 0,
        'hoursAway': 0,
        'offlineHours': 0,
        'daysElapsed': 0,
        'passiveIncome': 0.0,
        'earnedIncome': 0.0,
        'expensesPaid': 0.0,
        'netEarned': 0.0,
        'partsArrivedCount': 0,
        'newOffersCount': 0,
        'missedOpportunities': <String>[],
        'updatedDealership': dealership,
      };
    }

    // 16 hours max cap = 960 minutes (§3.6)
    final elapsedMinutes = rawDiff.clamp(0, 960);
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

    // 1. Calculate simulated days (30 offline minutes = 1 in-game day, capped at max 3 days / §3.6)
    final simulatedDays = (elapsedMinutes / 30).floor().clamp(0, 3);

    // 2. Property Daily Burn calculation (honors deed ownership)
    final double propertyDailyBurn = dealership.dailyPropertyRentBurn;

    // 3. Staff Salaries
    double totalDailySalaries = dealership.hiredStaff.fold(0.0, (sum, s) => sum + s.dailySalary);

    // 4. Side businesses passive income with balanced offline baseline efficiency (§3.6)
    // If offline > 6 hours (360 mins), economy cools down to 35% efficiency
    final double passiveEfficiency = elapsedMinutes > 360 ? 0.35 : 0.50;

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

    var updatedLoans = List<LoanModel>.from(dealership.activeLoans);
    var updatedInstallments = List<InstallmentContract>.from(dealership.activeInstallments);
    var updatedCheques = List<Cheque>.from(dealership.activeCheques);
    var updatedCars = List<CarModel>.from(dealership.ownedCars);
    final hasCarWash = dealership.sideBusinesses.any((b) => b.id == 'sb_1' && b.isOwned);

    for (int day = 0; day < simulatedDays; day++) {
      nextDay++;
      // Passive earnings
      newBalance += totalDailyPassive;
      totalPassiveEarned += totalDailyPassive;

      // Active rentals daily yield
      for (final rental in dealership.activeRentals) {
        newBalance += rental.dailyRate;
        totalPassiveEarned += rental.dailyRate;
      }

      // Expenses: property burn + salaries + daily tax
      final dailyTax = LoanSettlementEngine.calculateDailyTax(
        dealership.level,
        totalLiquidWealth: newBalance + dealership.bankDepositBalance,
      );
      final dayExpense = propertyDailyBurn + totalDailySalaries + dailyTax;
      if (newBalance >= dayExpense) {
        newBalance -= dayExpense;
        totalExpenses += dayExpense;
      } else {
        totalExpenses += newBalance > 0 ? newBalance : 0.0;
        newBalance = max(0.0, newBalance - dayExpense);
      }

      // Weekly loans settlement (if nextDay % 7 == 0)
      if (updatedLoans.isNotEmpty) {
        final loanResult = LoanSettlementEngine.processWeeklyLoans(
          nextDay: nextDay,
          balance: newBalance,
          loans: updatedLoans,
        );
        newBalance = loanResult.$1;
        updatedLoans = loanResult.$2;
      }

      // Installments & Cheques
      if (updatedInstallments.isNotEmpty) {
        final instResult = LoanSettlementEngine.processInstallments(
          balance: newBalance,
          installments: updatedInstallments,
        );
        newBalance = instResult.$1;
        updatedInstallments = instResult.$2;
      }

      if (updatedCheques.isNotEmpty) {
        final chequeResult = LoanSettlementEngine.processCheques(
          balance: newBalance,
          cheques: updatedCheques,
          chequeRiskReduction: dealership.skills.chequeRiskReduction,
          random: Random(),
        );
        newBalance = chequeResult.$1;
        updatedCheques = chequeResult.$2;
      }

      // Staff auto-actions during offline time, per simulated day using active logic & limits (§3.6)
      updatedCars = DailyStaffProcessor.processStaffAutomation(
        staff: dealership.hiredStaff,
        cars: updatedCars,
        hasCarWashBusiness: hasCarWash,
      );
    }

    if (newBalance < 0) newBalance = 0;

    // Organic offers during absence (100% efficiency)
    int repLevel = dealership.skills.reputation;
    int minutesPerOffer = 60;
    if (repLevel >= 3) minutesPerOffer = 40;
    if (repLevel >= 4) minutesPerOffer = 25;

    int maxOffersLimit = 6;
    if (dealership.unlockedBuildings.contains('property_tier_2')) maxOffersLimit = 8;
    if (dealership.unlockedBuildings.contains('property_tier_3')) maxOffersLimit = 10;
    if (dealership.unlockedBuildings.contains('property_tier_4')) maxOffersLimit = 12;
    if (dealership.unlockedBuildings.contains('property_tier_5')) maxOffersLimit = 14;
    if (dealership.unlockedBuildings.contains('property_tier_6')) maxOffersLimit = 16;
    if (dealership.unlockedBuildings.contains('property_tier_7')) maxOffersLimit = 18;
    if (dealership.unlockedBuildings.contains('property_tier_8')) maxOffersLimit = 20;

    int potentialOffers = (elapsedMinutes / minutesPerOffer).floor().clamp(1, 10);

    var updatedOffers = List<OfferModel>.from(dealership.incomingOffers);
    int newOffersGenerated = 0;

    final eligibleOfferCars = updatedCars.where((c) => c.isListed && !c.isRented && !c.isLockedInShowcase).toList();

    for (int i = 0; i < potentialOffers; i++) {
      if (eligibleOfferCars.isNotEmpty && updatedOffers.length < maxOffersLimit) {
        final car = eligibleOfferCars[i % eligibleOfferCars.length];
        final offer = NegotiationEngine.generateBuyerOffer(
          car,
          car.listingPrice,
          currentDay: dealership.currentDay,
        );
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

    DramaticCardModel? updatedCard = dealership.pendingDramaticCard;
    if (updatedCard != null) {
      updatedCard = updatedCard.copyWith(dayNumber: nextDay);
    }

    final updatedDealership = dealership.copyWith(
      balance: newBalance,
      currentDay: nextDay,
      activeLoans: updatedLoans,
      activeInstallments: updatedInstallments,
      activeCheques: updatedCheques,
      ownedCars: updatedCars,
      incomingOffers: updatedOffers,
      pendingDramaticCard: updatedCard,
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
