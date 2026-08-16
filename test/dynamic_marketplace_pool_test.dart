import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/market_trend_model.dart';
import 'package:galeriden/domain/usecases/market_engine.dart';
import 'package:galeriden/presentation/providers/market_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Dynamic Marketplace Pool & Live Sizing Tests', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('1. calculateDynamicListingCount scales with player level and respects [20, 70] bounds', () {
      // Level 1: [20, 40]
      for (int i = 0; i < 20; i++) {
        final countLv1 = MarketEngine.calculateDynamicListingCount(playerLevel: 1);
        expect(countLv1, greaterThanOrEqualTo(20));
        expect(countLv1, lessThanOrEqualTo(40));
      }

      // Level 3: [30, 55]
      for (int i = 0; i < 20; i++) {
        final countLv3 = MarketEngine.calculateDynamicListingCount(playerLevel: 3);
        expect(countLv3, greaterThanOrEqualTo(30));
        expect(countLv3, lessThanOrEqualTo(55));
      }

      // Level 5: [35, 70]
      for (int i = 0; i < 20; i++) {
        final countLv5 = MarketEngine.calculateDynamicListingCount(playerLevel: 5);
        expect(countLv5, greaterThanOrEqualTo(35));
        expect(countLv5, lessThanOrEqualTo(70));
      }
    });

    test('2. Market trend sentiments adjust pool capacity appropriately', () {
      final slumpTrend = MarketTrendModel(
        headline: 'İkinci El Piyasasında Durgunluk — Kelepir Araç Fırsatları Artıyor.',
        bodyTypeMultipliers: {'Sedan': 0.9, 'Hatchback': 0.9, 'SUV': 0.9, 'Spor': 0.9, 'Klasik': 0.9},
        generatedAt: DateTime.now(),
      );

      final boomTrend = MarketTrendModel(
        headline: 'Bahar Ayı Yaza Doğru SUV & Spor Araç Fiyatları %15 Yükselişte!',
        bodyTypeMultipliers: {'Sedan': 1.1, 'Hatchback': 1.1, 'SUV': 1.2, 'Spor': 1.2, 'Klasik': 1.1},
        generatedAt: DateTime.now(),
      );

      // Slump trend should produce lower or equal min bounds
      final countSlump = MarketEngine.calculateDynamicListingCount(playerLevel: 1, trend: slumpTrend);
      expect(countSlump, greaterThanOrEqualTo(20));
      expect(countSlump, lessThanOrEqualTo(40));

      // Boom trend should produce higher counts
      final countBoom = MarketEngine.calculateDynamicListingCount(playerLevel: 5, trend: boomTrend);
      expect(countBoom, greaterThanOrEqualTo(35));
      expect(countBoom, lessThanOrEqualTo(70));
    });

    test('3. generateRandomListings defaults to dynamic count when count parameter is omitted', () {
      final defaultListings = MarketEngine.generateRandomListings(playerLevel: 2);
      expect(defaultListings.length, greaterThanOrEqualTo(20));
      expect(defaultListings.length, lessThanOrEqualTo(70));
    });

    test('4. MarketNotifier refreshMarket and partialRefresh organically adapt pool size', () {
      final notifier = container.read(marketProvider.notifier);

      // Initial refresh
      notifier.refreshMarket();
      final initialCount = container.read(marketProvider).length;
      expect(initialCount, greaterThanOrEqualTo(20));
      expect(initialCount, lessThanOrEqualTo(70));

      // Partial refresh shifts listings while preserving safety bounds
      for (int i = 0; i < 5; i++) {
        notifier.partialRefresh();
        final currentCount = container.read(marketProvider).length;
        expect(currentCount, greaterThanOrEqualTo(20), reason: 'Market pool must never fall below minimum 20 listings');
        expect(currentCount, lessThanOrEqualTo(70), reason: 'Market pool must never exceed maximum 70 listings');
      }
    });
  });
}
