import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/mega_systems_extensions_model.dart';
import 'package:galeriden/domain/usecases/negotiation_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  CarModel createCleanCar({double baseMarketValue = 1000000.0}) {
    return CarModel(
      id: 'test_car_audit_1',
      brand: 'Volkswagen',
      modelName: 'Passat 2.0 TDI',
      modelYear: 2018,
      bodyType: 'Sedan',
      colorHex: '#FFFFFF',
      colorDisplayName: 'Beyaz',
      colorRarity: 'common',
      plateNumber: '34 GTC 192',
      plateRarity: 'common',
      baseMarketValue: baseMarketValue,
      currentPurchasePrice: 600000.0,
      isRare: false,
      isBarnFind: false,
      declarationType: ListingDeclarationType.honest,
      expertise: ExpertiseReport(
        engineCondition: 100.0,
        transmissionCondition: 100.0,
        tramerAmount: 0,
        mileage: 85000,
        isMileageTampered: false,
        bodyParts: {
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
        },
      ),
    );
  }

  group('Vehicle Valuation & Upgrades Economy Audit Tests', () {
    test('Clean pristine car base factor equals 1.00 of baseMarketValue', () {
      final car = createCleanCar(baseMarketValue: 1000000.0);
      expect(car.estimatedRealValue, equals(1000000.0));
    });

    test('Washing and Detailing provide realistic +4% to +8% condition increase', () {
      final car = createCleanCar(baseMarketValue: 1000000.0);

      final washedCar = car.copyWith(isWashed: true);
      expect(washedCar.estimatedRealValue, equals(1040000.0)); // +4%

      final detailedCar = car.copyWith(isDetailedCleaned: true);
      expect(detailedCar.estimatedRealValue, equals(1080000.0)); // +8%
    });

    test('Detailing add-ons exhibit diminishing returns and cap at +10%', () {
      final car = createCleanCar(baseMarketValue: 1000000.0);

      // Adding 8 cosmetic detailing items
      final fullyDetailedCar = car.copyWith(
        appliedDetailingOptionIds: [
          'headlight_restoration',
          'iron_decon',
          'pdr_repaired',
          'tuvturk_certified',
          'dyno_certified',
          'ozone_sanitized',
          'interior_detailing',
          'paint_polish',
        ],
      );

      // Total detailing bonus is capped at +10% (1.100.000 TL), not +48% (1.480.000 TL)
      expect(fullyDetailedCar.estimatedRealValue, equals(1100000.0));
    });

    test('Performance tuning add-ons exhibit diminishing returns and cap at +25%', () {
      final car = createCleanCar(baseMarketValue: 1000000.0);

      // Adding 8 tuning items
      final fullyTunedCar = car.copyWith(
        appliedDetailingOptionIds: [
          'tune_ecu_stg1',
          'tune_ecu_stg2',
          'tune_turbo_stg3',
          'tune_bodykit_carbon',
          'tune_widebody',
          'tune_matrix_lights',
          'tune_coilover',
          'tune_air_suspension',
        ],
      );

      // Total tuning bonus is capped at +25% (1.250.000 TL), not unbounded +150%
      expect(fullyTunedCar.estimatedRealValue, equals(1250000.0));
    });

    test('Combined all-upgrades (Detailing + Tuning + Cleaning) remain balanced under 1.45x', () {
      final car = createCleanCar(baseMarketValue: 1000000.0);

      final maxedCar = car.copyWith(
        isDetailedCleaned: true,
        appliedDetailingOptionIds: [
          'headlight_restoration',
          'iron_decon',
          'pdr_repaired',
          'tuvturk_certified',
          'dyno_certified',
          'ozone_sanitized',
          'tune_ecu_stg1',
          'tune_turbo_stg3',
          'tune_bodykit_carbon',
          'tune_coilover',
        ],
      );

      // 1.00 base + 0.08 cleaning + 0.09 detailing + 0.16 tuning = 1.33x (1.330.000 TL)
      // Car does NOT explode into 2.800.000 TL+
      expect(maxedCar.estimatedRealValue, lessThan(1450000.0));
      expect(maxedCar.estimatedRealValue, greaterThan(1300000.0));
    });

    test('Dyno and Chip Tuning do NOT mutate baseMarketValue in GameCoreNotifier', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      final car = createCleanCar(baseMarketValue: 1000000.0);

      notifier.state = notifier.state.copyWith(
        balance: 500000.0,
        ownedCars: [car],
      );

      // 1. Apply Chip Tuning
      notifier.applyChipTuning(car.id, ChipTuningStage.stage1);
      final tunedCar = notifier.state.ownedCars.firstWhere((c) => c.id == car.id);
      expect(tunedCar.baseMarketValue, equals(1000000.0)); // Immutable!
      expect(tunedCar.appliedDetailingOptionIds.contains(ChipTuningStage.stage1.id), isTrue);

      // 2. Apply Dyno Test
      notifier.performDynoHpTest(car.id, ExpertisePackageTier.vipFull);
      final dynoCar = notifier.state.ownedCars.firstWhere((c) => c.id == car.id);
      expect(dynoCar.baseMarketValue, equals(1000000.0)); // Immutable!
      expect(dynoCar.appliedDetailingOptionIds.contains('dyno_certified'), isTrue);

      // 3. Apply Ozone Sanitization
      notifier.applyOzoneSanitization(car.id);
      final ozoneCar = notifier.state.ownedCars.firstWhere((c) => c.id == car.id);
      expect(ozoneCar.baseMarketValue, equals(1000000.0)); // Immutable!
      expect(ozoneCar.appliedDetailingOptionIds.contains('ozone_sanitized'), isTrue);
    });

    test('Overpriced showroom listing is anchored by buyers and prevents exploit', () {
      final car = createCleanCar(baseMarketValue: 1000000.0);
      final overpricedCar = car.copyWith(customListingPrice: 3000000.0); // +200% overpriced

      // Generate 20 buyer offers
      for (int i = 0; i < 20; i++) {
        final offer = NegotiationEngine.generateBuyerOffer(overpricedCar, overpricedCar.listingPrice);
        // Offers must NOT blindly match 3.000.000 TL; they must be anchored near fair market value
        expect(offer.offeredAmount, lessThan(1250000.0));
      }
    });
  });
}
