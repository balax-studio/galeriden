import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/side_business_model.dart';
import 'package:galeriden/domain/usecases/market_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Sprint 0 & 1: P0 Critical & Economy Dengeleme Tests', () {
    test('P0-1: CarModel.estimatedRealValue rewards body repair and calculates damage penalty correctly', () {
      final damagedCar = CarModel(
        id: 'car_test_1',
        brand: 'Tofaşk',
        modelName: 'Hacı Murat 124',
        modelYear: 1978,
        bodyType: 'Sedan',
        colorHex: '0xFF8B4513',
        baseMarketValue: 240000.0,
        currentPurchasePrice: 0.0,
        isRare: true,
        expertise: ExpertiseReport(
          engineCondition: 100.0,
          transmissionCondition: 100.0,
          tramerAmount: 12500,
          mileage: 215000,
          isMileageTampered: false,
          bodyParts: {
            'Kaput': PartStatus.damaged,
            'Tavan': PartStatus.painted,
            'Sol Kapı': PartStatus.changed,
            'Sağ Kapı': PartStatus.damaged,
            'Bagaj': PartStatus.painted,
          },
        ),
      );

      final fullyRestoredCar = damagedCar.copyWith(
        expertise: ExpertiseReport(
          engineCondition: 100.0,
          transmissionCondition: 100.0,
          tramerAmount: 12500,
          mileage: 215000,
          isMileageTampered: false,
          bodyParts: {
            'Kaput': PartStatus.original,
            'Tavan': PartStatus.original,
            'Sol Kapı': PartStatus.original,
            'Sağ Kapı': PartStatus.original,
            'Bagaj': PartStatus.original,
          },
        ),
      );

      // Value must significantly increase when 5 body parts are restored
      expect(fullyRestoredCar.estimatedRealValue, greaterThan(damagedCar.estimatedRealValue + 30000.0));
    });

    test('P0.5 #3: MarketEngine.generateRandomListings generates exact requested count', () {
      final listings3 = MarketEngine.generateRandomListings(count: 3, playerLevel: 1);
      expect(listings3.length, equals(3));

      final listings7 = MarketEngine.generateRandomListings(count: 7, playerLevel: 2);
      expect(listings7.length, equals(7));
    });

    test('P0.5 #5: CarModel.copyWith supports clearListingPrice flag', () {
      final car = CarModel(
        id: 'c1',
        brand: 'BMW',
        modelName: '320i',
        modelYear: 2018,
        bodyType: 'Sedan',
        colorHex: '0xFF000000',
        baseMarketValue: 600000.0,
        currentPurchasePrice: 500000.0,
        customListingPrice: 650000.0,
        expertise: ExpertiseReport(
          engineCondition: 90.0,
          transmissionCondition: 90.0,
          tramerAmount: 0,
          mileage: 80000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );

      expect(car.customListingPrice, equals(650000.0));
      final unlistedCar = car.copyWith(clearListingPrice: true);
      expect(unlistedCar.customListingPrice, isNull);
    });

    test('P0.5 #7 & P1-3c: Bank & Side Business economy parameters', () {
      final model = DealershipModel.initial();
      expect(model.bankCreditLimit, lessThanOrEqualTo(500000.0)); // Initial credit limit ₺250.000
      
      final business = SideBusinessModel(
        id: 'test_sb',
        name: 'Test Business',
        description: 'Testing',
        type: SideBusinessType.vendingMachine,
        dailyIncome: 1000.0,
        cost: 25000.0,
        level: 2,
      );

      // Higher level upgrades should scale quadratically to prevent instant ROI exploit
      expect(business.nextLevelUpgradeCost, greaterThan(business.cost * 1.20 * 2));
    });
  });
}
