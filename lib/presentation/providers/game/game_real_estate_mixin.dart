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
    final updatedProperty = property.copyWith(isRented: !property.isRented);

    final updatedList = List<RealEstateModel>.from(state.ownedRealEstates);
    updatedList[index] = updatedProperty;

    state = state.copyWith(ownedRealEstates: updatedList);
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
}
