import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/listing_model.dart';
import '../../data/models/vehicle_category.dart';
import '../../domain/usecases/vasita_market_engine.dart';
import 'game_provider.dart';

final vasitaMarketFilterProvider =
    StateProvider<VehicleCategory?>((ref) => null);

final vasitaMarketSearchProvider = StateProvider<String>((ref) => '');

final vasitaLockedListingsProvider = StateProvider<Set<String>>((ref) => {});

final vasitaMarketRefreshCooldownProvider =
    StateNotifierProvider<VasitaMarketCooldownNotifier, int>((ref) {
  return VasitaMarketCooldownNotifier();
});

class VasitaMarketCooldownNotifier extends StateNotifier<int> {
  Timer? _timer;

  VasitaMarketCooldownNotifier() : super(0);

  void startCooldown([int seconds = 45]) {
    _timer?.cancel();
    state = seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (state <= 1) {
        state = 0;
        t.cancel();
      } else {
        state = state - 1;
      }
    });
  }

  void resetCooldown() {
    _timer?.cancel();
    state = 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final vasitaMarketProvider =
    StateNotifierProvider<VasitaMarketNotifier, List<ListingModel>>((ref) {
  ref.listen<int>(gameProvider.select((g) => g.currentDay), (previous, next) {
    if (previous != null && next != previous) {
      ref.read(vasitaLockedListingsProvider.notifier).state = {};
      ref.read(vasitaMarketRefreshCooldownProvider.notifier).resetCooldown();
    }
  });
  return VasitaMarketNotifier(ref);
});

class VasitaMarketNotifier extends StateNotifier<List<ListingModel>> {
  final Ref _ref;
  Timer? _autoRefreshTimer;

  VasitaMarketNotifier(this._ref) : super([]) {
    refreshMarket();
    _startAutoRefreshTimer();
  }

  void _startAutoRefreshTimer() {
    _autoRefreshTimer?.cancel();
    // Refresh market listings every 4 minutes automatically
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 4), (_) {
      refreshMarket();
    });
  }

  void refreshMarket({bool triggerCooldown = false}) {
    final game = _ref.read(gameProvider);
    final playerLevel = game.level;
    final categoryFilter = _ref.read(vasitaMarketFilterProvider);

    if (triggerCooldown && !game.hasNoAdsLicense) {
      _ref.read(vasitaMarketRefreshCooldownProvider.notifier).startCooldown(45);
    }

    state = VasitaMarketEngine.generateListings(
      count: 24,
      categoryFilter: categoryFilter,
      playerLevel: playerLevel,
      playerBalance: game.balance,
    );
    // Prune locked listings so vanished listing IDs don't leak memory
    Future.microtask(() {
      if (!mounted) return;
      final activeIds = state.map((l) => l.id).toSet();
      _ref.read(vasitaLockedListingsProvider.notifier).update(
            (current) => current.intersection(activeIds),
          );
    });
  }

  void clearLockedListings() {
    _ref.read(vasitaLockedListingsProvider.notifier).state = {};
  }

  void setCategoryFilter(VehicleCategory? cat) {
    _ref.read(vasitaMarketFilterProvider.notifier).state = cat;
    refreshMarket();
  }

  bool buyVasitaNegotiated({
    required ListingModel listing,
    required double agreedPrice,
    required double noterFee,
    double registrationFee = 850.0,
  }) {
    final gameNotifier = _ref.read(gameProvider.notifier);
    final outcome = gameNotifier.buyCarWithNoter(
      car: listing.car,
      agreedPrice: agreedPrice,
      noterFee: noterFee,
      registrationFee: registrationFee,
      isExpertiseCompleted: listing.isExpertiseCompleted,
    );

    if (outcome != null) {
      state = state.where((l) => l.id != listing.id).toList();
      return true;
    }
    return false;
  }

  bool performDetailedExpertise(String listingId, {double cost = 3500.0}) {
    final gameNotifier = _ref.read(gameProvider.notifier);
    final success = gameNotifier.performMarketExpertise(cost);
    if (success) {
      state = state.map((l) {
        if (l.id == listingId) {
          return l.copyWith(isExpertiseCompleted: true);
        }
        return l;
      }).toList();
      return true;
    }
    return false;
  }

  /// Generates and appends additional listings dynamically for infinite stream scrolling
  void loadMoreListings({int count = 6}) {
    if (state.length >= 150) return;

    final game = _ref.read(gameProvider);
    final playerLevel = game.level;
    final categoryFilter = _ref.read(vasitaMarketFilterProvider);

    final newListings = VasitaMarketEngine.generateListings(
      count: count,
      categoryFilter: categoryFilter,
      playerLevel: playerLevel,
    );

    final existingIds = state.map((l) => l.id).toSet();
    final uniqueNew =
        newListings.where((l) => !existingIds.contains(l.id)).toList();

    state = [...state, ...uniqueNew];
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
