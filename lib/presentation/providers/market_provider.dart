import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/listing_model.dart';
import '../../domain/usecases/market_engine.dart';
import 'game_provider.dart';

final marketProvider =
    StateNotifierProvider<MarketNotifier, List<ListingModel>>((ref) {
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
    final game = _ref.read(gameProvider);
    final trend = game.marketTrend;
    final balance = game.balance;
    final hasNecati = game.hasHighNpcTrust('necati');
    state = MarketEngine.generateRandomListings(
      playerLevel: playerLevel,
      trend: trend,
      playerBalance: balance,
      hasHighNecatiTrust: hasNecati,
    );
  }

  void refreshListings() => refreshMarket();

  /// Partially refresh market (some cars get sold, new ones appear with organic pool fluctuation)
  void partialRefresh() {
    if (state.isEmpty) {
      refreshMarket();
      return;
    }

    final game = _ref.read(gameProvider);
    final trend = game.marketTrend;
    final balance = game.balance;
    final hasNecati = game.hasHighNpcTrust('necati');
    final targetCount = MarketEngine.calculateDynamicListingCount(
      playerLevel: playerLevel,
      trend: trend,
      randomOverride: _random,
    );

    var current = List<ListingModel>.from(state);

    // Remove 1-3 random listings
    int removeCount = 1 + _random.nextInt(min(3, current.length));
    for (int i = 0; i < removeCount && current.isNotEmpty; i++) {
      current.removeAt(_random.nextInt(current.length));
    }

    // Add dynamic number of listings to naturally expand/contract pool toward targetCount
    int addCount = (targetCount - current.length).clamp(1, 10);
    if (current.length + addCount < 20) {
      addCount = 20 - current.length;
    }

    final newListings = MarketEngine.generateRandomListings(
      count: addCount,
      playerLevel: playerLevel,
      trend: trend,
      playerBalance: balance,
      hasHighNecatiTrust: hasNecati,
    );

    final updatedList = [...current, ...newListings];
    // Keep within safe operational bounds (20-70)
    state = updatedList.take(70).toList();
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
