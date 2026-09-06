import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../../data/models/game_event_model.dart';
import '../../../data/models/loan_model.dart';
import '../../../data/models/real_estate_category.dart';
import '../../../data/models/real_estate_model.dart';
import '../../../data/models/real_estate_offer_model.dart';
import '../../../data/models/staff_model.dart';
import '../../../data/models/tenant_model.dart';
import '../../../data/models/weather_model.dart';
import '../../../domain/usecases/construction_negative_events_engine.dart';
import '../../../domain/usecases/construction_timeline_engine.dart';
import '../../../domain/usecases/real_estate_listing_narrative_engine.dart';
import '../../../domain/usecases/zoning_engine.dart';
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
    // Strict gating: Rented, personal residence, active renovation, or active construction properties cannot be sold
    if (property.isRented ||
        property.isPersonalResidence ||
        property.isUnderRenovation ||
        property.isConstructionActive) {
      if (kDebugMode) {
        debugPrint(
            'Cannot sell property: rented=${property.isRented}, residence=${property.isPersonalResidence}, underRenovation=${property.isUnderRenovation}, construction=${property.isConstructionActive}');
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

  /// Lists an owned real estate property for sale with custom asking price and options
  bool listRealEstateForSale(
    String realEstateId,
    double askingPrice, {
    String? headline,
    String? description,
    List<String>? features,
    String listingPackage = 'standard',
  }) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == realEstateId);
    if (index == -1) return false;

    final property = state.ownedRealEstates[index];
    if (!property.canBeSold) return false;

    double packageCost = 0.0;
    if (listingPackage == 'featured') {
      packageCost = 25000.0;
    } else if (listingPackage == 'super') {
      packageCost = 60000.0;
    }

    if (packageCost > 0 && state.balance < packageCost) {
      return false;
    }

    final activeOffers = List<RealEstateOfferModel>.from(property.activeOffers);
    final updatedEvents = List<GameEventModel>.from(state.recentEvents);

    // If super package is chosen and no offers yet, trigger an eager VIP buyer inquiry immediately
    if (listingPackage == 'super' && activeOffers.isEmpty) {
      final immediateOffer = RealEstateListingNarrativeEngine.generateInitialSuperOffer(
        property: property,
        askingPrice: askingPrice,
      );
      activeOffers.add(immediateOffer);

      updatedEvents.insert(
        0,
        GameEventModel(
          id: 're_event_super_${immediateOffer.id}',
          title: 'Süper Vitrin • İlk Teklif Geldi',
          description:
              '${property.title} süper vitrin ilanınıza ${immediateOffer.buyerName} tarafından ₺${immediateOffer.offeredAmount.round()} tutarında resmi teklif sunuldu. Showroom üzerinden değerlendirebilirsiniz.',
          amount: 0.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
        ),
      );
    }

    final updatedProperty = property.copyWith(
      isListed: true,
      customListingPrice: askingPrice,
      daysListed: 0,
      listingHeadline: headline,
      listingDescription: description,
      listingFeatures: features ?? property.listingFeatures,
      listingPackage: listingPackage,
      activeOffers: activeOffers,
    );

    final updatedList = List<RealEstateModel>.from(state.ownedRealEstates);
    updatedList[index] = updatedProperty;

    state = state.copyWith(
      balance: state.balance - packageCost,
      ownedRealEstates: updatedList,
      recentEvents: updatedEvents,
    );
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

  /// Rejects a tenant candidate or matching rental offer
  bool rejectTenantCandidate({required String propertyId, required String candidateId}) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == propertyId);
    if (index == -1) return false;

    final property = state.ownedRealEstates[index];
    final updatedOffers = property.activeOffers.where((o) => o.id != candidateId).toList();
    if (updatedOffers.length != property.activeOffers.length) {
      final updatedProperty = property.copyWith(activeOffers: updatedOffers);
      final updatedList = List<RealEstateModel>.from(state.ownedRealEstates);
      updatedList[index] = updatedProperty;
      state = state.copyWith(ownedRealEstates: updatedList);
      saveState();
    }
    return true;
  }

  /// Leases property to a specific tenant candidate with deposit collection and provenance logging
  bool leaseRealEstateToTenant({
    required String realEstateId,
    required TenantModel tenant,
    bool force = false,
  }) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == realEstateId);
    if (index == -1) return false;

    final property = state.ownedRealEstates[index];
    if (property.isRented ||
        property.isPersonalResidence ||
        property.isUnderRenovation ||
        property.isConstructionActive) {
      return false;
    }

    if (!force && property.category == RealEstateCategory.land) {
      return false;
    }

    final nowStr = DateTime.now().toIso8601String().split('T').first;
    final updatedOffers = property.activeOffers.where((o) => !o.isRentalOffer).toList();

    final updatedProperty = property.copyWith(
      isRented: true,
      currentTenant: tenant,
      isRentalListed: false,
      isListed: false,
      clearCustomPrice: true,
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

  /// Applies annual inflation/TÜFE rent increase to current tenant
  bool applyRentIndexIncrease(String realEstateId, {double rate = 0.25}) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == realEstateId);
    if (index == -1) return false;

    final property = state.ownedRealEstates[index];
    if (!property.isRented || property.currentTenant == null) return false;

    final tenant = property.currentTenant!;
    // Strict annual gating: requires at least 365 in-game days between index increases
    if (state.currentDay - tenant.lastRentIncreaseDay < 365) return false;

    final nowStr = DateTime.now().toIso8601String().split('T').first;
    final random = Random();
    // 20% probability tenant rejects the aggressive hike and terminates lease unilaterally
    final bool doesTenantVacate = random.nextInt(100) < 20;

    if (doesTenantVacate) {
      final updatedProperty = property.copyWith(
        isRented: false,
        currentTenant: null,
        clearCurrentTenant: true,
        provenanceLog: [
          ...property.provenanceLog,
          '$nowStr • TÜFE kira artışı reddedildi • Kiracı sözleşmeyi tek taraflı feshetti',
        ],
      );
      final updatedList = List<RealEstateModel>.from(state.ownedRealEstates);
      updatedList[index] = updatedProperty;
      state = state.copyWith(ownedRealEstates: updatedList);
      saveState();
      return true;
    }

    final newRent = (tenant.monthlyRent * (1.0 + rate)).roundToDouble();
    final newEvictionRisk = (tenant.evictionRiskScore + 15).clamp(0, 95);
    final updatedTenant = tenant.copyWith(
      monthlyRent: newRent,
      lastRentIncreaseDay: state.currentDay,
      evictionRiskScore: newEvictionRisk,
    );

    final updatedProperty = property.copyWith(
      currentTenant: updatedTenant,
      provenanceLog: [
        ...property.provenanceLog,
        '$nowStr • TÜFE kira artışı uygulandı • Yeni Kira: ₺${newRent.round()}',
      ],
    );

    final updatedList = List<RealEstateModel>.from(state.ownedRealEstates);
    updatedList[index] = updatedProperty;

    state = state.copyWith(ownedRealEstates: updatedList);
    addXP(10);
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
    final offerIndex = property.activeOffers.indexWhere((o) => o.id == offerId);
    if (offerIndex == -1) return false;

    final offer = property.activeOffers[offerIndex];
    if (!offer.isRentalOffer || offer.tenant == null) return false;

    return leaseRealEstateToTenant(
      realEstateId: realEstateId,
      tenant: offer.tenant!,
      force: true,
    );
  }

  /// Saves custom typology mix designed in Tab 1 to land model (D1)
  bool saveUnitMix(String landId, Map<String, dynamic> unitMix) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == landId);
    if (index == -1) return false;

    final land = state.ownedRealEstates[index];
    final updatedLand = land.copyWith(
      customUnitMix: unitMix,
    );

    final updatedList = List<RealEstateModel>.from(state.ownedRealEstates);
    updatedList[index] = updatedLand;

    state = state.copyWith(ownedRealEstates: updatedList);
    saveState();
    return true;
  }

  /// Cancels an active construction project on a land, returning 40% of spent costs (C7)
  bool cancelConstruction(String landId) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == landId);
    if (index == -1) return false;

    final land = state.ownedRealEstates[index];
    if (!land.isConstructionActive) return false;

    double refundAmount = 0.0;
    if (land.constructionMode == 'selfBuild') {
      refundAmount = (land.totalConstructionSpent * 0.40).roundToDouble();
    }

    double preSaleLiability = 0.0;
    int repPenalty = 0;
    if (land.soldPreSaleUnits > 0) {
      preSaleLiability = (land.soldPreSaleUnits * land.preSaleUnitPrice).roundToDouble();
      repPenalty = 10;
    }

    final netBalanceChange = refundAmount - preSaleLiability;
    final nowStr = DateTime.now().toIso8601String().split('T').first;

    final updatedLand = land.copyWith(
      clearConstructionMode: true,
      constructionStage: 0,
      constructionDaysRemaining: 0,
      isConstructionWorking: false,
      clearActiveSubcontractor: true,
      stageTotalDays: 0,
      soldPreSaleUnits: 0,
      totalConstructionSpent: 0.0,
      provenanceLog: [
        ...land.provenanceLog,
        '$nowStr • İnşaat projesi iptal edildi • ₺${refundAmount.round()} iade alındı${preSaleLiability > 0 ? ' • ₺${preSaleLiability.round()} ön satış tazminatı ödendi' : ''}',
      ],
    );

    final updatedList = List<RealEstateModel>.from(state.ownedRealEstates);
    updatedList[index] = updatedLand;

    final nextBalance = (state.balance + netBalanceChange).clamp(0.0, double.infinity);
    final nextRep = (state.reputationScore - repPenalty).clamp(0, 1000);

    state = state.copyWith(
      balance: nextBalance,
      reputationScore: nextRep,
      ownedRealEstates: updatedList,
    );

    saveState();
    return true;
  }

  /// Starts Contractor Construction Agreement (Kat Karşılığı Müteahhit Sözleşmesi)
  /// 0 upfront cost, 33-60% customizable player share, customizable contract terms
  bool startContractorConstruction(
    String landId, {
    int sharePercent = 50,
    int? customTotalUnits,
    ZoningUnitMix? customUnitMix,
    bool hasPrimeFloorClause = false,
    bool hasQualityUpgrade = false,
    double contractorAdvancePaid = 0.0,
    bool hasBankGuarantee = false,
    int contractorStageDays = 15,
  }) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == landId);
    if (index == -1) return false;

    final land = state.ownedRealEstates[index];
    if (land.category != RealEstateCategory.land) return false;
    if (land.isConstructionActive) return false;

    final effectiveMix = customUnitMix ??
        (land.customUnitMix != null ? ZoningUnitMix.fromMap(land.customUnitMix!) : null);

    // Domain Emsal Check (D2)
    if (effectiveMix != null) {
      final zoning = ZoningEngine.calculateZoning(
        parcelSquareMeters: land.squareMeters.toDouble(),
        baseMarketValue: land.baseMarketValue,
        customUnitMix: effectiveMix,
      );
      if (zoning.isEmsalExceeded) return false;
    }

    final totalUnits = effectiveMix?.totalUnits ?? customTotalUnits ?? land.totalProjectUnits;
    final clampedShare = sharePercent.clamp(33, 60);

    final nowStr = DateTime.now().toIso8601String().split('T').first;
    final updatedLand = land.copyWith(
      constructionMode: 'contractor',
      playerSharePercent: clampedShare,
      totalProjectUnits: totalUnits,
      customUnitMix: effectiveMix?.toMap(),
      hasPrimeFloorClause: hasPrimeFloorClause,
      hasQualityUpgrade: hasQualityUpgrade,
      contractorAdvancePaid: contractorAdvancePaid,
      hasBankGuarantee: hasBankGuarantee,
      contractorStageDays: contractorStageDays,
      soldPreSaleUnits: 0,
      constructionStage: 1,
      constructionDaysRemaining: contractorStageDays,
      qualityScore: hasQualityUpgrade ? 90.0 : 75.0,
      provenanceLog: [
        ...land.provenanceLog,
        '$nowStr • Müteahhitle kat karşılığı sözleşmesi imzalandı • $totalUnits Dairelik Proje • %$clampedShare Oyuncu Payı${contractorAdvancePaid > 0 ? ' • ₺${contractorAdvancePaid.round()} Nakit Avans' : ''}',
      ],
    );

    final updatedList = List<RealEstateModel>.from(state.ownedRealEstates);
    updatedList[index] = updatedLand;

    state = state.copyWith(
      balance: state.balance + contractorAdvancePaid,
      ownedRealEstates: updatedList,
    );
    addXP(100);
    saveState();
    return true;
  }

  /// Starts Self-Build Development Project (Kendi İnşaatını Yap • Kendi Şantiyen)
  /// 100% flat share, Stage 1 (Permits) funded upfront, ready for Stage 2 (Excavation)
  bool startSelfBuildConstruction(String landId, {ZoningUnitMix? customUnitMix}) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == landId);
    if (index == -1) return false;

    final land = state.ownedRealEstates[index];
    if (land.category != RealEstateCategory.land) return false;
    if (land.isConstructionActive) return false;

    final effectiveMix = customUnitMix ??
        (land.customUnitMix != null ? ZoningUnitMix.fromMap(land.customUnitMix!) : null);

    // Domain Emsal Check (D2)
    if (effectiveMix != null) {
      final zoning = ZoningEngine.calculateZoning(
        parcelSquareMeters: land.squareMeters.toDouble(),
        baseMarketValue: land.baseMarketValue,
        customUnitMix: effectiveMix,
      );
      if (zoning.isEmsalExceeded) return false;
    }

    // F1·13, F2·5: Ruhsat harcı %10, Hukuk Müşaviri varsa %30 indirim, malzeme endeksi çarpanı
    final hasLegalAdvisor = state.hiredStaff.any((s) => s.role == StaffRole.legalAdvisor);
    final discountMultiplier = hasLegalAdvisor ? 0.70 : 1.0;
    final stageCost = (land.baseMarketValue * 0.10 * discountMultiplier * state.constructionCostIndex).roundToDouble();
    if (state.balance < stageCost) return false;

    final totalUnits = effectiveMix?.totalUnits ?? land.totalProjectUnits;
    final nowStr = DateTime.now().toIso8601String().split('T').first;

    final updatedLand = land.copyWith(
      constructionMode: 'selfBuild',
      playerSharePercent: 100,
      totalProjectUnits: totalUnits,
      customUnitMix: effectiveMix?.toMap(),
      totalConstructionSpent: stageCost,
      soldPreSaleUnits: 0,
      constructionStage: 1,
      constructionDaysRemaining: 0,
      isConstructionWorking: false,
      clearActiveSubcontractor: true,
      stageTotalDays: 0,
      provenanceLog: [
        ...land.provenanceLog,
        '$nowStr • Öz-inşaat şantiyesi kuruldu • Ruhsat ve saha izinleri alındı${hasLegalAdvisor ? ' • Hukuk Müşaviri %30 İndirimi' : ''} • ₺${stageCost.round()}',
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
    if (land.constructionStage < 1 || land.constructionStage > 8) return false;
    if (land.isConstructionWorking) return false; // Already actively working

    final sub = subcontractor ??
        ConstructionTimelineEngine.getSubcontractorsForStage(land.constructionStage)[1]; // Standard default

    // F1·9, F3·2: Malzeme Fiyat Endeksi ile çarpılan tekil etap maliyeti
    final calculatedCost = ConstructionPricing.stageCost(
      land,
      land.constructionStage,
      subcontractor: sub,
      costIndex: state.constructionCostIndex,
    );
    final stageCost = (customStageCost != null && customStageCost > 0)
        ? customStageCost
        : calculatedCost;

    if (state.balance < stageCost) return false;

    final nowStr = DateTime.now().toIso8601String().split('T').first;

    // F1·8, F2·5: Etaba göre risk, usta mekanik ve hava durumu entegrasyonu
    final incident = triggerIncidents
        ? ConstructionNegativeEventsEngine.rollStageIncident(
            stageNumber: land.constructionStage,
            baseStageCost: stageCost,
            riskMultiplier: sub.tier == SubcontractorTier.budget
                ? 1.3
                : (sub.tier == SubcontractorTier.speed ? 0.8 : 1.0),
            hasMasterMechanic: state.hiredStaff.any((s) => s.role == StaffRole.masterMechanic),
            isBadWeather: (state.currentWeather == WeatherType.rainy || state.currentWeather == WeatherType.snowy),
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

    // F3·3: Taşeron kademesine göre kalite skoru değişimi
    double nextQuality = land.qualityScore;
    if (sub.tier == SubcontractorTier.speed) {
      nextQuality = (nextQuality - 5.0).clamp(20.0, 100.0);
    } else if (sub.tier == SubcontractorTier.budget) {
      nextQuality = (nextQuality - 8.0).clamp(20.0, 100.0);
    } else {
      nextQuality = (nextQuality + 2.0).clamp(20.0, 100.0);
    }

    final updatedLand = land.copyWith(
      constructionDaysRemaining: stageDays,
      stageTotalDays: stageDays,
      isConstructionWorking: true,
      activeSubcontractorName: sub.name,
      totalConstructionSpent: land.totalConstructionSpent + stageCost + incidentCost,
      qualityScore: nextQuality,
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
    return true;
  }

  /// Completes the active Self-Build stage when days reach 0 and hands over to the next milestone
  bool completeSelfBuildStage(String landId) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == landId);
    if (index == -1) return false;

    final land = state.ownedRealEstates[index];
    if (land.constructionMode != 'selfBuild') return false;
    if (land.activeSubcontractorName == null || land.activeSubcontractorName!.isEmpty) return false;
    if (land.constructionDaysRemaining > 0) return false; // Must wait for duration to finish

    final nextStage = (land.constructionStage + 1).clamp(1, 8);
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

  /// Funds and advances next milestone in Self-Build mode
  bool advanceSelfBuildStage(String landId, {bool triggerIncidents = true, double? customStageCost}) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == landId);
    if (index == -1) return false;

    final land = state.ownedRealEstates[index];
    if (land.constructionMode != 'selfBuild') return false;
    if (land.constructionStage >= 8) return false;

    final calculatedCost = (land.baseMarketValue *
            ConstructionTimelineEngine.getStageDetails(land.constructionStage)
                .costPercentage)
        .roundToDouble();
    final stageCost = (customStageCost != null && customStageCost > 0)
        ? customStageCost
        : calculatedCost;

    if (state.balance < stageCost) return false;

    final nextStage = (land.constructionStage + 1).clamp(1, 8);
    final nowStr = DateTime.now().toIso8601String().split('T').first;

    final updatedLand = land.copyWith(
      constructionStage: nextStage,
      constructionDaysRemaining: 4,
      isConstructionWorking: true,
      totalConstructionSpent: land.totalConstructionSpent + stageCost,
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
    if (land.constructionStage < 8) return [];
    if (land.constructionDaysRemaining > 0) return [];

    final unitsToCreate = land.playerShareUnits;

    // Slot capacity guard (C2)
    final availableSlots = state.maxRealEstateSlots - (state.ownedRealEstates.length - 1);
    if (unitsToCreate > availableSlots) {
      return [];
    }

    final createdApartments = <RealEstateModel>[];

    // Zoning calculations & fallback unit mix (C5, C6)
    final zoning = ZoningEngine.calculateZoning(
      parcelSquareMeters: land.squareMeters.toDouble(),
      baseMarketValue: land.baseMarketValue,
      customUnitMix: land.customUnitMix != null ? ZoningUnitMix.fromMap(land.customUnitMix!) : null,
    );

    final activeMix = land.customUnitMix != null
        ? ZoningUnitMix.fromMap(land.customUnitMix!)
        : ZoningEngine.optimizeUnitMix(zoning.netResidentialArea);

    final List<Map<String, dynamic>> allProjectUnits = [];
    for (int i = 0; i < activeMix.units4Plus1; i++) {
      allProjectUnits.add({'type': '4+1', 'gross': ZoningUnitMix.grossArea4Plus1, 'net': ZoningUnitMix.netArea4Plus1});
    }
    for (int i = 0; i < activeMix.units3Plus1; i++) {
      allProjectUnits.add({'type': '3+1', 'gross': ZoningUnitMix.grossArea3Plus1, 'net': ZoningUnitMix.netArea3Plus1});
    }
    for (int i = 0; i < activeMix.units2Plus1; i++) {
      allProjectUnits.add({'type': '2+1', 'gross': ZoningUnitMix.grossArea2Plus1, 'net': ZoningUnitMix.netArea2Plus1});
    }
    for (int i = 0; i < activeMix.units2Plus0; i++) {
      allProjectUnits.add({'type': '2+0', 'gross': ZoningUnitMix.grossArea2Plus0, 'net': ZoningUnitMix.netArea2Plus0});
    }
    for (int i = 0; i < activeMix.units1Plus1; i++) {
      allProjectUnits.add({'type': '1+1', 'gross': ZoningUnitMix.grossArea1Plus1, 'net': ZoningUnitMix.netArea1Plus1});
    }
    for (int i = 0; i < activeMix.units1Plus0; i++) {
      allProjectUnits.add({'type': '1+0', 'gross': ZoningUnitMix.grossArea1Plus0, 'net': ZoningUnitMix.netArea1Plus0});
    }

    // Dynamic valuation with emsal premium & quality specification (C5, A7, F1·4, F3·3, F3·4)
    final totalBuildable = max(1.0, zoning.netResidentialArea);
    double avgValuePerM2 = (land.baseMarketValue * 2.8) / totalBuildable;
    avgValuePerM2 *= (1.0 + (zoning.kaks - 1.5) * 0.10);
    if (land.hasQualityUpgrade) {
      avgValuePerM2 *= 1.08;
    }
    final hasRivalPressure = state.recentEvents.any((e) => e.id.contains('rival_project_completed_${land.id}'));
    if (hasRivalPressure) {
      avgValuePerM2 *= 0.92; // F3·4: Rakip erken teslim kırım baskısı (%8)
    }

    // Fair value allocation (C3)
    final List<Map<String, dynamic>> playerAllocatedTypologies = [];
    if (land.constructionMode == 'selfBuild') {
      final remainingUnits = List<Map<String, dynamic>>.from(allProjectUnits);
      for (int s = 0; s < land.soldPreSaleUnits && remainingUnits.isNotEmpty; s++) {
        remainingUnits.removeLast(); // sacrifice smallest units first (C3)
      }
      playerAllocatedTypologies.addAll(remainingUnits.take(unitsToCreate));
    } else {
      if (land.hasPrimeFloorClause) {
        playerAllocatedTypologies.addAll(allProjectUnits.take(unitsToCreate));
      } else {
        // Serpentine 1-2-2-1 fair distribution
        final playerUnits = <Map<String, dynamic>>[];
        bool playerTurn = true;
        int consecutive = 0;
        int targetConsecutive = 1;
        for (final unit in allProjectUnits) {
          if (playerUnits.length >= unitsToCreate) break;
          if (playerTurn) {
            playerUnits.add(unit);
            consecutive++;
            if (consecutive >= targetConsecutive) {
              playerTurn = false;
              consecutive = 0;
              targetConsecutive = 2;
            }
          } else {
            consecutive++;
            if (consecutive >= targetConsecutive) {
              playerTurn = true;
              consecutive = 0;
              targetConsecutive = 2;
            }
          }
        }
        while (playerUnits.length < unitsToCreate && playerUnits.length < allProjectUnits.length) {
          for (final u in allProjectUnits) {
            if (!playerUnits.contains(u)) {
              playerUnits.add(u);
              if (playerUnits.length >= unitsToCreate) break;
            }
          }
        }
        playerAllocatedTypologies.addAll(playerUnits);
      }
    }

    // Unit acquisition cost calculation for accurate profit accounting (C4)
    final totalInvested = land.currentPurchasePrice +
        land.deedFeePaid +
        land.commissionPaid +
        land.totalConstructionSpent;
    final costPerUnit = unitsToCreate > 0 ? (totalInvested / unitsToCreate).roundToDouble() : 0.0;

    for (int i = 0; i < unitsToCreate; i++) {
      final typology = (i < playerAllocatedTypologies.length)
          ? playerAllocatedTypologies[i]
          : (i < allProjectUnits.length ? allProjectUnits[i] : {'type': '2+1', 'gross': 105.0, 'net': 88.0});

      final grossM2 = (typology['gross'] as num).toDouble();
      final roomType = typology['type'] as String;
      final unitVal = (grossM2 * (avgValuePerM2 > 0 ? avgValuePerM2 : 35000.0)).roundToDouble();

      // F3·3: Kalite ve gizli kusur değerlendirmesi
      final bool hasHiddenDefect = (land.qualityScore < 60.0);
      final double qualityMultiplier = land.qualityScore >= 85.0
          ? 1.15 // +%15 piyasa primi
          : (land.qualityScore < 60.0 ? 0.85 : 1.0); // -%15 kırım
      final finalUnitVal = (unitVal * qualityMultiplier).roundToDouble();

      createdApartments.add(
        RealEstateModel(
          id: 're_turnkey_${land.id}_$i',
          title: '${land.district} Rezidans • Daire #${i + 1} - $roomType',
          category: RealEstateCategory.housing,
          city: land.city,
          district: land.district,
          squareMeters: grossM2.round(),
          roomCount: roomType,
          buildingAge: 0,
          deedType: DeedType.ownershipDeed, // Kat Mülkiyeti (İskanlı, sorunsuz)
          sellerType: RealEstateSellerType.individual,
          baseMarketValue: finalUnitVal > 0 ? finalUnitVal : 3500000.0,
          currentPurchasePrice: costPerUnit, // C4
          isRenovated: true,
          renovationStage: 3,
          hasWaterLeakRisk: hasHiddenDefect, // F3·3: Düşük kalitede gizli su kaçağı kusuru
          qualityScore: land.qualityScore,
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

  /// Takes a mortgage-backed construction loan using land parcel as collateral (F2·6, F5)
  bool takeConstructionLoan(String landId, double amount) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == landId);
    if (index == -1) return false;

    final land = state.ownedRealEstates[index];
    if (land.category != RealEstateCategory.land) return false;
    if (land.isMortgaged) return false;

    final maxLoan = (land.baseMarketValue * 0.50).roundToDouble();
    if (amount <= 0 || amount > maxLoan) return false;

    final loanId = 'loan_construction_${land.id}';
    final totalRepayment = (amount * 1.25).roundToDouble();
    final newLoan = LoanModel(
      id: loanId,
      bankName: 'Emlak Katılım Bankası • Şantiye Finansmanı',
      principalAmount: amount,
      interestRate: 0.25,
      totalRepayment: totalRepayment,
      remainingAmount: totalRepayment,
      totalInstallments: 12,
      remainingInstallments: 12,
      monthlyPayment: (totalRepayment / 12).roundToDouble(),
    );

    final nowStr = DateTime.now().toIso8601String().split('T').first;
    final updatedLand = land.copyWith(
      isMortgaged: true,
      provenanceLog: [
        ...land.provenanceLog,
        '$nowStr • Emlak Katılım Bankası • Arsa ipoteği karşılığı ₺${amount.round()} inşaat kredisi çekildi',
      ],
    );

    final updatedLands = List<RealEstateModel>.from(state.ownedRealEstates);
    updatedLands[index] = updatedLand;

    final updatedLoans = List<LoanModel>.from(state.activeLoans)..add(newLoan);

    state = state.copyWith(
      balance: state.balance + amount,
      ownedRealEstates: updatedLands,
      activeLoans: updatedLoans,
    );

    saveState();
    return true;
  }

  /// Repays the construction loan and releases the mortgage on the land (F2·6, F5)
  bool repayConstructionLoan(String landId) {
    final landIndex = state.ownedRealEstates.indexWhere((r) => r.id == landId);
    if (landIndex == -1) return false;

    final land = state.ownedRealEstates[landIndex];
    if (!land.isMortgaged) return false;

    final loanId = 'loan_construction_${land.id}';
    final loanIndex = state.activeLoans.indexWhere((l) => l.id == loanId);
    if (loanIndex == -1) {
      final updatedLands = List<RealEstateModel>.from(state.ownedRealEstates);
      updatedLands[landIndex] = land.copyWith(isMortgaged: false);
      state = state.copyWith(ownedRealEstates: updatedLands);
      saveState();
      return true;
    }

    final loan = state.activeLoans[loanIndex];
    if (state.balance < loan.remainingAmount) return false;

    final nowStr = DateTime.now().toIso8601String().split('T').first;
    final updatedLand = land.copyWith(
      isMortgaged: false,
      provenanceLog: [
        ...land.provenanceLog,
        '$nowStr • İnşaat kredisi kapatıldı • Arsa üzerindeki banka ipoteği kaldırıldı',
      ],
    );

    final updatedLands = List<RealEstateModel>.from(state.ownedRealEstates);
    updatedLands[landIndex] = updatedLand;

    final updatedLoans = List<LoanModel>.from(state.activeLoans)..removeAt(loanIndex);

    state = state.copyWith(
      balance: state.balance - loan.remainingAmount,
      ownedRealEstates: updatedLands,
      activeLoans: updatedLoans,
    );

    saveState();
    return true;
  }
}
