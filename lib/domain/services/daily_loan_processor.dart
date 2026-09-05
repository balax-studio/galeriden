import 'dart:math';
import '../../data/models/cheque_model.dart';
import '../../data/models/installment_contract_model.dart';
import '../../data/models/loan_model.dart';
import '../usecases/loan_settlement_engine.dart';

/// Pure domain processor for daily bank loans, installment sales, and customer cheques.
class DailyLoanProcessor {
  const DailyLoanProcessor._();

  static (double newBalance, List<LoanModel> updatedLoans) processLoans({
    required int nextDay,
    required double balance,
    required List<LoanModel> loans,
  }) {
    return LoanSettlementEngine.processWeeklyLoans(
      nextDay: nextDay,
      balance: balance,
      loans: loans,
    );
  }

  static (double newBalance, List<InstallmentContract> updatedInstallments) processInstallments({
    required double balance,
    required List<InstallmentContract> installments,
    required Random random,
  }) {
    return LoanSettlementEngine.processInstallments(
      balance: balance,
      installments: installments,
      random: random,
    );
  }

  static (double newBalance, List<Cheque> updatedCheques) processCheques({
    required double balance,
    required List<Cheque> cheques,
    required double chequeRiskReduction,
    required Random random,
  }) {
    return LoanSettlementEngine.processCheques(
      balance: balance,
      cheques: cheques,
      chequeRiskReduction: chequeRiskReduction,
      random: random,
    );
  }
}
