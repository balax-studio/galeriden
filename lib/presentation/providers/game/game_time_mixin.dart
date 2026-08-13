import 'dart:async';
import 'dart:math';

import '../../../data/models/staff_model.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/loan_model.dart';
import '../../../data/models/rental_agreement_model.dart';
import '../../../data/models/installment_contract_model.dart';
import '../../../data/models/cheque_model.dart';
import '../../../data/models/side_business_model.dart';
import '../../../data/models/stock_model.dart';
import '../../../data/models/game_event_model.dart';

import 'game_base_notifier.dart';

mixin GameTimeMixin on GameBaseNotifier {
  Timer? _organicOfferTimer;

  void startPeriodicOrganicOfferTimer() {
    _organicOfferTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      // ponytail: Advance game calendar day every 2 ticks (120 seconds)
      if (timer.tick % 2 == 0) {
        advanceGameDay();
      }

      // Günlük dalgalanma faktörü (0.8 ile 1.2 arası)
      double dayFactor = 0.8 + (random.nextDouble() * 0.4);

      // Daha düşük ihtimal ve daha uzun aralıklarla organik teklifler (Örn: %15 şans)
      if (state.ownedCars.isNotEmpty && random.nextDouble() < (0.15 * dayFactor)) {
        triggerOrganicOffers();
      }
    });
  }

  void stopPeriodicOrganicOfferTimer() {
    _organicOfferTimer?.cancel();
  }

  void advanceGameDay() {
    int nextDay = state.currentDay + 1;
    double newBalance = state.balance;

    // 1. Deduct daily salaries for hired staff
    double totalSalaries = 0.0;
    for (var staff in state.hiredStaff) {
      totalSalaries += staff.role.dailySalary;
    }
    
    // Eğer maaşı ödeyecek para yoksa personel işi bırakır
    List<StaffModel> currentStaff = List.from(state.hiredStaff);
    if (newBalance >= totalSalaries) {
      newBalance -= totalSalaries;
    } else {
      newBalance = 0; // Kalan para ancak bir kısmını ödedi
      currentStaff.clear(); // Tüm personel ayrıldı
    }

    // 2. Process automatic loan installments every 7 days (Weekly deduction)
    List<LoanModel> updatedLoans = List.from(state.activeLoans);
    bool isLoanPaymentDay = nextDay % 7 == 0;

    if (isLoanPaymentDay && updatedLoans.isNotEmpty) {
      for (int i = updatedLoans.length - 1; i >= 0; i--) {
        final loan = updatedLoans[i];
        newBalance -= loan.monthlyPayment;

        final newRemaining = loan.remainingAmount - loan.monthlyPayment;
        final newInstallments = loan.remainingInstallments - 1;

        if (newInstallments <= 0 || newRemaining <= 0) {
          updatedLoans.removeAt(i);
        } else {
          updatedLoans[i] = loan.copyWith(
            remainingAmount: newRemaining,
            remainingInstallments: newInstallments,
          );
        }
      }
    }

    // 4. Rent a Car (Pasif Gelir) mechanics
    List<RentalAgreement> updatedRentals = List.from(state.activeRentals);
    List<CarModel> currentCars = List.from(state.ownedCars);
    
    for (int i = updatedRentals.length - 1; i >= 0; i--) {
      final rental = updatedRentals[i];
      newBalance += rental.dailyRate;
      
      final carIndex = currentCars.indexWhere((c) => c.id == rental.carId);
      if (carIndex != -1) {
        CarModel car = currentCars[carIndex];
        if (random.nextDouble() < 0.05) { 
          car = car.copyWith(expertise: car.expertise.copyWith(engineCondition: max(0, car.expertise.engineCondition - 5)));
        } else if (random.nextDouble() < 0.01) { 
          car = car.copyWith(expertise: car.expertise.copyWith(tramerAmount: car.expertise.tramerAmount + 15000, engineCondition: max(0, car.expertise.engineCondition - 20)));
        }
        currentCars[carIndex] = car;
      }
      
      updatedRentals[i] = rental.copyWith(
        rentedDays: rental.rentedDays + 1,
        totalEarned: rental.totalEarned + rental.dailyRate,
      );
    }

    // 5. Installments mechanics
    List<InstallmentContract> updatedInstallments = List.from(state.activeInstallments);
    for (int i = updatedInstallments.length - 1; i >= 0; i--) {
      final contract = updatedInstallments[i];
      int remainingDays = contract.daysUntilNextPayment - 1;
      
      if (remainingDays <= 0) {
        if (random.nextDouble() < 0.05) {
          newBalance += (contract.totalAmount - contract.paidAmount) * 0.5;
          updatedInstallments.removeAt(i);
        } else if (random.nextDouble() < 0.10) {
          updatedInstallments[i] = contract.copyWith(daysUntilNextPayment: 5, isDefaulted: true);
        } else {
          newBalance += contract.installmentAmount;
          int newPaidInstallments = contract.paidInstallments + 1;
          
          if (newPaidInstallments >= contract.totalInstallments) {
            updatedInstallments.removeAt(i);
          } else {
            updatedInstallments[i] = contract.copyWith(
              paidAmount: contract.paidAmount + contract.installmentAmount,
              paidInstallments: newPaidInstallments,
              daysUntilNextPayment: 30,
              isDefaulted: false,
            );
          }
        }
      } else {
        updatedInstallments[i] = contract.copyWith(daysUntilNextPayment: remainingDays);
      }
    }

    // 6. Cheques mechanics
    List<Cheque> updatedCheques = List.from(state.activeCheques);
    for (int i = updatedCheques.length - 1; i >= 0; i--) {
      final cheque = updatedCheques[i];
      int remainingDays = cheque.daysUntilDue - 1;
      
      if (remainingDays <= 0) {
        if (random.nextDouble() < 0.05) {
          newBalance += cheque.amount * 0.5; 
          updatedCheques.removeAt(i);
        } else {
          newBalance += cheque.amount;
          updatedCheques.removeAt(i);
        }
      } else {
        updatedCheques[i] = cheque.copyWith(daysUntilDue: remainingDays);
      }
    }

    // 7. Bailout (İflas Kurtarma Mekanizması)
    // Eğer oyuncu kredi taksiti sonrası eksiye düştüyse ve satacak arabası yoksa soft-lock olur.
    if (newBalance < 0 && currentCars.isEmpty && state.pendingOrders.isEmpty) {
      newBalance = 25000.0; // Devlet hibesi / başlangıç sermayesi
      updatedLoans.clear(); // Borçlar silinir
    }

    // 8. Side Businesses (Pasif Gelir)
    List<SideBusinessModel> updatedBusinesses = List.from(state.sideBusinesses);
    for (int i = 0; i < updatedBusinesses.length; i++) {
      if (updatedBusinesses[i].isOwned) {
        newBalance += updatedBusinesses[i].dailyIncome;
      }
    }

    // 9. Stock Market Fluctuations
    List<StockModel> updatedStocks = List.from(state.marketStocks);
    List<GameEventModel> newEvents = List.from(state.recentEvents);
    
    for (int i = 0; i < updatedStocks.length; i++) {
      final stock = updatedStocks[i];
      double changePercent = (random.nextDouble() * 0.10) - 0.05; // -5% to +5%
      
      if (random.nextDouble() < 0.05) {
        changePercent = (random.nextDouble() * 0.30) - 0.15; // -15% to +15%
        newEvents.insert(0, GameEventModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
          date: DateTime.now(),
          title: '${stock.symbol} Hissesinde Dalgalanma',
          description: 'Piyasa haberleri ${stock.symbol} hissesini etkiledi.',
          amount: 0.0,
          type: changePercent > 0 ? GameEventType.income : GameEventType.badEvent,
        ));
      }
      
      double newPrice = stock.currentPrice * (1 + changePercent);
      if (newPrice < 1.0) newPrice = 1.0; 
      
      updatedStocks[i] = stock.copyWith(currentPrice: newPrice);
    }
    
    // Keep only last 50 events
    if (newEvents.length > 50) {
      newEvents = newEvents.sublist(0, 50);
    }

    // 10. Daily Tax
    newBalance -= (newBalance * state.dailyTaxRate);

    state = state.copyWith(
      currentDay: nextDay,
      balance: newBalance,
      ownedCars: currentCars,
      hiredStaff: currentStaff,
      activeLoans: updatedLoans,
      activeRentals: updatedRentals,
      activeInstallments: updatedInstallments,
      activeCheques: updatedCheques,
      sideBusinesses: updatedBusinesses,
      marketStocks: updatedStocks,
      recentEvents: newEvents,
    );

    refreshMarketTrends();
  }
}
