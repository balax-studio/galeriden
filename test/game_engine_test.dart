import 'package:flutter_test/flutter_test.dart';
import 'package:galerisinden/domain/usecases/market_engine.dart';
import 'package:galerisinden/domain/usecases/expertise_engine.dart';
import 'package:galerisinden/domain/usecases/repair_engine.dart';
import 'package:galerisinden/domain/usecases/negotiation_engine.dart';
import 'package:galerisinden/domain/usecases/risk_engine.dart';
import 'package:galerisinden/data/models/expertise_model.dart';

void main() {
  group('Galerisinden Tycoon Engine Tests', () {
    test('Market Engine generates offline listings with realistic Turkish prices', () {
      final listings = MarketEngine.generateRandomListings(count: 5, playerLevel: 1);
      expect(listings.length, equals(5));
      expect(listings.first.car.brand.isNotEmpty, isTrue);
      expect(listings.first.askingPrice, greaterThanOrEqualTo(250000));
    });

    test('Expertise Engine evaluates vehicle damage correctly', () {
      final listings = MarketEngine.generateRandomListings(count: 1, playerLevel: 1);
      final car = listings.first.car;
      final eval = ExpertiseEngine.evaluateVehicle(car);

      expect(eval.containsKey('overallGrade'), isTrue);
      expect(eval['damagePercentage'], greaterThanOrEqualTo(0));
    });

    test('Repair Engine restores body part to original with Master Tier', () {
      final listings = MarketEngine.generateRandomListings(count: 1, playerLevel: 1);
      final car = listings.first.car;

      // Find a part that is not original, or force one to painted
      final targetPart = car.expertise.bodyParts.keys.firstWhere(
        (k) => car.expertise.bodyParts[k] != PartStatus.original,
        orElse: () => 'Kaput',
      );

      final damagedCar = car.copyWith(
        expertise: ExpertiseReport(
          engineCondition: car.expertise.engineCondition,
          transmissionCondition: car.expertise.transmissionCondition,
          tramerAmount: car.expertise.tramerAmount,
          mileage: car.expertise.mileage,
          isMileageTampered: car.expertise.isMileageTampered,
          bodyParts: {...car.expertise.bodyParts, targetPart: PartStatus.painted},
        ),
      );

      final result = RepairEngine.repairBodyPart(damagedCar, targetPart, RepairTier.master);
      expect(result.isSuccess, isTrue);
      expect(result.updatedCar.expertise.bodyParts[targetPart], equals(PartStatus.original));
    });

    test('Risk Engine evaluates uninspected purchases correctly', () {
      final listings = MarketEngine.generateRandomListings(count: 1, playerLevel: 1);
      final car = listings.first.car;

      // Run 20 evaluations to ensure risk engine produces valid outcomes
      for (int i = 0; i < 20; i++) {
        final outcome = RiskEngine.evaluateUninspectedPurchaseRisk(car);
        expect(outcome.title.isNotEmpty, isTrue);
        expect(outcome.description.isNotEmpty, isTrue);
      }
    });

    test('Repair Engine prevents repairing already original parts and 100% engines', () {
      final listings = MarketEngine.generateRandomListings(count: 1, playerLevel: 1);
      final car = listings.first.car;

      final damagedCar = car.copyWith(
        expertise: ExpertiseReport(
          engineCondition: 80.0,
          transmissionCondition: 80.0,
          tramerAmount: car.expertise.tramerAmount,
          mileage: car.expertise.mileage,
          isMileageTampered: car.expertise.isMileageTampered,
          bodyParts: {...car.expertise.bodyParts, 'Kaput': PartStatus.painted},
        ),
      );

      // 1. Repair part to original first
      final res1 = RepairEngine.repairBodyPart(damagedCar, 'Kaput', RepairTier.master);
      expect(res1.isSuccess, isTrue);

      // 2. Try to repair already original part
      final res2 = RepairEngine.repairBodyPart(res1.updatedCar, 'Kaput', RepairTier.master);
      expect(res2.isSuccess, isFalse);
      expect(res2.costPaid, equals(0.0));

      // 3. Repair engine to 100%
      final engRes1 = RepairEngine.repairEngine(damagedCar, RepairTier.master);
      expect(engRes1.isSuccess, isTrue);

      // 4. Try to repair already 100% engine
      final engRes2 = RepairEngine.repairEngine(engRes1.updatedCar, RepairTier.master);
      expect(engRes2.isSuccess, isFalse);
      expect(engRes2.costPaid, equals(0.0));
    });

    test('NegotiationEngine detects expertise discrepancy correctly', () {
      final listings = MarketEngine.generateRandomListings(count: 1, playerLevel: 1);
      final car = listings.first.car;

      final tamperedCar = car.copyWith(
        expertise: ExpertiseReport(
          engineCondition: car.expertise.engineCondition,
          transmissionCondition: car.expertise.transmissionCondition,
          tramerAmount: car.expertise.tramerAmount,
          mileage: car.expertise.mileage,
          isMileageTampered: true,
          bodyParts: car.expertise.bodyParts,
        ),
      );

      final disc = NegotiationEngine.detectExpertiseDiscrepancy(tamperedCar);
      expect(disc.hasDiscrepancy, isTrue);
      expect(disc.extraDiscountPercent, equals(0.25));
    });
  });
}
