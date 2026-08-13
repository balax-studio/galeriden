import '../../../data/models/car_model.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/customer_review_model.dart';
import '../../../data/models/offer_model.dart';
import '../../../data/models/part_order_model.dart';
import '../../../data/models/player_skills.dart';
import '../../../data/models/player_achievements.dart';
import '../../../data/models/sale_record_model.dart';
import '../../../data/models/side_business_model.dart';
import '../../../data/models/cheque_model.dart';
import '../../../data/models/installment_contract_model.dart';
import '../../../data/models/stock_model.dart';
import '../../../data/models/mission_model.dart';
import '../../../domain/usecases/negotiation_engine.dart';
import '../../../domain/usecases/repair_engine.dart';
import 'game_base_notifier.dart';

mixin GameMarketMixin on GameBaseNotifier {
  /// Buy a side business
  bool buySideBusiness(String businessId) {
    final businessIndex = state.sideBusinesses.indexWhere((b) => b.id == businessId);
    if (businessIndex == -1) return false;

    final business = state.sideBusinesses[businessIndex];
    if (business.isOwned) return false;
    if (state.balance < business.cost) return false;

    final updatedBusinesses = List<SideBusinessModel>.from(state.sideBusinesses);
    updatedBusinesses[businessIndex] = business.copyWith(isOwned: true);

    state = state.copyWith(
      balance: state.balance - business.cost,
      sideBusinesses: updatedBusinesses,
    );
    
    addXP(150); 
    saveState();
    return true;
  }

  /// Upgrade a side business
  bool upgradeSideBusiness(String businessId) {
    final businessIndex = state.sideBusinesses.indexWhere((b) => b.id == businessId);
    if (businessIndex == -1) return false;

    final business = state.sideBusinesses[businessIndex];
    if (!business.isOwned) return false;
    
    double upgradeCost = business.cost * 0.5 * business.level;
    if (state.balance < upgradeCost) return false;

    final updatedBusinesses = List<SideBusinessModel>.from(state.sideBusinesses);
    updatedBusinesses[businessIndex] = business.copyWith(
      level: business.level + 1,
      dailyIncome: business.dailyIncome * 1.5,
    );

    state = state.copyWith(
      balance: state.balance - upgradeCost,
      sideBusinesses: updatedBusinesses,
    );
    
    addXP(50);
    saveState();
    return true;
  }

  /// Buy stocks
  bool buyStock(String symbol, int amount) {
    final stock = state.marketStocks.firstWhere((s) => s.symbol == symbol, orElse: () => throw Exception('Hisse bulunamadı'));
    double totalCost = stock.currentPrice * amount;
    
    if (state.balance < totalCost) return false;

    List<PlayerStockModel> updatedOwned = List.from(state.ownedStocks);
    final existingIndex = updatedOwned.indexWhere((s) => s.symbol == symbol);
    
    if (existingIndex != -1) {
      final existing = updatedOwned[existingIndex];
      double totalSpent = (existing.averageCost * existing.quantity) + totalCost;
      int newShares = existing.quantity + amount;
      double newAvgPrice = totalSpent / newShares;
      
      updatedOwned[existingIndex] = existing.copyWith(
        quantity: newShares,
        averageCost: newAvgPrice,
      );
    } else {
      updatedOwned.add(PlayerStockModel(
        symbol: symbol,
        quantity: amount,
        averageCost: stock.currentPrice,
      ));
    }

    state = state.copyWith(
      balance: state.balance - totalCost,
      ownedStocks: updatedOwned,
    );
    
    addXP(10);
    saveState();
    return true;
  }

  /// Sell stocks
  bool sellStock(String symbol, int amount) {
    List<PlayerStockModel> updatedOwned = List.from(state.ownedStocks);
    final existingIndex = updatedOwned.indexWhere((s) => s.symbol == symbol);
    
    if (existingIndex == -1) return false;
    
    final existing = updatedOwned[existingIndex];
    if (existing.quantity < amount) return false;
    
    final stock = state.marketStocks.firstWhere((s) => s.symbol == symbol);
    double revenue = stock.currentPrice * amount;

    if (existing.quantity == amount) {
      updatedOwned.removeAt(existingIndex);
    } else {
      updatedOwned[existingIndex] = existing.copyWith(
        quantity: existing.quantity - amount,
      );
    }

    state = state.copyWith(
      balance: state.balance + revenue,
      ownedStocks: updatedOwned,
    );
    
    addXP(10);
    saveState();
    return true;
  }

  /// Boost Listing Doping
  bool boostListingDoping(String carId) {
    const cost = 2500.0;
    if (state.balance < cost) return false;

    final car = state.ownedCars.firstWhere((c) => c.id == carId, orElse: () => throw Exception('Car not found'));
    
    state = state.copyWith(balance: state.balance - cost);
    addXP(15);
    saveState();

    final delay1 = 3 + random.nextInt(3);
    final delay2 = 6 + random.nextInt(4);

    Future.delayed(Duration(seconds: delay1), () {
      if (!mounted || !state.ownedCars.any((c) => c.id == car.id)) return;
      final newOffer1 = NegotiationEngine.generateBuyerOffer(car, car.estimatedRealValue * 1.05);
      state = state.copyWith(incomingOffers: [...state.incomingOffers, newOffer1]);
      saveState();
    });

    Future.delayed(Duration(seconds: delay2), () {
      if (!mounted || !state.ownedCars.any((c) => c.id == car.id)) return;
      final newOffer2 = NegotiationEngine.generateBuyerOffer(car, car.estimatedRealValue * 1.05);
      state = state.copyWith(incomingOffers: [...state.incomingOffers, newOffer2]);
      saveState();
    });

    return true;
  }

  /// Organic buyer offers trigger over time even WITHOUT paid doping
  @override
  void triggerOrganicOffers() {
    if (state.ownedCars.isEmpty) return;
    
    // Sadece üzerinde 2'den az aktif teklif olan araçlara organik teklif gelsin
    final eligibleCars = state.ownedCars.where((car) {
       int activeOffers = state.incomingOffers.where((o) => o.carId == car.id && !o.isExpired).length;
       return activeOffers < 2; 
    }).toList();

    if (eligibleCars.isEmpty) return;

    final randomCar = eligibleCars[random.nextInt(eligibleCars.length)];
    final offer = NegotiationEngine.generateBuyerOffer(randomCar, randomCar.estimatedRealValue);
    state = state.copyWith(incomingOffers: [...state.incomingOffers, offer]);
    saveState();
  }

  /// Accept offer with fraud inspection evaluation
  FraudInspectionResult? acceptOfferWithFraudCheck(OfferModel offer, CustomerModel customer) {
    final carIndex = state.ownedCars.indexWhere((c) => c.id == offer.carId);
    if (carIndex == -1) return null;

    final car = state.ownedCars[carIndex];
    final fraudResult = NegotiationEngine.evaluatePlayerFraudInspection(car: car, customer: customer);

    if (fraudResult.caughtFraud) {
      final newBalance = (state.balance - fraudResult.fineAmount).clamp(0.0, double.infinity);
      final newReputation = (state.reputationScore - fraudResult.reputationPenalty).clamp(0, 100);
      final updatedOffers = state.incomingOffers.where((o) => o.id != offer.id).toList();

      state = state.copyWith(
        balance: newBalance,
        reputationScore: newReputation,
        incomingOffers: updatedOffers,
      );
      saveState();
      return fraudResult;
    }

    acceptOffer(offer);
    return fraudResult;
  }

  /// Accept an offer and sell car
  void acceptOffer(OfferModel offer) {
    final carIndex = state.ownedCars.indexWhere((c) => c.id == offer.carId);
    if (carIndex == -1) return;

    final car = state.ownedCars[carIndex];
    final profit = offer.offeredAmount - car.currentPurchasePrice;

    final updatedCars = state.ownedCars.where((c) => c.id != car.id).toList();
    final updatedOffers = state.incomingOffers.where((o) => o.carId != car.id).toList();
    final updatedPendingOrders = state.pendingOrders.where((o) => o.carId != car.id).toList();

    int newCarsSold = state.carsSold + 1;

    final record = SaleRecordModel(
      id: 'sale_${DateTime.now().millisecondsSinceEpoch}',
      carTitle: '${car.modelYear} ${car.brand} ${car.modelName}',
      buyerName: offer.buyerName,
      purchasePrice: car.currentPurchasePrice,
      salePrice: offer.offeredAmount,
      netProfit: profit,
      saleDay: state.currentDay,
      saleDate: DateTime.now(),
    );

    double cashReceived = 0.0;
    List<Cheque> updatedCheques = List.from(state.activeCheques);
    List<InstallmentContract> updatedInstallments = List.from(state.activeInstallments);

    if (offer.offerType == OfferType.cash) {
      cashReceived = offer.offeredAmount;
    } else if (offer.offerType == OfferType.cheque) {
      updatedCheques.add(Cheque(
        id: 'cheque_${DateTime.now().millisecondsSinceEpoch}',
        customerName: offer.buyerName,
        amount: offer.offeredAmount,
        daysUntilDue: 30,
      ));
    } else if (offer.offerType == OfferType.installment) {
      updatedInstallments.add(InstallmentContract(
        id: 'inst_${DateTime.now().millisecondsSinceEpoch}',
        customerName: offer.buyerName,
        totalAmount: offer.offeredAmount,
        paidAmount: 0.0,
        installmentAmount: offer.offeredAmount / 5,
        totalInstallments: 5,
        paidInstallments: 0,
        daysUntilNextPayment: 30,
      ));
    }

    state = state.copyWith(
      balance: state.balance + cashReceived,
      ownedCars: updatedCars,
      incomingOffers: updatedOffers,
      pendingOrders: updatedPendingOrders,
      activeCheques: updatedCheques,
      activeInstallments: updatedInstallments,
      totalProfit: state.totalProfit + profit,
      carsSold: newCarsSold,
      salesHistory: [record, ...state.salesHistory],
    );

    addXP(100 + (profit > 0 ? (profit / 1000).round() : 0));
    checkAchievement('first_sale');
    updateMissionProgress(MissionType.sellCars, 1);
    if (profit > 0) {
      updateMissionProgress(MissionType.earnProfit, profit.round());
    }
    if (state.totalProfit >= 250000) checkAchievement('dealer_baron');

    if (!state.tutorialCompleted) {
      completeTutorial();
    }

    saveState();
  }

  /// Reject an offer
  void rejectOffer(String offerId) {
    final updatedOffers = state.incomingOffers.where((o) => o.id != offerId).toList();
    state = state.copyWith(incomingOffers: updatedOffers);
    saveState();
  }

  /// Add a new offer
  void addOffer(OfferModel offer) {
    state = state.copyWith(incomingOffers: [...state.incomingOffers, offer]);
    saveState();
  }

  /// Counter offer
  NegotiationOutcome counterOffer(String offerId, double playerTargetPrice) {
    final offerIndex = state.incomingOffers.indexWhere((o) => o.id == offerId);
    if (offerIndex == -1) {
      throw Exception('Teklif bulunamadı');
    }

    final offer = state.incomingOffers[offerIndex];
    final carIndex = state.ownedCars.indexWhere((c) => c.id == offer.carId);
    if (carIndex == -1) {
      throw Exception('Araç bulunamadı');
    }

    final car = state.ownedCars[carIndex];
    final outcome = NegotiationEngine.evaluateCounterOffer(
      currentOffer: offer,
      playerTargetPrice: playerTargetPrice,
      car: car,
      negotiationSkillLevel: state.skills.negotiationLevel,
    );

    List<OfferModel> updatedOffers = List.from(state.incomingOffers);
    if (outcome.isWalkaway) {
      updatedOffers.removeAt(offerIndex);
    } else {
      updatedOffers[offerIndex] = outcome.updatedOffer;
    }

    state = state.copyWith(incomingOffers: updatedOffers);
    saveState();
    return outcome;
  }

  /// Place a part order
  bool orderPart({
    required String carId,
    required String partName,
    required OrderType orderType,
    required double cost,
    required int deliveryDurationSeconds,
  }) {
    if (state.balance < cost) return false;

    final newOrder = PartOrderModel(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      carId: carId,
      partName: partName,
      orderType: orderType,
      cost: cost,
      orderedAt: DateTime.now(),
      deliveryDurationSeconds: deliveryDurationSeconds,
    );

    final updatedOrders = List<PartOrderModel>.from(state.pendingOrders)..add(newOrder);

    state = state.copyWith(
      balance: state.balance - cost,
      pendingOrders: updatedOrders,
    );
    saveState();
    return true;
  }

  /// Instant repair
  bool instantRepair({
    required String carId,
    required String partName,
    required OrderType orderType,
    required double cost,
  }) {
    if (state.balance < cost) return false;

    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    final restoredCar = RepairEngine.applyInstalledPart(car, partName, orderType);

    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = restoredCar;

    state = state.copyWith(
      balance: state.balance - cost,
      ownedCars: updatedCars,
    );
    saveState();
    return true;
  }

  /// Install delivered part
  bool installDeliveredPart(String orderId) {
    final orderIndex = state.pendingOrders.indexWhere((o) => o.id == orderId);
    if (orderIndex == -1) return false;

    final order = state.pendingOrders[orderIndex];
    if (!order.isDelivered) return false;

    final carIndex = state.ownedCars.indexWhere((c) => c.id == order.carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    final restoredCar = RepairEngine.applyInstalledPart(car, order.partName, order.orderType);

    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = restoredCar;

    final updatedOrders = List<PartOrderModel>.from(state.pendingOrders)..removeAt(orderIndex);

    state = state.copyWith(
      ownedCars: updatedCars,
      pendingOrders: updatedOrders,
    );
    saveState();
    return true;
  }

  /// Claim Mission Reward
  bool claimMissionReward(String missionId) {
    final missionIndex = state.activeMissions.indexWhere((m) => m.id == missionId);
    if (missionIndex == -1) return false;

    final mission = state.activeMissions[missionIndex];
    if (mission.currentProgress < mission.targetGoal || mission.isCompleted) return false;

    final updatedMission = mission.copyWith(isCompleted: true);
    final updatedMissions = List<MissionModel>.from(state.activeMissions);
    updatedMissions[missionIndex] = updatedMission;

    state = state.copyWith(
      balance: state.balance + mission.rewardMoney,
      activeMissions: updatedMissions,
    );

    addXP(mission.rewardXP);
    saveState();
    return true;
  }

  /// Upgrade player skill
  bool upgradeSkill(String skillName) {
    final skills = state.skills;
    if (skills.availableSkillPoints <= 0) return false;

    PlayerSkills updated;
    switch (skillName) {
      case 'negotiation':
        if (skills.negotiationLevel >= 10) return false;
        updated = skills.copyWith(negotiationLevel: skills.negotiationLevel + 1);
        break;
      case 'eyeForDetail':
        if (skills.eyeForDetail >= 10) return false;
        updated = skills.copyWith(eyeForDetail: skills.eyeForDetail + 1);
        break;
      case 'marketSense':
        if (skills.marketSense >= 10) return false;
        updated = skills.copyWith(marketSense: skills.marketSense + 1);
        break;
      case 'reputation':
        if (skills.reputation >= 10) return false;
        updated = skills.copyWith(reputation: skills.reputation + 1);
        break;
      case 'financeSense':
        if (skills.financeSense >= 10) return false;
        updated = skills.copyWith(financeSense: skills.financeSense + 1);
        break;
      default:
        return false;
    }

    state = state.copyWith(skills: updated);
    saveState();
    return true;
  }

  /// Claim achievement reward
  bool claimAchievementReward(String achievementId) {
    final index = state.achievements.indexWhere((a) => a.id == achievementId);
    if (index == -1) return false;

    final achievement = state.achievements[index];
    if (!achievement.isUnlocked || achievement.isClaimed) return false;

    List<AchievementItem> updatedAchievements = List.from(state.achievements);
    updatedAchievements[index] = achievement.copyWith(isClaimed: true);

    final updatedSkills = state.skills.copyWith(
      xp: state.skills.xp + achievement.rewardXP,
      bonusSkillPoints: state.skills.bonusSkillPoints + achievement.rewardSkillPoints,
    );

    state = state.copyWith(
      balance: state.balance + achievement.rewardMoney,
      achievements: updatedAchievements,
      skills: updatedSkills,
      level: updatedSkills.currentLevel,
    );

    saveState();
    return true;
  }

  /// Add customer review upon sales
  void addCustomerReview(CustomerReviewModel review) {
    final newReputation = (state.reputationScore + (review.rating >= 4.0 ? 5 : -10)).clamp(0, 100);
    state = state.copyWith(
      customerReviews: [review, ...state.customerReviews],
      reputationScore: newReputation,
    );
    saveState();
  }
}
