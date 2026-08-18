import 'dart:math';
import '../../../data/models/car_model.dart';
import '../../../data/models/loan_model.dart';
import '../../../data/models/installment_contract_model.dart';
import '../../../data/models/cheque_model.dart';
import '../../../data/models/game_event_model.dart';

/// Pure domain usecase engine for loan settlements, installment collection,
/// cheque clearance, bankruptcy resolution, and daily tax calculation.
class LoanSettlementEngine {
  /// Deducts weekly bank loan installments every 7th day.
  static (double, List<LoanModel>) processWeeklyLoans({
    required int nextDay,
    required double balance,
    required List<LoanModel> loans,
  }) {
    if (nextDay % 7 != 0 || loans.isEmpty) {
      return (balance, loans);
    }

    final updatedLoans = List<LoanModel>.from(loans);
    double currentBalance = balance;

    for (int i = updatedLoans.length - 1; i >= 0; i--) {
      final loan = updatedLoans[i];
      currentBalance -= loan.monthlyPayment;
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
    return (currentBalance, updatedLoans);
  }

  /// Processes installment contracts countdown, payments, and default risks.
  static (double, List<InstallmentContract>) processInstallments({
    required double balance,
    required List<InstallmentContract> installments,
    Random? random,
  }) {
    final rng = random ?? Random();
    final updatedInstallments = List<InstallmentContract>.from(installments);
    double currentBalance = balance;

    for (int i = updatedInstallments.length - 1; i >= 0; i--) {
      final contract = updatedInstallments[i];
      int remainingDays = contract.daysUntilNextPayment - 1;

      if (remainingDays <= 0) {
        if (rng.nextDouble() < 0.05) {
          // Default recovery with 50% discount
          currentBalance += (contract.totalAmount - contract.paidAmount) * 0.5;
          updatedInstallments.removeAt(i);
        } else if (rng.nextDouble() < 0.10) {
          // Late payment delay
          updatedInstallments[i] = contract.copyWith(
            daysUntilNextPayment: 5,
            isDefaulted: true,
          );
        } else {
          // Full installment payment
          currentBalance += contract.installmentAmount;
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
    return (currentBalance, updatedInstallments);
  }

  /// Processes cheque maturities, bounce risks, and legal debt collection progression.
  static (double, List<Cheque>) processCheques({
    required double balance,
    required List<Cheque> cheques,
    required double chequeRiskReduction,
    Random? random,
  }) {
    final rng = random ?? Random();
    final double chequeBounceRisk = (0.05 - chequeRiskReduction).clamp(0.005, 0.05);
    final updatedCheques = List<Cheque>.from(cheques);
    double currentBalance = balance;

    for (int i = updatedCheques.length - 1; i >= 0; i--) {
      final cheque = updatedCheques[i];

      // Handle legal collection progression
      if (cheque.inLegalCollection) {
        int legalDays = cheque.legalCollectionDaysRemaining - 1;
        if (legalDays <= 0) {
          final recovered = cheque.amount * 0.75;
          currentBalance += recovered;
          updatedCheques.removeAt(i);
        } else {
          updatedCheques[i] = cheque.copyWith(legalCollectionDaysRemaining: legalDays);
        }
        continue;
      }

      int remainingDays = cheque.daysUntilDue - 1;

      if (remainingDays <= 0) {
        if (rng.nextDouble() < chequeBounceRisk) {
          updatedCheques[i] = cheque.copyWith(daysUntilDue: 0, isDefaulted: true);
        } else {
          currentBalance += cheque.amount;
          updatedCheques.removeAt(i);
        }
      } else {
        updatedCheques[i] = cheque.copyWith(daysUntilDue: remainingDays);
      }
    }
    return (currentBalance, updatedCheques);
  }

  /// Processes severe bankruptcy, bailiff asset seizure, or court concordat restructuring.
  static (double, List<CarModel>, List<LoanModel>, List<String>, List<GameEventModel>) processBankruptcy({
    required int nextDay,
    required double balance,
    required List<CarModel> cars,
    required List<LoanModel> loans,
    required List<String> dynastyHistory,
    required List<GameEventModel> events,
    required double bankDepositBalance,
  }) {
    double currentBalance = balance;
    final updatedCars = List<CarModel>.from(cars);
    final updatedLoans = List<LoanModel>.from(loans);
    final updatedDynasty = List<String>.from(dynastyHistory);
    final updatedEvents = List<GameEventModel>.from(events);

    double liquidatableValue = updatedCars
        .where((c) => !c.isConsignment)
        .fold(0.0, (s, c) => s + c.estimatedRealValue * 0.70) + bankDepositBalance;

    if (currentBalance < -50000.0) {
      final unlistedSeizableCarIndex = updatedCars.indexWhere(
        (c) => !c.isLockedInShowcase && !c.isRented && !c.isConsignment,
      );

      if (unlistedSeizableCarIndex != -1 && currentBalance < -100000.0) {
        final seizedCar = updatedCars.removeAt(unlistedSeizableCarIndex);
        final recovery = (seizedCar.estimatedRealValue * 0.60).roundToDouble();
        currentBalance += recovery;
        updatedEvents.insert(0, GameEventModel(
          id: 'bailiff_seize_$nextDay',
          title: 'İcra Dairesi Haciz Tebliği!',
          description: 'Aşırı borç nedeniyle ${seizedCar.brand} ${seizedCar.modelName} icra memurlarınca ₺${recovery.round()} bedelle tasfiye edildi.',
          type: GameEventType.expense,
          amount: recovery,
          date: DateTime.now(),
        ));
      } else if (currentBalance < 0 && (liquidatableValue + currentBalance) < 15000.0) {
        currentBalance = 25000.0;
        updatedLoans.clear();
        updatedDynasty.add('Gün $nextDay: Galeri konkordato ilan etti, borçlar yapılandırılarak taze başlangıç yapıldı.');
        updatedEvents.insert(0, GameEventModel(
          id: 'concordat_$nextDay',
          title: 'Konkordato & Yapılandırma Kararı!',
          description: 'Mahkeme galeri konkordato talebini onayladı. Borçlar donduruldu, ₺25.000 taze can suyu ile faaliyetler sürüyor.',
          type: GameEventType.income,
          amount: 25000.0,
          date: DateTime.now(),
        ));
      }
    }

    return (currentBalance, updatedCars, updatedLoans, updatedDynasty, updatedEvents);
  }

  /// Calculates progressive daily corporate tax based on dealership level.
  static double calculateDailyTax(int dealershipLevel) {
    if (dealershipLevel >= 9) return 3500.0;
    if (dealershipLevel >= 6) return 1200.0;
    if (dealershipLevel >= 3) return 450.0;
    return 150.0;
  }
}
