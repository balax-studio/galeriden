import 'package:flutter/foundation.dart';
import '../../../data/models/real_estate_category.dart';
import '../../../data/models/real_estate_model.dart';
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

  /// Sets or relocates the player's personal residence
  bool setPersonalResidence(String realEstateId) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == realEstateId);
    if (index == -1) return false;

    final property = state.ownedRealEstates[index];
    // Cannot reside in property currently leased to tenants or under renovation
    if (property.isRented || property.isUnderRenovation) return false;

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

    final updatedProperty = property.copyWith(
      renovationStage: nextStage,
      renovationDaysRemaining: isNowFullyRenovated ? 0 : 2,
      isRenovated: isNowFullyRenovated,
      provenanceLog: [
        ...property.provenanceLog,
        stageLog,
      ],
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

  /// Upgrades maximum real estate portfolio slots (+2 slots)
  bool expandRealEstateSlots() {
    const expansionCost = 500000.0;
    if (state.balance < expansionCost) return false;

    state = state.copyWith(
      balance: state.balance - expansionCost,
      maxRealEstateSlots: state.maxRealEstateSlots + 2,
    );

    addXP(200);
    saveState();
    return true;
  }

  /// Starts Contractor Construction Agreement (Kat Karşılığı Müteahhit Sözleşmesi)
  /// 0 upfront cost, 50% flat share, 5 days per milestone
  bool startContractorConstruction(String landId) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == landId);
    if (index == -1) return false;

    final land = state.ownedRealEstates[index];
    if (land.category != RealEstateCategory.land) return false;
    if (land.isConstructionActive) return false;

    final totalUnits = land.totalProjectUnits;

    final nowStr = DateTime.now().toIso8601String().split('T').first;
    final updatedLand = land.copyWith(
      constructionMode: 'contractor',
      contractorSharePercent: 50,
      totalProjectUnits: totalUnits,
      soldPreSaleUnits: 0,
      constructionStage: 1,
      constructionDaysRemaining: 5,
      provenanceLog: [
        ...land.provenanceLog,
        '$nowStr • Müteahhitle kat karşılığı sözleşmesi imzalandı • $totalUnits Dairelik Proje • %50 Oyuncu Payı',
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
      constructionDaysRemaining: 4,
      provenanceLog: [
        ...land.provenanceLog,
        '$nowStr • Öz-inşaat şantiyesi kuruldu • Aşama 1 Hafriyat başladı • ₺${stageCost.round()}',
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

  /// Funds and advances next milestone in Self-Build mode
  bool advanceSelfBuildStage(String landId) {
    final index = state.ownedRealEstates.indexWhere((r) => r.id == landId);
    if (index == -1) return false;

    final land = state.ownedRealEstates[index];
    if (land.constructionMode != 'selfBuild') return false;
    if (land.constructionStage < 1 || land.constructionStage >= 4) return false;

    // Stage cost calculation based on next stage (2: Kaba İnşaat, 3: Çatı/Cephe, 4: İskan)
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

    final stageCost = (land.baseMarketValue * stageRate).roundToDouble();
    if (state.balance < stageCost) return false;

    final nextStage = land.constructionStage + 1;
    final nowStr = DateTime.now().toIso8601String().split('T').first;

    final updatedLand = land.copyWith(
      constructionStage: nextStage,
      constructionDaysRemaining: 4,
      provenanceLog: [
        ...land.provenanceLog,
        '$nowStr • Şantiye Aşama $nextStage fonlandı ve başladı • ₺${stageCost.round()}',
      ],
    );

    final updatedList = List<RealEstateModel>.from(state.ownedRealEstates);
    updatedList[index] = updatedLand;

    state = state.copyWith(
      balance: state.balance - stageCost,
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
