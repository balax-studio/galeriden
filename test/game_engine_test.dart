import 'package:flutter_test/flutter_test.dart';
import 'package:galerisinden/domain/usecases/market_engine.dart';
import 'package:galerisinden/domain/usecases/expertise_engine.dart';
import 'package:galerisinden/domain/usecases/repair_engine.dart';
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

      final result = RepairEngine.repairBodyPart(car, 'Kaput', RepairTier.master);
      expect(result.isSuccess, isTrue);
      expect(result.updatedCar.expertise.bodyParts['Kaput'], equals(PartStatus.original));
    });
  });
}
