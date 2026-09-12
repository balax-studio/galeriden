import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/real_estate_category.dart';
import '../../data/models/real_estate_model.dart';
import '../../domain/usecases/real_estate_market_engine.dart';
import 'game_provider.dart';

final realEstateMarketFilterProvider =
    StateProvider<RealEstateCategory?>((ref) => null);

final realEstateMarketSearchProvider = StateProvider<String>((ref) => '');

final realEstateMarketCityProvider = StateProvider<String?>((ref) => null);

final realEstateMarketProvider = StateNotifierProvider<
    RealEstateMarketNotifier, List<RealEstateListingModel>>((ref) {
  return RealEstateMarketNotifier(ref);
});

class RealEstateMarketNotifier
    extends StateNotifier<List<RealEstateListingModel>> {
  final Ref _ref;
  Timer? _autoRefreshTimer;

  RealEstateMarketNotifier(this._ref) : super([]) {
    refreshMarket();
    _startAutoRefreshTimer();
  }

  void _startAutoRefreshTimer() {
    _autoRefreshTimer?.cancel();
    // Refresh real estate listings every 5 minutes automatically
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      refreshMarket();
    });
  }

  void refreshMarket() {
    final currentDay = _ref.read(gameProvider).currentDay;
    final categoryFilter = _ref.read(realEstateMarketFilterProvider);
    state = RealEstateMarketEngine.generateListings(
      count: 24,
      categoryFilter: categoryFilter,
      currentDay: currentDay,
    );
  }

  void setCategoryFilter(RealEstateCategory? cat) {
    _ref.read(realEstateMarketFilterProvider.notifier).state = cat;
    refreshMarket();
  }

  /// Generates and appends additional listings dynamically for infinite stream scrolling
  void loadMoreListings({int count = 6}) {
    if (state.length >= 150) return;

    final currentDay = _ref.read(gameProvider).currentDay;
    final categoryFilter = _ref.read(realEstateMarketFilterProvider);

    final newListings = RealEstateMarketEngine.generateListings(
      count: count,
      categoryFilter: categoryFilter,
      currentDay: currentDay,
    );

    final existingIds = state.map((l) => l.id).toSet();
    final uniqueNew =
        newListings.where((l) => !existingIds.contains(l.id)).toList();

    state = [...state, ...uniqueNew];
  }

  void removeListing(String listingId) {
    state = state.where((l) => l.id != listingId).toList();
  }

  /// Cancels auto refresh timer when app goes to background
  void onAppPaused() {
    _autoRefreshTimer?.cancel();
  }

  /// Restarts auto refresh timer when app returns to foreground
  void onAppResumed() {
    _startAutoRefreshTimer();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }
}
