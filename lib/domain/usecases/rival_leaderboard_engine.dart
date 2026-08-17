import '../../core/utils/currency_formatter.dart';
import '../../data/models/dealership_model.dart';

class LeaderboardEntry {
  final String name;
  final double turnoverScore;
  final int reputation;
  final int carsSold;
  final bool isPlayer;
  final int rank;
  final int rankChange; // Positive: moved up, Negative: dropped, 0: stable
  final String tagline;

  LeaderboardEntry({
    required this.name,
    required this.turnoverScore,
    required this.reputation,
    required this.carsSold,
    required this.isPlayer,
    this.rank = 1,
    this.rankChange = 0,
    this.tagline = '',
  });

  LeaderboardEntry copyWith({
    String? name,
    double? turnoverScore,
    int? reputation,
    int? carsSold,
    bool? isPlayer,
    int? rank,
    int? rankChange,
    String? tagline,
  }) {
    return LeaderboardEntry(
      name: name ?? this.name,
      turnoverScore: turnoverScore ?? this.turnoverScore,
      reputation: reputation ?? this.reputation,
      carsSold: carsSold ?? this.carsSold,
      isPlayer: isPlayer ?? this.isPlayer,
      rank: rank ?? this.rank,
      rankChange: rankChange ?? this.rankChange,
      tagline: tagline ?? this.tagline,
    );
  }

  LeaderboardEntry copyWithRank(int newRank, {int? newRankChange}) {
    return LeaderboardEntry(
      name: name,
      turnoverScore: turnoverScore,
      reputation: reputation,
      carsSold: carsSold,
      isPlayer: isPlayer,
      rank: newRank,
      rankChange: newRankChange ?? rankChange,
      tagline: tagline,
    );
  }
}

class LeaderboardNearMissInfo {
  final int playerRank;
  final bool isLeader;
  final String? targetRivalName;
  final double scoreDifference;
  final String motivationMessage;

  LeaderboardNearMissInfo({
    required this.playerRank,
    required this.isLeader,
    this.targetRivalName,
    this.scoreDifference = 0.0,
    required this.motivationMessage,
  });
}

class RivalLeaderboardEngine {
  static const List<Map<String, dynamic>> _npcArchetypes = [
    {
      'name': 'Boğaziçi Otomotiv',
      'tagline': 'Bölge Lideri & Zirve Galeri',
      'multiplier': 1.65,
      'flatOffset': 120000.0,
      'dailyGrowthRate': 0.015,
      'baseSold': 18,
      'baseRep': 140,
    },
    {
      'name': 'Anadolu Plaza',
      'tagline': 'Premium Kurumsal Galeri',
      'multiplier': 1.30,
      'flatOffset': 60000.0,
      'dailyGrowthRate': 0.012,
      'baseSold': 12,
      'baseRep': 110,
    },
    {
      'name': 'Altınel Galeri',
      'tagline': 'Tecrübeli Esnaf Galerisi',
      'multiplier': 1.08,
      'flatOffset': 20000.0,
      'dailyGrowthRate': 0.010,
      'baseSold': 8,
      'baseRep': 85,
    },
    {
      'name': 'Star Motors',
      'tagline': 'Kafa Kafaya Çekişmeli Rakip',
      'multiplier': 0.90,
      'flatOffset': -8000.0,
      'dailyGrowthRate': 0.008,
      'baseSold': 4,
      'baseRep': 65,
    },
    {
      'name': 'Yıldız Auto',
      'tagline': 'Gelişmekte Olan Mahalle Galerisi',
      'multiplier': 0.70,
      'flatOffset': -25000.0,
      'dailyGrowthRate': 0.006,
      'baseSold': 2,
      'baseRep': 45,
    },
  ];

  static double _calculatePlayerScore(DealershipModel playerDealership) {
    final vehicleAssets = playerDealership.ownedCars.fold<double>(
      0.0,
      (sum, car) => sum + (car.estimatedRealValue > 0 ? car.estimatedRealValue : car.baseMarketValue),
    );
    final netWorth = playerDealership.balance + vehicleAssets;
    final activityScore = playerDealership.totalProfit + (playerDealership.carsSold * 90000.0);
    final combined = activityScore + (netWorth * 0.4);
    return combined > 50000.0 ? combined : 50000.0;
  }

  static double _getDailyVariance(String name, int day) {
    final seed = (name.hashCode ^ (day * 7919) ^ (day * day)).abs();
    // 0.88 to 1.14 variance (±12-14%)
    return 0.88 + ((seed % 27) / 100.0);
  }

