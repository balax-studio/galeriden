import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/services/analytics_service.dart';

void main() {
  group('AnalyticsService Fault-Tolerance & API Tests', () {
    test('AnalyticsService singleton instance is not null', () {
      expect(AnalyticsService.instance, isNotNull);
    });

    test('AnalyticsService methods execute gracefully without throwing when uninitialized', () async {
      final service = AnalyticsService.instance;

      // These must never throw or crash the game loop even if Firebase is uninitialized or in tests
      await expectLater(service.logScreenView('dashboard'), completes);
      await expectLater(
        service.logCarPurchased(
          brand: 'BMW',
          model: '320i',
          price: 1500000.0,
          modelYear: 2020,
        ),
        completes,
      );
      await expectLater(
        service.logCarSold(
          brand: 'BMW',
          model: '320i',
          salePrice: 1750000.0,
          profit: 250000.0,
        ),
        completes,
      );
      await expectLater(
        service.logLevelUp(
          newLevel: 5,
          totalXp: 3500,
        ),
        completes,
      );
      await expectLater(
        service.logAuctionBid(
          carName: 'Mercedes-Benz E250',
          bidAmount: 2100000.0,
          isWon: true,
        ),
        completes,
      );
      await expectLater(
        service.logAdRewardWatched(
          placement: 'daily_grant',
          rewardAmount: 25000.0,
        ),
        completes,
      );
      await expectLater(
        service.logLoanTaken(
          amount: 500000.0,
          installmentCount: 12,
        ),
        completes,
      );
      await expectLater(
        service.logLeaderboardViewed(
          activeTab: 'wealth',
        ),
        completes,
      );
    });
  });
}
