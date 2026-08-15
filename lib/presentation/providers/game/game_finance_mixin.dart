import '../../../data/models/loan_model.dart';
import 'game_base_notifier.dart';

mixin GameFinanceMixin on GameBaseNotifier {
  /// Deduct balance from dealership capital
  void deductBalance(double amount) {
    if (state.balance < amount) return;
    state = state.copyWith(balance: state.balance - amount);
    saveState();
  }

  /// Take bank loan
  bool takeBankLoan({required String bankName, required double amount, required int months}) {
    if (state.activeLoans.length >= 3) return false; // Max 3 active loans

    final interestRate = months == 3 ? 0.10 : (months == 6 ? 0.18 : 0.28);
    final totalRepayment = amount * (1.0 + interestRate);
    final monthlyPayment = totalRepayment / months;

    final loan = LoanModel(
      id: 'loan_${DateTime.now().millisecondsSinceEpoch}',
      bankName: bankName,
      principalAmount: amount,
      interestRate: interestRate,
      totalRepayment: totalRepayment,
      remainingAmount: totalRepayment,
      totalInstallments: months,
      remainingInstallments: months,
      monthlyPayment: monthlyPayment,
    );

    state = state.copyWith(
      balance: state.balance + amount,
      activeLoans: [...state.activeLoans, loan],
    );
    saveState();
    return true;
  }

  /// Pay installment for bank loan
  bool payLoanInstallment(String loanId) {
    final index = state.activeLoans.indexWhere((l) => l.id == loanId);
    if (index == -1) return false;

    final loan = state.activeLoans[index];
    if (state.balance < loan.monthlyPayment) return false;

    final newRemaining = loan.remainingAmount - loan.monthlyPayment;
    final newInstallments = loan.remainingInstallments - 1;

    List<LoanModel> updatedLoans = List<LoanModel>.from(state.activeLoans);
    if (newInstallments <= 0 || newRemaining <= 0) {
      updatedLoans.removeAt(index);
    } else {
      updatedLoans[index] = loan.copyWith(
        remainingAmount: newRemaining,
        remainingInstallments: newInstallments,
      );
    }

    state = state.copyWith(
      balance: state.balance - loan.monthlyPayment,
      activeLoans: updatedLoans,
    );
    saveState();
    return true;
  }

  /// Add rewarded ad balance boost
  void claimAdReward(double rewardAmount) {
    state = state.copyWith(balance: state.balance + rewardAmount);
    saveState();
  }

  /// Deposit cash into bank time deposit
  bool depositToBank(double amount) {
    if (amount <= 0 || state.balance < amount) return false;
    state = state.copyWith(
      balance: state.balance - amount,
      bankDepositBalance: state.bankDepositBalance + amount,
    );
    saveState();
    return true;
  }

  /// Withdraw cash from bank time deposit
  bool withdrawFromBank(double amount) {
    if (amount <= 0 || state.bankDepositBalance < amount) return false;
    state = state.copyWith(
      balance: state.balance + amount,
      bankDepositBalance: state.bankDepositBalance - amount,
    );
    saveState();
    return true;
  }

  /// Upgrade bank credit limit
  bool upgradeCreditLimit({required double newLimit, required double fee}) {
    if (state.balance < fee) return false;
    state = state.copyWith(
      balance: state.balance - fee,
      bankCreditLimit: newLimit,
    );
    saveState();
    return true;
  }

  /// Perform New Game+ Prestige
  bool performPrestige() {
    if (state.level < 5 && state.totalProfit < 3000000) return false;
    state = state.performPrestigeReset();
    saveState();
    return true;
  }
}
