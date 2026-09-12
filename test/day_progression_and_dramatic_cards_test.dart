import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/domain/usecases/contextual_dilemma_pool.dart';
import 'package:galeriden/domain/usecases/dramatic_card_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Day Progression Counter & Dramatic Cards Life-Cycle Tests', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      container.dispose();
    });

    test('1. Day 1 starts with seeded dramatic decision card', () async {
      // Let async _loadState complete
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final state = container.read(gameProvider);

      expect(state.currentDay, equals(1));
      expect(state.pendingDramaticCard, isNotNull);
      expect(state.pendingDramaticCard!.dayNumber, equals(1));
      expect(state.pendingDramaticCard!.id, equals('rookie_tea_mahmut'));
    });

    test('2. advanceGameDay triggers dilemma only when critical conditions occur', () async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final notifier = container.read(gameProvider.notifier);

      expect(notifier.state.currentDay, equals(1));

      // Resolve Day 1 card
      notifier.dismissPendingDramaticCard();
      expect(notifier.state.pendingDramaticCard, isNull);

      // Advance game day to Day 2 (Rookie onboarding critical condition)
      notifier.advanceGameDay();

      expect(notifier.state.currentDay, equals(2));
      expect(notifier.state.pendingDramaticCard, isNotNull);
      expect(notifier.state.pendingDramaticCard!.dayNumber, equals(2));
      expect(notifier.state.pendingDramaticCard!.id, equals('rookie_mentor_cemil'));

      // Dismiss Day 2 card
      notifier.dismissPendingDramaticCard();
      expect(notifier.state.pendingDramaticCard, isNull);

      // Advance to Day 3 (Day 3 is rookie onboarding day 3: rookie_first_cleaning)
      notifier.advanceGameDay(); // Day 3
      expect(notifier.state.pendingDramaticCard, isNotNull);
      expect(notifier.state.pendingDramaticCard!.id, equals('rookie_first_cleaning'));

      // Dismiss Day 3 card
      notifier.dismissPendingDramaticCard();
      expect(notifier.state.pendingDramaticCard, isNull);

      // Advance to Day 4: Past rookie onboarding (Day 4) and no crises active -> MUST BE NULL
      notifier.advanceGameDay(); // Day 4
      expect(notifier.state.pendingDramaticCard, isNull);
    });

    test('3. Crisis situations (debt, damaged fleet) reliably trigger critical dilemma cards', () async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final notifier = container.read(gameProvider.notifier);

      // Clear Day 1 card and move past rookie days
      notifier.dismissPendingDramaticCard();
      notifier.state = notifier.state.copyWith(currentDay: 10, level: 3);

      // Normal operations: no pending card
      notifier.advanceGameDay(); // Day 11
      expect(notifier.state.pendingDramaticCard, isNull);

      // 1. Cash Crisis: balance drops to ₺12,000
      notifier.state = notifier.state.copyWith(balance: 12000.0);
      notifier.advanceGameDay(); // Day 12
      expect(notifier.state.pendingDramaticCard, isNotNull);
      expect(
        ContextualDilemmaPool.cashCrisisCards.any((c) => c.id == notifier.state.pendingDramaticCard!.id),
        isTrue,
      );

      // Clear crisis card and restore balance
      notifier.dismissPendingDramaticCard();
      notifier.state = notifier.state.copyWith(balance: 100000.0);
      notifier.advanceGameDay(); // Day 13
      expect(notifier.state.pendingDramaticCard, isNull);
    });

    test('4. Invariant Rules: Zero Unicode Emojis and Zero Parentheses in Day 1 Card & Outcomes', () {
      final base = DealershipModel.initial();
      final day1 = DramaticCardEngine.generateDailyDilemma(1, base);

      final emojiRegex = RegExp(
        r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F900}-\u{1F9FF}\u{1F018}-\u{1F270}\u{23E9}-\u{23FA}]',
        unicode: true,
      );
      final parenthesesRegex = RegExp(r'[\(\)]');

      expect(emojiRegex.hasMatch(day1.title), isFalse);
      expect(parenthesesRegex.hasMatch(day1.title), isFalse);
      expect(emojiRegex.hasMatch(day1.dialogue), isFalse);
      expect(parenthesesRegex.hasMatch(day1.dialogue), isFalse);

      for (final choice in day1.choices) {
        expect(emojiRegex.hasMatch(choice.label), isFalse);
        expect(parenthesesRegex.hasMatch(choice.label), isFalse);
        for (final outcome in choice.outcomes) {
          expect(emojiRegex.hasMatch(outcome.title), isFalse);
          expect(parenthesesRegex.hasMatch(outcome.title), isFalse);
          expect(emojiRegex.hasMatch(outcome.message), isFalse);
          expect(parenthesesRegex.hasMatch(outcome.message), isFalse);
        }
      }
    });
  });
}
