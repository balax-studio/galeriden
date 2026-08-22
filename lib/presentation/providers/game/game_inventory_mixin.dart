import 'dart:math';
import '../../../core/constants/first_time_action_keys.dart';
import '../../../data/models/mega_systems_extensions_model.dart';
import '../../../data/models/cheque_model.dart';
import '../../../data/models/branch_model.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/contract_model.dart';
import '../../../data/models/dealership_model.dart';
import '../../../data/models/detailing_model.dart';
import '../../../data/models/expertise_model.dart';
import '../../../data/models/gossip_item_model.dart';
import '../../../data/models/mission_model.dart';
import '../../../data/models/rental_agreement_model.dart';
import '../../../data/models/scrapyard_model.dart';
import '../../../data/models/staff_model.dart';
import '../../../data/models/trade_in_offer_model.dart';
import '../../../data/models/workshop_job_model.dart';
import '../../../data/models/car_wash_job_model.dart';
import '../../../data/models/customer_review_model.dart';
import '../../../data/models/lifestyle_item_model.dart';
import '../../../data/models/pr_campaign_model.dart';
import '../../../domain/usecases/night_market_engine.dart';
import '../../../domain/usecases/repair_engine.dart';
import '../../../domain/usecases/risk_engine.dart';
import '../../../domain/usecases/smart_office_hook_engine.dart';
import 'game_base_notifier.dart';

