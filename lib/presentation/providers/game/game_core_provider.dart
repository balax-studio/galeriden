import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/dealership_model.dart';
import '../../../data/models/mission_model.dart';
import '../../../domain/usecases/market_engine.dart';
import '../../../domain/usecases/offline_progression.dart';
import '../../../domain/usecases/psychology_engine.dart';

import 'game_base_notifier.dart';
import 'game_finance_mixin.dart';
import 'game_inventory_mixin.dart';
import 'game_market_mixin.dart';
import 'game_staff_mixin.dart';
import 'game_time_mixin.dart';

class GameCoreNotifier extends GameBaseNotifier
    with
        GameFinanceMixin,
        GameInventoryMixin,
        GameMarketMixin,
        GameStaffMixin,
        GameTimeMixin {
  
  Timer? _saveDebounceTimer;
  Map<String, dynamic>? pendingOfflineRecap;

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

        // Calculate calendar-day login streak & freeze consumption
        final now = DateTime.now();
        final streak = PsychologyEngine.calculateLoginStreak(
          lastLoginDate: loaded.lastLoginDate,
          currentStreak: loaded.loginStreak,
          now: now,
          hasStreakFreeze: loaded.hasStreakFreeze,
        );
        final calDays = DateTime(now.year, now.month, now.day).difference(
          DateTime(loaded.lastLoginDate.year, loaded.lastLoginDate.month, loaded.lastLoginDate.day),
        ).inDays;
        final bool freezeConsumed = loaded.hasStreakFreeze && (calDays > 1);

        // Filter expired offers
        final activeOffers = loaded.incomingOffers.where((o) => !o.isExpired).toList();

        // Process offline time progression
        final offlineResult = OfflineProgression.processOfflineTime(loaded.copyWith(incomingOffers: activeOffers));
        DealershipModel updated = offlineResult['updatedDealership'] as DealershipModel;
        updated = updated.copyWith(
          loginStreak: streak,
          lastLoginDate: now,
          hasStreakFreeze: freezeConsumed ? false : updated.hasStreakFreeze,
        );

        final offlineHours = (offlineResult['hoursAway'] as int?) ?? (offlineResult['offlineHours'] as int? ?? 0);
        final elapsedMinutes = (offlineResult['elapsedMinutes'] as int?) ?? 0;
        final earnedIncome = (offlineResult['earnedIncome'] as double?) ??
            (offlineResult['passiveIncome'] as double? ?? 0.0);
        final partsArrivedCount = offlineResult['partsArrivedCount'] as int? ?? 0;
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

        state = updated;
        syncRentalState();
        startPeriodicOrganicOfferTimer();
        saveState();
        return;
      } catch (e) {
        // Fallback: Clear corrupted storage key if load fails
        await prefs.remove(_storageKey);
      }
    }

    state = DealershipModel.initial();
    startPeriodicOrganicOfferTimer();
    saveState();
  }

  @override
  void saveState() {
    if (!mounted) return;
    _checkAchievementsInternal();
    
    _saveDebounceTimer?.cancel();
    _saveDebounceTimer = Timer(const Duration(milliseconds: 350), () async {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final jsonString = jsonEncode(state.toJson());
      await prefs.setString(_storageKey, jsonString);
    });
  }

  /// Forces an immediate save to disk
  Future<void> flushSaveNow() async {
    _saveDebounceTimer?.cancel();
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final jsonString = jsonEncode(state.toJson());
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
          final restoredCount = state.ownedCars.where((c) =>
              c.expertise.engineCondition >= 95 &&
              c.expertise.transmissionCondition >= 95).length + (state.carsSold >= 5 ? 3 : 0);
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

  @override
  void addXP(int amount) {
    final updatedSkills = state.skills.copyWith(xp: state.skills.xp + amount);
    final calculatedLevel = updatedSkills.currentLevel;
    final newLevel = calculatedLevel > state.level ? calculatedLevel : state.level;
    
    // Level 3 milestone grants Streak Freeze reward (§3.3)
    final grantFreeze = newLevel >= 3 && !state.hasStreakFreeze;

    state = state.copyWith(
      skills: updatedSkills,
      level: newLevel,
      hasStreakFreeze: grantFreeze ? true : state.hasStreakFreeze,
    );
    checkAndUnlockFeatures();
    saveState();
  }

  void checkAndUnlockFeatures() {
    final baseRoutes = {
      '/marketplace',
      '/showroom',
      '/expertise',
      '/car-wash',
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
      balance: state.balance + 50000.0, // Bonus capital reward for completing tutorial!
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
  }) {
    state = state.copyWith(
      playerName: playerName ?? state.playerName,
      dealershipName: dealershipName ?? state.dealershipName,
      logoEmblemId: logoEmblemId ?? state.logoEmblemId,
      characterOrigin: characterOrigin ?? state.characterOrigin,
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

  /// Dev / God Mode: Unlock All Properties & Level 4 (Mega Otomotiv Kalesi)
  void unlockAllPropertiesAndMaxLevel() {
    state = state.copyWith(
      level: 4,
      maxGarageSlots: 15,
      reputationScore: 100,
    );
    saveState();
  }

  /// Dev / God Mode: Clear Garage
  void clearGarage() {
    state = state.copyWith(ownedCars: []);
    saveState();
  }
}

final gameCoreProvider = StateNotifierProvider<GameCoreNotifier, DealershipModel>((ref) {
  return GameCoreNotifier();
});
