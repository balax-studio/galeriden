import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/car_model.dart';
import '../../data/models/dealership_model.dart';
import '../../data/models/offer_model.dart';
import '../../data/models/player_skills.dart';
import '../../domain/usecases/offline_progression.dart';
import '../../domain/usecases/psychology_engine.dart';

final gameProvider = StateNotifierProvider<GameNotifier, DealershipModel>((ref) {
  return GameNotifier();
});

class GameNotifier extends StateNotifier<DealershipModel> {
  GameNotifier() : super(DealershipModel.initial()) {
    _loadState();
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
          streak = 1; // reset streak if missed a day
        }

        // Process offline time progression
        final offlineResult = OfflineProgression.processOfflineTime(loaded);
        DealershipModel updated = offlineResult['updatedDealership'] as DealershipModel;
        updated = updated.copyWith(loginStreak: streak, lastLoginDate: now);

        state = updated;
        _saveState();
        return;
      } catch (e) {
        // Fallback
      }
    }

    state = DealershipModel.initial();
    _saveState();
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(state.toJson());
    await prefs.setString(_storageKey, jsonString);
  }

  /// Claim daily login streak reward
  int claimDailyStreak() {
    final reward = PsychologyEngine.getStreakReward(state.loginStreak);
    state = state.copyWith(
      balance: state.balance + reward,
      lastLoginDate: DateTime.now(),
    );
    addXP(50);
    _saveState();
    return reward;
  }

  /// Purchase a car from market
  bool buyCar(CarModel car, double purchasePrice) {
    if (state.balance < purchasePrice) return false;
    if (state.ownedCars.length >= state.maxGarageSlots) return false;

    final updatedBalance = state.balance - purchasePrice;
    final updatedCar = CarModel(
      id: car.id,
      brand: car.brand,
      modelName: car.modelName,
      modelYear: car.modelYear,
      bodyType: car.bodyType,
      colorHex: car.colorHex,
      baseMarketValue: car.baseMarketValue,
      currentPurchasePrice: purchasePrice,
      expertise: car.expertise,
    );

    state = state.copyWith(
      balance: updatedBalance,
      ownedCars: [...state.ownedCars, updatedCar],
    );

    addXP(25);
    _checkAchievement('first_buy');
    _saveState();
    return true;
  }

  /// Update owned car after repair or detailing
  void updateOwnedCar(CarModel updatedCar, double cost) {
    if (state.balance < cost) return;

    final cars = state.ownedCars.map((c) {
      return c.id == updatedCar.id ? updatedCar : c;
    }).toList();

    state = state.copyWith(
      balance: state.balance - cost,
      ownedCars: cars,
    );

    addXP(15);
    if (updatedCar.expertise.engineCondition == 100.0 && updatedCar.isDetailedCleaned) {
      _checkAchievement('restoration_king');
    }
    _saveState();
  }

  /// Accept an offer and sell car
  void acceptOffer(OfferModel offer) {
    final carIndex = state.ownedCars.indexWhere((c) => c.id == offer.carId);
    if (carIndex == -1) return;

    final car = state.ownedCars[carIndex];
    final profit = offer.offeredAmount - car.currentPurchasePrice;

    final updatedCars = state.ownedCars.where((c) => c.id != car.id).toList();
    final updatedOffers = state.incomingOffers.where((o) => o.id != offer.id).toList();

    int newCarsSold = state.carsSold + 1;
    int newLevel = state.level;
    int newSlots = state.maxGarageSlots;

    if (newCarsSold % 3 == 0) {
      newLevel += 1;
      newSlots += 1;
    }

    state = state.copyWith(
      balance: state.balance + offer.offeredAmount,
      ownedCars: updatedCars,
      incomingOffers: updatedOffers,
      totalProfit: state.totalProfit + profit,
      carsSold: newCarsSold,
      level: newLevel,
      maxGarageSlots: newSlots,
    );

    addXP(100 + (profit > 0 ? (profit / 1000).round() : 0));
    _checkAchievement('first_sale');
    if (state.totalProfit >= 250000) _checkAchievement('dealer_baron');

    _saveState();
  }

  /// Reject an offer
  void rejectOffer(String offerId) {
    final updatedOffers = state.incomingOffers.where((o) => o.id != offerId).toList();
    state = state.copyWith(incomingOffers: updatedOffers);
    _saveState();
  }

  /// Add a new offer
  void addOffer(OfferModel offer) {
    state = state.copyWith(incomingOffers: [...state.incomingOffers, offer]);
    _saveState();
  }

  /// Upgrade player skill
  bool upgradeSkill(String skillName) {
    final skills = state.skills;
    if (skills.availableSkillPoints <= 0) return false;

    PlayerSkills updated;
    switch (skillName) {
      case 'negotiation':
        if (skills.negotiationLevel >= 10) return false;
        updated = skills.copyWith(negotiationLevel: skills.negotiationLevel + 1);
        break;
      case 'eyeForDetail':
        if (skills.eyeForDetail >= 10) return false;
        updated = skills.copyWith(eyeForDetail: skills.eyeForDetail + 1);
        break;
      case 'marketSense':
        if (skills.marketSense >= 10) return false;
        updated = skills.copyWith(marketSense: skills.marketSense + 1);
        break;
      case 'reputation':
        if (skills.reputation >= 10) return false;
        updated = skills.copyWith(reputation: skills.reputation + 1);
        break;
      default:
        return false;
    }

    state = state.copyWith(skills: updated);
    _saveState();
    return true;
  }

  /// Add XP
  void addXP(int amount) {
    final updatedSkills = state.skills.copyWith(xp: state.skills.xp + amount);
    state = state.copyWith(skills: updatedSkills);
  }

  /// Check & unlock achievement
  void _checkAchievement(String id) {
    final list = state.achievements.map((a) {
      if (a.id == id && !a.isUnlocked) {
        return a.copyWith(isUnlocked: true);
      }
      return a;
    }).toList();

    state = state.copyWith(achievements: list);
  }

  /// Add rewarded ad balance boost
  void claimAdReward(double rewardAmount) {
    state = state.copyWith(balance: state.balance + rewardAmount);
    _saveState();
  }

  /// Reset progress
  void resetGame() {
    state = DealershipModel.initial();
    _saveState();
  }
}
