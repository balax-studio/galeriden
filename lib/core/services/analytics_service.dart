import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Centralized service to manage Firebase Analytics events and screen tracking.
class AnalyticsService {
  static final AnalyticsService instance = AnalyticsService._internal();
  AnalyticsService._internal();

  FirebaseAnalytics? _analytics;
  FirebaseAnalyticsObserver? _observer;

  /// Initializes Firebase Analytics safely.
  void initialize() {
    try {
      _analytics = FirebaseAnalytics.instance;
      _observer = FirebaseAnalyticsObserver(analytics: _analytics!);
    } catch (e) {
      debugPrint('[AnalyticsService] initialize error: $e');
    }
  }

  /// GoRouter navigation observer for automatic screen view logging.
  NavigatorObserver? get observer {
    if (_observer == null && _analytics != null) {
      _observer = FirebaseAnalyticsObserver(analytics: _analytics!);
    }
    return _observer;
  }

  /// Logs a custom screen view event.
  Future<void> logScreenView(String screenName) async {
    try {
      await _analytics?.logScreenView(screenName: screenName);
      if (kDebugMode) {
        debugPrint('[Analytics] ScreenView: $screenName');
      }
    } catch (e) {
      debugPrint('[AnalyticsService] logScreenView error: $e');
    }
  }

  /// Logs vehicle acquisition event.
  Future<void> logCarPurchased({
    required String brand,
    required String model,
    required double price,
    int? modelYear,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'car_purchased',
        parameters: {
          'brand': brand,
          'model': model,
          'price': price,
          if (modelYear != null) 'model_year': modelYear,
        },
      );
      if (kDebugMode) {
        debugPrint('[Analytics] car_purchased: $brand $model for $price');
      }
    } catch (e) {
      debugPrint('[AnalyticsService] logCarPurchased error: $e');
    }
  }

  /// Logs vehicle sale and realized profit event.
  Future<void> logCarSold({
    required String brand,
    required String model,
    required double salePrice,
    required double profit,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'car_sold',
        parameters: {
          'brand': brand,
          'model': model,
          'sale_price': salePrice,
          'profit': profit,
        },
      );
      if (kDebugMode) {
        debugPrint('[Analytics] car_sold: $brand $model profit: $profit');
      }
    } catch (e) {
      debugPrint('[AnalyticsService] logCarSold error: $e');
    }
  }

  /// Logs player level progression.
  Future<void> logLevelUp({
    required int newLevel,
    required int totalXp,
  }) async {
    try {
      await _analytics?.logLevelUp(
        level: newLevel,
      );
      await _analytics?.logEvent(
        name: 'dealership_level_up',
        parameters: {
          'level': newLevel,
          'total_xp': totalXp,
        },
      );
      if (kDebugMode) {
        debugPrint('[Analytics] level_up: $newLevel (XP: $totalXp)');
      }
    } catch (e) {
      debugPrint('[AnalyticsService] logLevelUp error: $e');
    }
  }

  /// Logs live auction participation and result.
  Future<void> logAuctionBid({
    required String carName,
    required double bidAmount,
    required bool isWon,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'auction_bid_placed',
        parameters: {
          'car_name': carName,
          'bid_amount': bidAmount,
          'is_won': isWon ? 1 : 0,
        },
      );
      if (kDebugMode) {
        debugPrint('[Analytics] auction_bid: $carName bid: $bidAmount won: $isWon');
      }
    } catch (e) {
      debugPrint('[AnalyticsService] logAuctionBid error: $e');
    }
  }

  /// Logs rewarded ad view completion.
  Future<void> logAdRewardWatched({
    required String placement,
    double? rewardAmount,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'ad_reward_watched',
        parameters: {
          'placement': placement,
          if (rewardAmount != null) 'reward_amount': rewardAmount,
        },
      );
      if (kDebugMode) {
        debugPrint('[Analytics] ad_reward_watched: $placement');
      }
    } catch (e) {
      debugPrint('[AnalyticsService] logAdRewardWatched error: $e');
    }
  }

  /// Logs loan acquisition.
  Future<void> logLoanTaken({
    required double amount,
    required int installmentCount,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'bank_loan_taken',
        parameters: {
          'amount': amount,
          'installments': installmentCount,
        },
      );
      if (kDebugMode) {
        debugPrint('[Analytics] bank_loan_taken: $amount in $installmentCount installments');
      }
    } catch (e) {
      debugPrint('[AnalyticsService] logLoanTaken error: $e');
    }
  }

  /// Logs leaderboard screen visits.
  Future<void> logLeaderboardViewed({required String activeTab}) async {
    try {
      await _analytics?.logEvent(
        name: 'leaderboard_viewed',
        parameters: {
          'tab': activeTab,
        },
      );
      if (kDebugMode) {
        debugPrint('[Analytics] leaderboard_viewed: $activeTab');
      }
    } catch (e) {
      debugPrint('[AnalyticsService] logLeaderboardViewed error: $e');
    }
  }
}
