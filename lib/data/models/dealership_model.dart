import 'car_model.dart';
import 'offer_model.dart';
import 'player_skills.dart';
import 'player_achievements.dart';
import 'mission_model.dart';
import 'market_trend_model.dart';

class DealershipModel {
  final double balance;
  final int level;
  final int maxGarageSlots;
  final List<CarModel> ownedCars;
  final List<OfferModel> incomingOffers;
  final double totalProfit;
  final int carsSold;
  final DateTime lastActiveTime;
  final PlayerSkills skills;
  final List<AchievementItem> achievements;
  final int loginStreak;
  final DateTime lastLoginDate;
  final List<MissionModel> activeMissions;
  final MarketTrendModel marketTrend;

  DealershipModel({
    required this.balance,
    required this.level,
    required this.maxGarageSlots,
    required this.ownedCars,
    required this.incomingOffers,
    required this.totalProfit,
    required this.carsSold,
    required this.lastActiveTime,
    required this.skills,
    required this.achievements,
    required this.loginStreak,
    required this.lastLoginDate,
    required this.activeMissions,
    required this.marketTrend,
  });

  factory DealershipModel.initial() {
    final now = DateTime.now();
    return DealershipModel(
      balance: 450000.0,
      level: 1,
      maxGarageSlots: 3,
      ownedCars: [],
      incomingOffers: [],
      totalProfit: 0.0,
      carsSold: 0,
      lastActiveTime: now,
      skills: PlayerSkills(),
      achievements: PlayerAchievements.initialList,
      loginStreak: 1,
      lastLoginDate: now,
      activeMissions: [
        MissionModel(
          id: 'm_buy_1',
          title: 'İlk Alım',
          description: 'Pazardan 1 araç satın al',
          type: MissionType.buyCars,
          currentProgress: 0,
          targetGoal: 1,
          rewardMoney: 15000,
          rewardXP: 100,
        ),
        MissionModel(
          id: 'm_sell_1',
          title: 'Ticaret Adamı',
          description: '1 aracı başarıyla sat',
          type: MissionType.sellCars,
          currentProgress: 0,
          targetGoal: 1,
          rewardMoney: 25000,
          rewardXP: 150,
        ),
        MissionModel(
          id: 'm_exp_1',
          title: 'Titiz İnceleme',
          description: '1 araca ekspertiz yaptır',
          type: MissionType.doExpertise,
          currentProgress: 0,
          targetGoal: 1,
          rewardMoney: 10000,
          rewardXP: 80,
        ),
      ],
      marketTrend: MarketTrendModel.defaultTrend(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'level': level,
      'maxGarageSlots': maxGarageSlots,
      'ownedCars': ownedCars.map((c) => c.toJson()).toList(),
      'incomingOffers': incomingOffers.map((o) => o.toJson()).toList(),
      'totalProfit': totalProfit,
      'carsSold': carsSold,
      'lastActiveTime': lastActiveTime.toIso8601String(),
      'skills': skills.toJson(),
      'achievements': achievements.map((a) => a.toJson()).toList(),
      'loginStreak': loginStreak,
      'lastLoginDate': lastLoginDate.toIso8601String(),
      'activeMissions': activeMissions.map((m) => m.toJson()).toList(),
      'marketTrend': marketTrend.toJson(),
    };
  }

  factory DealershipModel.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return DealershipModel(
      balance: (json['balance'] as num).toDouble(),
      level: json['level'] as int,
      maxGarageSlots: json['maxGarageSlots'] as int,
      ownedCars: (json['ownedCars'] as List<dynamic>?)
              ?.map((c) => CarModel.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      incomingOffers: (json['incomingOffers'] as List<dynamic>?)
              ?.map((o) => OfferModel.fromJson(o as Map<String, dynamic>))
              .toList() ??
          [],
      totalProfit: (json['totalProfit'] as num).toDouble(),
      carsSold: json['carsSold'] as int,
      lastActiveTime: DateTime.tryParse(json['lastActiveTime'] as String? ?? '') ?? now,
      skills: json['skills'] != null ? PlayerSkills.fromJson(json['skills'] as Map<String, dynamic>) : PlayerSkills(),
      achievements: json['achievements'] != null
          ? (json['achievements'] as List<dynamic>).map((a) => AchievementItem.fromJson(a as Map<String, dynamic>)).toList()
          : PlayerAchievements.initialList,
      loginStreak: json['loginStreak'] as int? ?? 1,
      lastLoginDate: DateTime.tryParse(json['lastLoginDate'] as String? ?? '') ?? now,
      activeMissions: json['activeMissions'] != null
          ? (json['activeMissions'] as List<dynamic>).map((m) => MissionModel.fromJson(m as Map<String, dynamic>)).toList()
          : DealershipModel.initial().activeMissions,
      marketTrend: json['marketTrend'] != null
          ? MarketTrendModel.fromJson(json['marketTrend'] as Map<String, dynamic>)
          : MarketTrendModel.defaultTrend(),
    );
  }

  DealershipModel copyWith({
    double? balance,
    int? level,
    int? maxGarageSlots,
    List<CarModel>? ownedCars,
    List<OfferModel>? incomingOffers,
    double? totalProfit,
    int? carsSold,
    DateTime? lastActiveTime,
    PlayerSkills? skills,
    List<AchievementItem>? achievements,
    int? loginStreak,
    DateTime? lastLoginDate,
    List<MissionModel>? activeMissions,
    MarketTrendModel? marketTrend,
  }) {
    return DealershipModel(
      balance: balance ?? this.balance,
      level: level ?? this.level,
      maxGarageSlots: maxGarageSlots ?? this.maxGarageSlots,
      ownedCars: ownedCars ?? this.ownedCars,
      incomingOffers: incomingOffers ?? this.incomingOffers,
      totalProfit: totalProfit ?? this.totalProfit,
      carsSold: carsSold ?? this.carsSold,
      lastActiveTime: lastActiveTime ?? this.lastActiveTime,
      skills: skills ?? this.skills,
      achievements: achievements ?? this.achievements,
      loginStreak: loginStreak ?? this.loginStreak,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      activeMissions: activeMissions ?? this.activeMissions,
      marketTrend: marketTrend ?? this.marketTrend,
    );
  }
}
