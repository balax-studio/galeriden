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
        final card = DramaticCardEngine.generateCalendarDilemma(day);

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

    test('Milestone and key days produce expected general life narrative cards', () {
      // Day 1: Yanlış Gruba Ses Kaydı
      final day1 = DramaticCardEngine.generateCalendarDilemma(1);
      expect(day1.id, equals('life_card_day_1'));
      expect(day1.title, equals('Yanlış Gruba Ses Kaydı'));
      expect(day1.choices.length, greaterThanOrEqualTo(2));

      // Day 2: Eski Sevgilinin 4 Yıllık Fotoğrafı
      final day2 = DramaticCardEngine.generateCalendarDilemma(2);
      expect(day2.id, equals('life_card_day_2'));
      expect(day2.title, equals('Eski Sevgilinin 4 Yıllık Fotoğrafı'));

      // Day 3: Akraba WhatsApp Grubu Kavgası
      final day3 = DramaticCardEngine.generateCalendarDilemma(3);
      expect(day3.id, equals('life_card_day_3'));
      expect(day3.title, equals('Akraba WhatsApp Grubu Kavgası'));

      // Day 6: Matrix Kırmızı Hap İkilemi
      final day6 = DramaticCardEngine.generateCalendarDilemma(6);
      expect(day6.id, equals('life_card_day_6'));
      expect(day6.title, equals('Matrix Kırmızı Hap İkilemi'));

      // Day 15: Ezel Replikleriyle Teselli
      final day15 = DramaticCardEngine.generateCalendarDilemma(15);
      expect(day15.id, equals('life_card_day_15'));
      expect(day15.title, equals('Ezel Replikleriyle Teselli'));

      // Day 30: Ekran Süresi Raporu Şoku
      final day30 = DramaticCardEngine.generateCalendarDilemma(30);
      expect(day30.id, equals('life_card_day_30'));
      expect(day30.title, equals('Ekran Süresi Raporu Şoku'));

      // Day 61: Kurtlar Vadisi Çakır Ruhu
      final day61 = DramaticCardEngine.generateCalendarDilemma(61);
      expect(day61.id, equals('life_card_day_61'));
      expect(day61.title, equals('Kurtlar Vadisi Çakır Ruhu'));

      // Day 181: İlk Buluşmada Hesabı Kim Öder
      final day181 = DramaticCardEngine.generateCalendarDilemma(181);
      expect(day181.id, equals('life_card_day_181'));
      expect(day181.title, equals('İlk Buluşmada Hesabı Kim Öder'));

      // Day 365: Büyük 365 Gün Finali ve Yaşam Zaferi
      final day365 = DramaticCardEngine.generateCalendarDilemma(365);
      expect(day365.id, equals('life_card_day_365'));
      expect(day365.title, equals('Büyük 365 Gün Finali ve Yaşam Zaferi'));
      expect(day365.category, equals(DramaticCategory.legacy));
    });

    test('Choice resolution returns proper success and failure outcomes', () {
      final card = DramaticCardEngine.generateCalendarDilemma(1);
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
        final card = DramaticCardEngine.generateCalendarDilemma(day);

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

    test('Authentic Turkish general life dilemma cards are accessible in calendar cycles', () {
      final generatedTitles = <String>{};
      for (int day = 1; day <= 365; day++) {
        final card = DramaticCardEngine.generateCalendarDilemma(day);
        generatedTitles.add(card.title);
      }

      expect(generatedTitles.contains('Yanlış Gruba Ses Kaydı'), isTrue);
      expect(generatedTitles.contains('LinkedIn Başarı Hikayesi Balonu'), isTrue);
      expect(generatedTitles.contains('Apartman Yöneticiliği Seçimi'), isTrue);
      expect(generatedTitles.contains('Avrupa Yakası Burhan Tripleri'), isTrue);
      expect(generatedTitles.contains('Plaza Türkçesi Maruziyeti'), isTrue);
      expect(generatedTitles.contains('Efsane Cuma İndirimi Hipnozu'), isTrue);
      expect(generatedTitles.contains('Her Şey Dahil Otel Yemek Kuyruğu'), isTrue);
      expect(generatedTitles.contains('İlk Buluşmada Hesabı Kim Öder'), isTrue);
      expect(generatedTitles.contains('Dolmuşta Müsait Bir Yerde Diyememek'), isTrue);
      expect(generatedTitles.contains('Otuz Yaş Doğum Günü Paniği'), isTrue);
      expect(generatedTitles.contains('Pazartesi Başlayan Diyetin Salı Akşamı Çöküşü'), isTrue);
      expect(generatedTitles.contains('Kredi Kartı Asgarisini Ödeme Ritüeli'), isTrue);
      expect(generatedTitles.contains('Büyük 365 Gün Finali ve Yaşam Zaferi'), isTrue);
    });
  });
}
