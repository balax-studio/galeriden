import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/leaderboard_service.dart';
import '../../data/models/leaderboard_entry_model.dart';
import '../../data/models/dealership_model.dart';
import '../../domain/usecases/rival_leaderboard_engine.dart';

class LeaderboardState {
  final bool isLoading;
  final LeaderboardSortType activeTab;
  final List<LeaderboardEntryModel> wealthList;
  final List<LeaderboardEntryModel> xpList;
  final String myPlayerId;
  final int? myExactRank;
  final String? errorMessage;
  final bool isOfflineFallback;

  const LeaderboardState({
    this.isLoading = false,
    this.activeTab = LeaderboardSortType.wealth,
    this.wealthList = const [],
    this.xpList = const [],
    this.myPlayerId = '',
    this.myExactRank,
    this.errorMessage,
    this.isOfflineFallback = false,
  });

  List<LeaderboardEntryModel> get currentList =>
      activeTab == LeaderboardSortType.wealth ? wealthList : xpList;

  LeaderboardState copyWith({
    bool? isLoading,
    LeaderboardSortType? activeTab,
    List<LeaderboardEntryModel>? wealthList,
    List<LeaderboardEntryModel>? xpList,
    String? myPlayerId,
    int? myExactRank,
    String? errorMessage,
    bool? isOfflineFallback,
  }) {
    return LeaderboardState(
      isLoading: isLoading ?? this.isLoading,
      activeTab: activeTab ?? this.activeTab,
      wealthList: wealthList ?? this.wealthList,
      xpList: xpList ?? this.xpList,
      myPlayerId: myPlayerId ?? this.myPlayerId,
      myExactRank: myExactRank ?? this.myExactRank,
      errorMessage: errorMessage,
      isOfflineFallback: isOfflineFallback ?? this.isOfflineFallback,
    );
  }
}

class LeaderboardNotifier extends StateNotifier<LeaderboardState> {
  final LeaderboardService _service;

  LeaderboardNotifier(this._service) : super(const LeaderboardState()) {
    _initPlayerId();
  }

  Future<void> _initPlayerId() async {
    final id = await _service.getOrCreatePlayerId();
    state = state.copyWith(myPlayerId: id);
  }

  Future<void> loadLeaderboard({DealershipModel? game, bool forceRefresh = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final myId = await _service.getOrCreatePlayerId();
      final wealth = await _service.fetchTopByWealth(forceRefresh: forceRefresh);
      final xp = await _service.fetchTopByXp(forceRefresh: forceRefresh);

      if (wealth.isEmpty && xp.isEmpty && game != null) {
        // Safe offline fallback: populate using simulated city rivals
        final offlineList = _generateSimulatedRivalEntries(game, myId);
        state = state.copyWith(
          isLoading: false,
          wealthList: offlineList,
          xpList: offlineList,
          myPlayerId: myId,
          isOfflineFallback: true,
        );
        await updateMyExactRank(game);
        return;
      }

      state = state.copyWith(
        isLoading: false,
        wealthList: wealth,
        xpList: xp,
        myPlayerId: myId,
        isOfflineFallback: false,
      );

      if (game != null) {
        await updateMyExactRank(game);
      }
    } catch (e) {
      if (game != null) {
        final myId = state.myPlayerId.isNotEmpty ? state.myPlayerId : 'offline_player';
        final offlineList = _generateSimulatedRivalEntries(game, myId);
        state = state.copyWith(
          isLoading: false,
          wealthList: offlineList,
          xpList: offlineList,
          myPlayerId: myId,
          isOfflineFallback: true,
        );
        await updateMyExactRank(game);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'leaderboard_error_fetch',
        );
      }
    }
  }

  List<LeaderboardEntryModel> _generateSimulatedRivalEntries(DealershipModel game, String myId) {
    final rivals = RivalLeaderboardEngine.getLeaderboard(
      playerDealership: game,
      currentDay: game.currentDay,
    );
    final now = DateTime.now();

    return rivals.map((r) {
      final isMe = r.isPlayer;
      return LeaderboardEntryModel(
        playerId: isMe ? myId : (r.key.isNotEmpty ? r.key : 'npc_${r.name.hashCode}'),
        dealershipName: r.name,
        ownerName: isMe
            ? (game.playerName.isNotEmpty ? game.playerName : 'Galerici')
            : (r.tagline.isNotEmpty ? r.tagline : 'Rakip Galeri'),
        netWorth: r.turnoverScore,
        reputationXp: r.reputation,
        playerLevel: isMe ? game.level : ((r.reputation ~/ 20).clamp(1, 10)),
        carCount: r.carsSold,
        updatedAt: now,
      );
    }).toList();
  }

  void switchTab(LeaderboardSortType tab, [DealershipModel? game]) {
    if (state.activeTab == tab) return;
    state = state.copyWith(activeTab: tab);
    if (game != null) {
      updateMyExactRank(game);
    }
  }

  Future<void> updateMyExactRank(DealershipModel game) async {
    final double totalCarValue = game.ownedCars.fold(
      0.0,
      (sum, car) => sum + car.baseMarketValue,
    );
    final double netWorth = game.balance + totalCarValue;
    final myId = state.myPlayerId;

    // Check if player is already inside the loaded top 50
    final idx = state.currentList.indexWhere((e) => e.playerId == myId);
    if (idx >= 0) {
      state = state.copyWith(myExactRank: idx + 1);
      return;
    }

    // Otherwise query exact position using fast Firestore count aggregation
    final rank = await _service.fetchPlayerExactRank(
      netWorth: netWorth,
      reputationXp: game.skills.xp,
      sortType: state.activeTab,
    );
    if (rank != null) {
      state = state.copyWith(myExactRank: rank);
    }
  }

  Future<void> syncMyStats(DealershipModel game, {bool force = false}) async {
    final double totalCarValue = game.ownedCars.fold(
      0.0,
      (sum, car) => sum + car.baseMarketValue,
    );
    final double netWorth = game.balance + totalCarValue;

    await _service.syncPlayerStats(
      dealershipName: game.dealershipName,
      ownerName: game.playerName,
      netWorth: netWorth,
      reputationXp: game.skills.xp,
      playerLevel: game.level,
      carCount: game.ownedCars.length,
      force: force,
    );
  }
}

final leaderboardProvider =
    StateNotifierProvider<LeaderboardNotifier, LeaderboardState>((ref) {
  return LeaderboardNotifier(LeaderboardService.instance);
});
