import 'dart:math';
import '../../../data/models/branch_model.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/detailing_model.dart';
import '../../../data/models/expertise_model.dart';
import '../../../data/models/rental_agreement_model.dart';
import '../../../data/models/scrapyard_model.dart';
import '../../../domain/usecases/repair_engine.dart';
import '../../../domain/usecases/risk_engine.dart';
import '../../../data/models/contract_model.dart';
import '../../../data/models/mission_model.dart';
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
    updateMissionProgress(MissionType.sellCars, 1);
    if (profit > 0) updateMissionProgress(MissionType.earnProfit, profit.toInt());
    saveState();
    return true;
  }
  /// Perform market expertise on a vehicle
  bool performMarketExpertise(double cost) {
    if (state.balance < cost) return false;
    state = state.copyWith(balance: state.balance - cost);
    addXP(25);
    checkAchievement('expert_master');
    updateMissionProgress(MissionType.doExpertise, 1);
    saveState();
    return true;
  }

  /// Purchase a car from market with RiskEngine check
  PurchaseRiskOutcome? buyCar(CarModel car, double purchasePrice, {bool isExpertiseCompleted = false}) {
    if (state.balance < purchasePrice) return null;
    if (state.ownedCars.length >= state.maxGarageSlots) return null;

    final updatedBalance = state.balance - purchasePrice;
    
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

    final purchasedCar = outcome.updatedCar;
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
    updateMissionProgress(MissionType.buyCars, 1);
    saveState();
    return outcome;
  }

  /// Toggle Showcase Lock for rare/classic vehicles
  bool toggleShowcaseLock(String carId) {
    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    final updatedCar = car.copyWith(isLockedInShowcase: !car.isLockedInShowcase);
    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    state = state.copyWith(ownedCars: updatedCars);
    saveState();
    return true;
  }

  /// Upgrade Prestige Branch Tier
  bool upgradePrestigeBranch(int targetTier) {
    double cost = 350000.0;
    int extraSlots = 2;
    String tierKey = 'property_tier_2';

    if (targetTier == 3) {
      cost = 1250000.0;
      extraSlots = 4;
      tierKey = 'property_tier_3';
    } else if (targetTier == 4) {
      cost = 4500000.0;
      extraSlots = 6;
      tierKey = 'property_tier_4';
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
    if (car.isLockedInShowcase) return false;

    final profit = sellingPrice - car.currentPurchasePrice;

    final updatedCars = List<CarModel>.from(state.ownedCars)..removeAt(carIndex);
    
    state = state.copyWith(
      balance: state.balance + sellingPrice,
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
    final finalCar = car.copyWith(currentPurchasePrice: price);
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

  /// Purchase & Upgrade Branch (Advances Dealership Level directly)
  bool upgradeBranch(BranchModel branch) {
    if (state.balance < branch.requiredBalance) return false;

    final newLevel = branch.targetLevel > state.level ? branch.targetLevel : state.level;
    final updatedBuildings = Set<String>.from(state.unlockedBuildings);
    if (branch.targetLevel >= 3) updatedBuildings.add('property_tier_2');
    if (branch.targetLevel >= 4) updatedBuildings.add('property_tier_3');
    if (branch.targetLevel >= 5) updatedBuildings.add('property_tier_4');

    state = state.copyWith(
      balance: state.balance - branch.requiredBalance,
      maxGarageSlots: branch.maxGarageSlots,
      level: newLevel,
      unlockedBuildings: updatedBuildings,
    );
    addXP(250);
    checkAchievement('garage_expand');
    saveState();
    return true;
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
    updateMissionProgress(MissionType.repairParts, 1);
    if (updatedCar.expertise.engineCondition == 100.0 && updatedCar.isDetailedCleaned) {
      checkAchievement('restoration_king');
    }
    saveState();
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

  /// Updates car's custom listing price and/or declaration status
  void updateCarListingDetails(String carId, {double? customPrice, ListingDeclarationType? declaration}) {
    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return;

    final existing = state.ownedCars[carIndex];
    final updatedCar = existing.copyWith(
      customListingPrice: customPrice,
      declarationType: declaration ?? existing.declarationType,
    );
    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    state = state.copyWith(ownedCars: updatedCars);
    saveState();
  }

  /// Rent a Car with strict market rate validation and state sync
  bool rentCar(String carId, double dailyRate) {
    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;
    
    final car = state.ownedCars[carIndex];
    if (car.isRented || state.activeRentals.any((r) => r.carId == carId)) return false;

    // Cap daily rate to maximum 1.2% of car value to prevent economy exploits
    final carValue = car.currentPurchasePrice > 0 ? car.currentPurchasePrice : car.estimatedRealValue;
    final maxAllowedDailyRate = (carValue * 0.012).clamp(100.0, 50000.0);
    final validatedDailyRate = dailyRate.clamp(100.0, maxAllowedDailyRate);

    final updatedCar = car.copyWith(isRented: true);
    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    final agreement = RentalAgreement(
      id: 'rent_${DateTime.now().millisecondsSinceEpoch}',
      carId: carId,
      dailyRate: validatedDailyRate,
    );

    state = state.copyWith(
      ownedCars: updatedCars,
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

  /// Purchase and dismantle a scrap car into salvaged parts
  bool buyAndDismantleScrapCar(String scrapCarId) {
    final scrapIndex = state.scrapyardCars.indexWhere((c) => c.id == scrapCarId);
    if (scrapIndex == -1) return false;

    final scrapCar = state.scrapyardCars[scrapIndex];
    if (state.balance < scrapCar.scrapPrice) return false;

    final generatedParts = scrapCar.parts.isNotEmpty
        ? scrapCar.parts
        : ScrapyardCar.generateRandomParts('${scrapCar.brand} ${scrapCar.modelName}', scrapCar.scrapPrice * 1.5);

    final updatedScrapCars = List<ScrapyardCar>.from(state.scrapyardCars)..removeAt(scrapIndex);

    state = state.copyWith(
      balance: state.balance - scrapCar.scrapPrice,
      salvagedParts: [...state.salvagedParts, ...generatedParts],
      scrapyardCars: updatedScrapCars,
    );

    addXP(60);
    checkAchievement('first_scrap');
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

    // Calculate boost depending on part category and condition
    double engineBoost = 0.0;
    double transBoost = 0.0;

    if (part.category == 'engine' || part.category == 'turbo' || part.category == 'ecu' || part.category == 'radiator') {
      engineBoost = (part.conditionPercent * 0.35).clamp(10.0, 45.0);
    } else if (part.category == 'transmission' || part.category == 'brakes' || part.category == 'suspension') {
      transBoost = (part.conditionPercent * 0.35).clamp(10.0, 45.0);
    }

    final newEngineCond = (car.expertise.engineCondition + engineBoost).clamp(0.0, 100.0);
    final newTransCond = (car.expertise.transmissionCondition + transBoost).clamp(0.0, 100.0);

    final updatedCar = car.copyWith(
      expertise: car.expertise.copyWith(
        engineCondition: newEngineCond,
        transmissionCondition: newTransCond,
      ),
    );

    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;
    final updatedParts = List<SalvagedPart>.from(state.salvagedParts)..removeAt(partIndex);

    state = state.copyWith(
      ownedCars: updatedCars,
      salvagedParts: updatedParts,
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
    required bool setPolished,
    required bool setDetailed,
  }) {
    if (state.balance < cost) return false;
    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    final newValue = car.baseMarketValue * (1.0 + valueBoostPercent);

    final updatedCar = car.copyWith(
      baseMarketValue: newValue,
      isWashed: true,
      isPolished: setPolished ? true : car.isPolished,
      isDetailedCleaned: setDetailed ? true : car.isDetailedCleaned,
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

  /// Perform specialized workshop station repair
  bool performWorkshopStationRepair(
    String carId, {
    required String repairType,
    required double cost,
  }) {
    if (state.balance < cost) return false;
    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    final exp = car.expertise;

    ExpertiseReport updatedExp = exp;
    double valueBoost = 1.0;

    switch (repairType) {
      case 'engine':
        updatedExp = exp.copyWith(engineCondition: 100.0);
        valueBoost = 1.10;
        break;
      case 'transmission':
        updatedExp = exp.copyWith(transmissionCondition: 100.0);
        valueBoost = 1.08;
        break;
      case 'ecu':
        updatedExp = exp.copyWith(engineCondition: (exp.engineCondition + 15).clamp(0.0, 100.0));
        valueBoost = 1.05;
        break;
      case 'bodywork':
        final repairedParts = Map<String, PartStatus>.from(exp.bodyParts);
        repairedParts.forEach((key, value) {
          if (value == PartStatus.changed || value == PartStatus.painted || value == PartStatus.damaged) {
            repairedParts[key] = PartStatus.original;
          }
        });
        updatedExp = exp.copyWith(bodyParts: repairedParts);
        valueBoost = 1.15;
        break;
      case 'chassis':
        updatedExp = exp.copyWith(
          engineCondition: 100.0,
          transmissionCondition: 100.0,
        );
        valueBoost = 1.20;
        break;
    }

    final initialCarValue = max(100000.0, car.currentPurchasePrice > 0 ? car.currentPurchasePrice : car.estimatedRealValue);
    final maxAllowedValue = initialCarValue * 1.35;

    final updatedCar = car.copyWith(
      expertise: updatedExp,
      baseMarketValue: (car.baseMarketValue * valueBoost).clamp(car.baseMarketValue * 0.5, maxAllowedValue),
    );

    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    state = state.copyWith(
      balance: state.balance - cost,
      ownedCars: updatedCars,
    );

    addXP(50);
    saveState();
    return true;
  }

  /// Emergency Bailout: Dede Mirası Can Suyu (₺50.000)
  bool claimEmergencyBailout() {
    final totalLiquidAssets = state.balance + state.bankDepositBalance;
    if (totalLiquidAssets > 15000 || state.ownedCars.isNotEmpty) return false;
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
    saveState();
    return true;
  }
}
