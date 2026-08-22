class PrCampaignModel {
  final String id;
  final String title;
  final String description;
  final double cost;
  final int durationDays;
  final double customerFlowMultiplier; // e.g. 2.0 (+%100)
  final double offerPriceBoost; // e.g. 0.15 (+%15)
  final double negotiationResistanceReduction; // e.g. 0.50 (-%50)
  final int reputationReward;
  final String vectorIcon;

  const PrCampaignModel({
    required this.id,
    required this.title,
    required this.description,
    required this.cost,
    required this.durationDays,
    required this.customerFlowMultiplier,
    required this.offerPriceBoost,
    required this.negotiationResistanceReduction,
    required this.reputationReward,
    required this.vectorIcon,
  });

  static const List<PrCampaignModel> campaigns = [
    PrCampaignModel(
      id: 'pr_youtube_influencer',
      title: 'Otomotiv Fenomeni & YouTube İncelemesi',
      description: 'Milyon takipçili otomotiv yayıncısı galerinizin vitrinini ve özel araçlarını tanıtır • 3 gün boyunca vitrine iki kat daha fazla müşteri akar.',
      cost: 150000.0,
      durationDays: 3,
      customerFlowMultiplier: 2.0,
      offerPriceBoost: 0.10,
      negotiationResistanceReduction: 0.25,
      reputationReward: 30,
      vectorIcon: 'social',
    ),
    PrCampaignModel(
      id: 'pr_national_tv_sponsor',
      title: 'Ulusal TV Ana Haber & Gazete Manşetleri',
      description: 'Otomotiv sektöründe güvenin adresi olarak ulusal basında yer alın • Müşteriler pazarlık yapmadan liste fiyatına yakın teklif verir.',
      cost: 450000.0,
      durationDays: 5,
      customerFlowMultiplier: 3.2,
      offerPriceBoost: 0.18,
      negotiationResistanceReduction: 0.55,
      reputationReward: 75,
      vectorIcon: 'tv',
    ),
    PrCampaignModel(
      id: 'pr_intercity_billboard_network',
      title: 'Şehirlerarası Dijital Billboard Ağı & Lansman',
      description: 'Tüm metropol ana arterlerinde ve havalimanı VIP terminallerinde devasa LED reklamlar • Zengin alıcılar araçlarınızı anında kapışır.',
      cost: 1200000.0,
      durationDays: 7,
      customerFlowMultiplier: 5.0,
      offerPriceBoost: 0.25,
      negotiationResistanceReduction: 0.85,
      reputationReward: 180,
      vectorIcon: 'billboard',
    ),
  ];
}

class ActivePrCampaign {
  final String campaignId;
  final String title;
  final int startDay;
  final int endDay;
  final double customerFlowMultiplier;
  final double offerPriceBoost;
  final double negotiationResistanceReduction;

  const ActivePrCampaign({
    required this.campaignId,
    required this.title,
    required this.startDay,
    required this.endDay,
    required this.customerFlowMultiplier,
    required this.offerPriceBoost,
    required this.negotiationResistanceReduction,
  });

  bool isActive(int currentDay) => currentDay <= endDay;

  int remainingDays(int currentDay) {
    final diff = endDay - currentDay + 1;
    return diff > 0 ? diff : 0;
  }

  Map<String, dynamic> toJson() => {
        'campaignId': campaignId,
        'title': title,
        'startDay': startDay,
        'endDay': endDay,
        'customerFlowMultiplier': customerFlowMultiplier,
        'offerPriceBoost': offerPriceBoost,
        'negotiationResistanceReduction': negotiationResistanceReduction,
      };

  factory ActivePrCampaign.fromJson(Map<String, dynamic> json) {
    return ActivePrCampaign(
      campaignId: json['campaignId'] as String,
      title: json['title'] as String,
      startDay: json['startDay'] as int,
      endDay: json['endDay'] as int,
      customerFlowMultiplier: (json['customerFlowMultiplier'] as num).toDouble(),
      offerPriceBoost: (json['offerPriceBoost'] as num).toDouble(),
      negotiationResistanceReduction: (json['negotiationResistanceReduction'] as num).toDouble(),
    );
  }
}
