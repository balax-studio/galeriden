import 'dart:async';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'analytics_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../presentation/widgets/ads/neo_brutal_fallback_ad_dialog.dart';
import 'ad_reward_calculator.dart';

/// Singleton Service to manage Google Mobile Ads (AdMob) Rewarded Video and Native Advanced Ads
class AdService with ChangeNotifier {
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
  DateTime? _lastRewardedAdFailedAt;

  /// Cooldown window after an ad failed to load, preventing request storms and protecting AdMob match rate
  static const Duration rewardedAdFailureCooldown = Duration(seconds: 45);

  /// Determines if a native ad or in-game sponsored window should be active on a given in-game day.
  ///
  /// Rule: Day 1 (currentDay < 2) is completely ad-free and sponsor-free (closed).
  /// From Day 2 onwards, native ad slots are consistently active across all game domains.
  static bool shouldShowNativeAdForDay(int currentDay, [dynamic contextType]) {
    if (currentDay < 2) {
      return false;
    }
    return true;
  }

  static const Duration minNativeAdInterval = Duration(milliseconds: 1500);
  DateTime? _lastNativeAdRequestedAt;

  static const int maxNativeAdPoolSize = 6;
  final List<NativeAd> _preloadedNativeAdPool = [];
  final List<DateTime> _preloadedNativeAdPoolLoadedAt = [];
  bool _isPreloadingNativeAd = false;
  int _nativeAdRetryAttempt = 0;
  DateTime? _lastNativeAdFailedAt;

  /// Cooldown after a native ad load failure (Rule 9 invariant)
  static const Duration nativeAdFailureCooldown = Duration(seconds: 45);

  /// Whether the background pool is currently fetching a native ad
  bool get isPreloadingNativeAd => _isPreloadingNativeAd;

  /// Purges expired native ads from the cache pool (>50 min)
  void _purgeExpiredPreloadedAds() {
    final now = DateTime.now();
    for (int i = _preloadedNativeAdPool.length - 1; i >= 0; i--) {
      if (now.difference(_preloadedNativeAdPoolLoadedAt[i]) >
          adExpirationThreshold) {
        _preloadedNativeAdPool[i].dispose();
        _preloadedNativeAdPool.removeAt(i);
        _preloadedNativeAdPoolLoadedAt.removeAt(i);
      }
    }
  }

  /// Checks if at least one valid, unexpired preloaded native ad is ready in the cache pool
  bool get hasPreloadedNativeAd {
    if (kIsWeb || !_isInitialized) return false;
    _purgeExpiredPreloadedAds();
    return _preloadedNativeAdPool.isNotEmpty;
  }

  /// Current count of warm preloaded native ads available in cache pool
  int get preloadedNativeAdCount {
    if (kIsWeb || !_isInitialized) return 0;
    _purgeExpiredPreloadedAds();
    return _preloadedNativeAdPool.length;
  }

  /// Global throttle checking if a native ad can be requested to protect AdMob show rate
  bool get canRequestNativeAd {
    if (kIsWeb || !_isInitialized) return false;
    if (_lastNativeAdRequestedAt == null) return true;
    return DateTime.now().difference(_lastNativeAdRequestedAt!) >=
        minNativeAdInterval;
  }

  /// Marks that a native ad request was sent to AdMob, updating the global throttle.
  void markNativeAdRequested() {
    _lastNativeAdRequestedAt = DateTime.now();
  }

  /// Preloads native ads into the cache pool up to [targetCount] (max [maxNativeAdPoolSize]).
  void preloadNativeAdPool({int targetCount = maxNativeAdPoolSize}) {
    if (kIsWeb || !_isInitialized) return;
    _purgeExpiredPreloadedAds();

    final desired = targetCount.clamp(1, maxNativeAdPoolSize);
    if (_preloadedNativeAdPool.length >= desired || _isPreloadingNativeAd) {
      return;
    }

    _preloadNextInPool(desired);
  }

