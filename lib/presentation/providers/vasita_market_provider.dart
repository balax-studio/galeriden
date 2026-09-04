import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/listing_model.dart';
import '../../data/models/vehicle_category.dart';
import '../../domain/usecases/vasita_market_engine.dart';
import 'game_provider.dart';

final vasitaMarketFilterProvider =
    StateProvider<VehicleCategory?>((ref) => null);

final vasitaMarketSearchProvider = StateProvider<String>((ref) => '');

final vasitaMarketProvider =
    StateNotifierProvider<VasitaMarketNotifier, List<ListingModel>>((ref) {
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

  void refreshMarket() {
    final playerLevel = _ref.read(gameProvider).level;
    final categoryFilter = _ref.read(vasitaMarketFilterProvider);
    state = VasitaMarketEngine.generateListings(
      count: 24,
      categoryFilter: categoryFilter,
      playerLevel: playerLevel,
    );
  }

  void setCategoryFilter(VehicleCategory? cat) {
    _ref.read(vasitaMarketFilterProvider.notifier).state = cat;
    refreshMarket();
  }

  bool buyVasita(ListingModel listing) {
    final gameNotifier = _ref.read(gameProvider.notifier);
    final outcome = gameNotifier.buyCar(
      listing.car,
      listing.askingPrice,
      isExpertiseCompleted: listing.isExpertiseCompleted,
    );

    if (outcome != null) {
      // Successfully bought: remove from active listings
      state = state.where((l) => l.id != listing.id).toList();
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }
}
