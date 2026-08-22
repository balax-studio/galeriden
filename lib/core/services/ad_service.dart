import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../presentation/widgets/ads/neo_brutal_fallback_ad_dialog.dart';
import 'ad_reward_calculator.dart';

/// Singleton Service to manage Google Mobile Ads (AdMob) Rewarded Video and Native Advanced Ads
class AdService {
  static final AdService instance = AdService._internal();
  AdService._internal();

  /// Production AdMob Rewarded Ad Unit IDs
  static const String _androidProductionRewardedAdUnitId = 'ca-app-pub-2626843024156194/9140182901';
  static const String _iosProductionRewardedAdUnitId = 'ca-app-pub-2626843024156194/6070487811';

  /// Standard Google Test Rewarded Ad Unit IDs
  static const String _androidTestRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  static const String _iosTestRewardedAdUnitId = 'ca-app-pub-3940256099942544/1712485313';

  /// Production AdMob Native Advanced Ad Unit IDs
  static const String _androidProductionNativeAdUnitId = 'ca-app-pub-2626843024156194/2418995337';
  static const String _iosProductionNativeAdUnitId = 'ca-app-pub-2626843024156194/3384592643';

  /// Standard Google Test Native Advanced Ad Unit IDs
  static const String _androidTestNativeAdUnitId = 'ca-app-pub-3940256099942544/2247696110';
  static const String _iosTestNativeAdUnitId = 'ca-app-pub-3940256099942544/3986624511';

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

  String get nativeAdUnitId {
    final bool isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    if (kDebugMode) {
      return isIOS ? _iosTestNativeAdUnitId : _androidTestNativeAdUnitId;
    }
    return isIOS ? _iosProductionNativeAdUnitId : _androidProductionNativeAdUnitId;
  }

  int _retryAttempt = 0;

  /// Initialize Google Mobile Ads SDK safely with Apple ATT compliance
  Future<void> initialize() async {
    if (kIsWeb) return;
    if (_isInitialized) return;

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;

      // Safe iOS ATT request after UI frame is ready
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        Future.delayed(const Duration(milliseconds: 800), () async {
          try {
            final status = await AppTrackingTransparency.trackingAuthorizationStatus;
            if (status == TrackingStatus.notDetermined) {
              await AppTrackingTransparency.requestTrackingAuthorization();
            }
          } catch (attError) {
            debugPrint('[AdService] ATT request error: $attError');
          }
          loadRewardedAd();
        });
      } else {
        loadRewardedAd();
      }
    } catch (e) {
      debugPrint('[AdService] MobileAds initialization failed or not supported on this platform: $e');
    }
  }

  /// Preload Rewarded Ad with automatic retry logic
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
            _retryAttempt = 0;
            _setupAdCallbacks(ad);
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('[AdService] Rewarded ad failed to load: ${error.message} - code: ${error.code}');
            _rewardedAd = null;
            _isAdLoading = false;
            _retryAttempt++;
            if (_retryAttempt <= 3) {
              final delay = Duration(seconds: _retryAttempt * 5);
              debugPrint('[AdService] Retrying ad load in ${delay.inSeconds}s - attempt $_retryAttempt/3...');
              Future.delayed(delay, () => loadRewardedAd());
            }
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

  /// Shows rewarded ad. If ad is available, plays it and calls [onRewardEarned].
  /// If unavailable, fails, or running on web, cleanly provides reward and optional fallback callback.
  void showRewardedAd({
    required VoidCallback onRewardEarned,
    VoidCallback? onAdUnavailable,
  }) {
    if (kIsWeb) {
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
      debugPrint('[AdService] Rewarded ad not ready yet. Triggering graceful fallback...');
      loadRewardedAd();
      if (onAdUnavailable != null) {
        onAdUnavailable();
      } else {
        onRewardEarned();
      }
    }
  }

  /// High-level smart helper that attempts to show AdMob rewarded ad.
  /// If unavailable or failing, displays the in-universe Neo-Brutalist Sanayi Esnafı sponsor dialog
  /// and guarantees 100% reward grant so the player is never penalised.
  void showRewardedAdWithFallback({
    required BuildContext context,
    required VoidCallback onRewardEarned,
    String? customRewardTitle,
    AdRewardOutcome? outcome,
  }) {
    if (kIsWeb) {
      onRewardEarned();
      return;
    }

    if (_rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
          debugPrint('[AdService] User earned reward via AdMob: ${rewardItem.amount} ${rewardItem.type}');
          onRewardEarned();
        },
      );
    } else {
      // AdMob not available - launch in-game lore fallback modal with 100% reward delivery
      loadRewardedAd();
      NeoBrutalFallbackAdDialog.show(
        context: context,
        onRewardClaimed: onRewardEarned,
        rewardTitle: customRewardTitle,
        outcome: outcome,
      );
    }
  }

  /// Factory helper to build a [NativeAd] with listener callbacks.
  NativeAd createNativeAd({
    required void Function(NativeAd ad) onAdLoaded,
    required void Function(LoadAdError error) onAdFailedToLoad,
  }) {
    return NativeAd(
      adUnitId: nativeAdUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) => onAdLoaded(ad as NativeAd),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onAdFailedToLoad(error);
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: const Color(0xFF141721),
        cornerRadius: 12.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          backgroundColor: const Color(0xFFFFDE59),
          style: NativeTemplateFontStyle.bold,
          size: 13.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          style: NativeTemplateFontStyle.bold,
          size: 14.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: const Color(0xFF94A3B8),
          size: 11.0,
        ),
      ),
    );
  }
}
