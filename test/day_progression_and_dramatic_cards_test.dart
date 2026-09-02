import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/dealership_model.dart';
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
      expect(state.pendingDramaticCard!.id, equals('milestone_day_1'));
    });

    test('2. advanceGameDay advances day counter and generates next day dilemma', () async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final notifier = container.read(gameProvider.notifier);

      expect(notifier.state.currentDay, equals(1));

      // Resolve Day 1 card
      notifier.dismissPendingDramaticCard();
      expect(notifier.state.pendingDramaticCard, isNull);

      // Advance game day
      notifier.advanceGameDay();

      expect(notifier.state.currentDay, equals(2));
      expect(notifier.state.pendingDramaticCard, isNotNull);
      expect(notifier.state.pendingDramaticCard!.dayNumber, equals(2));
    });

    test('3. Consecutive day advancements update currentDay continuously and generate unique dilemmas', () async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final notifier = container.read(gameProvider.notifier);

      for (int day = 2; day <= 10; day++) {
        notifier.dismissPendingDramaticCard();
        notifier.advanceGameDay();
        expect(notifier.state.currentDay, equals(day));
        expect(notifier.state.pendingDramaticCard, isNotNull);
        expect(notifier.state.pendingDramaticCard!.dayNumber, equals(day));
      }
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
