import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/constants/car_specifications.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/mega_systems_extensions_model.dart';
import 'package:galeriden/data/models/tuning_model.dart';
import 'package:galeriden/domain/usecases/market_engine.dart';
import 'package:galeriden/domain/usecases/negotiation_engine.dart';
import 'package:galeriden/domain/usecases/night_market_engine.dart';

void main() {
  group('CarSpecifications & Factory HP Catalog Tests', () {
    test('Authentic factory horsepower mapping for common and exotic models', () {
      // Tofaşk
      expect(CarSpecifications.getFactoryHorsepower('Tofaşk', 'Şahin-S Yanlama'), 80);
      expect(CarSpecifications.getFactoryHorsepower('Tofaşk', 'Doğan Görünümlü SLX'), 86);
      expect(CarSpecifications.getFactoryHorsepower('Tofaşk', 'Hacı Murat 124 (Dede Mirası)'), 65);

      // Fiyasko & Reno
      expect(CarSpecifications.getFactoryHorsepower('Fiyasko', 'Ege-Paket 1.3 Multijet'), 95);
      expect(CarSpecifications.getFactoryHorsepower('Reno', 'Megan Dört Sedan'), 115);
      expect(CarSpecifications.getFactoryHorsepower('Reno', 'Toros Dağ Aslanı SW'), 72);

      // Vosgen & Hondam
      expect(CarSpecifications.getFactoryHorsepower('Vosgen', 'Pas-At 2.0 TDi Aşiret'), 150);
      expect(CarSpecifications.getFactoryHorsepower('Hondam', 'Civciv 1.5 VTEC'), 129);
      expect(CarSpecifications.getFactoryHorsepower('Hondam', 'Civciv Type-R Vututu'), 320);

      // Premium & Exotics
      expect(CarSpecifications.getFactoryHorsepower('Bemeve', '3.20d Yanlama E-90'), 177);
      expect(CarSpecifications.getFactoryHorsepower('Bemeve', 'M-Dört Pist Fırtınası'), 510);
      expect(CarSpecifications.getFactoryHorsepower('Porş', '9-1-2 Kurbağa Turbo'), 580);
      expect(CarSpecifications.getFactoryHorsepower('Ferro', 'SF-Doksan Hibrit'), 1000);
      expect(CarSpecifications.getFactoryHorsepower('Teslo', 'Model-S Pled Uzay Mekiği'), 1020);
    });

    test('CarModel factoryHorsepower and effectiveHorsepower calculations', () {
      final pristineCar = CarModel(
        id: 'c1',
        brand: 'Fiyasko',
        modelName: 'Ege-Paket 1.3 Multijet',
        modelYear: 2022,
        bodyType: 'Sedan',
        colorHex: '0xFFFFFFFF',
        baseMarketValue: 650000.0,
        currentPurchasePrice: 650000.0,
        expertise: ExpertiseReport(
          engineCondition: 100.0,
          transmissionCondition: 100.0,
          tramerAmount: 0,
          mileage: 25000,
          isMileageTampered: false,
          bodyParts: {
            'Kaput': PartStatus.original,
            'Tavan': PartStatus.original,
            'Bagaj': PartStatus.original,
          },
        ),
      );

      expect(pristineCar.factoryHorsepower, 95);
      expect(pristineCar.effectiveHorsepower, 95);

      // With stage 1 ECU tuning (+35 HP)
      final tunedCar = pristineCar.copyWith(
        appliedDetailingOptionIds: ['tune_ecu_stg1'],
      );
      expect(tunedCar.effectiveHorsepower, 95 + 35);
    });
  });

  group('Pristine Vehicles & Seller Honesty Distribution in MarketEngine', () {
    test('Pristine vehicles (Hatasız & Boyasız) generated with at least 20% frequency across large sample', () {
      final listings = MarketEngine.generateRandomListings(count: 200, playerLevel: 3);

      final pristineCount = listings.where((l) => l.car.isPristineOriginal).length;
      final pristineRatio = pristineCount / listings.length;

      // Expect around 25-30% pristine vehicles
      expect(pristineRatio, greaterThanOrEqualTo(0.18));
      expect(pristineCount, greaterThan(30));

      // Validate all pristine cars have 0 tramer and all original parts
      final pristineListings = listings.where((l) => l.car.isPristineOriginal);
      for (final l in pristineListings) {
        expect(l.car.expertise.tramerAmount, 0);
        expect(l.car.expertise.isMileageTampered, false);
        expect(l.car.expertise.engineCondition, greaterThanOrEqualTo(80.0));
        for (final status in l.car.expertise.bodyParts.values) {
          expect(status, PartStatus.original);
        }
      }
    });

    test('Seller honesty distribution has substantial honest sellers (~40%)', () {
      final listings = MarketEngine.generateRandomListings(count: 250, playerLevel: 3);

      final honestCount = listings.where((l) => l.car.declarationType == ListingDeclarationType.honest).length;
      final honestRatio = honestCount / listings.length;

      // Honest sellers should make up at least 35% of total generated listings
      expect(honestRatio, greaterThanOrEqualTo(0.35));

      // Honest listings should NOT produce discrepancy kozu
      final honestListings = listings.where((l) => l.car.declarationType == ListingDeclarationType.honest);
      for (final l in honestListings) {
        final disc = NegotiationEngine.detectExpertiseDiscrepancy(l.car);
        expect(disc.hasDiscrepancy, false);
        expect(disc.title.contains('DÜRÜST SATICI') || disc.title.contains('Çelişki Yok'), true);
      }
    });

    test('Deceptive listings produce appropriate leverage kozu', () {
      final deceptiveCar = CarModel(
        id: 'c_deceptive',
        brand: 'Bemeve',
        modelName: '3.20d Yanlama E-90',
        modelYear: 2011,
        bodyType: 'Sedan',
        colorHex: '0xFF000000',
        baseMarketValue: 700000.0,
        currentPurchasePrice: 700000.0,
        declarationType: ListingDeclarationType.flawlessClaim,
        expertise: ExpertiseReport(
          engineCondition: 85.0,
          transmissionCondition: 80.0,
          tramerAmount: 12000,
          mileage: 180000,
          isMileageTampered: false,
          bodyParts: {
            'Kaput': PartStatus.changed,
            'Tavan': PartStatus.original,
          },
        ),
      );

      final disc = NegotiationEngine.detectExpertiseDiscrepancy(deceptiveCar);
      expect(disc.hasDiscrepancy, true);
      expect(disc.extraDiscountPercent, 0.18);
      expect(disc.title, contains('GİZLİ DEĞİŞEN'));
    });
  });

  group('Dyno Test and Night Market Realism Tests', () {
    test('Dyno test report produces realistic factory HP and torque', () {
      final car = CarModel(
        id: 'c_passat',
        brand: 'Vosgen',
        modelName: 'Pas-At 2.0 TDi Aşiret',
        modelYear: 2019,
        bodyType: 'Sedan',
        colorHex: '0xFFFFFFFF',
        baseMarketValue: 1200000.0,
        currentPurchasePrice: 1200000.0,
        expertise: ExpertiseReport(
          engineCondition: 90.0,
          transmissionCondition: 90.0,
          tramerAmount: 0,
          mileage: 95000,
          isMileageTampered: false,
          bodyParts: {'Kaput': PartStatus.original},
        ),
      );

      final dyno = DynoTestReport.generate(car);
      expect(dyno.factoryHp, 150);
      expect(dyno.factoryTorque, 340);
      expect(dyno.measuredHp, greaterThanOrEqualTo(140));

      final studioDyno = CarDynoCalculator.calculateDyno(car);
      expect(studioDyno.baseHp, 150);
      expect(studioDyno.baseNm, 340);
    });

    test('Night market street power score matches vehicle horsepower realistically', () {
      final dogan = CarModel(
        id: 'c_dogan',
        brand: 'Tofaşk',
        modelName: 'Doğan Görünümlü SLX',
        modelYear: 1996,
        bodyType: 'Sedan',
        colorHex: '0xFFFFFFFF',
        baseMarketValue: 120000.0,
        currentPurchasePrice: 120000.0,
        expertise: ExpertiseReport(
          engineCondition: 85.0,
          transmissionCondition: 85.0,
          tramerAmount: 0,
          mileage: 180000,
          isMileageTampered: false,
          bodyParts: {'Kaput': PartStatus.original},
        ),
      );

      final doganPower = NightMarketEngine.calculatePlayerPower(dogan);
      expect(doganPower, greaterThanOrEqualTo(75));
      expect(doganPower, lessThanOrEqualTo(100));

      final porsche = CarModel(
        id: 'c_porche',
        brand: 'Porş',
        modelName: '9-1-2 Kurbağa Turbo',
        modelYear: 2021,
        bodyType: 'Spor',
        colorHex: '0xFFFFFF00',
        baseMarketValue: 8500000.0,
        currentPurchasePrice: 8500000.0,
        expertise: ExpertiseReport(
          engineCondition: 98.0,
          transmissionCondition: 98.0,
          tramerAmount: 0,
          mileage: 15000,
          isMileageTampered: false,
          bodyParts: {'Kaput': PartStatus.original},
        ),
      );

      final porschePower = NightMarketEngine.calculatePlayerPower(porsche);
      expect(porschePower, greaterThanOrEqualTo(550));
      expect(porschePower, lessThanOrEqualTo(650));
    });

    test('Night Market rivals have realistic street power scores across tiers', () {
      for (final rival in NightMarketEngine.allRivals) {
        if (rival.tier == 1) {
          expect(rival.basePower, greaterThanOrEqualTo(70));
          expect(rival.basePower, lessThanOrEqualTo(130));
        } else if (rival.tier == 2) {
          expect(rival.basePower, greaterThanOrEqualTo(180));
          expect(rival.basePower, lessThanOrEqualTo(320));
        } else if (rival.tier == 3) {
          expect(rival.basePower, greaterThanOrEqualTo(400));
          expect(rival.basePower, lessThanOrEqualTo(1000));
        }
      }
    });
  });
}
