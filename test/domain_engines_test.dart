import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/game_event_model.dart';
import 'package:galeriden/domain/usecases/black_market_engine.dart';
import 'package:galeriden/domain/usecases/district_economy_engine.dart';

void main() {
  group('DistrictEconomyEngine Domain Tests', () {
    test('calculateBoostCost scales progressively from 0.0 to 1.0', () {
      final cost0 = DistrictEconomyEngine.calculateBoostCost(0.0);
      final cost50 = DistrictEconomyEngine.calculateBoostCost(0.50);
      final cost95 = DistrictEconomyEngine.calculateBoostCost(0.95);
      final cost100 = DistrictEconomyEngine.calculateBoostCost(1.0);

      expect(cost0, equals(15000.0));
      expect(cost50, greaterThan(cost0));
      expect(cost95, greaterThan(cost50));
      expect(cost100, equals(0.0));
    });

    test('processDecay reduces share for districts above 10% and generates notifications', () {
      final initialShares = {'ikitelli_sanayi': 0.40, 'nisantasi_vitrin': 0.08};
      final initialEvents = <GameEventModel>[];

      // Use a random that always triggers decay (nextDouble() returns 0.05)
      final deterministicRng = _DeterministicRandom(0.05);

      final (updatedShares, updatedEvents) = DistrictEconomyEngine.processDecay(
        initialShares,
        initialEvents,
        random: deterministicRng,
      );

      expect(updatedShares['ikitelli_sanayi']!, lessThan(0.40));
      expect(updatedShares['ikitelli_sanayi']!, greaterThanOrEqualTo(0.05));
      // < 10% share should not decay
      expect(updatedShares['nisantasi_vitrin'], equals(0.08));
      expect(updatedEvents.isNotEmpty, isTrue);
      expect(updatedEvents.first.type, equals(GameEventType.badEvent));
    });
  });

  group('BlackMarketEngine Domain Tests', () {
    test('isNotaryBlocked probability respects riskLevelPercent', () {
      final lowRiskBlocked = BlackMarketEngine.isNotaryBlocked(10, random: _DeterministicRandom(0.05));
      final lowRiskPassed = BlackMarketEngine.isNotaryBlocked(10, random: _DeterministicRandom(0.20));

      expect(lowRiskBlocked, isTrue);
      expect(lowRiskPassed, isFalse);
    });

    test('processRaid handles change_vin with and without legal advisor', () {
      final car = CarModel(
        id: 'test_bm_car_1',
        brand: 'BMW',
        modelName: 'M5 F90',
        modelYear: 2021,
        bodyType: 'Sedan',
        colorHex: '0xFF000000',
        baseMarketValue: 2500000,
        currentPurchasePrice: 2000000,
        expertise: ExpertiseReport(
          engineCondition: 90,
          transmissionCondition: 90,
          tramerAmount: 0,
          mileage: 45000,
          isMileageTampered: false,
          bodyParts: {
            'Kaput': PartStatus.original,
            'Şasi/Podye': PartStatus.original,
          },
        ),
        isBlackMarket: true,
        blackMarketRiskType: 'change_vin',
        blackMarketRiskPercent: 80,
      );

      // 1. Without legal advisor (deterministic trigger: 0.10)
      final raidWithoutAdvisor = BlackMarketEngine.processRaid(
        car: car,
        hasLegalAdvisor: false,
        random: _DeterministicRandom(0.10),
      );

      expect(raidWithoutAdvisor.fine, equals(35000.0));
      expect(raidWithoutAdvisor.reputationLoss, equals(20));
      expect(raidWithoutAdvisor.shouldSeizeCar, isTrue);

      // 2. With legal advisor
      final raidWithAdvisor = BlackMarketEngine.processRaid(
        car: car,
        hasLegalAdvisor: true,
        random: _DeterministicRandom(0.10),
      );

      expect(raidWithAdvisor.fine, equals(35000.0 * 0.25));
      expect(raidWithAdvisor.reputationLoss, equals(5));
      expect(raidWithAdvisor.shouldSeizeCar, isFalse);
    });
  });
}

class _DeterministicRandom implements Random {
  final double fixedValue;
  _DeterministicRandom(this.fixedValue);

  @override
  int nextInt(int max) => (fixedValue * max).floor().clamp(0, max - 1);

  @override
  double nextDouble() => fixedValue;

  @override
  bool nextBool() => fixedValue >= 0.5;
}
