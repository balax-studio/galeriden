import 'dart:math';
import '../../../data/models/car_model.dart';
import '../../../data/models/mission_model.dart';
import '../../../data/models/scrapyard_model.dart';
import '../../../data/models/staff_model.dart';
import 'game_base_notifier.dart';

mixin GameScrapyardMixin on GameBaseNotifier {
  /// Buys a scrap car from the scrapyard so player owns it
  bool buyScrapCar(String scrapCarId) {
    final scrapIndex =
        state.scrapyardCars.indexWhere((c) => c.id == scrapCarId);
    if (scrapIndex == -1) return false;

    final scrapCar = state.scrapyardCars[scrapIndex];
    if (scrapCar.isPurchased) return true;

    double effectivePrice = scrapCar.scrapPrice;
    if (state.hasHighNpcTrust('cikmaci_ibo')) {
      effectivePrice = (effectivePrice * 0.75)
          .roundToDouble(); // Çıkmacı İbo dost indirimi -%25!
    }
    if (state.balance < effectivePrice) return false;

    final updatedScrapCar = scrapCar.copyWith(
      isPurchased: true,
      parts: scrapCar.parts.isNotEmpty
          ? scrapCar.parts
          : ScrapyardCar.generateRandomParts(
              '${scrapCar.brand} ${scrapCar.modelName}',
              scrapCar.scrapPrice * 1.5),
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
  BulkScrapDismantleResult buyAndDismantleScrapCar(String scrapCarId,
      {Random? random}) {
    final scrapIndex =
        state.scrapyardCars.indexWhere((c) => c.id == scrapCarId);
    if (scrapIndex == -1) {
      return const BulkScrapDismantleResult(
        success: false,
        message: 'Hurda araç bulunamadı.',
      );
    }

    final scrapCar = state.scrapyardCars[scrapIndex];
    double effectivePrice = scrapCar.scrapPrice;
    if (state.hasHighNpcTrust('cikmaci_ibo')) {
      effectivePrice = (effectivePrice * 0.75)
          .roundToDouble(); // Çıkmacı İbo dost indirimi -%25!
    }
    if (state.balance < effectivePrice) {
      return const BulkScrapDismantleResult(
        success: false,
        message: 'Yetersiz bakiye.',
      );
    }

    final allParts = scrapCar.parts.isNotEmpty
        ? scrapCar.parts
        : ScrapyardCar.generateRandomParts(
            '${scrapCar.brand} ${scrapCar.modelName}',
            scrapCar.scrapPrice * 1.5);

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

    final updatedScrapCars = List<ScrapyardCar>.from(state.scrapyardCars)
      ..removeAt(scrapIndex);

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

  /// Dismantle a single specific part from a scrap car
  SinglePartDismantleResult dismantleSinglePartFromScrap(
    String scrapCarId,
    String partId, {
    Random? random,
    bool? forceSuccess,
    int? customCondition,
  }) {
    final scrapIndex =
        state.scrapyardCars.indexWhere((c) => c.id == scrapCarId);
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
    final part = customCondition != null
        ? originalPart.copyWith(conditionPercent: customCondition)
        : originalPart;
    final updatedParts = List<SalvagedPart>.from(scrapCar.parts)
      ..removeAt(partIndex);
    final updatedScrapCar = scrapCar.copyWith(parts: updatedParts);

    final updatedScrapCars = List<ScrapyardCar>.from(state.scrapyardCars);
    updatedScrapCars[scrapIndex] = updatedScrapCar;

    final rng = random ?? Random();
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
        message:
            'Civata kaynamış! ${part.name} sökülürken hasar gördü ve ziyan oldu.',
      );
    }
  }

  /// Crush the remaining car chassis into scrap metal and extract surprise finds
  ChassisCrushResult crushChassisToScrapMetal(String scrapCarId) {
    final scrapIndex =
        state.scrapyardCars.indexWhere((c) => c.id == scrapCarId);
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
        message:
            'Şasiyi presleyebilmek için önce hurda aracı satın almalısınız.',
      );
    }
    final scrapMetalVal = scrapCar.chassisScrapValue;
    final surpriseVal = scrapCar.surpriseFindValue;
    final surpriseName = scrapCar.surpriseFindItem;
    final totalEarned = scrapMetalVal + surpriseVal;

    final updatedScrapCars = List<ScrapyardCar>.from(state.scrapyardCars)
      ..removeAt(scrapIndex);

    state = state.copyWith(
      balance: state.balance + totalEarned,
      scrapyardCars: updatedScrapCars,
    );

    addXP(30);
    saveState();

    String msg =
        '${scrapCar.brand} ${scrapCar.modelName} şasisi preslendi! ₺${scrapMetalVal.toInt()} hurda demir geliri kazanıldı.';
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

    if (part.category != order.requiredCategory) return false;

    if (order.requiredCarBrand != null) {
      final matchesBrand = part.carModelName
          .toLowerCase()
          .contains(order.requiredCarBrand!.toLowerCase());
      if (!matchesBrand) return false;
    }

    if (part.tier.index < order.minQualityTier.index) return false;

    final updatedParts = List<SalvagedPart>.from(state.salvagedParts)
      ..removeAt(partIndex);
    final updatedOrder = order.copyWith(isCompleted: true);
    final updatedOrders = List<B2BPartOrder>.from(state.b2bPartOrders);
    updatedOrders[orderIndex] = updatedOrder;

    state = state.copyWith(
      balance: state.balance + order.offeredPrice,
      reputationScore:
          (state.reputationScore + order.reputationReward).clamp(0, 1000),
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
    final updatedParts = List<SalvagedPart>.from(state.salvagedParts)
      ..removeAt(partIndex);

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

    final isBrandMatch =
        part.carModelName.toLowerCase().contains(car.brand.toLowerCase());
    final compMultiplier = isBrandMatch ? 1.0 : 0.60;

    double engineBoost = 0.0;
    double transBoost = 0.0;

    if (part.category == 'engine' ||
        part.category == 'turbo' ||
        part.category == 'ecu' ||
        part.category == 'radiator') {
      engineBoost =
          (part.conditionPercent * 0.35 * compMultiplier).clamp(10.0, 45.0);
    } else if (part.category == 'transmission' ||
        part.category == 'brakes' ||
        part.category == 'suspension') {
      transBoost =
          (part.conditionPercent * 0.35 * compMultiplier).clamp(10.0, 45.0);
    }

    final newEngineCond =
        (car.expertise.engineCondition + engineBoost).clamp(0.0, 100.0);
    final newTransCond =
        (car.expertise.transmissionCondition + transBoost).clamp(0.0, 100.0);

    bool isRestored = car.isBarnFindRestored;
    bool isRare = car.isRare;
    List<String> newProvenance = List.from(car.provenanceLog);

    if (car.isBarnFind &&
        !isRestored &&
        newEngineCond >= 95.0 &&
        newTransCond >= 95.0) {
      isRestored = true;
      isRare = true;
      newProvenance.add(
          'Gün ${state.currentDay}: Hurdalıktan kurtarılan klasik tam restorasyondan geçti! Değeri katlandı.');
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
        updatedStaff[i] =
            staff.copyWith(tasksCompleted: nextTasks, masteryLevel: nextLevel);
      }
    }

    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;
    final updatedParts = List<SalvagedPart>.from(state.salvagedParts)
      ..removeAt(partIndex);

    state = state.copyWith(
      ownedCars: updatedCars,
      salvagedParts: updatedParts,
      hiredStaff: updatedStaff,
    );

    addXP(45);
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
    adjustNpcRelationship('cikmaci_ibo', 2);
    addXP(25);
    updateMissionProgress(MissionType.scrapyardDismantle, 1);
    saveState();
    return true;
  }

  /// Alias for doDailyScrapyardSideGig
  bool workScrapyardSideGig() => doDailyScrapyardSideGig();

  /// Çıkma Parçaları Sanayi Toptancısına Satma (§17)
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

  /// Hurdalıkta Kayıp Hazine Arama (§17)
  double? searchScrapForTreasures(
      {ScrapyardZoneType zone = ScrapyardZoneType.ostim}) {
    final searchCount = (state.lastScrapyardSearchDay == state.currentDay)
        ? state.scrapyardSearchesToday
        : 0;
    if (searchCount >= 3) return null;

    final cost = zone.cost;
    if (state.balance < cost) return null;

    final roll = random.nextDouble();
    double foundCash;

    switch (zone) {
      case ScrapyardZoneType.ostim:
        if (roll < 0.30) {
          foundCash = 0.0;
        } else if (roll < 0.75) {
          foundCash = 3500.0 + (random.nextInt(4) * 500);
        } else {
          foundCash = 8500.0 + (random.nextInt(3) * 1000);
        }
        break;
      case ScrapyardZoneType.maslak:
        if (roll < 0.35) {
          foundCash = 0.0;
        } else if (roll < 0.70) {
          foundCash = 7500.0 + (random.nextInt(5) * 1000);
        } else {
          foundCash = 16000.0 + (random.nextInt(4) * 2000);
        }
        break;
      case ScrapyardZoneType.sasmaz:
        if (roll < 0.30) {
          foundCash = 0.0;
        } else if (roll < 0.75) {
          foundCash = 5000.0 + (random.nextInt(4) * 750);
        } else {
          foundCash = 12000.0 + (random.nextInt(3) * 1500);
        }
        break;
      case ScrapyardZoneType.harabe:
        if (roll < 0.40) {
          foundCash = 0.0;
        } else if (roll < 0.70) {
          foundCash = 15000.0 + (random.nextInt(4) * 2500);
        } else {
          foundCash = 35000.0 + (random.nextInt(5) * 5000);
        }
        break;
    }

    state = state.copyWith(
      balance: state.balance - cost + foundCash,
      scrapyardSearchesToday: searchCount + 1,
      lastScrapyardSearchDay: state.currentDay,
    );

    addXP(foundCash > 0 ? 35 : 15);
    saveState();
    return foundCash;
  }
}