  void _preloadNextInPool(int targetCount, {bool isRetry = false}) {
    if (kIsWeb || !_isInitialized || _isPreloadingNativeAd) return;
    _purgeExpiredPreloadedAds();
    if (_preloadedNativeAdPool.length >= targetCount) return;

    if (!isRetry && _lastNativeAdFailedAt != null) {
      if (DateTime.now().difference(_lastNativeAdFailedAt!) <
          nativeAdFailureCooldown) {
        debugPrint(
            '[AdService] Native ad pool preload throttled due to failure cooldown (45s).');
        return;
      } else {
        _nativeAdRetryAttempt = 0;
      }
    }

    _isPreloadingNativeAd = true;
    try {
      final ad = createNativeAd(
        onAdLoaded: (loadedAd) {
          debugPrint(
              '[AdService] Native ad #${_preloadedNativeAdPool.length + 1} preloaded and added to pool.');
          _preloadedNativeAdPool.add(loadedAd);
          _preloadedNativeAdPoolLoadedAt.add(DateTime.now());
          _isPreloadingNativeAd = false;
          _nativeAdRetryAttempt = 0;
          _lastNativeAdFailedAt = null;
          notifyListeners();

          // If more ads needed to fill pool to targetCount, stagger next fetch safely with 1500ms anti-spam interval
          if (_preloadedNativeAdPool.length < targetCount) {
            Future.delayed(const Duration(milliseconds: 1500), () {
              _preloadNextInPool(targetCount);
            });
          }
        },
        onAdFailedToLoad: (error) {
          debugPrint(
              '[AdService] Native ad pool preload failed: ${error.message} - code: ${error.code}');
          _isPreloadingNativeAd = false;
          _lastNativeAdFailedAt = DateTime.now();
          _nativeAdRetryAttempt++;
          notifyListeners();
          if (_nativeAdRetryAttempt <= 2) {
            final delay = Duration(seconds: 45 + (_nativeAdRetryAttempt * 15));
            debugPrint(
                '[AdService] Retrying native ad pool preload in ${delay.inSeconds}s (attempt $_nativeAdRetryAttempt/2)...');
            Future.delayed(delay, () {
              if (_preloadedNativeAdPool.length < targetCount &&
                  !_isPreloadingNativeAd) {
                _preloadNextInPool(targetCount, isRetry: true);
              }
            });
          }
        },
      );
      markNativeAdRequested();
      ad.load();
    } catch (e) {
      debugPrint('[AdService] createNativeAd pool exception: $e');
      _isPreloadingNativeAd = false;
      _lastNativeAdFailedAt = DateTime.now();
      notifyListeners();
    }
  }

  /// Preloads native ads into the warm singleton cache pool.
  void preloadNativeAd() {
    preloadNativeAdPool(targetCount: maxNativeAdPoolSize);
  }

