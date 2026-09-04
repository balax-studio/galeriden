import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../presentation/widgets/ads/neo_brutal_fallback_ad_dialog.dart';
import 'ad_reward_calculator.dart';

/// Singleton Service to manage Google Mobile Ads (AdMob) Rewarded Video and Native Advanced Ads
class AdService {
  static final AdService instance = AdService._internal();
  AdService._internal();

  final FacebookAppEvents _facebookAppEvents = FacebookAppEvents();
  FacebookAppEvents get facebookAppEvents => _facebookAppEvents;

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
  DateTime? _rewardedAdLoadedAt;
  bool _isAdLoading = false;
  bool _isInitialized = false;

  /// AdMob ad expiration threshold (AdMob ads expire after ~60 minutes, we refresh after 50 min)
  static const Duration adExpirationThreshold = Duration(minutes: 50);

  /// Checks if the cached rewarded ad is expired
  bool get isAdExpired {
    if (_rewardedAdLoadedAt == null) return false;
    return DateTime.now().difference(_rewardedAdLoadedAt!) > adExpirationThreshold;
  }

  /// Checks if a valid, unexpired rewarded ad is ready to play
  bool get isRewardedAdReady => _rewardedAd != null && !isAdExpired;

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

  /// Determines if a native ad or in-game sponsored window should be active on a given in-game day.
  ///
  /// Rule 1: First 7 in-game days (currentDay <= 7) are completely ad-free and sponsor-free (closed).
  /// Rule 2: From Day 8 onwards, uses a pseudo-random deterministic pacing algorithm
  /// based on game days (~55% active days, alternating randomly to prevent ad fatigue).
  static bool shouldShowNativeAdForDay(int currentDay, [dynamic contextType]) {
    if (currentDay <= 7) {
      return false;
    }

    final contextOffset = contextType != null ? contextType.hashCode.abs() % 13 : 0;
    // Multiplicative pseudo-random hashing based on in-game day & context
    final hash = ((currentDay * 37 + contextOffset * 17 + 101) * 2654435761) & 0x7FFFFFFF;
    final dayScore = hash % 100;

    return dayScore < 55;
  }

  /// Initialize Google Mobile Ads SDK and Meta App Events safely with Apple ATT compliance
  Future<void> initialize() async {
    if (kIsWeb) return;
    if (_isInitialized) return;

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;

      try {
        await _facebookAppEvents.setAutoLogAppEventsEnabled(true);
        await _facebookAppEvents.logEvent(name: 'fb_mobile_activate_app');
        await _facebookAppEvents.flush();
      } catch (fbError) {
        debugPrint('[AdService] Facebook App Events autoLog initialization error: $fbError');
      }

      // Safe iOS ATT request after UI frame is ready
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        Future.delayed(const Duration(milliseconds: 800), () async {
          try {
            var status = await AppTrackingTransparency.trackingAuthorizationStatus;
            if (status == TrackingStatus.notDetermined) {
              status = await AppTrackingTransparency.requestTrackingAuthorization();
            }
            final isAuthorized = status == TrackingStatus.authorized;
            await _facebookAppEvents.setAdvertiserIdCollectionEnabled(isAuthorized);
            await _facebookAppEvents.flush();
          } catch (attError) {
            debugPrint('[AdService] ATT request error: $attError');
          } finally {
            loadRewardedAd();
          }
        });
      } else {
        try {
          await _facebookAppEvents.setAdvertiserIdCollectionEnabled(true);
          await _facebookAppEvents.flush();
        } catch (e) {
          debugPrint('[AdService] Meta setAdvertiserIdCollectionEnabled error: $e');
        }
        loadRewardedAd();
      }
    } catch (e) {
      debugPrint('[AdService] MobileAds initialization failed or not supported on this platform: $e');
    }
  }

  /// Log custom Meta analytics event safely
  Future<void> logMetaEvent(String name, [Map<String, dynamic>? parameters]) async {
    if (kIsWeb) return;
    try {
      await _facebookAppEvents.logEvent(name: name, parameters: parameters);
      await _facebookAppEvents.flush();
    } catch (e) {
      debugPrint('[AdService] Meta logEvent error: $e');
    }
  }

  /// Preload Rewarded Ad lazily with automatic retry logic and expiration handling
  void loadRewardedAd() {
    if (kIsWeb || !_isInitialized || _isAdLoading) return;

    if (_rewardedAd != null) {
      if (isAdExpired) {
        debugPrint('[AdService] Cached rewarded ad is expired (>50 min). Disposing and reloading fresh.');
        _rewardedAd?.dispose();
        _rewardedAd = null;
        _rewardedAdLoadedAt = null;
      } else {
        // Valid fresh ad already cached in memory
        return;
      }
    }

    _isAdLoading = true;
    try {
      RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('[AdService] Rewarded ad loaded successfully.');
            _rewardedAd = ad;
            _rewardedAdLoadedAt = DateTime.now();
            _isAdLoading = false;
            _retryAttempt = 0;
            _setupAdCallbacks(ad);
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('[AdService] Rewarded ad failed to load: ${error.message} - code: ${error.code}');
            _rewardedAd = null;
            _rewardedAdLoadedAt = null;
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
      _rewardedAdLoadedAt = null;
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
        _rewardedAdLoadedAt = null;
        // Preload next rewarded ad immediately for continuous seamless experience
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, AdError error) {
        debugPrint('[AdService] Rewarded ad failed to show: ${error.message}');
        ad.dispose();
        _rewardedAd = null;
        _rewardedAdLoadedAt = null;
        loadRewardedAd();
      },
    );
  }

  /// Shows rewarded ad. If ad is available and unexpired, plays it and calls [onRewardEarned].
  /// If unavailable, expired, fails, or running on web, cleanly provides reward and optional fallback callback.
  void showRewardedAd({
    required VoidCallback onRewardEarned,
    VoidCallback? onAdUnavailable,
  }) {
    if (kIsWeb) {
      onRewardEarned();
      return;
    }

    if (_rewardedAd != null && !isAdExpired) {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
          debugPrint('[AdService] User earned reward: ${rewardItem.amount} ${rewardItem.type}');
          onRewardEarned();
        },
      );
    } else {
      if (_rewardedAd != null && isAdExpired) {
        debugPrint('[AdService] Rewarded ad expired. Disposing stale ad.');
        _rewardedAd?.dispose();
        _rewardedAd = null;
        _rewardedAdLoadedAt = null;
      }
      debugPrint('[AdService] Rewarded ad not ready yet. Triggering graceful fallback and preloading for next time...');
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

    if (_rewardedAd != null && !isAdExpired) {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
          debugPrint('[AdService] User earned reward via AdMob: ${rewardItem.amount} ${rewardItem.type}');
          onRewardEarned();
        },
      );
    } else {
      if (_rewardedAd != null && isAdExpired) {
        _rewardedAd?.dispose();
        _rewardedAd = null;
        _rewardedAdLoadedAt = null;
      }
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
