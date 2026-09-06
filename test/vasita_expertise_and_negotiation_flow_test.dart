import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/vehicle_category.dart';
import 'package:galeriden/domain/usecases/vasita_market_engine.dart';

void main() {
  group('Vasita Dynamic Expertise & Safety Analysis Tests', () {
    test('VasitaMarketEngine generates authentic body parts per vehicle category', () {
      final listings = VasitaMarketEngine.generateListings(count: 30);
      for (final listing in listings) {
        final exp = listing.car.expertise;
        // Body parts must not be empty
        expect(exp.bodyParts.isNotEmpty, isTrue);

        if (listing.car.vehicleCategory == VehicleCategory.motorcycle) {
          expect(exp.bodyParts.containsKey('Ön Maşa & Gidon'), isTrue);
          expect(exp.bodyParts.containsKey('Depo / Yakıt Tankı'), isTrue);
        } else if (listing.car.vehicleCategory == VehicleCategory.marine) {
          expect(exp.bodyParts.containsKey('Gövde / Karina'), isTrue);
        } else if (listing.car.vehicleCategory == VehicleCategory.aircraft) {
          expect(exp.bodyParts.containsKey('Gövde (Füzelaj)'), isTrue);
          expect(exp.isChassisAligned, isTrue);
          expect(exp.hasAirbagDeployed, isFalse);
          expect(exp.isMileageTampered, isFalse);
        }
      }
    });

    test('Chassis alignment is not fixed: clean vehicles have intact chassis', () {
      final listings = VasitaMarketEngine.generateListings(count: 40);
      final alignedCount = listings.where((l) => l.car.expertise.isChassisAligned).length;
      final damagedChassisCount = listings.where((l) => !l.car.expertise.isChassisAligned).length;

      // In a normal batch of 40 vehicles, the vast majority must have clean/intact chassis, not 100% damaged
      expect(alignedCount, greaterThan(20));
      expect(damagedChassisCount, lessThan(alignedCount));
      // Variations must exist across categories
      final cleanCars = listings.where((l) => l.car.expertise.tramerAmount == 0).toList();
      for (final cleanCar in cleanCars) {
        expect(cleanCar.car.expertise.isChassisAligned, isTrue);
      }
    });

    test('Damaged category vehicles frequently have compromised chassis', () {
      final damagedListings = VasitaMarketEngine.generateListings(
        count: 20,
        categoryFilter: VehicleCategory.damaged,
      );
      final compromisedCount =
          damagedListings.where((l) => !l.car.expertise.isChassisAligned).length;
      expect(compromisedCount, greaterThan(0));
    });

    test('ExpertiseReport serialization preserves isChassisAligned and hasAirbagDeployed', () {
      final report = ExpertiseReport(
        engineCondition: 92.0,
        transmissionCondition: 89.0,
        tramerAmount: 65000,
        mileage: 65000,
        isMileageTampered: true,
        isChassisAligned: false,
        hasAirbagDeployed: true,
        bodyParts: {'Kaput': PartStatus.changed},
      );

      final json = report.toJson();
      expect(json['isChassisAligned'], isFalse);
      expect(json['hasAirbagDeployed'], isTrue);
      expect(json['isMileageTampered'], isTrue);

      final reconstructed = ExpertiseReport.fromJson(json);
      expect(reconstructed.isChassisAligned, isFalse);
      expect(reconstructed.hasAirbagDeployed, isTrue);
      expect(reconstructed.isMileageTampered, isTrue);
    });
  });
}
