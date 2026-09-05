import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../../data/models/real_estate_category.dart';
import '../../../data/models/real_estate_model.dart';
import '../../../data/models/tenant_model.dart';
import '../../../domain/usecases/construction_negative_events_engine.dart';
import '../../../domain/usecases/construction_timeline_engine.dart';
import 'game_base_notifier.dart';

mixin GameRealEstateMixin on GameBaseNotifier {
  /// Purchases a real estate property and adds it to dealership's portfolio
  bool purchaseRealEstate({
    required RealEstateListingModel listing,
    required double finalPrice,
    required double deedFee,
    required double commission,
  }) {
    final revolvingFundFee = RealEstateListingModel.revolvingFundFee;
    final totalAcquisitionCost = finalPrice + deedFee + revolvingFundFee + commission;

    if (state.balance < totalAcquisitionCost) {
      if (kDebugMode) {
        debugPrint('Insufficient balance to purchase real estate: needs $totalAcquisitionCost, has ${state.balance}');
      }
      return false;
    }

    if (state.ownedRealEstates.length >= state.maxRealEstateSlots) {
      if (kDebugMode) {
        debugPrint('Max real estate portfolio slots reached: ${state.maxRealEstateSlots}');
      }
      return false;
    }

    final newBalance = state.balance - totalAcquisitionCost;
    final nowStr = DateTime.now().toIso8601String().split('T').first;

    final purchasedProperty = listing.realEstate.copyWith(
      currentPurchasePrice: finalPrice,
      deedFeePaid: deedFee + revolvingFundFee,
      commissionPaid: commission,
      provenanceLog: [
        ...listing.realEstate.provenanceLog,
        '$nowStr • ₺${finalPrice.round()} bedelle ${listing.sellerName} üzerinden portföye katıldı.',
      ],
    );

    final updatedList = List<RealEstateModel>.from(state.ownedRealEstates)..add(purchasedProperty);

    state = state.copyWith(
      balance: newBalance,
      ownedRealEstates: updatedList,
    );

    // Progression XP & motivation rewards
    addXP(250);
    checkAndAwardFirstTimeAction(
      'first_real_estate_purchase',
      label: 'İlk Gayrimenkul Yatırımı',
      bonusMoney: 15000.0,
      bonusXP: 10,
    );

    saveState();
    return true;
  }

  /// Sells a real estate property from portfolio at given sale price
  bool sellRealEstate({
    required String realEstateId,
    required double salePrice,
  }) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == realEstateId);
    if (index == -1) return false;

    final property = state.ownedRealEstates[index];
    // Strict gating: Rented, personal residence, or active renovation properties cannot be sold
    if (!property.canBeSold) {
      if (kDebugMode) {
        debugPrint('Cannot sell property: rented=${property.isRented}, residence=${property.isPersonalResidence}, underRenovation=${property.isUnderRenovation}');
      }
      return false;
    }

    final totalCost = property.currentPurchasePrice + property.deedFeePaid + property.commissionPaid;
    final netProfit = salePrice - totalCost;

    final updatedList = List<RealEstateModel>.from(state.ownedRealEstates)..removeAt(index);
    final newBalance = state.balance + salePrice;
    final newTotalProfit = state.totalProfit + netProfit;

    state = state.copyWith(
      balance: newBalance,
      totalProfit: newTotalProfit,
      ownedRealEstates: updatedList,
    );

    addXP(350);
    saveState();
    return true;
  }

  /// Toggles tenant rent status for passive daily income yield
  bool toggleRealEstateRent(String realEstateId) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == realEstateId);
    if (index == -1) return false;

    final property = state.ownedRealEstates[index];
    // Gating: If setting to rented, cannot be personal residence or under active renovation
    if (!property.isRented && !property.canBeRented) {
      if (kDebugMode) {
        debugPrint('Cannot lease property: residence=${property.isPersonalResidence}, underRenovation=${property.isUnderRenovation}');
      }
      return false;
    }

    final updatedProperty = property.copyWith(isRented: !property.isRented);

    final updatedList = List<RealEstateModel>.from(state.ownedRealEstates);
    updatedList[index] = updatedProperty;

    state = state.copyWith(ownedRealEstates: updatedList);
    saveState();
    return true;
  }

  /// Sets or relocates the player's personal residence (strictly housing only)
  bool setPersonalResidence(String realEstateId) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == realEstateId);
    if (index == -1) return false;

    final property = state.ownedRealEstates[index];
    // Strictly restricted to residential housing properties only
    if (property.category != RealEstateCategory.housing) return false;
    if (!property.canBePersonalResidence) return false;

    final nowStr = DateTime.now().toIso8601String().split('T').first;
    final updatedList = state.ownedRealEstates.map((p) {
      if (p.id == realEstateId) {
        return p.copyWith(
          isPersonalResidence: true,
          provenanceLog: [
            ...p.provenanceLog,
            '$nowStr • Kişisel ikametgah olarak tescillendi • +${p.personalResidencePrestigeBonus} Prestij',
          ],
        );
      } else if (p.isPersonalResidence) {
        return p.copyWith(isPersonalResidence: false);
      }
      return p;
    }).toList();

    state = state.copyWith(
      ownedRealEstates: updatedList,
    );

    addXP(100 + property.personalResidencePrestigeBonus * 10);
    saveState();
    return true;
  }

  /// Vacates the personal residence
  bool vacatePersonalResidence(String realEstateId) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == realEstateId);
    if (index == -1) return false;

    final property = state.ownedRealEstates[index];
    if (!property.isPersonalResidence) return false;

    final updatedProperty = property.copyWith(isPersonalResidence: false);
    final updatedList = List<RealEstateModel>.from(state.ownedRealEstates);
    updatedList[index] = updatedProperty;

    state = state.copyWith(ownedRealEstates: updatedList);
    saveState();
    return true;
  }

  /// Collects accumulated pending rent for a specific real estate property
  double collectRent(String realEstateId) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == realEstateId);
    if (index == -1) return 0.0;

    final property = state.ownedRealEstates[index];
    final rentAmount = property.pendingRentIncome;
    if (rentAmount <= 0) return 0.0;

    final updatedProperty = property.copyWith(
      pendingRentIncome: 0.0,
      uncollectedRentDays: 0,
    );

    final updatedList = List<RealEstateModel>.from(state.ownedRealEstates);
    updatedList[index] = updatedProperty;

    state = state.copyWith(
      balance: state.balance + rentAmount,
      ownedRealEstates: updatedList,
    );

    addXP((rentAmount / 500).round().clamp(10, 200));
    saveState();
    return rentAmount;
  }

  /// Collects all accumulated pending rents across the entire real estate portfolio
  double collectAllPendingRents() {
    double totalCollected = 0.0;
    final updatedList = state.ownedRealEstates.map((prop) {
      if (prop.pendingRentIncome > 0) {
        totalCollected += prop.pendingRentIncome;
        return prop.copyWith(
          pendingRentIncome: 0.0,
          uncollectedRentDays: 0,
        );
      }
      return prop;
    }).toList();

    if (totalCollected <= 0) return 0.0;

    state = state.copyWith(
      balance: state.balance + totalCollected,
      ownedRealEstates: updatedList,
    );

    addXP((totalCollected / 400).round().clamp(25, 400));
    saveState();
    return totalCollected;
  }

  /// Advances renovation stage by 1 step (1: Yıkım/Tesisat %35, 2: Mutfak/Banyo %70, 3: Anahtar Teslim %100)
  bool advanceRenovationStage(String realEstateId) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == realEstateId);
    if (index == -1) return false;

    final property = state.ownedRealEstates[index];
    if (property.isRenovated ||
        property.renovationStage >= 3 ||
        property.renovationDaysRemaining > 0) {
      return false;
    }

    final stageCost = (property.category.renovationBaseCost / 3).roundToDouble();
    if (state.balance < stageCost) return false;

    final nextStage = property.renovationStage + 1;
    final isNowFullyRenovated = nextStage >= 3;
    final nowStr = DateTime.now().toIso8601String().split('T').first;

    // Random hidden defect discovery during early renovation stages (20% chance)
    bool discoveredLeak = property.hasWaterLeakRisk;
    String? defectNote;
    if (!property.hasWaterLeakRisk && nextStage <= 2 && Random().nextDouble() < 0.20) {
      discoveredLeak = true;
      defectNote = nextStage == 1
          ? 'Kırım sırasında eski galvaniz boruda çatlak ve su sızıntısı tespit edildi'
          : 'Tesisat şaftında gizli su kaçağı ve kablo korozyonu ortaya çıktı';
    }

    String stageLog;
    switch (nextStage) {
      case 1:
        stageLog = '$nowStr • 1. Aşama: Yıkım, kırım ve sıhhi tesisat yapıldı • ₺${stageCost.round()}';
        break;
      case 2:
        stageLog = '$nowStr • 2. Aşama: Mutfak, banyo ve seramik işçiliği tamamlandı • ₺${stageCost.round()}';
        break;
      default:
        stageLog = '$nowStr • 3. Aşama: Boya, parke ve anahtar teslim tamamlandı • ₺${stageCost.round()}';
        break;
    }

    final updatedLogs = [
      ...property.provenanceLog,
      stageLog,
      if (defectNote != null) '$nowStr • Gizli Kusur Ortaya Çıktı • $defectNote',
    ];

    final updatedProperty = property.copyWith(
      renovationStage: nextStage,
      renovationDaysRemaining: isNowFullyRenovated ? 0 : 2,
      isRenovated: isNowFullyRenovated,
      hasWaterLeakRisk: discoveredLeak,
      provenanceLog: updatedLogs,
    );

    final updatedList = List<RealEstateModel>.from(state.ownedRealEstates);
    updatedList[index] = updatedProperty;

    state = state.copyWith(
      balance: state.balance - stageCost,
      ownedRealEstates: updatedList,
    );

    addXP(75);
    saveState();
    return true;
  }

  /// Rushed renovation lore action: Instantly finishes renovation with risk of hidden water leaks
  bool rushRenovation(String realEstateId) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == realEstateId);
    if (index == -1) return false;

    final property = state.ownedRealEstates[index];
    if (property.isRenovated || property.renovationStage >= 3) return false;

    final nowStr = DateTime.now().toIso8601String().split('T').first;
    final updatedProperty = property.copyWith(
      renovationStage: 3,
      renovationDaysRemaining: 0,
      isRenovated: true,
      isRushedRenovation: true,
      hasWaterLeakRisk: true,
      provenanceLog: [
        ...property.provenanceLog,
        '$nowStr • Usta aceleye getirdi • Gizli su kaçağı riski oluştu',
      ],
    );

    final updatedList = List<RealEstateModel>.from(state.ownedRealEstates);
    updatedList[index] = updatedProperty;

    state = state.copyWith(ownedRealEstates: updatedList);
    addXP(100);
    saveState();
    return true;
  }

  /// Repairs hidden water leak caused by rushed renovation
  bool repairWaterLeak(String realEstateId) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == realEstateId);
    if (index == -1) return false;

    final property = state.ownedRealEstates[index];
    if (!property.hasWaterLeakRisk) return false;

    const repairCost = 5000.0;
    if (state.balance < repairCost) return false;

    final nowStr = DateTime.now().toIso8601String().split('T').first;
    final updatedProperty = property.copyWith(
      hasWaterLeakRisk: false,
      provenanceLog: [
        ...property.provenanceLog,
        '$nowStr • Tesisat ustası çağırıldı • Gizli su kaçağı onarıldı • ₺${repairCost.round()}',
      ],
    );

    final updatedList = List<RealEstateModel>.from(state.ownedRealEstates);
    updatedList[index] = updatedProperty;

    state = state.copyWith(
      balance: state.balance - repairCost,
      ownedRealEstates: updatedList,
    );

    addXP(40);
    saveState();
    return true;
  }

  /// Renovates the property (+15% market value boost for flipping)
  bool renovateRealEstate(String realEstateId) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == realEstateId);
    if (index == -1) return false;

    final property = state.ownedRealEstates[index];
    if (property.isRenovated) return false;

    final renovationCost = property.category.renovationBaseCost;
    if (state.balance < renovationCost) return false;

    final nowStr = DateTime.now().toIso8601String().split('T').first;
    final updatedProperty = property.copyWith(
      isRenovated: true,
      renovationStage: 3,
      hasWaterLeakRisk: false,
      provenanceLog: [
        ...property.provenanceLog,
        '$nowStr • Kapsamlı tadilat ve yenileme tamamlandı • ₺${renovationCost.round()}',
      ],
    );

    final updatedList = List<RealEstateModel>.from(state.ownedRealEstates);
    updatedList[index] = updatedProperty;

    state = state.copyWith(
      balance: state.balance - renovationCost,
      ownedRealEstates: updatedList,
    );

    addXP(150);
    saveState();
    return true;
  }

  /// Dynamic capacity expansion cost using exponential scaling:
  /// TabanUcret * (1.8 ^ MevcutSeviye)
  double get realEstateSlotExpansionCost {
    final level = ((state.maxRealEstateSlots - 5) / 2).clamp(0, 50).toInt();
    return (500000.0 * pow(1.8, level)).roundToDouble();
  }

  /// Upgrades maximum real estate portfolio slots (+2 slots) with exponential scaling cost
  bool expandRealEstateSlots() {
    final expansionCost = realEstateSlotExpansionCost;
    if (state.balance < expansionCost) return false;

    state = state.copyWith(
      balance: state.balance - expansionCost,
      maxRealEstateSlots: state.maxRealEstateSlots + 2,
    );

    addXP(200);
    saveState();
    return true;
  }

  /// Lists an owned real estate property for sale with custom asking price
  bool listRealEstateForSale(String realEstateId, double askingPrice) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == realEstateId);
    if (index == -1) return false;

    final property = state.ownedRealEstates[index];
    if (!property.canBeSold) return false;

    final updatedProperty = property.copyWith(
      isListed: true,
      customListingPrice: askingPrice,
      daysListed: 0,
    );

    final updatedList = List<RealEstateModel>.from(state.ownedRealEstates);
    updatedList[index] = updatedProperty;

    state = state.copyWith(ownedRealEstates: updatedList);
    saveState();
    return true;
  }

  /// Unlists an owned real estate property from sale
  bool unlistRealEstate(String realEstateId) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == realEstateId);
    if (index == -1) return false;

    final property = state.ownedRealEstates[index];
    final updatedProperty = property.copyWith(
      isListed: false,
      clearCustomPrice: true,
      activeOffers: const [],
    );

    final updatedList = List<RealEstateModel>.from(state.ownedRealEstates);
    updatedList[index] = updatedProperty;

    state = state.copyWith(ownedRealEstates: updatedList);
    saveState();
    return true;
  }

  /// Accepts a buyer's offer from the showcase pool
  bool acceptRealEstateOffer({
    required String realEstateId,
    required String offerId,
    double? customAgreedPrice,
  }) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == realEstateId);
    if (index == -1) return false;

    final property = state.ownedRealEstates[index];
    final offerIndex = property.activeOffers.indexWhere((o) => o.id == offerId);
    if (offerIndex == -1) return false;

    final offer = property.activeOffers[offerIndex];
    return sellRealEstate(
      realEstateId: realEstateId,
      salePrice: customAgreedPrice ?? offer.offeredAmount,
    );
  }

  /// Rejects a buyer's offer from the showcase pool
  bool rejectRealEstateOffer({required String realEstateId, required String offerId}) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == realEstateId);
    if (index == -1) return false;

    final property = state.ownedRealEstates[index];
    final updatedOffers = property.activeOffers.where((o) => o.id != offerId).toList();
    final updatedProperty = property.copyWith(activeOffers: updatedOffers);

    final updatedList = List<RealEstateModel>.from(state.ownedRealEstates);
    updatedList[index] = updatedProperty;

    state = state.copyWith(ownedRealEstates: updatedList);
    saveState();
    return true;
  }

  /// Leases property to a specific tenant candidate with deposit collection and provenance logging
  bool leaseRealEstateToTenant({
    required String realEstateId,
    required TenantModel tenant,
  }) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == realEstateId);
    if (index == -1) return false;

    final property = state.ownedRealEstates[index];
    if (!property.canBeRented) return false;

    final nowStr = DateTime.now().toIso8601String().split('T').first;
    final updatedOffers = property.activeOffers.where((o) => !o.isRentalOffer).toList();

    final updatedProperty = property.copyWith(
      isRented: true,
      currentTenant: tenant,
      isRentalListed: false,
      activeOffers: updatedOffers,
      provenanceLog: [
        ...property.provenanceLog,
        '$nowStr • ${tenant.name} - ${tenant.profession} ile kiralandı • Depozito: ₺${tenant.depositAmount.round()}',
      ],
    );

    final updatedList = List<RealEstateModel>.from(state.ownedRealEstates);
    updatedList[index] = updatedProperty;

    state = state.copyWith(
      balance: state.balance + tenant.depositAmount,
      ownedRealEstates: updatedList,
    );

    addXP(150);
    saveState();
    return true;
  }

  /// Evicts current tenant or terminates lease, returning deposit
  bool evictTenant(String realEstateId) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == realEstateId);
    if (index == -1) return false;

    final property = state.ownedRealEstates[index];
    if (!property.isRented) return false;

    final tenant = property.currentTenant;
    final depositRefund = tenant?.depositAmount ?? 0.0;
    final newBalance = (state.balance - depositRefund).clamp(0.0, double.infinity);

    final nowStr = DateTime.now().toIso8601String().split('T').first;
    final updatedProperty = property.copyWith(
      isRented: false,
      clearCurrentTenant: true,
      isRentalListed: false,
      provenanceLog: [
        ...property.provenanceLog,
        '$nowStr • Kiracı tahliye edildi - sözleşme feshedildi.',
      ],
    );

    final updatedList = List<RealEstateModel>.from(state.ownedRealEstates);
    updatedList[index] = updatedProperty;

    state = state.copyWith(
      balance: newBalance,
      ownedRealEstates: updatedList,
    );

    saveState();
    return true;
  }

  /// Lists property on rental market to receive tenant offers in showroom
  bool listRealEstateForRent(String realEstateId) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == realEstateId);
    if (index == -1) return false;

    final property = state.ownedRealEstates[index];
    if (!property.canBeRented) return false;

    final updatedProperty = property.copyWith(
      isRentalListed: true,
    );

    final updatedList = List<RealEstateModel>.from(state.ownedRealEstates);
    updatedList[index] = updatedProperty;

    state = state.copyWith(ownedRealEstates: updatedList);
    saveState();
    return true;
  }

  /// Unlists property from rental market
  bool unlistRealEstateFromRent(String realEstateId) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == realEstateId);
    if (index == -1) return false;

    final property = state.ownedRealEstates[index];
    final updatedOffers = property.activeOffers.where((o) => !o.isRentalOffer).toList();
    final updatedProperty = property.copyWith(
      isRentalListed: false,
      activeOffers: updatedOffers,
    );

    final updatedList = List<RealEstateModel>.from(state.ownedRealEstates);
    updatedList[index] = updatedProperty;

    state = state.copyWith(ownedRealEstates: updatedList);
    saveState();
    return true;
  }

  /// Accepts a rental offer and leases property to tenant
  bool acceptRealEstateRentalOffer({
    required String realEstateId,
    required String offerId,
  }) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == realEstateId);
    if (index == -1) return false;

    final property = state.ownedRealEstates[index];
    final offer = property.activeOffers.firstWhere(
      (o) => o.id == offerId,
      orElse: () => throw StateError('Offer not found'),
    );

    if (!offer.isRentalOffer || offer.tenant == null) return false;

    return leaseRealEstateToTenant(
      realEstateId: realEstateId,
      tenant: offer.tenant!,
    );
  }

  /// Starts Contractor Construction Agreement (Kat Karşılığı Müteahhit Sözleşmesi)
  /// 0 upfront cost, 40-60% customizable share, 5 days per milestone
  bool startContractorConstruction(String landId, {int sharePercent = 50, int? customTotalUnits}) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == landId);
    if (index == -1) return false;

    final land = state.ownedRealEstates[index];
    if (land.category != RealEstateCategory.land) return false;
    if (land.isConstructionActive) return false;

    final totalUnits = customTotalUnits ?? land.totalProjectUnits;
    final clampedShare = sharePercent.clamp(40, 60);

    final nowStr = DateTime.now().toIso8601String().split('T').first;
    final updatedLand = land.copyWith(
      constructionMode: 'contractor',
      contractorSharePercent: clampedShare,
      totalProjectUnits: totalUnits,
      soldPreSaleUnits: 0,
      constructionStage: 1,
      constructionDaysRemaining: 30,
      provenanceLog: [
        ...land.provenanceLog,
        '$nowStr • Müteahhitle kat karşılığı sözleşmesi imzalandı • $totalUnits Dairelik Proje • %$clampedShare Oyuncu Payı',
      ],
    );

    final updatedList = List<RealEstateModel>.from(state.ownedRealEstates);
    updatedList[index] = updatedLand;

    state = state.copyWith(ownedRealEstates: updatedList);
    addXP(100);
    saveState();
    return true;
  }

  /// Starts Self-Build Development Project (Kendi İnşaatını Yap • Kendi Şantiyen)
  /// 100% flat share, requires capital investment per stage
  bool startSelfBuildConstruction(String landId) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == landId);
    if (index == -1) return false;

    final land = state.ownedRealEstates[index];
    if (land.category != RealEstateCategory.land) return false;
    if (land.isConstructionActive) return false;

    final stageCost = (land.baseMarketValue * 0.15).roundToDouble();
    if (state.balance < stageCost) return false;

    final totalUnits = land.totalProjectUnits;
    final nowStr = DateTime.now().toIso8601String().split('T').first;

    final updatedLand = land.copyWith(
      constructionMode: 'selfBuild',
      contractorSharePercent: 0,
      totalProjectUnits: totalUnits,
      soldPreSaleUnits: 0,
      constructionStage: 1,
      constructionDaysRemaining: 0,
      isConstructionWorking: false,
      clearActiveSubcontractor: true,
      stageTotalDays: 0,
      provenanceLog: [
        ...land.provenanceLog,
        '$nowStr • Öz-inşaat şantiyesi kuruldu • Ruhsat ve saha izinleri alındı • ₺${stageCost.round()}',
      ],
    );

    final updatedList = List<RealEstateModel>.from(state.ownedRealEstates);
    updatedList[index] = updatedLand;

    state = state.copyWith(
      balance: state.balance - stageCost,
      ownedRealEstates: updatedList,
    );

    addXP(150);
    saveState();
    return true;
  }

  /// Funds and starts the current Self-Build stage with a selected subcontractor
  bool startSelfBuildStage(
    String landId, {
    SubcontractorProfile? subcontractor,
    double? customStageCost,
    bool triggerIncidents = true,
  }) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == landId);
    if (index == -1) return false;

    final land = state.ownedRealEstates[index];
    if (land.constructionMode != 'selfBuild') return false;
    if (land.constructionStage < 1 || land.constructionStage > 4) return false;
    if (land.isConstructionWorking) return false; // Already actively working

    final sub = subcontractor ??
        ConstructionTimelineEngine.getSubcontractorsForStage(land.constructionStage)[1]; // Standard default

    final double stageRate;
    switch (land.constructionStage) {
      case 1:
        stageRate = 0.15; // Hafriyat & Zemin
        break;
      case 2:
        stageRate = 0.25; // Kaba Yapı & Karkas
        break;
      case 3:
        stageRate = 0.20; // Çatı & Dış Cephe & Tesisat
        break;
      case 4:
        stageRate = 0.15; // İnce İşçilik & İskan
        break;
      default:
        stageRate = 0.15;
    }

    final calculatedBaseCost = (land.baseMarketValue * stageRate).roundToDouble();
    final baseCostWithMultiplier = (calculatedBaseCost * sub.costMultiplier).roundToDouble();
    final stageCost = (customStageCost != null && customStageCost > 0)
        ? customStageCost
        : baseCostWithMultiplier;

    if (state.balance < stageCost) return false;

    final nowStr = DateTime.now().toIso8601String().split('T').first;

    final incident = triggerIncidents
        ? ConstructionNegativeEventsEngine.rollStageIncident(
            stageNumber: land.constructionStage,
            baseStageCost: stageCost,
            riskMultiplier: sub.tier == SubcontractorTier.budget
                ? 1.3
                : (sub.tier == SubcontractorTier.speed ? 0.8 : 1.0),
          )
        : null;

    int extraDays = 0;
    double incidentCost = 0.0;
    final extraLogs = <String>[];

    if (incident != null) {
      extraDays = incident.dayDelayImpact;
      if (state.balance >= stageCost + incident.costImpact) {
        incidentCost = incident.costImpact;
      } else {
        extraDays += 1;
      }
      extraLogs.add('$nowStr • Şantiye Olayı: ${incident.title} • Etki: ₺${incident.costImpact.round()}');
    }

    final totalDeduction = stageCost + incidentCost;
    if (state.balance < totalDeduction) return false;

    final stageDays = ConstructionTimelineEngine.calculateStageDays(
      stageNumber: land.constructionStage,
      parcelSquareMeters: land.squareMeters.toDouble(),
      tier: sub.tier,
    ) + extraDays;

    final updatedLand = land.copyWith(
      constructionDaysRemaining: stageDays,
      stageTotalDays: stageDays,
      isConstructionWorking: true,
      activeSubcontractorName: sub.name,
      provenanceLog: [
        ...land.provenanceLog,
        '$nowStr • Aşama ${land.constructionStage} başladı • Taşeron: ${sub.name} • Süre: $stageDays Gün • ₺${stageCost.round()}',
        ...extraLogs,
      ],
    );

    final updatedList = List<RealEstateModel>.from(state.ownedRealEstates);
    updatedList[index] = updatedLand;

    state = state.copyWith(
      balance: state.balance - totalDeduction,
      ownedRealEstates: updatedList,
    );

    addXP(100);
    saveState();
    return true;
  }

  /// Completes the active Self-Build stage when days reach 0 and hands over to the next milestone
  bool completeSelfBuildStage(String landId) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == landId);
    if (index == -1) return false;

    final land = state.ownedRealEstates[index];
    if (land.constructionMode != 'selfBuild') return false;
    if (!land.isConstructionWorking) return false;
    if (land.constructionDaysRemaining > 0) return false; // Must wait for duration to finish

    final nextStage = land.constructionStage + 1;
    final nowStr = DateTime.now().toIso8601String().split('T').first;

    final updatedLand = land.copyWith(
      constructionStage: nextStage,
      constructionDaysRemaining: 0,
      stageTotalDays: 0,
      isConstructionWorking: false,
      clearActiveSubcontractor: true,
      provenanceLog: [
        ...land.provenanceLog,
        '$nowStr • Aşama ${land.constructionStage} başarıyla teslim alındı ve denetimden geçti • Sonraki etaba hazır',
      ],
    );

    final updatedList = List<RealEstateModel>.from(state.ownedRealEstates);
    updatedList[index] = updatedLand;

    state = state.copyWith(
      ownedRealEstates: updatedList,
    );

    addXP(150);
    saveState();
    return true;
  }

  /// Funds and advances next milestone in Self-Build mode (legacy compatibility)
  bool advanceSelfBuildStage(String landId, {bool triggerIncidents = true, double? customStageCost}) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == landId);
    if (index == -1) return false;

    final land = state.ownedRealEstates[index];
    if (land.constructionMode != 'selfBuild') return false;
    if (land.constructionStage < 1 || land.constructionStage >= 4) return false;

    final double stageRate;
    switch (land.constructionStage) {
      case 1:
        stageRate = 0.25; // Stage 2: Kaba İnşaat & Karkas
        break;
      case 2:
        stageRate = 0.20; // Stage 3: Çatı & Dış Cephe
        break;
      case 3:
        stageRate = 0.15; // Stage 4: İnce İşçilik & İskan Ruhsatı
        break;
      default:
        stageRate = 0.15;
    }

    final calculatedCost = (land.baseMarketValue * stageRate).roundToDouble();
    final stageCost = (customStageCost != null && customStageCost > 0)
        ? customStageCost
        : calculatedCost;

    if (state.balance < stageCost) return false;

    final nextStage = land.constructionStage + 1;
    final nowStr = DateTime.now().toIso8601String().split('T').first;

    final updatedLand = land.copyWith(
      constructionStage: nextStage,
      constructionDaysRemaining: 4,
      isConstructionWorking: true,
      provenanceLog: [
        ...land.provenanceLog,
        '$nowStr • Şantiye Aşama $nextStage fonlandı ve başladı • ₺${stageCost.round()}',
      ],
    );

    final updatedList = List<RealEstateModel>.from(state.ownedRealEstates);
    updatedList[index] = updatedLand;

    state = state.copyWith(
      balance: (state.balance - stageCost).roundToDouble(),
      ownedRealEstates: updatedList,
    );

    addXP(120);
    saveState();
    return true;
  }

  /// Sells 1 unit off-plan (Topraktan Ön Satış) for immediate liquidity injection
  double preSellUnit(String landId) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == landId);
    if (index == -1) return 0.0;

    final land = state.ownedRealEstates[index];
    if (!land.canPreSell) return 0.0;

    final revenue = land.preSaleUnitPrice;
    final nextSold = land.soldPreSaleUnits + 1;
    final nowStr = DateTime.now().toIso8601String().split('T').first;

    final updatedLand = land.copyWith(
      soldPreSaleUnits: nextSold,
      provenanceLog: [
        ...land.provenanceLog,
        '$nowStr • Topraktan ön satış yapıldı • 1 Daire devredildi • +₺${revenue.round()}',
      ],
    );

    final updatedList = List<RealEstateModel>.from(state.ownedRealEstates);
    updatedList[index] = updatedLand;

    state = state.copyWith(
      balance: state.balance + revenue,
      ownedRealEstates: updatedList,
    );

    addXP(80);
    saveState();
    return revenue;
  }

  /// Finalizes 100% completed construction, removes land and adds turnkey housing units to portfolio
  List<RealEstateModel> finalizeConstruction(String landId) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == landId);
    if (index == -1) return [];

    final land = state.ownedRealEstates[index];
    if (land.constructionStage < 4) return [];
    if (land.constructionDaysRemaining > 0) return [];

    final unitsToCreate = land.playerShareUnits;
    final createdApartments = <RealEstateModel>[];

    for (int i = 0; i < unitsToCreate; i++) {
      createdApartments.add(
        RealEstateModel(
          id: 're_turnkey_${land.id}_$i',
          title: '${land.district} Rezidans • Daire #${i + 1}',
          category: RealEstateCategory.housing,
          city: land.city,
          district: land.district,
          squareMeters: (land.squareMeters * 0.75 / (land.totalProjectUnits > 0 ? land.totalProjectUnits : 4)).round(),
          roomCount: '3+1',
          buildingAge: 0,
          deedType: DeedType.ownershipDeed,
          sellerType: RealEstateSellerType.individual,
          baseMarketValue: land.turnkeyUnitPrice > 0 ? land.turnkeyUnitPrice : 3500000.0,
          currentPurchasePrice: 0.0,
          isRenovated: true,
          renovationStage: 3,
        ),
      );
    }

    final updatedList = List<RealEstateModel>.from(state.ownedRealEstates);
    updatedList.removeAt(index);
    updatedList.addAll(createdApartments);

    state = state.copyWith(ownedRealEstates: updatedList);
    addXP(500);
    saveState();
    return createdApartments;
  }
}
