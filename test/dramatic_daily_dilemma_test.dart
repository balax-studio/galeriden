import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/dramatic_card_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/domain/usecases/dramatic_card_engine.dart';
import 'package:galeriden/core/localization/translations/tr_translations.dart';
import 'package:galeriden/core/localization/translations/en_translations.dart';
import 'package:galeriden/core/localization/translations/de_translations.dart';
import 'package:galeriden/core/localization/translations/es_translations.dart';
import 'package:galeriden/core/localization/translations/pt_translations.dart';
import 'package:galeriden/core/localization/translations/ru_translations.dart';
import 'package:galeriden/core/localization/translations/ar_translations.dart';

void main() {
  group('365-Day Daily Dilemma Engine Tests', () {
    late DealershipModel baseState;

    setUp(() {
      baseState = DealershipModel.initial().copyWith(
        balance: 100000,
        reputationScore: 50,
        currentDay: 1,
      );
    });

    test('Generates valid unique dilemma cards for each of the 365 days', () {
      final seenCardIds = <String>{};

      for (int day = 1; day <= 365; day++) {
        final card = DramaticCardEngine.generateDailyDilemma(day, baseState);

        expect(card.id, isNotEmpty);
        expect(card.title, isNotEmpty);
        expect(card.dialogue, isNotEmpty);
        expect(card.dayNumber, equals(day));
        expect(card.choices, isNotEmpty);
        expect(card.choices.length, greaterThanOrEqualTo(2));

        for (final choice in card.choices) {
          expect(choice.id, isNotEmpty);
          expect(choice.label, isNotEmpty);
          expect(choice.outcomes, isNotEmpty);
          for (final outcome in choice.outcomes) {
            expect(outcome.title, isNotEmpty);
            expect(outcome.message, isNotEmpty);
          }
        }

        seenCardIds.add(card.id);
      }

      // Ensure full 365 unique daily card IDs exist
      expect(seenCardIds.length, equals(365));
    });

    test('Milestone days produce expected narrative cards', () {
      // Day 1: First customer / tea ceremony
      final day1 = DramaticCardEngine.generateDailyDilemma(1, baseState);
      expect(day1.id, equals('milestone_day_1'));
      expect(day1.category, equals(DramaticCategory.legacy));
      expect(day1.choices.length, equals(3));

      // Day 7: Sanayi çırağı
      final day7 = DramaticCardEngine.generateDailyDilemma(7, baseState);
      expect(day7.id, equals('milestone_day_7'));
      expect(day7.category, equals(DramaticCategory.comedy));

      // Day 14: Vergi müfettişi
      final day14 = DramaticCardEngine.generateDailyDilemma(14, baseState);
      expect(day14.id, equals('milestone_day_14'));
      expect(day14.category, equals(DramaticCategory.loss));

      // Day 30: Galericiler derneği
      final day30 = DramaticCardEngine.generateDailyDilemma(30, baseState);
      expect(day30.id, equals('milestone_day_30'));

      // Day 50: Gizemli koleksiyoncu
      final day50 = DramaticCardEngine.generateDailyDilemma(50, baseState);
      expect(day50.id, equals('milestone_day_50'));
      expect(day50.category, equals(DramaticCategory.opportunity));

      // Day 100: Şubeleşme
      final day100 = DramaticCardEngine.generateDailyDilemma(100, baseState);
      expect(day100.id, equals('milestone_day_100'));

      // Day 365: Yıl sonu esnaf balosu
      final day365 = DramaticCardEngine.generateDailyDilemma(365, baseState);
      expect(day365.id, equals('milestone_day_365'));
      expect(day365.category, equals(DramaticCategory.legacy));
    });

    test('Choice resolution returns proper success and failure outcomes', () {
      final card = DramaticCardEngine.generateDailyDilemma(1, baseState);
      final firstChoice = card.choices.first;

      final res = DramaticCardEngine.resolveChoice(
        baseState,
        card,
        firstChoice,
      );

      expect(res.outcome.title, isNotEmpty);
      expect(res.outcome.message, isNotEmpty);
      expect(res.choice.id, equals(firstChoice.id));
      expect(res.card.id, equals(card.id));
    });

    test('Zero Unicode Emojis and Zero Parentheses Invariant across all 365 days', () {
      final emojiRegex = RegExp(
        r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F900}-\u{1F9FF}\u{1F018}-\u{1F270}\u{23E9}-\u{23FA}]',
        unicode: true,
      );
      final parenthesesRegex = RegExp(r'[\(\)]');

      for (int day = 1; day <= 365; day++) {
        final card = DramaticCardEngine.generateDailyDilemma(day, baseState);

        // Check Card Title
        expect(emojiRegex.hasMatch(card.title), isFalse,
            reason: 'Card title on day $day contains emoji: ${card.title}');
        expect(parenthesesRegex.hasMatch(card.title), isFalse,
            reason: 'Card title on day $day contains parentheses: ${card.title}');

        // Check Dialogue
        expect(emojiRegex.hasMatch(card.dialogue), isFalse,
            reason: 'Card dialogue on day $day contains emoji');
        expect(parenthesesRegex.hasMatch(card.dialogue), isFalse,
            reason: 'Card dialogue on day $day contains parentheses: ${card.dialogue}');

        // Check Foreshadowing
        expect(emojiRegex.hasMatch(card.foreshadowHint), isFalse,
            reason: 'Card foreshadowHint on day $day contains emoji');
        expect(parenthesesRegex.hasMatch(card.foreshadowHint), isFalse,
            reason: 'Card foreshadowHint on day $day contains parentheses');

        // Check Choices
        for (final choice in card.choices) {
          expect(emojiRegex.hasMatch(choice.label), isFalse,
              reason: 'Choice label on day $day contains emoji: ${choice.label}');
          expect(parenthesesRegex.hasMatch(choice.label), isFalse,
              reason: 'Choice label on day $day contains parentheses: ${choice.label}');
          expect(emojiRegex.hasMatch(choice.shortDescription), isFalse,
              reason: 'Choice desc on day $day contains emoji');
          expect(parenthesesRegex.hasMatch(choice.shortDescription), isFalse,
              reason: 'Choice desc on day $day contains parentheses: ${choice.shortDescription}');

          for (final outcome in choice.outcomes) {
            expect(emojiRegex.hasMatch(outcome.title), isFalse);
            expect(parenthesesRegex.hasMatch(outcome.title), isFalse);
            expect(emojiRegex.hasMatch(outcome.message), isFalse);
            expect(parenthesesRegex.hasMatch(outcome.message), isFalse);
          }
        }
      }
    });

    test('Simultaneous 7-Language Localization covers all new dilemma keys', () {
      final requiredKeys = [
        'category_comedy',
        'category_opportunity',
        'daily_dilemma_badge',
        'daily_dilemma_action_prompt',
        'daily_dilemma_sealed',
        'daily_dilemma_sealed_desc',
      ];

      final allTranslations = [
        ('tr', trTranslations),
        ('en', enTranslations),
        ('de', deTranslations),
        ('es', esTranslations),
        ('pt', ptTranslations),
        ('ru', ruTranslations),
        ('ar', arTranslations),
      ];

      for (final (langCode, translations) in allTranslations) {
        for (final key in requiredKeys) {
          expect(translations.containsKey(key), isTrue,
              reason: 'Language $langCode is missing translation key $key');
          expect(translations[key], isNotEmpty,
              reason: 'Language $langCode has empty translation for $key');
          // Ensure zero parentheses in translations
          expect(translations[key]!.contains('(') || translations[key]!.contains(')'), isFalse,
              reason: 'Language $langCode contains parentheses in key $key: ${translations[key]}');
        }
      }
    });
  });
}
