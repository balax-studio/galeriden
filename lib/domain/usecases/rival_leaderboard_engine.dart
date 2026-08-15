import '../../data/models/dealership_model.dart';

class LeaderboardEntry {
  final String name;
  final double turnoverScore;
  final int reputation;
  final int carsSold;
  final bool isPlayer;
  final int rank;

  LeaderboardEntry({
    required this.name,
    required this.turnoverScore,
    required this.reputation,
    required this.carsSold,
    required this.isPlayer,
    this.rank = 1,
  });

  LeaderboardEntry copyWithRank(int newRank) {
    return LeaderboardEntry(
      name: name,
      turnoverScore: turnoverScore,
      reputation: reputation,
      carsSold: carsSold,
      isPlayer: isPlayer,
      rank: newRank,
    );
  }
}

class RivalLeaderboardEngine {
  static const List<Map<String, dynamic>> _npcRivals = [
    {'name': 'Boğaziçi Otomotiv', 'baseTurnover': 3200000.0, 'dailyGrowth': 120000.0, 'baseRep': 160, 'baseSold': 35},
    {'name': 'Anadolu Plaza', 'baseTurnover': 2100000.0, 'dailyGrowth': 85000.0, 'baseRep': 135, 'baseSold': 22},
    {'name': 'Altınel Galeri', 'baseTurnover': 1500000.0, 'dailyGrowth': 65000.0, 'baseRep': 115, 'baseSold': 16},
    {'name': 'Star Motors', 'baseTurnover': 950000.0, 'dailyGrowth': 45000.0, 'baseRep': 95, 'baseSold': 10},
    {'name': 'Yıldız Auto', 'baseTurnover': 450000.0, 'dailyGrowth': 25000.0, 'baseRep': 75, 'baseSold': 5},
  ];

  static List<LeaderboardEntry> getLeaderboard({
    required DealershipModel playerDealership,
    required int currentDay,
  }) {
    final entries = <LeaderboardEntry>[];

    // Player Entry
    final playerTurnover = playerDealership.totalProfit + (playerDealership.carsSold * 85000.0);
    entries.add(LeaderboardEntry(
      name: playerDealership.dealershipName.isNotEmpty ? playerDealership.dealershipName : 'Benim Galerim',
      turnoverScore: playerTurnover,
      reputation: playerDealership.reputationScore,
      carsSold: playerDealership.carsSold,
      isPlayer: true,
    ));

    // NPC Rival Entries with deterministic day-based progression
    for (final npc in _npcRivals) {
      final name = npc['name'] as String;
      final baseTurnover = npc['baseTurnover'] as double;
      final dailyGrowth = npc['dailyGrowth'] as double;
      final baseRep = npc['baseRep'] as int;
      final baseSold = npc['baseSold'] as int;

      final turnover = baseTurnover + (dailyGrowth * currentDay);
      final sold = baseSold + (currentDay * 1.5).round();
      final rep = (baseRep + (currentDay * 0.5)).round();

      entries.add(LeaderboardEntry(
        name: name,
        turnoverScore: turnover,
        reputation: rep,
        carsSold: sold,
        isPlayer: false,
      ));
    }

    // Sort descending by turnoverScore
    entries.sort((a, b) => b.turnoverScore.compareTo(a.turnoverScore));

    // Assign 1-indexed ranks
    final ranked = <LeaderboardEntry>[];
    for (int i = 0; i < entries.length; i++) {
      ranked.add(entries[i].copyWithRank(i + 1));
    }

    return ranked;
  }
}
