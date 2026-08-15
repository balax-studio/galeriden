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

    test('1. calculateDynamicListingCount scales with player level and respects [4, 14] bounds', () {
      // Level 1: [4, 8]
      for (int i = 0; i < 20; i++) {
        final countLv1 = MarketEngine.calculateDynamicListingCount(playerLevel: 1);
        expect(countLv1, greaterThanOrEqualTo(4));
        expect(countLv1, lessThanOrEqualTo(8));
      }

      // Level 3: [6, 11]
      for (int i = 0; i < 20; i++) {
        final countLv3 = MarketEngine.calculateDynamicListingCount(playerLevel: 3);
        expect(countLv3, greaterThanOrEqualTo(6));
        expect(countLv3, lessThanOrEqualTo(11));
      }

      // Level 5: [7, 14]
      for (int i = 0; i < 20; i++) {
        final countLv5 = MarketEngine.calculateDynamicListingCount(playerLevel: 5);
        expect(countLv5, greaterThanOrEqualTo(7));
        expect(countLv5, lessThanOrEqualTo(14));
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
      expect(countSlump, greaterThanOrEqualTo(4));
      expect(countSlump, lessThanOrEqualTo(8));

      // Boom trend should produce higher counts
      final countBoom = MarketEngine.calculateDynamicListingCount(playerLevel: 5, trend: boomTrend);
      expect(countBoom, greaterThanOrEqualTo(8));
      expect(countBoom, lessThanOrEqualTo(14));
    });

    test('3. generateRandomListings defaults to dynamic count when count parameter is omitted', () {
      final defaultListings = MarketEngine.generateRandomListings(playerLevel: 2);
      expect(defaultListings.length, greaterThanOrEqualTo(4));
      expect(defaultListings.length, lessThanOrEqualTo(14));
    });

    test('4. MarketNotifier refreshMarket and partialRefresh organically adapt pool size', () {
      final notifier = container.read(marketProvider.notifier);

      // Initial refresh
      notifier.refreshMarket();
      final initialCount = container.read(marketProvider).length;
      expect(initialCount, greaterThanOrEqualTo(4));
      expect(initialCount, lessThanOrEqualTo(14));

      // Partial refresh shifts listings while preserving safety bounds
      for (int i = 0; i < 5; i++) {
        notifier.partialRefresh();
        final currentCount = container.read(marketProvider).length;
        expect(currentCount, greaterThanOrEqualTo(4), reason: 'Market pool must never fall below minimum 4 listings');
        expect(currentCount, lessThanOrEqualTo(14), reason: 'Market pool must never exceed maximum 14 listings');
      }
    });
  });
}
