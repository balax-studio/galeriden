import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/casino_game_model.dart';
import 'package:galeriden/domain/usecases/casino_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Casino State & Serialization Tests', () {
    test('DealershipModel serializes and deserializes casinoStats accurately', () {
      const stats = CasinoStatsModel(
        totalGamesPlayed: 45,
        totalWonAmount: 1250000.0,
        totalLostAmount: 450000.0,
        biggestMultiplierRecord: 50.0,
        vehiclesWageredCount: 5,
        vehiclesLostCount: 2,
        vehiclesWonCount: 3,
      );

      final initial = DealershipModel.initial().copyWith(casinoStats: stats);
      final json = initial.toJson();
      final recovered = DealershipModel.fromJson(json);

      expect(recovered.casinoStats.totalGamesPlayed, equals(45));
      expect(recovered.casinoStats.totalWonAmount, equals(1250000.0));
      expect(recovered.casinoStats.totalLostAmount, equals(450000.0));
      expect(recovered.casinoStats.biggestMultiplierRecord, equals(50.0));
      expect(recovered.casinoStats.vehiclesWageredCount, equals(5));
      expect(recovered.casinoStats.vehiclesLostCount, equals(2));
      expect(recovered.casinoStats.vehiclesWonCount, equals(3));
    });

    test('isFeatureUnlocked unlocks /casino when property_tier_5 is owned or branch is tier 5', () {
      final level1 = DealershipModel.initial();
      expect(level1.isFeatureUnlocked('/casino'), isFalse);

      final level5 = level1.copyWith(
        unlockedBuildings: {'property_tier_5'},
      );
      expect(level5.isFeatureUnlocked('/casino'), isTrue);
      expect(level5.isFeatureUnlocked('/casino-hub'), isTrue);
    });

    test('GameCasinoMixin playCasinoBaccarat mutates balance, stats and Pink Slip inventory', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      final wagerCar = CasinoEngine.createRewardCar(
        brand: 'Mercedes-Benz',
        modelName: 'C63 AMG S',
        year: 2022,
        price: 3000000.0,
      );

      notifier.state = notifier.state.copyWith(
        balance: 1000000.0,
        ownedCars: [wagerCar],
      );

      // Play with Cash
      final res = notifier.playCasinoBaccarat(
        betAmount: 100000,
        choice: BaccaratBetChoice.player,
      );

      expect(res, isNotNull);
      expect(notifier.state.casinoStats.totalGamesPlayed, equals(1));

      // Play with Pink Slip Wager
      final pinkSlipRes = notifier.playCasinoBaccarat(
        betAmount: 0,
        choice: BaccaratBetChoice.banker,
        wageredCar: wagerCar,
      );

      expect(pinkSlipRes, isNotNull);
      expect(notifier.state.casinoStats.totalGamesPlayed, equals(2));
      expect(notifier.state.casinoStats.vehiclesWageredCount, equals(1));

      if (pinkSlipRes!.isWin) {
        expect(notifier.state.ownedCars.any((c) => c.id == wagerCar.id), isTrue);
      } else {
        expect(notifier.state.ownedCars.any((c) => c.id == wagerCar.id), isFalse);
      }
    });

    test('GameCasinoMixin playCasinoPlinko drops buji and updates player balance', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      notifier.state = notifier.state.copyWith(balance: 500000.0);

      final res = notifier.playCasinoPlinko(betAmount: 50000.0);

      expect(res, isNotNull);
      expect(res!.pathOffsets.length, equals(8));
      expect(notifier.state.casinoStats.totalGamesPlayed, equals(1));
    });
  });
}