mixin GameInventoryMixin on GameBaseNotifier {
  /// Fulfill a VIP Wanted Car Contract
  bool fulfillWantedCarContract(String contractId, String carId) {
    final contractIndex = state.activeContracts.indexWhere((c) => c.id == contractId);
    if (contractIndex == -1) return false;
    final contract = state.activeContracts[contractIndex];

    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;
    final car = state.ownedCars[carIndex];
    if (car.isRented || car.isLockedInShowcase || car.isConsignment) return false;

    // Validate requirements
    if (car.brand.toLowerCase() != contract.targetBrand.toLowerCase()) return false;
    if (contract.targetBodyType != null && car.bodyType != contract.targetBodyType) return false;
    if (car.modelYear < contract.minYear) return false;
    if (car.expertise.mileage > contract.maxMileage) return false;

    final totalPayout = contract.budget + contract.rewardBonus;
    final profit = totalPayout - car.currentPurchasePrice;

    final updatedCars = List<CarModel>.from(state.ownedCars)..removeAt(carIndex);
    final updatedContracts = List<WantedCarContract>.from(state.activeContracts)..removeAt(contractIndex);

    state = state.copyWith(
      balance: state.balance + totalPayout,
      totalProfit: state.totalProfit + profit,
      carsSold: state.carsSold + 1,
      ownedCars: updatedCars,
      activeContracts: updatedContracts,
    );

    addXP(200);
    checkAchievement('first_sale');
    checkAndAwardFirstTimeAction(FirstTimeActionKeys.firstCarSell);
    updateMissionProgress(MissionType.sellCars, 1);
    if (profit > 0) updateMissionProgress(MissionType.earnProfit, profit.toInt());
    saveState();
    return true;
  }
  /// Perform market expertise on a vehicle
  bool performMarketExpertise(double cost) {
    if (state.balance < cost) return false;
    state = state.copyWith(balance: state.balance - cost);
    adjustNpcRelationship('haydar_usta', 2);
    addXP(25);
    checkAchievement('expert_master');
    checkAndAwardFirstTimeAction(FirstTimeActionKeys.firstExpertise);
    updateMissionProgress(MissionType.doExpertise, 1);
    saveState();
    return true;
  }

  /// Purchase a car from market with RiskEngine check
  PurchaseRiskOutcome? buyCar(CarModel car, double purchasePrice, {bool isExpertiseCompleted = false}) {
    double finalPurchasePrice = purchasePrice;
    // Skill Perk: Pazarlık Gücü - negotiationMultiplier (up to 18% discount)
    if (state.skills.negotiationMultiplier > 0) {
      finalPurchasePrice *= (1.0 - state.skills.negotiationMultiplier);
    }
    // Origin Perk: Tüccar Torunu -%8 alım indirimi
    if (state.characterOrigin == CharacterOrigin.tuccarTorunu) {
      finalPurchasePrice *= 0.92;
    }
    // Specialization Perk: Pazar Kurdu (Trader) -%10 alım indirimi
    if (state.specializationPath == SpecializationPath.trader) {
      finalPurchasePrice *= 0.90;
    }

    if (state.balance < finalPurchasePrice) return null;
    if (state.ownedCars.length >= state.maxGarageSlots) return null;

    final updatedBalance = state.balance - finalPurchasePrice;
    
    PurchaseRiskOutcome outcome;
    if (!isExpertiseCompleted) {
      outcome = RiskEngine.evaluateUninspectedPurchaseRisk(car);
    } else {
      outcome = PurchaseRiskOutcome(
        isTrapped: false,
        title: 'Ekspertizli Alım',
        description: 'Ekspertiz raporu doğrultusunda güvenle satın alındı.',
        updatedCar: car,
      );
    }

    final logEntry = 'Gün ${state.currentDay}: Piyasadan ₺${finalPurchasePrice.round()} bedelle galeri stoklarına katıldı.';
    final purchasedCar = outcome.updatedCar.copyWith(
      currentPurchasePrice: finalPurchasePrice,
      provenanceLog: [...outcome.updatedCar.provenanceLog, logEntry],
    );
    final updatedCars = [...state.ownedCars, purchasedCar];
    final modelKey = '${purchasedCar.brand}_${purchasedCar.modelName}'.toLowerCase().replaceAll(' ', '_');
    final updatedAlbum = <String>{...state.discoveredCarModelIds, modelKey}.toList();

    state = state.copyWith(
      balance: updatedBalance,
      ownedCars: updatedCars,
      discoveredCarModelIds: updatedAlbum,
    );

    addXP(50);
    checkAchievement('first_buy');
    checkAndAwardFirstTimeAction(FirstTimeActionKeys.firstCarBuy);
    updateMissionProgress(MissionType.buyCars, 1);
    saveState();
    return outcome;
  }

  /// Toggle Showcase Lock for rare/classic vehicles (§1.5, §2.6)
  bool toggleShowcaseLock(String carId) {
    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    if (car.isRented) return false;

    final bool newLocked = !car.isLockedInShowcase;
    final updatedCar = car.copyWith(
      isLockedInShowcase: newLocked,
      clearListingPrice: newLocked ? true : false,
    );
    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    final updatedOffers = newLocked
        ? state.incomingOffers.where((o) => o.carId != carId).toList()
        : state.incomingOffers;

    int newRep = state.reputationScore;
    if (newLocked) {
      newRep = (state.reputationScore + 5).clamp(0, 1000);
      addXP(50);
    }

    state = state.copyWith(
      ownedCars: updatedCars,
      incomingOffers: updatedOffers,
      reputationScore: newRep,
    );
    saveState();
    return true;
  }

  /// Select permanent Specialization Path at level >= 4 (§2.2)
  bool chooseSpecialization(SpecializationPath path) {
    if (state.level < 4) return false;
    state = state.copyWith(specializationPath: path);
    addXP(200);
    saveState();
    return true;
  }

  /// Mutate NPC relationship by key (0 to 100) (§2.4)
  void adjustNpcRelationship(String npcId, int delta) {
    final current = state.npcRelationships[npcId] ?? 50;
    final newRelation = (current + delta).clamp(0, 100);
    final updated = Map<String, int>.from(state.npcRelationships);
    updated[npcId] = newRelation;
    state = state.copyWith(npcRelationships: updated);
    saveState();
  }

  /// Interactive NPC interaction (Tea, Job handover, Special Gift)
  bool interactWithNpc({
    required String npcId,
    required double cost,
    required int trustGain,
  }) {
    if (state.balance < cost) return false;
    final current = state.npcRelationships[npcId] ?? 50;
    final newRelation = (current + trustGain).clamp(0, 100);
    final updated = Map<String, int>.from(state.npcRelationships);
    updated[npcId] = newRelation;
    state = state.copyWith(
      balance: state.balance - cost,
      npcRelationships: updated,
    );
    addXP(trustGain * 3);
    saveState();
    return true;
  }

  /// Change character origin (§2.1)
  void setCharacterOrigin(CharacterOrigin origin) {
    state = state.copyWith(characterOrigin: origin);
    saveState();
  }

  /// Upgrade Prestige Branch Tier
  bool upgradePrestigeBranch(int targetTier) {
    double cost = 100000.0;
    int extraSlots = 1;
    String tierKey = 'property_tier_2';

    if (targetTier == 3) {
      cost = 350000.0;
      extraSlots = 2;
      tierKey = 'property_tier_3';
    } else if (targetTier == 4) {
      cost = 900000.0;
      extraSlots = 2;
      tierKey = 'property_tier_4';
    } else if (targetTier == 5) {
      cost = 2500000.0;
      extraSlots = 2;
      tierKey = 'property_tier_5';
    } else if (targetTier == 6) {
      cost = 6000000.0;
      extraSlots = 3;
      tierKey = 'property_tier_6';
    } else if (targetTier == 7) {
      cost = 14000000.0;
      extraSlots = 3;
      tierKey = 'property_tier_7';
    } else if (targetTier == 8) {
      cost = 30000000.0;
      extraSlots = 4;
      tierKey = 'property_tier_8';
    }

    if (state.balance < cost) return false;
    if (state.unlockedBuildings.contains(tierKey)) return false;

    final updatedBuildings = Set<String>.from(state.unlockedBuildings)..add(tierKey);

    state = state.copyWith(
      balance: state.balance - cost,
      maxGarageSlots: state.maxGarageSlots + extraSlots,
      unlockedBuildings: updatedBuildings,
    );

    addXP(500);
    saveState();
    return true;
  }

  /// Sell a car from garage
  bool sellCar(String carId, double sellingPrice) {
    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    if (car.isLockedInShowcase || car.isRented) return false;

    final isConsignment = car.isConsignment;
    final double profit;
    final double cashReceived;

    if (isConsignment) {
      final commRate = car.consignmentCommissionRate > 0 ? car.consignmentCommissionRate : 0.10;
      final commissionAmount = (sellingPrice * commRate).roundToDouble();
      profit = commissionAmount;
      cashReceived = commissionAmount;
    } else {
      profit = sellingPrice - car.currentPurchasePrice;
      cashReceived = sellingPrice;
    }

    final updatedCars = List<CarModel>.from(state.ownedCars)..removeAt(carIndex);
    
    state = state.copyWith(
      balance: state.balance + cashReceived,
      ownedCars: updatedCars,
      totalProfit: state.totalProfit + profit,
      carsSold: state.carsSold + 1,
    );

    addXP(100);
    checkAchievement('first_sale');
    updateMissionProgress(MissionType.sellCars, 1);
    saveState();
    return true;
  }

  /// Directly purchase a car
  bool buyCarDirectly(CarModel car, double price) {
    if (state.balance < price) return false;
    if (state.ownedCars.length >= state.maxGarageSlots) return false;
    final logEntry = 'Gün ${state.currentDay}: ₺${price.round()} bedelle doğrudan satın alındı.';
    final finalCar = car.copyWith(
      currentPurchasePrice: price,
      provenanceLog: [...car.provenanceLog, logEntry],
    );
    final modelKey = '${finalCar.brand}_${finalCar.modelName}'.toLowerCase().replaceAll(' ', '_');
    final updatedAlbum = <String>{...state.discoveredCarModelIds, modelKey}.toList();

    state = state.copyWith(
      balance: state.balance - price,
      ownedCars: [...state.ownedCars, finalCar],
      discoveredCarModelIds: updatedAlbum,
    );
    addXP(30);
    checkAchievement('first_buy');
    updateMissionProgress(MissionType.buyCars, 1);
    saveState();
    return true;
  }

  /// Expand Garage Slots
  bool expandGarageSlot(int newMaxSlots, double cost) {
    if (state.balance < cost) return false;
    state = state.copyWith(
      balance: state.balance - cost,
      maxGarageSlots: newMaxSlots,
    );
    addXP(100);
    checkAchievement('garage_expand');
    saveState();
    return true;
  }

  /// Purchase & Upgrade Branch (Dual-Gate: Level Requirement + Capital Investment)
  bool upgradeBranch(BranchModel branch) {
    if (state.balance < branch.requiredBalance) return false;
    if (state.level < branch.targetLevel) return false;

    final updatedBuildings = Set<String>.from(state.unlockedBuildings);
    if (branch.targetLevel >= 2) {
      updatedBuildings.addAll({
        'property_tier_2',
        '/car-wash',
        '/history',
      });
    }
    if (branch.targetLevel >= 3) {
      updatedBuildings.addAll({
        'property_tier_3',
        '/workshop',
        '/staff',
        '/staff-academy',
      });
    }
    if (branch.targetLevel >= 4) {
      updatedBuildings.addAll({
        'property_tier_4',
        '/tuning-studio',
        '/showroom-decor',
      });
    }
    if (branch.targetLevel >= 5) {
      updatedBuildings.addAll({
        'property_tier_5',
        '/auction',
        '/finance',
        '/reviews',
      });
    }
    if (branch.targetLevel >= 6) {
      updatedBuildings.addAll({
        'property_tier_6',
        '/bank-investments',
        '/stock-market',
      });
    }
    if (branch.targetLevel >= 7) {
      updatedBuildings.addAll({
        'property_tier_7',
        '/rent-a-car',
        '/black-market',
        '/district-market',
        '/districts',
        '/gossip-hotline',
        '/gossip',
      });
    }
    if (branch.targetLevel >= 8) {
      updatedBuildings.addAll({
        'property_tier_8',
        '/scrapyard',
        '/side-businesses',
        '/consignment-market',
        '/consignment',
        '/second-branch',
        '/vip-appointments',
        '/customs-import',
        '/guild-chamber',
        '/franchise',
        '/prestige-dynasty',
      });
    }

    state = state.copyWith(
      balance: state.balance - branch.requiredBalance,
      maxGarageSlots: branch.maxGarageSlots,
      unlockedBuildings: updatedBuildings,
    );
    addXP(250);
    checkAchievement('garage_expand');
    saveState();
    return true;
  }

  /// Purchase & Construct Showroom Architecture Decor Upgrade
  bool purchaseShowroomDecor({
    required String decorId,
    required double cost,
    required double reputationBonus,
  }) {
    if (state.unlockedDecorIds.contains(decorId)) return false; // Prevent duplicate purchase / spamming
    if (state.balance < cost) return false;

    final updatedDecors = [...state.unlockedDecorIds, decorId];
    final updatedReputation = (state.reputationScore + reputationBonus.toInt()).clamp(0, 1000);

    state = state.copyWith(
      balance: state.balance - cost,
      unlockedDecorIds: updatedDecors,
      reputationScore: updatedReputation,
    );

    addXP(150);
    saveState();
    return true;
  }

  /// Purchase Branch Property Deed (Tapu) to drop rent to ₺0 and boost credit limit
  bool buyBranchDeed(BranchModel branch) {
    if (state.ownedBranchDeeds.contains(branch.id)) return false;
    if (state.balance < branch.deedCost) return false;

    final updatedDeeds = {...state.ownedBranchDeeds, branch.id};
    final creditBoost = branch.deedCost * 0.35;
    final updatedReputation = (state.reputationScore + 40).clamp(0, 1000);

    state = state.copyWith(
      balance: state.balance - branch.deedCost,
      ownedBranchDeeds: updatedDeeds,
      bankCreditLimit: state.bankCreditLimit + creditBoost,
      reputationScore: updatedReputation,
    );

    addXP(300);
    saveState();
    return true;
  }

  /// Start Media & Influencer PR Agency Campaign
  bool startPrCampaign(PrCampaignModel campaign) {
    if (state.balance < campaign.cost) return false;

    final activeCampaign = ActivePrCampaign(
      campaignId: campaign.id,
      title: campaign.title,
      startDay: state.currentDay,
      endDay: state.currentDay + campaign.durationDays - 1,
      customerFlowMultiplier: campaign.customerFlowMultiplier,
      offerPriceBoost: campaign.offerPriceBoost,
      negotiationResistanceReduction: campaign.negotiationResistanceReduction,
    );

    final updatedReputation = (state.reputationScore + campaign.reputationReward).clamp(0, 1000);

    state = state.copyWith(
      balance: state.balance - campaign.cost,
      activePrCampaign: activeCampaign,
      reputationScore: updatedReputation,
    );

    addXP(100);
    saveState();
    return true;
  }

  /// Purchase Lifestyle Item (Suit, Watch/Tasbih, Executive Office Luxury)
  bool buyLifestyleItem(LifestyleItemModel item) {
    if (state.ownedLifestyleItems.contains(item.id)) return false;
    if (state.balance < item.price) return false;

    final updatedItems = {...state.ownedLifestyleItems, item.id};
    final updatedReputation = (state.reputationScore + item.reputationBonus).clamp(0, 1000);

    String? suit = state.equippedSuitId;
    String? acc = state.equippedAccessoryId;
    String? decor = state.equippedOfficeDecorId;

    if (item.category == 'suit') suit = item.id;
    if (item.category == 'accessory') acc = item.id;
    if (item.category == 'officeDecor') decor = item.id;

    state = state.copyWith(
      balance: state.balance - item.price,
      ownedLifestyleItems: updatedItems,
      equippedSuitId: suit,
      equippedAccessoryId: acc,
      equippedOfficeDecorId: decor,
      reputationScore: updatedReputation,
    );

    addXP(150);
    saveState();
    return true;
  }

  /// Equip an already owned Lifestyle item
  void equipLifestyleItem(LifestyleItemModel item) {
    if (!state.ownedLifestyleItems.contains(item.id)) return;

    if (item.category == 'suit') {
      state = state.copyWith(equippedSuitId: item.id);
    } else if (item.category == 'accessory') {
      state = state.copyWith(equippedAccessoryId: item.id);
    } else if (item.category == 'officeDecor') {
      state = state.copyWith(equippedOfficeDecorId: item.id);
    }
    saveState();
  }

  /// Apply detailing option
  bool applyDetailingOption(String carId, DetailingOption option) {
    if (state.balance < option.cost) return false;

    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    if (car.appliedDetailingOptionIds.contains(option.id)) return false;

    final updatedCar = car.copyWith(
      appliedDetailingOptionIds: [...car.appliedDetailingOptionIds, option.id],
    );

    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    state = state.copyWith(
      balance: state.balance - option.cost,
      ownedCars: updatedCars,
    );

    addXP(25);
    saveState();
    return true;
  }

  /// Perform detailing
  bool detailCleanCar(String carId) {
    const cost = RepairEngine.detailedCleanCost;
    if (state.balance < cost) return false;

    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    if (car.isDetailedCleaned) return false;

    final updatedCar = RepairEngine.performDetailing(car);
    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    state = state.copyWith(
      balance: state.balance - cost,
      ownedCars: updatedCars,
    );

    addXP(20);
    if (updatedCar.expertise.engineCondition == 100.0 && updatedCar.isDetailedCleaned) {
      checkAchievement('restoration_king');
    }
    saveState();
    return true;
  }

  /// Wash and Polish
  bool washAndPolishCar(String carId, {required bool wash, required bool polish}) {
    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    
    final bool willWash = wash && !car.isWashed;
    final bool willPolish = polish && !car.isPolished;
    
    if (!willWash && !willPolish) return false;

    final cost = (willWash ? 300.0 : 0.0) + (willPolish ? 800.0 : 0.0);
    if (state.balance < cost) return false;

    final updatedCar = car.copyWith(
      isWashed: willWash ? true : car.isWashed,
      isPolished: willPolish ? true : car.isPolished,
    );

    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    state = state.copyWith(
      balance: state.balance - cost,
      ownedCars: updatedCars,
    );

    addXP(15);
    checkAndAwardFirstTimeAction(FirstTimeActionKeys.firstCarWash);
    updateMissionProgress(MissionType.washCars, 1);
    saveState();
    return true;
  }

  /// Update owned car after repair
  void updateOwnedCar(CarModel updatedCar, double cost) {
    if (state.balance < cost) return;

    final cars = state.ownedCars.map((c) {
      return c.id == updatedCar.id ? updatedCar : c;
    }).toList();

    state = state.copyWith(
      balance: state.balance - cost,
      ownedCars: cars,
    );

    addXP(15);
    checkAndAwardFirstTimeAction(FirstTimeActionKeys.firstPartRepair);
    updateMissionProgress(MissionType.repairParts, 1);
    if (updatedCar.expertise.engineCondition == 100.0 && updatedCar.isDetailedCleaned) {
      checkAchievement('restoration_king');
    }
    saveState();
  }

  /// Boosts district market share through local marketing campaign (§1.4 / Q8)
  bool boostDistrictMarketShare(String districtKey, double amount, double cost) {
    if (state.balance < cost) return false;

    final current = state.districtMarketShare[districtKey] ?? 0.0;
    if (current >= 1.0) return false;

    final updatedMap = Map<String, double>.from(state.districtMarketShare);
    updatedMap[districtKey] = (current + amount).clamp(0.0, 1.0);

    state = state.copyWith(
      balance: state.balance - cost,
      districtMarketShare: updatedMap,
    );

    addXP(10);
    saveState();
    return true;
  }

  /// Accepts a customer vehicle trade-in offer (§4.6.2)
  bool acceptTradeInOffer(TradeInOfferModel offer) {
    // Verify target car exists in owned inventory
    final targetIndex = state.ownedCars.indexWhere((c) => c.id == offer.targetCarId);
    if (targetIndex == -1) return false;

    final targetCar = state.ownedCars[targetIndex];
    if (targetCar.isLockedInShowcase || targetCar.isRented || targetCar.isConsignment) return false;
    // Block black market and hot cars from trade-in to prevent money laundering
    if (targetCar.isBlackMarket || targetCar.id.startsWith('bm_')) return false;

    // Check if player has enough money if cashDifference is negative
    if (offer.cashDifference < 0 && state.balance < -offer.cashDifference) {
      return false;
    }

    final updatedOwnedCars = List<CarModel>.from(state.ownedCars);
    updatedOwnedCars.removeAt(targetIndex);

    // Add provenance note to offered car
    final tradedCar = offer.offeredCar.copyWith(
      provenanceLog: [
        ...offer.offeredCar.provenanceLog,
        '${state.currentDay}. Gün: ${targetCar.modelName} karşılığı ${offer.customerName} ile takaslandı.',
      ],
    );
    updatedOwnedCars.add(tradedCar);

    // Remove accepted trade offer from pending offers
    final updatedTradeOffers = state.incomingTradeInOffers.where((t) => t.id != offer.id).toList();
    // Remove purchase offers for the target car
    final updatedOffers = state.incomingOffers.where((o) => o.carId != targetCar.id).toList();

    // Calculate profit
    final effectiveSalePrice = tradedCar.estimatedRealValue + offer.cashDifference;
    final netProfit = effectiveSalePrice - targetCar.currentPurchasePrice;

    state = state.copyWith(
      balance: state.balance + offer.cashDifference,
      ownedCars: updatedOwnedCars,
      incomingOffers: updatedOffers,
      incomingTradeInOffers: updatedTradeOffers,
      totalProfit: state.totalProfit + (netProfit > 0 ? netProfit : 0),
      carsSold: state.carsSold + 1,
      cleanSaleStreak: state.cleanSaleStreak + 1,
    );

    addXP(35);
    updateMissionProgress(MissionType.sellCars, 1);
    saveState();
    return true;
  }

  /// Rejects a trade-in offer
  void rejectTradeInOffer(String offerId) {
    final updatedOffers = state.incomingTradeInOffers.where((t) => t.id != offerId).toList();
    state = state.copyWith(incomingTradeInOffers: updatedOffers);
    saveState();
  }

  /// Buys an industry gossip / asymmetric intel item (§4.6.3)
  bool buyGossipItem(GossipItemModel gossip) {
    final npcKey = gossip.sourceNpc == 'cayci_necati' ? 'necati' : gossip.sourceNpc;
    final isDost = state.hasHighNpcTrust(npcKey);
    final effectiveCost = isDost ? (gossip.cost * 0.50).roundToDouble() : gossip.cost;
    if (state.balance < effectiveCost) return false;

    final updatedGossips = state.activeGossips.map((g) {
      if (g.id == gossip.id) {
        return g.copyWith(isPurchased: true);
      }
      return g;
    }).toList();

    state = state.copyWith(
      balance: state.balance - effectiveCost,
      activeGossips: updatedGossips,
    );

    adjustNpcRelationship(npcKey, 3);
    addXP(15);
    saveState();
    return true;
  }

  /// Accepts a consignment vehicle offer from an NPC (§4.6.1)
  bool acceptConsignmentOffer(CarModel consignmentCar) {
    if (state.ownedCars.length >= state.maxGarageSlots) return false;

    final updatedOwnedCars = List<CarModel>.from(state.ownedCars)..add(consignmentCar);
    final updatedConsignmentOffers = state.consignmentOffers.where((c) => c.id != consignmentCar.id).toList();

    state = state.copyWith(
      ownedCars: updatedOwnedCars,
      consignmentOffers: updatedConsignmentOffers,
    );

    addXP(20);
    saveState();
    return true;
  }

  /// Enters an underground night modification street race (§4.4)
  NightRaceResult enterNightRace(CarModel car, {NightRivalModel? rival}) {
    final activeRival = rival ?? NightMarketEngine.getMatchedRival(car);
    final entryFee = NightMarketEngine.getEntryFeeForRival(activeRival);
    if (state.dailyRacesRemaining <= 0) {
      return const NightRaceResult(
        isWon: false,
        prizeMoney: 0,
        reputationBonus: 0,
        raceSummary: 'Bugünkü tüm 3 yarış hakkınızı kullandınız! Gece yarışları yarın tekrar açılacak.',
        rivalName: 'Yarış Hakemleri',
        rivalCarName: 'Pist Kapalı',
      );
    }

    if (state.balance < entryFee) {
      return NightRaceResult(
        isWon: false,
        prizeMoney: 0,
        reputationBonus: 0,
        raceSummary: 'Bu yarışa katılmak için ₺${entryFee.toInt()} giriş bahsi gereklidir!',
        rivalName: 'Bahis Masası',
        rivalCarName: 'Kasa Yetersiz',
      );
    }

    if (car.expertise.engineCondition < 30) {
      return const NightRaceResult(
        isWon: false,
        prizeMoney: 0,
        reputationBonus: 0,
        raceSummary: 'Motor sağlığı %30 altında olan yıpranmış araçlar piste çıkarılamaz!',
        rivalName: 'Pist Güvenliği',
        rivalCarName: 'Mekanik İptal',
      );
    }

    // 1. Deduct entry fee and apply 8-12% engine & transmission wear
    final wearAmount = 8 + random.nextInt(5);
    final updatedExpertise = car.expertise.copyWith(
      engineCondition: (car.expertise.engineCondition - wearAmount).clamp(5, 100),
      transmissionCondition: (car.expertise.transmissionCondition - (wearAmount ~/ 2)).clamp(5, 100),
    );
    final updatedCar = car.copyWith(expertise: updatedExpertise);
    final updatedCars = state.ownedCars.map((c) => c.id == car.id ? updatedCar : c).toList();

    final result = NightMarketEngine.simulateNightRace(updatedCar, rival: activeRival);
    final remainingRaces = (state.dailyRacesRemaining - 1).clamp(0, 3);

    if (result.isWon) {
      state = state.copyWith(
        balance: state.balance - entryFee + result.prizeMoney,
        reputationScore: (state.reputationScore + result.reputationBonus).clamp(0, 1000),
        ownedCars: updatedCars,
        dailyRacesRemaining: remainingRaces,
      );
      addXP(50);
    } else {
      state = state.copyWith(
        balance: state.balance - entryFee,
        reputationScore: (state.reputationScore + result.reputationBonus).clamp(0, 1000),
        ownedCars: updatedCars,
        dailyRacesRemaining: remainingRaces,
      );
    }

    saveState();
    return result;
  }

  /// Repair body part with tier
  RepairResult repairBodyPartWithTier(CarModel car, String partName, RepairTier tier) {
    final result = RepairEngine.repairBodyPart(car, partName, tier);
    if (state.balance >= result.costPaid) {
      final updatedCars = state.ownedCars.map((c) => c.id == car.id ? result.updatedCar : c).toList();
      state = state.copyWith(
        balance: state.balance - result.costPaid,
        ownedCars: updatedCars,
      );
      if (result.isSuccess) {
        addXP(20);
        checkAndAwardFirstTimeAction(FirstTimeActionKeys.firstPartRepair);
        updateMissionProgress(MissionType.repairParts, 1);
      }
      saveState();
    }
    return result;
  }

  /// Repair Engine with tier
  RepairResult repairEngineWithTier(CarModel car, RepairTier tier) {
    final result = RepairEngine.repairEngine(car, tier);
    if (state.balance >= result.costPaid) {
      final updatedCars = state.ownedCars.map((c) => c.id == car.id ? result.updatedCar : c).toList();
      state = state.copyWith(
        balance: state.balance - result.costPaid,
        ownedCars: updatedCars,
      );
      if (result.isSuccess) {
        addXP(30);
        checkAndAwardFirstTimeAction(FirstTimeActionKeys.firstPartRepair);
        updateMissionProgress(MissionType.repairParts, 1);
      }
      saveState();
    }
    return result;
  }

  /// Repair Transmission with tier
  RepairResult repairTransmissionWithTier(CarModel car, RepairTier tier) {
    final result = RepairEngine.repairTransmission(car, tier);
    if (state.balance >= result.costPaid) {
      final updatedCars = state.ownedCars.map((c) => c.id == car.id ? result.updatedCar : c).toList();
      state = state.copyWith(
        balance: state.balance - result.costPaid,
        ownedCars: updatedCars,
      );
      if (result.isSuccess) {
        addXP(30);
        checkAndAwardFirstTimeAction(FirstTimeActionKeys.firstPartRepair);
        updateMissionProgress(MissionType.repairParts, 1);
      }
      saveState();
    }
    return result;
  }

  /// Updates car's listing declaration status
  void updateCarListingDeclaration(String carId, ListingDeclarationType declaration) {
    updateCarListingDetails(carId, declaration: declaration);
  }

  /// Updates only the listing price
  void updateCarListingPrice(String carId, double customPrice) {
    updateCarListingDetails(carId, customPrice: customPrice);
  }

  /// Updates car's custom listing price and/or declaration status
  void updateCarListingDetails(
    String carId, {
    double? customPrice,
    ListingDeclarationType? declaration,
    String? listingPhotoLocation,
    int? listingPhotoCount,
    String? listingTone,
    bool? hideDamagedPhotos,
    bool? allowsInstallments,
  }) {
    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return;

    final existing = state.ownedCars[carIndex];
    if (existing.isRented || existing.isLockedInShowcase) return;

    double photoCost = 0.0;
    if (listingPhotoLocation != null && listingPhotoLocation != existing.listingPhotoLocation) {
      if (listingPhotoLocation == 'studio') photoCost += 1500.0;
      if (listingPhotoLocation == 'scenic') photoCost += 800.0;
    }

    final updatedCar = existing.copyWith(
      customListingPrice: customPrice,
      declarationType: declaration ?? existing.declarationType,
      listingPhotoLocation: listingPhotoLocation ?? existing.listingPhotoLocation,
      listingPhotoCount: listingPhotoCount ?? existing.listingPhotoCount,
      listingTone: listingTone ?? existing.listingTone,
      hideDamagedPhotos: hideDamagedPhotos ?? existing.hideDamagedPhotos,
      allowsInstallments: allowsInstallments ?? existing.allowsInstallments,
    );
    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    state = state.copyWith(
      balance: (state.balance - photoCost).clamp(0.0, double.infinity),
      ownedCars: updatedCars,
    );
    saveState();
  }

  /// Toggle Hero / Vitrin Star Slot (+30% traffic)
  bool toggleHeroShowcase(String carId) {
    final index = state.ownedCars.indexWhere((c) => c.id == carId);
    if (index == -1) return false;

    final isCurrentlyHero = state.ownedCars[index].isHeroShowcase;
    final updatedCars = state.ownedCars.map((c) {
      if (c.id == carId) {
        return c.copyWith(isHeroShowcase: !isCurrentlyHero);
      } else {
        return c.isHeroShowcase ? c.copyWith(isHeroShowcase: false) : c;
      }
    }).toList();

    state = state.copyWith(ownedCars: updatedCars);
    saveState();
    return true;
  }

  /// Refresh stale listing to reset days listed and boost visibility
  bool refreshStaleListing(String carId) {
    const refreshCost = 1500.0;
    if (state.balance < refreshCost) return false;

    final index = state.ownedCars.indexWhere((c) => c.id == carId);
    if (index == -1) return false;

    final car = state.ownedCars[index];
    final updatedCar = car.copyWith(daysListed: 0);
    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[index] = updatedCar;

    state = state.copyWith(
      balance: state.balance - refreshCost,
      ownedCars: updatedCars,
    );
    saveState();
    return true;
  }

  /// Rent a Car with strict market rate validation, profile and insurance options
  bool rentCar(
    String carId,
    double dailyRate, {
    String renterType = 'individual',
    bool hasInsurance = false,
    String? renterName,
  }) {
    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;
    
    final car = state.ownedCars[carIndex];
    if (car.isRented || state.activeRentals.any((r) => r.carId == carId)) return false;

    // Cap daily rate to maximum rate
    final carValue = car.currentPurchasePrice > 0 ? car.currentPurchasePrice : car.estimatedRealValue;
    final maxRateMultiplier = renterType == 'young_driver' ? 0.016 : 0.012;
    final maxAllowedDailyRate = (carValue * maxRateMultiplier).clamp(100.0, 60000.0);
    final validatedDailyRate = dailyRate.clamp(100.0, maxAllowedDailyRate);

    // Kasko daily fee: 0.1% of car value (min 150 TL, max 1.500 TL)
    final insuranceDailyFee = hasInsurance ? (carValue * 0.001).clamp(150.0, 1500.0) : 0.0;

    String resolvedRenterName = renterName ?? '';
    if (resolvedRenterName.isEmpty) {
      if (renterType == 'corporate') {
        final corpNames = ['Anadolu Filo & Lojistik', 'Kuzey Holding A.Ş.', 'Mavi Bulut Danışmanlık', 'Atlas Medikal'];
        resolvedRenterName = corpNames[DateTime.now().millisecondsSinceEpoch % corpNames.length];
      } else if (renterType == 'young_driver') {
        final youngNames = ['Bora & Ceyda • Düğün', 'Gurbetçi Berkcan', 'Kürşat & Arkadaşları • Tatil', 'Cengiz • Hızlı Sürücü'];
        resolvedRenterName = youngNames[DateTime.now().millisecondsSinceEpoch % youngNames.length];
      } else {
        final indivNames = ['Av. Mehmet Bey', 'Mimar Sinan Bey', 'Doktor Ayşe Hanım', 'Öğretmen Kemal'];
        resolvedRenterName = indivNames[DateTime.now().millisecondsSinceEpoch % indivNames.length];
      }
    }

    final updatedCar = car.copyWith(
      isRented: true,
      clearListingPrice: true,
    );
    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    final updatedOffers = state.incomingOffers.where((o) => o.carId != carId).toList();

    final agreement = RentalAgreement(
      id: 'rent_${DateTime.now().millisecondsSinceEpoch}',
      carId: carId,
      dailyRate: validatedDailyRate,
      renterType: renterType,
      renterName: resolvedRenterName,
      hasInsurance: hasInsurance,
      insuranceDailyFee: insuranceDailyFee,
    );

    state = state.copyWith(
      ownedCars: updatedCars,
      incomingOffers: updatedOffers,
      activeRentals: [...state.activeRentals, agreement],
    );
    saveState();
    return true;
  }

  /// Return Rented Car (Self-healing: returns true and cleans up even if car was removed)
  bool returnRentedCar(String agreementId) {
    final rentalIndex = state.activeRentals.indexWhere((r) => r.id == agreementId);
    if (rentalIndex == -1) return false;

    final rental = state.activeRentals[rentalIndex];
    final updatedRentals = List<RentalAgreement>.from(state.activeRentals)..removeAt(rentalIndex);
    
    final carIndex = state.ownedCars.indexWhere((c) => c.id == rental.carId);
    if (carIndex != -1) {
      final updatedCar = state.ownedCars[carIndex].copyWith(isRented: false);
      final updatedCars = List<CarModel>.from(state.ownedCars);
      updatedCars[carIndex] = updatedCar;
      
      state = state.copyWith(
        ownedCars: updatedCars,
        activeRentals: updatedRentals,
      );
    } else {
      // Orphan agreement cleanup when car was sold/removed
      state = state.copyWith(activeRentals: updatedRentals);
    }
    saveState();
    return true;
  }

  /// Self-healing state sync: Ensures all ownedCars.isRented flags match activeRentals
  void syncRentalState() {
    final rentedCarIds = state.activeRentals.map((r) => r.carId).toSet();
    bool needsUpdate = false;

    final syncedCars = state.ownedCars.map((car) {
      final shouldBeRented = rentedCarIds.contains(car.id);
      if (car.isRented != shouldBeRented) {
        needsUpdate = true;
        return car.copyWith(isRented: shouldBeRented);
      }
      return car;
    }).toList();

    if (needsUpdate) {
      state = state.copyWith(ownedCars: syncedCars);
      saveState();
    }
  }

  /// Buys a scrap car from the scrapyard so player owns it and can dismantle parts or crush chassis
  bool buyScrapCar(String scrapCarId) {
    final scrapIndex = state.scrapyardCars.indexWhere((c) => c.id == scrapCarId);
    if (scrapIndex == -1) return false;

    final scrapCar = state.scrapyardCars[scrapIndex];
    if (scrapCar.isPurchased) return true;

    double effectivePrice = scrapCar.scrapPrice;
    if (state.hasHighNpcTrust('cikmaci_ibo')) {
      effectivePrice = (effectivePrice * 0.75).roundToDouble(); // Çıkmacı İbo dost indirimi -%25!
    }
    if (state.balance < effectivePrice) return false;

    final updatedScrapCar = scrapCar.copyWith(
      isPurchased: true,
      parts: scrapCar.parts.isNotEmpty
          ? scrapCar.parts
          : ScrapyardCar.generateRandomParts('${scrapCar.brand} ${scrapCar.modelName}', scrapCar.scrapPrice * 1.5),
    );
    final updatedScrapCars = List<ScrapyardCar>.from(state.scrapyardCars);
    updatedScrapCars[scrapIndex] = updatedScrapCar;

    state = state.copyWith(
      balance: state.balance - effectivePrice,
      scrapyardCars: updatedScrapCars,
    );

    adjustNpcRelationship('cikmaci_ibo', 2);
    addXP(40);
    saveState();
    return true;
  }

  /// Purchase and dismantle a scrap car into salvaged parts with realistic RNG loss risk
  BulkScrapDismantleResult buyAndDismantleScrapCar(String scrapCarId, {Random? random}) {
    final scrapIndex = state.scrapyardCars.indexWhere((c) => c.id == scrapCarId);
    if (scrapIndex == -1) {
      return const BulkScrapDismantleResult(
        success: false,
        message: 'Hurda araç bulunamadı.',
      );
    }

    final scrapCar = state.scrapyardCars[scrapIndex];
    double effectivePrice = scrapCar.scrapPrice;
    if (state.hasHighNpcTrust('cikmaci_ibo')) {
      effectivePrice = (effectivePrice * 0.75).roundToDouble(); // Çıkmacı İbo dost indirimi -%25!
    }
    if (state.balance < effectivePrice) {
      return const BulkScrapDismantleResult(
        success: false,
        message: 'Yetersiz bakiye.',
      );
    }

    final allParts = scrapCar.parts.isNotEmpty
        ? scrapCar.parts
        : ScrapyardCar.generateRandomParts('${scrapCar.brand} ${scrapCar.modelName}', scrapCar.scrapPrice * 1.5);

    final rng = random ?? Random();
    final salvagedList = <SalvagedPart>[];
    final lostList = <SalvagedPart>[];

    // %75 chance of intact extraction, %25 risk of part getting crushed/lost in fast disassembly
    for (final part in allParts) {
      if (rng.nextDouble() < 0.75) {
        salvagedList.add(part);
      } else {
        lostList.add(part);
      }
    }

    // Ensure at least 1 part is salvaged if parts were available
    if (salvagedList.isEmpty && lostList.isNotEmpty) {
      salvagedList.add(lostList.removeLast());
    }

    final updatedScrapCars = List<ScrapyardCar>.from(state.scrapyardCars)..removeAt(scrapIndex);

    state = state.copyWith(
      balance: state.balance - effectivePrice,
      salvagedParts: [...state.salvagedParts, ...salvagedList],
      scrapyardCars: updatedScrapCars,
    );

    adjustNpcRelationship('cikmaci_ibo', 2);
    addXP(60);
    checkAchievement('first_scrap');
    saveState();

    return BulkScrapDismantleResult(
      success: true,
      totalPartsCount: allParts.length,
      salvagedCount: salvagedList.length,
      lostCount: lostList.length,
      salvagedParts: salvagedList,
      lostParts: lostList,
      costPaid: effectivePrice,
      message: lostList.isEmpty
          ? '${scrapCar.brand} ${scrapCar.modelName} satın alındı ve tüm parçaları depoya aktarıldı!'
          : 'Hurda araç söküldü! ${salvagedList.length} parça kurtarıldı • ${lostList.length} parça sökümde ziyan oldu.',
    );
  }

  /// Dismantle a single specific part from a scrap car with %85 extraction success dice roll or mini game result
  SinglePartDismantleResult dismantleSinglePartFromScrap(
    String scrapCarId,
    String partId, {
    Random? random,
    bool? forceSuccess,
    int? customCondition,
  }) {
    final scrapIndex = state.scrapyardCars.indexWhere((c) => c.id == scrapCarId);
    if (scrapIndex == -1) {
      return const SinglePartDismantleResult(
        success: false,
        isSalvaged: false,
        message: 'Hurda araç bulunamadı.',
      );
    }

    final scrapCar = state.scrapyardCars[scrapIndex];
    if (!scrapCar.isPurchased) {
      return const SinglePartDismantleResult(
        success: false,
        isSalvaged: false,
        message: 'Parça sökebilmek için önce hurda aracı satın almalısınız.',
      );
    }
    final partIndex = scrapCar.parts.indexWhere((p) => p.id == partId);
    if (partIndex == -1) {
      return const SinglePartDismantleResult(
        success: false,
        isSalvaged: false,
        message: 'Parça bulunamadı veya zaten sökülmüş.',
      );
    }

    final originalPart = scrapCar.parts[partIndex];
    final part = customCondition != null ? originalPart.copyWith(conditionPercent: customCondition) : originalPart;
    final updatedParts = List<SalvagedPart>.from(scrapCar.parts)..removeAt(partIndex);
    final updatedScrapCar = scrapCar.copyWith(parts: updatedParts);

    final updatedScrapCars = List<ScrapyardCar>.from(state.scrapyardCars);
    updatedScrapCars[scrapIndex] = updatedScrapCar;

    final rng = random ?? Random();
    // %85 success rate on quick dismantle, or deterministic result from mini-game
    final isSuccess = forceSuccess ?? (rng.nextDouble() < 0.85);

    if (isSuccess) {
      state = state.copyWith(
        salvagedParts: [...state.salvagedParts, part],
        scrapyardCars: updatedScrapCars,
      );
      addXP(20);
      saveState();
      return SinglePartDismantleResult(
        success: true,
        isSalvaged: true,
        part: part,
        message: '${part.name} sağlam şekilde söküldü ve depoya alındı!',
      );
    } else {
      state = state.copyWith(
        scrapyardCars: updatedScrapCars,
      );
      addXP(5);
      saveState();
      return SinglePartDismantleResult(
        success: true,
        isSalvaged: false,
        part: part,
        message: 'Civata kaynamış! ${part.name} sökülürken hasar gördü ve ziyan oldu.',
      );
    }
  }

  /// Crush the remaining car chassis into scrap metal and extract surprise finds
  ChassisCrushResult crushChassisToScrapMetal(String scrapCarId) {
    final scrapIndex = state.scrapyardCars.indexWhere((c) => c.id == scrapCarId);
    if (scrapIndex == -1) {
      return const ChassisCrushResult(
        success: false,
        scrapMetalEarned: 0,
        surpriseEarned: 0,
        message: 'Hurda araç bulunamadı.',
      );
    }

    final scrapCar = state.scrapyardCars[scrapIndex];
    if (!scrapCar.isPurchased) {
      return const ChassisCrushResult(
        success: false,
        scrapMetalEarned: 0,
        surpriseEarned: 0,
        message: 'Şasiyi presleyebilmek için önce hurda aracı satın almalısınız.',
      );
    }
    final scrapMetalVal = scrapCar.chassisScrapValue;
    final surpriseVal = scrapCar.surpriseFindValue;
    final surpriseName = scrapCar.surpriseFindItem;
    final totalEarned = scrapMetalVal + surpriseVal;

    final updatedScrapCars = List<ScrapyardCar>.from(state.scrapyardCars)..removeAt(scrapIndex);

    state = state.copyWith(
      balance: state.balance + totalEarned,
      scrapyardCars: updatedScrapCars,
    );

    addXP(30);
    saveState();

    String msg = '${scrapCar.brand} ${scrapCar.modelName} şasisi preslendi! ₺${scrapMetalVal.toInt()} hurda demir geliri kazanıldı.';
    if (surpriseName != null && surpriseVal > 0) {
      msg += ' Torpidodan "$surpriseName" çıktı • +₺${surpriseVal.toInt()}!';
    }

    return ChassisCrushResult(
      success: true,
      scrapMetalEarned: scrapMetalVal,
      surpriseEarned: surpriseVal,
      surpriseItemName: surpriseName,
      message: msg,
    );
  }

  /// Refurbish / Restore a salvaged part in workshop
  bool refurbishSalvagedPart(String partId) {
    final partIndex = state.salvagedParts.indexWhere((p) => p.id == partId);
    if (partIndex == -1) return false;

    final part = state.salvagedParts[partIndex];
    if (!part.canRefurbish) return false;

    final cost = part.refurbishCost;
    if (state.balance < cost) return false;

    final restoredPart = part.refurbish();
    final updatedParts = List<SalvagedPart>.from(state.salvagedParts);
    updatedParts[partIndex] = restoredPart;

    state = state.copyWith(
      balance: state.balance - cost,
      salvagedParts: updatedParts,
    );

    addXP(25);
    saveState();
    return true;
  }

  /// Fulfill a B2B Part Order from Sanayi NPCs
  bool fulfillB2BPartOrder(String orderId, String partId) {
    final orderIndex = state.b2bPartOrders.indexWhere((o) => o.id == orderId);
    final partIndex = state.salvagedParts.indexWhere((p) => p.id == partId);

    if (orderIndex == -1 || partIndex == -1) return false;

    final order = state.b2bPartOrders[orderIndex];
    final part = state.salvagedParts[partIndex];

    if (order.isCompleted) return false;

    // Check category match
    if (part.category != order.requiredCategory) return false;

    // Check brand match if specified
    if (order.requiredCarBrand != null) {
      final matchesBrand = part.carModelName.toLowerCase().contains(order.requiredCarBrand!.toLowerCase());
      if (!matchesBrand) return false;
    }

    // Check quality tier
    if (part.tier.index < order.minQualityTier.index) return false;

    // Execute fulfillment
    final updatedParts = List<SalvagedPart>.from(state.salvagedParts)..removeAt(partIndex);
    final updatedOrder = order.copyWith(isCompleted: true);
    final updatedOrders = List<B2BPartOrder>.from(state.b2bPartOrders);
    updatedOrders[orderIndex] = updatedOrder;

    state = state.copyWith(
      balance: state.balance + order.offeredPrice,
      reputationScore: (state.reputationScore + order.reputationReward).clamp(0, 1000),
      salvagedParts: updatedParts,
      b2bPartOrders: updatedOrders,
    );

    addXP(45);
    saveState();
    return true;
  }

  /// Sell a salvaged part on the secondary parts market
  bool sellSalvagedPart(String partId) {
    final partIndex = state.salvagedParts.indexWhere((p) => p.id == partId);
    if (partIndex == -1) return false;

    final part = state.salvagedParts[partIndex];
    final updatedParts = List<SalvagedPart>.from(state.salvagedParts)..removeAt(partIndex);

    state = state.copyWith(
      balance: state.balance + part.estimatedValue,
      salvagedParts: updatedParts,
    );

    addXP(15);
    saveState();
    return true;
  }

  /// Fit a salvaged part to improve an owned car in the workshop
  bool installPartToCar(String partId, String carId) {
    final partIndex = state.salvagedParts.indexWhere((p) => p.id == partId);
    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (partIndex == -1 || carIndex == -1) return false;

    final part = state.salvagedParts[partIndex];
    final car = state.ownedCars[carIndex];
    if (car.isRented || car.isConsignment) return false;

    // Brand compatibility check
    final isBrandMatch = part.carModelName.toLowerCase().contains(car.brand.toLowerCase());
    final compMultiplier = isBrandMatch ? 1.0 : 0.60;

    // Calculate boost depending on part category and condition
    double engineBoost = 0.0;
    double transBoost = 0.0;

    if (part.category == 'engine' || part.category == 'turbo' || part.category == 'ecu' || part.category == 'radiator') {
      engineBoost = (part.conditionPercent * 0.35 * compMultiplier).clamp(10.0, 45.0);
    } else if (part.category == 'transmission' || part.category == 'brakes' || part.category == 'suspension') {
      transBoost = (part.conditionPercent * 0.35 * compMultiplier).clamp(10.0, 45.0);
    }

    final newEngineCond = (car.expertise.engineCondition + engineBoost).clamp(0.0, 100.0);
    final newTransCond = (car.expertise.transmissionCondition + transBoost).clamp(0.0, 100.0);

    // Barn Find Restoration Check
    bool isRestored = car.isBarnFindRestored;
    bool isRare = car.isRare;
    List<String> newProvenance = List.from(car.provenanceLog);

    if (car.isBarnFind && !isRestored && newEngineCond >= 95.0 && newTransCond >= 95.0) {
      isRestored = true;
      isRare = true;
      newProvenance.add('Gün ${state.currentDay}: Hurdalıktan kurtarılan klasik tam restorasyondan geçti! Değeri katlandı.');
      checkAchievement('collector_king');
    }

    final updatedCar = car.copyWith(
      isBarnFindRestored: isRestored,
      isRare: isRare,
      hasNonOriginalParts: car.hasNonOriginalParts || !isBrandMatch,
      provenanceLog: newProvenance,
      expertise: car.expertise.copyWith(
        engineCondition: newEngineCond,
        transmissionCondition: newTransCond,
      ),
    );

    // Staff mastery progression
    List<StaffModel> updatedStaff = List.from(state.hiredStaff);
    for (int i = 0; i < updatedStaff.length; i++) {
      if (updatedStaff[i].role == StaffRole.masterMechanic) {
        final staff = updatedStaff[i];
        final nextTasks = staff.tasksCompleted + 1;
        int nextLevel = staff.masteryLevel;
        if (nextTasks >= 25 && nextLevel < 3) {
          nextLevel = 3;
        } else if (nextTasks >= 10 && nextLevel < 2) {
          nextLevel = 2;
        }
        updatedStaff[i] = staff.copyWith(tasksCompleted: nextTasks, masteryLevel: nextLevel);
      }
    }

    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;
    final updatedParts = List<SalvagedPart>.from(state.salvagedParts)..removeAt(partIndex);

    state = state.copyWith(
      ownedCars: updatedCars,
      salvagedParts: updatedParts,
      hiredStaff: updatedStaff,
    );

    addXP(45);
    saveState();
    return true;
  }

  /// Purchase an equipment upgrade for Wash or Workshop
  bool purchaseEquipmentUpgrade(String equipmentId, double cost) {
    if (state.balance < cost) return false;
    if (state.unlockedBuildings.contains(equipmentId)) return false;

    final updatedBuildings = Set<String>.from(state.unlockedBuildings)..add(equipmentId);
    state = state.copyWith(
      balance: state.balance - cost,
      unlockedBuildings: updatedBuildings,
    );

    addXP(120);
    saveState();
    return true;
  }

  /// Perform a dedicated Wash & Detailing service package on an owned car
  bool performWashService(
    String carId, {
    required double cost,
    required double valueBoostPercent,
    bool setWashed = false,
    bool setInterior = false,
    bool setPolished = false,
    bool setDetailed = false,
  }) {
    if (state.balance < cost) return false;
    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    if (car.isRented) return false;

    final isStandardWash = setWashed || (!setInterior && !setPolished && !setDetailed);

    if (setDetailed && car.isDetailedCleaned) return false;
    if (setPolished && !setDetailed && car.isPolished) return false;
    if (setInterior && car.isInteriorCleaned) return false;
    if (isStandardWash && !setInterior && !setPolished && !setDetailed && car.isWashed) return false;

    // Remove double-dipping: baseMarketValue stays the same, 
    // car_model.dart's estimatedRealValue handles the price increase dynamically.
    final newValue = car.baseMarketValue;

    final updatedDetailing = List<String>.from(car.appliedDetailingOptionIds);
    if (setInterior && !updatedDetailing.contains('interior_detailing')) {
      updatedDetailing.add('interior_detailing');
    }
    if (setPolished && !updatedDetailing.contains('paint_polish')) {
      updatedDetailing.add('paint_polish');
    }
    if (setDetailed && !updatedDetailing.contains('ceramic_coating')) {
      updatedDetailing.add('ceramic_coating');
    }

    final updatedCar = car.copyWith(
      baseMarketValue: newValue,
      isWashed: (isStandardWash || setInterior) ? true : car.isWashed,
      isPolished: setPolished ? true : car.isPolished,
      isDetailedCleaned: setDetailed ? true : car.isDetailedCleaned,
      appliedDetailingOptionIds: updatedDetailing,
    );

    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    state = state.copyWith(
      balance: state.balance - cost,
      ownedCars: updatedCars,
    );

    addXP(30);
    checkAndAwardFirstTimeAction(FirstTimeActionKeys.firstCarWash);
    updateMissionProgress(MissionType.washCars, 1);
    saveState();
    return true;
  }

  /// Perform specialized workshop station repair
  bool performWorkshopStationRepair(
    String carId, {
    required String repairType,
    required double cost,
  }) {
    double finalCost = cost;
    // Origin Perk: Sanayi Çırağı -%15 tamir indirimi
    if (state.characterOrigin == CharacterOrigin.sanayiCiragi) {
      finalCost *= 0.85;
    }
    // Specialization Perk: Restoratör Usta -%20 tamir indirimi
    if (state.specializationPath == SpecializationPath.restorer) {
      finalCost *= 0.80;
    }

    if (state.balance < finalCost) return false;
    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    final exp = car.expertise;

    ExpertiseReport updatedExp = exp;

    switch (repairType) {
      case 'engine':
        if (exp.engineCondition >= 99.5) return false;
        updatedExp = exp.copyWith(engineCondition: 100.0);
        break;
      case 'transmission':
        if (exp.transmissionCondition >= 99.5) return false;
        updatedExp = exp.copyWith(transmissionCondition: 100.0);
        break;
      case 'ecu':
        if (exp.isEcuCleaned) return false;
        updatedExp = exp.copyWith(
          isEcuCleaned: true,
          engineCondition: (exp.engineCondition + 15).clamp(0.0, 100.0),
        );
        break;
      case 'bodywork':
        final hasDamagedOrChanged = exp.bodyParts.values.any((v) => v != PartStatus.original);
        if (!hasDamagedOrChanged) return false;
        final repairedParts = Map<String, PartStatus>.from(exp.bodyParts);
        final repairedConditions = Map<String, double>.from(exp.partConditions);
        repairedParts.forEach((key, value) {
          repairedParts[key] = PartStatus.original;
          repairedConditions[key] = 100.0;
        });
        updatedExp = exp.copyWith(
          bodyParts: repairedParts,
          partConditions: repairedConditions,
        );
        break;
      case 'chassis':
        if (exp.isChassisAligned) return false;
        updatedExp = exp.copyWith(
          isChassisAligned: true,
        );
        break;
    }

    final updatedCar = car.copyWith(
      expertise: updatedExp,
      // Fix exponential price inflation: don't artificially scale baseMarketValue
      baseMarketValue: car.baseMarketValue,
    );

    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    state = state.copyWith(
      balance: state.balance - finalCost,
      ownedCars: updatedCars,
    );

    addXP(50);
    saveState();
    return true;
  }

  /// Complete a customer repair contract job
  bool completeCustomerRepairJob(CustomerRepairJob job) {
    if (state.balance < job.partsCost) return false;
    final netGain = job.laborReward - job.partsCost;
    state = state.copyWith(
      balance: state.balance + netGain,
      totalProfit: state.totalProfit + (netGain > 0 ? netGain : 0.0),
      partsRepairedLast7Days: state.partsRepairedLast7Days + 1,
    );
    addXP(job.masteryXpReward);
    updateMissionProgress(MissionType.repairParts, 1);
    saveState();
    return true;
  }

  /// Perform 10.000 KM Periodic Maintenance (+15% condition)
  bool performPeriodicMaintenance(String carId) {
    const cost = 3500.0;
    if (state.balance < cost) return false;

    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    if (car.isRented || car.isPeriodicMaintained) return false;
    final exp = car.expertise;

    final updatedExp = exp.copyWith(
      engineCondition: (exp.engineCondition + 15.0).clamp(0.0, 100.0),
      transmissionCondition: (exp.transmissionCondition + 15.0).clamp(0.0, 100.0),
    );

    final updatedCar = car.copyWith(
      expertise: updatedExp,
      isPeriodicMaintained: true,
    );

    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    state = state.copyWith(
      balance: state.balance - cost,
      ownedCars: updatedCars,
    );

    addXP(30);
    saveState();
    return true;
  }

  /// Apply custom color paint respray
  bool applyCustomPaintRespray(String carId, CustomPaintColor paint) {
    if (state.balance < paint.cost) return false;

    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    if (car.isRented) return false;

    final updatedCar = car.copyWith(
      colorHex: paint.hex,
      colorDisplayName: paint.name,
      colorRarity: paint.buyerAppealMultiplier >= 1.20 ? 'rare' : 'common',
    );

    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    state = state.copyWith(
      balance: state.balance - paint.cost,
      ownedCars: updatedCars,
    );

    addXP(40);
    saveState();
    return true;
  }

  /// Wash and polish all cars in garage in one batch
  bool washAllCars() {
    if (state.ownedCars.isEmpty) return false;
    final hasWasher = state.hiredStaff.any((s) => s.role == StaffRole.washer);
    final unwashedCars = state.ownedCars.where((c) => !c.isRented && (!c.isWashed || !c.isPolished || !c.isDetailedCleaned)).toList();
    if (unwashedCars.isEmpty) return false;

    final totalCost = hasWasher ? 0.0 : (unwashedCars.length * 600.0);
    if (state.balance < totalCost) return false;

    final updatedCars = state.ownedCars.map((c) {
      if (c.isRented) return c;
      return c.copyWith(
        isWashed: true,
        isPolished: true,
        isDetailedCleaned: true,
      );
    }).toList();

    state = state.copyWith(
      balance: state.balance - totalCost,
      ownedCars: updatedCars,
    );
    addXP(20 * unwashedCars.length);
    checkAndAwardFirstTimeAction(FirstTimeActionKeys.firstCarWash);
    updateMissionProgress(MissionType.washCars, unwashedCars.length);
    saveState();
    return true;
  }

  /// Emergency Bailout: Dede Mirası Can Suyu (₺50.000)
  bool claimEmergencyBailout() {
    final totalAssets = state.balance +
        state.bankDepositBalance +
        state.ownedCars
            .where((c) => !c.isConsignment)
            .fold<double>(0.0, (s, c) => s + c.estimatedRealValue);
    if (totalAssets > 15000) return false;

    state = state.copyWith(
      balance: state.balance + 50000.0,
    );
    addXP(100);
    saveState();
    return true;
  }

  /// Daily Scrapyard Side Gig: Hurdalıkta Günlük Çıraklık (₺5.000) - Günde 1 kez yapılabilir
  bool doDailyScrapyardSideGig() {
    final now = DateTime.now();
    if (state.lastScrapyardGigDate != null) {
      final diff = now.difference(state.lastScrapyardGigDate!);
      if (diff.inHours < 20) {
        return false;
      }
    }
    state = state.copyWith(
      balance: state.balance + 5000.0,
      lastScrapyardGigDate: now,
    );
    addXP(25);
    updateMissionProgress(MissionType.scrapyardDismantle, 1);
    saveState();
    return true;
  }

  /// Alias for doDailyScrapyardSideGig
  bool workScrapyardSideGig() => doDailyScrapyardSideGig();

  /// Complete an incoming customer wash job
  bool completeCustomerWashJob(CustomerWashJob job) {
    state = state.copyWith(
      balance: state.balance + job.paymentReward,
      totalProfit: state.totalProfit + job.paymentReward,
    );
    addXP(job.masteryXp);
    checkAndAwardFirstTimeAction(FirstTimeActionKeys.firstCarWash);
    updateMissionProgress(MissionType.washCars, 1);
    saveState();
    return true;
  }

  /// Apply a scented aroma diffuser / hanging scent to rearview mirror
  bool applyCarScent(String carId, CarScent scent) {
    if (state.balance < scent.cost) return false;

    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    if (car.isRented) return false;
    final updatedOptions = car.appliedDetailingOptionIds.where((id) => !id.startsWith('scent_')).toList();
    updatedOptions.add(scent.id);

    final updatedCar = car.copyWith(
      appliedDetailingOptionIds: updatedOptions,
    );

    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    state = state.copyWith(
      balance: state.balance - scent.cost,
      ownedCars: updatedCars,
    );
    addXP(15);
    saveState();
    return true;
  }

  /// Restore cloudy / yellowish headlights using chlorovapor and sanding (₺850)
  bool restoreHeadlights(String carId) {
    const cost = 850.0;
    if (state.balance < cost) return false;

    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    if (car.isRented || car.hasRestoredHeadlights) return false;

    final updatedOptions = List<String>.from(car.appliedDetailingOptionIds)..add('headlight_restoration');
    final updatedCar = car.copyWith(
      appliedDetailingOptionIds: updatedOptions,
    );

    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    state = state.copyWith(
      balance: state.balance - cost,
      ownedCars: updatedCars,
    );
    addXP(20);
    saveState();
    return true;
  }

  /// Deep clean brake dust & iron particles from wheels (₺450)
  bool cleanWheelIronDecon(String carId) {
    const cost = 450.0;
    if (state.balance < cost) return false;

    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    if (car.isRented || car.hasIronDecon) return false;

    final updatedOptions = List<String>.from(car.appliedDetailingOptionIds)..add('iron_decon');
    final updatedCar = car.copyWith(
      appliedDetailingOptionIds: updatedOptions,
    );

    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    state = state.copyWith(
      balance: state.balance - cost,
      ownedCars: updatedCars,
    );
    addXP(15);
    saveState();
    return true;
  }

  /// Paintless Dent Repair (PDR) - restores minor dents without painting (₺3.200)
  bool performPdrDentRepair(String carId) {
    const cost = 3200.0;
    if (state.balance < cost) return false;

    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    if (car.isRented || car.hasPdrRepaired) return false;

    final updatedOptions = List<String>.from(car.appliedDetailingOptionIds)..add('pdr_repaired');
    final updatedCar = car.copyWith(
      appliedDetailingOptionIds: updatedOptions,
    );

    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    state = state.copyWith(
      balance: state.balance - cost,
      ownedCars: updatedCars,
    );
    addXP(40);
    saveState();
    return true;
  }

  /// Certify 2-Year TÜVTÜRK & Emission Inspection Check-up (₺1.500)
  bool certifyTuvturkInspection(String carId) {
    const cost = 1500.0;
    if (state.balance < cost) return false;

    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    if (car.isRented || car.hasTuvturkCertified) return false;

    final updatedOptions = List<String>.from(car.appliedDetailingOptionIds)..add('tuvturk_certified');
    final updatedCar = car.copyWith(
      appliedDetailingOptionIds: updatedOptions,
    );

    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    state = state.copyWith(
      balance: state.balance - cost,
      ownedCars: updatedCars,
    );
    addXP(35);
    saveState();
    return true;
  }

  /// Order Sanayi Tostu & Demli Çay snack for workshop team (₺250)
  bool treatWorkshopStaffSnack() {
    const cost = 250.0;
    if (state.balance < cost) return false;

    final updatedStaff = state.hiredStaff.map((s) {
      return s.copyWith(morale: (s.morale + 20).clamp(0, 100));
    }).toList();

    state = state.copyWith(
      balance: state.balance - cost,
      hiredStaff: updatedStaff,
    );
    addXP(10);
    saveState();
    return true;
  }

  /// Batch Publish all ready, unlisted cars in garage at recommended market price (+10%)
  int publishAllReadyCars() {
    final readyCars = state.ownedCars.where((c) => !c.isListed && !c.isRented && !c.isLockedInShowcase && c.expertise.engineCondition >= 70 && c.expertise.transmissionCondition >= 70).toList();
    if (readyCars.isEmpty) return 0;

    final updatedCars = state.ownedCars.map((c) {
      if (!c.isListed && !c.isRented && !c.isLockedInShowcase && c.expertise.engineCondition >= 70 && c.expertise.transmissionCondition >= 70) {
        final recommendedPrice = (c.estimatedRealValue * 1.10).roundToDouble();
        return c.copyWith(
          customListingPrice: recommendedPrice,
          daysListed: 0,
          declarationType: ListingDeclarationType.honest,
          listingPhotoCount: 3,
          listingTone: 'standart',
          hideDamagedPhotos: false,
        );
      }
      return c;
    }).toList();

    state = state.copyWith(
      ownedCars: updatedCars,
    );
    addXP(25 * readyCars.length);
    saveState();
    return readyCars.length;
  }

  /// Launch Weekend Flash Sale campaign (-10% discount on stale or listed cars, triggers rush)
  int startWeekendFlashSale() {
    final listedCars = state.ownedCars.where((c) => c.isListed).toList();
    if (listedCars.isEmpty) return 0;

    final updatedCars = state.ownedCars.map((c) {
      if (c.isListed) {
        final discountedPrice = (c.listingPrice * 0.90).roundToDouble();
        return c.copyWith(
          customListingPrice: discountedPrice,
        );
      }
      return c;
    }).toList();

    state = state.copyWith(
      ownedCars: updatedCars,
    );
    triggerOrganicOffers();
    addXP(30);
    saveState();
    return listedCars.length;
  }

  /// 1. Sabah Siftahı & Kasa Duası Ritüeli (§5)
  bool performMorningSiftah() {
    const siftahCoin = 100.0;
    if (state.balance < siftahCoin) return false;

    final updatedStaff = state.hiredStaff.map((s) {
      return s.copyWith(morale: (s.morale + 15).clamp(0, 100));
    }).toList();

    state = state.copyWith(
      balance: state.balance + siftahCoin, // Siftah bereket getirir
      hiredStaff: updatedStaff,
    );
    triggerOrganicOffers();
    addXP(25);
    saveState();
    return true;
  }

  /// 2. Dyno Motor Beygir Gücü & Tork Testi (§9)
  DynoTestReport? performDynoHpTest(String carId, ExpertisePackageTier tier) {
    if (state.balance < tier.cost) return null;

    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return null;

    final car = state.ownedCars[carIndex];
    if (car.isRented || car.isConsignment) return null;
    if (car.appliedDetailingOptionIds.contains('dyno_certified')) return null;

    final report = DynoTestReport.generate(car);

    final updatedOptions = List<String>.from(car.appliedDetailingOptionIds)..add('dyno_certified');

    final updatedCar = car.copyWith(
      appliedDetailingOptionIds: updatedOptions,
    );

    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    state = state.copyWith(
      balance: state.balance - tier.cost,
      ownedCars: updatedCars,
    );

    addXP(35);
    saveState();
    return report;
  }

  /// 3. Stage 1 / Stage 2 Chip Tuning ECU Yazılımı (§22)
  bool applyChipTuning(String carId, ChipTuningStage stage) {
    if (stage == ChipTuningStage.none) return false;
    if (state.balance < stage.cost) return false;

    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    if (car.isRented || car.isConsignment) return false;
    if (car.appliedDetailingOptionIds.contains(stage.id)) return false;

    final updatedOptions = List<String>.from(car.appliedDetailingOptionIds)..add(stage.id);

    final updatedCar = car.copyWith(
      appliedDetailingOptionIds: updatedOptions,
    );

    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    state = state.copyWith(
      balance: state.balance - stage.cost,
      ownedCars: updatedCars,
    );

    addXP(50);
    checkAndAwardFirstTimeAction(FirstTimeActionKeys.firstTuning);
    updateMissionProgress(MissionType.tuneCar, 1);
    saveState();
    return true;
  }

  /// 4. Çizilmez Cam Filmi & Karbon Bodykit Montajı (§22)
  bool installBodykitAndTint(String carId) {
    const cost = 3500.0;
    if (state.balance < cost) return false;

    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    if (car.isRented || car.isConsignment) return false;
    if (car.appliedDetailingOptionIds.contains('bodykit_tint')) return false;

    final updatedOptions = List<String>.from(car.appliedDetailingOptionIds)..add('bodykit_tint');

    final updatedCar = car.copyWith(
      appliedDetailingOptionIds: updatedOptions,
    );

    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    state = state.copyWith(
      balance: state.balance - cost,
      ownedCars: updatedCars,
    );

    addXP(35);
    checkAndAwardFirstTimeAction(FirstTimeActionKeys.firstTuning);
    updateMissionProgress(MissionType.tuneCar, 1);
    saveState();
    return true;
  }

  /// 5. Pazarlık Masası Çay / Kahve İkramı (§24)
  bool treatNegotiationBeverage(NegotiationTreat treat) {
    if (state.balance < treat.cost) return false;

    state = state.copyWith(
      balance: state.balance - treat.cost,
    );
    addXP(15);
    saveState();
    return true;
  }

  /// 6. Pazarlıkta Müşteriye Özel Memleket Plakası Hediye Etme (§24)
  bool giftHometownPlate(String carId, String cityCode) {
    const cost = 500.0;
    if (state.balance < cost) return false;

    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    if (car.isRented || car.isConsignment) return false;

    final updatedCar = car.copyWith(
      plateNumber: '$cityCode GAL 34',
    );

    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    state = state.copyWith(
      balance: state.balance - cost,
      ownedCars: updatedCars,
    );

    addXP(25);
    saveState();
    return true;
  }

  /// 7. Vadesi Gelmemiş Müşteri Çekini Kırdırma (Faktoring Masası) (§10)
  FactoringDeal? cashInChequeWithFactoring(String chequeId) {
    final chequeIndex = state.activeCheques.indexWhere((c) => c.id == chequeId);
    if (chequeIndex == -1) return null;

    final cheque = state.activeCheques[chequeIndex];
    final deal = FactoringDeal.calculate(cheque.id, cheque.amount);

    final updatedCheques = List<Cheque>.from(state.activeCheques)..removeAt(chequeIndex);

    state = state.copyWith(
      balance: state.balance + deal.payoutCash,
      activeCheques: updatedCheques,
    );

    addXP(20);
    saveState();
    return deal;
  }

  /// 8. Karaborsa Polis Baskını Müdahalesi (§2)
  bool handlePoliceEncounter(String carId, PoliceEncounterAction action) {
    if (action == PoliceEncounterAction.surrenderCar) {
      final updatedCars = state.ownedCars.where((c) => c.id != carId).toList();
      state = state.copyWith(ownedCars: updatedCars);
      saveState();
      return true;
    }

    if (state.balance < action.cost) return false;

    state = state.copyWith(
      balance: state.balance - action.cost,
    );

    addXP(30);
    saveState();
    return true;
  }

  /// 9. Soğuk Damga Şasi Çakma (Cold Stamping) (§2)
  bool coldStampChassis(String carId) {
    const cost = 4000.0;
    if (state.balance < cost) return false;

    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    if (car.isRented || car.isConsignment || car.isChassisRepaired) return false;

    final updatedOptions = List<String>.from(car.appliedDetailingOptionIds)..add('chassis_restamped');

    final updatedCar = car.copyWith(
      appliedDetailingOptionIds: updatedOptions,
      isChassisRepaired: true,
    );

    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    state = state.copyWith(
      balance: state.balance - cost,
      ownedCars: updatedCars,
    );

    addXP(45);
    saveState();
    return true;
  }

  /// 10. Çıkma Parçaları Sanayi Toptancısına Satma (§17)
  double sellScrapPartsInBulk() {
    if (state.salvagedParts.isEmpty) {
      return 0.0;
    }

    final totalPayout = state.salvagedParts.length * 1500.0;
    state = state.copyWith(
      balance: state.balance + totalPayout,
      salvagedParts: [],
    );

    addXP(30);
    saveState();
    return totalPayout;
  }

  /// 11. Hurdalıkta Kayıp Hazine Arama (§17)
  double? searchScrapForTreasures() {
    const cost = 500.0;
    if (state.balance < cost) return null;

    final roll = random.nextDouble();
    double foundCash;
    if (roll < 0.35) {
      // Boş / Değersiz hurda yığını
      foundCash = 0.0;
    } else if (roll < 0.80) {
      // Çıkma radyo & kriko gibi orta buluntu
      foundCash = 750.0 + (random.nextInt(4) * 250);
    } else {
      // Nadir hurdalık hazinesi
      foundCash = 2500.0 + (random.nextInt(3) * 500);
    }

    state = state.copyWith(
      balance: state.balance - cost + foundCash,
    );

    addXP(foundCash > 0 ? 25 : 10);
    saveState();
    return foundCash;
  }

  /// 12. Fırçasız Otomatik Tünel Yıkama Ünitesi Satın Alma (§4)
  bool purchaseAutoWashTunnel() {
    const cost = 45000.0;
    if (state.balance < cost) return false;
    if (state.unlockedBuildings.contains('auto_wash_tunnel')) return false;

    final updatedBuildings = Set<String>.from(state.unlockedBuildings)..add('auto_wash_tunnel');

    state = state.copyWith(
      balance: state.balance - cost,
      unlockedBuildings: updatedBuildings,
    );

    addXP(100);
    saveState();
    return true;
  }

  /// 13. VIP Araç İçi Medikal Ozon Dezenfeksiyonu (§4)
  bool applyOzoneSanitization(String carId) {
    const cost = 600.0;
    if (state.balance < cost) return false;

    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    if (car.isRented || car.isConsignment || car.appliedDetailingOptionIds.contains('ozone_sanitized')) return false;
    final updatedOptions = List<String>.from(car.appliedDetailingOptionIds)..add('ozone_sanitized');

    final updatedCar = car.copyWith(
      appliedDetailingOptionIds: updatedOptions,
    );

    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    state = state.copyWith(
      balance: state.balance - cost,
      ownedCars: updatedCars,
    );

    addXP(20);
    saveState();
    return true;
  }

  /// 14. VIP Dizi / Reklam Makam Aracı Kiralama Kabulü (§15)
  bool acceptVipFilmSetRental(VipSetRentalContract contract) {
    final carIndex = state.ownedCars.indexWhere((c) => c.id == contract.carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    if (car.isRented || car.isLockedInShowcase) return false;
    final updatedCar = car.copyWith(
      appliedDetailingOptionIds: List<String>.from(car.appliedDetailingOptionIds)..add('rented_to_film_set'),
    );

    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    state = state.copyWith(
      balance: state.balance + contract.totalPayout,
      totalProfit: state.totalProfit + contract.totalPayout,
      ownedCars: updatedCars,
    );

    addXP(50);
    saveState();
    return true;
  }

  /// 15. Müşteri Yorumuna Esnaf Cevabı Yazma (§16)
  bool respondToReview(String reviewId, String replyText) {
    final index = state.customerReviews.indexWhere((r) => r.id == reviewId);
    if (index != -1) {
      final review = state.customerReviews[index];
      if (review.reply != null && review.reply!.isNotEmpty) return false;

      final updatedReview = review.copyWith(reply: replyText);
      List<CustomerReviewModel> updatedReviews = List.from(state.customerReviews);
      updatedReviews[index] = updatedReview;

      state = state.copyWith(
        customerReviews: updatedReviews,
        reputationScore: (state.reputationScore + 5).clamp(0, 1000),
      );
    } else {
      state = state.copyWith(
        reputationScore: (state.reputationScore + 5).clamp(0, 1000),
      );
    }

    addXP(20);
    saveState();
    return true;
  }

  /// 16. Otomobil YouTuber / Fenomen Sponsorluğu Satın Alma (§16)
  bool sponsorAutoInfluencer() {
    const cost = 15000.0;
    if (state.balance < cost) return false;

    state = state.copyWith(
      balance: state.balance - cost,
      reputationScore: (state.reputationScore + 15).clamp(0, 1000),
    );

    triggerOrganicOffers();
    addXP(100);
    saveState();
    return true;
  }

  /// 17. Ofis Reklam Desteği: Gurbetçi Dayı Zarf Fonu / Dinamik Esnaf Katkısı
  double claimOfficeAdGrant([double? customAmount]) {
    final grantAmount = customAmount ?? 25000.0;
    state = state.copyWith(
      balance: state.balance + grantAmount,
      lastOfficeGrantClaimDay: state.currentDay,
    );
    addXP(50);
    saveState();
    return grantAmount;
  }

  /// 18. Dinamik Akıllı Kanca (Smart Hook) Reklam Ödülü İnfazı
  bool executeSmartOfficeHook(SmartHookType hookType) {
    switch (hookType) {
      case SmartHookType.dirtyCarsWash:
        // Tüm garaj araçlarını yıka, cila çek ve detaylı temizle
        final updatedCars = state.ownedCars.map((c) {
          if (c.isRented) return c;
          return c.copyWith(
            isWashed: true,
            isPolished: true,
            isDetailedCleaned: true,
          );
        }).toList();
        state = state.copyWith(
          ownedCars: updatedCars,
          lastSmartHookUsedDay: state.currentDay,
        );
        addXP(75);
        saveState();
        return true;

      case SmartHookType.damagedCarRepair:
        // En düşük kondisyondaki araca sandık motor ve tamir uygula
        final candidates = state.ownedCars
            .where((c) => !c.isRented && (c.expertise.engineCondition < 100 || c.expertise.transmissionCondition < 100))
            .toList()
          ..sort((a, b) => a.expertise.engineCondition.compareTo(b.expertise.engineCondition));

        if (candidates.isNotEmpty) {
          final targetCar = candidates.first;
          final repairedParts = Map<String, PartStatus>.from(targetCar.expertise.bodyParts);
          repairedParts.updateAll((key, value) => PartStatus.original);

          final repairedReport = targetCar.expertise.copyWith(
            engineCondition: 100.0,
            transmissionCondition: 100.0,
            bodyParts: repairedParts,
          );

          final updatedCar = targetCar.copyWith(expertise: repairedReport);
          final updatedCars = state.ownedCars.map((c) => c.id == updatedCar.id ? updatedCar : c).toList();
          state = state.copyWith(
            ownedCars: updatedCars,
            lastSmartHookUsedDay: state.currentDay,
          );
        } else {
          state = state.copyWith(lastSmartHookUsedDay: state.currentDay);
        }
        addXP(75);
        saveState();
        return true;

      case SmartHookType.lowBalanceGrant:
        // Çıkmacı İbo Dayı acil nakit hibesi (+₺35.000)
        state = state.copyWith(
          balance: state.balance + 35000.0,
          lastSmartHookUsedDay: state.currentDay,
        );
        addXP(50);
        saveState();
        return true;

      case SmartHookType.emptyGarageSpawn:
        // Gümrük muhafaza kelepir harçlığı (+₺10.000)
        state = state.copyWith(
          balance: state.balance + 10000.0,
          lastSmartHookUsedDay: state.currentDay,
        );
        addXP(50);
        saveState();
        return true;

      case SmartHookType.viralReputationBoost:
        // Fenomen Berkcan viral reels: +25 Prestij ve vitrin dopingi
        final dopedCars = state.ownedCars.map((c) {
          if (c.isListed) {
            return c.copyWith(isDoped: true);
          }
          return c;
        }).toList();
        state = state.copyWith(
          ownedCars: dopedCars,
          reputationScore: (state.reputationScore + 25).clamp(0, 1000),
          lastSmartHookUsedDay: state.currentDay,
        );
        triggerOrganicOffers();
        addXP(100);
        saveState();
        return true;
    }
  }

  /// 19. Ofis Ekranı Dinamik Metin & Tavsiye Yenileme
  void refreshOfficeSeed() {
    state = state.copyWith(officeSeed: state.officeSeed + 1);
  }

  /// 20. Özel Plaka Satın Alma ve Araca Atama
  bool buyAndAssignPlate({
    required String carId,
    required String plateNumber,
    required String plateRarity,
    required double cost,
    required int reputationBonus,
  }) {
    if (state.balance < cost) return false;
    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    if (car.isRented) return false;

    final updatedCar = car.copyWith(
      plateNumber: plateNumber,
      plateRarity: plateRarity,
    );

    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    state = state.copyWith(
      balance: state.balance - cost,
      ownedCars: updatedCars,
      reputationScore: (state.reputationScore + reputationBonus).clamp(0, 1000),
    );

    addXP(reputationBonus * 10);
    saveState();
    return true;
  }
}



