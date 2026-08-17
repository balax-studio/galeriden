import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/cheque_model.dart';
import 'package:galeriden/data/models/installment_contract_model.dart';
import 'package:galeriden/data/models/loan_model.dart';
import 'package:galeriden/presentation/providers/game/game_finance_mixin.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Finance & Collection Micro-System Test Suite', () {
    test('1. Cheque factoring / early discount calculation & cash-out works', () {
      final cheque = Cheque(
        id: 'chq_1',
        customerName: 'Ahmet Bey',
        amount: 100000.0,
        daysUntilDue: 15,
      );

      expect(cheque.calculateFactoringCash(discountRate: 0.08), equals(92000.0));
      expect(cheque.calculateFactoringDiscount(discountRate: 0.08), equals(8000.0));

      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        balance: 10000.0,
        activeCheques: [cheque],
      );

      final success = notifier.cashOutChequeEarly('chq_1', discountRate: 0.08);
      expect(success, isTrue);
      expect(notifier.state.balance, equals(102000.0)); // 10k + 92k
      expect(notifier.state.activeCheques.isEmpty, isTrue);
    });

    test('2. Defaulted cheque can be sent to legal / lawyer collection and recovers funds over time', () {
      final defaultedCheque = Cheque(
        id: 'chq_bad',
        customerName: 'Dolandırıcı Niyazi',
        amount: 80000.0,
        daysUntilDue: 0,
        isDefaulted: true,
      );

      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        balance: 50000.0,
        activeCheques: [defaultedCheque],
      );

      // Lawyer filing fee = 1500 TL
      final sentToLegal = notifier.sendChequeToLegalCollection('chq_bad');
      expect(sentToLegal, isTrue);
      expect(notifier.state.balance, equals(48500.0)); // 50k - 1.5k
      expect(notifier.state.activeCheques.first.inLegalCollection, isTrue);
      expect(notifier.state.activeCheques.first.legalCollectionDaysRemaining, equals(5));

      // Advance 5 days to resolve legal collection (recovers 75% = 60.000 TL)
      for (int i = 0; i < 5; i++) {
        notifier.advanceGameDay();
      }

      // Cheque should be resolved and removed, and recovered cash deposited
      expect(notifier.state.activeCheques.any((c) => c.id == 'chq_bad'), isFalse);
      expect(notifier.state.balance, greaterThan(100000.0));
    });

    test('3. Installment early settlement discount gives cash upfront & closes contract', () {
      final contract = InstallmentContract(
        id: 'inst_1',
        customerName: 'Mehmet Usta',
        totalAmount: 120000.0,
        paidAmount: 40000.0,
        installmentAmount: 10000.0,
        totalInstallments: 12,
        paidInstallments: 4,
        daysUntilNextPayment: 10,
      );

      expect(contract.remainingAmount, equals(80000.0));
      expect(contract.calculateEarlySettlementCash(discountRate: 0.05), equals(76000.0));
      expect(contract.calculateEarlySettlementDiscount(discountRate: 0.05), equals(4000.0));

      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        balance: 20000.0,
        activeInstallments: [contract],
      );

      final settled = notifier.settleInstallmentEarly('inst_1', discountRate: 0.05);
      expect(settled, isTrue);
      expect(notifier.state.balance, equals(96000.0)); // 20k + 76k
      expect(notifier.state.activeInstallments.isEmpty, isTrue);
    });

    test('4. Liquidity & Financial Safety ratio categorizes dealer solvency accurately', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        balance: 500000.0,
        activeLoans: const [],
        dailyTaxRate: 150.0,
      );

      final status1 = notifier.calculateLiquidityStatus();
      expect(status1.level, equals(LiquidityLevel.strong));
      expect(status1.badgeLabel, contains('Sağlam'));

      notifier.state = notifier.state.copyWith(
        balance: 10000.0,
        activeLoans: [
          LoanModel(
            id: 'loan_big',
            bankName: 'Devlet Bankası',
            principalAmount: 1000000.0,
            remainingAmount: 900000.0,
            monthlyPayment: 75000.0,
            totalInstallments: 12,
            remainingInstallments: 12,
            interestRate: 0.04,
            totalRepayment: 1040000.0,
          ),
        ],
      );

      final status2 = notifier.calculateLiquidityStatus();
      expect(status2.level, equals(LiquidityLevel.tight));
      expect(status2.badgeLabel, contains('Nakit'));
    });
  });
}
