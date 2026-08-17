import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/tuning_model.dart';

void main() {
  group('VIP Tuning Studio & Dyno Performance Test Suite', () {
    late CarModel baseCar;

    setUp(() {
      baseCar = CarModel(
        id: 'car_bmw_m3',
        brand: 'BMW',
        modelName: 'M3 Competition',
        modelYear: 2021,
        bodyType: 'Sedan',
        colorHex: '#003366',
        baseMarketValue: 1000000,
        currentPurchasePrice: 900000,
        appliedDetailingOptionIds: [],
        expertise: ExpertiseReport(
          engineCondition: 100,
          transmissionCondition: 100,
          tramerAmount: 0,
          mileage: 15000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );
    });

    test('1. Default Dyno stats calculate factory baseline accurately', () {
      final dyno = CarDynoCalculator.calculateDyno(baseCar);

      expect(dyno.totalHp, greaterThanOrEqualTo(150));
      expect(dyno.totalNm, greaterThanOrEqualTo(200));
      expect(dyno.exhaustDb, equals(78)); // Factory quiet
      expect(dyno.tuningRating, equals(0));
      expect(dyno.isInspectionCompliant, isTrue);
      expect(dyno.hasLegalProject, isFalse);
    });

    test('2. Applying Powertrain and Exhaust tuning boosts HP, Nm, dB and tuning rating', () {
      final modifiedCar = baseCar.copyWith(
        appliedDetailingOptionIds: ['tune_ecu_stg2', 'tune_varex_exhaust'],
      );

      final dyno = CarDynoCalculator.calculateDyno(modifiedCar);

      expect(dyno.totalHp, greaterThan(dyno.baseHp));
      expect(dyno.totalNm, greaterThan(dyno.baseNm));
      expect(dyno.exhaustDb, greaterThan(78)); // Louder
      expect(dyno.currentAccel, lessThan(dyno.baseAccel)); // Faster 0-100
      expect(dyno.tuningRating, greaterThan(20));
    });

    test('3. Extreme modifications flag inspection non-compliance until legal project is approved', () {
      final loudCar = baseCar.copyWith(
        appliedDetailingOptionIds: ['tune_straight_pipe_flame', 'tune_air_suspension'],
      );

      final dynoNonLegal = CarDynoCalculator.calculateDyno(loudCar);
      expect(dynoNonLegal.isInspectionCompliant, isFalse);

      final certifiedCar = loudCar.copyWith(
        appliedDetailingOptionIds: [...loudCar.appliedDetailingOptionIds, 'tune_legal_project_cert'],
      );

      final dynoLegal = CarDynoCalculator.calculateDyno(certifiedCar);
      expect(dynoLegal.hasLegalProject, isTrue);
      expect(dynoLegal.isInspectionCompliant, isTrue);
    });

    test('4. Preset concept builds calculate total discounted cost and option coverage', () {
      final preset = TuningPresetBuilds.allPresets.firstWhere((p) => p.id == 'preset_street_racer');

      expect(preset.optionIds.length, greaterThanOrEqualTo(3));
      expect(preset.discountPercent, equals(0.15)); // %15 discount

      final fullPrice = TuningCatalog.calculateRawCost(preset.optionIds);
      final discountedPrice = preset.getDiscountedCost();

      expect(discountedPrice, equals(fullPrice * 0.85));
    });

    test('5. 4 Thematic categories have dedicated options and icons', () {
      final powertrain = TuningCatalog.getOptionsByCategory(TuningCategory.powertrain);
      final aero = TuningCatalog.getOptionsByCategory(TuningCategory.aero);
      final stance = TuningCatalog.getOptionsByCategory(TuningCategory.stance);
      final exhaust = TuningCatalog.getOptionsByCategory(TuningCategory.exhaust);

      expect(powertrain.length, greaterThanOrEqualTo(3));
      expect(aero.length, greaterThanOrEqualTo(3));
      expect(stance.length, greaterThanOrEqualTo(3));
      expect(exhaust.length, greaterThanOrEqualTo(3));
    });
  });
}
