import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/services/ad_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdMob Rewarded Video Service Tests', () {
    test('AdService singleton instance exists and provides ad unit IDs', () {
      final adService = AdService.instance;
      expect(adService, isNotNull);
      expect(adService.rewardedAdUnitId, isNotEmpty);
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
}
