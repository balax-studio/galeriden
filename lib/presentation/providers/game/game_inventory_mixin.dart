import 'dart:math' as math;
import '../../../core/constants/first_time_action_keys.dart';
import '../../../data/models/mega_systems_extensions_model.dart';
import '../../../data/models/cheque_model.dart';
import '../../../data/models/branch_model.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/sale_record_model.dart';
import '../../../data/models/vehicle_category.dart';
import '../../../data/models/contract_model.dart';
import '../../../data/models/dealership_model.dart';
import '../../../data/models/expertise_model.dart';
import '../../../data/models/gossip_item_model.dart';
import '../../../data/models/player_spread_gossip_model.dart';
import '../../../data/models/mission_model.dart';
import '../../../data/models/trade_in_offer_model.dart';
import '../../../data/models/customer_review_model.dart';
import '../../../data/models/lifestyle_item_model.dart';
import '../../../data/models/pr_campaign_model.dart';
import '../../../data/models/daily_login_reward_model.dart';
import '../../../data/models/stock_model.dart';
import '../../../data/models/game_event_model.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/offer_model.dart';
import '../../../domain/usecases/negotiation_engine.dart';
import '../../../domain/usecases/night_market_engine.dart';
import '../../../domain/usecases/repair_engine.dart';
import '../../../domain/usecases/risk_engine.dart';
import '../../../domain/usecases/smart_office_hook_engine.dart';
import '../../../domain/usecases/gossip_engine.dart';
import 'game_base_notifier.dart';

