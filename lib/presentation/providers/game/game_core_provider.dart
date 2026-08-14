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
  
  GameCoreNotifier() : super(DealershipModel.initial()) {
    _loadState();
    startPeriodicOrganicOfferTimer();
  }

  @override
  void dispose() {
    stopPeriodicOrganicOfferTimer();
    super.dispose();
  }

  static const String _storageKey = 'dealership_state_v2';

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(jsonString);
        final loaded = DealershipModel.fromJson(decoded);

        // Calculate login streak
        final now = DateTime.now();
        int streak = loaded.loginStreak;
        final diffDays = now.difference(loaded.lastLoginDate).inDays;
        if (diffDays == 1) {
          streak += 1;
        } else if (diffDays > 1) {
          streak = 1;
        }

        // Filter expired offers
        final activeOffers = loaded.incomingOffers.where((o) => !o.isExpired).toList();

        // Process offline time progression
        final offlineResult = OfflineProgression.processOfflineTime(loaded.copyWith(incomingOffers: activeOffers));
        DealershipModel updated = offlineResult['updatedDealership'] as DealershipModel;
        updated = updated.copyWith(loginStreak: streak, lastLoginDate: now);

        state = updated;
        syncRentalState();
        saveState();
        return;
      } catch (e) {
        // Fallback
      }
    }

    state = DealershipModel.initial();
    saveState();
  }

  @override
  Future<void> saveState() async {
    if (!mounted) return;
    _checkAchievementsInternal();
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
    state = state.copyWith(
      skills: updatedSkills,
      level: updatedSkills.currentLevel,
    );
    saveState();
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

  /// Update player identity, gallery title and logo emblem
  void updateDealershipIdentity({
    String? playerName,
    String? dealershipName,
    String? logoEmblemId,
  }) {
    state = state.copyWith(
      playerName: playerName ?? state.playerName,
      dealershipName: dealershipName ?? state.dealershipName,
      logoEmblemId: logoEmblemId ?? state.logoEmblemId,
    );
    saveState();
  }

  /// Reset progress
  void resetGame() {
    state = DealershipModel.initial();
    saveState();
  }
}

final gameCoreProvider = StateNotifierProvider<GameCoreNotifier, DealershipModel>((ref) {
  return GameCoreNotifier();
});
