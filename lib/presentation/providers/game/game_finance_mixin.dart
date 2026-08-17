import '../../../data/models/cheque_model.dart';
import '../../../data/models/dealership_model.dart';
import '../../../data/models/installment_contract_model.dart';
import '../../../data/models/loan_model.dart';
import '../../../domain/usecases/weekly_event_engine.dart';
import 'game_base_notifier.dart';

enum LiquidityLevel { strong, moderate, tight }

class LiquidityStatus {
  final LiquidityLevel level;
  final double ratio;
  final String badgeLabel;
  final String description;
  final double totalLiquidAssets;
  final double totalShortTermDebts;

  const LiquidityStatus({
    required this.level,
    required this.ratio,
    required this.badgeLabel,
    required this.description,
    required this.totalLiquidAssets,
    required this.totalShortTermDebts,
  });
}

mixin GameFinanceMixin on GameBaseNotifier {
  /// Deduct balance from dealership capital
  void deductBalance(double amount) {
    if (state.balance < amount) return;
    state = state.copyWith(balance: state.balance - amount);
    saveState();
  }

  /// Add cash / bonus to dealership capital
  void addMoney(double amount) {
    if (amount <= 0) return;
    state = state.copyWith(balance: state.balance + amount);
    saveState();
  }

  /// Take bank loan
  bool takeBankLoan({required String bankName, required double amount, required int months}) {
    if (state.activeLoans.length >= 3) return false; // Max 3 active loans
    if (amount <= 0 || amount > state.bankCreditLimit) return false; // Must be within approved credit limit

    final baseInterestRate = months == 3 ? 0.10 : (months == 6 ? 0.18 : 0.28);
    final weeklyEvent = WeeklyEventEngine.getEventForDay(state.currentDay);
    final eventDiscount = weeklyEvent.id == 'credit_ease_monday' ? weeklyEvent.discountMultiplier : 1.0;
    final skillDiscount = 1.0 - state.skills.financeInterestDiscount;
    final originDiscount = state.characterOrigin == CharacterOrigin.sehirliYatirimci ? 0.80 : 1.0;
    final interestRate = baseInterestRate * eventDiscount * skillDiscount * originDiscount;
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

  /// Cash out / factor cheque early with discount fee
  bool cashOutChequeEarly(String chequeId, {double discountRate = 0.08}) {
    final index = state.activeCheques.indexWhere((c) => c.id == chequeId);
    if (index == -1) return false;

    final cheque = state.activeCheques[index];
    if (cheque.isDefaulted || cheque.inLegalCollection) return false;

    final double cashReceived = cheque.calculateFactoringCash(discountRate: discountRate);

    List<Cheque> updatedCheques = List<Cheque>.from(state.activeCheques);
    updatedCheques.removeAt(index);

    state = state.copyWith(
      balance: state.balance + cashReceived,
      activeCheques: updatedCheques,
    );

    addXP(15);
    saveState();
    return true;
  }

  /// Send defaulted / bounced cheque to legal lawyer collection
  bool sendChequeToLegalCollection(String chequeId) {
    final index = state.activeCheques.indexWhere((c) => c.id == chequeId);
    if (index == -1) return false;

    final cheque = state.activeCheques[index];
    if (!cheque.isDefaulted || cheque.inLegalCollection) return false;

    const double lawyerFee = 1500.0;
    if (state.balance < lawyerFee) return false;

    List<Cheque> updatedCheques = List<Cheque>.from(state.activeCheques);
    updatedCheques[index] = cheque.copyWith(
      inLegalCollection: true,
      legalCollectionDaysRemaining: 5,
    );

    state = state.copyWith(
      balance: state.balance - lawyerFee,
      activeCheques: updatedCheques,
    );

    saveState();
    return true;
  }

  /// Settle all remaining installments of a contract early with cash discount
  bool settleInstallmentEarly(String contractId, {double discountRate = 0.05}) {
    final index = state.activeInstallments.indexWhere((c) => c.id == contractId);
    if (index == -1) return false;

    final contract = state.activeInstallments[index];
    final double netCash = contract.calculateEarlySettlementCash(discountRate: discountRate);

    List<InstallmentContract> updatedContracts = List<InstallmentContract>.from(state.activeInstallments);
    updatedContracts.removeAt(index);

    state = state.copyWith(
      balance: state.balance + netCash,
      activeInstallments: updatedContracts,
    );

    addXP(20);
    saveState();
    return true;
  }

  /// Calculate dealership current liquidity and solvency status
  LiquidityStatus calculateLiquidityStatus() {
    final double carStockValue = state.ownedCars.fold(0.0, (sum, c) => sum + c.purchasePrice);
    final double installmentReceivables = state.activeInstallments.fold(0.0, (sum, c) => sum + (c.totalAmount - c.paidAmount));
    final double chequeReceivables = state.activeCheques.fold(0.0, (sum, c) => sum + c.amount);

    final double totalLiquidAssets = state.balance + state.bankDepositBalance + carStockValue + installmentReceivables + chequeReceivables;
    final double totalLoanLiabilities = state.activeLoans.fold(0.0, (sum, l) => sum + l.remainingAmount);
    final double shortTermTax = state.dailyTaxRate * 30.0;
    final double totalShortTermDebts = totalLoanLiabilities + shortTermTax;

    final double ratio = totalShortTermDebts <= 0 ? 10.0 : (totalLiquidAssets / totalShortTermDebts);

    LiquidityLevel level;
    String badgeLabel;
    String description;

    if (ratio >= 2.5) {
      level = LiquidityLevel.strong;
      badgeLabel = 'Sağlam & Likit (Güçlü Nakit)';
      description = 'Kasa ve dönen varlıkların borçlarını rahatça karşılıyor. Yeni araç yatırımlarına hazır.';
    } else if (ratio >= 1.2) {
      level = LiquidityLevel.moderate;
      badgeLabel = 'Dengeli & İzlemede (Stabil)';
      description = 'Alacak ve borç dengesi normal seviyede. Taksit ve çek vadelerini takip et.';
    } else {
      level = LiquidityLevel.tight;
      badgeLabel = 'Nakit Sıkışıklığı (Riskli Likidite)';
      description = 'Kısa vadeli borçlar yüksek. Çek kırdırma veya acil araç satışı ile nakit yarat.';
    }

    return LiquidityStatus(
      level: level,
      ratio: ratio,
      badgeLabel: badgeLabel,
      description: description,
      totalLiquidAssets: totalLiquidAssets,
      totalShortTermDebts: totalShortTermDebts,
    );
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
