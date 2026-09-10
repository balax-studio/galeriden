import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/stock_model.dart';
import 'package:galeriden/data/services/forex_market_service.dart';
import 'package:galeriden/domain/usecases/stock_market_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Real Forex & Gold Market Tests', () {
    test('parseTrNumber accurately converts Turkish and international decimal strings', () {
      expect(ForexMarketService.parseTrNumber('6.764,13'), 6764.13);
      expect(ForexMarketService.parseTrNumber('48,5021'), 48.5021);
      expect(ForexMarketService.parseTrNumber('1.250.000,50'), 1250000.50);
      expect(ForexMarketService.parseTrNumber(48.5), 48.5);
      expect(ForexMarketService.parseTrNumber(null), 0.0);
      expect(ForexMarketService.parseTrNumber('invalid'), 0.0);
    });

    test('parseTruncgilJson extracts valid USD, EUR, and Gram Altın models', () {
      const mockJson = {
        'USD': {'Alış': '48,4869', 'Satış': '48,5021'},
        'EUR': {'Alış': '56,4478', 'Satış': '56,4778'},
        'gram-altin': {'Alış': '6.764,13', 'Satış': '6.765,12'},
      };

      final forexList = ForexMarketService.parseTruncgilJson(mockJson);
      expect(forexList.length, 3);

      final usd = forexList.firstWhere((f) => f.symbol == 'USD');
      expect(usd.name, 'Amerikan Doları');
      expect(usd.buyRate, closeTo(48.50, 0.05));
      expect(usd.sellRate, closeTo(48.48, 0.05));

      final eur = forexList.firstWhere((f) => f.symbol == 'EUR');
      expect(eur.name, 'Euro');
      expect(eur.buyRate, closeTo(56.47, 0.05));

      final gold = forexList.firstWhere((f) => f.symbol == 'GOLD');
      expect(gold.name, contains('Altın'));
      expect(gold.buyRate, closeTo(6765.12, 0.1));
    });

    test('parseFallbackJson calculates rates correctly from USD-based payload', () {
      const mockOpenErJson = {
        'rates': {
          'TRY': 48.50,
          'EUR': 0.86,
        }
      };
      const double mockXauUsd = 4333.20;

      final forexList = ForexMarketService.parseFallbackJson(
        openErData: mockOpenErJson,
        goldUsdPrice: mockXauUsd,
      );

      expect(forexList.length, 3);
      final usd = forexList.firstWhere((f) => f.symbol == 'USD');
      expect(usd.buyRate, 48.50);

      final eur = forexList.firstWhere((f) => f.symbol == 'EUR');
      // 48.50 / 0.86 ~= 56.39
      expect(eur.buyRate, closeTo(56.39, 0.2));

      final gold = forexList.firstWhere((f) => f.symbol == 'GOLD');
      // Gram Altın = (4333.20 * 48.50) / 31.1034768 ~= 6756.9
      expect(gold.buyRate, greaterThan(6500));
      expect(gold.buyRate, lessThan(7000));
    });

    test('StockMarketEngine.processForexFluctuations respects useRealForex mode', () {
      final initialForex = [
        const ForexGoldModel(
          symbol: 'USD',
          name: 'Amerikan Doları',
          buyRate: 48.50,
          sellRate: 48.20,
          previousRate: 48.40,
          rateHistory: [48.40, 48.50],
        ),
      ];

      // Simulated mode has broader random fluctuation (up to ±1.5%)
      final simUpdated = StockMarketEngine.processForexFluctuations(
        forexList: initialForex,
        useRealForex: false,
      );
      expect(simUpdated.length, 1);
      expect(simUpdated.first.rateHistory.length, 3);

      // Real mode has micro-fluctuation anchor (±0.3%)
      final realUpdated = StockMarketEngine.processForexFluctuations(
        forexList: initialForex,
        useRealForex: true,
      );
      expect(realUpdated.length, 1);
      expect(realUpdated.first.buyRate, closeTo(48.50, 0.35));
    });

    test('DealershipModel serializes and deserializes real forex fields seamlessly', () {
      final dealership = DealershipModel.initial().copyWith(
        useRealForexRates: true,
        lastForexSyncTimestamp: 1773300000000,
      );

      final json = dealership.toJson();
      expect(json['useRealForexRates'], isTrue);
      expect(json['lastForexSyncTimestamp'], 1773300000000);

      final restored = DealershipModel.fromJson(json);
      expect(restored.useRealForexRates, isTrue);
      expect(restored.lastForexSyncTimestamp, 1773300000000);

      // Test default values when keys are missing
      final defaultRestored = DealershipModel.fromJson({});
      expect(defaultRestored.useRealForexRates, isTrue);
      expect(defaultRestored.lastForexSyncTimestamp, isNull);
    });

    test('ForexMarketService.fetchLiveForexRates returns non-empty live rates or graceful fallback', () async {
      final rates = await ForexMarketService.fetchLiveForexRates(force: true);
      expect(rates, isNotNull);
      expect(rates!.length, greaterThanOrEqualTo(3));

      final usd = rates.firstWhere((r) => r.symbol == 'USD');
      expect(usd.buyRate, greaterThan(30.0));

      final eur = rates.firstWhere((r) => r.symbol == 'EUR');
      expect(eur.buyRate, greaterThan(30.0));

      final gold = rates.firstWhere((r) => r.symbol == 'GOLD');
      expect(gold.buyRate, greaterThan(2000.0));
    });
  });
}
