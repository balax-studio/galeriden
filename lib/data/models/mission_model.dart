enum MissionType {
  buyCars,
  sellCars,
  repairParts,
  doExpertise,
  earnProfit,
}

class MissionModel {
  final String id;
  final String title;
  final String description;
  final MissionType type;
  final int currentProgress;
  final int targetGoal;
  final int rewardMoney;
  final int rewardXP;
  final bool isCompleted;

  MissionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.currentProgress,
    required this.targetGoal,
    required this.rewardMoney,
    required this.rewardXP,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'currentProgress': currentProgress,
      'targetGoal': targetGoal,
      'rewardMoney': rewardMoney,
      'rewardXP': rewardXP,
      'isCompleted': isCompleted,
    };
  }

  factory MissionModel.fromJson(Map<String, dynamic> json) {
    return MissionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: MissionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MissionType.buyCars,
      ),
      currentProgress: json['currentProgress'] as int? ?? 0,
      targetGoal: json['targetGoal'] as int? ?? 1,
      rewardMoney: json['rewardMoney'] as int? ?? 5000,
      rewardXP: json['rewardXP'] as int? ?? 100,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  MissionModel copyWith({
    int? currentProgress,
    bool? isCompleted,
  }) {
    return MissionModel(
      id: id,
      title: title,
      description: description,
      type: type,
      currentProgress: currentProgress ?? this.currentProgress,
      targetGoal: targetGoal,
      rewardMoney: rewardMoney,
      rewardXP: rewardXP,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
