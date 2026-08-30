import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/data/models/cheque_model.dart';
import 'package:galeriden/data/models/game_event_model.dart';
import 'package:galeriden/data/models/installment_contract_model.dart';
import 'package:galeriden/data/models/stock_model.dart';
import 'package:galeriden/domain/usecases/cashflow_engine.dart';
import 'package:galeriden/domain/usecases/stock_market_engine.dart';
import 'package:galeriden/presentation/providers/game/game_finance_mixin.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Finance & Bank System Deep Audit', () {
    test('Bank loan enforces active loan limit of 3 and bank credit limit', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      notifier.state = notifier.state.copyWith(
        balance: 10000.0,
        bankCreditLimit: 500000.0,
        activeLoans: [],
      );

      // Loan 1
      final loan1 = notifier.takeBankLoan(bankName: 'İş Bankası', amount: 100000.0, months: 6);
      expect(loan1, isTrue);
      expect(notifier.state.activeLoans.length, equals(1));
      expect(notifier.state.balance, equals(110000.0));

      // Loan 2
      final loan2 = notifier.takeBankLoan(bankName: 'Garanti BBVA', amount: 50000.0, months: 3);
      expect(loan2, isTrue);
      expect(notifier.state.activeLoans.length, equals(2));
      expect(notifier.state.balance, equals(160000.0));

      // Loan 3
      final loan3 = notifier.takeBankLoan(bankName: 'Akbank', amount: 80000.0, months: 12);
      expect(loan3, isTrue);
      expect(notifier.state.activeLoans.length, equals(3));
      expect(notifier.state.balance, equals(240000.0));

      // 4th loan attempt must fail
      final loan4 = notifier.takeBankLoan(bankName: 'Ziraat', amount: 20000.0, months: 6);
      expect(loan4, isFalse);
      expect(notifier.state.activeLoans.length, equals(3));

      // Loan exceeding credit limit must fail
      notifier.state = notifier.state.copyWith(activeLoans: []);
      final loanExceedLimit = notifier.takeBankLoan(bankName: 'İş Bankası', amount: 600000.0, months: 6);
      expect(loanExceedLimit, isFalse);
      expect(notifier.state.activeLoans.isEmpty, isTrue);

      container.dispose();
    });

    test('Loan installment repayment decreases remaining payments and removes upon payoff', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      notifier.state = notifier.state.copyWith(
        balance: 100000.0,
        bankCreditLimit: 500000.0,
        activeLoans: [],
      );

      notifier.takeBankLoan(bankName: 'İş Bankası', amount: 30000.0, months: 3);
      expect(notifier.state.activeLoans.length, equals(1));
      final loanId = notifier.state.activeLoans.first.id;

      // Pay installment 1
      final p1 = notifier.payLoanInstallment(loanId);
      expect(p1, isTrue);
      expect(notifier.state.activeLoans.first.remainingInstallments, equals(2));

      // Pay installment 2
      final p2 = notifier.payLoanInstallment(loanId);
      expect(p2, isTrue);
      expect(notifier.state.activeLoans.first.remainingInstallments, equals(1));

      // Pay installment 3 (final)
      final p3 = notifier.payLoanInstallment(loanId);
      expect(p3, isTrue);
      expect(notifier.state.activeLoans.isEmpty, isTrue);

      container.dispose();
    });

    test('Bank deposit and withdraw bounds, zero/negative handling and daily interest', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      notifier.state = notifier.state.copyWith(
        balance: 50000.0,
        bankDepositBalance: 0.0,
        completedFirstTimeActions: {'first_bank_deposit'},
      );

      // Negative or zero deposit rejected
      expect(notifier.depositToBank(-500.0), isFalse);
      expect(notifier.depositToBank(0.0), isFalse);
      // More than balance rejected
      expect(notifier.depositToBank(100000.0), isFalse);

      // Valid deposit 20,000
      expect(notifier.depositToBank(20000.0), isTrue);
      expect(notifier.state.balance, equals(30000.0));
      expect(notifier.state.bankDepositBalance, equals(20000.0));

      // Negative or zero withdraw rejected
      expect(notifier.withdrawFromBank(-100.0), isFalse);
      expect(notifier.withdrawFromBank(0.0), isFalse);
      // Overdrawn withdraw rejected
      expect(notifier.withdrawFromBank(25000.0), isFalse);

      // Valid withdraw 5,000
      expect(notifier.withdrawFromBank(5000.0), isTrue);
      expect(notifier.state.balance, equals(35000.0));
      expect(notifier.state.bankDepositBalance, equals(15000.0));

      // CashflowEngine daily interest projection matches rate (0.12% daily)
      final summary = CashflowEngine.calculate(notifier.state);
      expect(summary.depositDailyInterest, equals((15000.0 * 0.0012).roundToDouble()));

      container.dispose();
    });

    test('Factoring cheque cash-out with 8% discount fee and liquidity calculation', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      final cheque = Cheque(
        id: 'cheque_audit_1',
        customerName: 'Ahmet Bey',
        amount: 50000.0,
        daysUntilDue: 30,
        isDefaulted: false,
        isFactored: false,
      );

      notifier.state = notifier.state.copyWith(
        balance: 10000.0,
        activeCheques: [cheque],
      );

      // Cash out cheque early
      final success = notifier.cashOutChequeEarly('cheque_audit_1');
      expect(success, isTrue);

      // 50,000 * 0.92 = 46,000 cash received -> 10,000 + 46,000 = 56,000
      expect(notifier.state.balance, equals(56000.0));
      expect(notifier.state.activeCheques.isEmpty, isTrue);

      // Liquidity calculation
      final liquidity = notifier.calculateLiquidityStatus();
      expect(liquidity.totalLiquidAssets, greaterThanOrEqualTo(56000.0));
      expect(liquidity.level, equals(LiquidityLevel.strong));

      container.dispose();
    });

    test('Installment plan early settlement with 5% customer discount', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      final note = InstallmentContract(
        id: 'note_audit_1',
        customerName: 'Mehmet Usta',
        totalAmount: 40000.0,
        paidAmount: 0.0,
        installmentAmount: 10000.0,
        totalInstallments: 4,
        paidInstallments: 0,
        daysUntilNextPayment: 5,
      );

      notifier.state = notifier.state.copyWith(
        balance: 10000.0,
        activeInstallments: [note],
      );

      // Settle early: 40,000 * 0.95 = 38,000 lump sum collected -> 10,000 + 38,000 = 48,000
      final result = notifier.settleInstallmentEarly('note_audit_1');
      expect(result, isTrue);
      expect(notifier.state.balance, equals(48000.0));
      expect(notifier.state.activeInstallments.isEmpty, isTrue);

      container.dispose();
    });
  });

  group('Stock Market, Forex & IPO Deep Audit', () {
    test('Stock buy and sell correctly computes Weighted Average Cost and 0.2% commission', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      final stock = StockModel(
        symbol: 'GLRD',
        name: 'Galeriden Corp',
        currentPrice: 100.0,
        previousPrice: 98.0,
        priceHistory: [98.0, 100.0],
      );

      notifier.state = notifier.state.copyWith(
        balance: 50000.0,
        marketStocks: [stock],
        ownedStocks: [],
      );

      // Buy 100 shares at 100 TL = 10,000 TL + 0.2% commission (20 TL) = 10,020 TL
      final buy1 = notifier.buyStock('GLRD', 100);
      expect(buy1, isTrue);
      expect(notifier.state.balance, equals(50000.0 - 10020.0));
      expect(notifier.state.ownedStocks.first.quantity, equals(100));
      expect(notifier.state.ownedStocks.first.averageCost, equals(100.0));

      // Update price to 120 TL and buy 100 more shares
      final updatedStock = stock.copyWith(currentPrice: 120.0);
      notifier.state = notifier.state.copyWith(
        marketStocks: [updatedStock],
      );

      // Buy 100 shares at 120 TL = 12,000 TL + 0.2% commission (24 TL) = 12,024 TL
      final buy2 = notifier.buyStock('GLRD', 100);
      expect(buy2, isTrue);
      expect(notifier.state.ownedStocks.first.quantity, equals(200));
      // Weighted Average Cost: (100 * 100 + 12024) / 200 = 110.12 TL
      expect(notifier.state.ownedStocks.first.averageCost, closeTo(110.12, 0.01));

      // Sell 100 shares at 120 TL = 12,000 gross - 0.2% commission (24 TL) = 11,976 TL net
      final balanceBeforeSell = notifier.state.balance;
      final sell1 = notifier.sellStock('GLRD', 100);
      expect(sell1, isTrue);
      expect(notifier.state.balance, equals(balanceBeforeSell + 11976.0));
      expect(notifier.state.ownedStocks.first.quantity, equals(100));

      // Sell remaining 100 shares -> removes from ownedStocks
      final sell2 = notifier.sellStock('GLRD', 100);
      expect(sell2, isTrue);
      expect(notifier.state.ownedStocks.any((s) => s.symbol == 'GLRD'), isFalse);

      container.dispose();
    });

    test('Forex buy and sell validates limits and balances correctly', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      const usd = ForexGoldModel(
        symbol: 'USD',
        name: 'Amerikan Doları',
        buyRate: 35.0,
        sellRate: 34.7,
        previousRate: 34.8,
        rateHistory: [34.5, 34.8, 35.0],
      );

      notifier.state = notifier.state.copyWith(
        balance: 100000.0,
        marketForex: [usd],
        ownedForex: [],
      );

      // Buy 1000 USD at 35.0 = 35,000 TL
      final buyUsd = notifier.buyForex('USD', 1000.0);
      expect(buyUsd, isTrue);
      expect(notifier.state.balance, equals(65000.0));
      expect(notifier.state.ownedForex.first.amount, equals(1000.0));

      // Overdrawn Forex buy fails (3000 USD * 35 = 105,000 > 65,000)
      final overdrawnBuy = notifier.buyForex('USD', 3000.0);
      expect(overdrawnBuy, isFalse);

      // Sell 500 USD at 34.7 = 17,350 TL
      final sellUsd = notifier.sellForex('USD', 500.0);
      expect(sellUsd, isTrue);
      expect(notifier.state.balance, equals(65000.0 + 17350.0));
      expect(notifier.state.ownedForex.first.amount, equals(500.0));

      // Selling more than owned fails
      final invalidSell = notifier.sellForex('USD', 1000.0);
      expect(invalidSell, isFalse);

      container.dispose();
    });

    test('IPO settlement distributes payouts and creates game event without duplicate cycles', () {
      const ipo = IpoOfferModel(
        id: 'ipo_test_1',
        companyName: 'Borusan Batarya',
        symbol: 'BBAT',
        lotPrice: 50.0,
        totalLotsAvailable: 1000000,
        daysUntilListing: 1, // Will settle on next day
        isListed: false,
        maxLotPerUser: 200,
        listingMultiplier: 1.30,
        description: 'Batarya ve şarj istasyonları üreticisi',
      );

      const ipoRequest = PlayerIpoRequestModel(
        ipoId: 'ipo_test_1',
        requestedLots: 100,
        totalSpent: 5000.0,
      );

      final (updatedIpos, updatedRequests, updatedBalance, updatedEvents) =
          StockMarketEngine.processIpoSettlement(
        nextDay: 15,
        balance: 10000.0,
        ipos: [ipo],
        requests: [ipoRequest],
        events: [],
      );

      expect(updatedIpos.first.isListed, isTrue);
      expect(updatedRequests.isEmpty, isTrue);
      expect(updatedBalance, greaterThan(10000.0));
      expect(updatedEvents.isNotEmpty, isTrue);
    });

    test('StockMarketEngine quarterly GLRD report generation on day 30', () {
      final glrd = StockModel(
        symbol: 'GLRD',
        name: 'Galeriden Corp',
        currentPrice: 100.0,
        previousPrice: 95.0,
      );

      final (updatedStocks, updatedBalance, updatedEvents) =
          StockMarketEngine.processQuarterlyFinancialReport(
        nextDay: 30,
        balance: 100000.0,
        stocks: [glrd],
        events: [],
        reputationScore: 80,
        totalProfit: 500000.0,
        isCompanyListed: true,
      );

      expect(updatedStocks.first.currentPrice, greaterThan(100.0));
      expect(updatedBalance, greaterThan(100000.0));
      expect(updatedEvents.first.title, contains('GLRD'));
      expect(updatedEvents.first.type, equals(GameEventType.income));
    });
  });
}
