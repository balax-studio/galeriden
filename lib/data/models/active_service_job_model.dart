enum ServiceJobType {
  workshopEngineOverhaul,
  workshopPartsDelivery,
  workshopBarnFindRestore,
  carWashCeramicCure,
  carWashInteriorDry,
  carWashPpfArmor,
  tuningEcuRemap,
  tuningAirSuspension,
  staffAcademyTraining,
  staffExecutiveCert,
  expertiseDeepInspection,
  expertiseTuvPreparation,
  auctionVehicleTransport,
  auctionCustomsClearance,
  financeTermDeposit,
  financeChequeClearing,
  stockIpoSubscription,
  stockBlockTradeSettlement,
  showroomMarbleRenovation,
  showroomVipLounge,
  scrapyardDismantlePress,
  scrapyardMetalRecycleBatch,
  rentCarCorporateFleet,
  rentCarInsuranceAppraisal,
  consignmentVipMatchmaking,
  consignmentNotaryTransfer,
  sideBusinessLevelUpgrade,
  branchCityPermitOpening,
}

class ActiveServiceJobModel {
  final String id;
  final ServiceJobType type;
  final String targetEntityId;
  final String targetTitle;
  final int startDay;
  final int totalDurationDays;
  final int remainingDays;
  final double rushCashCost;
  final int rushReputationCost;
  final String rushLoreTitleKey;
  final String rushLoreDescKey;
  final String rushButtonActionKey;
  final Map<String, dynamic> metadata;

  const ActiveServiceJobModel({
    required this.id,
    required this.type,
    required this.targetEntityId,
    required this.targetTitle,
    required this.startDay,
    required this.totalDurationDays,
    required this.remainingDays,
    this.rushCashCost = 0.0,
    this.rushReputationCost = 0,
    required this.rushLoreTitleKey,
    required this.rushLoreDescKey,
    required this.rushButtonActionKey,
    this.metadata = const {},
  });

  bool get isCompleted => remainingDays <= 0;

  double get progressPercentage {
    if (totalDurationDays <= 0) return 1.0;
    final elapsed = totalDurationDays - remainingDays;
    return (elapsed / totalDurationDays).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'targetEntityId': targetEntityId,
      'targetTitle': targetTitle,
      'startDay': startDay,
      'totalDurationDays': totalDurationDays,
      'remainingDays': remainingDays,
      'rushCashCost': rushCashCost,
      'rushReputationCost': rushReputationCost,
      'rushLoreTitleKey': rushLoreTitleKey,
      'rushLoreDescKey': rushLoreDescKey,
      'rushButtonActionKey': rushButtonActionKey,
      'metadata': metadata,
    };
  }

  factory ActiveServiceJobModel.fromJson(Map<String, dynamic> json) {
    return ActiveServiceJobModel(
      id: json['id'] as String? ?? 'job_${DateTime.now().millisecondsSinceEpoch}',
      type: ServiceJobType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ServiceJobType.workshopPartsDelivery,
      ),
      targetEntityId: json['targetEntityId'] as String? ?? '',
      targetTitle: json['targetTitle'] as String? ?? '',
      startDay: json['startDay'] as int? ?? 1,
      totalDurationDays: json['totalDurationDays'] as int? ?? 1,
      remainingDays: json['remainingDays'] as int? ?? 1,
      rushCashCost: (json['rushCashCost'] as num?)?.toDouble() ?? 0.0,
      rushReputationCost: json['rushReputationCost'] as int? ?? 0,
      rushLoreTitleKey: json['rushLoreTitleKey'] as String? ?? '',
      rushLoreDescKey: json['rushLoreDescKey'] as String? ?? '',
      rushButtonActionKey: json['rushButtonActionKey'] as String? ?? '',
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  ActiveServiceJobModel copyWith({
    String? id,
    ServiceJobType? type,
    String? targetEntityId,
    String? targetTitle,
    int? startDay,
    int? totalDurationDays,
    int? remainingDays,
    double? rushCashCost,
    int? rushReputationCost,
    String? rushLoreTitleKey,
    String? rushLoreDescKey,
    String? rushButtonActionKey,
    Map<String, dynamic>? metadata,
  }) {
    return ActiveServiceJobModel(
      id: id ?? this.id,
      type: type ?? this.type,
      targetEntityId: targetEntityId ?? this.targetEntityId,
      targetTitle: targetTitle ?? this.targetTitle,
      startDay: startDay ?? this.startDay,
      totalDurationDays: totalDurationDays ?? this.totalDurationDays,
      remainingDays: remainingDays ?? this.remainingDays,
      rushCashCost: rushCashCost ?? this.rushCashCost,
      rushReputationCost: rushReputationCost ?? this.rushReputationCost,
      rushLoreTitleKey: rushLoreTitleKey ?? this.rushLoreTitleKey,
      rushLoreDescKey: rushLoreDescKey ?? this.rushLoreDescKey,
      rushButtonActionKey: rushButtonActionKey ?? this.rushButtonActionKey,
      metadata: metadata ?? this.metadata,
    );
  }
}
