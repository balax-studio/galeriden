import '../../../data/models/car_model.dart';
import '../../../data/models/mega_systems_extensions_model.dart';
import '../../../data/models/mission_model.dart';
import '../../../data/models/rental_agreement_model.dart';
import 'game_base_notifier.dart';

mixin GameRentalMixin on GameBaseNotifier {
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
    if (car.isRented ||
        car.isConsignment ||
        state.activeRentals.any((r) => r.carId == carId)) {
      return false;
    }

    // Cap daily rate to maximum rate
    final carValue = car.currentPurchasePrice > 0
        ? car.currentPurchasePrice
        : car.estimatedRealValue;
    final maxRateMultiplier = renterType == 'young_driver' ? 0.016 : 0.012;
    final maxAllowedDailyRate =
        (carValue * maxRateMultiplier).clamp(100.0, 60000.0);
    final validatedDailyRate = dailyRate.clamp(100.0, maxAllowedDailyRate);

    // Kasko daily fee: 0.1% of car value (min 150 TL, max 1.500 TL)
    final insuranceDailyFee =
        hasInsurance ? (carValue * 0.001).clamp(150.0, 1500.0) : 0.0;

    String resolvedRenterName = renterName ?? '';
    if (resolvedRenterName.isEmpty) {
      if (renterType == 'corporate') {
        final corpNames = [
          'Anadolu Filo & Lojistik',
          'Kuzey Holding A.Ş.',
          'Mavi Bulut Danışmanlık',
          'Atlas Medikal'
        ];
        resolvedRenterName =
            corpNames[DateTime.now().millisecondsSinceEpoch % corpNames.length];
      } else if (renterType == 'young_driver') {
        final youngNames = [
          'Bora & Ceyda • Düğün',
          'Gurbetçi Berkcan',
          'Kürşat & Arkadaşları • Tatil',
          'Cengiz • Hızlı Sürücü'
        ];
        resolvedRenterName = youngNames[
            DateTime.now().millisecondsSinceEpoch % youngNames.length];
      } else {
        final indivNames = [
          'Av. Mehmet Bey',
          'Mimar Sinan Bey',
          'Doktor Ayşe Hanım',
          'Öğretmen Kemal'
        ];
        resolvedRenterName = indivNames[
            DateTime.now().millisecondsSinceEpoch % indivNames.length];
      }
    }

    final updatedCar = car.copyWith(
      isRented: true,
      clearListingPrice: true,
    );
    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    final updatedOffers =
        state.incomingOffers.where((o) => o.carId != carId).toList();

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
    updateMissionProgress(MissionType.rentCar, 1);
    saveState();
    return true;
  }

  /// Return Rented Car (Self-healing: returns true and cleans up even if car was removed)
  bool returnRentedCar(String agreementId) {
    final rentalIndex =
        state.activeRentals.indexWhere((r) => r.id == agreementId);
    if (rentalIndex == -1) return false;

    final rental = state.activeRentals[rentalIndex];
    final updatedRentals = List<RentalAgreement>.from(state.activeRentals)
      ..removeAt(rentalIndex);

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
  /// and removes orphaned rental agreements for non-existent cars.
  void syncRentalState() {
    final ownedCarIds = state.ownedCars.map((c) => c.id).toSet();
    final validRentals = state.activeRentals
        .where((r) => ownedCarIds.contains(r.carId))
        .toList();
    final rentedCarIds = validRentals.map((r) => r.carId).toSet();
    bool needsUpdate = validRentals.length != state.activeRentals.length;

    final syncedCars = state.ownedCars.map((car) {
      final shouldBeRented = rentedCarIds.contains(car.id);
      if (car.isRented != shouldBeRented) {
        needsUpdate = true;
        return car.copyWith(isRented: shouldBeRented);
      }
      return car;
    }).toList();

    if (needsUpdate) {
      state = state.copyWith(
        ownedCars: syncedCars,
        activeRentals: validRentals,
      );
      saveState();
    }
  }

  /// VIP Dizi / Reklam Makam Aracı Kiralama Kabulü (§15)
  bool acceptVipFilmSetRental(VipSetRentalContract contract) {
    final carIndex = state.ownedCars.indexWhere((c) => c.id == contract.carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    if (car.isRented ||
        car.isLockedInShowcase ||
        car.appliedDetailingOptionIds.contains('rented_to_film_set')) {
      return false;
    }
    final updatedCar = car.copyWith(
      appliedDetailingOptionIds:
          List<String>.from(car.appliedDetailingOptionIds)
            ..add('rented_to_film_set'),
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
}
