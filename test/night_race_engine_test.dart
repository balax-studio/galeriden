import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/tuning_model.dart';
import 'package:galeriden/domain/usecases/negotiation_engine.dart';
import 'package:galeriden/domain/usecases/night_market_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Night Race Matchmaking & Fair Progression Engine Tests', () {
    final starterCar = CarModel(
      id: 'test_starter_car',
      brand: 'Tofaş',
      modelName: 'Hacı Murat 124 (Dede Mirası)',
      modelYear: 1976,
      bodyType: 'Sedan',
      colorHex: '#FFFFFF',
      baseMarketValue: 65000,
      currentPurchasePrice: 45000,
      isDetailedCleaned: false,
      isWashed: true,
      isPolished: false,
      isRare: false,
      expertise: ExpertiseReport(
        engineCondition: 40,
        transmissionCondition: 40,
        tramerAmount: 5000,
        mileage: 220000,
        isMileageTampered: false,
        bodyParts: {'Kaput': PartStatus.original},
      ),
      appliedDetailingOptionIds: [],
    );

    final tunedCar = CarModel(
      id: 'test_tuned_car',
      brand: 'BMW',
      modelName: '3.20d Stage 2 Canavarı',
      modelYear: 2012,
      bodyType: 'Sedan',
      colorHex: '#000000',
      baseMarketValue: 850000,
      currentPurchasePrice: 650000,
      isDetailedCleaned: true,
      isWashed: true,
      isPolished: true,
      isRare: false,
      expertise: ExpertiseReport(
        engineCondition: 95,
        transmissionCondition: 90,
        tramerAmount: 0,
        mileage: 120000,
        isMileageTampered: false,
        bodyParts: {'Kaput': PartStatus.original},
      ),
      appliedDetailingOptionIds: [
        'tune_ecu_stg2',
        'tune_exhaust',
        'tune_bodykit',
        'tune_air_suspension',
        'detail_ceramic_coating',
      ],
      isDoped: true,
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

    test('3. calculatePlayerPower correctly factors in mechanics, tuning, and condition', () {
      final starterPower = NightMarketEngine.calculatePlayerPower(starterCar);
      final tunedPower = NightMarketEngine.calculatePlayerPower(tunedCar);

      expect(starterPower, greaterThanOrEqualTo(50));
      expect(starterPower, lessThanOrEqualTo(100));
      expect(tunedPower, greaterThan(starterPower * 2));
      expect(tunedPower, greaterThanOrEqualTo(220));
    });

    test('4. Matched rival scales dynamically to player power and tuning level', () {
      final starterRival = NightMarketEngine.getMatchedRival(starterCar);
      final tunedRival = NightMarketEngine.getMatchedRival(tunedCar);
      final monsterRival = NightMarketEngine.getMatchedRival(monsterCar);

      expect(starterRival.tier, equals(1));
      expect(tunedRival.tier, greaterThanOrEqualTo(2));
      expect(monsterRival.tier, equals(3));
      expect(monsterRival.basePower, greaterThan(400));
    });

    test('5. estimateWinChance gives fair odds against matched rival', () {
      final starterRival = NightMarketEngine.getMatchedRival(starterCar);
      final starterWinChance = NightMarketEngine.estimateWinChance(starterCar, starterRival);
      expect(starterWinChance, inInclusiveRange(25, 65));

      final tunedRival = NightMarketEngine.getMatchedRival(tunedCar);
      final tunedWinChance = NightMarketEngine.estimateWinChance(tunedCar, tunedRival);
      expect(tunedWinChance, greaterThanOrEqualTo(45));
    });

    test('6. simulateNightRace generates dynamic logs and awards prize on win', () {
      final matchedRival = NightMarketEngine.getMatchedRival(starterCar);
      final result = NightMarketEngine.simulateNightRace(starterCar, rival: matchedRival);

      expect(result.rivalName, isNotEmpty);
      expect(result.rivalCarName, isNotEmpty);
      expect(result.raceSummary, isNotEmpty);

      if (result.isWon) {
        expect(result.prizeMoney, greaterThanOrEqualTo(20000));
        expect(result.reputationBonus, greaterThan(0));
      } else {
        expect(result.prizeMoney, equals(0.0));
      }
    });

    test('7. Rival reroll returns a valid alternative rival from matching pool', () {
      final rival1 = NightMarketEngine.getMatchedRival(starterCar);
      final rival2 = NightMarketEngine.getRandomRivalForTier(rival1.tier, excludeId: rival1.id);

      expect(rival2.id, isNot(equals(rival1.id)));
      expect(rival2.tier, equals(rival1.tier));
    });
  });

  group('VIP Tuning Studio Options & Presets Tests', () {
    test('1. VIP performance options exist in catalog with correct categories', () {
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

    test('2. Presets Drag Spec and Time Attack calculate discounts correctly', () {
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

      expect(
        TuningCatalog.isOverTuned([
          'tune_straight_pipe_flame',
          'tune_air_suspension',
          'tune_meth_injection',
        ]),
        isTrue,
      );

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
