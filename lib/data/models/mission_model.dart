enum MissionType {
  buyCars,
  sellCars,
  repairParts,
  doExpertise,
  earnProfit,
  smsInquiry,
  washCars,
  tuneCar,
  hireStaff,
  bankInvestment,
  scrapyardDismantle,
  nightMarketVisit,
  auctionBid,
  stockTrade,
  rentCar,
  blackMarketTrade,
  gossipListen,
  consignmentAccept,
  sideBusinessCollect,
  casinoPlay,
}

class MissionModel {
  final String id;
  final String title;
  final String description;
  final String? titleKey;
  final String? descriptionKey;
  final Map<String, dynamic>? templateParams;
  final MissionType type;
  final int currentProgress;
  final int targetGoal;
  final int rewardMoney;
  final int rewardXP;
  final bool isCompleted;
  final bool isClaimed;
  final String? featureRoute;
  final bool isDiscoveryMission;

  MissionModel({
    required this.id,
    required this.title,
    required this.description,
    this.titleKey,
    this.descriptionKey,
    this.templateParams,
    required this.type,
    required this.currentProgress,
    required this.targetGoal,
    required this.rewardMoney,
    required this.rewardXP,
    bool? isCompleted,
    bool? isClaimed,
    this.featureRoute,
    bool? isDiscoveryMission,
  })  : isCompleted = isCompleted ?? false,
        isClaimed = isClaimed ?? false,
        isDiscoveryMission = isDiscoveryMission ?? false;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      if (titleKey != null) 'titleKey': titleKey,
      if (descriptionKey != null) 'descriptionKey': descriptionKey,
      if (templateParams != null) 'templateParams': templateParams,
      'type': type.name,
      'currentProgress': currentProgress,
      'targetGoal': targetGoal,
      'rewardMoney': rewardMoney,
      'rewardXP': rewardXP,
      'isCompleted': isCompleted,
      'isClaimed': isClaimed,
      if (featureRoute != null) 'featureRoute': featureRoute,
      'isDiscoveryMission': isDiscoveryMission,
    };
  }

  factory MissionModel.fromJson(Map<String, dynamic> json) {
    return MissionModel(
      id: json['id'] as String? ?? 'mission_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      titleKey: json['titleKey'] as String?,
      descriptionKey: json['descriptionKey'] as String?,
      templateParams: json['templateParams'] != null
          ? Map<String, dynamic>.from(json['templateParams'] as Map)
          : null,
      type: MissionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MissionType.buyCars,
      ),
      currentProgress: (json['currentProgress'] as num?)?.toInt() ?? 0,
      targetGoal: (json['targetGoal'] as num?)?.toInt() ?? 1,
      rewardMoney: (json['rewardMoney'] as num?)?.toInt() ?? 5000,
      rewardXP: (json['rewardXP'] as num?)?.toInt() ?? 100,
      isCompleted: json['isCompleted'] == true,
      isClaimed: json['isClaimed'] == true,
      featureRoute: json['featureRoute'] as String?,
      isDiscoveryMission: json['isDiscoveryMission'] == true,
    );
  }

  MissionModel copyWith({
    String? title,
    String? description,
    String? titleKey,
    String? descriptionKey,
    Map<String, dynamic>? templateParams,
    int? currentProgress,
    int? targetGoal,
    int? rewardMoney,
    int? rewardXP,
    bool? isCompleted,
    bool? isClaimed,
    String? featureRoute,
    bool? isDiscoveryMission,
  }) {
    return MissionModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      titleKey: titleKey ?? this.titleKey,
      descriptionKey: descriptionKey ?? this.descriptionKey,
      templateParams: templateParams ?? this.templateParams,
      type: type,
      currentProgress: currentProgress ?? this.currentProgress,
      targetGoal: targetGoal ?? this.targetGoal,
      rewardMoney: rewardMoney ?? this.rewardMoney,
      rewardXP: rewardXP ?? this.rewardXP,
      isCompleted: isCompleted ?? this.isCompleted,
      isClaimed: isClaimed ?? this.isClaimed,
      featureRoute: featureRoute ?? this.featureRoute,
      isDiscoveryMission: isDiscoveryMission ?? this.isDiscoveryMission,
    );
  }
}