mixin GameInventoryMixin on GameBaseNotifier {
  /// Fulfill a VIP Wanted Car Contract
  bool fulfillWantedCarContract(String contractId, String carId) {
    final contractIndex =
        state.activeContracts.indexWhere((c) => c.id == contractId);
    if (contractIndex == -1) return false;
    final contract = state.activeContracts[contractIndex];

    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;
    final car = state.ownedCars[carIndex];
    if (car.isRented || car.isLockedInShowcase || car.isConsignment) {
      return false;
    }

    // Validate requirements
    if (car.brand.toLowerCase() != contract.targetBrand.toLowerCase()) {
      return false;
    }
    if (contract.targetBodyType != null &&
        car.bodyType != contract.targetBodyType) {
      return false;
    }
    if (car.modelYear < contract.minYear) return false;
    if (car.expertise.mileage > contract.maxMileage) return false;

    final totalPayout = contract.budget + contract.rewardBonus;
    final profit = totalPayout - car.totalCost;

    final updatedCars = List<CarModel>.from(state.ownedCars)
      ..removeAt(carIndex);
    final updatedContracts = List<WantedCarContract>.from(state.activeContracts)
      ..removeAt(contractIndex);

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
    if (profit > 0) {
      updateMissionProgress(MissionType.earnProfit, profit.toInt());
    }
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
  PurchaseRiskOutcome? buyCar(CarModel car, double purchasePrice,
      {bool isExpertiseCompleted = false}) {
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

    final logEntry =
        'Gün ${state.currentDay}: Piyasadan ₺${finalPurchasePrice.round()} bedelle galeri stoklarına katıldı.';
    final purchasedCar = outcome.updatedCar.copyWith(
      currentPurchasePrice: finalPurchasePrice,
      hasCertifiedExpertise: isExpertiseCompleted,
      provenanceLog: [
        ...outcome.updatedCar.provenanceLog,
        logEntry,
        if (isExpertiseCompleted)
          'Gün ${state.currentDay}: Kurumsal ekspertiz raporu tamamlandı • Güven damgası tescillendi.',
      ],
    );
    final updatedCars = [...state.ownedCars, purchasedCar];
    final modelKey = '${purchasedCar.brand}_${purchasedCar.modelName}'
        .toLowerCase()
        .replaceAll(' ', '_');
    final updatedAlbum =
        <String>{...state.discoveredCarModelIds, modelKey}.toList();

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

  /// Purchase a car with official Notary transfer fees and registration
  PurchaseRiskOutcome? buyCarWithNoter({
    required CarModel car,
    required double agreedPrice,
    required double noterFee,
    double registrationFee = 850.0,
    bool isExpertiseCompleted = false,
  }) {
    final totalAcquisitionCost = agreedPrice + noterFee + registrationFee;
    if (state.balance < totalAcquisitionCost) return null;
    if (state.ownedCars.length >= state.maxGarageSlots) return null;

    final updatedBalance = state.balance - totalAcquisitionCost;

    PurchaseRiskOutcome outcome;
    if (!isExpertiseCompleted) {
      outcome = RiskEngine.evaluateUninspectedPurchaseRisk(car);
    } else {
      outcome = PurchaseRiskOutcome(
        isTrapped: false,
        title: 'Noter Onaylı Alım',
        description: 'Ekspertiz ve noter tesciliyle güvenle satın alındı.',
        updatedCar: car,
      );
    }

    final logEntry =
        'Gün ${state.currentDay}: Noter tesciliyle ₺${agreedPrice.round()} bedel + ₺${(noterFee + registrationFee).round()} masrafla galeri stoklarına katıldı.';
    final purchasedCar = outcome.updatedCar.copyWith(
      currentPurchasePrice: agreedPrice,
      hasCertifiedExpertise: isExpertiseCompleted,
      provenanceLog: [
        ...outcome.updatedCar.provenanceLog,
        logEntry,
        if (isExpertiseCompleted)
          'Gün ${state.currentDay}: Kurumsal ekspertiz raporu tamamlandı • Güven damgası tescillendi.',
      ],
    );
    final updatedCars = [...state.ownedCars, purchasedCar];
    final modelKey = '${purchasedCar.brand}_${purchasedCar.modelName}'
        .toLowerCase()
        .replaceAll(' ', '_');
    final updatedAlbum =
        <String>{...state.discoveredCarModelIds, modelKey}.toList();

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

  /// Category-specific upgrade for alternative vehicles (marine, aircraft, caravan, etc.)
  Map<String, dynamic> upgradeVasitaVehicle(String carId) {
    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) {
      return {'success': false, 'messageKey': 'vasita_upgrade_err_not_found'};
    }

    final car = state.ownedCars[carIndex];
    if (car.isVasitaUpgraded) {
      return {'success': false, 'messageKey': 'vasita_upgrade_err_already_done'};
    }

    // Determine cost and log based on category
    double cost;
    String logEntry;
    switch (car.vehicleCategory) {
      case VehicleCategory.marine:
        cost = 15000.0;
        logEntry = 'Liman bakımı ve zehirli boya yenilendi • Sezona hazır';
        break;
      case VehicleCategory.aircraft:
        cost = 45000.0;
        logEntry = 'ARC uçuş elverişlilik sertifikası tescillendi • Tam lisanslı';
        break;
      case VehicleCategory.caravan:
        cost = 12000.0;
        logEntry = 'Off-grid kamp kiti ve güneş panelleri entegre edildi';
        break;
      case VehicleCategory.motorcycle:
        cost = 4000.0;
        logEntry = 'Titanyum koruma demirleri ve pad seti monte edildi';
        break;
      case VehicleCategory.commercial:
        cost = 8000.0;
        logEntry = 'Dijital takograf ve kantar kalibrasyonu tamamlandı';
        break;
      case VehicleCategory.atv:
      case VehicleCategory.utv:
        cost = 7500.0;
        logEntry = 'Ağır arazi vinci ve şnorkel kiti takıldı';
        break;
      case VehicleCategory.classic:
        cost = 6000.0;
        logEntry = 'Krom detay parlatma ve özel branda muhafazası yapıldı';
        break;
      case VehicleCategory.damaged:
        cost = 5000.0;
        logEntry = 'Ekspertiz şase ve yürür doğrulaması yapıldı';
        break;
      case VehicleCategory.rentalFleet:
        cost = 3500.0;
        logEntry = 'Filo sözleşme ve kasko revizyonu tamamlandı';
        break;
      case VehicleCategory.minivan:
        cost = 4500.0;
        logEntry = 'VIP taban ve bagaj koruma kaplaması yapıldı';
        break;
      case VehicleCategory.car:
        cost = 5000.0;
        logEntry = 'Özel vasıta periyodik servis bakımı yapıldı';
        break;
    }

    if (state.balance < cost) {
      return {'success': false, 'messageKey': 'vasita_upgrade_err_insufficient_funds'};
    }

    final updatedCar = car.copyWith(
      isVasitaUpgraded: true,
      provenanceLog: [...car.provenanceLog, logEntry],
    );

    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    state = state.copyWith(
      balance: state.balance - cost,
      ownedCars: updatedCars,
      reputationScore: (state.reputationScore + 4).clamp(0, 1000),
    );
    addXP(40);
    saveState();

    return {'success': true, 'cost': cost};
  }

  /// Select permanent Specialization Path at level >= 4 (§2.2)
  bool chooseSpecialization(SpecializationPath path) {
    if (state.level < 4) return false;
    state = state.copyWith(specializationPath: path);
    addXP(200);
    saveState();
    return true;
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

    final updatedBuildings = Set<String>.from(state.unlockedBuildings)
      ..add(tierKey);

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
      final commRate = car.consignmentCommissionRate > 0
          ? car.consignmentCommissionRate
          : 0.10;
      final commissionAmount = (sellingPrice * commRate).roundToDouble();
      profit = commissionAmount;
      cashReceived = commissionAmount;
    } else {
      profit = sellingPrice - car.totalCost;
      cashReceived = sellingPrice;
    }

    final updatedCars = List<CarModel>.from(state.ownedCars)
      ..removeAt(carIndex);

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

  /// Sell an owned car via Consignment Auction
  bool sellCarAtAuction({
    required String carId,
    required double salePrice,
    required double commission,
    required double fixedFee,
    required String buyerName,
  }) {
    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    if (car.isLockedInShowcase || car.isRented || car.isConsignment) return false;

    final double totalDeductions = commission + fixedFee;
    final double netCashReceived = math.max(0.0, salePrice - totalDeductions);
    final double profit = netCashReceived - car.totalCost;

    final updatedCars = List<CarModel>.from(state.ownedCars)..removeAt(carIndex);

    final record = SaleRecordModel(
      id: 'auction_sale_${DateTime.now().millisecondsSinceEpoch}',
      carTitle: '${car.modelYear} ${car.brand} ${car.modelName} • Müzayede',
      buyerName: buyerName,
      purchasePrice: car.currentPurchasePrice,
      salePrice: salePrice,
      netProfit: profit,
      saleDay: state.currentDay,
      saleDate: DateTime.now(),
      isConsignment: false,
      maintenanceCost: car.maintenanceCost,
    );

    final int newCarsSold = state.carsSold + 1;
    state = state.copyWith(
      balance: state.balance + netCashReceived,
      ownedCars: updatedCars,
      totalProfit: state.totalProfit + profit,
      carsSold: newCarsSold,
      salesHistory: [record, ...state.salesHistory],
    );

    final int saleXp = 100 +
        (profit > 0 ? (35.0 * math.log(1.0 + profit / 5000.0)).round() : 0)
            .clamp(0, 120);
    addXP(saleXp.clamp(0, 220));
    checkAchievement('first_sale');
    checkAndAwardFirstTimeAction(FirstTimeActionKeys.firstCarSell);
    updateMissionProgress(MissionType.sellCars, 1);
    if (profit > 0) {
      updateMissionProgress(MissionType.earnProfit, profit.toInt());
    }
    saveState();
    return true;
  }

  /// Directly purchase a car
  bool buyCarDirectly(CarModel car, double price) {
    if (state.balance < price) return false;
    if (state.ownedCars.length >= state.maxGarageSlots) return false;
    final logEntry =
        'Gün ${state.currentDay}: ₺${price.round()} bedelle doğrudan satın alındı.';
    final finalCar = car.copyWith(
      currentPurchasePrice: price,
      provenanceLog: [...car.provenanceLog, logEntry],
    );
    final modelKey = '${finalCar.brand}_${finalCar.modelName}'
        .toLowerCase()
        .replaceAll(' ', '_');
    final updatedAlbum =
        <String>{...state.discoveredCarModelIds, modelKey}.toList();

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
    if (state.unlockedDecorIds.contains(decorId)) {
      return false; // Prevent duplicate purchase / spamming
    }
    if (state.balance < cost) return false;

    final updatedDecors = [...state.unlockedDecorIds, decorId];
    final updatedReputation =
        (state.reputationScore + reputationBonus.toInt()).clamp(0, 1000);

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

    final updatedReputation =
        (state.reputationScore + campaign.reputationReward).clamp(0, 1000);

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
    final updatedReputation =
        (state.reputationScore + item.reputationBonus).clamp(0, 1000);

    String? suit = state.equippedSuitId;
    String? acc = state.equippedAccessoryId;
    String? decor = state.equippedOfficeDecorId;

    if (item.isApparel) suit = item.id;
    if (item.isAccessory) acc = item.id;
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

    if (item.isApparel) {
      state = state.copyWith(equippedSuitId: item.id);
    } else if (item.isAccessory) {
      state = state.copyWith(equippedAccessoryId: item.id);
    } else if (item.category == 'officeDecor') {
      state = state.copyWith(equippedOfficeDecorId: item.id);
    }
    saveState();
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
    if (updatedCar.expertise.engineCondition == 100.0 &&
        updatedCar.isDetailedCleaned) {
      checkAchievement('restoration_king');
    }
    saveState();
  }

  /// Boosts district market share through local marketing campaign (§1.4 / Q8)
  bool boostDistrictMarketShare(
      String districtKey, double amount, double cost) {
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
    final targetIndex =
        state.ownedCars.indexWhere((c) => c.id == offer.targetCarId);
    if (targetIndex == -1) return false;

    final targetCar = state.ownedCars[targetIndex];
    if (targetCar.isLockedInShowcase ||
        targetCar.isRented ||
        targetCar.isConsignment) {
      return false;
    }
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
    final updatedTradeOffers =
        state.incomingTradeInOffers.where((t) => t.id != offer.id).toList();
    // Remove purchase offers for the target car
    final updatedOffers =
        state.incomingOffers.where((o) => o.carId != targetCar.id).toList();

    // Calculate profit
    final effectiveSalePrice =
        tradedCar.estimatedRealValue + offer.cashDifference;
    final netProfit = effectiveSalePrice - targetCar.totalCost;

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
    final updatedOffers =
        state.incomingTradeInOffers.where((t) => t.id != offerId).toList();
    state = state.copyWith(incomingTradeInOffers: updatedOffers);
    saveState();
  }

  /// Buys an industry gossip / asymmetric intel item (§4.6.3)
  bool buyGossipItem(GossipItemModel gossip) {
    if (gossip.isPurchased) return false;
    final npcKey =
        gossip.sourceNpc == 'cayci_necati' ? 'necati' : gossip.sourceNpc;
    final isDost = state.hasHighNpcTrust(npcKey);
    final effectiveCost =
        isDost ? (gossip.cost * 0.50).roundToDouble() : gossip.cost;
    if (state.balance < effectiveCost) return false;

    final currentGossips = state.activeGossips.isNotEmpty
        ? state.activeGossips
        : GossipEngine.generateDailyGossips(state.currentDay);

    final updatedGossips = currentGossips.map((g) {
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
    updateMissionProgress(MissionType.gossipListen, 1);
    saveState();
    return true;
  }

  /// Spreads a market rumor / gossip through the tea house apprentice (§4.6.3 / Market Whisperer)
  bool spreadMarketRumor(String segment, [double cost = 2500.0]) {
    if (state.lastGossipSpreadDay >= state.currentDay) return false;
    if (state.balance < cost) return false;

    final newRumor = PlayerSpreadGossipModel(
      id: 'rumor_${state.currentDay}_${DateTime.now().millisecondsSinceEpoch}',
      targetSegment: segment,
      createdDay: state.currentDay,
      expiresDay: state.currentDay + 3,
      priceMultiplier: 1.15,
    );

    final updatedRumors = List<PlayerSpreadGossipModel>.from(state.playerSpreadGossips)
      ..removeWhere((r) => r.isExpired(state.currentDay))
      ..add(newRumor);

    final updatedEvents = List<GameEventModel>.from(state.recentEvents);
    updatedEvents.insert(
      0,
      GameEventModel(
        id: 'rumor_spread_${newRumor.id}',
        title: '$segment • Sanayide Fısıltı Başlatıldı',
        description: 'Çırağa ₺${cost.toStringAsFixed(0)} bahşiş verildi. Sanayide $segment araçlara yoğun talep olduğu fısıltısı 3 gün boyunca etkili olacak.',
        type: GameEventType.goodEvent,
        amount: -cost,
        date: DateTime.now(),
      ),
    );

    state = state.copyWith(
      balance: state.balance - cost,
      playerSpreadGossips: updatedRumors,
      lastGossipSpreadDay: state.currentDay,
      recentEvents: updatedEvents,
    );

    addXP(25);
    saveState();
    return true;
  }

  /// Accepts a consignment vehicle offer from an NPC (§4.6.1)
  bool acceptConsignmentOffer(CarModel consignmentCar) {
    if (state.ownedCars.length >= state.maxGarageSlots) return false;

    final updatedOwnedCars = List<CarModel>.from(state.ownedCars)
      ..add(consignmentCar);
    final updatedConsignmentOffers = state.consignmentOffers
        .where((c) => c.id != consignmentCar.id)
        .toList();

    state = state.copyWith(
      ownedCars: updatedOwnedCars,
      consignmentOffers: updatedConsignmentOffers,
    );

    addXP(20);
    updateMissionProgress(MissionType.consignmentAccept, 1);
    saveState();
    return true;
  }

  /// Prepares and starts a night race by deducting entry fee and applying wear
  NightRaceResult startNightRace(CarModel car, {NightRivalModel? rival}) {
    final activeRival = rival ?? NightMarketEngine.getMatchedRival(car);
    final entryFee = NightMarketEngine.getEntryFeeForRival(activeRival);
    if (state.dailyRacesRemaining <= 0) {
      return const NightRaceResult(
        isWon: false,
        prizeMoney: 0,
        reputationBonus: 0,
        raceSummary:
            'Bugünkü tüm 3 yarış hakkınızı kullandınız! Gece yarışları yarın tekrar açılacak.',
        rivalName: 'Yarış Hakemleri',
        rivalCarName: 'Pist Kapalı',
      );
    }

    if (state.balance < entryFee) {
      return NightRaceResult(
        isWon: false,
        prizeMoney: 0,
        reputationBonus: 0,
        raceSummary:
            'Bu yarışa katılmak için ₺${entryFee.toInt()} giriş bahsi gereklidir!',
        rivalName: 'Bahis Masası',
        rivalCarName: 'Kasa Yetersiz',
      );
    }

    if (car.expertise.engineCondition < 30) {
      return const NightRaceResult(
        isWon: false,
        prizeMoney: 0,
        reputationBonus: 0,
        raceSummary:
            'Motor sağlığı %30 altında olan yıpranmış araçlar piste çıkarılamaz!',
        rivalName: 'Pist Güvenliği',
        rivalCarName: 'Mekanik İptal',
      );
    }

    // 1. Deduct entry fee and apply 8-12% engine & transmission wear
    final wearAmount = 8 + random.nextInt(5);
    final updatedExpertise = car.expertise.copyWith(
      engineCondition:
          (car.expertise.engineCondition - wearAmount).clamp(5, 100),
      transmissionCondition:
          (car.expertise.transmissionCondition - (wearAmount ~/ 2))
              .clamp(5, 100),
    );
    final updatedCar = car.copyWith(expertise: updatedExpertise);
    final updatedCars =
        state.ownedCars.map((c) => c.id == car.id ? updatedCar : c).toList();
    final remainingRaces = (state.dailyRacesRemaining - 1).clamp(0, 3);

    state = state.copyWith(
      balance: state.balance - entryFee,
      ownedCars: updatedCars,
      dailyRacesRemaining: remainingRaces,
    );

    updateMissionProgress(MissionType.nightMarketVisit, 1);
    saveState();

    return NightRaceResult(
      isWon: false,
      prizeMoney: NightMarketEngine.getBasePrizeForRival(activeRival),
      reputationBonus: NightMarketEngine.getRepBonusForRival(activeRival),
      raceSummary: 'Yarış başladı!',
      rivalName: activeRival.name,
      rivalCarName: activeRival.carName,
      rivalTitle: activeRival.title,
      playerPowerScore: NightMarketEngine.calculatePlayerPower(updatedCar),
      rivalPowerScore: activeRival.basePower,
    );
  }

  /// Resolves the final interactive outcome of a night race (§4.4)
  void resolveNightRaceOutcome({
    required CarModel car,
    required NightRivalModel rival,
    required NightRaceResult finalResult,
  }) {
    if (finalResult.isWon) {
      state = state.copyWith(
        balance: state.balance + finalResult.prizeMoney,
        reputationScore:
            (state.reputationScore + finalResult.reputationBonus).clamp(0, 1000),
      );
      addXP(50);
    } else {
      state = state.copyWith(
        reputationScore:
            (state.reputationScore + finalResult.reputationBonus).clamp(0, 1000),
      );
    }
    saveState();
  }

  /// Enters an underground night modification street race with synchronous resolution (§4.4)
  NightRaceResult enterNightRace(CarModel car, {NightRivalModel? rival}) {
    final activeRival = rival ?? NightMarketEngine.getMatchedRival(car);
    final startRes = startNightRace(car, rival: activeRival);
    if (state.dailyRacesRemaining == 0 &&
        startRes.rivalCarName == 'Pist Kapalı') {
      return startRes;
    }
    if (startRes.rivalCarName == 'Kasa Yetersiz' ||
        startRes.rivalCarName == 'Mekanik İptal') {
      return startRes;
    }

    final simResult =
        NightMarketEngine.simulateNightRace(car, rival: activeRival);
    resolveNightRaceOutcome(
      car: car,
      rival: activeRival,
      finalResult: simResult,
    );
    return simResult;
  }

  /// Repair body part with tier
  RepairResult repairBodyPartWithTier(
      CarModel car, String partName, RepairTier tier) {
    final result = RepairEngine.repairBodyPart(car, partName, tier);
    if (state.balance >= result.costPaid) {
      final carWithCost = result.updatedCar.copyWith(
        maintenanceCost: car.maintenanceCost + result.costPaid,
      );
      final updatedCars = state.ownedCars
          .map((c) => c.id == car.id ? carWithCost : c)
          .toList();
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
      final carWithCost = result.updatedCar.copyWith(
        maintenanceCost: car.maintenanceCost + result.costPaid,
      );
      final updatedCars = state.ownedCars
          .map((c) => c.id == car.id ? carWithCost : c)
          .toList();
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
      final carWithCost = result.updatedCar.copyWith(
        maintenanceCost: car.maintenanceCost + result.costPaid,
      );
      final updatedCars = state.ownedCars
          .map((c) => c.id == car.id ? carWithCost : c)
          .toList();
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
  void updateCarListingDeclaration(
      String carId, ListingDeclarationType declaration) {
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
    if (listingPhotoLocation != null &&
        listingPhotoLocation != existing.listingPhotoLocation) {
      if (listingPhotoLocation == 'studio') photoCost += 1500.0;
      if (listingPhotoLocation == 'scenic') photoCost += 800.0;
    }

    final wasListedBefore = existing.isListed;
    final updatedCar = existing.copyWith(
      customListingPrice: customPrice,
      declarationType: declaration ?? existing.declarationType,
      listingPhotoLocation:
          listingPhotoLocation ?? existing.listingPhotoLocation,
      listingPhotoCount: listingPhotoCount ?? existing.listingPhotoCount,
      listingTone: listingTone ?? existing.listingTone,
      hideDamagedPhotos: hideDamagedPhotos ?? existing.hideDamagedPhotos,
      allowsInstallments: allowsInstallments ?? existing.allowsInstallments,
    );
    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    var newIncomingOffers = List<OfferModel>.from(state.incomingOffers);
    // If during tutorial the player lists their car, generate an instant buyer offer!
    if (!state.tutorialCompleted && !wasListedBefore && updatedCar.isListed) {
      final instantOffer = NegotiationEngine.generateBuyerOffer(
        updatedCar,
        updatedCar.listingPrice,
        isFinanceUnlocked: false,
      );
      newIncomingOffers.add(instantOffer);
    }

    state = state.copyWith(
      balance: (state.balance - photoCost).clamp(0.0, double.infinity),
      ownedCars: updatedCars,
      incomingOffers: newIncomingOffers,
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

  /// Batch Publish all ready, unlisted cars in garage at recommended market price (+10%)
  int publishAllReadyCars() {
    final readyCars = state.ownedCars
        .where((c) =>
            !c.isListed &&
            !c.isRented &&
            !c.isLockedInShowcase &&
            c.expertise.engineCondition >= 70 &&
            c.expertise.transmissionCondition >= 70)
        .toList();
    if (readyCars.isEmpty) return 0;

    final updatedCars = state.ownedCars.map((c) {
      if (!c.isListed &&
          !c.isRented &&
          !c.isLockedInShowcase &&
          c.expertise.engineCondition >= 70 &&
          c.expertise.transmissionCondition >= 70) {
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

    final updatedCheques = List<Cheque>.from(state.activeCheques)
      ..removeAt(chequeIndex);

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

  /// 15. Müşteri Yorumuna Esnaf Cevabı Yazma (§16)
  bool respondToReview(String reviewId, String replyText) {
    final index = state.customerReviews.indexWhere((r) => r.id == reviewId);
    if (index != -1) {
      final review = state.customerReviews[index];
      if (review.reply != null && review.reply!.isNotEmpty) return false;

      final updatedReview = review.copyWith(reply: replyText);
      List<CustomerReviewModel> updatedReviews =
          List.from(state.customerReviews);
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
    if (state.lastOfficeGrantClaimDay == state.currentDay) return 0.0;
    final grantAmount = customAmount ?? 25000.0;
    state = state.copyWith(
      balance: state.balance + grantAmount,
      lastOfficeGrantClaimDay: state.currentDay,
    );
    addXP(50);
    saveState();
    return grantAmount;
  }

  /// 17b. Koleksiyon Albümü Kilometre Taşı Ödülü Talebi
  bool claimAlbumMilestone(int milestoneTarget, double rewardAmount) {
    if (state.claimedAlbumMilestones.contains(milestoneTarget)) return false;
    final updatedClaimed = [...state.claimedAlbumMilestones, milestoneTarget];
    state = state.copyWith(
      balance: state.balance + rewardAmount,
      reputationScore: (state.reputationScore + 15).clamp(0, 1000),
      claimedAlbumMilestones: updatedClaimed,
    );
    addXP(100);
    saveState();
    return true;
  }

  /// 18. Dinamik Akıllı Kanca (Smart Hook) Reklam Ödülü İnfazı
  bool executeSmartOfficeHook(SmartHookType hookType) {
    if (state.lastSmartHookUsedDay == state.currentDay) return false;
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
            .where((c) =>
                !c.isRented &&
                (c.expertise.engineCondition < 100 ||
                    c.expertise.transmissionCondition < 100))
            .toList()
          ..sort((a, b) => a.expertise.engineCondition
              .compareTo(b.expertise.engineCondition));

        if (candidates.isNotEmpty) {
          final targetCar = candidates.first;
          final repairedParts =
              Map<String, PartStatus>.from(targetCar.expertise.bodyParts);
          repairedParts.updateAll((key, value) => PartStatus.original);

          final repairedReport = targetCar.expertise.copyWith(
            engineCondition: 100.0,
            transmissionCondition: 100.0,
            bodyParts: repairedParts,
          );

          final updatedCar = targetCar.copyWith(expertise: repairedReport);
          final updatedCars = state.ownedCars
              .map((c) => c.id == updatedCar.id ? updatedCar : c)
              .toList();
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

    final normalizedNewPlate =
        plateNumber.replaceAll(RegExp(r'\s+'), '').toUpperCase();

    // Check if another car in the garage is already using this exact plate number
    final isPlateAlreadyInUse = state.ownedCars.any((c) =>
        c.id != carId &&
        c.plateNumber.replaceAll(RegExp(r'\s+'), '').toUpperCase() ==
            normalizedNewPlate);
    if (isPlateAlreadyInUse) return false;

    // Check if target car already has this exact plate
    if (car.plateNumber.replaceAll(RegExp(r'\s+'), '').toUpperCase() ==
        normalizedNewPlate) {
      return false;
    }

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

  /// 21. 28 Günlük Esnaf Takvimi (Aylık Giriş Serisi) Ödülünü Talep Etme
  DailyLoginRewardModel? claimDailyLoginReward({DateTime? customNow, double rewardMultiplier = 1.0}) {
    final now = customNow ?? DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    if (!state.canClaimTodayStreak(todayStr)) {
      return null;
    }

    final allRewards = DailyLoginRewardModel.getSeasonalCycle(
        cycleCount: state.streakCycleCount);
    final currentDay = state.currentStreakDay.clamp(1, 28);
    final reward = allRewards.firstWhere((r) => r.dayNumber == currentDay);

    final updatedClaimed = List<int>.from(state.claimedStreakDays)
      ..add(currentDay);
    final updatedVouchers = List<String>.from(state.streakVouchers);
    if (reward.itemCode != null) {
      updatedVouchers.add(reward.itemCode!);
    }

    final isCycleCompleted = currentDay == 28;
    final nextStreakDay = isCycleCompleted ? 1 : currentDay + 1;
    final nextCycleCount =
        isCycleCompleted ? state.streakCycleCount + 1 : state.streakCycleCount;
    final nextClaimedDays = isCycleCompleted ? <int>[] : updatedClaimed;

    final lastDateStr = state.lastRealLoginDateStr;
    int newStreak = state.loginStreak;
    if (lastDateStr != null) {
      try {
        final parts = lastDateStr.split('-');
        if (parts.length == 3) {
          final lastDate = DateTime(
              int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
          final today = DateTime(now.year, now.month, now.day);
          final diff = today.difference(lastDate).inDays;
          if (diff == 1) {
            newStreak = state.loginStreak + 1;
          } else if (diff > 1) {
            newStreak = state.hasStreakFreeze ? (state.loginStreak + 1) : 1;
          }
        }
      } catch (_) {
        newStreak = state.loginStreak + 1;
      }
    } else {
      newStreak = 1;
    }

    final effectiveMoney = (reward.moneyAmount * rewardMultiplier).roundToDouble();
    final effectiveRep = (reward.reputationAmount * rewardMultiplier).round();

    state = state.copyWith(
      balance: state.balance + effectiveMoney,
      reputationScore:
          (state.reputationScore + effectiveRep).clamp(0, 1000),
      lastRealLoginDateStr: todayStr,
      lastLoginDate: now,
      lastRewardClaimDate: now,
      loginStreak: newStreak,
      currentStreakDay: nextStreakDay,
      streakCycleCount: nextCycleCount,
      claimedStreakDays: nextClaimedDays,
      streakVouchers: updatedVouchers,
    );

    addXP(effectiveRep * 15 + 50);
    saveState();
    return reward;
  }

  /// 21.1 Ödüllü Reklam ile Giriş Serisi Kurtarma ve Dondurma Kalkanı
  void activateStreakRescue() {
    state = state.copyWith(
      hasStreakFreeze: true,
      loginStreak: state.loginStreak < 1 ? 1 : state.loginStreak,
    );
    saveState();
  }

  /// 22. Şirketi Borsa İstanbul'da Halka Arz Etme (BIST: GLRD)
  double? launchPlayerCompanyIpo() {
    if (state.isCompanyListedOnBist) return null;
    if (state.level < 4 || state.carsSold < 10) return null;

    final double totalCarValue =
        state.ownedCars.fold(0.0, (sum, c) => sum + c.estimatedRealValue);
    final double totalValuation =
        (state.balance + totalCarValue + state.totalDeedValue) * 1.25;

    // %20 halka arz payı satışı kasaya nakit girer
    final double ipoCapitalRaised =
        (totalValuation * 0.20).clamp(250000.0, 50000000.0).roundToDouble();

    final playerStock = StockModel(
      symbol: 'GLRD',
      name: '${state.dealershipName} Holding A.Ş.',
      currentPrice: 125.0,
      previousPrice: 100.0,
      priceHistory: [100.0, 125.0],
      dividendYield: 0.12,
      sectorCategory: 'Otomotiv & Perakende',
    );

    final updatedMarketStocks = List<StockModel>.from(state.marketStocks)
      ..insert(0, playerStock);

    final ipoEvent = GameEventModel(
      id: 'player_ipo_${state.currentDay}',
      title: 'ŞİRKETİN BORSAYA AÇILDI: BIST: GLRD',
      description:
          '${state.dealershipName} Holding Borsa İstanbul\'da gong çalarak halka arz oldu! %20 hisse satışından kasaya ₺${CurrencyFormatter.formatShort(ipoCapitalRaised)} taze sermaye girdi.',
      type: GameEventType.income,
      amount: ipoCapitalRaised,
      date: DateTime.now(),
    );

    state = state.copyWith(
      balance: state.balance + ipoCapitalRaised,
      isCompanyListedOnBist: true,
      marketStocks: updatedMarketStocks,
      reputationScore: (state.reputationScore + 50).clamp(0, 1000),
      recentEvents: [ipoEvent, ...state.recentEvents],
    );

    addXP(500);
    saveState();
    return ipoCapitalRaised;
  }

  /// 23. GLRD Şirket Hisse Geri Alımı (Borsadan Kendi Hisselerini Toplama)
  bool buybackPlayerCompanyShares({required double amount}) {
    if (!state.isCompanyListedOnBist) return false;
    if (state.balance < amount || amount < 10000.0) return false;

    final glrdIndex = state.marketStocks.indexWhere((s) => s.symbol == 'GLRD');
    if (glrdIndex == -1) return false;

    final glrd = state.marketStocks[glrdIndex];
    // Hisse geri alımı tahtayı primlendirir (+%15)
    final newPrice =
        (glrd.currentPrice * 1.15).roundToDouble().clamp(10.0, 100000.0);
    List<double> history = List<double>.from(glrd.priceHistory)..add(newPrice);
    if (history.length > 30) history = history.sublist(history.length - 30);

    final updatedStocks = List<StockModel>.from(state.marketStocks);
    updatedStocks[glrdIndex] = glrd.copyWith(
      previousPrice: glrd.currentPrice,
      currentPrice: newPrice,
      priceHistory: history,
    );

    final buybackEvent = GameEventModel(
      id: 'glrd_buyback_${state.currentDay}',
      title: 'GLRD • Şirket Pay Geri Alımı Tamamlandı',
      description:
          'Piyasadan ${CurrencyFormatter.formatShort(amount)} tutarında şirket hissesi geri alındı. GLRD hissesi değer kazandı!',
      type: GameEventType.income,
      amount: amount,
      date: DateTime.now(),
    );

    state = state.copyWith(
      balance: state.balance - amount,
      marketStocks: updatedStocks,
      reputationScore: (state.reputationScore + 15).clamp(0, 1000),
      recentEvents: [buybackEvent, ...state.recentEvents],
    );

    addXP(100);
    saveState();
    return true;
  }
}
