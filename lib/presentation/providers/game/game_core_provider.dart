import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/dealership_model.dart';
import '../../../data/models/mission_model.dart';
import '../../../domain/usecases/market_engine.dart';
import '../../../domain/usecases/mission_factory.dart';
import '../../../domain/usecases/offline_progression.dart';
import '../../../domain/usecases/psychology_engine.dart';

import 'game_base_notifier.dart';
import 'game_casino_mixin.dart';
import 'game_finance_mixin.dart';
import 'game_inventory_mixin.dart';
import 'game_market_mixin.dart';
import 'game_monetization_mixin.dart';
import 'game_rental_mixin.dart';
import 'game_scrapyard_mixin.dart';
import 'game_staff_mixin.dart';
import 'game_time_mixin.dart';
import 'game_workshop_detailing_mixin.dart';

class GameCoreNotifier extends GameBaseNotifier
    with
        GameCasinoMixin,
        GameFinanceMixin,
        GameInventoryMixin,
        GameMarketMixin,
        GameMonetizationMixin,
        GameRentalMixin,
        GameScrapyardMixin,
        GameStaffMixin,
        GameTimeMixin,
        GameWorkshopDetailingMixin {
  Timer? _saveDebounceTimer;
  Map<String, dynamic>? pendingOfflineRecap;
  bool _isLoaded = false;

  @override
  bool get isLoaded => _isLoaded;

  Map<String, dynamic>? consumePendingOfflineRecap() {
    final recap = pendingOfflineRecap;
    pendingOfflineRecap = null;
    return recap;
  }

  GameCoreNotifier() : super(DealershipModel.initial()) {
    _loadState();
  }

  @override
  void dispose() {
    _saveDebounceTimer?.cancel();
    stopPeriodicOrganicOfferTimer();
    super.dispose();
  }

  /// Freezes background timers and flushes save to disk when app is paused
  void onAppPaused() {
    stopPeriodicOrganicOfferTimer();
    flushSaveNow();
  }

  /// Resumes background periodic timers when app is resumed
  void onAppResumed() {
    startPeriodicOrganicOfferTimer();
  }

  static const String _storageKey = 'dealership_state_v2';

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final jsonString = prefs.getString(_storageKey);

    if (jsonString != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(jsonString);
        final loaded = DealershipModel.fromJson(decoded);

        // Sync last_celebrated_level to loaded level so existing profiles never trigger level-up modal on launch
        final savedCelebratedLevel = prefs.getInt('last_celebrated_level') ?? 0;
        if (loaded.level > savedCelebratedLevel) {
          await prefs.setInt('last_celebrated_level', loaded.level);
        }

        // Calculate calendar-day login streak & freeze consumption
        final now = DateTime.now();
        final streak = PsychologyEngine.calculateLoginStreak(
          lastLoginDate: loaded.lastLoginDate,
          currentStreak: loaded.loginStreak,
          now: now,
          hasStreakFreeze: loaded.hasStreakFreeze,
        );
        final calDays = DateTime(now.year, now.month, now.day)
            .difference(
              DateTime(loaded.lastLoginDate.year, loaded.lastLoginDate.month,
                  loaded.lastLoginDate.day),
            )
            .inDays;
        final bool freezeConsumed = loaded.hasStreakFreeze && (calDays > 1);

        // Filter expired offers
        final activeOffers =
            loaded.incomingOffers.where((o) => !o.isExpired).toList();

        // Process offline time progression
        final offlineResult = OfflineProgression.processOfflineTime(
            loaded.copyWith(incomingOffers: activeOffers));
        DealershipModel updated =
            offlineResult['updatedDealership'] as DealershipModel;
        updated = updated.copyWith(
          loginStreak: streak,
          lastLoginDate: now,
          hasStreakFreeze: freezeConsumed ? false : updated.hasStreakFreeze,
        );

        final offlineHours = (offlineResult['hoursAway'] as int?) ??
            (offlineResult['offlineHours'] as int? ?? 0);
        final elapsedMinutes = (offlineResult['elapsedMinutes'] as int?) ?? 0;
        final earnedIncome = (offlineResult['earnedIncome'] as double?) ??
            (offlineResult['passiveIncome'] as double? ?? 0.0);
        final partsArrivedCount =
            offlineResult['partsArrivedCount'] as int? ?? 0;
        final newOffersCount = offlineResult['newOffersCount'] as int? ?? 0;

        if (offlineHours > 0 || elapsedMinutes >= 30) {
          pendingOfflineRecap = PsychologyEngine.getOfflineRecapSummary(
            offlineHours: offlineHours > 0 ? offlineHours : 1,
            earnedIncome: earnedIncome,
            partsArrivedCount: partsArrivedCount,
            newOffersCount: newOffersCount,
            streakDays: streak,
          );
        }

        if (!mounted) return;
        state = updated;
        _isLoaded = true;
        syncRentalState();
        startPeriodicOrganicOfferTimer();
        saveState();
        return;
      } catch (e) {
        debugPrint('GameCoreProvider save load error: $e');
        // Fallback: Backup corrupted state for diagnostics and clear primary key
        await prefs.setString('${_storageKey}_corrupted_backup', jsonString);
        await prefs.remove(_storageKey);
      }
    }

    final savedCelebratedLevel = prefs.getInt('last_celebrated_level') ?? 0;
    if (savedCelebratedLevel < 1) {
      await prefs.setInt('last_celebrated_level', 1);
    }
    if (!mounted) return;
    state = DealershipModel.initial();
    _isLoaded = true;
    startPeriodicOrganicOfferTimer();
    saveState();
  }

  @override
  void saveState() {
    if (!mounted) return;
    _checkAchievementsInternal();

    _saveDebounceTimer?.cancel();
    _saveDebounceTimer = Timer(const Duration(milliseconds: 350), () async {
      if (!mounted) return;
      final jsonMap = state.toJson();
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;

      String jsonString;
      try {
        if (!kIsWeb) {
          jsonString = await compute(_encodeDealershipToJson, jsonMap);
        } else {
          jsonString = jsonEncode(jsonMap);
        }
      } catch (_) {
        jsonString = jsonEncode(jsonMap);
      }

      await prefs.setString(_storageKey, jsonString);
    });
  }

  /// Forces an immediate save to disk
  Future<void> flushSaveNow() async {
    _saveDebounceTimer?.cancel();
    final jsonMap = state.toJson();
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    String jsonString;
    try {
      if (!kIsWeb) {
        jsonString = await compute(_encodeDealershipToJson, jsonMap);
      } else {
        jsonString = jsonEncode(jsonMap);
      }
    } catch (_) {
      jsonString = jsonEncode(jsonMap);
    }

    await prefs.setString(_storageKey, jsonString);
  }

  void _checkAchievementsInternal() {
    bool hasChanged = false;
    final updated = state.achievements.map((a) {
      if (a.isUnlocked) return a;
      bool unlock = false;
      switch (a.id) {
        case 'first_buy':
          unlock = state.ownedCars.isNotEmpty || state.carsSold > 0;
          break;
        case 'first_sale':
          unlock = state.carsSold >= 1;
          break;
        case 'sales_10':
          unlock = state.carsSold >= 10;
          break;
        case 'sales_50':
          unlock = state.carsSold >= 50;
          break;
        case 'dealer_baron':
          unlock = state.totalProfit >= 250000;
          break;
        case 'side_business_1':
          unlock = state.sideBusinesses.any((b) => b.isOwned);
          break;
        case 'stock_investor':
          unlock = state.ownedStocks.isNotEmpty;
          break;
        case 'streak_7':
          unlock = state.loginStreak >= 7;
          break;
        case 'expert_master':
          unlock = state.skills.eyeForDetail >= 2 || state.carsSold >= 3;
          break;
        case 'restoration_king':
          unlock = state.ownedCars.any((c) =>
              c.expertise.engineCondition >= 99 &&
              c.expertise.transmissionCondition >= 99 &&
              (c.isDetailedCleaned || (c.isWashed && c.isPolished)));
          break;
        case 'restoration_5':
          final restoredCount = state.ownedCars
                  .where((c) =>
                      c.expertise.engineCondition >= 95 &&
                      c.expertise.transmissionCondition >= 95)
                  .length +
              (state.carsSold >= 5 ? 3 : 0);
          unlock = restoredCount >= 5;
          break;
      }
      if (unlock) {
        hasChanged = true;
        return a.copyWith(isUnlocked: true);
      }
      return a;
    }).toList();

    if (hasChanged) {
      state = state.copyWith(achievements: updated);
    }
  }

  @override
  void checkAchievement(String id) {
    final list = state.achievements.map((a) {
      if (a.id == id && !a.isUnlocked) {
        return a.copyWith(isUnlocked: true);
      }
      return a;
    }).toList();

    state = state.copyWith(achievements: list);
  }

  final List<DateTime> _recentXpTimestamps = [];

  @override
  void addXP(int amount) {
    if (amount <= 0) return;

    // 1. Anti-Exploit Single Transaction Ceiling
    final rawAmount = amount.clamp(1, 500);

    // 2. Anti-Exploit Rolling Frequency Decay (Last 60 seconds)
    final now = DateTime.now();
    _recentXpTimestamps.removeWhere((t) => now.difference(t).inSeconds > 60);

    double multiplier = 1.0;
    if (_recentXpTimestamps.length >= 15) {
      multiplier = 0.25; // High decay if >15 rapid actions in 60s
    } else if (_recentXpTimestamps.length >= 8) {
      multiplier = 0.60; // Mild decay if >8 rapid actions in 60s
    }

    _recentXpTimestamps.add(now);

    final int effectiveXp = (rawAmount * multiplier).round().clamp(1, 500);
    final updatedSkills =
        state.skills.copyWith(xp: state.skills.xp + effectiveXp);
    final calculatedLevel = updatedSkills.currentLevel;
    final isLevelUp = calculatedLevel > state.level;
    final newLevel = isLevelUp ? calculatedLevel : state.level;

    // Level 3 milestone grants Streak Freeze reward (§3.3)
    final grantFreeze = newLevel >= 3 && !state.hasStreakFreeze;

    List<MissionModel> updatedMissions = state.activeMissions;
    if (isLevelUp) {
      updatedMissions = MissionFactory.generateDailyMissions(
        newLevel,
        unlockedBuildings: state.unlockedBuildings,
      );
    }

    state = state.copyWith(
      skills: updatedSkills,
      level: newLevel,
      hasStreakFreeze: grantFreeze ? true : state.hasStreakFreeze,
      activeMissions: updatedMissions,
    );
    checkAndUnlockFeatures();
    saveState();
  }

  /// Mağaza Puanlama & Geri Bildirim Tek Seferlik Teşvik Fonu (₺100.000 + 100 XP)
  bool claimReviewReward() {
    if (state.hasReceivedReviewReward) return false;

    state = state.copyWith(
      balance: state.balance + 100000.0,
      hasReceivedReviewReward: true,
      reputationScore: (state.reputationScore + 15).clamp(0, 1000),
    );
    addXP(100);
    saveState();
    return true;
  }

  void checkAndUnlockFeatures() {
    final baseRoutes = {
      '/marketplace',
      '/showroom',
      '/expertise',
      '/character-growth',
      '/settings',
      '/dealership-identity',
      '/theme-store',
      '/branches',
    };

    if (!state.unlockedBuildings.containsAll(baseRoutes)) {
      state = state.copyWith(
        unlockedBuildings: {...state.unlockedBuildings, ...baseRoutes},
      );
    }
  }

  @override
  void updateMissionProgress(MissionType type, int amount) {
    final updatedMissions = state.activeMissions.map((m) {
      if (m.type == type && !m.isCompleted) {
        final newProgress = (m.currentProgress + amount).clamp(0, m.targetGoal);
        return m.copyWith(
          currentProgress: newProgress,
          isCompleted: newProgress >= m.targetGoal,
        );
      }
      return m;
    }).toList();

    state = state.copyWith(activeMissions: updatedMissions);
  }

  @override
  bool checkAndAwardFirstTimeAction(
    String actionKey, {
    String? label,
    double bonusMoney = 5000.0,
    int bonusXP = 5,
  }) {
    if (state.completedFirstTimeActions.contains(actionKey)) {
      return false;
    }

    final updatedSet = Set<String>.from(state.completedFirstTimeActions)
      ..add(actionKey);
    state = state.copyWith(
      completedFirstTimeActions: updatedSet,
      balance: state.balance + bonusMoney,
    );
    addXP(bonusXP);

    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}

    saveState();
    return true;
  }

  @override
  void refreshMarketTrends() {
    final newTrend = MarketEngine.generateMarketTrend();
    state = state.copyWith(marketTrend: newTrend);
    saveState();
  }

  @override
  void completeTutorial() {
    if (state.tutorialCompleted) return; // Prevent duplicate rewards
    state = state.copyWith(
      tutorialCompleted: true,
      balance: state.balance +
          50000.0, // Bonus capital reward for completing tutorial!
    );
    saveState();
  }

  /// Claim daily login streak reward
  int claimDailyStreak() {
    final reward = PsychologyEngine.getStreakReward(state.loginStreak);
    state = state.copyWith(
      balance: state.balance + reward,
      lastLoginDate: DateTime.now(),
      lastRewardClaimDate: DateTime.now(),
    );
    addXP(50);
    saveState();
    return reward;
  }

  /// Advance tutorial step index
  void advanceTutorialStep(int nextStepIndex) {
    state = state.copyWith(tutorialStepIndex: nextStepIndex);
    saveState();
  }

  /// Update player identity, gallery title, logo emblem and character origin
  void updateDealershipIdentity({
    String? playerName,
    String? dealershipName,
    String? logoEmblemId,
    CharacterOrigin? characterOrigin,
    String? logoBadgeShape,
    String? logoBadgeColor,
    String? dealershipTagline,
  }) {
    state = state.copyWith(
      playerName: playerName ?? state.playerName,
      dealershipName: dealershipName ?? state.dealershipName,
      logoEmblemId: logoEmblemId ?? state.logoEmblemId,
      characterOrigin: characterOrigin ?? state.characterOrigin,
      logoBadgeShape: logoBadgeShape ?? state.logoBadgeShape,
      logoBadgeColor: logoBadgeColor ?? state.logoBadgeColor,
      dealershipTagline: dealershipTagline ?? state.dealershipTagline,
    );
    saveState();
  }

  /// Perform Dynasty Season Reset (§2.7)
  void performDynastySeasonReset({CharacterOrigin? newOrigin}) {
    state = state.performPrestigeReset(newOrigin: newOrigin);
    saveState();
  }

  /// Reset progress
  void resetGame() {
    state = DealershipModel.initial();
    saveState();
  }

  void unlockBuilding(String route, double cost) {
    if (state.unlockedBuildings.contains(route)) return;
    if (state.balance < cost) return;
    final updated = {...state.unlockedBuildings, route};
    state = state.copyWith(
      balance: state.balance - cost,
      unlockedBuildings: updated,
    );
    saveState();
  }

  /// Dev / God Mode: Add Cheat Funds
  void addCheatFunds(double amount) {
    state = state.copyWith(balance: state.balance + amount);
    saveState();
  }

  /// Dev / God Mode: Unlock All Properties & Level 8 (Mega Otomotiv Holding Plazası)
  void unlockAllPropertiesAndMaxLevel() {
    final allPropertiesAndRoutes = {
      'property_tier_2',
      'property_tier_3',
      'property_tier_4',
      'property_tier_5',
      'property_tier_6',
      'property_tier_7',
      'property_tier_8',
      '/marketplace',
      '/showroom',
      '/expertise',
      '/branches',
      '/character-growth',
      '/settings',
      '/dealership-identity',
      '/theme-store',
      '/car-wash',
      '/history',
      '/workshop',
      '/staff',
      '/staff-academy',
      '/tuning-studio',
      '/showroom-decor',
      '/auction',
      '/finance',
      '/reviews',
      '/bank-investments',
      '/stock-market',
      '/rent-a-car',
      '/black-market',
      '/district-market',
      '/districts',
      '/gossip-hotline',
      '/gossip',
      '/scrapyard',
      '/side-businesses',
      '/consignment-market',
      '/consignment',
      '/second-branch',
      '/vip-appointments',
      '/customs-import',
      '/guild-chamber',
      '/franchise',
      '/prestige-dynasty',
      '/night-market',
    };

    final updatedSkills = state.skills.copyWith(
      xp: 250000,
      negotiationLevel: 10,
      eyeForDetail: 10,
      marketSense: 10,
      reputation: 10,
      financeSense: 10,
    );

    state = state.copyWith(
      level: 8,
      maxGarageSlots: 20,
      reputationScore: 100,
      skills: updatedSkills,
      unlockedBuildings: {
        ...state.unlockedBuildings,
        ...allPropertiesAndRoutes
      },
    );
    saveState();
  }

  /// Dev / God Mode: Set Specific Level (1 to 8) and unlock appropriate properties
  void setLevel(int targetLevel) {
    final clamped = targetLevel.clamp(1, 8);
    final updatedBuildings = Set<String>.from(state.unlockedBuildings);

    int slots = 3;
    if (clamped >= 2) {
      slots = 4;
      updatedBuildings.addAll({'property_tier_2', '/car-wash', '/history'});
    }
    if (clamped >= 3) {
      slots = 6;
      updatedBuildings
          .addAll({'property_tier_3', '/workshop', '/staff', '/staff-academy'});
    }
    if (clamped >= 4) {
      slots = 8;
      updatedBuildings
          .addAll({'property_tier_4', '/tuning-studio', '/showroom-decor'});
    }
    if (clamped >= 5) {
      slots = 10;
      updatedBuildings
          .addAll({'property_tier_5', '/auction', '/finance', '/reviews'});
    }
    if (clamped >= 6) {
      slots = 13;
      updatedBuildings
          .addAll({'property_tier_6', '/bank-investments', '/stock-market'});
    }
    if (clamped >= 7) {
      slots = 16;
      updatedBuildings.addAll({
        'property_tier_7',
        '/rent-a-car',
        '/black-market',
        '/district-market',
        '/districts',
        '/gossip-hotline',
        '/gossip'
      });
    }
    if (clamped >= 8) {
      slots = 20;
      updatedBuildings.addAll({
        'property_tier_8',
        '/scrapyard',
        '/side-businesses',
        '/consignment-market',
        '/consignment',
        '/second-branch',
        '/vip-appointments',
        '/customs-import',
        '/guild-chamber',
        '/franchise',
        '/prestige-dynasty'
      });
    }

    state = state.copyWith(
      level: clamped,
      maxGarageSlots: slots,
      unlockedBuildings: updatedBuildings,
    );
    saveState();
  }

  /// Dev / God Mode: Clear Garage
  void clearGarage() {
    state = state.copyWith(ownedCars: []);
    saveState();
  }
}

final gameCoreProvider =
    StateNotifierProvider<GameCoreNotifier, DealershipModel>((ref) {
  return GameCoreNotifier();
});

/// Top-level helper function for background isolate serialization
String _encodeDealershipToJson(Map<String, dynamic> jsonMap) =>
    jsonEncode(jsonMap);
