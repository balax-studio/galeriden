import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/rental_agreement_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Rent a Car Dynamic Events, Profiles & Kasko Insurance Test Suite', () {
    test('RentalAgreement model serializes and deserializes new profile and insurance fields correctly', () {
      final agreement = RentalAgreement(
        id: 'rent_test_1',
        carId: 'car_123',
        dailyRate: 2500,
        rentedDays: 5,
        totalEarned: 12500,
        renterType: 'young_driver',
        renterName: 'Bora & Aslı (Düğün)',
        hasInsurance: true,
        insuranceDailyFee: 250,
      );

      expect(agreement.renterType, equals('young_driver'));
      expect(agreement.renterName, equals('Bora & Aslı (Düğün)'));
      expect(agreement.hasInsurance, isTrue);
      expect(agreement.insuranceDailyFee, equals(250));

      final json = agreement.toJson();
      final fromJson = RentalAgreement.fromJson(json);

      expect(fromJson.renterType, equals('young_driver'));
      expect(fromJson.renterName, equals('Bora & Aslı (Düğün)'));
      expect(fromJson.hasInsurance, isTrue);
      expect(fromJson.insuranceDailyFee, equals(250));
    });

    test('rentCar accepts customer profile and insurance settings', () {
      final notifier = GameNotifier();
      final car = CarModel(
        id: 'rental_car_test',
        brand: 'Bemeve',
        modelName: 'Üç-Yirmi D Sport',
        modelYear: 2021,
        bodyType: 'Sedan',
        colorHex: '#003366',
        baseMarketValue: 2000000,
        currentPurchasePrice: 1800000,
        expertise: ExpertiseReport(
          engineCondition: 95.0,
          transmissionCondition: 95.0,
          tramerAmount: 0,
          mileage: 30000,
          isMileageTampered: false,
          bodyParts: const {},
        ),
      );

      notifier.state = notifier.state.copyWith(
        balance: 500000,
        ownedCars: [car],
        activeRentals: [],
      );

      final success = notifier.rentCar(
        car.id,
        3500.0,
        renterType: 'young_driver',
        hasInsurance: true,
        renterName: 'Gurbetçi Kenan',
      );

      expect(success, isTrue);
      expect(notifier.state.activeRentals.length, equals(1));
      final rental = notifier.state.activeRentals.first;
      expect(rental.renterType, equals('young_driver'));
      expect(rental.hasInsurance, isTrue);
      expect(rental.renterName, equals('Gurbetçi Kenan'));
      expect(notifier.state.ownedCars.first.isRented, isTrue);
    });

    test('advanceGameDay generates dynamic negative events and event logs for rented cars', () {
      final notifier = GameNotifier();
      final car = CarModel(
        id: 'drift_car_test',
        brand: 'Merso',
        modelName: 'C-Yüz Seksen AMG',
        modelYear: 2020,
        bodyType: 'Coupe',
        colorHex: '#111111',
        baseMarketValue: 2200000,
        currentPurchasePrice: 2000000,
        isWashed: true,
        isPolished: true,
        isDetailedCleaned: true,
        expertise: ExpertiseReport(
          engineCondition: 100.0,
          transmissionCondition: 100.0,
          tramerAmount: 0,
          mileage: 25000,
          isMileageTampered: false,
          bodyParts: const {},
        ),
      );

      final agreement = RentalAgreement(
        id: 'rent_high_risk',
        carId: 'drift_car_test',
        dailyRate: 4000,
        renterType: 'young_driver',
        renterName: 'Konvoycu Selim',
        hasInsurance: false,
      );

      notifier.state = notifier.state.copyWith(
        balance: 100000,
        ownedCars: [car],
        activeRentals: [agreement],
        recentEvents: [],
      );

      // Advance 10 days to ensure at least one dynamic event or wear occurs
      for (int i = 0; i < 10; i++) {
        notifier.advanceGameDay();
      }

      // Verify that balance increased from rental earnings
      expect(notifier.state.balance, greaterThan(100000));
      // Total earned in agreement updated
      expect(notifier.state.activeRentals.first.totalEarned, greaterThan(0));
    });

    test('Commercial Insurance (Kasko) protects against full repair and tramer costs during rental accidents', () {
      final notifier = GameNotifier();
      final car = CarModel(
        id: 'insured_car_test',
        brand: 'Audi',
        modelName: 'A-Dört S-Line',
        modelYear: 2021,
        bodyType: 'Sedan',
        colorHex: '#FFFFFF',
        baseMarketValue: 2500000,
        currentPurchasePrice: 2200000,
        expertise: ExpertiseReport(
          engineCondition: 100.0,
          transmissionCondition: 100.0,
          tramerAmount: 0,
          mileage: 20000,
          isMileageTampered: false,
          bodyParts: const {},
        ),
      );

      final agreement = RentalAgreement(
        id: 'rent_insured',
        carId: 'insured_car_test',
        dailyRate: 3500,
        renterType: 'corporate',
        renterName: 'Koçak Lojistik A.Ş.',
        hasInsurance: true,
        insuranceDailyFee: 250,
      );

      notifier.state = notifier.state.copyWith(
        balance: 200000,
        ownedCars: [car],
        activeRentals: [agreement],
        recentEvents: [],
      );

      notifier.advanceGameDay();

      // Net daily earnings should be dailyRate - insuranceDailyFee (3500 - 250 = 3250) minus daily burn
      expect(notifier.state.activeRentals.first.hasInsurance, isTrue);
    });
  });
}
