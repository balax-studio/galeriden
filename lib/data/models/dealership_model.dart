import 'car_model.dart';
import 'offer_model.dart';
import 'loan_model.dart';
import 'part_order_model.dart';
import 'staff_model.dart';
import 'customer_review_model.dart';
import 'player_skills.dart';
import 'player_achievements.dart';
import 'expertise_model.dart';
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
  final int reputationScore;
  final List<LoanModel> activeLoans;
  final List<PartOrderModel> pendingOrders;
  final List<StaffModel> hiredStaff;
  final List<CustomerReviewModel> customerReviews;
  final bool tutorialCompleted;
  final int tutorialStepIndex;
  final int currentDay;
  final String playerName;
  final String dealershipName;
  final String logoEmblemId;

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
    this.reputationScore = 100,
    this.activeLoans = const [],
    this.pendingOrders = const [],
    this.hiredStaff = const [],
    this.customerReviews = const [],
    this.tutorialCompleted = false,
    this.tutorialStepIndex = 0,
    this.currentDay = 1,
    this.playerName = 'Kaptan',
    this.dealershipName = 'Miras Oto Galeri',
    this.logoEmblemId = 'crown',
  });

  factory DealershipModel.initial() {
    final now = DateTime.now();
    // Inherited Heritage Car from grandfather Hasan Usta
    final heritageCar = CarModel(
      id: 'car_heritage_dede',
      brand: 'Tofaş',
      modelName: 'Murat 124 (Dede Mirası)',
      modelYear: 1978,
      bodyType: 'Klasik',
      colorHex: '0xFF8B4513', // Saddle Brown
      baseMarketValue: 240000.0,
      currentPurchasePrice: 0.0, // Inherited for free
      isRare: true,
      expertise: ExpertiseReport(
        engineCondition: 40.0, // Low condition engine
        transmissionCondition: 50.0, // Low condition gearbox
        tramerAmount: 12500,
        mileage: 215000,
        isMileageTampered: false,
        bodyParts: {
          'Kaput': PartStatus.damaged,
          'Tavan': PartStatus.painted,
          'Sol Kapı': PartStatus.changed,
          'Sağ Kapı': PartStatus.damaged,
          'Bagaj': PartStatus.painted,
        },
        partConditions: {
          'Kaput': 25.0,
          'Tavan': 65.0,
          'Sol Kapı': 45.0,
          'Sağ Kapı': 30.0,
          'Bagaj': 70.0,
        },
      ),
    );

    return DealershipModel(
      balance: 75000.0, // Starting money: 75k TL
      level: 1,
      maxGarageSlots: 3,
      ownedCars: [heritageCar],
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
          id: 'm_heritage_1',
          title: 'Dede Mirası',
          description: 'Miras arabayı onarıp ilk satışını yap',
          type: MissionType.sellCars,
          currentProgress: 0,
          targetGoal: 1,
          rewardMoney: 35000,
          rewardXP: 250,
        ),
      ],
      marketTrend: MarketTrendModel.defaultTrend(),
      activeLoans: const [],
      pendingOrders: const [],
      tutorialCompleted: false,
      tutorialStepIndex: 0,
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
      'reputationScore': reputationScore,
      'activeLoans': activeLoans.map((l) => l.toJson()).toList(),
      'pendingOrders': pendingOrders.map((p) => p.toJson()).toList(),
      'hiredStaff': hiredStaff.map((s) => s.toJson()).toList(),
      'customerReviews': customerReviews.map((r) => r.toJson()).toList(),
      'tutorialCompleted': tutorialCompleted,
      'tutorialStepIndex': tutorialStepIndex,
      'currentDay': currentDay,
      'playerName': playerName,
      'dealershipName': dealershipName,
      'logoEmblemId': logoEmblemId,
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
      reputationScore: json['reputationScore'] as int? ?? 100,
      activeLoans: json['activeLoans'] != null
          ? (json['activeLoans'] as List<dynamic>).map((l) => LoanModel.fromJson(l as Map<String, dynamic>)).toList()
          : const [],
      pendingOrders: (json['pendingOrders'] as List<dynamic>?)
              ?.map((p) => PartOrderModel.fromJson(p as Map<String, dynamic>))
              .toList() ??
          const [],
      hiredStaff: (json['hiredStaff'] as List<dynamic>?)
              ?.map((s) => StaffModel.fromJson(s as Map<String, dynamic>))
              .toList() ??
          const [],
      customerReviews: (json['customerReviews'] as List<dynamic>?)
              ?.map((r) => CustomerReviewModel.fromJson(r as Map<String, dynamic>))
              .toList() ??
          const [],
      tutorialCompleted: json['tutorialCompleted'] as bool? ?? false,
      tutorialStepIndex: json['tutorialStepIndex'] as int? ?? 0,
      currentDay: json['currentDay'] as int? ?? 1,
      playerName: json['playerName'] as String? ?? 'Kaptan',
      dealershipName: json['dealershipName'] as String? ?? 'Miras Oto Galeri',
      logoEmblemId: json['logoEmblemId'] as String? ?? 'crown',
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
    int? reputationScore,
    List<LoanModel>? activeLoans,
    List<PartOrderModel>? pendingOrders,
    List<StaffModel>? hiredStaff,
    List<CustomerReviewModel>? customerReviews,
    bool? tutorialCompleted,
    int? tutorialStepIndex,
    int? currentDay,
    String? playerName,
    String? dealershipName,
    String? logoEmblemId,
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
      reputationScore: reputationScore ?? this.reputationScore,
      activeLoans: activeLoans ?? this.activeLoans,
      pendingOrders: pendingOrders ?? this.pendingOrders,
      hiredStaff: hiredStaff ?? this.hiredStaff,
      customerReviews: customerReviews ?? this.customerReviews,
      tutorialCompleted: tutorialCompleted ?? this.tutorialCompleted,
      tutorialStepIndex: tutorialStepIndex ?? this.tutorialStepIndex,
      currentDay: currentDay ?? this.currentDay,
      playerName: playerName ?? this.playerName,
      dealershipName: dealershipName ?? this.dealershipName,
      logoEmblemId: logoEmblemId ?? this.logoEmblemId,
    );
  }
}
