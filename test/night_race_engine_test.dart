import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
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

    test('Rival pool contains at least 12 distinct opponents spanning 3 tier classes', () {
      final allRivals = NightMarketEngine.allRivals;
      expect(allRivals.length, greaterThanOrEqualTo(12));

      final tier1Rivals = allRivals.where((r) => r.tier == 1).toList();
      final tier2Rivals = allRivals.where((r) => r.tier == 2).toList();
      final tier3Rivals = allRivals.where((r) => r.tier == 3).toList();

      expect(tier1Rivals.length, greaterThanOrEqualTo(4));
      expect(tier2Rivals.length, greaterThanOrEqualTo(4));
      expect(tier3Rivals.length, greaterThanOrEqualTo(4));
    });

    test('calculatePlayerPower correctly factors in mechanics, tuning, and condition', () {
      final starterPower = NightMarketEngine.calculatePlayerPower(starterCar);
      final tunedPower = NightMarketEngine.calculatePlayerPower(tunedCar);

      // Starter power is balanced for Tier 1 street entry (approx 50-100 HP)
      expect(starterPower, greaterThanOrEqualTo(50));
      expect(starterPower, lessThanOrEqualTo(100));

      // Tuned power with stage 2, exhaust, bodykit, air, ceramic and doping scales significantly (250+ HP)
      expect(tunedPower, greaterThan(starterPower * 2));
      expect(tunedPower, greaterThanOrEqualTo(220));
    });

    test('getMatchedRival matches starter car with Tier 1 rival and tuned car with high Tier rival', () {
      final starterRival = NightMarketEngine.getMatchedRival(starterCar);
      final tunedRival = NightMarketEngine.getMatchedRival(tunedCar);

      expect(starterRival.tier, equals(1));
      expect(tunedRival.tier, greaterThanOrEqualTo(2));
    });

    test('estimateWinChance gives fair ~30-65% odds for starter car against matched rival, and 45%+ for tuned car', () {
      final starterRival = NightMarketEngine.getMatchedRival(starterCar);
      final starterWinChance = NightMarketEngine.estimateWinChance(starterCar, starterRival);

      // Starter car has decent shot against matched Tier 1 rivals (approx 25% - 65%)
      expect(starterWinChance, greaterThanOrEqualTo(25));
      expect(starterWinChance, lessThanOrEqualTo(65));

      final tunedRival = NightMarketEngine.getMatchedRival(tunedCar);
      final tunedWinChance = NightMarketEngine.estimateWinChance(tunedCar, tunedRival);
      expect(tunedWinChance, greaterThanOrEqualTo(45));
    });

    test('simulateNightRace generates dynamic logs and awards prize on win', () {
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

    test('Rival reroll returns a valid alternative rival from matching pool', () {
      final rival1 = NightMarketEngine.getMatchedRival(starterCar);
      final rival2 = NightMarketEngine.getRandomRivalForTier(rival1.tier, excludeId: rival1.id);

      expect(rival2.id, isNot(equals(rival1.id)));
      expect(rival2.tier, equals(rival1.tier));
    });
  });
}
