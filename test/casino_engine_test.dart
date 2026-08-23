import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/casino_game_model.dart';
import 'package:galeriden/domain/usecases/casino_engine.dart';

void main() {
  group('CasinoEngine 7 Mini-Games Unit Tests', () {
    test('1. Valet Baccarat computes hands, rules, and payouts correctly', () {
      final rng = math.Random(101);

      // Play 100 hands of Baccarat
      for (int i = 0; i < 100; i++) {
        final res = CasinoEngine.playBaccarat(
          betAmount: 10000,
          choice: BaccaratBetChoice.player,
          rng: rng,
        );

        expect(res.playerCards.length, inInclusiveRange(2, 3));
        expect(res.bankerCards.length, inInclusiveRange(2, 3));
        expect(res.playerTotal, inInclusiveRange(0, 9));
        expect(res.bankerTotal, inInclusiveRange(0, 9));

        if (res.winningChoice == BaccaratBetChoice.player) {
          expect(res.isWin, isTrue);
          expect(res.payoutAmount, equals(20000.0));
        } else {
          expect(res.isWin, isFalse);
          expect(res.payoutAmount, equals(0.0));
        }
      }
    });

    test('1b. Valet Baccarat Pink Slip wager awards cash and bonus car on Tie win', () {
      final sampleCar = CasinoEngine.createRewardCar(
        brand: 'BMW',
        modelName: 'M3 Competition G80',
        year: 2023,
        price: 2000000.0,
      );

      final rng = math.Random(42);
      bool sawTie = false;

      for (int i = 0; i < 500; i++) {
        final res = CasinoEngine.playBaccarat(
          betAmount: 0,
          choice: BaccaratBetChoice.tie,
          wageredCar: sampleCar,
          rng: rng,
        );

        if (res.winningChoice == BaccaratBetChoice.tie) {
          sawTie = true;
          expect(res.isWin, isTrue);
          expect(res.payoutAmount, equals(sampleCar.price * 8.0));
          expect(res.wonCar, isNotNull);
          expect(res.wonCar!.brand, equals('Porsche'));
          break;
        }
      }

      expect(sawTie, isTrue);
    });

    test('2. Street Craps evaluates come-out and point phases', () {
      final rng = math.Random(55);

      // Test natural wins (7 or 11)
      int rolls = 0;
      bool sawNatural = false;
      bool sawCraps = false;
      bool sawPointSet = false;

      while (rolls < 200 && (!sawNatural || !sawCraps || !sawPointSet)) {
        rolls++;
        final comeOut = CasinoEngine.rollStreetCraps(
          currentPhase: CrapsPhase.comeOut,
          betAmount: 50000,
          rng: rng,
        );

        expect(comeOut.sum, inInclusiveRange(2, 12));

        if (comeOut.sum == 7 || comeOut.sum == 11) {
          sawNatural = true;
          expect(comeOut.isWin, isTrue);
          expect(comeOut.payoutMultiplier, equals(2.0));
          expect(comeOut.nextPhase, equals(CrapsPhase.comeOut));
        } else if (comeOut.sum == 2 || comeOut.sum == 3 || comeOut.sum == 12) {
          sawCraps = true;
          expect(comeOut.isLoss, isTrue);
          expect(comeOut.payoutMultiplier, equals(0.0));
          expect(comeOut.nextPhase, equals(CrapsPhase.comeOut));
        } else {
          sawPointSet = true;
          expect(comeOut.isWin, isFalse);
          expect(comeOut.isLoss, isFalse);
          expect(comeOut.point, equals(comeOut.sum));
          expect(comeOut.nextPhase, equals(CrapsPhase.pointPhase));
        }
      }

      expect(sawNatural, isTrue);
      expect(sawCraps, isTrue);
      expect(sawPointSet, isTrue);
    });

    test('3. Hi-Lo Vites progresses streaks and geometric multipliers', () {
      final rng = math.Random(77);
      const startCard = CasinoCard(suit: 'spades', rank: 2, label: '2', baccaratValue: 2);

      // Guessing Higher on a 2 should almost always succeed
      final res = CasinoEngine.guessHiLo(
        currentCard: startCard,
        guessHigher: true,
        currentStreak: 0,
        rng: rng,
      );

      expect(res.currentStreak, inInclusiveRange(0, 1));
      if (res.isCorrect) {
        expect(res.currentMultiplier, equals(1.5));
        expect(res.isBust, isFalse);
      }
    });

    test('4. Piston Plinko generates valid paths and bounded multipliers', () {
      final rng = math.Random(88);

      for (int i = 0; i < 100; i++) {
        final res = CasinoEngine.dropPlinkoBuji(
          betAmount: 10000,
          rows: 8,
          rng: rng,
        );

        expect(res.pathOffsets.length, equals(8));
        expect(res.slotIndex, inInclusiveRange(0, 8));
        expect(res.multiplier, inInclusiveRange(0.2, 1000.0));
        expect(res.payoutAmount, equals(10000 * res.multiplier));
      }
    });

    test('5. Kayip Bagaj Ruleti produces valid slices and bankrupt logic', () {
      final rng = math.Random(99);
      bool sawMultiplier = false;

      for (int i = 0; i < 50; i++) {
        final res = CasinoEngine.spinLuckyWheel(
          betAmount: 25000,
          rng: rng,
        );

        expect(res.sliceIndex, inInclusiveRange(0, CasinoEngine.wheelSlices.length - 1));
        if (!res.isBankrupt && res.slice.multiplier > 0) {
          sawMultiplier = true;
          expect(res.payoutAmount, greaterThan(0));
        }
      }

      expect(sawMultiplier, isTrue);
    });

    test('6. Sasi Kazi Kazan generates 3x3 grid and calculates matches', () {
      final rng = math.Random(123);

      for (int i = 0; i < 50; i++) {
        final res = CasinoEngine.generateScratchCard(
          cardCost: 15000,
          rng: rng,
        );

        expect(res.grid.length, equals(9));
        if (res.isWin) {
          expect(res.matchingSymbol, isNotNull);
          final matches = res.grid.where((s) => s.symbol == res.matchingSymbol).length;
          expect(matches, equals(3));
          expect(res.payoutAmount, greaterThan(0));
        } else {
          expect(res.payoutAmount, equals(0));
        }
      }
    });

    test('7. Cifte Katla (Double or Nothing) produces 50-50 outcomes', () {
      final rng = math.Random(456);
      int wins = 0;
      const rounds = 500;

      for (int i = 0; i < rounds; i++) {
        final won = CasinoEngine.flipDoubleOrNothing(guessHeads: true, rng: rng);
        if (won) wins++;
      }

      // Wins should be approximately 50% (+/- 8%)
      expect(wins, inInclusiveRange(210, 290));
    });
  });
}
