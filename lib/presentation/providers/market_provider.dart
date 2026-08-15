import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/listing_model.dart';
import '../../domain/usecases/market_engine.dart';
import 'game_provider.dart';

final marketProvider = StateNotifierProvider<MarketNotifier, List<ListingModel>>((ref) {
  return MarketNotifier(ref);
});

class MarketNotifier extends StateNotifier<List<ListingModel>> {
  final Ref _ref;
  Timer? _autoRefreshTimer;
  final Random _random = Random();

  MarketNotifier(this._ref) : super([]) {
    refreshMarket();
    _startAutoRefreshTimer();
  }

  int get playerLevel => _ref.read(gameProvider).level;

  void _startAutoRefreshTimer() {
    _autoRefreshTimer?.cancel();
    // Auto refresh every random 3-5 minutes partially
    final minutes = 3 + _random.nextInt(3);
    _autoRefreshTimer = Timer.periodic(Duration(minutes: minutes), (_) {
      partialRefresh();
    });
  }

  /// Cancels auto refresh timer when app goes to background
  void onAppPaused() {
    _autoRefreshTimer?.cancel();
  }

  /// Restarts auto refresh timer when app returns to foreground
  void onAppResumed() {
    _startAutoRefreshTimer();
  }

  void refreshMarket() {
    state = MarketEngine.generateRandomListings(count: 7, playerLevel: playerLevel);
  }

  void refreshListings() => refreshMarket();

  /// Partially refresh market (some cars get sold, new ones appear)
  void partialRefresh() {
    if (state.isEmpty) {
      refreshMarket();
      return;
    }
    // Remove 1-2 random listings and add 1-2 new ones
    var current = List<ListingModel>.from(state);
    int removeCount = 1 + _random.nextInt(2);
    for (int i = 0; i < removeCount && current.isNotEmpty; i++) {
      current.removeAt(_random.nextInt(current.length));
    }

    final newListings = MarketEngine.generateRandomListings(count: removeCount, playerLevel: playerLevel);
    state = [...current, ...newListings];
  }

  void markExpertiseCompleted(String listingId) {
    state = state.map((l) {
      if (l.id == listingId) {
        return l.copyWith(isExpertiseCompleted: true);
      }
      return l;
    }).toList();
  }

  void removeListing(String listingId) {
    state = state.where((l) => l.id != listingId).toList();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }
}
