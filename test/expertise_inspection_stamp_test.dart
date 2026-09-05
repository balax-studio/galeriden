import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/domain/usecases/expertise_engine.dart';

void main() {
  group('Expertise Inspection Stamp Dynamic Evaluation Tests', () {
    CarModel createTestCar({
      Map<String, PartStatus>? bodyParts,
      int tramer = 0,
      bool isTampered = false,
      double engine = 90.0,
      double transmission = 90.0,
    }) {
      final parts = bodyParts ?? {
        'Kaput': PartStatus.original,
        'Tavan': PartStatus.original,
        'Sol Ön Çamurluk': PartStatus.original,
        'Sağ Ön Çamurluk': PartStatus.original,
        'Sol Arka Çamurluk': PartStatus.original,
        'Sağ Arka Çamurluk': PartStatus.original,
        'Sol Ön Kapı': PartStatus.original,
        'Sağ Ön Kapı': PartStatus.original,
        'Sol Arka Kapı': PartStatus.original,
        'Sağ Arka Kapı': PartStatus.original,
        'Bagaj': PartStatus.original,
        'Şasi/Podye': PartStatus.original,
      };

      final exp = ExpertiseReport(
        bodyParts: parts,
        engineCondition: engine,
        transmissionCondition: transmission,
        mileage: 120000,
        tramerAmount: tramer,
        isMileageTampered: isTampered,
      );

      return CarModel(
        id: 'test_car_1',
        brand: 'Renault',
        modelName: 'Clio',
        modelYear: 2020,
        bodyType: 'Hatchback',
        colorHex: '0xFFFFFFFF',
        baseMarketValue: 600000,
        currentPurchasePrice: 550000,
        expertise: exp,
      );
    }

    test('100% original car evaluates to HATASIZ BOYASIZ (Green)', () {
      final car = createTestCar();
      final eval = ExpertiseEngine.evaluateVehicle(car);
      final stamp = ExpertiseEngine.getInspectionStamp(car: car, exp: car.expertise, eval: eval);

      expect(stamp.text, equals('HATASIZ BOYASIZ'));
      expect(Color(stamp.colorValue), equals(const Color(0xFF00E575)));
    });

    test('Car with painted parts evaluates to PARÇA BOYALI (Sky Blue)', () {
      final car = createTestCar(bodyParts: {
        'Kaput': PartStatus.original,
        'Tavan': PartStatus.original,
        'Sol Ön Çamurluk': PartStatus.painted,
        'Sağ Ön Çamurluk': PartStatus.painted,
        'Sol Arka Çamurluk': PartStatus.original,
        'Sağ Arka Çamurluk': PartStatus.original,
        'Sol Ön Kapı': PartStatus.original,
        'Sağ Ön Kapı': PartStatus.original,
        'Sol Arka Kapı': PartStatus.original,
        'Sağ Arka Kapı': PartStatus.original,
        'Bagaj': PartStatus.original,
        'Şasi/Podye': PartStatus.original,
      });

      final eval = ExpertiseEngine.evaluateVehicle(car);
      final stamp = ExpertiseEngine.getInspectionStamp(car: car, exp: car.expertise, eval: eval);

      expect(stamp.text, equals('2 PARÇA BOYALI'));
      expect(Color(stamp.colorValue), equals(const Color(0xFF38BDF8)));
    });

    test('Car with changed part evaluates to 1 PARÇA DEĞİŞEN (Amber)', () {
      final car = createTestCar(bodyParts: {
        'Kaput': PartStatus.changed,
        'Tavan': PartStatus.original,
        'Sol Ön Çamurluk': PartStatus.original,
        'Sağ Ön Çamurluk': PartStatus.original,
        'Sol Arka Çamurluk': PartStatus.original,
        'Sağ Arka Çamurluk': PartStatus.original,
        'Sol Ön Kapı': PartStatus.original,
        'Sağ Ön Kapı': PartStatus.original,
        'Sol Arka Kapı': PartStatus.original,
        'Sağ Arka Kapı': PartStatus.original,
        'Bagaj': PartStatus.original,
        'Şasi/Podye': PartStatus.original,
      });

      final eval = ExpertiseEngine.evaluateVehicle(car);
      final stamp = ExpertiseEngine.getInspectionStamp(car: car, exp: car.expertise, eval: eval);

      expect(stamp.text, equals('1 PARÇA DEĞİŞEN'));
      expect(Color(stamp.colorValue), equals(const Color(0xFFF59E0B)));
    });

    test('Car with both changed and painted parts evaluates to DEĞİŞEN & BOYA (Amber)', () {
      final car = createTestCar(bodyParts: {
        'Kaput': PartStatus.changed,
        'Tavan': PartStatus.original,
        'Sol Ön Çamurluk': PartStatus.painted,
        'Sağ Ön Çamurluk': PartStatus.original,
        'Sol Arka Çamurluk': PartStatus.original,
        'Sağ Arka Çamurluk': PartStatus.original,
        'Sol Ön Kapı': PartStatus.original,
        'Sağ Ön Kapı': PartStatus.original,
        'Sol Arka Kapı': PartStatus.original,
        'Sağ Arka Kapı': PartStatus.original,
        'Bagaj': PartStatus.original,
        'Şasi/Podye': PartStatus.original,
      });

      final eval = ExpertiseEngine.evaluateVehicle(car);
      final stamp = ExpertiseEngine.getInspectionStamp(car: car, exp: car.expertise, eval: eval);

      expect(stamp.text, equals('DEĞİŞEN & BOYA'));
      expect(Color(stamp.colorValue), equals(const Color(0xFFF59E0B)));
    });

    test('Severe damage (high tramer, tampered mileage, or D grade) evaluates to AĞIR HASARLI (Red)', () {
      final carHighTramer = createTestCar(tramer: 150000);
      final evalHighTramer = ExpertiseEngine.evaluateVehicle(carHighTramer);
      final stampHighTramer = ExpertiseEngine.getInspectionStamp(
        car: carHighTramer,
        exp: carHighTramer.expertise,
        eval: evalHighTramer,
      );
      expect(stampHighTramer.text, equals('AĞIR HASARLI'));
      expect(Color(stampHighTramer.colorValue), equals(const Color(0xFFEF4444)));

      final carTampered = createTestCar(isTampered: true);
      final evalTampered = ExpertiseEngine.evaluateVehicle(carTampered);
      final stampTampered = ExpertiseEngine.getInspectionStamp(
        car: carTampered,
        exp: carTampered.expertise,
        eval: evalTampered,
      );
      expect(stampTampered.text, equals('AĞIR HASARLI'));
      expect(Color(stampTampered.colorValue), equals(const Color(0xFFEF4444)));

      final carMultipleDamaged = createTestCar(bodyParts: {
        'Kaput': PartStatus.original,
        'Tavan': PartStatus.original,
        'Sol Ön Çamurluk': PartStatus.original,
        'Sağ Ön Çamurluk': PartStatus.original,
        'Sol Arka Çamurluk': PartStatus.original,
        'Sağ Arka Çamurluk': PartStatus.changed,
        'Sol Ön Kapı': PartStatus.original,
        'Sağ Ön Kapı': PartStatus.original,
        'Sol Arka Kapı': PartStatus.damaged,
        'Sağ Arka Kapı': PartStatus.damaged,
        'Bagaj': PartStatus.damaged,
        'Şasi/Podye': PartStatus.original,
      });
      final evalMultipleDamaged = ExpertiseEngine.evaluateVehicle(carMultipleDamaged);
      final stampMultipleDamaged = ExpertiseEngine.getInspectionStamp(
        car: carMultipleDamaged,
        exp: carMultipleDamaged.expertise,
        eval: evalMultipleDamaged,
      );
      expect(stampMultipleDamaged.text, equals('AĞIR HASARLI'));
      expect(Color(stampMultipleDamaged.colorValue), equals(const Color(0xFFEF4444)));
    });
  });
}
