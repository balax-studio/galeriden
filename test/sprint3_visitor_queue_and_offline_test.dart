import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/domain/usecases/visitor_queue_engine.dart';
import 'package:galeriden/domain/usecases/offline_progression.dart';

void main() {
  group('Sprint 3: Visitor Queue & Realistic Offline Progression Tests', () {
    test('VisitorQueueEngine calculates faster visitor arrival for doped cars and reputable dealers', () {
      final normalCar = CarModel(
        id: 'c_normal',
        brand: 'Bemeve',
        modelName: '320i',
        modelYear: 2018,
        bodyType: 'Sedan',
        colorHex: '0xFF000000',
        baseMarketValue: 500000.0,
        currentPurchasePrice: 450000.0,
        expertise: ExpertiseReport(
          engineCondition: 90.0,
          transmissionCondition: 90.0,
          tramerAmount: 0,
          mileage: 80000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );

      final dopedCar = normalCar.copyWith(isDoped: true);

      final normalSeconds = VisitorQueueEngine.calculateNextVisitorSeconds(
        car: normalCar,
        reputation: 100,
        hasSalesman: false,
      );

      final dopedSeconds = VisitorQueueEngine.calculateNextVisitorSeconds(
        car: dopedCar,
        reputation: 100,
        hasSalesman: false,
      );

      final masterSalesmanSeconds = VisitorQueueEngine.calculateNextVisitorSeconds(
        car: normalCar,
        reputation: 150,
        hasSalesman: true,
      );

      expect(dopedSeconds, lessThan(normalSeconds));
      expect(masterSalesmanSeconds, lessThan(normalSeconds));
    });

    test('OfflineProgression simulates full offline time without clamp(1, 5) limits up to 12 hours', () {
      final now = DateTime.now();
      final sixHoursAgo = now.subtract(const Duration(hours: 6));

      final initialDealership = DealershipModel.initial().copyWith(
        lastActiveTime: sixHoursAgo,
        balance: 100000.0,
      );

      final result = OfflineProgression.processOfflineTime(initialDealership, currentTime: now);
      expect(result.containsKey('updatedDealership'), isTrue);
      expect(result.containsKey('hoursAway'), isTrue);
      expect(result['hoursAway'], equals(6));

      final DealershipModel updated = result['updatedDealership'] as DealershipModel;
      expect(updated.currentDay, greaterThan(initialDealership.currentDay));
    });
  });
}
