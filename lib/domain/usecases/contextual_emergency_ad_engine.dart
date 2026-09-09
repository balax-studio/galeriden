import 'dart:math';
import '../../core/services/ad_reward_calculator.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/dealership_model.dart';
import '../../data/models/expertise_model.dart';
import '../../data/models/game_event_model.dart';

enum EmergencyNeedType {
  purchaseShortfall,
  cashCrisis,
  garageFull,
  actionQuotaExhausted,
  partsShortage,
  auctionDepositShortage,
  levelUpStagnation,
  postDisasterShock,
}

class ContextualLifelineEncounter {
  final EmergencyNeedType needType;
  final String titleKey;
  final String subtitleKey;
  final String storyDialogueKey;
  final String perkSummaryKey;
  final Map<String, String> translationArgs;
  final String callerNameKey;
  final String callerRoleKey;
  final String avatarKey;
  final int accentColorHex;
  final String ctaKey;
  final String dismissKey;
  final double grantAmount;
  final int reputationBonus;
  final int garageSlotBonus;
  final bool resetDailyActions;
  final bool grantPartsCrate;

  const ContextualLifelineEncounter({
    required this.needType,
    required this.titleKey,
    required this.subtitleKey,
    required this.storyDialogueKey,
    required this.perkSummaryKey,
    this.translationArgs = const {},
    required this.callerNameKey,
    required this.callerRoleKey,
    required this.avatarKey,
    required this.accentColorHex,
    required this.ctaKey,
    required this.dismissKey,
    this.grantAmount = 0.0,
    this.reputationBonus = 0,
    this.garageSlotBonus = 0,
    this.resetDailyActions = false,
    this.grantPartsCrate = false,
  });
}

class ContextualEmergencyAdEngine {
  ContextualEmergencyAdEngine._();

  static const int minSessionCooldownSeconds = 240;
  static int? _lastTriggerDay;
  static DateTime? _lastTriggerRealTime;

  /// Records that a lifeline has been triggered or dismissed
  static void markTriggered({required int currentDay, DateTime? now}) {
    _lastTriggerDay = currentDay;
    _lastTriggerRealTime = now ?? DateTime.now();
  }

  /// Determines whether an unprompted contextual lifeline popup can fire
  static bool canTriggerUnprompted({
    required int currentDay,
    int? lastTriggerDay,
    DateTime? lastTriggerRealTime,
    DateTime? now,
  }) {
    final effectiveDay = lastTriggerDay ?? _lastTriggerDay;
    final effectiveTime = lastTriggerRealTime ?? _lastTriggerRealTime;
    final effectiveNow = now ?? DateTime.now();

    // Onboarding protection
    if (currentDay < 2) {
      return false;
    }

    // 1. Day gate - maximum 1 automatic lifeline per in-game day
    if (effectiveDay != null && currentDay <= effectiveDay) {
      return false;
    }

    // 2. Real-world debounce - at least 4 minutes between unprompted popups
    if (effectiveTime != null) {
      final elapsed = effectiveNow.difference(effectiveTime).inSeconds;
      if (elapsed < minSessionCooldownSeconds) {
        return false;
      }
    }

    return true;
  }

