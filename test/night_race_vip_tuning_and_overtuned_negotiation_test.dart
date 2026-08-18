import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/tuning_model.dart';
import 'package:galeriden/domain/usecases/negotiation_engine.dart';
import 'package:galeriden/domain/usecases/night_market_engine.dart';

void main() {
  group('Night Race Expanded Roster & Taunts Tests', () {
    test('1. Rival pool contains 18 authentic street rivals (6 per tier)', () {
      final allRivals = NightMarketEngine.allRivals;
      expect(allRivals.length, equals(18));

      final tier1 = allRivals.where((r) => r.tier == 1).toList();
      final tier2 = allRivals.where((r) => r.tier == 2).toList();
      final tier3 = allRivals.where((r) => r.tier == 3).toList();

      expect(tier1.length, equals(6));
      expect(tier2.length, equals(6));
      expect(tier3.length, equals(6));
    });

    test('2. Defeat trash-talk taunts generate non-empty strings without parentheses', () {
      for (final rival in NightMarketEngine.allRivals) {
        final taunt = NightMarketEngine.getRandomDefeatTaunt(rival);
        expect(taunt.isNotEmpty, isTrue);
        expect(taunt.contains('('), isFalse);
        expect(taunt.contains(')'), isFalse);
      }
    });

    test('3. Matched rival scales dynamically to player power and tuning level', () {
      final stockCar = CarModel(
        id: 'car_stock',
        brand: 'Tofaş',
        modelName: 'Şahin 1.6 S',
        modelYear: 1995,
        bodyType: 'Sedan',
        colorHex: '#FFFFFF',
        baseMarketValue: 100000,
        currentPurchasePrice: 80000,
        expertise: ExpertiseReport(
          engineCondition: 60,
          transmissionCondition: 60,
          tramerAmount: 0,
          mileage: 180000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );

      final monsterCar = CarModel(
        id: 'car_monster',
        brand: 'Porş',
        modelName: '9-1-2 Kurbağa Turbo',
        modelYear: 2022,
        bodyType: 'Spor',
        colorHex: '#000000',
        baseMarketValue: 8500000,
        currentPurchasePrice: 8000000,
        expertise: ExpertiseReport(
          engineCondition: 100,
          transmissionCondition: 100,
          tramerAmount: 0,
          mileage: 10000,
          isMileageTampered: false,
          bodyParts: {},
        ),
        appliedDetailingOptionIds: [
          'tune_ecu_stg3_plus',
          'tune_meth_injection',
          'tune_straight_pipe_flame',
          'tune_carbon_hood_trunk',
          'tune_custom_forged_slick',
        ],
      );

      final stockRival = NightMarketEngine.getMatchedRival(stockCar);
      final monsterRival = NightMarketEngine.getMatchedRival(monsterCar);

      expect(stockRival.tier, equals(1));
      expect(monsterRival.tier, equals(3));
      expect(monsterRival.basePower, greaterThan(400));
    });
  });

  group('VIP Tuning Studio Options & Presets Tests', () {
    test('1. New VIP performance options exist in catalog with correct categories', () {
      final stg3 = TuningCatalog.allOptions.firstWhere((o) => o.id == 'tune_ecu_stg3_plus');
      final meth = TuningCatalog.allOptions.firstWhere((o) => o.id == 'tune_meth_injection');
      final intake = TuningCatalog.allOptions.firstWhere((o) => o.id == 'tune_titanium_intake');
      final carbon = TuningCatalog.allOptions.firstWhere((o) => o.id == 'tune_carbon_hood_trunk');
      final slicks = TuningCatalog.allOptions.firstWhere((o) => o.id == 'tune_custom_forged_slick');
      final rollcage = TuningCatalog.allOptions.firstWhere((o) => o.id == 'tune_rollcage_racing');

      expect(stg3.hpGain, greaterThanOrEqualTo(85));
      expect(stg3.category, equals(TuningCategory.powertrain));

      expect(meth.hpGain, greaterThanOrEqualTo(45));

      expect(intake.category, equals(TuningCategory.powertrain));

      expect(carbon.category, equals(TuningCategory.aero));

      expect(slicks.category, equals(TuningCategory.stance));

      expect(rollcage.category, equals(TuningCategory.stance));
    });

    test('2. New presets Drag Spec and Time Attack are registered and calculate discounts', () {
      final dragPreset = TuningPresetBuilds.allPresets.firstWhere((p) => p.id == 'preset_drag_spec');
      final timeAttackPreset = TuningPresetBuilds.allPresets.firstWhere((p) => p.id == 'preset_time_attack');

      expect(dragPreset.optionIds.contains('tune_ecu_stg3_plus'), isTrue);
      expect(dragPreset.optionIds.contains('tune_meth_injection'), isTrue);
      expect(dragPreset.discountPercent, equals(0.18));

      expect(timeAttackPreset.optionIds.contains('tune_carbon_hood_trunk'), isTrue);
      expect(timeAttackPreset.optionIds.contains('tune_rollcage_racing'), isTrue);
      expect(timeAttackPreset.discountPercent, equals(0.18));
    });

    test('3. Over-tuned threshold accurately flags 3+ aggressive or 5+ total mods', () {
      expect(TuningCatalog.isOverTuned([]), isFalse);
      expect(TuningCatalog.isOverTuned(['tune_tinted_windows', 'tune_air_intake_sport']), isFalse);

      // 3 Aggressive mods
      expect(
        TuningCatalog.isOverTuned([
          'tune_straight_pipe_flame',
          'tune_air_suspension',
          'tune_meth_injection',
        ]),
        isTrue,
      );

      // 5 Total mods
      expect(
        TuningCatalog.isOverTuned([
          'tune_tinted_windows',
          'tune_air_intake_sport',
          'tune_ecu_stg1',
          'tune_sport_springs',
          'tune_lip_spoiler',
        ]),
        isTrue,
      );
    });
  });

  group('Over-Tuned Vehicle Negotiation & Buyer Archetype Shift Tests', () {
    final regularCar = CarModel(
      id: 'car_regular',
      brand: 'Toyota',
      modelName: 'Corolla 1.6 Vision',
      modelYear: 2020,
      bodyType: 'Sedan',
      colorHex: '#FFFFFF',
      baseMarketValue: 700000,
      currentPurchasePrice: 650000,
      customListingPrice: 720000,
      appliedDetailingOptionIds: ['tune_tinted_windows'],
      expertise: ExpertiseReport(
        engineCondition: 90,
        transmissionCondition: 90,
        tramerAmount: 0,
        mileage: 60000,
        isMileageTampered: false,
        bodyParts: {},
      ),
    );

    final overTunedCar = CarModel(
      id: 'car_overtuned',
      brand: 'Honda',
      modelName: 'Civic 1.5 VTEC Turbo',
      modelYear: 2018,
      bodyType: 'Sedan',
      colorHex: '#FF0000',
      baseMarketValue: 850000,
      currentPurchasePrice: 800000,
      customListingPrice: 950000,
      appliedDetailingOptionIds: [
        'tune_ecu_stg3_plus',
        'tune_straight_pipe_flame',
        'tune_air_suspension',
        'tune_carbon_hood_trunk',
        'tune_meth_injection',
      ],
      expertise: ExpertiseReport(
        engineCondition: 95,
        transmissionCondition: 95,
        tramerAmount: 0,
        mileage: 45000,
        isMileageTampered: false,
        bodyParts: {},
      ),
    );

    test('1. isOverTuned getter on CarModel is true for over-tuned car and false for regular car', () {
      expect(regularCar.isOverTuned, isFalse);
      expect(overTunedCar.isOverTuned, isTrue);
    });

    test('2. Over-tuned vehicle generates buyer offers with youthful enthusiast flavor', () {
      int youthCount = 0;
      for (int i = 0; i < 50; i++) {
        final offer = NegotiationEngine.generateBuyerOffer(overTunedCar, overTunedCar.listingPrice);
        if (offer.buyerMessage.contains('Reis') ||
            offer.buyerMessage.contains('makine') ||
            offer.buyerMessage.contains('popcorn') ||
            offer.buyerMessage.contains('caddeleri') ||
            offer.buyerMessage.contains('Jantlar') ||
            offer.buyerMessage.contains('basıklık')) {
          youthCount++;
        }
      }
      expect(youthCount, greaterThanOrEqualTo(20));
    });

    test('3. Zero parentheses in all generated over-tuned dialogue strings', () {
      for (int i = 0; i < 30; i++) {
        final offer = NegotiationEngine.generateBuyerOffer(overTunedCar, overTunedCar.listingPrice);
        expect(offer.buyerMessage.contains('('), isFalse);
        expect(offer.buyerMessage.contains(')'), isFalse);
      }
    });
  });
}
