import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/offer_model.dart';
import 'package:galeriden/data/models/rental_agreement_model.dart';
import 'package:galeriden/domain/usecases/rental_progression_engine.dart';
import 'package:galeriden/presentation/providers/game/game_core_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Rental & Showcase Gating Test Suite', () {
    late GameCoreNotifier notifier;
    late CarModel testCar;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      notifier = GameCoreNotifier();
      notifier.stopPeriodicOrganicOfferTimer();

      testCar = CarModel(
        id: 'test_car_1',
        brand: 'BMW',
        modelName: '320i',
        bodyType: 'Sedan',
        colorHex: '#000000',
        modelYear: 2020,
        currentPurchasePrice: 800000.0,
        baseMarketValue: 850000.0,
        expertise: ExpertiseReport(
          engineCondition: 90.0,
          transmissionCondition: 90.0,
          tramerAmount: 0,
          mileage: 45000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );

      notifier.state = notifier.state.copyWith(
        ownedCars: [testCar],
        incomingOffers: [],
        activeRentals: [],
      );
    });

    tearDown(() {
      notifier.stopPeriodicOrganicOfferTimer();
    });

    test('1. Renting a car de-lists it and purges active incoming offers', () {
      // First list the car
      notifier.updateCarListingDetails('test_car_1', customPrice: 900000.0);
      expect(notifier.state.ownedCars.first.isListed, isTrue);

      // Add a dummy incoming offer for this car
      final offer = OfferModel(
        id: 'offer_1',
        carId: 'test_car_1',
        buyerName: 'Ahmet',
        offeredAmount: 880000.0,
        buyerMessage: 'Aracı beğendim',
        createdAt: DateTime.now(),
      );
      notifier.state = notifier.state.copyWith(incomingOffers: [offer]);
      expect(notifier.state.incomingOffers.length, equals(1));

      // Now rent the car
      final rented = notifier.rentCar('test_car_1', 2500.0);
      expect(rented, isTrue);

      final carAfterRent = notifier.state.ownedCars.first;
      expect(carAfterRent.isRented, isTrue);
      expect(carAfterRent.isListed, isFalse);
      expect(carAfterRent.customListingPrice, isNull);
      // All pending offers for the rented car must be removed
      expect(notifier.state.incomingOffers.any((o) => o.carId == 'test_car_1'), isFalse);

      // Attempting to list a rented car must fail
      notifier.updateCarListingDetails('test_car_1', customPrice: 950000.0);
      expect(notifier.state.ownedCars.first.isListed, isFalse);
    });

    test('2. Locking a car in showcase de-lists it and purges active incoming offers', () {
      // First list the car
      notifier.updateCarListingDetails('test_car_1', customPrice: 900000.0);
      expect(notifier.state.ownedCars.first.isListed, isTrue);

      // Add a dummy incoming offer for this car
      final offer = OfferModel(
        id: 'offer_2',
        carId: 'test_car_1',
        buyerName: 'Mehmet',
        offeredAmount: 890000.0,
        buyerMessage: 'Hemen alırım',
        createdAt: DateTime.now(),
      );
      notifier.state = notifier.state.copyWith(incomingOffers: [offer]);
      expect(notifier.state.incomingOffers.length, equals(1));

      // Lock car in showcase
      final locked = notifier.toggleShowcaseLock('test_car_1');
      expect(locked, isTrue);

      final carAfterLock = notifier.state.ownedCars.first;
      expect(carAfterLock.isLockedInShowcase, isTrue);
      expect(carAfterLock.isListed, isFalse);
      expect(carAfterLock.customListingPrice, isNull);
      // Pending offers must be purged
      expect(notifier.state.incomingOffers.any((o) => o.carId == 'test_car_1'), isFalse);

      // Attempting to list a showcase-locked car must fail
      notifier.updateCarListingDetails('test_car_1', customPrice: 950000.0);
      expect(notifier.state.ownedCars.first.isListed, isFalse);
    });

    test('3. triggerOrganicOffers and manualPullOrganicOffer ignore rented and showcase-locked cars', () {
      // When car is locked in showcase
      notifier.toggleShowcaseLock('test_car_1');
      notifier.triggerOrganicOffers();
      expect(notifier.state.incomingOffers.isEmpty, isTrue);

      final pullResult1 = notifier.manualPullOrganicOffer();
      expect(pullResult1.hasNewOffer, isFalse);

      // Unlock and rent the car
      notifier.toggleShowcaseLock('test_car_1');
      notifier.rentCar('test_car_1', 2000.0);
      notifier.triggerOrganicOffers();
      expect(notifier.state.incomingOffers.isEmpty, isTrue);

      final pullResult2 = notifier.manualPullOrganicOffer();
      expect(pullResult2.hasNewOffer, isFalse);
    });

    test('4. RentalProgressionEngine executes daily events with higher frequency', () {
      final agreement = RentalAgreement(
        id: 'rent_test_1',
        carId: 'test_car_1',
        dailyRate: 3000.0,
        renterType: 'young_driver',
        renterName: 'Berkcan',
      );

      final (newBal, newCars, newRentals, newEvents, newOffers) =
          RentalProgressionEngine.processDailyRentals(
        balance: 50000.0,
        cars: [testCar],
        rentals: [agreement],
        events: [],
        incomingOffers: [],
      );

      expect(newRentals.first.rentedDays, equals(1));
      expect(newRentals.first.totalEarned, greaterThan(0));
    });
  });
}