  static List<LeaderboardEntry> _generateRawList({
    required DealershipModel playerDealership,
    required int day,
    required double baseScore,
  }) {
    final entries = <LeaderboardEntry>[];

    // Player Entry
    final playerName = playerDealership.dealershipName.isNotEmpty
        ? playerDealership.dealershipName
        : 'Benim Galerim';
    entries.add(LeaderboardEntry(
      name: playerName,
      turnoverScore: baseScore,
      reputation: playerDealership.reputationScore,
      carsSold: playerDealership.carsSold,
      isPlayer: true,
      tagline: 'Senin Galerim',
    ));

    // NPC Rival Entries
    for (final npc in _npcArchetypes) {
      final name = npc['name'] as String;
      final tagline = npc['tagline'] as String;
      final multiplier = npc['multiplier'] as double;
      final flatOffset = npc['flatOffset'] as double;
      final dailyGrowthRate = npc['dailyGrowthRate'] as double;
      final baseSold = npc['baseSold'] as int;
      final baseRep = npc['baseRep'] as int;

      final variance = _getDailyVariance(name, day);
      final dayBonus = 1.0 + (dailyGrowthRate * (day - 1));
      final turnover = ((baseScore * multiplier) + flatOffset) * dayBonus * variance;

      // Scale cars sold and reputation organically with player progress
      final playerSoldFactor = playerDealership.carsSold * 0.8;
      final sold = (baseSold + (day * 0.8) + (playerSoldFactor * multiplier)).round();
      final rep = (baseRep + (day * 0.5) + (playerDealership.reputationScore * 0.2 * multiplier)).round();

      entries.add(LeaderboardEntry(
        name: name,
        turnoverScore: turnover > 5000.0 ? turnover : 5000.0,
        reputation: rep > 10 ? rep : 10,
        carsSold: sold > 0 ? sold : 0,
        isPlayer: false,
        tagline: tagline,
      ));
    }

    entries.sort((a, b) => b.turnoverScore.compareTo(a.turnoverScore));
    return entries;
  }

  static List<LeaderboardEntry> getLeaderboard({
    required DealershipModel playerDealership,
    required int currentDay,
  }) {
    final effectiveDay = currentDay > 0 ? currentDay : 1;
    final baseScore = _calculatePlayerScore(playerDealership);

    // Current day leaderboard
    final currentList = _generateRawList(
      playerDealership: playerDealership,
      day: effectiveDay,
      baseScore: baseScore,
    );

    // Previous day leaderboard for trend computation (if day 1, compare with baseline day 0)
    final prevList = _generateRawList(
      playerDealership: playerDealership,
      day: effectiveDay > 1 ? effectiveDay - 1 : 0,
      baseScore: baseScore * 0.97,
    );

    // Map previous ranks
    final prevRanks = <String, int>{};
    for (int i = 0; i < prevList.length; i++) {
      prevRanks[prevList[i].name] = i + 1;
    }

    // Assign final ranks and rankChanges
    final ranked = <LeaderboardEntry>[];
    for (int i = 0; i < currentList.length; i++) {
      final currentRank = i + 1;
      final item = currentList[i];
      final prevRank = prevRanks[item.name] ?? currentRank;
      final rankChange = prevRank - currentRank; // +1 if moved up from 5 to 4

      ranked.add(item.copyWithRank(currentRank, newRankChange: rankChange));
    }

    return ranked;
  }

  /// Generates Near-Miss & Motivational Distance for the Player
  static LeaderboardNearMissInfo getNearMissInfo(List<LeaderboardEntry> leaderboard) {
    final playerIndex = leaderboard.indexWhere((e) => e.isPlayer);
    if (playerIndex == -1) {
      return LeaderboardNearMissInfo(
        playerRank: 6,
        isLeader: false,
        motivationMessage: 'Şehir sıralamasında yerini almak için satış yap!',
      );
    }

    final playerRank = playerIndex + 1;
    final playerEntry = leaderboard[playerIndex];

    if (playerIndex == 0) {
      final secondRival = leaderboard.length > 1 ? leaderboard[1] : null;
      final diff = secondRival != null ? (playerEntry.turnoverScore - secondRival.turnoverScore) : 0.0;
      return LeaderboardNearMissInfo(
        playerRank: 1,
        isLeader: true,
        scoreDifference: diff,
        motivationMessage: secondRival != null
            ? 'ŞEHİR LİDERİSİN! En yakın rakibin ${secondRival.name} ${CurrencyFormatter.format(diff)} gerinde.'
            : 'ŞEHİR LİDERİSİN!',
      );
    }

    final rivalAhead = leaderboard[playerIndex - 1];
    final diff = rivalAhead.turnoverScore - playerEntry.turnoverScore;

    return LeaderboardNearMissInfo(
      playerRank: playerRank,
      isLeader: false,
      targetRivalName: rivalAhead.name,
      scoreDifference: diff,
      motivationMessage:
          '#${playerRank - 1} sıradaki ${rivalAhead.name}\'ı geçmek için sadece ${CurrencyFormatter.format(diff)} ciro kaldı! 1-2 kârlı satışla sıranı yükselt!',
    );
  }
}
