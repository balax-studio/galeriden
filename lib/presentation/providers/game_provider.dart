import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/car_model.dart';
import '../../data/models/dealership_model.dart';
import '../../data/models/offer_model.dart';
import '../../domain/usecases/offline_progression.dart';

final gameProvider = StateNotifierProvider<GameNotifier, DealershipModel>((ref) {
  return GameNotifier();
});

class GameNotifier extends StateNotifier<DealershipModel> {
  GameNotifier() : super(DealershipModel.initial()) {
    _loadState();
  }

  static const String _storageKey = 'dealership_state_v1';

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(jsonString);
        final loaded = DealershipModel.fromJson(decoded);

        // Process offline time progression
        final offlineResult = OfflineProgression.processOfflineTime(loaded);
        state = offlineResult['updatedDealership'] as DealershipModel;
        _saveState();
        return;
      } catch (e) {
        // Fallback to initial
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

    // Check level up (every 3 cars sold)
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

    _saveState();
  }

  /// Reject an offer
  void rejectOffer(String offerId) {
    final updatedOffers = state.incomingOffers.where((o) => o.id != offerId).toList();
    state = state.copyWith(incomingOffers: updatedOffers);
    _saveState();
  }

  /// Add a new offer to incoming offers
  void addOffer(OfferModel offer) {
    state = state.copyWith(incomingOffers: [...state.incomingOffers, offer]);
    _saveState();
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
