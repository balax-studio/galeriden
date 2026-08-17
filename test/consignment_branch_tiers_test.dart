import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/domain/usecases/consignment_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Consignment & Escrow 8-Tier Dealership Engine Tests', () {
    test('generateConsignmentOffers generates branch-scaled cars and NPC owners for all 8 tiers', () {
      for (int tier = 1; tier <= 8; tier++) {
        final offers = ConsignmentEngine.generateConsignmentOffers(
          inGameDay: 5,
          branchTier: tier,
          reputationScore: 100,
        );

        expect(offers, isNotEmpty);
        expect(offers.length, greaterThanOrEqualTo(2));

        for (final car in offers) {
          expect(car.isConsignment, isTrue);
          expect(car.currentPurchasePrice, equals(0.0)); // Zero capital requirement
          expect(car.consignmentOwnerName, isNotNull);
          expect(car.consignmentOwnerName, isNotEmpty);
          expect(car.consignmentCommissionRate, greaterThan(0.05));
          expect(car.consignmentDaysRemaining, greaterThanOrEqualTo(10));
        }

        // Verify tier pricing scaling
        final avgPrice = offers.map((c) => c.baseMarketValue).reduce((a, b) => a + b) / offers.length;
        if (tier == 1) {
          expect(avgPrice, lessThanOrEqualTo(180000));
        } else if (tier >= 7) {
          expect(avgPrice, greaterThanOrEqualTo(3000000));
        }
      }
    });

    test('Higher branch tiers have higher daily parking and showcase fees', () {
      final feeTier1 = ConsignmentEngine.calculateDailyParkingFee(1);
      final feeTier4 = ConsignmentEngine.calculateDailyParkingFee(4);
      final feeTier8 = ConsignmentEngine.calculateDailyParkingFee(8);

      expect(feeTier1, greaterThanOrEqualTo(200));
      expect(feeTier4, greaterThan(feeTier1));
      expect(feeTier8, greaterThan(feeTier4));
      expect(feeTier8, greaterThanOrEqualTo(25000));
    });

    test('High reputation grants a commission rate bonus', () {
      final lowRepOffers = ConsignmentEngine.generateConsignmentOffers(
        inGameDay: 1,
        branchTier: 4,
        reputationScore: 20,
      );

      final highRepOffers = ConsignmentEngine.generateConsignmentOffers(
        inGameDay: 1,
        branchTier: 4,
        reputationScore: 200,
      );

      final avgLowRate = lowRepOffers.map((c) => c.consignmentCommissionRate).reduce((a, b) => a + b) / lowRepOffers.length;
      final avgHighRate = highRepOffers.map((c) => c.consignmentCommissionRate).reduce((a, b) => a + b) / highRepOffers.length;

      expect(avgHighRate, greaterThan(avgLowRate));
    });

    test('calculateCommissionEarnings yields substantial zero-capital profits on sale', () {
      final car = CarModel(
        id: 'test_consignment_car',
        brand: 'Mercedes-Benz',
        modelName: 'E 250 CGI AMG',
        modelYear: 2014,
        bodyType: 'Sedan',
        colorHex: '#000000',
        baseMarketValue: 1400000,
        currentPurchasePrice: 0.0,
        isDetailedCleaned: false,
        isWashed: true,
        isPolished: false,
        isRare: false,
        isConsignment: true,
        consignmentCommissionRate: 0.12,
        consignmentOwnerName: 'Müteahhit Rıfat',
        consignmentDaysRemaining: 12,
        expertise: ExpertiseReport(
          engineCondition: 85,
          transmissionCondition: 80,
          tramerAmount: 12000,
          mileage: 165000,
          isMileageTampered: false,
          bodyParts: {'Kaput': PartStatus.original},
        ),
      );

      final netEarnings = ConsignmentEngine.calculateCommissionEarnings(car, 1500000);
      expect(netEarnings, equals(180000.0)); // 1.500.000 * 0.12 = 180.000 TL pure profit!
    });
  });
}
