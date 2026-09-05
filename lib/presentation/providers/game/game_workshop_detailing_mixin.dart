import '../../../core/constants/first_time_action_keys.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/car_wash_job_model.dart';
import '../../../data/models/dealership_model.dart';
import '../../../data/models/detailing_model.dart';
import '../../../data/models/expertise_model.dart';
import '../../../data/models/mega_systems_extensions_model.dart';
import '../../../data/models/mission_model.dart';
import '../../../data/models/staff_model.dart';
import '../../../data/models/workshop_job_model.dart';
import '../../../domain/usecases/repair_engine.dart';
import 'game_base_notifier.dart';

mixin GameWorkshopDetailingMixin on GameBaseNotifier {
  /// Apply detailing option
  bool applyDetailingOption(String carId, DetailingOption option) {
    if (state.balance < option.cost) return false;

    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    if (car.appliedDetailingOptionIds.contains(option.id)) return false;

    final updatedCar = car.copyWith(
      appliedDetailingOptionIds: [...car.appliedDetailingOptionIds, option.id],
      maintenanceCost: car.maintenanceCost + option.cost,
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

    final updatedCar = RepairEngine.performDetailing(car).copyWith(
      maintenanceCost: car.maintenanceCost + cost,
    );
    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    state = state.copyWith(
      balance: state.balance - cost,
      ownedCars: updatedCars,
    );

    addXP(20);
    if (updatedCar.expertise.engineCondition == 100.0 &&
        updatedCar.isDetailedCleaned) {
      checkAchievement('restoration_king');
    }
    saveState();
    return true;
  }

  /// Wash and Polish
  bool washAndPolishCar(String carId,
      {required bool wash, required bool polish}) {
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
      maintenanceCost: car.maintenanceCost + cost,
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

  /// Purchase an equipment upgrade for Wash or Workshop
  bool purchaseEquipmentUpgrade(String equipmentId, double cost) {
    if (state.balance < cost) return false;
    if (state.unlockedBuildings.contains(equipmentId)) return false;

    final updatedBuildings = Set<String>.from(state.unlockedBuildings)
      ..add(equipmentId);
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

    final isStandardWash =
        setWashed || (!setInterior && !setPolished && !setDetailed);

    if (setDetailed && car.isDetailedCleaned) return false;
    if (setPolished && !setDetailed && car.isPolished) return false;
    if (setInterior && car.isInteriorCleaned) return false;
    if (isStandardWash &&
        !setInterior &&
        !setPolished &&
        !setDetailed &&
        car.isWashed) {
      return false;
    }

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
      maintenanceCost: car.maintenanceCost + cost,
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
    if (state.characterOrigin == CharacterOrigin.sanayiCiragi) {
      finalCost *= 0.85;
    }
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
        final hasDamagedOrChanged =
            exp.bodyParts.values.any((v) => v != PartStatus.original);
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
      baseMarketValue: car.baseMarketValue,
      maintenanceCost: car.maintenanceCost + finalCost,
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
      transmissionCondition:
          (exp.transmissionCondition + 15.0).clamp(0.0, 100.0),
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

  /// Apply custom color paint respray with 1-day oven curing duration
  bool applyCustomPaintRespray(String carId, CustomPaintColor paint) {
    if (state.balance < paint.cost) return false;

    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    if (car.isRented || car.isPainting) return false;

    final targetReadyDay = state.currentDay + 1;
    final updatedCar = car.copyWith(
      paintReadyDay: targetReadyDay,
      pendingPaintHex: paint.hex,
      pendingPaintName: paint.name,
      pendingPaintRarity: paint.buyerAppealMultiplier >= 1.20 ? 'rare' : 'common',
      maintenanceCost: car.maintenanceCost + paint.cost,
    );

    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    state = state.copyWith(
      balance: state.balance - paint.cost,
      ownedCars: updatedCars,
    );

    saveState();
    return true;
  }

  /// Wash and polish all cars in garage in one batch
  bool washAllCars() {
    if (state.ownedCars.isEmpty) return false;
    final hasWasher = state.hiredStaff.any((s) => s.role == StaffRole.washer);
    final unwashedCars = state.ownedCars
        .where((c) =>
            !c.isRented &&
            (!c.isWashed || !c.isPolished || !c.isDetailedCleaned))
        .toList();
    if (unwashedCars.isEmpty) return false;

    final totalCost = hasWasher ? 0.0 : (unwashedCars.length * 600.0);
    if (state.balance < totalCost) return false;

    final costPerCar = hasWasher ? 0.0 : 600.0;
    final updatedCars = state.ownedCars.map((c) {
      if (c.isRented) return c;
      final wasClean = c.isWashed && c.isPolished && c.isDetailedCleaned;
      return c.copyWith(
        isWashed: true,
        isPolished: true,
        maintenanceCost: wasClean ? c.maintenanceCost : (c.maintenanceCost + costPerCar),
      );
    }).toList();

    state = state.copyWith(
      balance: state.balance - totalCost,
      ownedCars: updatedCars,
    );

    addXP(15 * unwashedCars.length);
    checkAndAwardFirstTimeAction(FirstTimeActionKeys.firstCarWash);
    updateMissionProgress(MissionType.washCars, unwashedCars.length);
    saveState();
    return true;
  }

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
    final updatedOptions = car.appliedDetailingOptionIds
        .where((id) => !id.startsWith('scent_'))
        .toList();
    updatedOptions.add(scent.id);

    final updatedCar = car.copyWith(
      appliedDetailingOptionIds: updatedOptions,
      maintenanceCost: car.maintenanceCost + scent.cost,
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

    final updatedOptions = List<String>.from(car.appliedDetailingOptionIds)
      ..add('headlight_restoration');
    final updatedCar = car.copyWith(
      appliedDetailingOptionIds: updatedOptions,
      maintenanceCost: car.maintenanceCost + cost,
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

    final updatedOptions = List<String>.from(car.appliedDetailingOptionIds)
      ..add('iron_decon');
    final updatedCar = car.copyWith(
      appliedDetailingOptionIds: updatedOptions,
      maintenanceCost: car.maintenanceCost + cost,
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

    final updatedOptions = List<String>.from(car.appliedDetailingOptionIds)
      ..add('pdr_repaired');
    final updatedCar = car.copyWith(
      appliedDetailingOptionIds: updatedOptions,
      maintenanceCost: car.maintenanceCost + cost,
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

    final updatedOptions = List<String>.from(car.appliedDetailingOptionIds)
      ..add('tuvturk_certified');
    final updatedCar = car.copyWith(
      appliedDetailingOptionIds: updatedOptions,
      maintenanceCost: car.maintenanceCost + cost,
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
    if (state.hiredStaff.isEmpty) return false;
    if (state.hiredStaff.every((s) => s.morale >= 100)) return false;
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

  /// 1. Sabah Siftahı & Kasa Duası Ritüeli (§5)
  bool performMorningSiftah() {
    if (state.lastSiftahDay == state.currentDay) return false;
    const siftahCoin = 100.0;
    if (state.balance < siftahCoin) return false;

    final updatedStaff = state.hiredStaff.map((s) {
      return s.copyWith(morale: (s.morale + 15).clamp(0, 100));
    }).toList();

    state = state.copyWith(
      balance: state.balance + siftahCoin,
      hiredStaff: updatedStaff,
      lastSiftahDay: state.currentDay,
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

    final updatedOptions = List<String>.from(car.appliedDetailingOptionIds)
      ..add('dyno_certified');

    final updatedCar = car.copyWith(
      appliedDetailingOptionIds: updatedOptions,
      maintenanceCost: car.maintenanceCost + tier.cost,
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

    final updatedOptions = List<String>.from(car.appliedDetailingOptionIds)
      ..add(stage.id);

    final updatedCar = car.copyWith(
      appliedDetailingOptionIds: updatedOptions,
      maintenanceCost: car.maintenanceCost + stage.cost,
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

    final updatedOptions = List<String>.from(car.appliedDetailingOptionIds)
      ..add('bodykit_tint');

    final updatedCar = car.copyWith(
      appliedDetailingOptionIds: updatedOptions,
      maintenanceCost: car.maintenanceCost + cost,
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

  /// Cold stamp chassis repairs (§22)
  bool coldStampChassis(String carId) {
    const cost = 4000.0;
    if (state.balance < cost) return false;

    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    if (car.isRented || car.isConsignment || car.isChassisRepaired) {
      return false;
    }

    final updatedOptions = List<String>.from(car.appliedDetailingOptionIds)
      ..add('chassis_restamped');

    final updatedCar = car.copyWith(
      appliedDetailingOptionIds: updatedOptions,
      isChassisRepaired: true,
      maintenanceCost: car.maintenanceCost + cost,
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

  /// 12. Fırçasız Otomatik Tünel Yıkama Ünitesi Satın Alma (§4)
  bool purchaseAutoWashTunnel() {
    const cost = 45000.0;
    if (state.balance < cost) return false;
    if (state.unlockedBuildings.contains('auto_wash_tunnel')) return false;

    final updatedBuildings = Set<String>.from(state.unlockedBuildings)
      ..add('auto_wash_tunnel');

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
    if (car.isRented ||
        car.isConsignment ||
        car.appliedDetailingOptionIds.contains('ozone_sanitized')) {
      return false;
    }
    final updatedOptions = List<String>.from(car.appliedDetailingOptionIds)
      ..add('ozone_sanitized');

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
}