  /// Consumes the first available warm NativeAd from the pool and transfers ownership to the caller widget.
  /// Automatically replenishes the cache pool in the background.
  NativeAd? consumePreloadedNativeAd() {
    _purgeExpiredPreloadedAds();
    if (_preloadedNativeAdPool.isEmpty) return null;

    final ad = _preloadedNativeAdPool.removeAt(0);
    _preloadedNativeAdPoolLoadedAt.removeAt(0);

    // Replenish pool in background gently so subsequent ad slots stay warm
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_preloadedNativeAdPool.length < maxNativeAdPoolSize &&
          !_isPreloadingNativeAd) {
        preloadNativeAdPool(targetCount: maxNativeAdPoolSize);
      }
    });

    return ad;
  }

  /// Disposes all unconsumed preloaded native ads in the cache pool.
  void disposePreloadedNativeAd() {
    for (final ad in _preloadedNativeAdPool) {
      ad.dispose();
    }
    _preloadedNativeAdPool.clear();
    _preloadedNativeAdPoolLoadedAt.clear();
    _isPreloadingNativeAd = false;
    notifyListeners();
  }

  /// Initialize early platform services.
  /// On Android, MobileAds is initialized immediately.
  /// On iOS, MobileAds initialization is coordinated with ATT via [initializeWithTrackingConsent].
  Future<void> initialize() async {
    if (kIsWeb) return;
    if (_isInitialized) return;

    if (defaultTargetPlatform != TargetPlatform.iOS) {
      try {
        await MobileAds.instance.initialize();
        _isInitialized = true;

        try {
          await _facebookAppEvents.setAutoLogAppEventsEnabled(true);
          await _facebookAppEvents.setAdvertiserIdCollectionEnabled(true);
          await _facebookAppEvents.logEvent(name: 'fb_mobile_activate_app');
          await _facebookAppEvents.flush();
        } catch (fbError) {
          debugPrint('[AdService] Facebook App Events autoLog initialization error: $fbError');
        }

        loadRewardedAd();
        preloadNativeAd();
      } catch (e) {
        debugPrint('[AdService] MobileAds initialization failed or not supported on this platform: $e');
      }
    }
  }

  /// Coordinated iOS lifecycle startup:
  /// 1. Requests Apple ATT tracking authorization once the root view is active.
  /// 2. Configures advertiser ID tracking.
  /// 3. Initializes Google Mobile Ads SDK with resolved IDFA.
  /// 4. Preloads rewarded video ad.
  Future<void> initializeWithTrackingConsent() async {
    if (kIsWeb) return;

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        var status = await AppTrackingTransparency.trackingAuthorizationStatus;
        if (status == TrackingStatus.notDetermined) {
          await Future.delayed(const Duration(milliseconds: 500));
          status = await AppTrackingTransparency.requestTrackingAuthorization();
        }
        final isAuthorized = status == TrackingStatus.authorized;
        try {
          await _facebookAppEvents.setAutoLogAppEventsEnabled(true);
          await _facebookAppEvents.setAdvertiserIdCollectionEnabled(isAuthorized);
          await _facebookAppEvents.logEvent(name: 'fb_mobile_activate_app');
          await _facebookAppEvents.flush();
        } catch (fbError) {
          debugPrint('[AdService] Meta App Events error: $fbError');
        }
      } catch (attError) {
        debugPrint('[AdService] ATT authorization error: $attError');
      }

      if (!_isInitialized) {
        try {
          await MobileAds.instance.initialize();
          _isInitialized = true;
        } catch (e) {
          debugPrint('[AdService] MobileAds initialization error: $e');
        }
      }

      if (_rewardedAd == null && !_isAdLoading) {
        loadRewardedAd();
      }
      if (!hasPreloadedNativeAd && !_isPreloadingNativeAd) {
        preloadNativeAd();
      }
    } else {
      if (!_isInitialized) {
        await initialize();
      }
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

    if (_lastRewardedAdFailedAt != null &&
        DateTime.now().difference(_lastRewardedAdFailedAt!) < rewardedAdFailureCooldown) {
      debugPrint('[AdService] Rewarded ad request throttled due to recent failure cooldown (45s).');
      return;
    }

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
            _lastRewardedAdFailedAt = null;
            _setupAdCallbacks(ad);
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('[AdService] Rewarded ad failed to load: ${error.message} - code: ${error.code}');
            _rewardedAd = null;
            _rewardedAdLoadedAt = null;
            _isAdLoading = false;
            _lastRewardedAdFailedAt = DateTime.now();
            _retryAttempt++;
            if (_retryAttempt <= 2) {
              final delay = Duration(seconds: _retryAttempt * 30);
              debugPrint('[AdService] Delayed gentle retry in ${delay.inSeconds}s - attempt $_retryAttempt/2...');
              Future.delayed(delay, () {
                if (_rewardedAd == null && !_isAdLoading) {
                  loadRewardedAd();
                }
              });
            }
          },
        ),
      );
    } catch (e) {
      debugPrint('[AdService] RewardedAd.load exception: $e');
      _rewardedAd = null;
      _rewardedAdLoadedAt = null;
      _isAdLoading = false;
      _lastRewardedAdFailedAt = DateTime.now();
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
          AnalyticsService.instance.logAdRewardWatched(
            placement: 'rewarded_ad',
            rewardAmount: rewardItem.amount.toDouble(),
          );
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
      NeoBrutalFallbackAdDialog.show(
        context: context,
        onRewardClaimed: onRewardEarned,
        rewardTitle: customRewardTitle,
        outcome: outcome,
      );
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