  /// Evaluates player state and optional situational shortfall to pinpoint the #1 bottleneck
  static ContextualLifelineEncounter? evaluateNeed({
    required DealershipModel game,
    double? purchaseShortfall,
    String? currentScreen,
  }) {
    // 1. Direct Purchase Shortfall: Player clicked buy but is missing funds
    if (purchaseShortfall != null && purchaseShortfall > 0) {
      final grant = purchaseShortfall.clamp(10000.0, max(500000.0, purchaseShortfall)).toDouble();
      return ContextualLifelineEncounter(
        needType: EmergencyNeedType.purchaseShortfall,
        titleKey: 'lifeline_shortfall_title',
        subtitleKey: 'lifeline_shortfall_subtitle',
        storyDialogueKey: 'lifeline_shortfall_story',
        perkSummaryKey: 'lifeline_shortfall_perk',
        translationArgs: {
          'shortfall': grant.toStringAsFixed(0),
        },
        callerNameKey: 'lifeline_shortfall_caller_name',
        callerRoleKey: 'lifeline_shortfall_caller_role',
        avatarKey: 'suit',
        accentColorHex: 0xFFFFDE59, // brutalYellow
        ctaKey: 'lifeline_btn_accept_ad',
        dismissKey: 'lifeline_btn_decline',
        grantAmount: grant,
      );
    }

    // 2. Critical Cash Crisis: Dealership running low on operating capital relative to level & fleet
    final garageTotal = game.ownedCars.fold<double>(0.0, (sum, c) => sum + c.baseMarketValue);
    final crisisThreshold = max(25000.0, (game.level * 25000.0) + (garageTotal > 0 ? garageTotal * 0.015 : 0.0));
    if (game.balance < crisisThreshold) {
      final grant = AdRewardCalculator.calculateEmergencyGrant(
        playerLevel: game.level,
        playerBalance: game.balance,
        totalGarageValue: garageTotal,
      );
      return ContextualLifelineEncounter(
        needType: EmergencyNeedType.cashCrisis,
        titleKey: 'lifeline_cash_crisis_title',
        subtitleKey: 'lifeline_cash_crisis_subtitle',
        storyDialogueKey: 'lifeline_cash_crisis_story',
        perkSummaryKey: 'lifeline_cash_crisis_perk',
        translationArgs: {
          'amount': CurrencyFormatter.formatShort(grant),
        },
        callerNameKey: 'lifeline_cash_crisis_caller_name',
        callerRoleKey: 'lifeline_cash_crisis_caller_role',
        avatarKey: 'mustache',
        accentColorHex: 0xFF00E575, // brutalGreen
        ctaKey: 'lifeline_btn_accept_ad',
        dismissKey: 'lifeline_btn_decline',
        grantAmount: grant,
      );
    }

    // 3. Garage Capacity Wall: All parking spaces full
    if (game.ownedCars.length >= game.maxGarageSlots && game.maxGarageSlots < 20) {
      return const ContextualLifelineEncounter(
        needType: EmergencyNeedType.garageFull,
        titleKey: 'lifeline_garage_full_title',
        subtitleKey: 'lifeline_garage_full_subtitle',
        storyDialogueKey: 'lifeline_garage_full_story',
        perkSummaryKey: 'lifeline_garage_full_perk',
        callerNameKey: 'lifeline_garage_full_caller_name',
        callerRoleKey: 'lifeline_garage_full_caller_role',
        avatarKey: 'hat',
        accentColorHex: 0xFF00F0FF, // brutalCyan
        ctaKey: 'lifeline_btn_accept_ad',
        dismissKey: 'lifeline_btn_decline',
        garageSlotBonus: 1,
      );
    }

    // 4. Action Quota Exhausted: Daily workshop repairs or car washes hit ceiling
    final isWorkshopExhausted = game.dailyWorkshopRepairsCount >= 4;
    final isCarWashExhausted = game.dailyCarWashCount >= 4;
    if (isWorkshopExhausted || isCarWashExhausted) {
      return const ContextualLifelineEncounter(
        needType: EmergencyNeedType.actionQuotaExhausted,
        titleKey: 'lifeline_quota_title',
        subtitleKey: 'lifeline_quota_subtitle',
        storyDialogueKey: 'lifeline_quota_story',
        perkSummaryKey: 'lifeline_quota_perk',
        callerNameKey: 'lifeline_quota_caller_name',
        callerRoleKey: 'lifeline_quota_caller_role',
        avatarKey: 'mechanic',
        accentColorHex: 0xFFFF7A00, // brutalOrange
        ctaKey: 'lifeline_btn_accept_ad',
        dismissKey: 'lifeline_btn_decline',
        resetDailyActions: true,
      );
    }

    // 5. Parts Shortage: Owned damaged vehicles exist, but zero salvaged parts in inventory
    final hasDamagedCars = game.ownedCars.any((c) =>
        c.expertise.bodyParts.values.any((bp) =>
            bp == PartStatus.changed ||
            bp == PartStatus.painted ||
            bp == PartStatus.damaged) ||
        c.expertise.engineCondition < 85.0);
    if (hasDamagedCars && game.salvagedParts.isEmpty) {
      return const ContextualLifelineEncounter(
        needType: EmergencyNeedType.partsShortage,
        titleKey: 'lifeline_parts_title',
        subtitleKey: 'lifeline_parts_subtitle',
        storyDialogueKey: 'lifeline_parts_story',
        perkSummaryKey: 'lifeline_parts_perk',
        callerNameKey: 'lifeline_parts_caller_name',
        callerRoleKey: 'lifeline_parts_caller_role',
        avatarKey: 'mechanic',
        accentColorHex: 0xFFA855F7, // brutalPurple
        ctaKey: 'lifeline_btn_accept_ad',
        dismissKey: 'lifeline_btn_decline',
        grantPartsCrate: true,
      );
    }

    // 6. Auction Deposit Shortage: Insufficient cash for high-tier auction bidding
    final depositThreshold = max(50000.0, (game.level * 30000.0));
    if (game.balance < depositThreshold && game.level >= 2) {
      final depositGrant = AdRewardCalculator.calculateEmergencyGrant(
        playerLevel: game.level,
        playerBalance: game.balance,
        totalGarageValue: garageTotal,
      );
      return ContextualLifelineEncounter(
        needType: EmergencyNeedType.auctionDepositShortage,
        titleKey: 'lifeline_auction_title',
        subtitleKey: 'lifeline_auction_subtitle',
        storyDialogueKey: 'lifeline_auction_story',
        perkSummaryKey: 'lifeline_auction_perk',
        translationArgs: {
          'deposit': CurrencyFormatter.formatShort(depositGrant),
        },
        callerNameKey: 'lifeline_auction_caller_name',
        callerRoleKey: 'lifeline_auction_caller_role',
        avatarKey: 'sunglasses',
        accentColorHex: 0xFFFFDE59, // brutalYellow
        ctaKey: 'lifeline_btn_accept_ad',
        dismissKey: 'lifeline_btn_decline',
        grantAmount: depositGrant,
      );
    }

    // 7. Level-Up Stagnation: Reputation is high (>= 75 and < 100)
    if (game.reputationScore >= 75 && game.reputationScore < 100) {
      return const ContextualLifelineEncounter(
        needType: EmergencyNeedType.levelUpStagnation,
        titleKey: 'lifeline_levelup_title',
        subtitleKey: 'lifeline_levelup_subtitle',
        storyDialogueKey: 'lifeline_levelup_story',
        perkSummaryKey: 'lifeline_levelup_perk',
        callerNameKey: 'lifeline_levelup_caller_name',
        callerRoleKey: 'lifeline_levelup_caller_role',
        avatarKey: 'glasses',
        accentColorHex: 0xFF38BDF8, // brutalCyan
        ctaKey: 'lifeline_btn_accept_ad',
        dismissKey: 'lifeline_btn_decline',
        reputationBonus: 15,
      );
    }

    // 8. Post-Disaster Shock: Recent negative event occurred in history
    final hasRecentCrisis = game.recentEvents.any((e) =>
        e.type == GameEventType.badEvent ||
        (e.type == GameEventType.expense && e.amount > 15000.0));
    if (hasRecentCrisis) {
      final recentCrisisAmount = game.recentEvents
          .where((e) => e.type == GameEventType.badEvent || (e.type == GameEventType.expense && e.amount > 15000.0))
          .fold<double>(0.0, (sum, e) => sum + e.amount);
      final reliefGrant = AdRewardCalculator.calculateEmergencyGrant(
        playerLevel: game.level,
        playerBalance: game.balance,
        totalGarageValue: garageTotal,
        recentLoss: recentCrisisAmount > 0 ? recentCrisisAmount : null,
      );
      return ContextualLifelineEncounter(
        needType: EmergencyNeedType.postDisasterShock,
        titleKey: 'lifeline_disaster_title',
        subtitleKey: 'lifeline_disaster_subtitle',
        storyDialogueKey: 'lifeline_disaster_story',
        perkSummaryKey: 'lifeline_disaster_perk',
        translationArgs: {
          'amount': CurrencyFormatter.formatShort(reliefGrant),
        },
        callerNameKey: 'lifeline_disaster_caller_name',
        callerRoleKey: 'lifeline_disaster_caller_role',
        avatarKey: 'heritage',
        accentColorHex: 0xFFCCFF00, // toxicLime
        ctaKey: 'lifeline_btn_accept_ad',
        dismissKey: 'lifeline_btn_decline',
        grantAmount: reliefGrant,
      );
    }

    return null;
  }
}
