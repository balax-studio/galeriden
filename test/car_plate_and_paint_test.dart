import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/domain/usecases/market_engine.dart';

void main() {
  group('Dynamic License Plate & Automotive Paint Generation Tests', () {
    test('generateLicensePlate produces diverse city codes and realistic formats', () {
      final plates = <String>{};
      final rarities = <String>{};

      for (int i = 0; i < 100; i++) {
        final plate = MarketEngine.generateLicensePlate();
        expect(plate.number.isNotEmpty, isTrue);
        expect(plate.number.contains(' '), isTrue);
        plates.add(plate.number);
        rarities.add(plate.rarity);
      }

      // Should generate at least 50 distinct plate numbers out of 100
      expect(plates.length, greaterThan(50));
      // Should include standard and may include special/repeated/legendary
      expect(rarities.contains('standard'), isTrue);
    });

    test('generateLicensePlate respects city parameter', () {
      final ankaraPlate = MarketEngine.generateLicensePlate(city: 'Ankara');
      expect(ankaraPlate.number.startsWith('06'), isTrue);

      final istanbulPlate = MarketEngine.generateLicensePlate(city: 'İstanbul');
      expect(istanbulPlate.number.startsWith('34'), isTrue);

      final izmirPlate = MarketEngine.generateLicensePlate(city: 'İzmir');
      expect(izmirPlate.number.startsWith('35'), isTrue);
    });

    test('generateRandomListings produces varied plates and paint colors across cars', () {
      final listings = MarketEngine.generateRandomListings(count: 25);
      expect(listings.isNotEmpty, isTrue);

      final plateNumbers = listings.map((l) => l.car.plateNumber).toSet();
      final colorNames = listings.map((l) => l.car.colorDisplayName).toSet();

      // Ensure cars don't all have the same hardcoded plate and color
      expect(plateNumbers.length, greaterThan(15));
      expect(colorNames.length, greaterThan(5));
      expect(plateNumbers.contains('34 GAL 1923') && plateNumbers.length == 1, isFalse);
      expect(colorNames.contains('Standart Boya') && colorNames.length == 1, isFalse);
    });
  });
}
