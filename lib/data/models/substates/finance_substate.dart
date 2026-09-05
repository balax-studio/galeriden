import '../cheque_model.dart';
import '../installment_contract_model.dart';
import '../loan_model.dart';
import '../stock_model.dart';

/// Substate representing banking, loans, securities, and financial balance
class FinanceSubstate {
  final double balance;
  final double bankDepositBalance;
  final double bankCreditLimit;
  final List<LoanModel> activeLoans;
  final List<InstallmentContract> activeInstallments;
  final List<Cheque> activeCheques;
  final List<StockModel> marketStocks;
  final List<PlayerStockModel> ownedStocks;
  final List<PlayerForexModel> ownedForex;
  final List<ForexGoldModel> marketForex;
  final List<IpoOfferModel> activeIpos;
  final List<PlayerIpoRequestModel> playerIpoRequests;
  final double totalProfit;
  final double dailyTaxRate;

  const FinanceSubstate({
    this.balance = 50000.0,
    this.bankDepositBalance = 0.0,
    this.bankCreditLimit = 100000.0,
    this.activeLoans = const [],
    this.activeInstallments = const [],
    this.activeCheques = const [],
    this.marketStocks = const [],
    this.ownedStocks = const [],
    this.ownedForex = const [],
    this.marketForex = const [],
    this.activeIpos = const [],
    this.playerIpoRequests = const [],
    this.totalProfit = 0.0,
    this.dailyTaxRate = 0.02,
  });

  FinanceSubstate copyWith({
    double? balance,
    double? bankDepositBalance,
    double? bankCreditLimit,
    List<LoanModel>? activeLoans,
    List<InstallmentContract>? activeInstallments,
    List<Cheque>? activeCheques,
    List<StockModel>? marketStocks,
    List<PlayerStockModel>? ownedStocks,
    List<PlayerForexModel>? ownedForex,
    List<ForexGoldModel>? marketForex,
    List<IpoOfferModel>? activeIpos,
    List<PlayerIpoRequestModel>? playerIpoRequests,
    double? totalProfit,
    double? dailyTaxRate,
  }) {
    return FinanceSubstate(
      balance: balance ?? this.balance,
      bankDepositBalance: bankDepositBalance ?? this.bankDepositBalance,
      bankCreditLimit: bankCreditLimit ?? this.bankCreditLimit,
      activeLoans: activeLoans ?? this.activeLoans,
      activeInstallments: activeInstallments ?? this.activeInstallments,
      activeCheques: activeCheques ?? this.activeCheques,
      marketStocks: marketStocks ?? this.marketStocks,
      ownedStocks: ownedStocks ?? this.ownedStocks,
      ownedForex: ownedForex ?? this.ownedForex,
      marketForex: marketForex ?? this.marketForex,
      activeIpos: activeIpos ?? this.activeIpos,
      playerIpoRequests: playerIpoRequests ?? this.playerIpoRequests,
      totalProfit: totalProfit ?? this.totalProfit,
      dailyTaxRate: dailyTaxRate ?? this.dailyTaxRate,
    );
  }
}
