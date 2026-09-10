import 'dart:convert';

/// Active temporary perks granted to podium winners for the duration of a season (7 days).
class ActivePodiumPerks {
  final int seasonId;
  final int rank; // 1, 2, 3, or 4..10
  final DateTime expiresAt;
  final double notaryDiscountRate; // 0.50 for rank 1, 0.30 for rank 2, 0.15 for rank 3
  final bool hasCustomsAuctionPass; // Rank 1: Gümrük Tasfiye İhalesi
  final bool hasFleetLiquidationProtocol; // Rank 2: Banka Filo Tasfiyesi
  final bool hasMasterMechanicVoucher; // Rank 3: Sanayi Usta Başı Çeki
  final bool hasGulfBuyerNetwork; // Rank 1: Körfez Alıcıları (%15 primli nakit alım)
  final bool hasInspectionTransparency; // Rank 2: Ekspertizde %100 kusur görme
  final bool hasShowcaseBoost; // Rank 3: Sarı Site Vitrin Dopingi
  final int freeNoterVouchers; // Rank 4..10
  final String? customPlateTitle;

  const ActivePodiumPerks({
    required this.seasonId,
    required this.rank,
    required this.expiresAt,
    this.notaryDiscountRate = 0.0,
    this.hasCustomsAuctionPass = false,
    this.hasFleetLiquidationProtocol = false,
    this.hasMasterMechanicVoucher = false,
    this.hasGulfBuyerNetwork = false,
    this.hasInspectionTransparency = false,
    this.hasShowcaseBoost = false,
    this.freeNoterVouchers = 0,
    this.customPlateTitle,
  });

  bool get isActive => DateTime.now().isBefore(expiresAt);

  ActivePodiumPerks copyWith({
    int? seasonId,
    int? rank,
    DateTime? expiresAt,
    double? notaryDiscountRate,
    bool? hasCustomsAuctionPass,
    bool? hasFleetLiquidationProtocol,
    bool? hasMasterMechanicVoucher,
    bool? hasGulfBuyerNetwork,
    bool? hasInspectionTransparency,
    bool? hasShowcaseBoost,
    int? freeNoterVouchers,
    String? customPlateTitle,
  }) {
    return ActivePodiumPerks(
      seasonId: seasonId ?? this.seasonId,
      rank: rank ?? this.rank,
      expiresAt: expiresAt ?? this.expiresAt,
      notaryDiscountRate: notaryDiscountRate ?? this.notaryDiscountRate,
      hasCustomsAuctionPass: hasCustomsAuctionPass ?? this.hasCustomsAuctionPass,
      hasFleetLiquidationProtocol: hasFleetLiquidationProtocol ?? this.hasFleetLiquidationProtocol,
      hasMasterMechanicVoucher: hasMasterMechanicVoucher ?? this.hasMasterMechanicVoucher,
      hasGulfBuyerNetwork: hasGulfBuyerNetwork ?? this.hasGulfBuyerNetwork,
      hasInspectionTransparency: hasInspectionTransparency ?? this.hasInspectionTransparency,
      hasShowcaseBoost: hasShowcaseBoost ?? this.hasShowcaseBoost,
      freeNoterVouchers: freeNoterVouchers ?? this.freeNoterVouchers,
      customPlateTitle: customPlateTitle ?? this.customPlateTitle,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'seasonId': seasonId,
      'rank': rank,
      'expiresAt': expiresAt.toIso8601String(),
      'notaryDiscountRate': notaryDiscountRate,
      'hasCustomsAuctionPass': hasCustomsAuctionPass,
      'hasFleetLiquidationProtocol': hasFleetLiquidationProtocol,
      'hasMasterMechanicVoucher': hasMasterMechanicVoucher,
      'hasGulfBuyerNetwork': hasGulfBuyerNetwork,
      'hasInspectionTransparency': hasInspectionTransparency,
      'hasShowcaseBoost': hasShowcaseBoost,
      'freeNoterVouchers': freeNoterVouchers,
      'customPlateTitle': customPlateTitle,
    };
  }

  factory ActivePodiumPerks.fromMap(Map<String, dynamic> map) {
    return ActivePodiumPerks(
      seasonId: map['seasonId'] as int? ?? 0,
      rank: map['rank'] as int? ?? 0,
      expiresAt: map['expiresAt'] != null
          ? DateTime.tryParse(map['expiresAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      notaryDiscountRate: (map['notaryDiscountRate'] as num?)?.toDouble() ?? 0.0,
      hasCustomsAuctionPass: map['hasCustomsAuctionPass'] as bool? ?? false,
      hasFleetLiquidationProtocol: map['hasFleetLiquidationProtocol'] as bool? ?? false,
      hasMasterMechanicVoucher: map['hasMasterMechanicVoucher'] as bool? ?? false,
      hasGulfBuyerNetwork: map['hasGulfBuyerNetwork'] as bool? ?? false,
      hasInspectionTransparency: map['hasInspectionTransparency'] as bool? ?? false,
      hasShowcaseBoost: map['hasShowcaseBoost'] as bool? ?? false,
      freeNoterVouchers: map['freeNoterVouchers'] as int? ?? 0,
      customPlateTitle: map['customPlateTitle'] as String?,
    );
  }

  String toJson() => json.encode(toMap());
  factory ActivePodiumPerks.fromJson(String source) =>
      ActivePodiumPerks.fromMap(json.decode(source) as Map<String, dynamic>);
}

/// Permanent trophy/berat stored in the player's office trophy room.
class PodiumTrophy {
  final String id;
  final int seasonId;
  final int rank; // 1: Gold, 2: Silver, 3: Bronze
  final String titleKey;
  final DateTime earnedAt;

  const PodiumTrophy({
    required this.id,
    required this.seasonId,
    required this.rank,
    required this.titleKey,
    required this.earnedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'seasonId': seasonId,
      'rank': rank,
      'titleKey': titleKey,
      'earnedAt': earnedAt.toIso8601String(),
    };
  }

  factory PodiumTrophy.fromMap(Map<String, dynamic> map) {
    return PodiumTrophy(
      id: map['id'] as String? ?? '',
      seasonId: map['seasonId'] as int? ?? 0,
      rank: map['rank'] as int? ?? 1,
      titleKey: map['titleKey'] as String? ?? 'podium_trophy_title_1',
      earnedAt: map['earnedAt'] != null
          ? DateTime.tryParse(map['earnedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());
  factory PodiumTrophy.fromJson(String source) =>
      PodiumTrophy.fromMap(json.decode(source) as Map<String, dynamic>);
}
