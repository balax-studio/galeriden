import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Singleton Service to manage Google Mobile Ads (AdMob) Rewarded Video Ads
class AdService {
  static final AdService instance = AdService._internal();
  AdService._internal();

  /// Production AdMob Rewarded Ad Unit IDs
  static const String _androidProductionRewardedAdUnitId = 'ca-app-pub-2626843024156194/9140182901';
  static const String _iosProductionRewardedAdUnitId = 'ca-app-pub-2626843024156194/6070487811';

  /// Standard Google Test Rewarded Ad Unit IDs
  static const String _androidTestRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  static const String _iosTestRewardedAdUnitId = 'ca-app-pub-3940256099942544/1712485313';

  RewardedAd? _rewardedAd;
  bool _isAdLoading = false;
  bool _isInitialized = false;

  String get rewardedAdUnitId {
    final bool isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    if (kDebugMode) {
      // Use official Google test unit IDs in debug to prevent AdMob policy violations
      return isIOS ? _iosTestRewardedAdUnitId : _androidTestRewardedAdUnitId;
    }
    return isIOS ? _iosProductionRewardedAdUnitId : _androidProductionRewardedAdUnitId;
  }

  /// Initialize Google Mobile Ads SDK safely with Apple ATT compliance
  Future<void> initialize() async {
    if (kIsWeb) return;
    if (_isInitialized) return;

    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        try {
          final status = await AppTrackingTransparency.trackingAuthorizationStatus;
          if (status == TrackingStatus.notDetermined) {
            await AppTrackingTransparency.requestTrackingAuthorization();
          }
        } catch (attError) {
          debugPrint('[AdService] ATT request error: $attError');
        }
      }

      await MobileAds.instance.initialize();
      _isInitialized = true;
      loadRewardedAd();
    } catch (e) {
      debugPrint('[AdService] MobileAds initialization failed or not supported on this platform: $e');
    }
  }

  /// Preload Rewarded Ad
  void loadRewardedAd() {
    if (kIsWeb || !_isInitialized || _isAdLoading || _rewardedAd != null) return;

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
