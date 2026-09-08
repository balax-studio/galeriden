class LeaderboardEntryModel {
  final String playerId;
  final String dealershipName;
  final String ownerName;
  final double netWorth;
  final int reputationXp;
  final int playerLevel;
  final int carCount;
  final DateTime updatedAt;

  const LeaderboardEntryModel({
    required this.playerId,
    required this.dealershipName,
    required this.ownerName,
    required this.netWorth,
    required this.reputationXp,
    required this.playerLevel,
    required this.carCount,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'playerId': playerId,
      'dealershipName': dealershipName,
      'ownerName': ownerName,
      'netWorth': netWorth,
      'reputationXp': reputationXp,
      'playerLevel': playerLevel,
      'carCount': carCount,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory LeaderboardEntryModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return LeaderboardEntryModel(
      playerId: docId ?? (map['playerId'] as String? ?? ''),
      dealershipName: map['dealershipName'] as String? ?? 'Bilinmeyen Galeri',
      ownerName: map['ownerName'] as String? ?? 'Galerici',
      netWorth: (map['netWorth'] as num?)?.toDouble() ?? 0.0,
      reputationXp: (map['reputationXp'] as num?)?.toInt() ?? 0,
      playerLevel: (map['playerLevel'] as num?)?.toInt() ?? 1,
      carCount: (map['carCount'] as num?)?.toInt() ?? 0,
      updatedAt: map['updatedAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
          : DateTime.now(),
    );
  }

  LeaderboardEntryModel copyWith({
    String? playerId,
    String? dealershipName,
    String? ownerName,
    double? netWorth,
    int? reputationXp,
    int? playerLevel,
    int? carCount,
    DateTime? updatedAt,
  }) {
    return LeaderboardEntryModel(
      playerId: playerId ?? this.playerId,
      dealershipName: dealershipName ?? this.dealershipName,
      ownerName: ownerName ?? this.ownerName,
      netWorth: netWorth ?? this.netWorth,
      reputationXp: reputationXp ?? this.reputationXp,
      playerLevel: playerLevel ?? this.playerLevel,
      carCount: carCount ?? this.carCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
