/// Data model representing a market rumor / gossip spread by the player (§4.6.3 / Market Whisperer)
class PlayerSpreadGossipModel {
  final String id;
  final String targetSegment; // 'Sedan', 'Hatchback', 'SUV', 'Spor', 'Klasik', 'Ticari'
  final int createdDay;
  final int expiresDay;
  final double priceMultiplier; // e.g. 1.15 (+15%)

  const PlayerSpreadGossipModel({
    required this.id,
    required this.targetSegment,
    required this.createdDay,
    required this.expiresDay,
    this.priceMultiplier = 1.15,
  });

  bool isExpired(int currentDay) => currentDay >= expiresDay;

  Map<String, dynamic> toJson() => {
        'id': id,
        'targetSegment': targetSegment,
        'createdDay': createdDay,
        'expiresDay': expiresDay,
        'priceMultiplier': priceMultiplier,
      };

  factory PlayerSpreadGossipModel.fromJson(Map<String, dynamic> json) {
    return PlayerSpreadGossipModel(
      id: json['id'] as String? ?? 'rumor_${DateTime.now().millisecondsSinceEpoch}',
      targetSegment: json['targetSegment'] as String? ?? 'Sedan',
      createdDay: (json['createdDay'] as num?)?.toInt() ?? 1,
      expiresDay: (json['expiresDay'] as num?)?.toInt() ?? 4,
      priceMultiplier: (json['priceMultiplier'] as num?)?.toDouble() ?? 1.15,
    );
  }

  PlayerSpreadGossipModel copyWith({
    String? id,
    String? targetSegment,
    int? createdDay,
    int? expiresDay,
    double? priceMultiplier,
  }) {
    return PlayerSpreadGossipModel(
      id: id ?? this.id,
      targetSegment: targetSegment ?? this.targetSegment,
      createdDay: createdDay ?? this.createdDay,
      expiresDay: expiresDay ?? this.expiresDay,
      priceMultiplier: priceMultiplier ?? this.priceMultiplier,
    );
  }
}
