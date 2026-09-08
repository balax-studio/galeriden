import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/leaderboard_entry_model.dart';
import 'package:galeriden/presentation/providers/leaderboard_provider.dart';
import 'package:galeriden/core/services/leaderboard_service.dart';

void main() {
  group('LeaderboardEntryModel Tests', () {
    test('LeaderboardEntryModel serializes and deserializes accurately', () {
      final now = DateTime.now();
      final entry = LeaderboardEntryModel(
        playerId: 'test_player_123',
        dealershipName: 'Yıldız Otomotiv',
        ownerName: 'Yaşar Usta',
        netWorth: 4500000.0,
        reputationXp: 1250,
        playerLevel: 14,
        carCount: 8,
        updatedAt: now,
      );

      final map = entry.toMap();
      expect(map['playerId'], 'test_player_123');
      expect(map['dealershipName'], 'Yıldız Otomotiv');
      expect(map['ownerName'], 'Yaşar Usta');
      expect(map['netWorth'], 4500000.0);
      expect(map['reputationXp'], 1250);
      expect(map['playerLevel'], 14);
      expect(map['carCount'], 8);

      final deserialized = LeaderboardEntryModel.fromMap(map, docId: 'test_player_123');
      expect(deserialized.playerId, 'test_player_123');
      expect(deserialized.dealershipName, 'Yıldız Otomotiv');
      expect(deserialized.ownerName, 'Yaşar Usta');
      expect(deserialized.netWorth, 4500000.0);
      expect(deserialized.reputationXp, 1250);
      expect(deserialized.playerLevel, 14);
      expect(deserialized.carCount, 8);
    });

    test('LeaderboardEntryModel handles empty or missing map keys gracefully', () {
      final fallback = LeaderboardEntryModel.fromMap({}, docId: 'doc_fallback_id');
      expect(fallback.playerId, 'doc_fallback_id');
      expect(fallback.dealershipName, 'Bilinmeyen Galeri');
      expect(fallback.ownerName, 'Galerici');
      expect(fallback.netWorth, 0.0);
      expect(fallback.reputationXp, 0);
      expect(fallback.playerLevel, 1);
      expect(fallback.carCount, 0);
    });

    test('LeaderboardEntryModel copyWith works immutably', () {
      final entry = LeaderboardEntryModel(
        playerId: 'p1',
        dealershipName: 'Galeri A',
        ownerName: 'Ali',
        netWorth: 100000,
        reputationXp: 50,
        playerLevel: 2,
        carCount: 1,
        updatedAt: DateTime.now(),
      );

      final updated = entry.copyWith(
        netWorth: 200000,
        reputationXp: 100,
      );

      expect(updated.playerId, 'p1');
      expect(updated.netWorth, 200000);
      expect(updated.reputationXp, 100);
      expect(entry.netWorth, 100000);
    });
  });

  group('LeaderboardState Tests', () {
    test('LeaderboardState toggles between wealth and xp list correctly', () {
      final entryWealth = LeaderboardEntryModel(
        playerId: 'w1',
        dealershipName: 'Zengin Oto',
        ownerName: 'Ahmet',
        netWorth: 9999999,
        reputationXp: 10,
        playerLevel: 3,
        carCount: 15,
        updatedAt: DateTime.now(),
      );

      final entryXp = LeaderboardEntryModel(
        playerId: 'x1',
        dealershipName: 'İtibarlı Oto',
        ownerName: 'Mehmet',
        netWorth: 50000,
        reputationXp: 9999,
        playerLevel: 50,
        carCount: 2,
        updatedAt: DateTime.now(),
      );

      final state = LeaderboardState(
        wealthList: [entryWealth],
        xpList: [entryXp],
        activeTab: LeaderboardSortType.wealth,
      );

      expect(state.currentList.first.dealershipName, 'Zengin Oto');

      final switchedState = state.copyWith(activeTab: LeaderboardSortType.reputation);
      expect(switchedState.currentList.first.dealershipName, 'İtibarlı Oto');
    });

    test('LeaderboardState stores and updates myExactRank correctly', () {
      const state = LeaderboardState(myExactRank: 142);
      expect(state.myExactRank, 142);

      final updated = state.copyWith(myExactRank: 48);
      expect(updated.myExactRank, 48);
    });
  });
}
