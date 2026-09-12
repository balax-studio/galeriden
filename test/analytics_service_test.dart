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
      await expectLater(
        service.syncUserProperties(
          level: 3,
          day: 12,
          balance: 350000.0,
          carCount: 4,
        ),
        completes,
      );
      await expectLater(
        service.logDayPassed(
          day: 13,
          balance: 340000.0,
          carCount: 4,
          reputation: 250,
        ),
        completes,
      );
      await expectLater(
        service.logCarRepaired(
          brand: 'BMW',
          model: '320i',
          cost: 15000.0,
          repairType: 'engine_master',
        ),
        completes,
      );
      await expectLater(
        service.logSideBusinessPurchased(
          businessId: 'car_wash',
          businessName: 'Oto Yıkama',
          price: 120000.0,
        ),
        completes,
      );
      await expectLater(
        service.logRandomEventChoice(
          eventId: 'tax_audit',
          choiceId: 'settle',
          balanceChange: -10000,
          reputationChange: 5,
        ),
        completes,
      );
      await expectLater(
        service.logFirstCarAction(isBuy: true),
        completes,
      );
      await expectLater(
        service.logFirstCarAction(isBuy: false),
        completes,
      );
      await expectLater(
        service.logBankruptcy(
          day: 45,
          balance: -50000.0,
        ),
        completes,
      );
      await expectLater(
        service.logTutorialStep(
          stepName: 'test_step',
          stepIndex: 1,
        ),
        completes,
      );
      await expectLater(
        service.logTutorialCompleted(),
        completes,
      );
      await expectLater(
        service.logOfferReceived(
          carId: 'car_123',
          offerAmount: 250000.0,
          isFirstSale: true,
        ),
        completes,
      );
    });
  });
}

