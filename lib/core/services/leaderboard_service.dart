import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/leaderboard_entry_model.dart';

enum LeaderboardSortType { wealth, reputation }

/// Service managing Firestore Leaderboard with memory caching and write throttling.
class LeaderboardService {
  static final LeaderboardService instance = LeaderboardService._internal();
  LeaderboardService._internal();

  static const String _collectionName = 'leaderboards';
  static const String _prefPlayerIdKey = 'leaderboard_anonymous_player_id';
  static const Duration _cacheDuration = Duration(minutes: 10);
  static const Duration _writeThrottleDuration = Duration(minutes: 6);

  String? _cachedPlayerId;
  DateTime? _lastSyncAt;

  List<LeaderboardEntryModel>? _cachedWealthLeaderboard;
  DateTime? _wealthCacheTimestamp;

  List<LeaderboardEntryModel>? _cachedXpLeaderboard;
  DateTime? _xpCacheTimestamp;

  /// Retrieves or generates a persistent anonymous player ID.
  Future<String> getOrCreatePlayerId() async {
    if (_cachedPlayerId != null && _cachedPlayerId!.isNotEmpty) {
      return _cachedPlayerId!;
    }
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString(_prefPlayerIdKey);
    if (id == null || id.isEmpty) {
      final random = Random();
      id = 'galerici_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(8999) + 1000}';
      await prefs.setString(_prefPlayerIdKey, id);
    }
    _cachedPlayerId = id;
    return id;
  }

  /// Syncs player's current net worth and XP to Firestore if throttle window elapsed.
  Future<bool> syncPlayerStats({
    required String dealershipName,
    required String ownerName,
    required double netWorth,
    required int reputationXp,
    required int playerLevel,
    required int carCount,
    bool force = false,
  }) async {
    final now = DateTime.now();

    if (!force && _lastSyncAt != null && now.difference(_lastSyncAt!) < _writeThrottleDuration) {
      return false;
    }

    try {
      final playerId = await getOrCreatePlayerId();
      final entry = LeaderboardEntryModel(
        playerId: playerId,
        dealershipName: dealershipName.trim().isEmpty ? 'Bilinmeyen Galeri' : dealershipName,
        ownerName: ownerName.trim().isEmpty ? 'Galerici' : ownerName,
        netWorth: netWorth,
        reputationXp: reputationXp,
        playerLevel: playerLevel,
        carCount: carCount,
        updatedAt: now,
      );

      await FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(playerId)
          .set(entry.toMap(), SetOptions(merge: true));

      _lastSyncAt = now;
      return true;
    } catch (e) {
      debugPrint('[LeaderboardService] syncPlayerStats error: $e');
      return false;
    }
  }

  /// Fetches top 50 players by total net worth with in-memory caching.
  Future<List<LeaderboardEntryModel>> fetchTopByWealth({bool forceRefresh = false}) async {
    final now = DateTime.now();

    if (!forceRefresh &&
        _cachedWealthLeaderboard != null &&
        _wealthCacheTimestamp != null &&
        now.difference(_wealthCacheTimestamp!) < _cacheDuration) {
      return _cachedWealthLeaderboard!;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(_collectionName)
          .orderBy('netWorth', descending: true)
          .limit(50)
          .get();

      final list = snapshot.docs.map((d) {
        return LeaderboardEntryModel.fromMap(d.data(), docId: d.id);
      }).toList();

      _cachedWealthLeaderboard = list;
      _wealthCacheTimestamp = now;
      return list;
    } catch (e) {
      debugPrint('[LeaderboardService] fetchTopByWealth error: $e');
      return _cachedWealthLeaderboard ?? [];
    }
  }

  /// Fetches top 50 players by reputation XP with in-memory caching.
  Future<List<LeaderboardEntryModel>> fetchTopByXp({bool forceRefresh = false}) async {
    final now = DateTime.now();

    if (!forceRefresh &&
        _cachedXpLeaderboard != null &&
        _xpCacheTimestamp != null &&
        now.difference(_xpCacheTimestamp!) < _cacheDuration) {
      return _cachedXpLeaderboard!;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(_collectionName)
          .orderBy('reputationXp', descending: true)
          .limit(50)
          .get();

      final list = snapshot.docs.map((d) {
        return LeaderboardEntryModel.fromMap(d.data(), docId: d.id);
      }).toList();

      _cachedXpLeaderboard = list;
      _xpCacheTimestamp = now;
      return list;
    } catch (e) {
      debugPrint('[LeaderboardService] fetchTopByXp error: $e');
      return _cachedXpLeaderboard ?? [];
    }
  }

  /// Calculates player's exact rank across the entire database via Firestore count aggregation.
  Future<int?> fetchPlayerExactRank({
    required double netWorth,
    required int reputationXp,
    required LeaderboardSortType sortType,
  }) async {
    try {
      final field = sortType == LeaderboardSortType.wealth ? 'netWorth' : 'reputationXp';
      final val = sortType == LeaderboardSortType.wealth ? netWorth : reputationXp;

      final countSnapshot = await FirebaseFirestore.instance
          .collection(_collectionName)
          .where(field, isGreaterThan: val)
          .count()
          .get();

      final higherCount = countSnapshot.count ?? 0;
      return higherCount + 1;
    } catch (e) {
      debugPrint('[LeaderboardService] fetchPlayerExactRank error: $e');
      return null;
    }
  }

  /// Clears in-memory cache forcing next fetch to hit network.
  void invalidateCache() {
    _cachedWealthLeaderboard = null;
    _wealthCacheTimestamp = null;
    _cachedXpLeaderboard = null;
    _xpCacheTimestamp = null;
  }
}
