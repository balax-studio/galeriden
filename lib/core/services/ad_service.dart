import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Singleton Service to manage Google Mobile Ads (AdMob) Rewarded Video Ads
class AdService {
  static final AdService instance = AdService._internal();
  AdService._internal();

  /// User provided AdMob Rewarded Ad Unit ID
  static const String _productionRewardedAdUnitId = 'ca-app-pub-2626843024156194/9140182901';

  /// Standard Google Test Rewarded Ad Unit ID for Android Debugging
  static const String _testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  RewardedAd? _rewardedAd;
  bool _isAdLoading = false;
  bool _isInitialized = false;

  String get rewardedAdUnitId {
    if (kDebugMode) {
      // Use test unit ID in debug to prevent AdMob policy violations during development
      return _testRewardedAdUnitId;
    }
    return _productionRewardedAdUnitId;
  }

  /// Initialize Google Mobile Ads SDK safely
  Future<void> initialize() async {
    if (kIsWeb) return;
    if (_isInitialized) return;

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      loadRewardedAd();
    } catch (e) {
      debugPrint('[AdService] MobileAds initialization failed or not supported on this platform: $e');
    }
  }

  /// Preload Rewarded Ad
  void loadRewardedAd() {
    if (kIsWeb || _isAdLoading || _rewardedAd != null) return;

    _isAdLoading = true;
    try {
      RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('[AdService] Rewarded ad loaded successfully.');
            _rewardedAd = ad;
            _isAdLoading = false;
            _setupAdCallbacks(ad);
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('[AdService] Rewarded ad failed to load: ${error.message} (code: ${error.code})');
            _rewardedAd = null;
            _isAdLoading = false;
          },
        ),
      );
    } catch (e) {
      debugPrint('[AdService] RewardedAd.load exception: $e');
      _rewardedAd = null;
      _isAdLoading = false;
    }
  }

  void _setupAdCallbacks(RewardedAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('[AdService] Rewarded ad showed full screen.');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('[AdService] Rewarded ad dismissed.');
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd(); // Preload next ad
      },
      onAdFailedToShowFullScreenContent: (ad, AdError error) {
        debugPrint('[AdService] Rewarded ad failed to show: ${error.message}');
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
      },
    );
  }

  /// Shows the rewarded ad and triggers [onRewardEarned] when user completes watching.
  /// If running on Web or ad is not available, executes fallback gracefully.
  void showRewardedAd({
    required VoidCallback onRewardEarned,
    VoidCallback? onAdUnavailable,
  }) {
    if (kIsWeb) {
      // On Web platform, simulate reward grant safely
      onRewardEarned();
      return;
    }

    if (_rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
          debugPrint('[AdService] User earned reward: ${rewardItem.amount} ${rewardItem.type}');
          onRewardEarned();
        },
      );
    } else {
      debugPrint('[AdService] Rewarded ad not ready yet. Attempting to load...');
      loadRewardedAd();
      // Execute fallback if ad is not ready
      if (onAdUnavailable != null) {
        onAdUnavailable();
      } else {
        onRewardEarned();
      }
    }
  }
}
