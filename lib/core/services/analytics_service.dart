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

  /// Synchronizes high-level player segments as Firebase User Properties.
  Future<void> syncUserProperties({
    required int level,
    required int day,
    required double balance,
    required int carCount,
  }) async {
    try {
      final wealthBracket = balance < 50000
          ? 'under_50k'
          : balance < 250000
              ? '50k_250k'
              : balance < 1000000
                  ? '250k_1m'
                  : '1m_plus';

      await _analytics?.setUserProperty(
        name: 'dealership_level',
        value: level.toString(),
      );
      await _analytics?.setUserProperty(
        name: 'game_day',
        value: day.toString(),
      );
      await _analytics?.setUserProperty(
        name: 'wealth_bracket',
        value: wealthBracket,
      );
      await _analytics?.setUserProperty(
        name: 'owned_cars_count',
        value: carCount.toString(),
      );

      if (kDebugMode) {
        debugPrint('[Analytics] UserProperties synced: Lvl $level, Day $day, $wealthBracket, $carCount cars');
      }
    } catch (e) {
      debugPrint('[AnalyticsService] syncUserProperties error: $e');
    }
  }

  /// Logs daily progression and key dealership metrics.
  Future<void> logDayPassed({
    required int day,
    required double balance,
    required int carCount,
    required int reputation,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'day_passed',
        parameters: {
          'day': day,
          'balance': balance,
          'car_count': carCount,
          'reputation': reputation,
        },
      );
      if (kDebugMode) {
        debugPrint('[Analytics] day_passed: Day $day, Balance: $balance');
      }
    } catch (e) {
      debugPrint('[AnalyticsService] logDayPassed error: $e');
    }
  }

  /// Logs vehicle repair and maintenance actions.
  Future<void> logCarRepaired({
    required String brand,
    required String model,
    required double cost,
    required String repairType,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'car_repaired',
        parameters: {
          'brand': brand,
          'model': model,
          'cost': cost,
          'repair_type': repairType,
        },
      );
      if (kDebugMode) {
        debugPrint('[Analytics] car_repaired: $brand $model ($repairType) for ₺$cost');
      }
    } catch (e) {
      debugPrint('[AnalyticsService] logCarRepaired error: $e');
    }
  }

  /// Logs acquisition of side facilities (e.g. car wash, detailing, expertise).
  Future<void> logSideBusinessPurchased({
    required String businessId,
    required String businessName,
    required double price,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'side_business_purchased',
        parameters: {
          'business_id': businessId,
          'business_name': businessName,
          'price': price,
        },
      );
      if (kDebugMode) {
        debugPrint('[Analytics] side_business_purchased: $businessName ($price)');
      }
    } catch (e) {
      debugPrint('[AnalyticsService] logSideBusinessPurchased error: $e');
    }
  }

  /// Logs player choice in random narrative events.
  Future<void> logRandomEventChoice({
    required String eventId,
    required String choiceId,
    int? balanceChange,
    int? reputationChange,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'random_event_choice',
        parameters: {
          'event_id': eventId,
          'choice_id': choiceId,
          if (balanceChange != null) 'balance_change': balanceChange,
          if (reputationChange != null) 'reputation_change': reputationChange,
        },
      );
      if (kDebugMode) {
        debugPrint('[Analytics] random_event_choice: Event $eventId Choice $choiceId');
      }
    } catch (e) {
      debugPrint('[AnalyticsService] logRandomEventChoice error: $e');
    }
  }

  /// Logs first vehicle acquisition or sale for onboarding funnel tracking.
  Future<void> logFirstCarAction({required bool isBuy}) async {
    try {
      final eventName = isBuy ? 'first_car_purchased' : 'first_car_sold';
      await _analytics?.logEvent(name: eventName);
      if (kDebugMode) {
        debugPrint('[Analytics] Funnel Event: $eventName');
      }
    } catch (e) {
      debugPrint('[AnalyticsService] logFirstCarAction error: $e');
    }
  }

  /// Logs critical financial distress or bankruptcy.
  Future<void> logBankruptcy({
    required int day,
    required double balance,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'game_bankruptcy',
        parameters: {
          'day': day,
          'balance': balance,
        },
      );
      if (kDebugMode) {
        debugPrint('[Analytics] game_bankruptcy: Day $day, Balance: $balance');
      }
    } catch (e) {
      debugPrint('[AnalyticsService] logBankruptcy error: $e');
    }
  }

  /// Logs player progress through onboarding and tutorial steps.
  Future<void> logTutorialStep({
    required String stepName,
    required int stepIndex,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'tutorial_step',
        parameters: {
          'step_name': stepName,
          'step_index': stepIndex,
        },
      );
      if (kDebugMode) {
        debugPrint('[Analytics] tutorial_step: $stepIndex • $stepName');
      }
    } catch (e) {
      debugPrint('[AnalyticsService] logTutorialStep error: $e');
    }
  }

  /// Logs successful tutorial completion.
  Future<void> logTutorialCompleted() async {
    try {
      await _analytics?.logTutorialComplete();
      await _analytics?.logEvent(name: 'tutorial_finished_custom');
      if (kDebugMode) {
        debugPrint('[Analytics] tutorial_complete');
      }
    } catch (e) {
      debugPrint('[AnalyticsService] logTutorialCompleted error: $e');
    }
  }

  /// Logs incoming customer buyer offer generation.
  Future<void> logOfferReceived({
    required String carId,
    required double offerAmount,
    required bool isFirstSale,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'offer_received',
        parameters: {
          'car_id': carId,
          'offer_amount': offerAmount,
          'is_first_sale': isFirstSale ? 1 : 0,
        },
      );
      if (kDebugMode) {
        debugPrint('[Analytics] offer_received: $offerAmount (First: $isFirstSale)');
      }
    } catch (e) {
      debugPrint('[AnalyticsService] logOfferReceived error: $e');
    }
  }
}
