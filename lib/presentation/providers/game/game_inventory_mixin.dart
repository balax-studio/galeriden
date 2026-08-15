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
import '../../../data/models/dealership_model.dart';
import '../../../data/models/mission_model.dart';
import '../../../data/models/staff_model.dart';
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
    adjustNpcRelationship('haydar_usta', 2);
    addXP(25);
    checkAchievement('expert_master');
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
    updateMissionProgress(MissionType.buyCars, 1);
    saveState();
    return outcome;
  }

  /// Toggle Showcase Lock for rare/classic vehicles (§1.5, §2.6)
  bool toggleShowcaseLock(String carId) {
    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    final bool newLocked = !car.isLockedInShowcase;
    final updatedCar = car.copyWith(isLockedInShowcase: newLocked);
    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    int newRep = state.reputationScore;
    if (newLocked) {
      newRep = (state.reputationScore + 5).clamp(0, 100);
      addXP(50);
    }

    state = state.copyWith(
      ownedCars: updatedCars,
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

  /// Change character origin (§2.1)
  void setCharacterOrigin(CharacterOrigin origin) {
    state = state.copyWith(characterOrigin: origin);
    saveState();
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
        '/workshop',
        '/tuning-studio',
        '/staff',
        '/staff-academy',
        '/history',
      });
    }
    if (branch.targetLevel >= 3) {
      updatedBuildings.addAll({
        'property_tier_3',
        '/auction',
        '/finance',
        '/bank-investments',
        '/stock-market',
        '/reviews',
        '/showroom-decor',
      });
    }
    if (branch.targetLevel >= 4) {
      updatedBuildings.addAll({
        'property_tier_4',
        '/scrapyard',
        '/rent-a-car',
        '/black-market',
        '/side-businesses',
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
    final updatedReputation = (state.reputationScore + reputationBonus.toInt()).clamp(0, 500);

    state = state.copyWith(
      balance: state.balance - cost,
      unlockedDecorIds: updatedDecors,
      reputationScore: updatedReputation,
    );

    addXP(150);
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
    double effectivePrice = scrapCar.scrapPrice;
    if (state.hasHighNpcTrust('cikmaci_ibo')) {
      effectivePrice = (effectivePrice * 0.75).roundToDouble(); // Çıkmacı İbo dost indirimi -%25!
    }
    if (state.balance < effectivePrice) return false;

    final generatedParts = scrapCar.parts.isNotEmpty
        ? scrapCar.parts
        : ScrapyardCar.generateRandomParts('${scrapCar.brand} ${scrapCar.modelName}', scrapCar.scrapPrice * 1.5);

    final updatedScrapCars = List<ScrapyardCar>.from(state.scrapyardCars)..removeAt(scrapIndex);

    state = state.copyWith(
      balance: state.balance - effectivePrice,
      salvagedParts: [...state.salvagedParts, ...generatedParts],
      scrapyardCars: updatedScrapCars,
    );

    adjustNpcRelationship('cikmaci_ibo', 2);
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

    final isStandardWash = setWashed || (!setInterior && !setPolished && !setDetailed);

    if (setDetailed && car.isDetailedCleaned) return false;
    if (setPolished && !setDetailed && car.isPolished) return false;
    if (setInterior && car.isInteriorCleaned) return false;
    if (isStandardWash && !setInterior && !setPolished && !setDetailed && car.isWashed) return false;

    final newValue = car.baseMarketValue * (1.0 + valueBoostPercent);

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
    double valueBoost = 1.0;

    switch (repairType) {
      case 'engine':
        if (exp.engineCondition >= 99.5) return false;
        updatedExp = exp.copyWith(engineCondition: 100.0);
        valueBoost = 1.10;
        break;
      case 'transmission':
        if (exp.transmissionCondition >= 99.5) return false;
        updatedExp = exp.copyWith(transmissionCondition: 100.0);
        valueBoost = 1.08;
        break;
      case 'ecu':
        if (exp.isEcuCleaned) return false;
        updatedExp = exp.copyWith(
          isEcuCleaned: true,
          engineCondition: (exp.engineCondition + 15).clamp(0.0, 100.0),
        );
        valueBoost = 1.05;
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
        valueBoost = 1.15;
        break;
      case 'chassis':
        if (exp.isChassisAligned) return false;
        updatedExp = exp.copyWith(
          isChassisAligned: true,
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
      balance: state.balance - finalCost,
      ownedCars: updatedCars,
    );

    addXP(50);
    saveState();
    return true;
  }

  /// Wash and polish all cars in garage in one batch
  bool washAllCars() {
    if (state.ownedCars.isEmpty) return false;
    final hasWasher = state.hiredStaff.any((s) => s.role == StaffRole.washer);
    final unwashedCars = state.ownedCars.where((c) => !c.isWashed || !c.isPolished || !c.isDetailedCleaned).toList();
    if (unwashedCars.isEmpty) return false;

    final totalCost = hasWasher ? 0.0 : (unwashedCars.length * 600.0);
    if (state.balance < totalCost) return false;

    final updatedCars = state.ownedCars.map((c) {
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
    saveState();
    return true;
  }

  /// Emergency Bailout: Dede Mirası Can Suyu (₺50.000)
  bool claimEmergencyBailout() {
    final totalAssets = state.balance +
        state.bankDepositBalance +
        state.ownedCars.fold<double>(0.0, (s, c) => s + c.estimatedRealValue);
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
    saveState();
    return true;
  }

  /// Alias for doDailyScrapyardSideGig
  bool workScrapyardSideGig() => doDailyScrapyardSideGig();
}
