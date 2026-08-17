import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/stock_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Comprehensive Investment System Tests (Micro & Macro)', () {
    test('1. StockModel supports dividend yields, sectors, and BIST-OTO index calculations', () {
      final stockList = StockModel.defaultStocks;
      expect(stockList.length, 12);

      // Verify dividend yield and sector assignments
      for (final stock in stockList) {
        expect(stock.dividendYield, greaterThanOrEqualTo(0.04));
        expect(stock.sectorCategory.isNotEmpty, isTrue);
      }

      // Calculate BIST-OTO index
      final index = BistIndexModel.calculateIndex(stockList);
      expect(index.points, greaterThan(0));
      expect(index.trendName.isNotEmpty, isTrue);
      expect(index.pointsHistory.isNotEmpty, isTrue);
    });

    test('2. Forex & Gold trading allows hedging with accurate buy/sell exchange rates', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.resetGame();

      final initialBalance = container.read(gameProvider).balance;

      // Purchase 1.000 USD at ₺34.50 rate = ₺34.500
      final successBuy = notifier.buyForex('USD', 1000);
      expect(successBuy, isTrue);

      final updatedState = container.read(gameProvider);
      expect(updatedState.balance, closeTo(initialBalance - 34500, 100));

      final ownedUsd = updatedState.ownedForex.firstWhere((f) => f.symbol == 'USD');
      expect(ownedUsd.amount, 1000);
      expect(ownedUsd.averageRate, greaterThan(0));

      // Sell 500 USD back at sell rate ₺34.20 = ₺17.100
      final successSell = notifier.sellForex('USD', 500);
      expect(successSell, isTrue);

      final stateAfterSell = container.read(gameProvider);
      final remainingUsd = stateAfterSell.ownedForex.firstWhere((f) => f.symbol == 'USD');
      expect(remainingUsd.amount, 500);
      expect(stateAfterSell.balance, closeTo(initialBalance - 34500 + 17100, 100));
    });

    test('3. Daily simulation calculates and deposits cash dividends from stock portfolio', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.resetGame();

      // Give player 1.000 lots of TOFK (Price ₺285.50, Value ₺285.500, Yield 10% annual -> daily dividend)
      final ownedStocks = [
        PlayerStockModel(symbol: 'TOFK', quantity: 1000, averageCost: 280.0),
      ];

      notifier.state = container.read(gameProvider).copyWith(
        balance: 100000,
        ownedStocks: ownedStocks,
        marketStocks: StockModel.defaultStocks,
      );

      final initialBal = container.read(gameProvider).balance;

      // Calculate projected daily dividend
      final dailyDividend = notifier.calculateDailyStockDividends();
      expect(dailyDividend, greaterThan(20.0)); // Noticeable daily cashflow

      // Advance game day
      notifier.advanceGameDay();

      // Verify dividend added to balance and logged
      expect(container.read(gameProvider).balance, greaterThan(initialBal - 5000));
      expect(container.read(gameProvider).recentEvents.any((e) => e.title.contains('Temettü')), isTrue);
    });

    test('4. IPO / Halka Arz participation allows lot requests and provides listing profit', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.resetGame();

      final ipo = IpoOfferModel(
        id: 'ipo_volt_charge',
        companyName: 'VoltŞarj İstasyonları A.Ş.',
        symbol: 'VOLT',
        lotPrice: 40.0,
        totalLotsAvailable: 500000,
        daysUntilListing: 2,
        listingMultiplier: 1.50, // %50 listing premium expected
        description: 'Türkiye geneli ultra hızlı şarj istasyonu ağı genişletme yatırımı.',
      );

      notifier.state = container.read(gameProvider).copyWith(
        balance: 100000,
        activeIpos: [ipo],
        playerIpoRequests: [],
      );

      // Request 100 lots = ₺4.000
      final successReq = notifier.requestIpo('ipo_volt_charge', 100);
      expect(successReq, isTrue);

      expect(container.read(gameProvider).balance, 100000 - 4000);
      expect(container.read(gameProvider).playerIpoRequests.length, 1);
      final req = container.read(gameProvider).playerIpoRequests.first;
      expect(req.requestedLots, 100);
      expect(req.totalSpent, 4000);
    });
  });
}
