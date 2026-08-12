import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/listing_model.dart';
import '../../domain/usecases/market_engine.dart';
import 'game_provider.dart';

final marketProvider = StateNotifierProvider<MarketNotifier, List<ListingModel>>((ref) {
  final playerLevel = ref.watch(gameProvider.select((s) => s.level));
  return MarketNotifier(playerLevel);
});

class MarketNotifier extends StateNotifier<List<ListingModel>> {
  final int playerLevel;

  MarketNotifier(this.playerLevel) : super([]) {
    refreshMarket();
  }

  void refreshMarket() {
    state = MarketEngine.generateRandomListings(count: 7, playerLevel: playerLevel);
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
}
