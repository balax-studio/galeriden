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
import 'sale_record_model.dart';
import 'cheque_model.dart';
import 'installment_contract_model.dart';
import 'rental_agreement_model.dart';
import 'side_business_model.dart';
import 'stock_model.dart';
import 'game_event_model.dart';

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
  final List<SaleRecordModel> salesHistory;
  final List<Cheque> activeCheques;
  final List<InstallmentContract> activeInstallments;
  final List<RentalAgreement> activeRentals;
  final bool tutorialCompleted;
  final int tutorialStepIndex;
  final int currentDay;
  final String playerName;
  final String dealershipName;
  final String logoEmblemId;
  final DateTime? lastRewardClaimDate;
  
  // Yeni Pasif Gelir ve Ekonomi Alanları
  final List<SideBusinessModel> sideBusinesses;
  final List<StockModel> marketStocks;
  final List<PlayerStockModel> ownedStocks;
  final List<GameEventModel> recentEvents;
  final double dailyTaxRate;

  DateTime get inGameTime => DateTime.now();

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
    this.salesHistory = const [],
    this.activeCheques = const [],
    this.activeInstallments = const [],
    this.activeRentals = const [],
    this.tutorialCompleted = false,
    this.tutorialStepIndex = 0,
    this.currentDay = 1,
    this.playerName = 'Kaptan',
    this.dealershipName = 'Miras Oto Galeri',
    this.logoEmblemId = 'crown',
    this.lastRewardClaimDate,
    this.sideBusinesses = const [],
    this.marketStocks = const [],
    this.ownedStocks = const [],
    this.recentEvents = const [],
    this.dailyTaxRate = 150.0,
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
      activeCheques: const [],
      activeInstallments: const [],
      activeRentals: const [],
      salesHistory: [
        SaleRecordModel(
          id: 'sale_init_1',
          carTitle: '1998 Tofaş Şahin 1.6 ie',
          buyerName: 'Ahmet Yılmaz',
          purchasePrice: 95000.0,
          salePrice: 135000.0,
          netProfit: 40000.0,
          saleDay: 0,
          saleDate: DateTime.now().subtract(const Duration(days: 2)),
        ),
        SaleRecordModel(
          id: 'sale_init_2',
          carTitle: '2004 Renault Toros Wagon',
          buyerName: 'Mehmet Kaya',
          purchasePrice: 110000.0,
          salePrice: 148000.0,
          netProfit: 38000.0,
          saleDay: 0,
          saleDate: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
      tutorialCompleted: false,
      tutorialStepIndex: 0,
      sideBusinesses: [
        SideBusinessModel(id: 'sb_1', name: 'Otomat Makinesi', description: 'Galeriye otomat makinesi kurarak günlük pasif gelir elde et.', type: SideBusinessType.vendingMachine, dailyIncome: 150.0, cost: 5000.0),
        SideBusinessModel(id: 'sb_2', name: 'Oto Yıkama', description: 'Küçük bir oto yıkama alanı kurarak ekstra gelir sağla.', type: SideBusinessType.carWash, dailyIncome: 500.0, cost: 25000.0),
        SideBusinessModel(id: 'sb_3', name: 'Reklam Panosu', description: 'Galerinin önüne reklam panosu al.', type: SideBusinessType.billboard, dailyIncome: 1000.0, cost: 75000.0),
        SideBusinessModel(id: 'sb_4', name: 'Çekici Hizmeti', description: 'Bir çekici alarak yolda kalanlara hizmet ver.', type: SideBusinessType.towTruck, dailyIncome: 2500.0, cost: 150000.0),
      ],
      marketStocks: [
        StockModel(symbol: 'TOF', name: 'Tof-AŞ Otomotiv', currentPrice: 15.4, previousPrice: 15.0),
        StockModel(symbol: 'FOR', name: 'For-D Motor', currentPrice: 85.2, previousPrice: 84.5),
        StockModel(symbol: 'RNO', name: 'Reno-L', currentPrice: 42.1, previousPrice: 43.0),
      ],
      ownedStocks: const [],
      recentEvents: const [],
      dailyTaxRate: 150.0,
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
      'salesHistory': salesHistory.map((s) => s.toJson()).toList(),
      'activeCheques': activeCheques.map((c) => c.toJson()).toList(),
      'activeInstallments': activeInstallments.map((i) => i.toJson()).toList(),
      'activeRentals': activeRentals.map((r) => r.toJson()).toList(),
      'tutorialCompleted': tutorialCompleted,
      'tutorialStepIndex': tutorialStepIndex,
      'currentDay': currentDay,
      'playerName': playerName,
      'dealershipName': dealershipName,
      'logoEmblemId': logoEmblemId,
      'lastRewardClaimDate': lastRewardClaimDate?.toIso8601String(),
      'sideBusinesses': sideBusinesses.map((e) => e.toJson()).toList(),
      'marketStocks': marketStocks.map((e) => e.toJson()).toList(),
      'ownedStocks': ownedStocks.map((e) => e.toJson()).toList(),
      'recentEvents': recentEvents.map((e) => e.toJson()).toList(),
      'dailyTaxRate': dailyTaxRate,
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
      salesHistory: (json['salesHistory'] as List<dynamic>?)
              ?.map((s) => SaleRecordModel.fromJson(s as Map<String, dynamic>))
              .toList() ??
          const [],
      activeCheques: (json['activeCheques'] as List<dynamic>?)
              ?.map((c) => Cheque.fromJson(c as Map<String, dynamic>))
              .toList() ??
          const [],
      activeInstallments: (json['activeInstallments'] as List<dynamic>?)
              ?.map((i) => InstallmentContract.fromJson(i as Map<String, dynamic>))
              .toList() ??
          const [],
      activeRentals: (json['activeRentals'] as List<dynamic>?)
              ?.map((r) => RentalAgreement.fromJson(r as Map<String, dynamic>))
              .toList() ??
          const [],
      tutorialCompleted: json['tutorialCompleted'] as bool? ?? false,
      tutorialStepIndex: json['tutorialStepIndex'] as int? ?? 0,
      currentDay: json['currentDay'] as int? ?? 1,
      playerName: json['playerName'] as String? ?? 'Kaptan',
      dealershipName: json['dealershipName'] as String? ?? 'Miras Oto Galeri',
      logoEmblemId: json['logoEmblemId'] as String? ?? 'crown',
      lastRewardClaimDate: json['lastRewardClaimDate'] != null ? DateTime.tryParse(json['lastRewardClaimDate'] as String) : null,
      sideBusinesses: (json['sideBusinesses'] as List<dynamic>?)
              ?.map((e) => SideBusinessModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      marketStocks: (json['marketStocks'] as List<dynamic>?)
              ?.map((e) => StockModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          DealershipModel.initial().marketStocks,
      ownedStocks: (json['ownedStocks'] as List<dynamic>?)
              ?.map((e) => PlayerStockModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      recentEvents: (json['recentEvents'] as List<dynamic>?)
              ?.map((e) => GameEventModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      dailyTaxRate: (json['dailyTaxRate'] as num?)?.toDouble() ?? 150.0,
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
    List<SaleRecordModel>? salesHistory,
    List<Cheque>? activeCheques,
    List<InstallmentContract>? activeInstallments,
    List<RentalAgreement>? activeRentals,
    bool? tutorialCompleted,
    int? tutorialStepIndex,
    int? currentDay,
    String? playerName,
    String? dealershipName,
    String? logoEmblemId,
    DateTime? lastRewardClaimDate,
    List<SideBusinessModel>? sideBusinesses,
    List<StockModel>? marketStocks,
    List<PlayerStockModel>? ownedStocks,
    List<GameEventModel>? recentEvents,
    double? dailyTaxRate,
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
      salesHistory: salesHistory ?? this.salesHistory,
      activeCheques: activeCheques ?? this.activeCheques,
      activeInstallments: activeInstallments ?? this.activeInstallments,
      activeRentals: activeRentals ?? this.activeRentals,
      tutorialCompleted: tutorialCompleted ?? this.tutorialCompleted,
      tutorialStepIndex: tutorialStepIndex ?? this.tutorialStepIndex,
      currentDay: currentDay ?? this.currentDay,
      playerName: playerName ?? this.playerName,
      dealershipName: dealershipName ?? this.dealershipName,
      logoEmblemId: logoEmblemId ?? this.logoEmblemId,
      lastRewardClaimDate: lastRewardClaimDate ?? this.lastRewardClaimDate,
      sideBusinesses: sideBusinesses ?? this.sideBusinesses,
      marketStocks: marketStocks ?? this.marketStocks,
      ownedStocks: ownedStocks ?? this.ownedStocks,
      recentEvents: recentEvents ?? this.recentEvents,
      dailyTaxRate: dailyTaxRate ?? this.dailyTaxRate,
    );
  }
}
