class WantedCarContract {
  final String id;
  final String clientName;
  final String targetBrand;
  final String? targetModel;
  final String? targetBodyType;
  final int minYear;
  final int maxMileage;
  final double budget;
  final double rewardBonus;
  final int deadlineDays;
  final bool isFulfilled;
  final String description;

  const WantedCarContract({
    required this.id,
    required this.clientName,
    required this.targetBrand,
    this.targetModel,
    this.targetBodyType,
    this.minYear = 2005,
    this.maxMileage = 250000,
    required this.budget,
    required this.rewardBonus,
    required this.deadlineDays,
    this.isFulfilled = false,
    this.description = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'clientName': clientName,
        'targetBrand': targetBrand,
        'targetModel': targetModel,
        'targetBodyType': targetBodyType,
        'minYear': minYear,
        'maxMileage': maxMileage,
        'budget': budget,
        'rewardBonus': rewardBonus,
        'deadlineDays': deadlineDays,
        'isFulfilled': isFulfilled,
        'description': description,
      };

  factory WantedCarContract.fromJson(Map<String, dynamic> json) =>
      WantedCarContract(
        id: json['id'] as String? ?? 'c_${DateTime.now().millisecondsSinceEpoch}',
        clientName: json['clientName'] as String? ?? 'Müşteri',
        targetBrand: json['targetBrand'] as String? ?? 'Tofaşk',
        targetModel: json['targetModel'] as String?,
        targetBodyType: json['targetBodyType'] as String?,
        minYear: json['minYear'] as int? ?? 2005,
        maxMileage: json['maxMileage'] as int? ?? 250000,
        budget: (json['budget'] as num?)?.toDouble() ?? 100000.0,
        rewardBonus: (json['rewardBonus'] as num?)?.toDouble() ?? 15000.0,
        deadlineDays: json['deadlineDays'] as int? ?? 5,
        isFulfilled: json['isFulfilled'] as bool? ?? false,
        description: json['description'] as String? ?? '',
      );

  WantedCarContract copyWith({
    int? deadlineDays,
    bool? isFulfilled,
  }) =>
      WantedCarContract(
        id: id,
        clientName: clientName,
        targetBrand: targetBrand,
        targetModel: targetModel,
        targetBodyType: targetBodyType,
        minYear: minYear,
        maxMileage: maxMileage,
        budget: budget,
        rewardBonus: rewardBonus,
        deadlineDays: deadlineDays ?? this.deadlineDays,
        isFulfilled: isFulfilled ?? this.isFulfilled,
        description: description,
      );
}
