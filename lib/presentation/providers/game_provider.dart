import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/car_model.dart';
import '../../data/models/dealership_model.dart';
import '../../data/models/mission_model.dart';
import '../../data/models/offer_model.dart';
import '../../data/models/player_skills.dart';
import '../../domain/usecases/market_engine.dart';
import '../../domain/usecases/negotiation_engine.dart';
import '../../domain/usecases/offline_progression.dart';
import '../../domain/usecases/psychology_engine.dart';
import '../../domain/usecases/repair_engine.dart';
import '../../domain/usecases/risk_engine.dart';

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
          streak = 1;
        }

        // Filter expired offers
        final activeOffers = loaded.incomingOffers.where((o) => !o.isExpired).toList();

        // Process offline time progression
        final offlineResult = OfflineProgression.processOfflineTime(loaded.copyWith(incomingOffers: activeOffers));
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

  /// Refresh Market Trends
  void refreshMarketTrends() {
    final newTrend = MarketEngine.generateMarketTrend();
    state = state.copyWith(marketTrend: newTrend);
    _saveState();
  }

  /// Purchase a car from market with RiskEngine check
  PurchaseRiskOutcome? buyCar(CarModel car, double purchasePrice, {bool isExpertiseCompleted = false}) {
    if (state.balance < purchasePrice) return null;
    if (state.ownedCars.length >= state.maxGarageSlots) return null;

    final updatedBalance = state.balance - purchasePrice;
    
    // Evaluate risk if expertise was not done
    PurchaseRiskOutcome outcome;
    if (!isExpertiseCompleted) {
      outcome = RiskEngine.evaluateUninspectedPurchaseRisk(car);
    } else {
      outcome = PurchaseRiskOutcome(
        isTrapped: false,
        title: 'Ekspertizli Alım',
        description: 'Ekspertiz raporu doğrultusunda güvenle satın alındı.',
        updatedCar: car,
      );
    }

    final finalCar = outcome.updatedCar.copyWith(
      currentPurchasePrice: purchasePrice,
    );

    state = state.copyWith(
      balance: updatedBalance,
      ownedCars: [...state.ownedCars, finalCar],
    );

    addXP(25);
    _checkAchievement('first_buy');
    _updateMissionProgress(MissionType.buyCars, 1);
    _saveState();
    return outcome;
  }

  /// Directly purchase a car (e.g. won from Live Auction)
  bool buyCarDirectly(CarModel car, double price) {
    if (state.balance < price) return false;
    final finalCar = car.copyWith(currentPurchasePrice: price);
    state = state.copyWith(
      balance: state.balance - price,
      ownedCars: [...state.ownedCars, finalCar],
    );
    addXP(30);
    _checkAchievement('first_buy');
    _updateMissionProgress(MissionType.buyCars, 1);
    _saveState();
    return true;
  }

  /// Expand Garage Slots / Buy Branch
  bool expandGarageSlot(int newMaxSlots, double cost) {
    if (state.balance < cost) return false;
    state = state.copyWith(
      balance: state.balance - cost,
      maxGarageSlots: newMaxSlots,
    );
    addXP(100);
    _checkAchievement('garage_expand');
    _saveState();
    return true;
  }

  /// Boost Listing Doping (₺2.500) to instantly bring 2 buyer offers
  bool boostListingDoping(String carId) {
    const cost = 2500.0;
    if (state.balance < cost) return false;

    final car = state.ownedCars.firstWhere((c) => c.id == carId, orElse: () => throw Exception('Car not found'));
    
    // Generate 2 immediate high-value offers
    final newOffer1 = NegotiationEngine.generateBuyerOffer(car, car.estimatedRealValue * 1.1);
    final newOffer2 = NegotiationEngine.generateBuyerOffer(car, car.estimatedRealValue * 1.1);

    state = state.copyWith(
      balance: state.balance - cost,
      incomingOffers: [...state.incomingOffers, newOffer1, newOffer2],
    );

    addXP(15);
    _saveState();
    return true;
  }

  /// Perform detailing & pasta cila (+8% value boost & shine badge)
  bool detailCleanCar(String carId) {
    const cost = RepairEngine.detailedCleanCost; // 2500 TL
    if (state.balance < cost) return false;

    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    if (car.isDetailedCleaned) return false; // Already cleaned guard!

    final updatedCar = RepairEngine.performDetailing(car);
    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    state = state.copyWith(
      balance: state.balance - cost,
      ownedCars: updatedCars,
    );

    addXP(20);
    if (updatedCar.expertise.engineCondition == 100.0 && updatedCar.isDetailedCleaned) {
      _checkAchievement('restoration_king');
    }
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
    _updateMissionProgress(MissionType.repairParts, 1);
    if (updatedCar.expertise.engineCondition == 100.0 && updatedCar.isDetailedCleaned) {
      _checkAchievement('restoration_king');
    }
    _saveState();
  }

  /// Repair body part with Craftsman Tier
  RepairResult repairBodyPartWithTier(CarModel car, String partName, RepairTier tier) {
    final result = RepairEngine.repairBodyPart(car, partName, tier);
    if (state.balance >= result.costPaid) {
      final updatedCars = state.ownedCars.map((c) => c.id == car.id ? result.updatedCar : c).toList();
      state = state.copyWith(
        balance: state.balance - result.costPaid,
        ownedCars: updatedCars,
      );
      if (result.isSuccess) {
        addXP(20);
        _updateMissionProgress(MissionType.repairParts, 1);
      }
      _saveState();
    }
    return result;
  }

  /// Repair Engine with Craftsman Tier
  RepairResult repairEngineWithTier(CarModel car, RepairTier tier) {
    final result = RepairEngine.repairEngine(car, tier);
    if (state.balance >= result.costPaid) {
      final updatedCars = state.ownedCars.map((c) => c.id == car.id ? result.updatedCar : c).toList();
      state = state.copyWith(
        balance: state.balance - result.costPaid,
        ownedCars: updatedCars,
      );
      if (result.isSuccess) {
        addXP(30);
        _updateMissionProgress(MissionType.repairParts, 1);
      }
      _saveState();
    }
    return result;
  }

  /// Submit counter-offer to buyer
  NegotiationOutcome counterOffer(String offerId, double playerTargetPrice) {
    final offerIndex = state.incomingOffers.indexWhere((o) => o.id == offerId);
    if (offerIndex == -1) {
      throw Exception('Teklif bulunamadı');
    }

    final offer = state.incomingOffers[offerIndex];
    final carIndex = state.ownedCars.indexWhere((c) => c.id == offer.carId);
    if (carIndex == -1) {
      throw Exception('Araç bulunamadı');
    }

    final car = state.ownedCars[carIndex];
    final outcome = NegotiationEngine.evaluateCounterOffer(
      currentOffer: offer,
      playerTargetPrice: playerTargetPrice,
      car: car,
      negotiationSkillLevel: state.skills.negotiationLevel,
    );

    List<OfferModel> updatedOffers = List.from(state.incomingOffers);
    if (outcome.isWalkaway) {
      updatedOffers.removeAt(offerIndex);
    } else {
      updatedOffers[offerIndex] = outcome.updatedOffer;
    }

    state = state.copyWith(incomingOffers: updatedOffers);
    _saveState();
    return outcome;
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
    _updateMissionProgress(MissionType.sellCars, 1);
    if (profit > 0) {
      _updateMissionProgress(MissionType.earnProfit, profit.round());
    }
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

  /// Complete & Claim Mission Reward
  bool claimMissionReward(String missionId) {
    final missionIndex = state.activeMissions.indexWhere((m) => m.id == missionId);
    if (missionIndex == -1) return false;

    final mission = state.activeMissions[missionIndex];
    if (mission.currentProgress < mission.targetGoal || mission.isCompleted) return false;

    final updatedMission = mission.copyWith(isCompleted: true);
    final updatedMissions = List<MissionModel>.from(state.activeMissions);
    updatedMissions[missionIndex] = updatedMission;

    state = state.copyWith(
      balance: state.balance + mission.rewardMoney,
      activeMissions: updatedMissions,
    );

    addXP(mission.rewardXP);
    _saveState();
    return true;
  }

  void _updateMissionProgress(MissionType type, int amount) {
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
