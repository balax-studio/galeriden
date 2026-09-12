import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/car_model.dart';
import '../../data/models/outsourced_tuning_model.dart';
import '../../domain/usecases/outsourced_tuning_engine.dart';
import 'game_provider.dart';

class OutsourcedTuningState {
  final List<TuningOrder> activeOrders;
  final List<StudioDeal> dailyDeals;
  final int lastDealDay;
  final bool isLoading;

  const OutsourcedTuningState({
    this.activeOrders = const [],
    this.dailyDeals = const [],
    this.lastDealDay = 0,
    this.isLoading = false,
  });

  TuningOrder? getActiveOrderForCar(String carId) {
    for (final order in activeOrders) {
      if (order.carId == carId && order.status != TuningOrderStatus.completed) {
        return order;
      }
    }
    return null;
  }

  OutsourcedTuningState copyWith({
    List<TuningOrder>? activeOrders,
    List<StudioDeal>? dailyDeals,
    int? lastDealDay,
    bool? isLoading,
  }) {
    return OutsourcedTuningState(
      activeOrders: activeOrders ?? this.activeOrders,
      dailyDeals: dailyDeals ?? this.dailyDeals,
      lastDealDay: lastDealDay ?? this.lastDealDay,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class OutsourcedTuningNotifier extends StateNotifier<OutsourcedTuningState> {
  final Ref ref;
  Timer? _tickerTimer;
  static const String _storageKey = 'outsourced_tuning_orders_v1';

  OutsourcedTuningNotifier(this.ref) : super(const OutsourcedTuningState()) {
    _loadFromPrefs();
    _startTicker();
  }

  void _startTicker() {
    _tickerTimer?.cancel();
    _tickerTimer = null;
    if (!state.activeOrders.any((o) => o.status == TuningOrderStatus.inProgress)) {
      return;
    }
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!state.activeOrders.any((o) => o.status == TuningOrderStatus.inProgress)) {
        timer.cancel();
        _tickerTimer = null;
        return;
      }

      bool hasStatusChange = false;
      final updatedOrders = state.activeOrders.map((order) {
        if (order.status == TuningOrderStatus.inProgress && order.isTimerExpired) {
          hasStatusChange = true;
          return order.copyWith(status: TuningOrderStatus.readyForPickup);
        }
        return order;
      }).toList();

      state = state.copyWith(activeOrders: updatedOrders);
      if (hasStatusChange) {
        _saveToPrefs();
        if (!updatedOrders.any((o) => o.status == TuningOrderStatus.inProgress)) {
          timer.cancel();
          _tickerTimer = null;
        }
      }
    });
  }

  /// Pauses periodic timer when app is paused
  void onAppPaused() {
    _tickerTimer?.cancel();
    _tickerTimer = null;
  }

  /// Resumes periodic timer when app is foregrounded
  void onAppResumed() {
    _startTicker();
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    _tickerTimer = null;
    super.dispose();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawData = prefs.getString(_storageKey);
      if (rawData != null && rawData.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(rawData) as List<dynamic>;
        final orders = jsonList
            .map((item) => TuningOrder.fromJson(item as Map<String, dynamic>))
            .where((o) => o.status != TuningOrderStatus.completed)
            .toList();

        state = state.copyWith(activeOrders: orders);
        _startTicker();
      }
    } catch (_) {
      // Graceful fallback on corrupt prefs
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = state.activeOrders.map((o) => o.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  /// Create and submit an order to an outsourced tuning studio
  TuningOrder? submitOrder({
    required CarModel car,
    required OutsourcedTuningStudio studio,
    int discountPercent = 0,
  }) {
    final gameState = ref.read(gameProvider);
    final cost = OutsourcedTuningEngine.calculateCost(
      studio,
      car,
      discountPercent: discountPercent,
    );

    if (gameState.balance < cost) {
      return null;
    }

    // Deduct cash from player
    ref.read(gameProvider.notifier).deductBalance(cost);

    // Create the order
    final order = OutsourcedTuningEngine.createOrder(
      studio: studio,
      car: car,
      currentDay: gameState.currentDay,
      discountPercent: discountPercent,
    );

    // Update car in inventory to be locked in tuning
    final updatedCar = car.copyWith(
      isOutsourcedTuning: true,
      activeTuningOrderId: order.orderId,
      customListingPrice: null,
      clearListingPrice: true,
    );
    ref.read(gameProvider.notifier).updateCar(updatedCar);

    // Append order to state
    final updatedOrders = List<TuningOrder>.from(state.activeOrders)..add(order);
    state = state.copyWith(activeOrders: updatedOrders);
    _startTicker();
    _saveToPrefs();

    return order;
  }

  /// Speedup active tuning project by watching a rewarded ad (-50% remaining time)
  bool speedupOrderWithAd(String orderId) {
    final index = state.activeOrders.indexWhere((o) => o.orderId == orderId);
    if (index == -1) return false;

    final existing = state.activeOrders[index];
    if (existing.speedupCount >= 2 || !existing.status.name.contains('inProgress')) {
      return false;
    }

    final spedUp = OutsourcedTuningEngine.applySpeedup(existing);
    final updatedOrders = List<TuningOrder>.from(state.activeOrders);
    updatedOrders[index] = spedUp;

    state = state.copyWith(activeOrders: updatedOrders);
    _saveToPrefs();
    return true;
  }

  /// Claim finished car from studio and return to garage with power & value boost
  CarModel? claimCompletedOrder(String orderId) {
    final index = state.activeOrders.indexWhere((o) => o.orderId == orderId);
    if (index == -1) return null;

    final order = state.activeOrders[index];
    if (!order.isReadyForPickup) return null;

    final studio = OutsourcedTuningEngine.getStudioById(order.studioId);
    if (studio == null) return null;

    final gameState = ref.read(gameProvider);
    CarModel? car;
    for (final c in gameState.ownedCars) {
      if (c.id == order.carId) {
        car = c;
        break;
      }
    }
    if (car == null) return null;

    // Apply upgrades to car
    final tunedCar = OutsourcedTuningEngine.applyCompletedTuning(
      car: car,
      order: order,
      studio: studio,
    );

    // Update car in gameProvider
    ref.read(gameProvider.notifier).updateCar(tunedCar);

    // Remove finished order from active orders
    final updatedOrders = List<TuningOrder>.from(state.activeOrders)..removeAt(index);
    state = state.copyWith(activeOrders: updatedOrders);
    _saveToPrefs();

    return tunedCar;
  }

  /// Hook called when in-game day advances to speed up pending orders
  void onDayAdvanced(int currentDay) {
    if (state.activeOrders.isEmpty) return;

    final advancedOrders = state.activeOrders.map((order) {
      return OutsourcedTuningEngine.advanceDayForOrder(order);
    }).toList();

    state = state.copyWith(activeOrders: advancedOrders);
    _saveToPrefs();
  }
}

final outsourcedTuningProvider =
    StateNotifierProvider<OutsourcedTuningNotifier, OutsourcedTuningState>((ref) {
  return OutsourcedTuningNotifier(ref);
});
