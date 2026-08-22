import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/services/ad_reward_calculator.dart';
import 'package:galeriden/core/services/ad_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdMob Rewarded Video Service Tests', () {
    test('AdService singleton instance exists and provides ad unit IDs', () {
      final adService = AdService.instance;
      expect(adService, isNotNull);
      expect(adService.rewardedAdUnitId, isNotEmpty);
      expect(adService.nativeAdUnitId, isNotEmpty);
    });

    test('AdService triggers reward callback gracefully in test/simulated environment', () {
      final adService = AdService.instance;
      bool rewardClaimed = false;

      adService.showRewardedAd(
        onRewardEarned: () {
          rewardClaimed = true;
        },
      );

      expect(rewardClaimed, isTrue);
    });
  });

  group('AdRewardCalculator Dynamic Scaling & Variable Ratio Tests', () {
    test('Calculates scaled baseline reward for Level 1 player with small garage', () {
      final outcome = AdRewardCalculator.calculateDynamicReward(
        playerLevel: 1,
        totalGarageValue: 50000.0,
      );

      expect(outcome.moneyAmount, greaterThanOrEqualTo(5000.0));
      expect(outcome.multiplier, isIn([1.0, 2.0, 4.0]));
      expect(outcome.badgeText, isNotEmpty);
      expect(outcome.title, isNotEmpty);
      expect(outcome.message, isNotEmpty);

      // Invariant check: Zero parentheses in badge and title strings
      expect(outcome.badgeText.contains('(') || outcome.badgeText.contains(')'), isFalse);
      expect(outcome.title.contains('(') || outcome.title.contains(')'), isFalse);
    });

    test('Scales significantly higher for high-tier player with large fleet', () {
      final outcome = AdRewardCalculator.calculateDynamicReward(
        playerLevel: 15,
        totalGarageValue: 4000000.0,
      );

      expect(outcome.moneyAmount, greaterThanOrEqualTo(100000.0));
      expect(outcome.moneyAmount, lessThanOrEqualTo(500000.0));
    });

    test('Respects maximum economic cap of 500.000 TL base', () {
      final outcome = AdRewardCalculator.calculateDynamicReward(
        playerLevel: 100,
        totalGarageValue: 100000000.0,
      );

      expect(outcome.moneyAmount, lessThanOrEqualTo(500000.0)); // 500k max jackpot
    });
  });
}
