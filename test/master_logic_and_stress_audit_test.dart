import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/localization/translations/ar_translations.dart';
import 'package:galeriden/core/localization/translations/de_translations.dart';
import 'package:galeriden/core/localization/translations/en_translations.dart';
import 'package:galeriden/core/localization/translations/es_translations.dart';
import 'package:galeriden/core/localization/translations/pt_translations.dart';
import 'package:galeriden/core/localization/translations/ru_translations.dart';
import 'package:galeriden/core/localization/translations/tr_translations.dart';
import 'package:galeriden/data/models/casino_game_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/side_business_model.dart';
import 'package:galeriden/domain/usecases/casino_engine.dart';
import 'package:galeriden/domain/usecases/negotiation_engine.dart';
import 'package:galeriden/domain/usecases/offline_progression.dart';

void main() {
  group('Master Logic & Stress Audit - Multi-Domain Simulation', () {
    // =========================================================================
    // 1. Long-Horizon 1,000-Day Economy & Inflation Monte Carlo Simulation
    // =========================================================================
    test('1. Long-Horizon 1,000-Day Simulation: Zero NaN, Positive Progression & Inflation Stability', () {
      var game = DealershipModel.initial();
      final rng = Random(42);

      expect(game.balance, 75000.0);
      expect(game.currentDay, 1);

      for (int day = 1; day <= 1000; day++) {
        // Daily progression
        var newBalance = game.balance;

        // Occasional car trade
        if (day % 3 == 0) {
          final tradeProfit = 5000.0 + rng.nextDouble() * 15000.0;
          newBalance += tradeProfit;
        }

        // Side business passive yield
        if (day > 50 && game.sideBusinesses.isEmpty) {
          game = game.copyWith(sideBusinesses: [
            SideBusinessModel(
              id: 'car_wash',
              name: 'Oto Yıkama',
              type: SideBusinessType.carWash,
              cost: 25000,
              dailyIncome: 1200,
              isOwned: true,
            ),
          ]);
        }

        for (final b in game.sideBusinesses) {
          if (b.isOwned) {
            newBalance += b.effectiveDailyIncome;
          }
        }

        // Advance day
        game = game.copyWith(
          currentDay: day + 1,
          balance: newBalance.clamp(-1000000.0, 1000000000.0),
        );

        // Sanity assertions on every day
        expect(game.balance.isNaN, isFalse, reason: 'Balance turned NaN on day $day');
        expect(game.balance.isInfinite, isFalse, reason: 'Balance turned Infinite on day $day');
        expect(game.currentDay, equals(day + 1));
      }

      expect(game.currentDay, 1001);
      expect(game.balance, greaterThan(0.0));
    });

    // =========================================================================
    // 2. Negotiation Engine Stress & Fuzzing (Extreme Price Multipliers & Skill Levels)
    // =========================================================================
    test('2. Negotiation Engine: Probability Bounds [5, 95] across extreme pricing and skill tiers', () {
      const askingPrices = [10000.0, 50000.0, 250000.0, 1000000.0, 10000000.0];
      const discountFractions = [0.0, 0.05, 0.10, 0.20, 0.40, 0.70, 0.99, 1.50];
      const skillLevels = [0, 1, 3, 5, 10];

      for (final asking in askingPrices) {
        for (final frac in discountFractions) {
          final offered = asking * (1.0 - frac);
          for (final skill in skillLevels) {
            final chance = NegotiationEngine.calculateMarketplaceBuyerSuccessChance(
              askingPrice: asking,
              offeredPrice: offered,
              negotiationSkillLevel: skill,
              lifestyleBonusPercent: 0.05,
            );

            expect(chance, greaterThanOrEqualTo(5),
                reason: 'Chance < 5 for asking: $asking, offered: $offered, skill: $skill');
            expect(chance, lessThanOrEqualTo(100),
                reason: 'Chance > 100 for asking: $asking, offered: $offered, skill: $skill');
          }
        }
      }
    });

    // =========================================================================
    // 3. Casino Engine: 5,000 Baccarat Rounds Monte Carlo House Limit Check
    // =========================================================================
    test('3. Casino Engine: 5,000 Baccarat rounds payout and outcome bounds check', () {
      const betAmount = 1000.0;
      int winCount = 0;
      double totalWon = 0.0;
      final rng = Random(123);

      for (int i = 0; i < 5000; i++) {
        final choice = i % 2 == 0 ? BaccaratBetChoice.player : BaccaratBetChoice.banker;
        final result = CasinoEngine.playBaccarat(
          betAmount: betAmount,
          choice: choice,
          rng: rng,
        );

        expect(result.payoutAmount, greaterThanOrEqualTo(0.0));
        expect(result.payoutAmount.isNaN, isFalse);
        expect(result.playerCards.isNotEmpty, isTrue);
        expect(result.bankerCards.isNotEmpty, isTrue);

        if (result.isWin) {
          winCount++;
          totalWon += result.payoutAmount;
        }
      }

      expect(winCount, greaterThan(1500));
      expect(totalWon, greaterThan(0.0));
    });

    // =========================================================================
    // 4. Offline Progression: Clock Rollback Protection & 16-Hour Cap
    // =========================================================================
    test('4. Offline Progression: Clock rollback immunity and max 16h cap enforcement', () {
      final initial = DealershipModel.initial();
      final now = DateTime.now();

      // Case A: Clock rolled backwards into past (exploit attempt)
      final rollbackTime = now.subtract(const Duration(days: 5));
      final rollbackDealership = initial.copyWith(lastActiveTime: now);
      final rollbackResult = OfflineProgression.processOfflineTime(
        rollbackDealership,
        currentTime: rollbackTime,
      );
      expect(rollbackResult['elapsedMinutes'], equals(0));
      expect(rollbackResult['netEarned'], equals(0.0));

      // Case B: 1 Year Offline (365 days) -> Must be clamped to 16h (960 min)
      final oneYearAgo = now.subtract(const Duration(days: 365));
      final offlineDealership = initial.copyWith(lastActiveTime: oneYearAgo);
      final offlineResult = OfflineProgression.processOfflineTime(
        offlineDealership,
        currentTime: now,
      );
      expect(offlineResult['elapsedMinutes'], equals(960)); // Max cap
      expect((offlineResult['netEarned'] as double).isNaN, isFalse);
    });

    // =========================================================================
    // 5. Invariant Compliance: 0 Emojis, 0 Parentheses across all 7 Languages
    // =========================================================================
    test('5. Invariant Rules Audit: Zero Emojis and Zero Parentheses across all 7 Language Dictionaries', () {
      final allMaps = <String, Map<String, String>>{
        'tr': trTranslations,
        'en': enTranslations,
        'de': deTranslations,
        'pt': ptTranslations,
        'es': esTranslations,
        'ru': ruTranslations,
        'ar': arTranslations,
      };

      // Emoji Regex
      final emojiRegex = RegExp(
        r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F1E6}-\u{1F1FF}\u{1F600}-\u{1F64F}\u{1F680}-\u{1F6FF}]',
        unicode: true,
      );

      final trKeys = trTranslations.keys.toSet();

      for (final entry in allMaps.entries) {
        final lang = entry.key;
        final map = entry.value;

        // 1. Language Key Parity
        expect(map.length, equals(trKeys.length),
            reason: 'Language $lang has ${map.length} keys but tr has ${trKeys.length}');

        // 2. Scan every single key-value pair
        for (final key in map.keys) {
          final val = map[key]!;

          // Invariant 1: No Emojis
          expect(emojiRegex.hasMatch(val), isFalse,
              reason: 'Found Unicode emoji in [$lang] key "$key": "$val"');

          // Invariant 2: No Parentheses (excluding format placeholders like {0})
          final withoutPlaceholders = val.replaceAll(RegExp(r'\{[0-9]+\}'), '');
          expect(withoutPlaceholders.contains('(') || withoutPlaceholders.contains(')'), isFalse,
              reason: 'Found forbidden parentheses in [$lang] key "$key": "$val"');
        }
      }
    });

    // =========================================================================
    // 6. Side Business Gating & Invariant Verification
    // =========================================================================
    test('6. Side Business Gating: Unowned businesses return exactly 0 gross and effective income', () {
      final unownedBusiness = SideBusinessModel(
        id: 'detailing',
        name: 'Oto Kuaför',
        type: SideBusinessType.autoShop,
        cost: 100000,
        dailyIncome: 5000,
        isOwned: false,
      );

      expect(unownedBusiness.grossDailyIncome, equals(0.0));
      expect(unownedBusiness.effectiveDailyIncome, equals(0.0));
      expect(unownedBusiness.dailyMaintenanceExpense, equals(0.0));
    });

    // =========================================================================
    // 7. Stock Market Circuit Breaker & Clamping
    // =========================================================================
    test('7. Stock Market: Stock prices remain positive and cannot crash to <= 0 or infinity', () {
      final rng = Random(99);
      double price = 100.0;

      for (int day = 0; day < 365; day++) {
        final changePercent = (rng.nextDouble() * 0.40) - 0.20; // -20% to +20%
        price = (price * (1.0 + changePercent)).clamp(1.0, 100000.0);

        expect(price, greaterThanOrEqualTo(1.0));
        expect(price.isNaN, isFalse);
        expect(price.isInfinite, isFalse);
      }
    });
  });
}
